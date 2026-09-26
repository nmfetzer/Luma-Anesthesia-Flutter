-- Reference-only taxonomy and private revisions. No published prose replaced.
alter table public.crisis_catalog drop constraint crisis_catalog_category_check;
alter table public.crisis_catalog add constraint crisis_catalog_category_check
  check (category in ('resuscitation','neurological','cardiac','airway',
    'toxicity','regional','metabolic','ob','pediatric','mental'));

update public.crisis_catalog set category = case
  when slug in ('cardiac_meds','pals') then 'resuscitation'
  when slug in ('cva','increased-intracranial-pressure-icp','perioperative-seizures')
    then 'neurological'
  when slug in ('high-spinal-total-spinal','last') then 'regional'
  when slug = 'mental_health' then 'mental'
  when slug = 'transfusion_rx' then 'toxicity'
  else category end;

create table public.crisis_reference_drafts (
  slug text primary key references public.crisis_catalog(slug),
  revision text not null,
  content jsonb not null check (jsonb_typeof(content) = 'object'),
  updated_at timestamptz not null default now()
);
alter table public.crisis_reference_drafts enable row level security;
revoke all on public.crisis_reference_drafts from anon, authenticated;
grant select on public.crisis_reference_drafts to authenticated;
grant all on public.crisis_reference_drafts to service_role;
create policy "Reviewers read unpublished reference revisions"
  on public.crisis_reference_drafts for select to authenticated
  using (public.is_crisis_reviewer());
