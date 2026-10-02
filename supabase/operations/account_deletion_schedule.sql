-- PREPARED ONLY. Requires separate production approval and pg_cron + pg_net.
-- No long-lived scheduler secret: mint a one-use 5-minute token inside Postgres.
-- Deploy account-deletion-notify with verify_jwt=false; it consumes the token
-- through a service-only RPC. No client can mint or read these tokens.
begin;
create function public.luma_dispatch_deletion_notifications()
returns bigint language plpgsql security definer set search_path='' as $$
declare token text := gen_random_uuid()::text; request_id bigint;
begin
  delete from public.luma_deletion_worker_tokens where expires_at<=now();
  insert into public.luma_deletion_worker_tokens(token_hash,expires_at)
    values(sha256(convert_to(token,'UTF8')),now()+interval '5 minutes');
  select net.http_post(
    url := 'https://xuckkusbbcxplpqclbxt.supabase.co/functions/v1/account-deletion-notify',
    headers := jsonb_build_object(
      'Content-Type','application/json','x-deletion-worker-token',token
    ),
    body := '{}'::jsonb, timeout_milliseconds := 90000
  ) into request_id;
  return request_id;
end $$;
revoke all on function public.luma_dispatch_deletion_notifications() from public,anon,authenticated;
grant execute on function public.luma_dispatch_deletion_notifications() to service_role;
select cron.schedule(
  'luma-account-deletion-notifications', '*/5 * * * *',
  'select public.luma_dispatch_deletion_notifications();'
);
commit;
