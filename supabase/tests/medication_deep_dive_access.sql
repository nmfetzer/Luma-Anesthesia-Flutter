BEGIN;
SELECT set_config('luma.test_user', gen_random_uuid()::text, true);
SELECT set_config('luma.test_drug', (SELECT id FROM public.medication
 WHERE nullif(trim(deep_dive_content),'') IS NOT NULL LIMIT 1), true);
INSERT INTO auth.users(id, raw_user_meta_data, is_anonymous)
VALUES (current_setting('luma.test_user')::uuid, '{}'::jsonb, false);
SET LOCAL ROLE anon;
SELECT set_config('request.jwt.claims','{}',true);
DO $$ BEGIN
 ASSERT has_column_privilege(current_user,'public.medication','adult_dose','SELECT'), 'Dosing free';
 ASSERT has_column_privilege(current_user,'public.medication','sources','SELECT'), 'Sources free';
 ASSERT NOT has_column_privilege(current_user,'public.medication','deep_dive_content','SELECT'), 'Deep Dive not public';
 ASSERT NOT has_function_privilege(current_user,'public.medication_deep_dive(text)','EXECUTE'), 'Guest cannot call protected function';
 ASSERT (SELECT count(id) FROM public.medication)>0, 'Free drug catalog readable';
END $$;
RESET ROLE;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claims',
 jsonb_build_object('sub',current_setting('luma.test_user'),'is_anonymous',false)::text,true);
DO $$ BEGIN
 ASSERT NOT has_column_privilege(current_user,'public.medication','deep_dive_content','SELECT'), 'No direct premium-column access';
 ASSERT (public.medication_deep_dive(current_setting('luma.test_drug'))->>'allowed')::boolean=false, 'Free account denied';
END $$;
RESET ROLE;
INSERT INTO public.luma_content_entitlements(user_id,entitlement,valid_until)
VALUES (current_setting('luma.test_user')::uuid,'clinical_premium',now()+interval '1 hour');
SET LOCAL ROLE authenticated;
DO $$ BEGIN
 ASSERT (public.medication_deep_dive(current_setting('luma.test_drug'))->>'allowed')::boolean=true, 'Premium allowed';
 ASSERT length(public.medication_deep_dive(current_setting('luma.test_drug'))->>'body')>0, 'Premium receives content';
END $$;
SELECT set_config('request.jwt.claims',
 jsonb_build_object('sub',current_setting('luma.test_user'),'is_anonymous',true)::text,true);
DO $$ BEGIN
 ASSERT (public.medication_deep_dive(current_setting('luma.test_drug'))->>'allowed')::boolean=false, 'Anonymous denied even with grant';
END $$;
RESET ROLE;
SELECT set_config('request.jwt.claims',
 jsonb_build_object('sub',current_setting('luma.test_user'),'is_anonymous',false)::text,true);
UPDATE public.luma_content_entitlements SET valid_until=now()-interval '1 second'
 WHERE user_id=current_setting('luma.test_user')::uuid;
SET LOCAL ROLE authenticated;
DO $$ BEGIN
 ASSERT (public.medication_deep_dive(current_setting('luma.test_drug'))->>'allowed')::boolean=false, 'Expired denied';
END $$;
RESET ROLE;
UPDATE public.luma_content_entitlements SET valid_until=now()+interval '1 hour',revoked_at=now()
 WHERE user_id=current_setting('luma.test_user')::uuid;
SET LOCAL ROLE authenticated;
DO $$ BEGIN
 ASSERT (public.medication_deep_dive(current_setting('luma.test_drug'))->>'allowed')::boolean=false, 'Revoked denied';
END $$;
RESET ROLE;
ROLLBACK;
SELECT 'PASS: free drug fields readable; Deep Dives protected for guests, free, anonymous, expired and revoked users; premium allowed; fixtures rolled back' AS result;
