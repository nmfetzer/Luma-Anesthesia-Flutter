-- REVIEW DRAFT. Not in migrations; do not apply implicitly with a release.
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
          AND p.revoked_at IS NULL AND p.purchased_at <= now() AND p.valid_until > now())
      OR EXISTS (SELECT 1 FROM public.luma_revenuecat_access r
        WHERE r.user_id = (SELECT auth.uid()) AND r.active AND r.valid_until > now())
    );
$$;
REVOKE ALL ON FUNCTION public.has_clinical_premium_access() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.has_clinical_premium_access() TO authenticated;
NOTIFY pgrst, 'reload schema';
COMMIT;
