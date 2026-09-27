-- Apple sandbox isolation. Customer sales remain OFF. No account is enrolled.
-- luma_review is private, not an exposed API schema; only verified server
-- adapters below can write test purchases. Test credits are never official CE.
BEGIN;
CREATE SCHEMA luma_review;
REVOKE ALL ON SCHEMA luma_review FROM PUBLIC,anon,authenticated,service_role;

CREATE TABLE luma_review.accounts (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  expires_at timestamptz NOT NULL,
  revoked_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE public.luma_billing_controls (
  singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton),
  customer_subscriptions_enabled boolean NOT NULL DEFAULT false
);
INSERT INTO public.luma_billing_controls DEFAULT VALUES;
ALTER TABLE public.luma_billing_controls ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.luma_billing_controls FROM PUBLIC,anon,authenticated;
GRANT SELECT,UPDATE ON public.luma_billing_controls TO service_role;

CREATE FUNCTION luma_review.is_tester(uid uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT EXISTS(SELECT 1 FROM luma_review.accounts a JOIN auth.users u ON u.id=a.user_id
    WHERE a.user_id=uid AND a.revoked_at IS NULL AND a.expires_at>now()
      AND u.is_anonymous=false);
$$;

-- Dedicated empty accounts only. Renewal preserves all test purchase history.
-- Never enroll an owner/provider or a customer account with real learning/sales.
CREATE FUNCTION public.enroll_luma_apple_reviewer(p_user_id uuid,p_expires_at timestamptz)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE n integer; occupied boolean;
BEGIN
  IF p_expires_at IS NULL OR p_expires_at<=now()
    OR p_expires_at>now()+interval '60 days'
    OR NOT EXISTS(SELECT 1 FROM auth.users WHERE id=p_user_id AND is_anonymous=false)
  THEN RAISE EXCEPTION 'Permanent test account and expiry within 60 days required'; END IF;
  IF EXISTS(SELECT 1 FROM public.luma_ce_bonus_purchases WHERE user_id=p_user_id)
    OR EXISTS(SELECT 1 FROM public.luma_revenuecat_access WHERE user_id=p_user_id AND active)
    OR EXISTS(SELECT 1 FROM public.luma_content_entitlements WHERE user_id=p_user_id)
  THEN RAISE EXCEPTION 'Use a dedicated test account without production access'; END IF;
  FOR n IN 1..3 LOOP
    EXECUTE format('SELECT EXISTS(SELECT 1 FROM public.ce_course%s_reviewers WHERE user_id=$1)
      OR EXISTS(SELECT 1 FROM public.ce_course%s_certificates WHERE user_id=$1)
      OR EXISTS(SELECT 1 FROM public.ce_course%s_state WHERE user_id=$1
        AND (NOT is_preview OR NOT EXISTS(SELECT 1 FROM luma_review.accounts WHERE user_id=$1)))',n,n,n)
      INTO occupied USING p_user_id;
    IF occupied THEN RAISE EXCEPTION 'Use an empty dedicated test account'; END IF;
  END LOOP;
  INSERT INTO luma_review.accounts(user_id,expires_at) VALUES(p_user_id,p_expires_at)
  ON CONFLICT(user_id) DO UPDATE SET expires_at=excluded.expires_at,revoked_at=NULL;
END $$;
CREATE FUNCTION public.revoke_luma_apple_reviewer(p_user_id uuid)
RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path='' AS $$
  UPDATE luma_review.accounts SET revoked_at=now() WHERE user_id=p_user_id;
$$;
REVOKE ALL ON FUNCTION public.enroll_luma_apple_reviewer(uuid,timestamptz),
  public.revoke_luma_apple_reviewer(uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.enroll_luma_apple_reviewer(uuid,timestamptz),
  public.revoke_luma_apple_reviewer(uuid) TO service_role;

-- Clone the tested production accounting algorithm into separate empty tables.
-- No production rows, eligibility flags or grants are copied.
DO $$
DECLARE name text; definition text; object_name text; expected_hash text;
BEGIN
  FOREACH name IN ARRAY ARRAY['luma_ce_bonus_products','luma_ce_bonus_purchases',
    'luma_ce_bonus_refunds','luma_ce_webhook_events','luma_revenuecat_access'] LOOP
    EXECUTE format('CREATE TABLE luma_review.%I (LIKE public.%I INCLUDING ALL)',name,name);
    EXECUTE format('ALTER TABLE luma_review.%I ENABLE ROW LEVEL SECURITY',name);
  END LOOP;
  FOREACH name IN ARRAY ARRAY[
    'record_verified_ce_bonus(text,text,text,uuid,timestamptz)',
    'revoke_verified_ce_bonus(text,text,timestamptz)',
    'process_revenuecat_ce_event(text,text,text,text,text,uuid,timestamptz,timestamptz)',
    'record_revenuecat_access(uuid,boolean,timestamptz,timestamptz,text)'] LOOP
    expected_hash:=CASE split_part(name,'(',1)
      WHEN 'record_verified_ce_bonus' THEN '94c43bee939e97575ec11b1c0da6d23c'
      WHEN 'revoke_verified_ce_bonus' THEN '6fc9102fc1b206760fd06378abfff6c0'
      WHEN 'process_revenuecat_ce_event' THEN '52535c4cda1d37b8d0c68e4123791e1b'
      WHEN 'record_revenuecat_access' THEN '6ab51210c45f1d31411f5d0939ed148a' END;
    IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=('public.'||name)::regprocedure)<>expected_hash
    THEN RAISE EXCEPTION 'Accounting function % changed; review before copying',name; END IF;
    definition := pg_get_functiondef(('public.'||name)::regprocedure);
    FOREACH object_name IN ARRAY ARRAY[
      'record_verified_ce_bonus','revoke_verified_ce_bonus','process_revenuecat_ce_event',
      'record_revenuecat_access','luma_ce_bonus_products','luma_ce_bonus_purchases',
      'luma_ce_bonus_refunds','luma_ce_webhook_events','luma_revenuecat_access'] LOOP
      definition := replace(definition,'public.'||object_name,'luma_review.'||object_name);
    END LOOP;
    EXECUTE definition;
  END LOOP;
END $$;
INSERT INTO luma_review.luma_ce_bonus_products(store,product_id,bonus_months,enabled)
VALUES ('APP_STORE','Medication_Review_for_the_Experienced_CRNA',1,true),
 ('APP_STORE','uncommon_anesthesia_events',1,true),
 ('APP_STORE','legal_essentials_CRNA',1,true),
 ('APP_STORE','3_course_bundle_pack',3,true);

CREATE FUNCTION public.process_revenuecat_ce_sandbox_event(
  p_event_id text,p_kind text,p_app_id text,p_transaction_id text,p_product_id text,
  p_user_id uuid,p_purchased_at timestamptz,p_occurred_at timestamptz
) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
BEGIN
  IF p_app_id IS DISTINCT FROM 'appbafd32b582' THEN RAISE EXCEPTION 'Wrong Apple app'; END IF;
  -- Unknown/expired testers get no grant. Refund tombstones still remain useful
  -- after revocation and before a delayed purchase; refunds never reset budget.
  IF p_kind='NON_RENEWING_PURCHASE' AND NOT luma_review.is_tester(p_user_id) THEN RETURN; END IF;
  PERFORM luma_review.process_revenuecat_ce_event(p_event_id,p_kind,p_app_id,
    p_transaction_id,p_product_id,p_user_id,p_purchased_at,p_occurred_at);
END $$;
CREATE FUNCTION public.record_revenuecat_sandbox_access(
  p_user_id uuid,p_active boolean,p_valid_until timestamptz,p_checked_at timestamptz,p_product_id text
) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
BEGIN
  IF NOT luma_review.is_tester(p_user_id) THEN RETURN; END IF;
  IF p_product_id IS NOT NULL AND p_product_id NOT IN
    ('Luma_Anesthesia_App_Monthly','Luma_Anesthesia_Yearly_Pro')
  THEN RAISE EXCEPTION 'Apple test products only'; END IF;
  PERFORM luma_review.record_revenuecat_access(p_user_id,p_active,p_valid_until,p_checked_at,p_product_id);
END $$;
REVOKE ALL ON FUNCTION public.process_revenuecat_ce_sandbox_event(text,text,text,text,text,uuid,timestamptz,timestamptz),
 public.record_revenuecat_sandbox_access(uuid,boolean,timestamptz,timestamptz,text) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.process_revenuecat_ce_sandbox_event(text,text,text,text,text,uuid,timestamptz,timestamptz),
 public.record_revenuecat_sandbox_access(uuid,boolean,timestamptz,timestamptz,text) TO service_role;

CREATE FUNCTION public.luma_billing_policy()
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE uid uuid:=auth.uid(); tester boolean;
BEGIN
  IF uid IS NULL OR NOT EXISTS(SELECT 1 FROM auth.users WHERE id=uid AND is_anonymous=false)
  THEN RAISE EXCEPTION 'Permanent sign-in required'; END IF;
  tester := luma_review.is_tester(uid);
  RETURN jsonb_build_object('user_id',uid,'apple_review',tester,
    'customer_subscriptions_enabled',(SELECT customer_subscriptions_enabled FROM public.luma_billing_controls));
END $$;
REVOKE ALL ON FUNCTION public.luma_billing_policy() FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.luma_billing_policy() TO authenticated;

CREATE FUNCTION luma_review.course_owned(uid uuid,n integer)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT luma_review.is_tester(uid) AND n BETWEEN 1 AND 3 AND EXISTS(
    SELECT 1 FROM luma_review.luma_ce_bonus_purchases WHERE user_id=uid
      AND store='APP_STORE' AND revoked_at IS NULL AND product_id IN
      ('3_course_bundle_pack',CASE n WHEN 1 THEN 'Medication_Review_for_the_Experienced_CRNA'
        WHEN 2 THEN 'uncommon_anesthesia_events' WHEN 3 THEN 'legal_essentials_CRNA' END));
$$;

CREATE OR REPLACE FUNCTION public.has_clinical_premium_access()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT auth.uid() IS NOT NULL AND coalesce(auth.jwt()->>'is_anonymous','true')='false'
    AND (
      EXISTS(SELECT 1 FROM public.luma_content_entitlements WHERE user_id=auth.uid()
        AND entitlement='clinical_premium' AND revoked_at IS NULL AND valid_until>now())
      OR EXISTS(SELECT 1 FROM public.luma_ce_bonus_purchases WHERE user_id=auth.uid()
        AND bonus_awarded AND revoked_at IS NULL AND bonus_starts_at<=now() AND valid_until>now())
      OR EXISTS(SELECT 1 FROM public.luma_revenuecat_access WHERE user_id=auth.uid() AND active AND valid_until>now())
      OR (luma_review.is_tester(auth.uid()) AND (
        EXISTS(SELECT 1 FROM luma_review.luma_ce_bonus_purchases WHERE user_id=auth.uid()
          AND bonus_awarded AND revoked_at IS NULL AND bonus_starts_at<=now() AND valid_until>now())
        OR EXISTS(SELECT 1 FROM luma_review.luma_revenuecat_access
          WHERE user_id=auth.uid() AND active AND valid_until>now()))));
$$;

-- Preserve the customer checkout logic unchanged, privately. Review checkout
-- bypasses sales/release dates ONLY for active designated testers, not customers.
ALTER FUNCTION public.luma_ce_checkout_status() SET SCHEMA luma_review;
CREATE FUNCTION public.luma_ce_checkout_status()
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE uid uuid:=auth.uid(); n integer; product text; ready boolean;
  ready_courses boolean[]:=ARRAY[false,false,false]; owned_courses boolean[]:=ARRAY[false,false,false];
  products jsonb:='[]';
BEGIN
  IF NOT luma_review.is_tester(uid) THEN RETURN luma_review.luma_ce_checkout_status(); END IF;
  FOR n IN 1..3 LOOP
    EXECUTE format('SELECT EXISTS(SELECT 1 FROM public.ce_course%s_catalog
      WHERE jsonb_typeof(metadata->''modules'')=''array''
      AND jsonb_array_length(metadata->''modules'')=$1)',n)
      INTO ready USING CASE n WHEN 2 THEN 10 ELSE 11 END;
    ready_courses[n]:=ready;
    owned_courses[n]:=luma_review.course_owned(uid,n);
  END LOOP;
  FOR n,product IN SELECT * FROM (VALUES
    (1,'Medication_Review_for_the_Experienced_CRNA'),(2,'uncommon_anesthesia_events'),
    (3,'legal_essentials_CRNA'),(4,'3_course_bundle_pack')) v(n,product) LOOP
    products:=products||jsonb_build_array(jsonb_build_object('product_id',product,
      'enabled',CASE WHEN n=4 THEN ready_courses[1] AND ready_courses[2] AND ready_courses[3] ELSE ready_courses[n] END,
      'owned',CASE WHEN n=4 THEN owned_courses[1] AND owned_courses[2] AND owned_courses[3] ELSE owned_courses[n] END));
  END LOOP;
  RETURN jsonb_build_object('user_id',uid,'apple_review',true,'products',products);
END $$;
REVOKE ALL ON FUNCTION public.luma_ce_checkout_status() FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.luma_ce_checkout_status() TO authenticated;

-- Narrow, guarded edits to current course functions, retaining curriculum,
-- assessments, official certificate conditions and provider-export permissions.
-- Every anchor must occur exactly once; unexpected drift aborts the transaction.
DO $$
DECLARE n integer; definition text; old_text text; new_text text; pair text[];
BEGIN
  FOR n IN 1..3 LOOP
    definition:=pg_get_functiondef(format('public.ce_course%s(text,jsonb)',n)::regprocedure);
    FOREACH pair SLICE 1 IN ARRAY ARRAY[
      ARRAY['reviewer boolean; allowed boolean;','reviewer boolean; allowed boolean; sandbox boolean;'],
      ARRAY['allowed := reviewer or (released',format('sandbox := luma_review.course_owned(uid,%s);%s  allowed := reviewer or sandbox or (released',n,chr(10))],
      ARRAY['values(uid,reviewer)','values(uid,reviewer or sandbox)'],
      ARRAY['''is_provider'',reviewer,''profile''','''is_provider'',reviewer,''is_sandbox'',sandbox,''profile'''],
      ARRAY['if s.is_preview and not reviewer then','if sandbox and not s.is_preview then raise exception ''Test account has real course state''; end if;'||chr(10)||'  if s.is_preview and not (reviewer or sandbox) then'],
      ARRAY['participation_start,participation_end,reviewer)','participation_start,participation_end,reviewer or sandbox)']
    ] LOOP
      old_text:=pair[1]; new_text:=pair[2];
      IF (length(definition)-length(replace(definition,old_text,'')))/length(old_text)<>1
      THEN RAISE EXCEPTION 'Course % changed; review migration before retry',n; END IF;
      definition:=replace(definition,old_text,new_text);
    END LOOP;
    EXECUTE definition;
    definition:=pg_get_functiondef(format('public.ce_course%s_certificate(text)',n)::regprocedure);
    old_text:=format('reviewer := exists(select 1 from public.ce_course%s_reviewers where user_id=uid);',n);
    new_text:=format('reviewer := exists(select 1 from public.ce_course%s_reviewers where user_id=uid) OR luma_review.course_owned(uid,%s);',n,n);
    IF (length(definition)-length(replace(definition,old_text,'')))/length(old_text)<>1
    THEN RAISE EXCEPTION 'Certificate % changed; review migration before retry',n; END IF;
    EXECUTE replace(definition,old_text,new_text);
  END LOOP;
END $$;

ALTER TABLE luma_review.accounts ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON ALL TABLES IN SCHEMA luma_review FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA luma_review FROM PUBLIC,anon,authenticated,service_role;
NOTIFY pgrst,'reload schema';
COMMIT;
