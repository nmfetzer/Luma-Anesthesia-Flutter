begin;
update public.luma_account_deletion_settings set enabled=false;
do $$ begin
  if public.luma_dispatch_deletion_notifications() is not null then
    raise exception 'Dispatched with no test access';
  end if;
end $$;
insert into public.luma_account_deletion_test_access(user_id,expires_at)
values ('00000000-0000-0000-0000-000000000001',now()+interval '1 hour');
do $$ begin
  if public.luma_dispatch_deletion_notifications() is distinct from 77 then
    raise exception 'Target dispatcher failed';
  end if;
  if (select count(*) from public.luma_deletion_worker_tokens) <> 1 then
    raise exception 'Missing one-use token';
  end if;
end $$;
set local role authenticated;
do $$ begin
  begin
    perform public.luma_dispatch_deletion_notifications();
    raise exception 'Client was allowed to dispatch';
  exception when insufficient_privilege then null; end;
end $$;
reset role;
update public.luma_account_deletion_test_access
  set created_at=now()-interval '2 hours',expires_at=now()-interval '1 hour';
do $$ begin
  if public.luma_dispatch_deletion_notifications() is not null then
    raise exception 'Dispatch continued after test expiry';
  end if;
end $$;
rollback;
