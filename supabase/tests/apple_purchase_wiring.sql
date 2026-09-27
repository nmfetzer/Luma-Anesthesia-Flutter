-- Run against an isolated database or in a rollback-only verification session.
BEGIN;
INSERT INTO auth.users(id,is_anonymous) VALUES
 ('fbbbbbbb-0000-4000-8000-000000000001',false),
 ('fbbbbbbb-0000-4000-8000-000000000002',false);
SELECT set_config('request.jwt.claims',
 '{"sub":"fbbbbbbb-0000-4000-8000-000000000001","is_anonymous":false}',true);
DO $$
DECLARE s jsonb;
BEGIN
  IF has_function_privilege('authenticated',
    'public.record_revenuecat_access(uuid,boolean,timestamptz,timestamptz,text)','EXECUTE')
    OR has_table_privilege('authenticated','public.luma_revenuecat_access','INSERT')
  THEN RAISE EXCEPTION 'Client can self-grant subscription'; END IF;
  IF has_function_privilege('anon','public.luma_ce_checkout_status()','EXECUTE')
  THEN RAISE EXCEPTION 'Anonymous CE lookup allowed'; END IF;
  s := public.luma_ce_checkout_status();
  IF jsonb_array_length(s->'products') <> 4
    OR s->>'user_id' <> 'fbbbbbbb-0000-4000-8000-000000000001'
  THEN RAISE EXCEPTION 'Wrong CE status'; END IF;
  IF EXISTS (SELECT 1 FROM jsonb_array_elements(s->'products') p WHERE (p->>'enabled')::boolean)
  THEN RAISE EXCEPTION 'Sales unexpectedly enabled'; END IF;
END $$;
SELECT public.record_revenuecat_access('fbbbbbbb-0000-4000-8000-000000000001',
 true,now()+interval '1 year',now(),'Luma_Anesthesia_App_Monthly');
DO $$
BEGIN
  IF NOT public.has_clinical_premium_access()
  THEN RAISE EXCEPTION 'Verified subscription missing'; END IF;
  IF EXISTS (SELECT 1 FROM public.luma_revenuecat_access
    WHERE user_id='fbbbbbbb-0000-4000-8000-000000000001'
      AND valid_until>now()+interval '15 minutes')
  THEN RAISE EXCEPTION 'Unbounded subscription lease'; END IF;
END $$;
SELECT public.record_revenuecat_access('fbbbbbbb-0000-4000-8000-000000000001',
 false,now(),now()-interval '1 minute',null);
DO $$ BEGIN
 IF NOT public.has_clinical_premium_access()
 THEN RAISE EXCEPTION 'Stale response overwrote newer grant'; END IF;
END $$;
SELECT set_config('request.jwt.claims',
 '{"sub":"fbbbbbbb-0000-4000-8000-000000000002","is_anonymous":false}',true);
DO $$ BEGIN
 IF public.has_clinical_premium_access()
 THEN RAISE EXCEPTION 'Another account gained access'; END IF;
END $$;
SELECT public.record_revenuecat_access('fbbbbbbb-0000-4000-8000-000000000001',
 false,now(),now()+interval '1 second',null);
SELECT set_config('request.jwt.claims',
 '{"sub":"fbbbbbbb-0000-4000-8000-000000000001","is_anonymous":false}',true);
DO $$ BEGIN
 IF public.has_clinical_premium_access()
 THEN RAISE EXCEPTION 'Revoked subscription retained access'; END IF;
END $$;
ROLLBACK;
