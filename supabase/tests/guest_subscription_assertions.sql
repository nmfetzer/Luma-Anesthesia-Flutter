-- Runs after the migration. Each block raises on failure.
INSERT INTO auth.users(id,is_anonymous,email_confirmed_at,banned_until) VALUES
 ('a0000000-0000-4000-8000-000000000001',true,NULL,NULL),           -- guest
 ('a0000000-0000-4000-8000-000000000002',true,NULL,now()+interval '1 day'), -- banned guest
 ('b0000000-0000-4000-8000-000000000001',false,now(),NULL),         -- confirmed account
 ('b0000000-0000-4000-8000-000000000002',false,NULL,NULL),          -- unconfirmed account
 ('a0000000-0000-4000-8000-000000000003',true,NULL,NULL),           -- paying guest
 ('a0000000-0000-4000-8000-000000000004',true,NULL,NULL);           -- guest, self-enrollment off

CREATE FUNCTION pg_temp.as_user(u uuid, anon boolean) RETURNS void LANGUAGE sql AS $$
  SELECT set_config('request.jwt.claims', jsonb_build_object('sub',u,'role','authenticated','is_anonymous',anon)::text, false);
$$;
CREATE FUNCTION pg_temp.check(ok boolean, label text) RETURNS void LANGUAGE plpgsql AS $$
BEGIN IF ok IS NOT TRUE THEN RAISE EXCEPTION 'FAIL: %', label; END IF; RAISE NOTICE 'PASS: %', label; END $$;

-- 1. A guest can read the billing policy and becomes a sandbox tester.
SELECT pg_temp.as_user('a0000000-0000-4000-8000-000000000001', true);
SET ROLE authenticated;
SELECT pg_temp.check((public.luma_billing_policy()->>'user_id')='a0000000-0000-4000-8000-000000000001', 'guest billing policy returns the guest identity');
SELECT pg_temp.check((public.luma_billing_policy()->>'apple_review')::boolean, 'guest receives sandbox tester status');
SELECT pg_temp.check((public.luma_billing_policy()->>'customer_subscriptions_enabled')::boolean, 'customer subscription switch is passed through');
SELECT pg_temp.check(NOT public.has_clinical_premium_access(), 'guest without a purchase has no premium access');
RESET ROLE;

-- 2. App Review sandbox purchase as a guest unlocks premium access.
SELECT public.record_revenuecat_sandbox_access('a0000000-0000-4000-8000-000000000001', true, now()+interval '1 month', now(), 'Luma_Anesthesia_App_Monthly');
SELECT pg_temp.as_user('a0000000-0000-4000-8000-000000000001', true);
SET ROLE authenticated;
SELECT pg_temp.check(public.has_clinical_premium_access(), 'guest sandbox purchase unlocks premium');
RESET ROLE;
DO $$ BEGIN
  PERFORM public.record_revenuecat_sandbox_access('a0000000-0000-4000-8000-000000000001', true, now()+interval '1 month', now(), 'luma_anesthesia_app_monthly:monthly');
  RAISE EXCEPTION 'FAIL: non-Apple sandbox product accepted';
EXCEPTION WHEN raise_exception THEN
  IF SQLERRM <> 'Apple test products only' THEN RAISE; END IF;
  RAISE NOTICE 'PASS: guest sandbox still limited to Apple test products';
END $$;

-- 3. A real (production) guest purchase unlocks access through the normal table.
INSERT INTO public.luma_revenuecat_access VALUES('a0000000-0000-4000-8000-000000000003',true,now()+interval '10 minutes',now(),'Luma_Anesthesia_Yearly_Pro');
SELECT pg_temp.as_user('a0000000-0000-4000-8000-000000000003', true);
SET ROLE authenticated;
SELECT pg_temp.check(public.has_clinical_premium_access(), 'guest production purchase unlocks premium');
SELECT pg_temp.check(NOT (public.luma_billing_policy()->>'apple_review')::boolean, 'paying guest is never enrolled as a tester');
RESET ROLE;
-- Expired production lease no longer unlocks.
UPDATE public.luma_revenuecat_access SET valid_until=now()-interval '1 second' WHERE user_id='a0000000-0000-4000-8000-000000000003';
SELECT pg_temp.as_user('a0000000-0000-4000-8000-000000000003', true);
SET ROLE authenticated;
SELECT pg_temp.check(NOT public.has_clinical_premium_access(), 'expired guest lease does not unlock');
RESET ROLE;

-- 4. Banned guests and unconfirmed permanent accounts are not testers.
SELECT pg_temp.as_user('a0000000-0000-4000-8000-000000000002', true);
SET ROLE authenticated;
SELECT pg_temp.check(NOT (public.luma_billing_policy()->>'apple_review')::boolean, 'banned guest is not a tester');
RESET ROLE;
SELECT pg_temp.as_user('b0000000-0000-4000-8000-000000000002', false);
SET ROLE authenticated;
SELECT pg_temp.check(NOT (public.luma_billing_policy()->>'apple_review')::boolean, 'unconfirmed permanent account is still not a tester');
RESET ROLE;
SELECT pg_temp.as_user('b0000000-0000-4000-8000-000000000001', false);
SET ROLE authenticated;
SELECT pg_temp.check((public.luma_billing_policy()->>'apple_review')::boolean, 'confirmed permanent account remains a tester');
RESET ROLE;

-- 5. Turning self-enrollment off stops new guest enrollment.
UPDATE public.luma_billing_controls SET sandbox_self_enrollment_enabled=false;
SELECT pg_temp.as_user('a0000000-0000-4000-8000-000000000004', true);
SET ROLE authenticated;
SELECT pg_temp.check(NOT (public.luma_billing_policy()->>'apple_review')::boolean, 'self-enrollment switch still controls guests');
RESET ROLE;

-- 6. Signed-out callers and unknown sessions are still rejected.
SELECT set_config('request.jwt.claims', '', false);
SET ROLE authenticated;
SELECT pg_temp.check(NOT public.has_clinical_premium_access(), 'no session has no access');
DO $$ BEGIN
  PERFORM public.luma_billing_policy();
  RAISE EXCEPTION 'FAIL: signed-out policy call accepted';
EXCEPTION WHEN raise_exception THEN
  IF SQLERRM <> 'Sign-in session required' THEN RAISE; END IF;
  RAISE NOTICE 'PASS: signed-out policy call rejected';
END $$;
RESET ROLE;
SELECT pg_temp.as_user('c0000000-0000-4000-8000-000000000009', true);
SET ROLE authenticated;
DO $$ BEGIN
  PERFORM public.luma_billing_policy();
  RAISE EXCEPTION 'FAIL: unknown session accepted';
EXCEPTION WHEN raise_exception THEN
  IF SQLERRM <> 'Sign-in session required' THEN RAISE; END IF;
  RAISE NOTICE 'PASS: unknown session rejected';
END $$;
RESET ROLE;

-- 7. Execute grants are unchanged by CREATE OR REPLACE.
SELECT pg_temp.check(NOT has_function_privilege('anon','public.luma_billing_policy()','EXECUTE'), 'anon role still cannot call billing policy');
SELECT 'PASS: guest subscription purchases' AS result;
