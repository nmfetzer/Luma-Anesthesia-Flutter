-- Disposable cluster only. Run after the base request assertions + workflow DDL.
insert into auth.users values
 ('00000000-0000-0000-0000-000000000003','third@example.test',false);
set role authenticated;
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000003',false);
do $$ begin
  if public.luma_account_deletion_available() then raise exception 'No worker heartbeat'; end if;
  if public.luma_my_account_deletion_request() is not null then raise exception 'Cross-user receipt'; end if;
  begin
    perform public.luma_deletion_claim_mail();
    raise exception 'User must not dispatch mail';
  exception when insufficient_privilege then null; end;
  begin
    perform public.luma_complete_account_deletion(gen_random_uuid(),'{}','fake');
    raise exception 'User must not complete requests';
  exception when insufficient_privilege then null; end;
  begin
    perform * from public.luma_account_deletion_mail;
    raise exception 'User must not read outbox';
  exception when insufficient_privilege then null; end;
end $$;
reset role;
update public.luma_account_deletion_settings set notification_email='operator@example.test';
-- Protected scheduler tokens are single-use, short-lived, and not user-readable.
insert into public.luma_deletion_worker_tokens values
 (sha256(convert_to('11111111-1111-1111-1111-111111111111','UTF8')),now()+interval '5 minutes'),
 (sha256(convert_to('22222222-2222-2222-2222-222222222222','UTF8')),now()-interval '1 minute');
set role authenticated;
do $$ begin
  begin
    perform public.luma_consume_deletion_worker_token('11111111-1111-1111-1111-111111111111');
    raise exception 'User must not authenticate a worker';
  exception when insufficient_privilege then null; end;
  begin
    perform * from public.luma_deletion_worker_tokens;
    raise exception 'User must not read worker token hashes';
  exception when insufficient_privilege then null; end;
end $$;
reset role;
set role service_role;
do $$ begin
  if not public.luma_consume_deletion_worker_token('11111111-1111-1111-1111-111111111111') then
    raise exception 'Valid token rejected';
  end if;
  if public.luma_consume_deletion_worker_token('11111111-1111-1111-1111-111111111111') then
    raise exception 'Replay accepted';
  end if;
  if public.luma_consume_deletion_worker_token('22222222-2222-2222-2222-222222222222') then
    raise exception 'Expired token accepted';
  end if;
end $$;
reset role;
set role service_role;
select public.luma_deletion_worker_healthy();
reset role;
set role authenticated;
do $$ declare a jsonb; b jsonb; begin
  a:=public.luma_request_account_deletion('DELETE MY ACCOUNT');
  b:=public.luma_request_account_deletion('DELETE MY ACCOUNT');
  if a is distinct from b then raise exception 'Duplicate must keep receipt/deadline'; end if;
  if a is distinct from public.luma_my_account_deletion_request() then raise exception 'Reopen receipt mismatch'; end if;
end $$;
reset role;
do $$ begin
  if (select count(*) from public.luma_account_deletion_mail)<>2 then
    raise exception 'Exactly two initial emails, not duplicate sends';
  end if;
  if (select recipient from public.luma_account_deletion_mail where kind='staff_new') <> 'operator@example.test' then
    raise exception 'Wrong operator destination';
  end if;
end $$;
set role service_role;
do $$ declare m record; n integer; begin
  for m in select * from public.luma_deletion_claim_mail() loop
    if public.luma_deletion_finish_mail(m.id,gen_random_uuid(),'fake') then
      raise exception 'Wrong lease accepted';
    end if;
    if not public.luma_deletion_finish_mail(m.id,m.lease_token,'test-provider-id') then
      raise exception 'Valid provider acknowledgment not recorded';
    end if;
  end loop;
  select count(*) into n from public.luma_deletion_claim_mail();
  if n<>0 then raise exception 'Accepted email sent again'; end if;
  begin
    perform public.luma_complete_account_deletion(
      (select id from public.luma_account_deletion_requests where user_id='00000000-0000-0000-0000-000000000003'),
      '{}','No required records.');
    raise exception 'Completed without erasing auth user';
  exception when others then
    if sqlerrm <> 'Auth account has not been deleted' then raise; end if;
  end;
end $$;
reset role;
-- Due-soon reminders are deduplicated per request/UTC day.
update public.luma_account_deletion_requests set due_at=now()-interval '1 hour'
 where user_id='00000000-0000-0000-0000-000000000003';
set role service_role;
do $$ declare m record; begin
  for m in select * from public.luma_deletion_claim_mail() loop
    if m.kind <> 'staff_reminder' then raise exception 'Expected reminder'; end if;
    perform public.luma_deletion_finish_mail(m.id,m.lease_token,null,'provider_send_failed');
  end loop;
  if exists(select 1 from public.luma_deletion_claim_mail()) then raise exception 'Retry too soon'; end if;
end $$;
reset role;
update public.luma_account_deletion_mail set first_attempt_at=now()-interval '24 hours',
 next_attempt_at=now()-interval '1 minute' where kind='staff_reminder';
set role service_role;
do $$ begin
  if exists(select 1 from public.luma_deletion_claim_mail()) then
    raise exception 'Ambiguous email must not retry after idempotency expiry';
  end if;
end $$;
reset role;
do $$ begin
  if (select count(*) from public.luma_account_deletion_mail where kind='staff_reminder')<>1 then
    raise exception 'Duplicate daily reminder';
  end if;
  if not exists(select 1 from public.luma_account_deletion_mail where status='needs_attention') then
    raise exception 'Needs manual reconciliation';
  end if;
end $$;
update public.luma_account_deletion_settings set worker_checked_at=now()-interval '1 hour';
select public.luma_deletion_worker_healthy();
do $$ begin
  if exists(select 1 from public.luma_account_deletion_settings where worker_checked_at>now()-interval '15 minutes') then
    raise exception 'Unresolved email failure must not restore heartbeat';
  end if;
end $$;
-- Simulate erasure of a disposable fixture, never a real learner.
delete from auth.users where id='00000000-0000-0000-0000-000000000003';
set role service_role;
do $$ declare r uuid; evidence jsonb; begin
  select id into r from public.luma_account_deletion_requests where contact_email='third@example.test';
  begin
    perform public.luma_complete_account_deletion(r,'{}','No retained records.');
    raise exception 'Missing evidence accepted';
  exception when others then
    if sqlerrm not like 'Missing fulfillment evidence:%' then raise; end if;
  end;
  evidence:='{"retention_verified":true,"nonretained_data_removed":true,"processors_addressed":true,"signin_tokens_addressed":true,"sessions_revoked":true,"operator":"Fixture tester","note":"Disposable fixture verified, no live user data or external providers."}';
  perform public.luma_complete_account_deletion(r,evidence,'No retained CE records in this disposable fixture.');
  perform public.luma_complete_account_deletion(r,evidence,'No retained CE records in this disposable fixture.');
  if (select count(*) from public.luma_account_deletion_mail where kind='learner_completed')<>1 then
    raise exception 'Completion mail must be idempotent';
  end if;
end $$;
reset role;
select 'Deletion workflow security, retries, reminders and completion tests passed' as result;
