set role authenticated;
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000001',false);
do $$ begin
  if public.luma_account_deletion_available() then raise exception 'Must start disabled'; end if;
  begin
    perform public.luma_request_account_deletion('DELETE MY ACCOUNT');
    raise exception 'Disabled request accepted';
  exception when others then
    if sqlerrm <> 'Deletion request processing is not available' then raise; end if;
  end;
end $$;
reset role;
update public.luma_account_deletion_settings set enabled=true;
set role authenticated;
do $$ declare first jsonb; repeated jsonb; begin
  first := public.luma_request_account_deletion('DELETE MY ACCOUNT');
  repeated := public.luma_request_account_deletion('DELETE MY ACCOUNT');
  if first->>'request_id' is distinct from repeated->>'request_id' then
    raise exception 'Repeated requests must be idempotent';
  end if;
  if (first->>'due_at')::timestamptz < now() + interval '6 days' then
    raise exception 'Missing seven day deadline';
  end if;
  if (select count(*) from public.luma_account_deletion_requests) <> 1 then
    raise exception 'Expected one owned request';
  end if;
  begin
    perform public.luma_request_account_deletion('wrong');
    raise exception 'Missing confirmation accepted';
  exception when insufficient_privilege then null; end;
  begin
    update public.luma_account_deletion_requests set status='completed';
    raise exception 'User may not mark their own request completed';
  exception when insufficient_privilege then null; end;
end $$;
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000002',false);
do $$ begin
  if exists(select 1 from public.luma_account_deletion_requests) then
    raise exception 'Cross-user request disclosure';
  end if;
  perform public.luma_request_account_deletion('DELETE MY ACCOUNT');
  if (select contact_email from public.luma_account_deletion_requests) <> 'second@example.test' then
    raise exception 'Request must derive email from authenticated account';
  end if;
end $$;
reset role;
set role anon;
select set_config('request.jwt.claim.sub','',false);
do $$ begin
  begin
    perform public.luma_request_account_deletion('DELETE MY ACCOUNT');
    raise exception 'Anonymous request accepted';
  exception when insufficient_privilege then null; end;
end $$;
reset role;
do $$ begin
  if (select count(*) from auth.users) <> 2 then raise exception 'Requests must not erase users'; end if;
end $$;
select 'Deletion request security tests passed' as result;
