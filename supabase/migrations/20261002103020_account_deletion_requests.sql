-- Applied October 2, 2026. Intake remains disabled pending live verification.
-- CE HALO approved 7 days; public contact info@cehalo.com.
-- Internal notification routing is configured in protected server settings.
-- Do not enable until delivery, monitoring, retention and fulfillment are ready.
-- This records requests; it does NOT erase accounts or declare them deleted.
begin;
create table public.luma_account_deletion_settings (
  id boolean primary key default true check (id),
  enabled boolean not null default false
);
insert into public.luma_account_deletion_settings(id, enabled) values (true, false);
alter table public.luma_account_deletion_settings enable row level security;
revoke all on public.luma_account_deletion_settings from anon, authenticated;
grant all on public.luma_account_deletion_settings to service_role;

create table public.luma_account_deletion_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  contact_email text not null,
  requested_at timestamptz not null default now(),
  due_at timestamptz not null default now() + interval '7 days',
  status text not null default 'pending' check (status in ('pending','completed')),
  completed_at timestamptz,
  -- Service-role staff records evidence only after all fulfillment steps.
  fulfillment_note text,
  constraint completion_evidence check (
    (status = 'pending' and completed_at is null) or
    (status = 'completed' and completed_at is not null and fulfillment_note is not null)
  )
);
create unique index luma_account_deletion_one_pending
  on public.luma_account_deletion_requests(user_id) where status = 'pending';
alter table public.luma_account_deletion_requests enable row level security;
revoke all on public.luma_account_deletion_requests from anon, authenticated;
grant all on public.luma_account_deletion_requests to service_role;
grant select on public.luma_account_deletion_requests to authenticated;
create policy deletion_read_own on public.luma_account_deletion_requests
  for select to authenticated using (user_id = (select auth.uid()));

create function public.luma_account_deletion_available()
returns boolean language sql stable security definer set search_path = '' as $$
  select auth.uid() is not null and exists (
    select 1 from public.luma_account_deletion_settings where id and enabled
  );
$$;
revoke all on function public.luma_account_deletion_available() from public, anon;
grant execute on function public.luma_account_deletion_available() to authenticated;

create function public.luma_request_account_deletion(confirmation text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  caller uuid := auth.uid();
  account_email text;
  receipt public.luma_account_deletion_requests;
begin
  if caller is null or confirmation is distinct from 'DELETE MY ACCOUNT' then
    raise exception 'Authenticated confirmation required' using errcode = '42501';
  end if;
  if not exists (select 1 from public.luma_account_deletion_settings where id and enabled) then
    raise exception 'Deletion request processing is not available';
  end if;
  select email into account_email from auth.users
    where id = caller and not coalesce(is_anonymous, false);
  if account_email is null then
    raise exception 'A signed-in account is required' using errcode = '42501';
  end if;
  insert into public.luma_account_deletion_requests(user_id, contact_email)
    values (caller, account_email)
    on conflict (user_id) where status = 'pending' do nothing;
  select * into strict receipt from public.luma_account_deletion_requests
    where user_id = caller and status = 'pending';
  return jsonb_build_object('status','pending','request_id',receipt.id,'due_at',receipt.due_at);
end;
$$;
revoke all on function public.luma_request_account_deletion(text) from public, anon;
grant execute on function public.luma_request_account_deletion(text) to authenticated;
commit;
