-- Apple CE products confirmed in the owner's App Store / RevenueCat screenshots.
-- Keep purchase granting disabled until webhook/native acceptance testing.
INSERT INTO public.luma_ce_bonus_products(store,product_id,bonus_months,enabled)
VALUES
  ('APP_STORE','Medication_Review_for_the_Experienced_CRNA',1,false),
  ('APP_STORE','uncommon_anesthesia_events',1,false),
  ('APP_STORE','legal_essentials_CRNA',1,false),
  ('APP_STORE','3_course_bundle_pack',3,false)
ON CONFLICT(store,product_id) DO NOTHING;
INSERT INTO public.ce_course1_store_products(store,product_id)
VALUES ('APP_STORE','3_course_bundle_pack') ON CONFLICT DO NOTHING;

-- Minimal audit ledger, never raw webhook data or payment details.
CREATE TABLE public.luma_ce_webhook_events (
  event_id text PRIMARY KEY,
  kind text NOT NULL CHECK(kind IN ('NON_RENEWING_PURCHASE','CANCELLATION')),
  app_id text NOT NULL,
  transaction_id text NOT NULL,
  product_id text NOT NULL,
  user_id uuid,
  purchased_at timestamptz NOT NULL,
  occurred_at timestamptz NOT NULL,
  processed_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.luma_ce_webhook_events ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.luma_ce_webhook_events FROM PUBLIC,anon,authenticated;
GRANT SELECT ON public.luma_ce_webhook_events TO service_role;

-- Service-only adapter. The Edge Function authenticates RevenueCat and validates
-- production environment, exact app, store, product and permanent account first.
CREATE FUNCTION public.process_revenuecat_ce_event(
  p_event_id text, p_kind text, p_app_id text, p_transaction_id text,
  p_product_id text, p_user_id uuid, p_purchased_at timestamptz,
  p_occurred_at timestamptz
) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE prior public.luma_ce_webhook_events%ROWTYPE;
BEGIN
  IF p_event_id IS NULL OR length(btrim(p_event_id)) NOT BETWEEN 1 AND 256
    OR p_app_id IS NULL OR length(btrim(p_app_id)) NOT BETWEEN 1 AND 256
    OR p_transaction_id IS NULL OR length(btrim(p_transaction_id)) NOT BETWEEN 1 AND 256
    OR p_kind IS NULL OR p_kind NOT IN ('NON_RENEWING_PURCHASE','CANCELLATION')
    OR p_purchased_at IS NULL OR p_occurred_at IS NULL
    OR p_purchased_at > now()+interval '5 minutes'
    OR p_occurred_at > now()+interval '5 minutes'
    OR p_product_id IS NULL OR p_product_id NOT IN (
      'Medication_Review_for_the_Experienced_CRNA','uncommon_anesthesia_events',
      'legal_essentials_CRNA','3_course_bundle_pack')
  THEN RAISE EXCEPTION 'Invalid CE event'; END IF;
  PERFORM pg_advisory_xact_lock(hashtextextended('rc-ce-event:'||p_event_id,0));
  SELECT * INTO prior FROM public.luma_ce_webhook_events WHERE event_id=p_event_id;
  IF FOUND THEN
    IF (prior.kind,prior.app_id,prior.transaction_id,prior.product_id,prior.user_id,
        prior.purchased_at,prior.occurred_at)
      IS DISTINCT FROM
       (p_kind,p_app_id,p_transaction_id,p_product_id,p_user_id,p_purchased_at,p_occurred_at)
    THEN RAISE EXCEPTION 'CE event identity mismatch'; END IF;
    RETURN;
  END IF;
  -- Same lock as purchase/refund code, so a refund cannot race product validation.
  PERFORM pg_advisory_xact_lock(hashtextextended('APP_STORE:'||p_transaction_id,0));
  IF EXISTS (SELECT 1 FROM public.luma_ce_bonus_purchases
    WHERE store='APP_STORE' AND transaction_id=p_transaction_id
      AND (product_id<>p_product_id OR purchased_at<>p_purchased_at))
  THEN RAISE EXCEPTION 'CE transaction identity mismatch'; END IF;
  -- Refund-first records in the ledger must match any later purchase event.
  IF EXISTS (SELECT 1 FROM public.luma_ce_webhook_events
    WHERE transaction_id=p_transaction_id
      AND (app_id<>p_app_id OR product_id<>p_product_id OR purchased_at<>p_purchased_at))
  THEN RAISE EXCEPTION 'CE transaction identity mismatch'; END IF;
  IF p_kind='NON_RENEWING_PURCHASE' THEN
    PERFORM public.record_verified_ce_bonus('APP_STORE',p_transaction_id,
      p_product_id,p_user_id,p_purchased_at);
  ELSE
    -- Refunds remain processable even if a product has since been disabled.
    PERFORM public.revoke_verified_ce_bonus('APP_STORE',p_transaction_id,p_occurred_at);
  END IF;
  INSERT INTO public.luma_ce_webhook_events(event_id,kind,app_id,transaction_id,
    product_id,user_id,purchased_at,occurred_at)
  VALUES(p_event_id,p_kind,p_app_id,p_transaction_id,p_product_id,
    p_user_id,p_purchased_at,p_occurred_at);
END $$;
REVOKE ALL ON FUNCTION public.process_revenuecat_ce_event(text,text,text,text,text,uuid,timestamptz,timestamptz)
  FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.process_revenuecat_ce_event(text,text,text,text,text,uuid,timestamptz,timestamptz)
  TO service_role;
CREATE INDEX luma_ce_webhook_transaction ON public.luma_ce_webhook_events(transaction_id);
NOTIFY pgrst,'reload schema';
