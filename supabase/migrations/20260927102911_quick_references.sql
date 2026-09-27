-- Searchable metadata is public; clinical bodies retain premium RLS protection.
-- Version matches the migration already applied to the connected Supabase project.
create table public.quick_reference_catalog (
  id text primary key,
  reference_id text not null,
  reference_title text not null,
  title text not null,
  keywords text[] not null default '{}',
  sort_order integer not null default 0,
  is_published boolean not null default false
);
create index quick_reference_catalog_order_idx
  on public.quick_reference_catalog(reference_id, sort_order, id);

create table public.quick_reference_sections (
  id text primary key references public.quick_reference_catalog(id) on delete cascade,
  body text not null,
  version text not null,
  updated_at timestamptz not null default now()
);

alter table public.quick_reference_catalog enable row level security;
alter table public.quick_reference_sections enable row level security;
revoke all on public.quick_reference_catalog from anon, authenticated;
revoke all on public.quick_reference_sections from anon, authenticated;
grant select on public.quick_reference_catalog to anon, authenticated;
grant select on public.quick_reference_sections to anon, authenticated;

create policy quick_reference_catalog_published
  on public.quick_reference_catalog for select to anon, authenticated
  using (is_published);

create policy quick_reference_premium_read
  on public.quick_reference_sections for select to authenticated
  using (
    (select public.has_clinical_premium_access())
    and exists (
      select 1 from public.quick_reference_catalog c
      where c.id = quick_reference_sections.id and c.is_published
    )
  );

comment on table public.quick_reference_sections is
  'Owner-approved clinical quick references. No client writes or bundled paid bodies.';
