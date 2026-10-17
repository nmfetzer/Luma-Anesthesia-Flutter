-- Academy is separate from CE, clinical subscriptions, and local owner review.
-- All content remains private; client access is through narrowly scoped RPCs.
create schema if not exists academy_private;
revoke all on schema academy_private from public, anon, authenticated;

create table academy_private.access (
  user_id uuid primary key references auth.users(id) on delete cascade,
  access_kind text not null check (access_kind in ('owner_review','purchase')),
  expires_at timestamptz,
  revoked_at timestamptz
);
create table academy_private.packages (
  level_id text not null,
  version text not null,
  position integer not null,
  title text not null,
  content jsonb not null,
  available boolean not null default false,
  primary key(level_id,version)
);
create unique index academy_one_current_version on academy_private.packages(level_id) where available;
create table academy_private.documents (
  level_id text not null,
  version text not null,
  kind text not null check(kind in ('Study guide','Flashcards','Practice questions','Mastery checkpoint')),
  pdf_base64 text not null,
  primary key(level_id,version,kind),
  foreign key(level_id,version) references academy_private.packages(level_id,version)
);
create table academy_private.marks (
  user_id uuid not null references auth.users(id) on delete cascade,
  level_id text not null,
  version text not null,
  kind text not null check(kind in ('lessons','cards')),
  item_id text not null,
  created_at timestamptz not null default now(),
  primary key(user_id,level_id,version,kind,item_id),
  foreign key(level_id,version) references academy_private.packages(level_id,version)
);
create table academy_private.attempts (
  user_id uuid not null references auth.users(id) on delete cascade,
  attempt_id uuid not null,
  level_id text not null,
  version text not null,
  kind text not null check(kind in ('practice','checkpoint')),
  scope text not null,
  answers jsonb not null,
  result jsonb not null,
  created_at timestamptz not null default now(),
  primary key(user_id,attempt_id),
  foreign key(level_id,version) references academy_private.packages(level_id,version)
);
alter table academy_private.access enable row level security;
alter table academy_private.packages enable row level security;
alter table academy_private.documents enable row level security;
alter table academy_private.marks enable row level security;
alter table academy_private.attempts enable row level security;
revoke all on all tables in schema academy_private from public,anon,authenticated;

create function academy_private.assert_access() returns uuid
language plpgsql security definer set search_path='' as $$
declare u uuid := auth.uid();
begin
  if u is null or not exists (
    select 1 from academy_private.access a where a.user_id=u and a.revoked_at is null
    and (a.expires_at is null or a.expires_at > now())
  ) then raise exception 'Academy access required' using errcode='42501'; end if;
  return u;
end $$;

