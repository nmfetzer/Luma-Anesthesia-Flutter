-- Enables sandbox eligibility, NOT purchases/entitlements, for fresh verified
-- accounts without knowing an Apple reviewer's or TestFlight user's email.
-- Existing review-build flags and verified receipt environment routing remain
-- mandatory. No client assertion is accepted as proof of a purchase.
BEGIN;

ALTER TABLE public.luma_billing_controls
  ADD COLUMN sandbox_self_enrollment_enabled boolean NOT NULL DEFAULT false;

CREATE FUNCTION luma_review.try_open_enrollment(uid uuid)
RETURNS boolean LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path='' AS $$
DECLARE existing luma_review.accounts%rowtype;
BEGIN
  IF uid IS NULL OR uid IS DISTINCT FROM auth.uid() THEN RETURN false; END IF;
  -- Serialize enrollment for the same signed-in account. No other user ID can
  -- be enrolled through a public policy/checkout call.
  PERFORM pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(uid::text,72901));
  SELECT * INTO existing FROM luma_review.accounts WHERE user_id=uid;
  IF FOUND THEN
    -- Never undo revocation, extend expiry, or reset purchase/bonus history.
    RETURN luma_review.is_tester(uid);
  END IF;
  IF NOT coalesce((SELECT sandbox_self_enrollment_enabled
    FROM public.luma_billing_controls WHERE singleton),false)
  THEN RETURN false; END IF;
  IF NOT EXISTS(SELECT 1 FROM auth.users WHERE id=uid AND is_anonymous=false
    AND email_confirmed_at IS NOT NULL
    AND (banned_until IS NULL OR banned_until<=now()))
  THEN RETURN false; END IF;
  BEGIN
    -- Reuse all existing owner/provider/production-account exclusion checks.
    -- This creates eligibility only, never course or subscription ownership.
    PERFORM public.enroll_luma_apple_reviewer(uid,now()+interval '60 days');
  EXCEPTION WHEN raise_exception THEN
    IF SQLERRM IN ('Use a dedicated test account without production access',
                  'Use an empty dedicated test account')
    THEN RETURN false;
    ELSE RAISE;
    END IF;
  END;
  RETURN luma_review.is_tester(uid);
END $$;
REVOKE ALL ON FUNCTION luma_review.try_open_enrollment(uuid)
  FROM PUBLIC,anon,authenticated,service_role;

CREATE OR REPLACE FUNCTION public.luma_billing_policy()
RETURNS jsonb LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path='' AS $$
DECLARE uid uuid:=auth.uid(); tester boolean;
BEGIN
  IF uid IS NULL OR NOT EXISTS(SELECT 1 FROM auth.users WHERE id=uid AND is_anonymous=false)
  THEN RAISE EXCEPTION 'Permanent sign-in required'; END IF;
  tester := luma_review.try_open_enrollment(uid);
  RETURN jsonb_build_object('user_id',uid,'apple_review',tester,
    'customer_subscriptions_enabled',(SELECT customer_subscriptions_enabled
      FROM public.luma_billing_controls WHERE singleton));
END $$;
REVOKE ALL ON FUNCTION public.luma_billing_policy() FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.luma_billing_policy() TO authenticated;

-- CE-first testers must also be eligible without visiting the subscription
-- paywall. Guard the exact existing implementation against unrelated drift.
DO $$
DECLARE definition text; anchor text :=
  'IF NOT luma_review.is_tester(uid) THEN RETURN luma_review.luma_ce_checkout_status(); END IF;';
BEGIN
  definition:=pg_get_functiondef('public.luma_ce_checkout_status()'::regprocedure);
  IF (length(definition)-length(replace(definition,anchor,'')))/length(anchor)<>1
  THEN RAISE EXCEPTION 'CE checkout changed; review migration before applying'; END IF;
  EXECUTE replace(definition,anchor,
    'PERFORM luma_review.try_open_enrollment(uid);'||chr(10)||anchor);
END $$;
ALTER FUNCTION public.luma_ce_checkout_status() VOLATILE;

-- This is the only switch enabled by this migration. Customer subscription
-- checkout and production CE product flags are not modified.
UPDATE public.luma_billing_controls SET sandbox_self_enrollment_enabled=true
  WHERE singleton;
NOTIFY pgrst,'reload schema';
COMMIT;
