-- Registration participation dates are distinct from verified completion.
-- No release flag, purchase, signature approval or issued award is changed.
create or replace function public.ce_course1_participation_error(
  p_start text, p_end text, p_preview boolean default false
) returns text language plpgsql stable set search_path = '' as $$
declare first_day date; last_day date;
begin
  if coalesce(p_start,'')='' and coalesce(p_end,'')='' then return null; end if;
  if coalesce(p_start,'') !~ '^\d{4}-\d{2}-\d{2}$'
    or coalesce(p_end,'') !~ '^\d{4}-\d{2}-\d{2}$' then
    return 'Enter both participation dates as YYYY-MM-DD.';
  end if;
  begin
    first_day := p_start::date; last_day := p_end::date;
  exception when others then return 'Enter valid calendar dates.'; end;
  if first_day < date '2026-10-01' or last_day > date '2029-09-30' then
    return 'Participation dates must fall between 2026-10-01 and 2029-09-30.';
  end if;
  if first_day > last_day then return 'End date cannot be before start date.'; end if;
  if not p_preview and last_day > (now() at time zone 'America/New_York')::date then
    return 'Enter actual participation dates, not future dates.';
  end if;
  return null;
end;
$$;
revoke all on function public.ce_course1_participation_error(text,text,boolean) from public,anon,authenticated;

create or replace function public.ce_course1(p_action text, p_payload jsonb default '{}')
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid();
  catalog jsonb; released boolean; reviewer boolean; allowed boolean;
  s public.ce_course1_state%rowtype;
  p jsonb; bank jsonb; plans jsonb; ids jsonb; form jsonb; questions jsonb;
  attempts jsonb; a jsonb; answers jsonb; evaluation jsonb;
  n int; i int; score int; q jsonb; safe_questions jsonb;
  completed boolean; passed boolean; document jsonb; eliminated jsonb;
  mid text := coalesce(p_payload->>'module_id','course_1_module_1');
  m jsonb; module_list jsonb; summaries jsonb := '{}'; item jsonb; mp jsonb;
  resource_prefix text; expected_ratings int;
  participation_start text; participation_end text; date_error text;
