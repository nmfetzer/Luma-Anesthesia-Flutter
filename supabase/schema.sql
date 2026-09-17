-- =============================================================================
-- Luma Anesthesia — Supabase schema
--
-- Paste this ENTIRE file into Supabase → SQL Editor → New Query → Run.
-- Safe to run multiple times (uses IF NOT EXISTS / OR REPLACE).
-- =============================================================================

-- Medication table -----------------------------------------------------------
create table if not exists public.medication (
  id                text primary key,
  name              text not null,
  brand_name        text,
  class_short       text,
  category          text not null,
  high_alert        boolean not null default false,
  dea_schedule      text not null default 'non_scheduled',
  adult_dose        text,
  peds_dose         text,
  onset_duration    text,
  black_box_warning text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

-- Helpful indexes ------------------------------------------------------------
create index if not exists medication_category_idx on public.medication (category);
create index if not exists medication_name_idx     on public.medication (lower(name));

-- Row Level Security ---------------------------------------------------------
-- Anyone (including anonymous readers with the publishable key) can SELECT.
-- Writes are blocked from the client — you'll insert data via the service key
-- from the import script, which bypasses RLS.
alter table public.medication enable row level security;

drop policy if exists "public can read medication" on public.medication;
create policy "public can read medication"
  on public.medication
  for select
  to anon, authenticated
  using (true);

-- updated_at auto-touch ------------------------------------------------------
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists medication_touch on public.medication;
create trigger medication_touch
  before update on public.medication
  for each row execute function public.touch_updated_at();
