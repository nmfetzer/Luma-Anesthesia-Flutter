-- DISPOSABLE TEST CLUSTER ONLY.
do $$ begin
  begin
    delete from auth.users where id='00000000-0000-0000-0000-000000000004';
    raise exception 'Unprepared account removed';
  exception when others then
    if sqlerrm <> 'Deletion fulfillment must be prepared before login removal' then raise; end if;
  end;
  if exists(select 1 from public.luma_deleted_account_ce_records) then
    raise exception 'Failed removal must not leave archive artifacts';
  end if;
end $$;
set role authenticated;
do $$ begin
  begin
    perform * from public.luma_deleted_account_ce_records;
    raise exception 'Clients must not access retained records';
  exception when insufficient_privilege then null; end;
  begin
    perform public.luma_prepare_account_deletion(gen_random_uuid(),'{}');
    raise exception 'Client may not prepare deletion';
  exception when insufficient_privilege then null; end;
end $$;
reset role;
set role service_role;
select public.luma_prepare_account_deletion(
 (select id from public.luma_account_deletion_requests where contact_email='retention@example.test'),
 '{"nonretained_data_removed":true,"processors_addressed":true,"signin_tokens_addressed":true,"sessions_revoked":true,"certificate_archives_verified":true,"operator":"Fixture tester","note":"Verified dummy archive files and mock external processors in disposable local tests."}'
);
reset role;
-- Missing PDF metadata blocks erasure; no partial archive survives rollback.
update public.ce_course1_certificates set archive_sha256=null;
do $$ begin
  begin
    delete from auth.users where id='00000000-0000-0000-0000-000000000004';
    raise exception 'Unarchived award account removed';
  exception when others then
    if sqlerrm <> 'Finish and verify certificate PDF archives before deletion' then raise; end if;
  end;
  if exists(select 1 from public.luma_deleted_account_ce_records) then
    raise exception 'Failed removal must roll back archives';
  end if;
end $$;
update public.ce_course1_certificates set archive_sha256=repeat('a',64);
create table public.ce_course4_state(user_id uuid);
do $$ begin
  begin
    delete from auth.users where id='00000000-0000-0000-0000-000000000004';
    raise exception 'Unknown course retention silently ignored';
  exception when others then
    if sqlerrm <> 'New CE tables require retention review' then raise; end if;
  end;
end $$;
drop table public.ce_course4_state;
-- This removes only a disposable fixture, never a real learner.
delete from auth.users where id='00000000-0000-0000-0000-000000000004';
do $$ declare n integer; cnt integer; begin
  for n in 1..3 loop
    execute format('select count(*) from public.ce_course%s_certificates',n) into cnt;
    if cnt<>1 then raise exception 'Award lost'; end if;
    execute format('select count(*) from public.ce_course%s_state',n) into cnt;
    if cnt<>0 then raise exception 'Active learning profile not removed'; end if;
  end loop;
  if (select count(*) from public.luma_deleted_account_ce_records)<>5 then
    raise exception 'Expected 3 award snapshots and 2 non-preview learning records';
  end if;
  if not exists(select 1 from public.luma_deleted_account_ce_records
    where source_table='ce_course1_state'
      and record->'progress'->'evaluation'->>'attestation'='true'
      and record->'profile'->>'aana_id'='test-number'
      and review_not_before>=now()+interval '59 months') then
    raise exception 'Required assessment/evaluation/learner evidence lost';
  end if;
  if not exists(select 1 from public.luma_ce_bonus_purchases where transaction_id='fixture-transaction') then
    raise exception 'Financial ledger lost';
  end if;
  if not exists(select 1 from public.luma_account_deletion_requests
    where contact_email='retention@example.test' and user_id is null
      and fulfillment_evidence->>'retention_verified'='true') then
    raise exception 'Missing retention evidence';
  end if;
  begin
    insert into public.luma_ce_bonus_purchases(transaction_id,user_id)
      values('bad-new-association','00000000-0000-0000-0000-000000000004');
    raise exception 'New association to a deleted user accepted';
  exception when others then
    if sqlerrm <> 'A live account is required for a new ledger association' then raise; end if;
  end;
end $$;
-- Existing financial records can still be corrected/revoked.
update public.luma_ce_bonus_purchases set revoked_at=now() where transaction_id='fixture-transaction';
set role service_role;
select public.luma_complete_account_deletion(id,fulfillment_evidence,
 'Required CE participation, assessments, evaluations, certificates and financial ledger records are retained for the necessary purposes.')
from public.luma_account_deletion_requests where contact_email='retention@example.test';
reset role;
select 'Retention snapshots, rollback, access isolation, archive checks, future course guard and completion passed' as result;