begin
  select c.metadata,c.released into catalog,released from public.ce_course1_catalog c where id='1047239';
  if catalog is null then raise exception 'Course not loaded'; end if;
  if p_action='catalog' then
    return catalog || jsonb_build_object('purchases_enabled',false,'released',released);
  end if;
  module_list := coalesce(catalog->'modules',jsonb_build_array(catalog->'module'));
  select value into m from jsonb_array_elements(module_list) where value->>'id'=mid;
  if m is null then raise exception 'Module not available'; end if;
  resource_prefix := coalesce(m->>'resource_prefix','ketamine');
  expected_ratings := jsonb_array_length(m->'objectives') + jsonb_array_length(m->'evaluation_items');
  if uid is null or not exists(select 1 from auth.users where id=uid and is_anonymous=false) then
    raise exception 'Sign in with a permanent account to continue';
  end if;
  reviewer := exists(select 1 from public.ce_course1_reviewers where user_id=uid);
  -- Purchase records can only be written by the existing server-side verified receipt hook.
  allowed := reviewer or (released and current_date between date '2026-10-01' and date '2029-09-30'
    and exists(select 1 from public.luma_ce_bonus_purchases
      where user_id=uid and revoked_at is null
      and exists (select 1 from public.ce_course1_store_products sp where sp.store=luma_ce_bonus_purchases.store and sp.product_id=luma_ce_bonus_purchases.product_id)));
  if p_action='access' and not allowed then
    return jsonb_build_object('has_access',false,'is_preview',false);
  end if;
  if not allowed then raise exception 'Verified course purchase required; course currently staged'; end if;
  insert into public.ce_course1_state(user_id,is_preview) values(uid,reviewer)
    on conflict(user_id) do nothing;
  select * into s from public.ce_course1_state where user_id=uid for update;
  -- Reviewer records never silently become CE credit records.
  if s.is_preview and not reviewer then raise exception 'Preview record requires provider review'; end if;
  p := case when mid='course_1_module_1' then s.progress-'modules'
    else coalesce(s.progress->'modules'->mid,'{}') end;
  attempts := coalesce(p->'attempts','[]');
  passed := coalesce((p->>'passed')::boolean,false);
  completed := p ? 'completion';
  if p_action in ('access','status') then
    for item in select value from jsonb_array_elements(module_list) loop
      mp := case when item->>'id'='course_1_module_1' then s.progress-'modules'
        else coalesce(s.progress->'modules'->(item->>'id'),'{}') end;
      summaries := summaries || jsonb_build_object(item->>'id',jsonb_build_object(
        'read',coalesce((mp->>'read')::boolean,false),
        'passed',coalesce((mp->>'passed')::boolean,false),
        'completed',mp ? 'completion',
        'attempts_used',jsonb_array_length(coalesce(mp->'attempts','[]'))));
    end loop;
    return jsonb_build_object('has_access',true,'is_preview',s.is_preview,'is_provider',reviewer,'profile',s.profile,
      'module_id',mid,'module_statuses',summaries,
      'read',coalesce((p->>'read')::boolean,false),'passed',passed,'completed',completed,
      'attempts_used',jsonb_array_length(attempts),'completion',p->'completion');
  end if;
  if p_action='profile' then
    participation_start := btrim(coalesce(p_payload->>'participation_start_on',s.profile->>'participation_start_on',''));
    participation_end := btrim(coalesce(p_payload->>'participation_end_on',s.profile->>'participation_end_on',''));
    date_error := public.ce_course1_participation_error(participation_start,participation_end,reviewer);
    if date_error is not null then raise exception '%',date_error; end if;
    if length(btrim(coalesce(p_payload->>'full_name',''))) not between 3 and 150
      or length(btrim(coalesce(p_payload->>'credentials',''))) not between 1 and 100
      or length(btrim(coalesce(p_payload->>'location',''))) not between 3 and 300
      or length(coalesce(p_payload->>'aana_id',''))>60 then
      raise exception 'Full name, credentials and completion location are required';
    end if;
    update public.ce_course1_state set profile=jsonb_build_object(
      'full_name',btrim(p_payload->>'full_name'),'credentials',btrim(p_payload->>'credentials'),
      'aana_id',btrim(coalesce(p_payload->>'aana_id','')),'location',btrim(p_payload->>'location'),
      'participation_start_on',participation_start,'participation_end_on',participation_end),
      updated_at=now() where user_id=uid;
    return jsonb_build_object('saved',true);
  end if;
  if not(s.profile ? 'full_name') then raise exception 'Complete learner details first'; end if;
  if p_action='document' then
    select data into document from public.ce_course1_resources where id=resource_prefix||'_pdf';
    if document is null then raise exception 'Learner document unavailable'; end if;
    return document;
  elsif p_action='read' then
    p:=p||jsonb_build_object('read',true,'read_at',now());
  elsif p_action='quiz' then
    if not coalesce((p->>'read')::boolean,false) then raise exception 'Review the learner content first'; end if;
    if passed then raise exception 'Assessment already passed'; end if;
    n := jsonb_array_length(attempts);
    if n>0 and not (attempts->(n-1) ? 'score') then
      a:=attempts->(n-1);
    else
      if n>=3 then raise exception 'Three attempts used. Contact info@cehalo.com for assistance'; end if;
      if not(p ? 'bank') then
        select data into bank from public.ce_course1_resources where id=resource_prefix||'_questions';
        if bank is null or jsonb_array_length(bank)<>25 then raise exception 'Assessment bank unavailable'; end if;
        -- Three forms, 15 questions each, exactly seven shared between any pair.
        select jsonb_agg(value order by random()) into bank from jsonb_array_elements(bank);
        select jsonb_agg(value->>'question_id' order by ord) into ids
          from jsonb_array_elements(bank) with ordinality t(value,ord);
        plans:='[]';
        for i in 1..3 loop
          select jsonb_agg(value order by random()) into form
            from jsonb_array_elements(ids) with ordinality t(value,ord)
            where (i=1 and ord between 1 and 15)
              or (i=2 and (ord between 1 and 7 or ord between 16 and 23))
              or (i=3 and (ord between 8 and 14 or ord between 16 and 22 or ord=24));
          plans:=plans||jsonb_build_array(form);
        end loop;
        p:=p||jsonb_build_object('bank',bank,'plans',plans);
      end if;
      a:=jsonb_build_object('id',pg_catalog.gen_random_uuid(),'number',n+1,
        'ids',p->'plans'->n,'started_at',now(),'answers','{}'::jsonb);
      attempts:=attempts||jsonb_build_array(a);
      p:=p||jsonb_build_object('attempts',attempts);
    end if;
  elsif p_action='hint' then
    n:=jsonb_array_length(attempts);
    if n=0 then raise exception 'Start an assessment first'; end if;
    a:=attempts->(n-1);
    if a->>'id' is distinct from p_payload->>'attempt_id' or a ? 'score'
      or not(a->'ids' ? (p_payload->>'question_id')) then raise exception 'Invalid active question'; end if;
    eliminated:=a->'hints'->(p_payload->>'question_id');
    if eliminated is null then
      select value into q from jsonb_array_elements(p->'bank')
        where value->>'question_id'=p_payload->>'question_id';
      eliminated := q->'hint'->'eliminate_choices';
      if eliminated is null then
        select jsonb_agg(choice) into eliminated from
          (select choice from unnest(array['a','b','c','d']) choice
            where choice<>q->>'correct_choice' order by random() limit 2) x;
      end if;
      if jsonb_array_length(eliminated)<>2 or eliminated ? (q->>'correct_choice')
        or (select count(distinct value) from jsonb_array_elements_text(eliminated))<>2
        or exists(select 1 from jsonb_array_elements_text(eliminated) x where x not in ('a','b','c','d'))
        then raise exception 'Invalid hint configuration'; end if;
      a:=a||jsonb_build_object('hints',coalesce(a->'hints','{}')||
        jsonb_build_object(p_payload->>'question_id',eliminated));
      if eliminated ? (a->'answers'->>(p_payload->>'question_id')) then
        a:=jsonb_set(a,'{answers}',(a->'answers')-(p_payload->>'question_id'));
      end if;
      attempts:=jsonb_set(attempts,array[(n-1)::text],a);
      p:=p||jsonb_build_object('attempts',attempts);
    end if;
  elsif p_action in ('save_answers','submit') then
    n:=jsonb_array_length(attempts);
    if n=0 then raise exception 'Start an assessment first'; end if;
    -- Match the exact attempt, including repeated submission after a successful response.
    select value into a from jsonb_array_elements(attempts) where value->>'id'=p_payload->>'attempt_id';
    if a is null then raise exception 'Unknown assessment attempt'; end if;
    if a ? 'score' then
      return jsonb_build_object('score',a->'score','passed',a->'passed','total',15);
    end if;
    if a->>'id'<>attempts->(n-1)->>'id' or passed then raise exception 'Attempt not active'; end if;
    answers:=p_payload->'answers';
    if answers is null or jsonb_typeof(answers)<>'object' then raise exception 'Invalid answers'; end if;
    if exists(select 1 from jsonb_each_text(answers) x where x.value is null or x.value not in ('a','b','c','d')
      or not (a->'ids' ? x.key)
      or coalesce(a->'hints'->x.key,'[]') ? x.value) then raise exception 'Invalid answer selection'; end if;
    if p_action='submit' then
      if (select count(*) from jsonb_each(answers))<>15 then raise exception 'Answer all 15 questions'; end if;
      select count(*) into score from jsonb_array_elements(p->'bank') b
        where a->'ids' ? (b->>'question_id') and answers->>(b->>'question_id')=b->>'correct_choice';
      a:=a||jsonb_build_object('score',score,'passed',score>=12,'submitted_at',now());
      p:=p||jsonb_build_object('passed',score>=12);
    end if;
    a:=a||jsonb_build_object('answers',answers);
    attempts:=jsonb_set(attempts,array[(n-1)::text],a);
    p:=p||jsonb_build_object('attempts',attempts);
  elsif p_action='evaluate' then
    if not passed then raise exception 'Pass the assessment before completing the evaluation'; end if;
    if completed then return p->'completion'; end if;
    evaluation:=p_payload;
    if jsonb_typeof(evaluation->'ratings') is distinct from 'array'
      or jsonb_array_length(evaluation->'ratings')<>expected_ratings then
        raise exception 'All % ratings are required',expected_ratings; end if;
    if exists(select 1 from jsonb_array_elements_text(evaluation->'ratings') r where r is null or r !~ '^[1-5]$')
      or length(btrim(coalesce(evaluation->>'learned',''))) not between 3 and 4000
      or length(btrim(coalesce(evaluation->>'barriers',''))) not between 2 and 4000
      or evaluation->>'attestation' is distinct from 'true' then
      raise exception 'Complete the ratings, written responses and acknowledgment';
    end if;
    -- Identity is inherited from the one-time course registration, not supplied
    -- again in each evaluation. Ignore legacy-client identity/location fields.
    evaluation := jsonb_build_object('ratings',evaluation->'ratings',
      'learned',btrim(evaluation->>'learned'),'barriers',btrim(evaluation->>'barriers'),
      'attestation',true,'submitted_at',now(),'user_id',uid,
      'registration',s.profile,'module_id',mid,
      'rating_scale',coalesce(m->'rating_scale','{"1":"Strongly disagree / not achieved","5":"Strongly agree / fully achieved"}'::jsonb));
    p:=p||jsonb_build_object('evaluation',evaluation,'completion',jsonb_build_object(
      'module_id',mid,'completed_at',now(),'learner',s.profile,
      'location',s.profile->>'location','user_id',uid,'is_preview',s.is_preview,
      'module_credits',case when s.is_preview then 0 else (m->>'credits')::numeric end,
      'pharmacology_credits',case when s.is_preview then 0 else (m->>'pharmacology_credits')::numeric end,
      'pain_credits',case when s.is_preview then 0 else (m->>'pain_credits')::numeric end,
      'course_complete',false,'certificate_status','not_implemented','approval_code','1047239'));
  else
    raise exception 'Unknown course action';
  end if;
  update public.ce_course1_state set progress=
    case when mid='course_1_module_1'
      then p || case when s.progress ? 'modules' then jsonb_build_object('modules',s.progress->'modules') else '{}' end
      else s.progress || jsonb_build_object('modules',
        coalesce(s.progress->'modules','{}')||jsonb_build_object(mid,p)) end,
    updated_at=now() where user_id=uid;
  if p_action='quiz' then
    select jsonb_agg(jsonb_build_object('question_id',b->>'question_id','stem',b->>'stem',
      'choice_a',b->>'choice_a','choice_b',b->>'choice_b','choice_c',b->>'choice_c','choice_d',b->>'choice_d')
      order by f.ord) into safe_questions
      from jsonb_array_elements_text(a->'ids') with ordinality f(id,ord)
      join jsonb_array_elements(p->'bank') b on b->>'question_id'=f.id;
    return jsonb_build_object('attempt_id',a->>'id','number',a->'number',
      'questions',safe_questions,'answers',a->'answers','hints',coalesce(a->'hints','{}'));
  elsif p_action='hint' then
    return jsonb_build_object('eliminated',eliminated,'answers',a->'answers');
  elsif p_action='submit' then
    return jsonb_build_object('score',score,'passed',score>=12,'total',15);
  elsif p_action='evaluate' then
    return p->'completion';
  end if;
  return jsonb_build_object('saved',true);
