-- Provider-only monthly ledger. This does not create full-course awards,
-- certificates, an AANA submission, or an AANA-compatible bulk-upload file.
create or replace function public.ce_course1_records(
 p_month text default null, p_include_preview boolean default false, p_offset int default 0)
returns jsonb language plpgsql security definer set search_path='' as $$
declare result jsonb;
begin
 if auth.uid() is null or not exists(select 1 from public.ce_course1_reviewers where user_id=auth.uid())
 then raise exception 'Provider access required'; end if;
 if p_month is not null and (p_month !~ '^[0-9]{4}-(0[1-9]|1[0-2])$') then
   raise exception 'Use YYYY-MM for completion month'; end if;
 if p_offset<0 then raise exception 'Invalid record offset'; end if;
 with modules as (
   select s.user_id,s.is_preview,s.progress-'modules' as p from public.ce_course1_state s
   union all
   select s.user_id,s.is_preview,m.value from public.ce_course1_state s
   cross join lateral jsonb_each(coalesce(s.progress->'modules','{}')) m
 ), filtered as (
   select user_id,is_preview,p from modules
   where p ? 'completion' and (p_include_preview or not is_preview)
     and (p_month is null or to_char((p->'completion'->>'completed_at')::timestamptz
       at time zone 'America/New_York','YYYY-MM')=p_month)
 ), page as (
   select * from filtered order by p->'completion'->>'completed_at',user_id,
     p->'completion'->>'module_id' limit 100 offset p_offset
 )
 select jsonb_build_object('rows',coalesce((select jsonb_agg(
   jsonb_build_object('account_id',user_id,'is_preview',is_preview,
     'course_id','1047239','reporting_class','196397',
     'module_id',p->'completion'->>'module_id',
     'full_name',p->'completion'->'learner'->>'full_name',
     'credentials',p->'completion'->'learner'->>'credentials',
     'aana_id',p->'completion'->'learner'->>'aana_id',
     'location',p->'completion'->>'location',
     'completed_at',p->'completion'->>'completed_at',
     'module_credits',p->'completion'->'module_credits',
     'pharmacology_credits',p->'completion'->'pharmacology_credits',
     'pain_credits',p->'completion'->'pain_credits',
     'quiz_attempts',p->'attempts','evaluation',p->'evaluation',
     'reporting_status',case when is_preview then 'PREVIEW - NOT REPORTABLE'
       else 'MODULE ONLY - FULL PROGRAM NOT AWARDED' end,
     'full_course_awarded',false)) from page),'[]'),
   'total',(select count(*) from filtered),'offset',p_offset,'page_size',100,
   'month_timezone','America/New_York','full_course_reporting_enabled',false,
   'export_format','internal_ledger_not_aana_upload') into result;
 return result;
end $$;
revoke all on function public.ce_course1_records(text,boolean,int) from public,anon;
grant execute on function public.ce_course1_records(text,boolean,int) to authenticated;
