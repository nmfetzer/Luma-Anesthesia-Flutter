BEGIN;
SELECT set_config('luma.test_user', gen_random_uuid()::text, true);
SELECT set_config('luma.other_user', gen_random_uuid()::text, true);
INSERT INTO auth.users(id, is_anonymous) VALUES
  (current_setting('luma.test_user')::uuid, false),
  (current_setting('luma.other_user')::uuid, false);
INSERT INTO public.luma_ce_bonus_products(store, product_id, bonus_months, enabled)
VALUES ('APP_STORE', '__test_course', 1, true), ('PLAY_STORE', '__test_bundle', 3, true);
SELECT set_config('request.jwt.claims', jsonb_build_object(
  'sub', current_setting('luma.test_user'), 'is_anonymous', false)::text, true);
DO $$
DECLARE u uuid := current_setting('luma.test_user')::uuid;
  expiry timestamptz;
BEGIN
  ASSERT NOT public.has_clinical_premium_access(), 'Free account denied';
  -- Calendar arithmetic, including end-of-month and leap year.
  expiry := public.record_verified_ce_bonus('APP_STORE', '__test_jan',
    '__test_course', u, '2024-01-31 12:00:00+00');
  ASSERT expiry = '2024-02-29 12:00:00+00'::timestamptz, 'Calendar month clamp';
  ASSERT NOT public.has_clinical_premium_access(), 'Old restored bonus stays expired';
  expiry := public.record_verified_ce_bonus('PLAY_STORE', '__test_active',
    '__test_bundle', u, now());
  ASSERT expiry = ((now() AT TIME ZONE 'UTC') + interval '3 months') AT TIME ZONE 'UTC',
    'Three calendar months';
  ASSERT public.has_clinical_premium_access(), 'Bonus unlocks premium';
  ASSERT public.record_verified_ce_bonus('PLAY_STORE', '__test_active',
    '__test_bundle', u, now()) = expiry, 'Replay retains original expiry';
  ASSERT (SELECT count(*) FROM public.luma_ce_bonus_purchases
    WHERE transaction_id = '__test_active') = 1, 'Replay recorded once';
  ASSERT public.record_verified_ce_bonus('PLAY_STORE', '__test_repeat_bundle',
    '__test_bundle', u, now()) IS NULL, 'Second bundle earns no more months';
  ASSERT public.record_verified_ce_bonus('APP_STORE', '__test_repeat_course',
    '__test_course', u, now()) IS NULL, 'Second course earns no more months';
  ASSERT (SELECT count(*) FROM public.luma_ce_bonus_purchases
    WHERE user_id = u AND bonus_awarded) = 2, 'One lifetime bonus of each kind';
  BEGIN
    PERFORM public.record_verified_ce_bonus('PLAY_STORE', '__test_active',
      '__test_bundle', current_setting('luma.other_user')::uuid, now());
    RAISE EXCEPTION 'Test failed: account reassignment accepted';
  EXCEPTION WHEN raise_exception THEN
    IF SQLERRM <> 'Purchase identity mismatch' THEN RAISE; END IF;
  END;
  BEGIN
    PERFORM public.record_verified_ce_bonus('APP_STORE', '__test_unknown',
      '__not_configured', u, now());
    RAISE EXCEPTION 'Test failed: unknown product accepted';
  EXCEPTION WHEN raise_exception THEN
    IF SQLERRM <> 'CE product is not configured' THEN RAISE; END IF;
  END;
  PERFORM public.revoke_verified_ce_bonus('PLAY_STORE', '__test_active', now());
  ASSERT NOT public.has_clinical_premium_access(), 'Refund removes bonus';
  PERFORM public.record_verified_ce_bonus('PLAY_STORE', '__test_active',
    '__test_bundle', u, now());
  ASSERT NOT public.has_clinical_premium_access(), 'Replay cannot reinstate refund';
  PERFORM public.revoke_verified_ce_bonus('APP_STORE', '__test_refund_first', now());
  PERFORM public.record_verified_ce_bonus('APP_STORE', '__test_refund_first',
    '__test_course', u, now());
  ASSERT NOT public.has_clinical_premium_access(), 'Refund-first remains revoked';
  ASSERT (SELECT revoked_at IS NOT NULL FROM public.luma_ce_bonus_purchases
    WHERE transaction_id = '__test_refund_first'), 'Refund tombstone retained';
END $$;
INSERT INTO public.luma_content_entitlements(user_id, entitlement, valid_until)
VALUES (current_setting('luma.test_user')::uuid, 'clinical_premium', now()+interval '1 day');
SET LOCAL ROLE authenticated;
DO $$ BEGIN
  ASSERT public.has_clinical_premium_access(), 'Paid subscription survives CE refund';
  ASSERT NOT has_function_privilege(current_user,
    'public.record_verified_ce_bonus(text,text,text,uuid,timestamptz)','EXECUTE'),
    'Client cannot grant itself a bonus';
  ASSERT NOT has_function_privilege(current_user,
    'public.revoke_verified_ce_bonus(text,text,timestamptz)','EXECUTE'),
    'Client cannot modify refunds';
  ASSERT NOT has_table_privilege(current_user,
    'public.luma_ce_bonus_purchases','INSERT'), 'Client cannot write purchases';
END $$;
SELECT set_config('request.jwt.claims', jsonb_build_object(
  'sub',current_setting('luma.test_user'),'is_anonymous',true)::text,true);
DO $$ BEGIN
  ASSERT NOT public.has_clinical_premium_access(), 'Anonymous sessions denied';
END $$;
SELECT set_config('request.jwt.claims', jsonb_build_object(
  'sub',current_setting('luma.other_user'),'is_anonymous',false)::text,true);
DO $$ BEGIN
  ASSERT NOT public.has_clinical_premium_access(), 'Other account not entitled';
  ASSERT (SELECT count(*) FROM public.luma_ce_bonus_purchases) = 0,
    'Other account cannot see purchases';
END $$;
RESET ROLE;
ROLLBACK;
SELECT 'PASS: calendar months, restore/replay, refunds, product mapping, identity, RLS, and independent paid access' AS result;
