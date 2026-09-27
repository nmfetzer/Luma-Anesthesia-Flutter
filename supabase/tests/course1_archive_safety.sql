begin;
do $$
declare uid uuid; cid uuid; response jsonb; blocked boolean;
begin
  if (select public from storage.buckets where id='ce-course1-certificates') then
    raise exception 'Archive bucket is public';
  end if;
  if has_function_privilege('anon','public.ce_course1_certificate_records(text,integer)','EXECUTE')
    or has_table_privilege('authenticated','public.ce_course1_certificates','UPDATE') then
    raise exception 'Archive permissions too broad';
  end if;
  select user_id into uid from public.ce_course1_reviewers limit 1;
  perform set_config('request.jwt.claim.sub',uid::text,true);
  response := public.ce_course1_certificate_records(null,0);
  if response->>'total'<>'0' then raise exception 'Unexpected live awards'; end if;
  -- Synthetic account and award only inside this rolled-back transaction.
  uid := gen_random_uuid(); cid := gen_random_uuid();
  insert into auth.users(id,is_anonymous) values(uid,false);
  insert into public.ce_course1_certificates(id,user_id,course_id,completed_at,snapshot)
  values(cid,uid,'1047239','2026-10-03T12:00:00Z',
    '{"is_preview":false,"credits_awarded":20,"learner":{"full_name":"Archive fixture","aana_id":""},"completed_on":"2026-10-03"}');
  update public.ce_course1_certificates set archive_path=uid::text||'/'||cid::text||'.pdf',
    archive_sha256=repeat('a',64),archived_at=now() where id=cid;
  blocked:=false;
  begin update public.ce_course1_certificates set snapshot='{}' where id=cid;
  exception when others then blocked:=true; end;
  if not blocked then raise exception 'Award snapshot was mutable'; end if;
  blocked:=false;
  begin update public.ce_course1_certificates set archive_sha256=repeat('b',64) where id=cid;
  exception when others then blocked:=true; end;
  if not blocked then raise exception 'Archive hash was mutable'; end if;
  response:=public.ce_course1_certificate_records('2026-10',0);
  if response->>'total'<>'1' or response->'rows'->0->>'archive_status'<>'SAVED'
    or response->'rows'->0->>'reporting_status'<>'AANA ID NOT PROVIDED - REVIEW BEFORE REPORTING' then
    raise exception 'Certificate ledger mapping incorrect';
  end if;
  perform set_config('request.jwt.claim.sub',uid::text,true);
  blocked:=false;
  begin perform public.ce_course1_certificate_records(null,0);
  exception when others then blocked:=true; end;
  if not blocked then raise exception 'Learner accessed provider ledger'; end if;
end $$;
rollback;
select 'PASS: private archive, immutable awards and metadata, monthly provider ledger, account isolation' as archive_safety;
