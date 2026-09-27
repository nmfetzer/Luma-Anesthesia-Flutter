-- Read-only RLS checks. All session claims are local and rolled back.
begin;
set local role anon;
select set_config('luma.qa.anon_catalog',
  (select count(*)::text from public.quick_reference_catalog), true);
select set_config('luma.qa.anon_body',
  (select count(*)::text from public.quick_reference_sections), true);
reset role;

select set_config('request.jwt.claims',
  '{"sub":"00000000-0000-0000-0000-000000000001","role":"authenticated","is_anonymous":false}',true);
set local role authenticated;
select set_config('luma.qa.unpaid_body',
  (select count(*)::text from public.quick_reference_sections), true);
select set_config('luma.qa.client_can_write',
  (has_table_privilege('authenticated','public.quick_reference_sections','INSERT')
   or has_table_privilege('authenticated','public.quick_reference_sections','UPDATE')
   or has_table_privilege('authenticated','public.quick_reference_catalog','UPDATE'))::text, true);
reset role;

-- Choose an existing eligible account; do not create or change any entitlement.
select set_config('request.jwt.claims',
  jsonb_build_object('sub',user_id,'role','authenticated','is_anonymous',false)::text, true)
from public.luma_content_entitlements
where entitlement='clinical_premium' and revoked_at is null and valid_until>now()
order by valid_until desc limit 1;
set local role authenticated;
select set_config('luma.qa.premium_body',
  (select count(*)::text from public.quick_reference_sections),true);
reset role;

select set_config('request.jwt.claims',
  (current_setting('request.jwt.claims')::jsonb || '{"is_anonymous":true}'::jsonb)::text,true);
set local role authenticated;
select set_config('luma.qa.anonymous_auth_body',
  (select count(*)::text from public.quick_reference_sections),true);
reset role;

select jsonb_build_object(
  'public_catalog_count',current_setting('luma.qa.anon_catalog')::int,
  'anonymous_body_count',current_setting('luma.qa.anon_body')::int,
  'unpaid_body_count',current_setting('luma.qa.unpaid_body')::int,
  'premium_body_count',current_setting('luma.qa.premium_body')::int,
  'anonymous_authenticated_body_count',current_setting('luma.qa.anonymous_auth_body')::int,
  'client_can_write',current_setting('luma.qa.client_can_write')::boolean
) as quick_reference_access_checks;
rollback;
