-- Applied October 2, 2026. Expiring service-managed access; general intake stays off.
begin;
create table public.luma_account_deletion_test_access (
  user_id uuid primary key references auth.users(id) on delete cascade,
  expires_at timestamptz not null,
  created_at timestamptz not null default now(),
  check (expires_at > created_at and expires_at <= created_at + interval '24 hours')
);
alter table public.luma_account_deletion_test_access enable row level security;
revoke all on public.luma_account_deletion_test_access from public, anon, authenticated;
grant all on public.luma_account_deletion_test_access to service_role;

create or replace function public.luma_account_deletion_available()
returns boolean language sql stable security definer set search_path = '' as $$
  select auth.uid() is not null and exists (
    select 1 from public.luma_account_deletion_settings s
    where s.id and s.notification_email is not null
      and s.worker_checked_at > now() - interval '15 minutes'
      and (
        s.enabled or exists (
          select 1 from public.luma_account_deletion_test_access t
          where t.user_id = auth.uid() and t.expires_at > now()
        )
      )
  );
$$;
revoke all on function public.luma_account_deletion_available() from public, anon;
grant execute on function public.luma_account_deletion_available() to authenticated;
commit;
