-- LOCAL ONLY; fixtures roll back. Run after the earlier sandbox regression.
BEGIN;
CREATE FUNCTION pg_temp.check(ok boolean,message text) RETURNS void LANGUAGE plpgsql AS $$
BEGIN IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %',message; END IF; END $$;
INSERT INTO auth.users(id,is_anonymous,email_confirmed_at,banned_until) VALUES
 ('bbbbbbbb-0000-4000-8000-000000000001',false,now(),NULL),
 ('bbbbbbbb-0000-4000-8000-000000000002',false,now(),NULL),
 ('bbbbbbbb-0000-4000-8000-000000000003',false,NULL,NULL),
 ('bbbbbbbb-0000-4000-8000-000000000004',true,now(),NULL),
 ('bbbbbbbb-0000-4000-8000-000000000005',false,now(),NULL),
 ('bbbbbbbb-0000-4000-8000-000000000006',false,now(),now()+interval '1 day'),
 ('bbbbbbbb-0000-4000-8000-000000000007',false,now(),NULL),
 ('bbbbbbbb-0000-4000-8000-000000000008',false,now(),NULL);
SELECT pg_temp.check(NOT has_function_privilege('authenticated',
 'public.enroll_luma_apple_reviewer(uuid,timestamptz)','EXECUTE'),'admin enrollment stays private');
SELECT pg_temp.check(NOT has_schema_privilege('authenticated','luma_review','USAGE'),'test ledger stays private');
SELECT pg_temp.check(NOT has_function_privilege('anon','public.luma_billing_policy()','EXECUTE'),'anonymous policy denied');

SELECT set_config('request.jwt.claims','{"sub":"bbbbbbbb-0000-4000-8000-000000000001","is_anonymous":false}',true);
SET LOCAL ROLE authenticated;
SELECT pg_temp.check((public.luma_billing_policy()->>'apple_review')::boolean,
 'fresh verified account enrolls without email allowlist');
SELECT pg_temp.check(NOT public.has_clinical_premium_access(),'enrollment gives no free clinical access');
SELECT pg_temp.check((SELECT bool_and((x->>'enabled')::boolean AND NOT (x->>'owned')::boolean)
 FROM jsonb_array_elements(public.luma_ce_checkout_status()->'products') x),'CE checkout offered without course ownership');
SELECT pg_temp.check(NOT (public.ce_course1('access','{}')->>'has_access')::boolean,'unpaid course stays locked');
RESET ROLE;
SELECT pg_temp.check((SELECT count(*)=1 FROM luma_review.accounts),'only own account enrolled');
DO $$ DECLARE original_expiry timestamptz; BEGIN
 SELECT expires_at INTO original_expiry FROM luma_review.accounts
   WHERE user_id='bbbbbbbb-0000-4000-8000-000000000001';
 PERFORM public.luma_billing_policy();
 PERFORM pg_temp.check((SELECT expires_at=original_expiry FROM luma_review.accounts
   WHERE user_id='bbbbbbbb-0000-4000-8000-000000000001'),'repeated calls do not extend eligibility');
END $$;

-- CE first: a different account need not visit the subscription paywall.
SELECT set_config('request.jwt.claims','{"sub":"bbbbbbbb-0000-4000-8000-000000000002","is_anonymous":false}',true);
SET LOCAL ROLE authenticated;
SELECT pg_temp.check((public.luma_ce_checkout_status()->>'apple_review')::boolean,'CE-first enrollment');
RESET ROLE;
SELECT pg_temp.check((SELECT count(*)=2 FROM luma_review.accounts),'two independently enrolled accounts');
SELECT public.process_revenuecat_ce_sandbox_event('open-ce','NON_RENEWING_PURCHASE','appbafd32b582',
 'open-tx','3_course_bundle_pack','bbbbbbbb-0000-4000-8000-000000000002',now(),now());
SELECT pg_temp.check((public.ce_course1('access','{}')->>'has_access')::boolean,'verified sandbox purchase unlocks CE');
SELECT pg_temp.check((public.ce_course1('access','{}')->>'is_preview')::boolean,'sandbox stays zero-credit preview');
SELECT pg_temp.check(NOT (public.ce_course1('access','{}')->>'is_provider')::boolean,'tester never becomes admin');
SELECT pg_temp.check(NOT EXISTS(SELECT 1 FROM public.luma_ce_bonus_purchases),'real CE purchases unchanged');