end;
$$;
revoke all on function public.ce_course1(text,jsonb) from public,anon;
grant execute on function public.ce_course1(text,jsonb) to anon,authenticated;
comment on function public.ce_course1 is
  'Public catalog; all learning actions require authenticated verified course ownership or explicit provider preview access. Answer keys and learner records stay private.';

create or replace function public.ce_course1_certificate(p_action text default 'status')
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid();
  s public.ce_course1_state%rowtype;
  cfg public.ce_course1_certificate_settings%rowtype;
  award public.ce_course1_certificates%rowtype;
  catalog jsonb; released boolean; reviewer boolean; paid boolean;
  m jsonb; p jsonb; a jsonb; checklist jsonb := '[]'; snapshot jsonb;
  ready boolean; all_ready boolean := true; official boolean := true;
  first_at timestamptz; last_at timestamptz; event_at timestamptz;
  learner jsonb; certificate_id uuid; today date := (now() at time zone 'America/New_York')::date;
  reason text; module_count integer := 0;
begin
  if p_action not in ('status','preview','issue') then raise exception 'Unknown certificate action'; end if;
  if uid is null or not exists(select 1 from auth.users where id=uid and is_anonymous=false) then
    raise exception 'Sign in with a permanent account';
  end if;
  reviewer := exists(select 1 from public.ce_course1_reviewers where user_id=uid);
  select * into s from public.ce_course1_state where user_id=uid for update;
  if not found then raise exception 'Complete course registration first'; end if;
  select * into cfg from public.ce_course1_certificate_settings where course_id='1047239';
  select metadata,c.released into catalog,released from public.ce_course1_catalog c where id='1047239';
  select * into award from public.ce_course1_certificates where user_id=uid and course_id='1047239';
  if found and p_action <> 'preview' then
    return jsonb_build_object('state','issued','certificate',award.snapshot,'can_issue',false);
  end if;
  if p_action='preview' and not reviewer then raise exception 'Provider preview only'; end if;
  if length(btrim(coalesce(s.profile->>'full_name',''))) < 3
    or length(btrim(coalesce(s.profile->>'credentials',''))) < 1
    or length(btrim(coalesce(s.profile->>'location',''))) < 3 then
    raise exception 'Complete learner registration first';
  end if;
  learner := s.profile;
  for m in select value from jsonb_array_elements(catalog->'modules') loop
    module_count := module_count + 1;
    p := case when m->>'id'='course_1_module_1' then s.progress-'modules'
      else coalesce(s.progress->'modules'->(m->>'id'),'{}') end;
    ready := coalesce((p->>'read')::boolean,false)
      and coalesce((p->>'passed')::boolean,false)
      and p ? 'completion' and p ? 'evaluation'
      and coalesce((p->'evaluation'->>'attestation')::boolean,false)
      and exists(select 1 from jsonb_array_elements(coalesce(p->'attempts','[]')) x
        where (x->>'score')::integer >= 12 and x->>'passed'='true');
    all_ready := all_ready and ready;
    checklist := checklist || jsonb_build_array(jsonb_build_object(
      'id',m->>'id','title',m->>'title','complete',ready));
    if ready then
      official := official and p->'completion'->>'is_preview'='false'
        and p->'completion'->>'user_id'=uid::text;
      event_at := (p->'completion'->>'completed_at')::timestamptz;
      if last_at is null or event_at > last_at then
        last_at := event_at;
        -- Keep completion timestamp; registration fields remain editable until issuance.
      end if;
    end if;
    if p ? 'read_at' then
      first_at := least(first_at,(p->>'read_at')::timestamptz);
    end if;
    for a in select value from jsonb_array_elements(coalesce(p->'attempts','[]')) loop
      if a ? 'started_at' then first_at := least(first_at,(a->>'started_at')::timestamptz); end if;
    end loop;
  end loop;
  paid := exists(select 1 from public.luma_ce_bonus_purchases b
    join public.ce_course1_store_products sp on sp.store=b.store and sp.product_id=b.product_id
    where b.user_id=uid and b.revoked_at is null);
  reason := case
    when s.is_preview or reviewer then 'Provider preview only. No CE credit is awarded.'
    when not cfg.enabled or cfg.approved_at is null or nullif(cfg.signature_png_base64,'') is null
      then 'Official certificates are awaiting provider approval.'
    when not released then 'The course has not been released.'
    when not paid then 'A verified course purchase is required.'
    when module_count <> 11 or not all_ready or not coalesce(official,false)
      then 'Complete all 11 modules, passing assessments and evaluations.'
    when first_at is null or last_at is null or first_at > last_at
      or (first_at at time zone 'America/New_York')::date < date '2026-10-01'
      or (last_at at time zone 'America/New_York')::date > date '2029-09-30'
      or last_at > now() or today < date '2026-10-01'
      then 'Participation dates must fall within the approved program period.'
    when coalesce(s.profile->>'participation_start_on','')=''
      or coalesce(s.profile->>'participation_end_on','')=''
      then 'Add your participation dates using Edit course registration.'
    when public.ce_course1_participation_error(s.profile->>'participation_start_on',s.profile->>'participation_end_on',false) is not null
      then public.ce_course1_participation_error(s.profile->>'participation_start_on',s.profile->>'participation_end_on',false)
    when (s.profile->>'participation_start_on')::date > (first_at at time zone 'America/New_York')::date
      or (s.profile->>'participation_end_on')::date < (last_at at time zone 'America/New_York')::date
      then 'Participation dates must include your recorded course activity and completion.'
    else null end;
  if p_action='status' then
    return jsonb_build_object('state','pending','can_issue',reason is null,
      'can_preview',reviewer,'reason',reason,'modules',checklist,
      'profile',s.profile,'required_modules',11);
  end if;
  if p_action='issue' and reason is not null then raise exception '%',reason; end if;
  certificate_id := gen_random_uuid();
  snapshot := jsonb_build_object(
    'id',case when p_action='preview' then 'PREVIEW-NOT-VALID' else certificate_id::text end,
    'is_preview',p_action='preview','course_id','1047239',
    'course_title','A Medication Review for the Experienced CRNA',
    'template_version',cfg.template_version,'learner',case when p_action='preview' then s.profile else learner end,
    'provider','CE HALO LLC','provider_city_state',cfg.provider_city_state,'email','info@cehalo.com',
    'signer_name',cfg.signer_name,'signer_title',cfg.signer_title,
    'signature_png_base64',cfg.signature_png_base64,
    'started_on',case when p_action='preview' then null else (first_at at time zone 'America/New_York')::date end,
    'completed_on',case when p_action='preview' then null else (last_at at time zone 'America/New_York')::date end,
    'completed_at',case when p_action='preview' then null else last_at end,
    'participation_start_on',s.profile->>'participation_start_on',
    'participation_end_on',s.profile->>'participation_end_on',
    'participation_dates_source','registration',
    'credits_awarded',case when p_action='preview' then 0 else 20.00 end,
    'pharmacology_credits',case when p_action='preview' then 0 else 17.50 end,
    'pain_credits',case when p_action='preview' then 0 else 2.50 end,
    'approved_credits',20.00,'expiration_date','9/30/2029');
  if p_action='issue' then
    insert into public.ce_course1_certificates(id,user_id,course_id,completed_at,snapshot)
      values(certificate_id,uid,'1047239',last_at,snapshot);
  end if;
  return jsonb_build_object('state',case when p_action='preview' then 'preview' else 'issued' end,
    'certificate',snapshot,'can_issue',false);
end;
$$;
revoke all on function public.ce_course1_certificate(text) from public,anon;
grant execute on function public.ce_course1_certificate(text) to authenticated;
comment on table public.ce_course1_certificates is
  'Immutable application-level award snapshots. No client table grants. Preview never inserts. No automatic AANA submission.';
