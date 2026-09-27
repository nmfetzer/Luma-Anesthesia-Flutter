-- Run with ON_ERROR_STOP after migrations. All fixtures are rolled back.
BEGIN;
INSERT INTO public.luma_ce_bonus_products(store, product_id, bonus_months, enabled)
VALUES ('APP_STORE', '__cap_course', 1, true),
       ('APP_STORE', '__cap_bundle', 3, true),
       ('PLAY_STORE', '__cap_course', 1, true),
       ('PLAY_STORE', '__cap_bundle', 3, true);
DO $$
DECLARE
  u uuid := gen_random_uuid(); b uuid := gen_random_uuid();
  r uuid := gen_random_uuid(); a uuid := gen_random_uuid();
  first_expiry timestamptz; bundle_expiry timestamptz;
  bought timestamptz := now() - interval '1 day';
BEGIN
  INSERT INTO auth.users(id, is_anonymous) VALUES (u,false),(b,false),(r,false),(a,true);
  first_expiry := public.record_verified_ce_bonus('APP_STORE','__cap_c1','__cap_course',u,bought);
  ASSERT first_expiry = ((bought AT TIME ZONE 'UTC') + interval '1 month') AT TIME ZONE 'UTC';
  ASSERT public.record_verified_ce_bonus('PLAY_STORE','__cap_c2','__cap_course',u,bought) IS NULL,
    'Another individual course across stores adds no months';
  bundle_expiry := public.record_verified_ce_bonus('PLAY_STORE','__cap_b1','__cap_bundle',u,now());
  ASSERT bundle_expiry = ((first_expiry AT TIME ZONE 'UTC') + interval '2 months') AT TIME ZONE 'UTC',
    'Bundle appends exactly two calendar months to unexpired course';
  ASSERT (SELECT awarded_months = 2 AND bonus_months = 3 AND bonus_starts_at = first_expiry
    FROM public.luma_ce_bonus_purchases WHERE transaction_id='__cap_b1'),
    'Actual award is distinct from bundle product kind';
  ASSERT public.record_verified_ce_bonus('APP_STORE','__cap_b2','__cap_bundle',u,now()) IS NULL;
  ASSERT (SELECT sum(awarded_months)=3 FROM public.luma_ce_bonus_purchases WHERE user_id=u);
  ASSERT (SELECT count(*)=4 FROM public.luma_ce_bonus_purchases WHERE user_id=u),
    'Zero-bonus purchases still recorded for course ownership';
  PERFORM set_config('request.jwt.claims',jsonb_build_object('sub',u,'is_anonymous',false)::text,true);
  ASSERT public.has_clinical_premium_access();
  PERFORM public.revoke_verified_ce_bonus('APP_STORE','__cap_c1',now());
  ASSERT NOT public.has_clinical_premium_access(),
    'Queued bundle cannot replace refunded course before its own start';
  ASSERT public.record_verified_ce_bonus('APP_STORE','__cap_c3','__cap_course',u,now()) IS NULL,
    'Refund never resets eligibility';
  ASSERT public.record_verified_ce_bonus('APP_STORE','__cap_c1','__cap_course',u,bought) IS NULL,
    'Refunded replay returns no live grant';
  PERFORM public.revoke_verified_ce_bonus('PLAY_STORE','__cap_b1',now());
  ASSERT public.record_verified_ce_bonus('APP_STORE','__cap_b3','__cap_bundle',u,now()) IS NULL;

  -- Bundle first consumes the entire budget, regardless of later purchase order.
  bundle_expiry := public.record_verified_ce_bonus('APP_STORE','__cap_bundle_first','__cap_bundle',b,bought);
  ASSERT bundle_expiry = ((bought AT TIME ZONE 'UTC') + interval '3 months') AT TIME ZONE 'UTC';
  ASSERT public.record_verified_ce_bonus('PLAY_STORE','__cap_late_course','__cap_course',b,bought - interval '1 month') IS NULL,
    'Delayed older course cannot add a fourth month';
  ASSERT public.record_verified_ce_bonus('APP_STORE','__cap_bundle_first','__cap_bundle',b,bought) = bundle_expiry;
  ASSERT (SELECT sum(awarded_months)=3 FROM public.luma_ce_bonus_purchases WHERE user_id=b);

  -- A refund received before a purchase still consumes its once-only allowance.
  PERFORM public.revoke_verified_ce_bonus('APP_STORE','__cap_refund_first',now());
  ASSERT public.record_verified_ce_bonus('APP_STORE','__cap_refund_first','__cap_course',r,bought) IS NULL;
  bundle_expiry := public.record_verified_ce_bonus('APP_STORE','__cap_after_refund','__cap_bundle',r,now());
  ASSERT bundle_expiry = ((now() AT TIME ZONE 'UTC') + interval '2 months') AT TIME ZONE 'UTC',
    'Refunded course consumes one month but does not delay bundle start';
  ASSERT (SELECT sum(awarded_months)=3 FROM public.luma_ce_bonus_purchases WHERE user_id=r);

  BEGIN
    PERFORM public.record_verified_ce_bonus('APP_STORE','__cap_anon','__cap_course',a,now());
    RAISE EXCEPTION 'Anonymous account accepted';
  EXCEPTION WHEN raise_exception THEN
    IF SQLERRM <> 'Invalid verified purchase' THEN RAISE; END IF;
  END;
  BEGIN
    PERFORM public.record_verified_ce_bonus('APP_STORE','__cap_bundle_first','__cap_bundle',b,now());
    RAISE EXCEPTION 'Changed restore date accepted';
  EXCEPTION WHEN raise_exception THEN
    IF SQLERRM <> 'Purchase identity mismatch' THEN RAISE; END IF;
  END;
END $$;
ROLLBACK;
SELECT 'PASS: lifetime cap, 1+2 upgrade timing, bundle-first, cross-store, ownership records, refunds, anonymous accounts, restore identity' AS result;