-- Exclude unverified, anonymous, banned and existing production/provider users.
SELECT set_config('request.jwt.claims','{"sub":"bbbbbbbb-0000-4000-8000-000000000003","is_anonymous":false}',true);
SELECT pg_temp.check(NOT (public.luma_billing_policy()->>'apple_review')::boolean,'unconfirmed email excluded');
SELECT set_config('request.jwt.claims','{"sub":"bbbbbbbb-0000-4000-8000-000000000004","is_anonymous":true}',true);
DO $$ BEGIN
 BEGIN PERFORM public.luma_billing_policy(); RAISE EXCEPTION 'FAIL anonymous enrollment';
 EXCEPTION WHEN raise_exception THEN IF SQLERRM LIKE 'FAIL%' THEN RAISE; END IF; END;
END $$;
INSERT INTO public.luma_content_entitlements VALUES
 ('bbbbbbbb-0000-4000-8000-000000000005','clinical_premium',now()+interval '1 day',NULL);
SELECT set_config('request.jwt.claims','{"sub":"bbbbbbbb-0000-4000-8000-000000000005","is_anonymous":false}',true);
SELECT pg_temp.check(NOT (public.luma_billing_policy()->>'apple_review')::boolean,'production account excluded');
SELECT pg_temp.check(public.has_clinical_premium_access(),'production access retained');
SELECT set_config('request.jwt.claims','{"sub":"bbbbbbbb-0000-4000-8000-000000000006","is_anonymous":false}',true);
SELECT pg_temp.check(NOT (public.luma_billing_policy()->>'apple_review')::boolean,'banned account excluded');
INSERT INTO public.ce_course1_reviewers VALUES('bbbbbbbb-0000-4000-8000-000000000007');
SELECT set_config('request.jwt.claims','{"sub":"bbbbbbbb-0000-4000-8000-000000000007","is_anonymous":false}',true);
SELECT pg_temp.check(NOT (public.luma_billing_policy()->>'apple_review')::boolean,'owner/provider excluded');
SELECT pg_temp.check((SELECT count(*)=2 FROM luma_review.accounts),'excluded accounts not enrolled');

SELECT public.revoke_luma_apple_reviewer('bbbbbbbb-0000-4000-8000-000000000002');
SELECT set_config('request.jwt.claims','{"sub":"bbbbbbbb-0000-4000-8000-000000000002","is_anonymous":false}',true);
SELECT pg_temp.check(NOT (public.luma_billing_policy()->>'apple_review')::boolean,'revoked tester not reenrolled');
SELECT pg_temp.check(NOT public.has_clinical_premium_access(),'revoked sandbox bonus inaccessible');
UPDATE luma_review.accounts SET expires_at=now()-interval '1 second'
 WHERE user_id='bbbbbbbb-0000-4000-8000-000000000001';
SELECT set_config('request.jwt.claims','{"sub":"bbbbbbbb-0000-4000-8000-000000000001","is_anonymous":false}',true);
SELECT pg_temp.check(NOT (public.luma_billing_policy()->>'apple_review')::boolean,'expiry is not silently extended');

UPDATE public.luma_billing_controls SET sandbox_self_enrollment_enabled=false;
SELECT set_config('request.jwt.claims','{"sub":"bbbbbbbb-0000-4000-8000-000000000008","is_anonymous":false}',true);
SELECT pg_temp.check(NOT (public.luma_billing_policy()->>'apple_review')::boolean,'kill switch stops new enrollment');
SELECT pg_temp.check(NOT (SELECT customer_subscriptions_enabled FROM public.luma_billing_controls),'customer subscriptions remain off');
SELECT pg_temp.check(NOT EXISTS(SELECT 1 FROM public.luma_ce_bonus_products WHERE enabled),'customer CE checkout remains off');
SELECT pg_temp.check(NOT EXISTS(SELECT 1 FROM public.luma_revenuecat_access),'production subscription ledger unchanged');
ROLLBACK;
