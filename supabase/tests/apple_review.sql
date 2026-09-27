-- LOCAL ONLY. All fixtures roll back. No production accounts are used.
BEGIN;
CREATE FUNCTION pg_temp.check(ok boolean,message text) RETURNS void LANGUAGE plpgsql AS $$
BEGIN IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %',message; END IF; END $$;
INSERT INTO auth.users(id,is_anonymous) VALUES
 ('aaaaaaaa-0000-4000-8000-000000000001',false),
 ('aaaaaaaa-0000-4000-8000-000000000002',false),
 ('aaaaaaaa-0000-4000-8000-000000000003',false),
 ('aaaaaaaa-0000-4000-8000-000000000004',true);
SELECT pg_temp.check(NOT (SELECT customer_subscriptions_enabled FROM public.luma_billing_controls),'customer subscriptions stay disabled');
SELECT pg_temp.check(NOT EXISTS(SELECT 1 FROM public.luma_ce_bonus_products WHERE enabled),'CE products remain disabled');
SELECT pg_temp.check(NOT has_schema_privilege('authenticated','luma_review','USAGE'),'private schema inaccessible');
SELECT pg_temp.check(NOT has_function_privilege('authenticated','public.enroll_luma_apple_reviewer(uuid,timestamptz)','EXECUTE'),'no self enrollment');
SELECT pg_temp.check(NOT has_function_privilege('authenticated','public.process_revenuecat_ce_sandbox_event(text,text,text,text,text,uuid,timestamptz,timestamptz)','EXECUTE'),'no client test receipts');
SELECT pg_temp.check(NOT has_function_privilege('service_role','luma_review.record_verified_ce_bonus(text,text,text,uuid,timestamptz)','EXECUTE'),'private helper cannot bypass allowlist');

DO $$ BEGIN
  BEGIN PERFORM public.enroll_luma_apple_reviewer('aaaaaaaa-0000-4000-8000-000000000004',now()+interval '7 days');
    RAISE EXCEPTION 'FAIL anonymous enrollment succeeded';
  EXCEPTION WHEN raise_exception THEN IF SQLERRM LIKE 'FAIL%' THEN RAISE; END IF; END;
END $$;
SELECT public.enroll_luma_apple_reviewer('aaaaaaaa-0000-4000-8000-000000000001',now()+interval '7 days');
SELECT public.enroll_luma_apple_reviewer('aaaaaaaa-0000-4000-8000-000000000002',now()+interval '7 days');
SELECT set_config('request.jwt.claims','{"sub":"aaaaaaaa-0000-4000-8000-000000000001","is_anonymous":false}',true);
SELECT pg_temp.check((public.luma_billing_policy()->>'apple_review')::boolean,'enrolled account policy');
SELECT pg_temp.check(NOT public.has_clinical_premium_access(),'enrollment alone grants no clinical access');
SELECT pg_temp.check((SELECT bool_and((x->>'enabled')::boolean AND NOT (x->>'owned')::boolean)
  FROM jsonb_array_elements(public.luma_ce_checkout_status()->'products') x),'test checkout enabled without free course grants');

DO $$
DECLARE uid uuid:='aaaaaaaa-0000-4000-8000-000000000001'; t timestamptz:=now()-interval '1 hour';
BEGIN
  PERFORM public.process_revenuecat_ce_sandbox_event('first','NON_RENEWING_PURCHASE','appbafd32b582',
    'tx1','Medication_Review_for_the_Experienced_CRNA',uid,t,t);
  PERFORM public.process_revenuecat_ce_sandbox_event('first','NON_RENEWING_PURCHASE','appbafd32b582',
    'tx1','Medication_Review_for_the_Experienced_CRNA',uid,t,t);
  PERFORM public.process_revenuecat_ce_sandbox_event('second','NON_RENEWING_PURCHASE','appbafd32b582',
    'tx2','uncommon_anesthesia_events',uid,t,t);
  PERFORM public.process_revenuecat_ce_sandbox_event('bundle','NON_RENEWING_PURCHASE','appbafd32b582',
    'tx3','3_course_bundle_pack',uid,t,t);
  PERFORM pg_temp.check((SELECT sum(awarded_months)=3 AND count(*)=3 FROM luma_review.luma_ce_bonus_purchases WHERE user_id=uid),'1 + 0 + 2 and idempotent retry');
  PERFORM pg_temp.check((SELECT awarded_months=2 FROM luma_review.luma_ce_bonus_purchases WHERE transaction_id='tx3'),'bundle upgrade awards only two');
  PERFORM pg_temp.check((SELECT valid_until=((t AT TIME ZONE 'UTC')+interval '3 months') AT TIME ZONE 'UTC'
    FROM luma_review.luma_ce_bonus_purchases WHERE transaction_id='tx3'),'calendar months and appended window');
  BEGIN
    PERFORM public.process_revenuecat_ce_sandbox_event('conflict','NON_RENEWING_PURCHASE','appbafd32b582',
      'tx1','Medication_Review_for_the_Experienced_CRNA','aaaaaaaa-0000-4000-8000-000000000002',t,t);
    RAISE EXCEPTION 'FAIL cross-account transaction accepted';
  EXCEPTION WHEN raise_exception THEN IF SQLERRM LIKE 'FAIL%' THEN RAISE; END IF; END;
