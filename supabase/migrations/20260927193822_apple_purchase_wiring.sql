-- Deploy only after review. No product, course or certificate is enabled here.
-- Adds an isolated RevenueCat authority, preserving owner/manual and CE grants.
BEGIN;
CREATE TABLE public.luma_revenuecat_access (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  active boolean NOT NULL DEFAULT false,
  valid_until timestamptz NOT NULL,
  checked_at timestamptz NOT NULL,
  product_id text,
  CONSTRAINT known_luma_product CHECK (product_id IS NULL OR product_id IN (
    'Luma_Anesthesia_App_Monthly', 'Luma_Anesthesia_Yearly_Pro',
    'luma_anesthesia_app_monthly', 'luma_anesthesia_yearly_pro',
    'luma_anesthesia_app_monthly:monthly', 'luma_anesthesia_yearly_pro:yearly'))
);
ALTER TABLE public.luma_revenuecat_access ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.luma_revenuecat_access FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.luma_revenuecat_access TO service_role;

-- Discard stale concurrent RevenueCat snapshots. Only service-role can call.
CREATE FUNCTION public.record_revenuecat_access(
  p_user_id uuid, p_active boolean, p_valid_until timestamptz,
  p_checked_at timestamptz, p_product_id text
) RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path = '' AS $$
  INSERT INTO public.luma_revenuecat_access
    (user_id, active, valid_until, checked_at, product_id)
  VALUES (p_user_id, p_active, LEAST(p_valid_until, now() + interval '15 minutes'),
    p_checked_at, p_product_id)
  ON CONFLICT (user_id) DO UPDATE SET active = excluded.active,
    valid_until = excluded.valid_until, checked_at = excluded.checked_at,
    product_id = excluded.product_id
  WHERE excluded.checked_at >= luma_revenuecat_access.checked_at;
$$;
REVOKE ALL ON FUNCTION public.record_revenuecat_access(uuid,boolean,timestamptz,timestamptz,text)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.record_revenuecat_access(uuid,boolean,timestamptz,timestamptz,text)
  TO service_role;

CREATE OR REPLACE FUNCTION public.has_clinical_premium_access()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT (SELECT auth.uid()) IS NOT NULL
    AND COALESCE((SELECT auth.jwt()->>'is_anonymous'), 'true') = 'false'
    AND (
      EXISTS (SELECT 1 FROM public.luma_content_entitlements e
        WHERE e.user_id = (SELECT auth.uid()) AND e.entitlement = 'clinical_premium'
          AND e.revoked_at IS NULL AND e.valid_until > now())
      OR EXISTS (SELECT 1 FROM public.luma_ce_bonus_purchases p
        WHERE p.user_id = (SELECT auth.uid()) AND p.bonus_awarded
          AND p.revoked_at IS NULL AND p.bonus_starts_at <= now() AND p.valid_until > now())
      OR EXISTS (SELECT 1 FROM public.luma_revenuecat_access r
        WHERE r.user_id = (SELECT auth.uid()) AND r.active AND r.valid_until > now())
    );
$$;
REVOKE ALL ON FUNCTION public.has_clinical_premium_access() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.has_clinical_premium_access() TO authenticated;
NOTIFY pgrst, 'reload schema';

