-- App Review Guideline 5.1.1(v): subscriptions are not account-based, so a
-- person may buy, restore and use a subscription without registering.
-- The app creates an anonymous ("guest") Supabase session only when someone
-- taps Subscribe or Restore. Store receipts, verified server-side through
-- revenuecat-sync, remain the only source of subscription access.
--
-- Unchanged and still permanent-account only: CE courses, CE checkout,
-- certificates, CE bonus records, account deletion and reviewer drafts.
--
-- Guests may receive sandbox tester status (owner-approved 2026-10-10) so
-- App Review's sandbox purchase without an account unlocks content. Sandbox
-- receipts are only possible for App Review and TestFlight testers.
-- Each definition below is the live production definition with only the
-- guest-account condition changed.

CREATE OR REPLACE FUNCTION public.has_clinical_premium_access()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  -- Guests qualify only through a verified store subscription or sandbox
  -- review lease; they can never hold CE bonus or content entitlements.
  SELECT auth.uid() IS NOT NULL
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
$function$;

CREATE OR REPLACE FUNCTION public.luma_billing_policy()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE uid uuid:=auth.uid(); tester boolean;
BEGIN
  IF uid IS NULL OR NOT EXISTS(SELECT 1 FROM auth.users WHERE id=uid)
  THEN RAISE EXCEPTION 'Sign-in session required'; END IF;
  tester := luma_review.try_open_enrollment(uid);
  RETURN jsonb_build_object('user_id',uid,'apple_review',tester,
    'customer_subscriptions_enabled',(SELECT customer_subscriptions_enabled
      FROM public.luma_billing_controls WHERE singleton));
END $function$;

CREATE OR REPLACE FUNCTION luma_review.is_tester(uid uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare n integer; occupied boolean;
begin
  -- Permanent testers still need a confirmed email; guests have no email.
  if not exists (
    select 1 from luma_review.accounts a join auth.users u on u.id=a.user_id
    where a.user_id=uid and a.revoked_at is null and a.expires_at>now()
      and (u.is_anonymous or u.email_confirmed_at is not null)
      and (u.banned_until is null or u.banned_until<=now())
  ) then return false; end if;
  if exists(select 1 from public.luma_ce_bonus_purchases where user_id=uid)
    or exists(select 1 from public.luma_content_entitlements where user_id=uid)
    or exists(select 1 from public.luma_revenuecat_access
      where user_id=uid and active and valid_until>now())
  then return false; end if;
  for n in 1..3 loop
    execute format(
      'select exists(select 1 from public.ce_course%s_reviewers where user_id=$1)
       or exists(select 1 from public.ce_course%s_certificates where user_id=$1)
       or exists(select 1 from public.ce_course%s_state
         where user_id=$1 and not is_preview)',n,n,n)
      into occupied using uid;
    if occupied then return false; end if;
  end loop;
  return true;
end $function$;

CREATE OR REPLACE FUNCTION public.enroll_luma_apple_reviewer(p_user_id uuid, p_expires_at timestamp with time zone)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE n integer; occupied boolean;
BEGIN
  IF p_expires_at IS NULL OR p_expires_at<=now()
    OR p_expires_at>now()+interval '60 days'
    OR NOT EXISTS(SELECT 1 FROM auth.users WHERE id=p_user_id)
  THEN RAISE EXCEPTION 'Test account and expiry within 60 days required'; END IF;
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
END $function$;

CREATE OR REPLACE FUNCTION luma_review.try_open_enrollment(uid uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
  -- Guests qualify without an email; permanent accounts still need one.
  IF NOT EXISTS(SELECT 1 FROM auth.users WHERE id=uid
    AND (is_anonymous OR email_confirmed_at IS NOT NULL)
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
END $function$;
