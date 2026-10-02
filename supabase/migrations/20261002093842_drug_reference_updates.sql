-- Additive public-source cache. Does not modify clinical records or access rules.
-- Applied with approval on 2026-10-02; filename matches Supabase's recorded version.
begin;
create table public.drug_reference_cache (
  medication_id text primary key,
  payload jsonb not null default '{}'::jsonb,
  next_refresh_at timestamptz not null default now(),
  constraint drug_reference_cache_size check (octet_length(payload::text) < 250000)
);
alter table public.drug_reference_cache enable row level security;
revoke all on public.drug_reference_cache from public, anon, authenticated;
grant all on public.drug_reference_cache to service_role;

-- Service-only atomic lease: deduplicates cold requests and caps outbound
-- refreshes globally at 20 medication lookups/minute, even across edge instances.
create table public.drug_reference_refresh_budget (
  singleton boolean primary key default true check(singleton),
  window_started timestamptz not null,
  used integer not null default 0
);
alter table public.drug_reference_refresh_budget enable row level security;
revoke all on public.drug_reference_refresh_budget from public, anon, authenticated;
grant all on public.drug_reference_refresh_budget to service_role;
insert into public.drug_reference_refresh_budget values (true, now(), 0);

create function public.luma_claim_drug_reference_refresh(p_id text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare claimed boolean; current_budget public.drug_reference_refresh_budget%rowtype;
begin
  if p_id is null or p_id !~ '^[a-zA-Z0-9_-]{1,80}$' then return false; end if;
  select * into current_budget from public.drug_reference_refresh_budget
    where singleton = true for update;
  if current_budget.window_started < now() - interval '1 minute' then
    update public.drug_reference_refresh_budget
      set window_started = now(), used = 0 where singleton = true;
    current_budget.used := 0;
  end if;
  if current_budget.used >= 20 then return false; end if;
  insert into public.drug_reference_cache (medication_id, next_refresh_at)
    values (p_id, now() + interval '1 minute')
    on conflict (medication_id) do update
      set next_refresh_at = now() + interval '1 minute'
      where public.drug_reference_cache.next_refresh_at <= now()
    returning true into claimed;
  if coalesce(claimed, false) then
    update public.drug_reference_refresh_budget set used = used + 1 where singleton = true;
  end if;
  return coalesce(claimed, false);
end;
$$;
revoke all on function public.luma_claim_drug_reference_refresh(text) from public, anon, authenticated;
grant execute on function public.luma_claim_drug_reference_refresh(text) to service_role;
commit;
