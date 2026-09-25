-- CE bonuses are independent grants. Never overwrite a paid subscription.
-- No product rules are seeded: verified store IDs must be configured first.
CREATE TABLE public.luma_ce_bonus_products (
  store text NOT NULL CHECK (store IN ('APP_STORE', 'PLAY_STORE')),
  product_id text NOT NULL,
  bonus_months integer NOT NULL CHECK (bonus_months IN (1, 3)),
  enabled boolean NOT NULL DEFAULT false,
  PRIMARY KEY (store, product_id)
);
CREATE TABLE public.luma_ce_bonus_purchases (
  store text NOT NULL,
  transaction_id text NOT NULL,
  product_id text NOT NULL,
  user_id uuid NOT NULL REFERENCES auth.users(id),
  purchased_at timestamptz NOT NULL,
  bonus_months integer NOT NULL CHECK (bonus_months IN (1, 3)),
  valid_until timestamptz NOT NULL,
  bonus_awarded boolean NOT NULL,
  revoked_at timestamptz,
  verified_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (store, transaction_id),
  FOREIGN KEY (store, product_id)
    REFERENCES public.luma_ce_bonus_products(store, product_id)
);
CREATE INDEX luma_ce_bonus_user ON public.luma_ce_bonus_purchases(user_id);
-- Lifetime limit: one course bonus and one bundle bonus per account.
-- Revoking/refunding a grant does not reset eligibility.
CREATE UNIQUE INDEX luma_ce_bonus_once
  ON public.luma_ce_bonus_purchases(user_id, bonus_months) WHERE bonus_awarded;
-- Retain refund tombstones even if the refund arrives before the purchase.
CREATE TABLE public.luma_ce_bonus_refunds (
  store text NOT NULL CHECK (store IN ('APP_STORE', 'PLAY_STORE')),
  transaction_id text NOT NULL,
  refunded_at timestamptz NOT NULL,
  PRIMARY KEY (store, transaction_id)
);
ALTER TABLE public.luma_ce_bonus_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.luma_ce_bonus_purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.luma_ce_bonus_refunds ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.luma_ce_bonus_products,
  public.luma_ce_bonus_purchases, public.luma_ce_bonus_refunds
  FROM PUBLIC, anon, authenticated;
GRANT ALL ON public.luma_ce_bonus_products,
  public.luma_ce_bonus_purchases, public.luma_ce_bonus_refunds TO service_role;
GRANT SELECT ON public.luma_ce_bonus_purchases TO authenticated;
CREATE POLICY ce_bonus_own ON public.luma_ce_bonus_purchases
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

-- Only a trusted server AFTER receipt verification may call this function.
-- Calendar months are calculated in UTC, clamping at the end of the month.
-- Replays/restores retain the original purchase date; bonuses overlap, not stack.
-- Repeat course/bundle purchases do not restart or extend an awarded bonus.
CREATE FUNCTION public.record_verified_ce_bonus(
  p_store text, p_transaction_id text, p_product_id text,
  p_user_id uuid, p_purchased_at timestamptz
) RETURNS timestamptz
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE months integer; prior public.luma_ce_bonus_purchases%ROWTYPE;
  expiry timestamptz; refund_time timestamptz; award boolean;
