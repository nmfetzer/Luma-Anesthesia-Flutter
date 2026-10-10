-- LOCAL ONLY (scripts/test_guest_subscriptions_db.mjs). Minimal stand-ins for
-- the production tables these functions read; never run against Supabase.
CREATE SCHEMA auth; CREATE SCHEMA luma_review;
CREATE TABLE auth.users(id uuid PRIMARY KEY, is_anonymous boolean NOT NULL DEFAULT false,
  email_confirmed_at timestamptz, banned_until timestamptz);
CREATE FUNCTION auth.jwt() RETURNS jsonb LANGUAGE sql STABLE AS
  $$ SELECT nullif(current_setting('request.jwt.claims',true),'')::jsonb $$;
CREATE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS $$ SELECT (auth.jwt()->>'sub')::uuid $$;
GRANT USAGE ON SCHEMA auth TO authenticated;
CREATE TABLE public.luma_content_entitlements(user_id uuid, entitlement text, valid_until timestamptz, revoked_at timestamptz);
CREATE TABLE public.luma_ce_bonus_purchases(user_id uuid, bonus_awarded boolean, revoked_at timestamptz,
  bonus_starts_at timestamptz, valid_until timestamptz, store text, product_id text);
CREATE TABLE luma_review.luma_ce_bonus_purchases(LIKE public.luma_ce_bonus_purchases);
CREATE TABLE public.luma_revenuecat_access(user_id uuid PRIMARY KEY, active boolean, valid_until timestamptz,
  checked_at timestamptz, product_id text);
CREATE TABLE luma_review.luma_revenuecat_access(LIKE public.luma_revenuecat_access INCLUDING ALL);
CREATE TABLE luma_review.accounts(user_id uuid PRIMARY KEY, expires_at timestamptz, revoked_at timestamptz);
CREATE TABLE public.luma_billing_controls(singleton boolean PRIMARY KEY, customer_subscriptions_enabled boolean,
  sandbox_self_enrollment_enabled boolean);
INSERT INTO public.luma_billing_controls VALUES(true,true,true);
DO $$ BEGIN FOR n IN 1..3 LOOP
  EXECUTE format('CREATE TABLE public.ce_course%s_reviewers(user_id uuid)', n);
  EXECUTE format('CREATE TABLE public.ce_course%s_certificates(user_id uuid)', n);
  EXECUTE format('CREATE TABLE public.ce_course%s_state(user_id uuid, is_preview boolean)', n);
END LOOP; END $$;

-- Live production definitions of the sandbox recorder (unchanged).
CREATE FUNCTION luma_review.record_revenuecat_access(p_user_id uuid, p_active boolean, p_valid_until timestamptz, p_checked_at timestamptz, p_product_id text)
 RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path TO '' AS $function$
  INSERT INTO luma_review.luma_revenuecat_access(user_id, active, valid_until, checked_at, product_id)
  VALUES (p_user_id, p_active, LEAST(p_valid_until, now() + interval '15 minutes'), p_checked_at, p_product_id)
  ON CONFLICT (user_id) DO UPDATE SET active = excluded.active, valid_until = excluded.valid_until,
    checked_at = excluded.checked_at, product_id = excluded.product_id
  WHERE excluded.checked_at >= luma_revenuecat_access.checked_at;
$function$;
CREATE FUNCTION public.record_revenuecat_sandbox_access(p_user_id uuid, p_active boolean, p_valid_until timestamptz, p_checked_at timestamptz, p_product_id text)
 RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $function$
BEGIN
  IF NOT luma_review.is_tester(p_user_id) THEN RETURN; END IF;
  IF p_product_id IS NOT NULL AND p_product_id NOT IN ('Luma_Anesthesia_App_Monthly','Luma_Anesthesia_Yearly_Pro')
  THEN RAISE EXCEPTION 'Apple test products only'; END IF;
  PERFORM luma_review.record_revenuecat_access(p_user_id,p_active,p_valid_until,p_checked_at,p_product_id);
END $function$;
-- Stand-in so is_tester exists before the migration replaces it.
CREATE FUNCTION luma_review.is_tester(uid uuid) RETURNS boolean LANGUAGE sql AS $$ SELECT false $$;
CREATE FUNCTION public.enroll_luma_apple_reviewer(p_user_id uuid, p_expires_at timestamptz) RETURNS void LANGUAGE sql AS $$ SELECT $$;
CREATE FUNCTION luma_review.try_open_enrollment(uid uuid) RETURNS boolean LANGUAGE sql AS $$ SELECT false $$;
CREATE FUNCTION public.has_clinical_premium_access() RETURNS boolean LANGUAGE sql AS $$ SELECT false $$;
CREATE FUNCTION public.luma_billing_policy() RETURNS jsonb LANGUAGE sql AS $$ SELECT '{}'::jsonb $$;
