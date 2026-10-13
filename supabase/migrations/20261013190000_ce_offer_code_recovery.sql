-- Recover Apple CE purchases the webhook cannot attribute to one account
-- (offer-code redemptions outside the app, guest-session aliases, restore
-- transfers). Called only by the revenuecat-sync Edge Function with the
-- signed-in account and RevenueCat's server REST response.

CREATE OR REPLACE FUNCTION public.reconcile_revenuecat_ce_purchase(
  p_transaction_id text, p_product_id text, p_user_id uuid, p_purchased_at timestamptz
) RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  IF p_transaction_id IS NULL OR length(btrim(p_transaction_id)) NOT BETWEEN 1 AND 256
    OR p_purchased_at IS NULL OR p_purchased_at > now()+interval '5 minutes'
    OR p_product_id IS NULL OR p_product_id NOT IN (
      'Medication_Review_for_the_Experienced_CRNA','uncommon_anesthesia_events',
      'legal_essentials_CRNA','3_course_bundle_pack')
    OR NOT EXISTS (SELECT 1 FROM auth.users WHERE id=p_user_id AND is_anonymous=false)
  THEN RETURN false; END IF;
  PERFORM pg_advisory_xact_lock(hashtextextended('APP_STORE:'||p_transaction_id,0));
  -- Already recorded (for this or any account): never move or duplicate it.
  IF EXISTS (SELECT 1 FROM public.luma_ce_bonus_purchases
    WHERE store='APP_STORE' AND transaction_id=p_transaction_id) THEN RETURN false; END IF;
  -- A webhook ledger entry for a different product means manual review.
  IF EXISTS (SELECT 1 FROM public.luma_ce_webhook_events
    WHERE transaction_id=p_transaction_id AND product_id<>p_product_id) THEN RETURN false; END IF;
  -- Existing accounting: guest rejection, lifetime bonus cap, refund tombstones.
  PERFORM public.record_verified_ce_bonus('APP_STORE',p_transaction_id,
    p_product_id,p_user_id,date_trunc('second',p_purchased_at));
  RETURN true;
END $$;
REVOKE ALL ON FUNCTION public.reconcile_revenuecat_ce_purchase(text,text,uuid,timestamptz)
  FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.reconcile_revenuecat_ce_purchase(text,text,uuid,timestamptz)
  TO service_role;

CREATE OR REPLACE FUNCTION public.process_revenuecat_ce_event(
  p_event_id text, p_kind text, p_app_id text, p_transaction_id text,
  p_product_id text, p_user_id uuid, p_purchased_at timestamptz,
  p_occurred_at timestamptz
) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE prior public.luma_ce_webhook_events%ROWTYPE; stored timestamptz;
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
  -- A purchase recovered from RevenueCat REST is stored at whole-second
  -- precision. Normalize the webhook's millisecond time to that stored value so
  -- later refunds and replays still match the same transaction.
  SELECT purchased_at INTO stored FROM public.luma_ce_bonus_purchases
    WHERE store='APP_STORE' AND transaction_id=p_transaction_id
      AND product_id=p_product_id
      AND purchased_at=date_trunc('second',p_purchased_at);
  IF FOUND THEN p_purchased_at := stored; END IF;
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
NOTIFY pgrst,'reload schema';
