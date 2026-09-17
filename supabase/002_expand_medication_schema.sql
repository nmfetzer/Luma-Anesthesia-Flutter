-- =============================================================================
-- Luma Anesthesia — schema expansion for full Base44 Medication fields
--
-- Adds every field from the Base44 Medication entity that we didn't already have.
-- Safe to run multiple times (uses ADD COLUMN IF NOT EXISTS).
-- Preserves existing 47 seed rows.
--
-- Paste this into Supabase → SQL Editor → New Query → Run.
-- =============================================================================

-- Full classification (long form) --------------------------------------------
alter table public.medication add column if not exists classification text;

-- Warnings -------------------------------------------------------------------
alter table public.medication add column if not exists lasa_warning text;

-- Multi-category cross-referencing -------------------------------------------
alter table public.medication add column if not exists secondary_categories text[];

-- Clinical narrative fields --------------------------------------------------
alter table public.medication add column if not exists indications text;
alter table public.medication add column if not exists mechanism text;

-- Dosing calculators ---------------------------------------------------------
alter table public.medication add column if not exists dose_mg_per_kg_min numeric;
alter table public.medication add column if not exists dose_mg_per_kg_max numeric;
alter table public.medication add column if not exists dose_unit text;
alter table public.medication add column if not exists is_infusion boolean default false;

-- Concentration & mixing -----------------------------------------------------
alter table public.medication add column if not exists concentration_mixing text;
alter table public.medication add column if not exists requires_dilution boolean default false;
alter table public.medication add column if not exists target_concentration text;
alter table public.medication add column if not exists standard_recipe text;
alter table public.medication add column if not exists final_volume_ml numeric;
alter table public.medication add column if not exists diluent text;
alter table public.medication add column if not exists alternative_concentrations text;
alter table public.medication add column if not exists stability_hours_room_temp numeric;
alter table public.medication add column if not exists stability_hours_refrigerated numeric;
alter table public.medication add column if not exists mixing_pearls text;
alter table public.medication add column if not exists notes text;

-- Available forms & routes ---------------------------------------------------
alter table public.medication add column if not exists common_concentrations text;
alter table public.medication add column if not exists dosage_forms text;
alter table public.medication add column if not exists routes text;

-- Pharmacokinetic timing (numeric for calculators) ---------------------------
alter table public.medication add column if not exists onset_minutes numeric;
alter table public.medication add column if not exists duration_minutes numeric;

-- Safety ---------------------------------------------------------------------
alter table public.medication add column if not exists contraindications text;
alter table public.medication add column if not exists side_effects text;
alter table public.medication add column if not exists serious_effects text;
alter table public.medication add column if not exists drug_interactions text;
alter table public.medication add column if not exists interactions_critical text[];

-- Administration -------------------------------------------------------------
alter table public.medication add column if not exists administration_details text;
alter table public.medication add column if not exists special_populations text;
alter table public.medication add column if not exists pregnancy_lactation text;
alter table public.medication add column if not exists warnings_precautions text;
alter table public.medication add column if not exists pharmacokinetics text;
alter table public.medication add column if not exists antidote_reversal text;
alter table public.medication add column if not exists clinical_pearls text;
alter table public.medication add column if not exists special_considerations text;

-- Monitoring (rendered as chips in the UI) -----------------------------------
alter table public.medication add column if not exists monitoring_parameters text[];

-- Premium deep-dive content --------------------------------------------------
alter table public.medication add column if not exists deep_dive_content text;

-- Structured citations (stored as JSONB — array of citation objects) --------
-- Each entry: {number, tier, type, citation, url}
alter table public.medication add column if not exists sources jsonb;

-- Review metadata ------------------------------------------------------------
alter table public.medication add column if not exists last_reviewed date;
alter table public.medication add column if not exists clinical_reviewer text;
alter table public.medication add column if not exists review_cycle_months integer;

-- Helpful indexes for the new fields ----------------------------------------
create index if not exists medication_secondary_categories_idx
  on public.medication using gin (secondary_categories);
create index if not exists medication_is_infusion_idx
  on public.medication (is_infusion) where is_infusion = true;
create index if not exists medication_last_reviewed_idx
  on public.medication (last_reviewed desc);

-- Sanity check: RLS is still enabled and read policy still exists ----------
-- (No-op if already configured, kept here for auditability.)
alter table public.medication enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'medication'
      and policyname = 'public can read medication'
  ) then
    create policy "public can read medication"
      on public.medication
      for select
      to anon, authenticated
      using (true);
  end if;
end $$;