BEGIN
  IF p_transaction_id IS NULL OR length(trim(p_transaction_id)) = 0
    OR p_purchased_at IS NULL OR p_purchased_at > now() + interval '5 minutes'
    OR NOT EXISTS (SELECT 1 FROM auth.users
      WHERE id = p_user_id AND is_anonymous = false) THEN
    RAISE EXCEPTION 'Invalid verified purchase';
  END IF;
  -- Same lock in purchase/refund paths protects out-of-order concurrent events.
  PERFORM pg_advisory_xact_lock(hashtextextended(p_store || ':' || p_transaction_id, 0));
  SELECT * INTO prior FROM public.luma_ce_bonus_purchases
    WHERE store = p_store AND transaction_id = p_transaction_id;
  IF FOUND THEN
    IF prior.user_id <> p_user_id OR prior.product_id <> p_product_id
      OR prior.purchased_at <> p_purchased_at THEN
      RAISE EXCEPTION 'Purchase identity mismatch';
    END IF;
    RETURN CASE WHEN prior.bonus_awarded THEN prior.valid_until ELSE NULL END;
  END IF;
  SELECT bonus_months INTO months FROM public.luma_ce_bonus_products
    WHERE store = p_store AND product_id = p_product_id AND enabled;
  IF months IS NULL THEN RAISE EXCEPTION 'CE product is not configured'; END IF;
  -- Serialize distinct purchases for one user as well as transaction replays.
  PERFORM pg_advisory_xact_lock(hashtextextended('ce-bonus-user:' || p_user_id::text, 0));
  award := NOT EXISTS (SELECT 1 FROM public.luma_ce_bonus_purchases
    WHERE user_id = p_user_id AND bonus_months = months AND bonus_awarded);
  expiry := ((p_purchased_at AT TIME ZONE 'UTC') +
    make_interval(months => months)) AT TIME ZONE 'UTC';
  SELECT refunded_at INTO refund_time FROM public.luma_ce_bonus_refunds
    WHERE store = p_store AND transaction_id = p_transaction_id;
  INSERT INTO public.luma_ce_bonus_purchases
    (store, transaction_id, product_id, user_id, purchased_at,
      bonus_months, valid_until, bonus_awarded, revoked_at)
  VALUES (p_store, p_transaction_id, p_product_id, p_user_id,
    p_purchased_at, months, expiry, award, refund_time);
  RETURN CASE WHEN award THEN expiry ELSE NULL END;
END $$;
CREATE FUNCTION public.revoke_verified_ce_bonus(
  p_store text, p_transaction_id text, p_refunded_at timestamptz
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  IF p_transaction_id IS NULL OR length(trim(p_transaction_id)) = 0
    OR p_refunded_at IS NULL THEN RAISE EXCEPTION 'Invalid refund'; END IF;
  PERFORM pg_advisory_xact_lock(hashtextextended(p_store || ':' || p_transaction_id, 0));
  INSERT INTO public.luma_ce_bonus_refunds(store, transaction_id, refunded_at)
    VALUES (p_store, p_transaction_id, p_refunded_at)
    ON CONFLICT (store, transaction_id) DO NOTHING;
  UPDATE public.luma_ce_bonus_purchases SET revoked_at =
    COALESCE(revoked_at, p_refunded_at)
    WHERE store = p_store AND transaction_id = p_transaction_id;
END $$;
REVOKE ALL ON FUNCTION public.record_verified_ce_bonus(text,text,text,uuid,timestamptz),
  public.revoke_verified_ce_bonus(text,text,timestamptz) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.record_verified_ce_bonus(text,text,text,uuid,timestamptz),
  public.revoke_verified_ce_bonus(text,text,timestamptz) TO service_role;

CREATE FUNCTION public.has_clinical_premium_access()
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
          AND p.purchased_at <= now() AND p.valid_until > now())
    );
$$;
REVOKE ALL ON FUNCTION public.has_clinical_premium_access() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.has_clinical_premium_access() TO authenticated;

ALTER POLICY sc_account_basic ON public.special_considerations USING (
  (SELECT public.has_clinical_premium_access())
  AND EXISTS (SELECT 1 FROM public.special_consideration_catalog c
    WHERE c.slug = special_considerations.slug AND c.review_status = 'published')
);
ALTER POLICY sc_premium_deep_dive ON public.special_consideration_deep_dives USING (
  review_status = 'published' AND (SELECT public.has_clinical_premium_access())
  AND EXISTS (SELECT 1 FROM public.special_consideration_catalog c
    WHERE c.slug = special_consideration_deep_dives.slug AND c.review_status = 'published')
);
CREATE OR REPLACE FUNCTION public.medication_deep_dive(p_medication_id text)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = ''
AS $$
DECLARE content text;
BEGIN
  IF NOT public.has_clinical_premium_access() THEN
    RETURN jsonb_build_object('allowed', false);
  END IF;
  SELECT m.deep_dive_content INTO content FROM public.medication m
    WHERE m.id = p_medication_id;
  RETURN jsonb_build_object('allowed', true, 'body', content);
END $$;
NOTIFY pgrst, 'reload schema';
