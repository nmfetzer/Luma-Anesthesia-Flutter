-- Disposable fixture only, never run against production.
begin;
update public.luma_account_deletion_settings
  set enabled=false, notification_email='operator@example.test', worker_checked_at=now();
insert into public.luma_account_deletion_test_access(user_id,expires_at)
values ('00000000-0000-0000-0000-000000000001',now()+interval '1 hour');
set local role authenticated;
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000001',true);
do $$ begin
  if not public.luma_account_deletion_available() then raise exception 'Target denied'; end if;
  begin
    perform * from public.luma_account_deletion_test_access;
    raise exception 'Allowlist exposed';
  exception when insufficient_privilege then null; end;
end $$;
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000002',true);
do $$ begin
  if public.luma_account_deletion_available() then raise exception 'Other user allowed'; end if;
end $$;
reset role;
update public.luma_account_deletion_test_access
  set created_at=now()-interval '2 hours',expires_at=now()-interval '1 hour';
set local role authenticated;
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000001',true);
do $$ begin
  if public.luma_account_deletion_available() then raise exception 'Expired target allowed'; end if;
end $$;
reset role;
update public.luma_account_deletion_test_access
  set created_at=now(),expires_at=now()+interval '1 hour';
update public.luma_account_deletion_settings set worker_checked_at=now()-interval '16 minutes';
set local role authenticated;
do $$ begin
  if public.luma_account_deletion_available() then raise exception 'Stale worker allowed'; end if;
end $$;
reset role;
rollback;