END $$;
SELECT pg_temp.check(public.has_clinical_premium_access(),'test bonus unlocks clinical references');
SELECT pg_temp.check(NOT EXISTS(SELECT 1 FROM public.luma_ce_bonus_purchases),'production bonus history unchanged');
SELECT pg_temp.check(NOT EXISTS(SELECT 1 FROM public.luma_ce_webhook_events),'production event history unchanged');
SELECT pg_temp.check((SELECT bool_and((x->>'owned')::boolean)
  FROM jsonb_array_elements(public.luma_ce_checkout_status()->'products') x),'bundle owns all courses');

DO $$
DECLARE n integer; access jsonb; cert jsonb; quiz jsonb; answers jsonb; complete jsonb; no_provider boolean;
BEGIN
  FOR n IN 1..3 LOOP
    EXECUTE format('SELECT public.ce_course%s(''access'',''{}'')',n) INTO access;
    PERFORM pg_temp.check((access->>'has_access')::boolean AND (access->>'is_preview')::boolean
      AND NOT (access->>'is_provider')::boolean AND (access->>'is_sandbox')::boolean,
      'course test access, preview state, no provider privileges');
    EXECUTE format('SELECT public.ce_course%s(''profile'',$1)',n) USING jsonb_build_object(
      'full_name','App Review Tester','credentials','CRNA','location','Test location',
      'participation_start_on','2026-10-01','participation_end_on','2026-10-01');
    EXECUTE format('SELECT public.ce_course%s(''read'',''{}'')',n);
    EXECUTE format('SELECT public.ce_course%s(''quiz'',''{}'')',n) INTO quiz;
    SELECT jsonb_object_agg(x->>'question_id','a') INTO answers FROM jsonb_array_elements(quiz->'questions') x;
    EXECUTE format('SELECT public.ce_course%s(''submit'',$1)',n)
      USING jsonb_build_object('attempt_id',quiz->>'attempt_id','answers',answers);
    EXECUTE format('SELECT public.ce_course%s(''evaluate'',$1)',n) INTO complete
      USING jsonb_build_object('ratings',jsonb_build_array(5,5),'learned','Test learning',
        'barriers','No barriers','attestation',true);
    PERFORM pg_temp.check((complete->>'is_preview')::boolean AND
      (complete->>'module_credits')::numeric=0,'quiz and evaluation work without awarding real credits');
    EXECUTE format('SELECT public.ce_course%s_certificate(''preview'')',n) INTO cert;
    PERFORM pg_temp.check(cert->'certificate'->>'is_preview'='true'
      AND (cert->'certificate'->>'credits_awarded')::numeric=0,'preview certificate earns zero credits');
    BEGIN
      EXECUTE format('SELECT public.ce_course%s_certificate(''issue'')',n);
      RAISE EXCEPTION 'FAIL official test certificate issued';
    EXCEPTION WHEN raise_exception THEN IF SQLERRM LIKE 'FAIL%' THEN RAISE; END IF; END;
    EXECUTE format('SELECT count(*)=0 FROM public.ce_course%s_reviewers',n) INTO no_provider;
    PERFORM pg_temp.check(no_provider,'testers were not added as provider reviewers');
  END LOOP;
END $$;

