-- Owner decision: all published Quick References are free, including signed-out
-- visitors. This changes only these two tables; premium modules stay protected.
drop policy if exists quick_reference_premium_read on public.quick_reference_sections;
create policy quick_reference_published_read
  on public.quick_reference_sections for select to anon, authenticated
  using (exists (
    select 1 from public.quick_reference_catalog c
    where c.id = quick_reference_sections.id and c.is_published
  ));
comment on table public.quick_reference_sections is
  'Free published clinical Quick References. Unpublished bodies remain private; no client writes.';
