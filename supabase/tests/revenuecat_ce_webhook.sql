BEGIN;
SELECT set_config('luma.webhook_test_user',gen_random_uuid()::text,true);
INSERT INTO auth.users(id,is_anonymous)
VALUES(current_setting('luma.webhook_test_user')::uuid,false);
-- Test-only activation; rolls back with all fixtures.
UPDATE public.luma_ce_bonus_products SET enabled=true WHERE store='APP_STORE'
  AND product_id IN ('Medication_Review_for_the_Experienced_CRNA','3_course_bundle_pack',
    'uncommon_anesthesia_events','legal_essentials_CRNA');
DO $$
DECLARE u uuid:=current_setting('luma.webhook_test_user')::uuid;
BEGIN
  PERFORM public.process_revenuecat_ce_event('__wh_course','NON_RENEWING_PURCHASE','__app',
    '__wh_tx1','Medication_Review_for_the_Experienced_CRNA',u,now(),now());
  PERFORM public.process_revenuecat_ce_event('__wh_course','NON_RENEWING_PURCHASE','__app',
    '__wh_tx1','Medication_Review_for_the_Experienced_CRNA',u,now(),now());
  ASSERT (SELECT count(*)=1 FROM public.luma_ce_webhook_events WHERE event_id='__wh_course');
  PERFORM public.process_revenuecat_ce_event('__wh_bundle','NON_RENEWING_PURCHASE','__app',
    '__wh_tx2','3_course_bundle_pack',u,now(),now());
  PERFORM public.process_revenuecat_ce_event('__wh_additional','NON_RENEWING_PURCHASE','__app',
    '__wh_tx3','uncommon_anesthesia_events',u,now(),now());
  ASSERT (SELECT sum(awarded_months)=3 FROM public.luma_ce_bonus_purchases WHERE user_id=u);
  ASSERT (SELECT awarded_months=2 FROM public.luma_ce_bonus_purchases WHERE transaction_id='__wh_tx2');
  ASSERT (SELECT awarded_months=0 FROM public.luma_ce_bonus_purchases WHERE transaction_id='__wh_tx3');
  ASSERT EXISTS(SELECT 1 FROM public.ce_course1_store_products
    WHERE store='APP_STORE' AND product_id='3_course_bundle_pack');
  BEGIN
    PERFORM public.process_revenuecat_ce_event('__wh_course','NON_RENEWING_PURCHASE','__app',
      '__wh_tx1','legal_essentials_CRNA',u,now(),now());
    RAISE EXCEPTION 'Changed event accepted';
  EXCEPTION WHEN raise_exception THEN
    IF SQLERRM<>'CE event identity mismatch' THEN RAISE; END IF;
  END;
  PERFORM public.process_revenuecat_ce_event('__wh_refund','CANCELLATION','__app',
    '__wh_tx2','3_course_bundle_pack',null,now(),now());
  ASSERT (SELECT revoked_at IS NOT NULL FROM public.luma_ce_bonus_purchases WHERE transaction_id='__wh_tx2');
  -- A distinct notification for the same refunded purchase never reactivates it.
  PERFORM public.process_revenuecat_ce_event('__wh_bundle_replay','NON_RENEWING_PURCHASE','__app',
    '__wh_tx2','3_course_bundle_pack',u,now(),now());
  ASSERT (SELECT revoked_at IS NOT NULL FROM public.luma_ce_bonus_purchases WHERE transaction_id='__wh_tx2');
  PERFORM public.process_revenuecat_ce_event('__wh_early_refund','CANCELLATION','__app',
    '__wh_tx4','legal_essentials_CRNA',null,now(),now());
  PERFORM public.process_revenuecat_ce_event('__wh_late_purchase','NON_RENEWING_PURCHASE','__app',
    '__wh_tx4','legal_essentials_CRNA',u,now(),now());
  ASSERT (SELECT revoked_at IS NOT NULL FROM public.luma_ce_bonus_purchases WHERE transaction_id='__wh_tx4');
  ASSERT NOT has_function_privilege('authenticated',
    'public.process_revenuecat_ce_event(text,text,text,text,text,uuid,timestamptz,timestamptz)','EXECUTE');
  ASSERT NOT has_table_privilege('authenticated','public.luma_ce_webhook_events','SELECT');
  -- Failed grants leave no success ledger row: the entire operation is atomic.
  UPDATE public.luma_ce_bonus_products SET enabled=false WHERE store='APP_STORE'
    AND product_id='legal_essentials_CRNA';
  BEGIN
    PERFORM public.process_revenuecat_ce_event('__wh_disabled','NON_RENEWING_PURCHASE','__app',
      '__wh_disabled_tx','legal_essentials_CRNA',u,now(),now());
    RAISE EXCEPTION 'Disabled product accepted';
  EXCEPTION WHEN raise_exception THEN
    IF SQLERRM<>'CE product is not configured' THEN RAISE; END IF;
  END;
  ASSERT NOT EXISTS(SELECT 1 FROM public.luma_ce_webhook_events WHERE event_id='__wh_disabled');
END $$;
ROLLBACK;
SELECT 'PASS: authenticated adapter, deduplication, atomicity, 1+2 cap, ownership mapping, refunds, refund-first, client denial' AS result;