-- Refund-before-purchase stays revoked; refunded bonuses still consume cap.
DO $$
DECLARE uid uuid:='aaaaaaaa-0000-4000-8000-000000000002'; t timestamptz:=now()-interval '1 hour';
BEGIN
  PERFORM public.process_revenuecat_ce_sandbox_event('refundfirst','CANCELLATION','appbafd32b582',
    'tx4','3_course_bundle_pack',NULL,t,t);
  PERFORM public.process_revenuecat_ce_sandbox_event('latebuy','NON_RENEWING_PURCHASE','appbafd32b582',
    'tx4','3_course_bundle_pack',uid,t,t);
  PERFORM public.process_revenuecat_ce_sandbox_event('latercourse','NON_RENEWING_PURCHASE','appbafd32b582',
    'tx5','legal_essentials_CRNA',uid,t,t);
  PERFORM pg_temp.check((SELECT revoked_at IS NOT NULL AND awarded_months=3
    FROM luma_review.luma_ce_bonus_purchases WHERE transaction_id='tx4'),'refund first tombstone');
  PERFORM pg_temp.check((SELECT awarded_months=0 FROM luma_review.luma_ce_bonus_purchases WHERE transaction_id='tx5'),'refund never resets cap');
  PERFORM public.process_revenuecat_ce_sandbox_event('ordinary','NON_RENEWING_PURCHASE','appbafd32b582',
    'tx6','3_course_bundle_pack','aaaaaaaa-0000-4000-8000-000000000003',t,t);
  PERFORM pg_temp.check(NOT EXISTS(SELECT 1 FROM luma_review.luma_ce_bonus_purchases WHERE transaction_id='tx6'),'unlisted sandbox account never unlocks');
END $$;

SELECT public.record_revenuecat_sandbox_access('aaaaaaaa-0000-4000-8000-000000000001',true,now()+interval '1 day',now(),'Luma_Anesthesia_App_Monthly');
SELECT pg_temp.check((SELECT valid_until<=now()+interval '15 minutes' FROM luma_review.luma_revenuecat_access LIMIT 1),'bounded test subscription lease');
SELECT pg_temp.check(NOT EXISTS(SELECT 1 FROM public.luma_revenuecat_access),'production subscription unchanged');
SELECT public.revoke_luma_apple_reviewer('aaaaaaaa-0000-4000-8000-000000000001');
SELECT pg_temp.check(NOT public.has_clinical_premium_access(),'revocation immediately removes bonus and subscription access');
SELECT pg_temp.check(NOT (public.ce_course1('access','{}')->>'has_access')::boolean,'revoked tester loses course access');
SELECT public.enroll_luma_apple_reviewer('aaaaaaaa-0000-4000-8000-000000000001',now()+interval '7 days');
SELECT pg_temp.check((SELECT sum(awarded_months)=3 FROM luma_review.luma_ce_bonus_purchases
  WHERE user_id='aaaaaaaa-0000-4000-8000-000000000001'),'renewal does not reset cap');
UPDATE luma_review.accounts SET expires_at=now()-interval '1 second' WHERE user_id='aaaaaaaa-0000-4000-8000-000000000001';
SELECT pg_temp.check(NOT public.has_clinical_premium_access(),'expired allowlist blocks cached grants');
SELECT set_config('request.jwt.claims','{"sub":"aaaaaaaa-0000-4000-8000-000000000003","is_anonymous":false}',true);
SELECT pg_temp.check(NOT (public.luma_billing_policy()->>'apple_review')::boolean,'ordinary customer is not a reviewer');
SELECT pg_temp.check((SELECT bool_and(NOT (x->>'enabled')::boolean AND NOT (x->>'owned')::boolean)
  FROM jsonb_array_elements(public.luma_ce_checkout_status()->'products') x),'ordinary customer sales stay disabled');
SELECT pg_temp.check(NOT (SELECT customer_subscriptions_enabled FROM public.luma_billing_controls),'subscription sales still disabled');
SELECT pg_temp.check(NOT EXISTS(SELECT 1 FROM public.luma_ce_bonus_products WHERE enabled),'CE sales still disabled');
-- Existing owner/manual access is preserved and cannot be enrolled as a tester.
INSERT INTO public.luma_content_entitlements VALUES
 ('aaaaaaaa-0000-4000-8000-000000000003','clinical_premium',now()+interval '1 day',NULL);
SELECT pg_temp.check(public.has_clinical_premium_access(),'owner/manual access preserved');
DO $$ BEGIN
  BEGIN
    PERFORM public.enroll_luma_apple_reviewer('aaaaaaaa-0000-4000-8000-000000000003',now()+interval '1 day');
    RAISE EXCEPTION 'FAIL owner account enrolled';
  EXCEPTION WHEN raise_exception THEN IF SQLERRM LIKE 'FAIL%' THEN RAISE; END IF; END;
END $$;
ROLLBACK;
