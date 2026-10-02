-- Execute only in a disposable PostgreSQL database after the migration.
do $$
begin
  if has_table_privilege('anon', 'public.drug_reference_cache', 'select') or
     has_table_privilege('authenticated', 'public.drug_reference_cache', 'insert') or
     has_function_privilege('anon', 'public.luma_claim_drug_reference_refresh(text)', 'execute') then
    raise exception 'Client cache access is not restricted';
  end if;
  if not public.luma_claim_drug_reference_refresh('drug1') then raise exception 'Cold lease failed'; end if;
  if public.luma_claim_drug_reference_refresh('drug1') then raise exception 'Duplicate lease allowed'; end if;
  if public.luma_claim_drug_reference_refresh('../invalid') then raise exception 'Invalid ID allowed'; end if;
  update public.drug_reference_cache set next_refresh_at=now()-interval '1 second' where medication_id='drug1';
  if not public.luma_claim_drug_reference_refresh('drug1') then raise exception 'Expired lease failed'; end if;
  update public.drug_reference_refresh_budget set used = 20;
  if public.luma_claim_drug_reference_refresh('drug2') then raise exception 'Global budget exceeded'; end if;
  update public.drug_reference_refresh_budget set window_started=now()-interval '2 minutes';
  if not public.luma_claim_drug_reference_refresh('drug2') then raise exception 'Budget window did not reset'; end if;
end $$;
