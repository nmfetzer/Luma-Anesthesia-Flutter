-- Final integration, not release. Only trusted edge code can write PDF archives.
alter table public.ce_course1_certificates
  add column archive_path text,
  add column archive_sha256 text check (archive_sha256 ~ '^[0-9a-f]{64}$'),
  add column archived_at timestamptz;
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
  values('ce-course1-certificates','ce-course1-certificates',false,5242880,array['application/pdf']);
-- Intentionally no storage policies for anon/authenticated. Access is streamed
-- by the edge function after validating the caller's own award.
grant select,update on public.ce_course1_certificates to service_role;

create function public.ce_course1_protect_award()
returns trigger language plpgsql set search_path='' as $$
begin
  if new.snapshot is distinct from old.snapshot
    or new.user_id is distinct from old.user_id
    or new.course_id is distinct from old.course_id
    or new.id is distinct from old.id
    or new.completed_at is distinct from old.completed_at
    or new.issued_at is distinct from old.issued_at then
    raise exception 'Issued certificate records are immutable';
  end if;
  if old.archive_path is not null and (
    new.archive_path is distinct from old.archive_path
    or new.archive_sha256 is distinct from old.archive_sha256
    or new.archived_at is distinct from old.archived_at) then
    raise exception 'Certificate archive cannot be overwritten';
  end if;
  if new.archive_path is not null and (
    new.archive_path <> new.user_id::text||'/'||new.id::text||'.pdf'
    or new.archive_sha256 is null or new.archived_at is null) then
    raise exception 'Invalid certificate archive metadata';
  end if;
  return new;
end $$;
revoke all on function public.ce_course1_protect_award() from public,anon,authenticated;
create trigger ce_course1_award_immutable before update on public.ce_course1_certificates
  for each row execute function public.ce_course1_protect_award();

create function public.ce_course1_certificate_records(p_month text default null,p_offset integer default 0)
returns jsonb language plpgsql security definer set search_path='' as $$
declare result jsonb;
begin
  if auth.uid() is null or not exists(select 1 from public.ce_course1_reviewers where user_id=auth.uid()) then
    raise exception 'Provider access required';
  end if;
  if p_month is not null and p_month !~ '^[0-9]{4}-(0[1-9]|1[0-2])$' then
    raise exception 'Use YYYY-MM for completion month';
  end if;
  if p_offset<0 then raise exception 'Invalid record offset'; end if;
  with filtered as (
    select * from public.ce_course1_certificates
    where snapshot->>'is_preview'='false'
      and (p_month is null or to_char(completed_at at time zone 'America/New_York','YYYY-MM')=p_month)
  ), page as (select * from filtered order by completed_at,id limit 100 offset p_offset)
  select jsonb_build_object('rows',coalesce((select jsonb_agg(jsonb_build_object(
    'certificate_id',id,'account_id',user_id,'course_id',course_id,'reporting_class','196397',
    'full_name',snapshot->'learner'->>'full_name','credentials',snapshot->'learner'->>'credentials',
    'aana_id',snapshot->'learner'->>'aana_id','location',snapshot->'learner'->>'location',
    'participation_start_on',snapshot->>'participation_start_on',
    'participation_end_on',snapshot->>'participation_end_on',
    'completed_at',completed_at,'completion_date',snapshot->>'completed_on',
    'issued_at',issued_at,'credits_awarded',snapshot->'credits_awarded',
    'pharmacology_credits',snapshot->'pharmacology_credits','pain_credits',snapshot->'pain_credits',
    'archive_status',case when archive_path is null then 'PENDING' else 'SAVED' end,
    'archive_sha256',archive_sha256,
    'reporting_status',case when nullif(btrim(snapshot->'learner'->>'aana_id'),'') is null
      then 'AANA ID NOT PROVIDED - REVIEW BEFORE REPORTING'
      else 'ISSUED - REVIEW FOR AANA REPORTING' end
  )) from page),'[]'),'total',(select count(*) from filtered),'offset',p_offset,
  'export_format','internal_certificate_ledger_not_aana_upload') into result;
  return result;
end $$;
revoke all on function public.ce_course1_certificate_records(text,integer) from public,anon;
grant execute on function public.ce_course1_certificate_records(text,integer) to authenticated;