-- Exact Apple course mappings. Optional Course 3 migration may be in progress;
-- missing tables remain fail-closed in the status RPC below.
DO $$
DECLARE n integer; product text;
BEGIN
  FOR n,product IN SELECT * FROM (VALUES
    (1,'Medication_Review_for_the_Experienced_CRNA'),
    (2,'uncommon_anesthesia_events'),(3,'legal_essentials_CRNA')
  ) AS mapping(n,product) LOOP
    IF to_regclass(format('public.ce_course%s_store_products',n)) IS NOT NULL THEN
      EXECUTE format(
        'INSERT INTO public.ce_course%s_store_products(store,product_id)
         VALUES (''APP_STORE'',$1),(''APP_STORE'',''3_course_bundle_pack'')
         ON CONFLICT DO NOTHING',n) USING product;
    END IF;
  END LOOP;
END $$;

CREATE FUNCTION public.luma_ce_checkout_status()
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  uid uuid := auth.uid();
  n integer; product text; ready boolean; release_ok boolean;
  owned_ids text[]; course_ready boolean[] := ARRAY[false,false,false];
  products jsonb := '[]'; product_enabled boolean; owned boolean;
BEGIN
  IF uid IS NULL OR NOT EXISTS (
    SELECT 1 FROM auth.users WHERE id=uid AND is_anonymous=false
  ) THEN RAISE EXCEPTION 'Permanent sign-in required'; END IF;

  SELECT coalesce(array_agg(DISTINCT product_id),'{}') INTO owned_ids
    FROM public.luma_ce_bonus_purchases
    WHERE user_id=uid AND store='APP_STORE' AND revoked_at IS NULL;

  FOR n,product IN SELECT * FROM (VALUES
    (1,'Medication_Review_for_the_Experienced_CRNA'),
    (2,'uncommon_anesthesia_events'),(3,'legal_essentials_CRNA')
  ) AS mapping(n,product) LOOP
    ready := false;
    IF to_regclass(format('public.ce_course%s_catalog',n)) IS NOT NULL
       AND to_regclass(format('public.ce_course%s_certificate_settings',n)) IS NOT NULL
       AND to_regclass(format('public.ce_course%s_store_products',n)) IS NOT NULL THEN
      EXECUTE format(
        'SELECT EXISTS(
          SELECT 1 FROM public.ce_course%s_catalog c
          JOIN public.ce_course%s_certificate_settings s ON s.course_id=c.id
          WHERE c.released AND s.enabled AND s.approved_at IS NOT NULL
          AND jsonb_typeof(c.metadata->''modules'')=''array''
          AND jsonb_array_length(c.metadata->''modules'') >= $2
          AND EXISTS(SELECT 1 FROM public.ce_course%s_store_products
            WHERE store=''APP_STORE'' AND product_id=$1)
          AND EXISTS(SELECT 1 FROM public.ce_course%s_store_products
            WHERE store=''APP_STORE'' AND product_id=''3_course_bundle_pack'')
        )',n,n,n,n)
        INTO ready USING product, CASE n WHEN 1 THEN 11 WHEN 2 THEN 10 ELSE 1 END;
    END IF;
    -- Matches the approved course-access period, not a new pre-sale policy.
    course_ready[n] := ready AND
      current_date BETWEEN date '2026-10-01' AND date '2029-09-30';
  END LOOP;

  FOR n,product IN SELECT * FROM (VALUES
    (1,'Medication_Review_for_the_Experienced_CRNA'),
    (2,'uncommon_anesthesia_events'),(3,'legal_essentials_CRNA'),
    (4,'3_course_bundle_pack')
  ) AS mapping(n,product) LOOP
    SELECT coalesce(bool_or(enabled),false) INTO product_enabled
      FROM public.luma_ce_bonus_products
      WHERE store='APP_STORE' AND product_id=product;
    release_ok := CASE WHEN n=4
      THEN course_ready[1] AND course_ready[2] AND course_ready[3]
      ELSE course_ready[n] END;
    owned := product=ANY(owned_ids) OR '3_course_bundle_pack'=ANY(owned_ids);
    IF n=4 THEN
      owned := owned OR ARRAY['Medication_Review_for_the_Experienced_CRNA',
        'uncommon_anesthesia_events','legal_essentials_CRNA'] <@ owned_ids;
    END IF;
    products := products || jsonb_build_array(jsonb_build_object(
      'product_id',product,'enabled',product_enabled AND release_ok,'owned',owned));
  END LOOP;
  RETURN jsonb_build_object('user_id',uid,'products',products);
END $$;
REVOKE ALL ON FUNCTION public.luma_ce_checkout_status() FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.luma_ce_checkout_status() TO authenticated;
COMMIT;
