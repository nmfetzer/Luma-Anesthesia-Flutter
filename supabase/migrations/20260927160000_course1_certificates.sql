-- Certificate foundation. Deliberately does NOT release the course or enable
-- official issuance. Provider must approve the template/signature separately.
create table public.ce_course1_certificate_settings (
  course_id text primary key references public.ce_course1_catalog(id),
  enabled boolean not null default false,
  template_version text not null default 'cehalo-course1-v1',
  provider_city_state text not null default 'Buffalo, New York',
  signer_name text not null default 'Nicole M Fetzer, MS, CRNA',
  signer_title text not null default 'Owner, CE HALO LLC',
  signature_png_base64 text,
  approved_at timestamptz
);
insert into public.ce_course1_certificate_settings(course_id) values ('1047239');

create table public.ce_course1_certificates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete restrict,
  course_id text not null references public.ce_course1_catalog(id),
  issued_at timestamptz not null default now(),
  completed_at timestamptz not null,
  snapshot jsonb not null,
  unique(user_id,course_id)
);
alter table public.ce_course1_certificate_settings enable row level security;
alter table public.ce_course1_certificates enable row level security;
revoke all on public.ce_course1_certificate_settings,public.ce_course1_certificates from public,anon,authenticated;

-- No caller-controlled identity, dates, credits or learner fields are accepted.
-- A stored award is returned unchanged on retry, including after expiration.
create function public.ce_course1_certificate(p_action text default 'status')
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
        learner := p->'completion'->'learner';
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
