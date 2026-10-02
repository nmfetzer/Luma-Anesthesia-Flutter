-- Applied October 2, 2026 for the approved test; general intake stays disabled.
-- With intake disabled, dispatch stops automatically when test access expires.
begin;
create extension if not exists pg_cron with schema pg_catalog;
create extension if not exists pg_net with schema extensions;
create function public.luma_dispatch_deletion_notifications()
returns bigint language plpgsql security definer set search_path='' as $$
declare token text := gen_random_uuid()::text; request_id bigint;
begin
  if not exists (
    select 1 from public.luma_account_deletion_settings s
    where s.id and (s.enabled or exists (
      select 1 from public.luma_account_deletion_test_access t
      where t.expires_at > now()
    ))
  ) then
    return null;
  end if;
  -- In test mode, never process a queue belonging to another account.
  if not exists (select 1 from public.luma_account_deletion_settings where id and enabled)
    and exists (
      select 1 from public.luma_account_deletion_mail m
      join public.luma_account_deletion_requests r on r.id=m.request_id
      where m.status in ('queued','sending') and not exists (
        select 1 from public.luma_account_deletion_test_access t
        where t.user_id=r.user_id and t.expires_at>now()
      )
    ) then
    return null;
  end if;
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