create function academy_private.package(p_level text,p_version text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare c jsonb;
begin
  perform academy_private.assert_access();
  select content into c from academy_private.packages
    where level_id=p_level and version=p_version and available;
  if c is null then raise exception 'Content version unavailable' using errcode='22023'; end if;
  return c;
end $$;

create function public.academy_catalog() returns jsonb
language plpgsql security definer set search_path='' as $$
declare u uuid := auth.uid(); a text; levels jsonb;
begin
  select access_kind into a from academy_private.access
    where user_id=u and revoked_at is null and (expires_at is null or expires_at>now());
  select coalesce(jsonb_agg(jsonb_build_object(
    'id',level_id,'version',version,'title',title,'position',position,
    'deckCount',jsonb_array_length(content->'decks'),
    'cardCount',jsonb_array_length(content->'flashcards'),
    'lessonCount',jsonb_array_length(content->'lessons')
  ) order by position),'[]') into levels from academy_private.packages where available;
  return jsonb_build_object('hasAccess',a is not null,'accessKind',a,
    'salesEnabled',false,'masteryGateEnabled',false,'levels',levels);
end $$;

create function public.academy_level(p_level text,p_version text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare c jsonb; items jsonb; docs jsonb;
begin
  c := academy_private.package(p_level,p_version);
  -- Never send checkpoint keys or answer explanations before submission.
  select jsonb_agg(jsonb_build_object(
    'id',q->'id','prompt',q->'prompt','options',q->'options',
    'deckId',q->'deckId','objectiveId',q->'objectiveId'
  ) order by ord) into items
    from jsonb_array_elements(c#>'{masteryCheckpoint,items}') with ordinality t(q,ord);
  select coalesce(jsonb_agg(kind order by kind),'[]') into docs from academy_private.documents
    where level_id=p_level and version=p_version
    -- PDF answer banks are owner-review companions, not pre-test learner keys.
    and (kind='Study guide' or exists(select 1 from academy_private.access
      where user_id=auth.uid() and access_kind='owner_review'));
  return (c - 'reviewPdfs' - 'masteryCheckpoint') || jsonb_build_object(
    'masteryCheckpoint',jsonb_build_object('items',items),
    'documents',docs,'masteryGateEnabled',false);
end $$;

create function public.academy_progress() returns jsonb
language plpgsql security definer set search_path='' as $$
declare u uuid := academy_private.assert_access(); m jsonb; a jsonb;
begin
  select coalesce(jsonb_agg(jsonb_build_object('levelId',level_id,'version',version,
    'kind',kind,'itemId',item_id)),'[]') into m from academy_private.marks where user_id=u;
  select coalesce(jsonb_agg(jsonb_build_object('levelId',level_id,'version',version,
    'kind',kind,'scope',scope,'correct',result->'correct','total',result->'total',
    'attemptId',attempt_id,'createdAt',created_at) order by created_at),'[]')
    into a from academy_private.attempts where user_id=u;
  return jsonb_build_object('marks',m,'attempts',a);
end $$;

create function public.academy_mark(p_level text,p_version text,p_kind text,p_item text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare u uuid := academy_private.assert_access(); c jsonb; list_name text;
begin
  c := academy_private.package(p_level,p_version);
  list_name := case p_kind when 'lessons' then 'lessons' when 'cards' then 'flashcards' else null end;
  if list_name is null or not exists (
    select 1 from jsonb_array_elements(c->list_name) x where x->>'id'=p_item
  ) then raise exception 'Invalid progress item' using errcode='22023'; end if;
  insert into academy_private.marks(user_id,level_id,version,kind,item_id)
    values(u,p_level,p_version,p_kind,p_item) on conflict do nothing;
  return jsonb_build_object('saved',true);
end $$;

create function public.academy_submit(
  p_level text,p_version text,p_kind text,p_scope text,p_attempt uuid,p_answers jsonb
) returns jsonb language plpgsql security definer set search_path='' as $$
declare
  u uuid := academy_private.assert_access(); c jsonb; questions jsonb;
  q jsonb; answer text; correct integer:=0; n integer;
  feedback jsonb:='[]'; result jsonb; old academy_private.attempts%rowtype;
begin
  c := academy_private.package(p_level,p_version);
  if p_attempt is null or p_kind not in ('practice','checkpoint') or p_kind is null
     or p_scope is null or p_answers is null or jsonb_typeof(p_answers)<>'object'
  then raise exception 'Invalid attempt' using errcode='22023'; end if;
  -- Same retry token cannot create a second attempt or overwrite another result.
  perform pg_advisory_xact_lock(hashtextextended(u::text || p_attempt::text,0));
  select * into old from academy_private.attempts where user_id=u and attempt_id=p_attempt;
  if found then
    if old.level_id<>p_level or old.version<>p_version or old.kind<>p_kind
       or old.scope<>p_scope or old.answers<>p_answers
    then raise exception 'Attempt token already used' using errcode='22023'; end if;
    return old.result;
  end if;
  if p_kind='checkpoint' then
    if p_scope<>'all' then raise exception 'Checkpoint scope invalid' using errcode='22023'; end if;
    questions:=c#>'{masteryCheckpoint,items}';
  else
    select coalesce(jsonb_agg(t.q order by t.ord),'[]') into questions
      from jsonb_array_elements(c->'practiceQuestions') with ordinality t(q,ord)
      where p_scope='all' or t.q->>'deckId'=p_scope;
  end if;
  n:=jsonb_array_length(questions);
  if n=0 or (select count(*) from jsonb_object_keys(p_answers))<>n then
    raise exception 'Answer every question in this round' using errcode='22023';
  end if;
  for q in select value from jsonb_array_elements(questions) loop
    answer:=p_answers->>(q->>'id');
    if answer is null or not exists(select 1 from jsonb_array_elements(q->'options') o where o->>'id'=answer)
    then raise exception 'Invalid answer selection' using errcode='22023'; end if;
    if answer=q->>'correctOptionId' then correct:=correct+1; end if;
    feedback:=feedback || jsonb_build_array(q || jsonb_build_object('selectedOptionId',answer));
  end loop;
  result:=jsonb_build_object('correct',correct,'total',n,'feedback',feedback,
    'masteryGateEnabled',false,'attemptId',p_attempt);
  insert into academy_private.attempts(user_id,attempt_id,level_id,version,kind,scope,answers,result)
    values(u,p_attempt,p_level,p_version,p_kind,p_scope,p_answers,result);
  return result;
end $$;

create function public.academy_document(p_level text,p_version text,p_kind text) returns text
language plpgsql security definer set search_path='' as $$
declare u uuid:=academy_private.assert_access(); doc text;
begin
  perform academy_private.package(p_level,p_version);
  if p_kind<>'Study guide' and not exists(select 1 from academy_private.access
    where user_id=u and access_kind='owner_review')
  then raise exception 'Document access required' using errcode='42501'; end if;
  select pdf_base64 into doc from academy_private.documents
    where level_id=p_level and version=p_version and kind=p_kind;
  if doc is null then raise exception 'Document unavailable' using errcode='22023'; end if;
  return doc;
end $$;

revoke all on all functions in schema academy_private from public,anon,authenticated;
revoke all on function public.academy_catalog() from public,anon;
revoke all on function public.academy_level(text,text) from public,anon;
revoke all on function public.academy_progress() from public,anon;
revoke all on function public.academy_mark(text,text,text,text) from public,anon;
revoke all on function public.academy_submit(text,text,text,text,uuid,jsonb) from public,anon;
revoke all on function public.academy_document(text,text,text) from public,anon;
grant execute on function public.academy_catalog(),public.academy_level(text,text),
  public.academy_progress(),public.academy_mark(text,text,text,text),
  public.academy_submit(text,text,text,text,uuid,jsonb),public.academy_document(text,text,text)
  to authenticated;
-- No products, purchases, clinical entitlements or CE ownership are changed here.
