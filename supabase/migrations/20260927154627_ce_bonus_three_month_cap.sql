-- Lifetime CE bonus cap, shared across stores by permanent Supabase account.
-- Version matches the migration applied to production Supabase.
-- Product bonus_months remains the product kind (1=course, 3=bundle).
-- awarded_months is the actual benefit (0, 1, 2 or 3), including revoked grants.
LOCK TABLE public.luma_ce_bonus_purchases IN ACCESS EXCLUSIVE MODE;
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM public.luma_ce_bonus_purchases WHERE bonus_awarded
    GROUP BY user_id HAVING sum(bonus_months) > 3
  ) THEN
    RAISE EXCEPTION 'Legacy CE bonuses exceed cap; review before migration';
  END IF;
END $$;

ALTER TABLE public.luma_ce_bonus_purchases
  ADD COLUMN awarded_months integer,
  ADD COLUMN bonus_starts_at timestamptz;
UPDATE public.luma_ce_bonus_purchases SET
  awarded_months = CASE WHEN bonus_awarded THEN bonus_months ELSE 0 END,
  bonus_starts_at = purchased_at;
ALTER TABLE public.luma_ce_bonus_purchases
  ALTER COLUMN awarded_months SET NOT NULL,
  ALTER COLUMN bonus_starts_at SET NOT NULL,
  ADD CONSTRAINT ce_bonus_award_bounds CHECK (
    awarded_months BETWEEN 0 AND bonus_months
    AND bonus_awarded = (awarded_months > 0)
    AND bonus_starts_at >= purchased_at
    AND valid_until >= bonus_starts_at
  );

CREATE OR REPLACE FUNCTION public.record_verified_ce_bonus(
  p_store text, p_transaction_id text, p_product_id text,
  p_user_id uuid, p_purchased_at timestamptz
) RETURNS timestamptz
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  months integer; used_months integer; grant_months integer;
  prior public.luma_ce_bonus_purchases%ROWTYPE;
  starts_at timestamptz; expiry timestamptz; refund_time timestamptz;
BEGIN
  IF p_store IS NULL OR p_product_id IS NULL
    OR p_transaction_id IS NULL OR length(trim(p_transaction_id)) = 0
    OR p_purchased_at IS NULL OR p_purchased_at > now() + interval '5 minutes'
    OR NOT EXISTS (SELECT 1 FROM auth.users
      WHERE id = p_user_id AND is_anonymous = false) THEN
    RAISE EXCEPTION 'Invalid verified purchase';
  END IF;
  PERFORM pg_advisory_xact_lock(hashtextextended(p_store || ':' || p_transaction_id, 0));
  SELECT * INTO prior FROM public.luma_ce_bonus_purchases
    WHERE store = p_store AND transaction_id = p_transaction_id;
  IF FOUND THEN
    IF prior.user_id <> p_user_id OR prior.product_id <> p_product_id
      OR prior.purchased_at <> p_purchased_at THEN
      RAISE EXCEPTION 'Purchase identity mismatch';
    END IF;
    RETURN CASE WHEN prior.bonus_awarded AND prior.revoked_at IS NULL
      THEN prior.valid_until ELSE NULL END;
  END IF;
  SELECT bonus_months INTO months FROM public.luma_ce_bonus_products
    WHERE store = p_store AND product_id = p_product_id AND enabled;
  IF months IS NULL THEN RAISE EXCEPTION 'CE product is not configured'; END IF;

  -- Serialize all stores/products for the same account. Refunds never free budget.
  PERFORM pg_advisory_xact_lock(hashtextextended('ce-bonus-user:' || p_user_id::text, 0));
  SELECT COALESCE(sum(awarded_months), 0) INTO used_months
    FROM public.luma_ce_bonus_purchases WHERE user_id = p_user_id;
  grant_months := CASE
    WHEN months = 1 AND used_months = 0 THEN 1
    WHEN months = 3 THEN greatest(0, 3 - used_months)
    ELSE 0 END;

  -- Add an upgrade after an unrevoked course window, not on top of it.
  -- Use original verified purchase time, NEVER restore/processing time.
  SELECT greatest(p_purchased_at, COALESCE(max(valid_until), p_purchased_at))
    INTO starts_at FROM public.luma_ce_bonus_purchases
    WHERE user_id = p_user_id AND bonus_awarded AND revoked_at IS NULL;
  IF grant_months = 0 THEN starts_at := p_purchased_at; END IF;
  expiry := ((starts_at AT TIME ZONE 'UTC') +
    make_interval(months => grant_months)) AT TIME ZONE 'UTC';
  SELECT refunded_at INTO refund_time FROM public.luma_ce_bonus_refunds
    WHERE store = p_store AND transaction_id = p_transaction_id;
  -- Record ownership even when this purchase receives zero bonus months.
  INSERT INTO public.luma_ce_bonus_purchases
    (store, transaction_id, product_id, user_id, purchased_at, bonus_months,
     awarded_months, bonus_starts_at, valid_until, bonus_awarded, revoked_at)
  VALUES (p_store, p_transaction_id, p_product_id, p_user_id, p_purchased_at,
    months, grant_months, starts_at, expiry, grant_months > 0, refund_time);
  RETURN CASE WHEN grant_months > 0 AND refund_time IS NULL THEN expiry ELSE NULL END;
END $$;
REVOKE ALL ON FUNCTION public.record_verified_ce_bonus(text,text,text,uuid,timestamptz)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.record_verified_ce_bonus(text,text,text,uuid,timestamptz)
  TO service_role;

CREATE OR REPLACE FUNCTION public.has_clinical_premium_access()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $$
  SELECT (SELECT auth.uid()) IS NOT NULL
    AND COALESCE((SELECT auth.jwt()->>'is_anonymous'), 'true') = 'false'
    AND (
      EXISTS (SELECT 1 FROM public.luma_content_entitlements e
        WHERE e.user_id = (SELECT auth.uid()) AND e.entitlement = 'clinical_premium'
          AND e.revoked_at IS NULL AND e.valid_until > now())
      OR EXISTS (SELECT 1 FROM public.luma_ce_bonus_purchases p
        WHERE p.user_id = (SELECT auth.uid()) AND p.bonus_awarded
          AND p.revoked_at IS NULL
          AND p.bonus_starts_at <= now() AND p.valid_until > now())
    );
$$;
REVOKE ALL ON FUNCTION public.has_clinical_premium_access() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.has_clinical_premium_access() TO authenticated;

UPDATE public.ce_course1_catalog SET metadata = jsonb_set(metadata,
  '{bonus_policy}',
  to_jsonb('Maximum three complimentary calendar months per account across stores. First individual course: one month, once. Bundle: three months total, or two additional months if the course month was already awarded. Additional course purchases and restores add no months. Bundle upgrades follow any unexpired, unrevoked CE bonus; otherwise they start on the original verified bundle purchase date. Refunds do not reset eligibility. No automatic subscription enrollment; existing store subscription billing is unchanged.'::text))
WHERE id = '1047239';
NOTIFY pgrst, 'reload schema';
