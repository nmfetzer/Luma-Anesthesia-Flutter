-- Non-persistent integration test. All fixture rows and users are rolled back.
BEGIN;
SELECT set_config('luma.test_user', gen_random_uuid()::text, true);
INSERT INTO auth.users(id, raw_user_meta_data, is_anonymous)
VALUES (current_setting('luma.test_user')::uuid, '{}'::jsonb, false);
INSERT INTO public.special_consideration_catalog
 (slug,title,category,review_status,is_guest_preview,reviewed_at,reviewed_by)
VALUES
 ('luma-test-preview','Test preview','Luma test','published',true,now(),'test fixture'),
 ('luma-test-account','Test account','Luma test','published',false,now(),'test fixture'),
 ('luma-test-draft','Test draft','Luma test','needs_review',false,NULL,NULL);
INSERT INTO public.special_considerations(slug,subtitle,content,citations,crisis_hub_links)
SELECT slug,'Fixture, not clinical content','{"snapshot":"fixture"}','[]','[]'
FROM public.special_consideration_catalog WHERE category='Luma test';
INSERT INTO public.special_consideration_deep_dives(slug,body,review_status,reviewed_at,reviewed_by)
VALUES ('luma-test-account','PREMIUM FIXTURE','published',now(),'test fixture');
INSERT INTO public.luma_content_entitlements(user_id,entitlement,valid_until)
VALUES (current_setting('luma.test_user')::uuid,'clinical_premium',now()+interval '1 hour');

SET LOCAL ROLE anon;
SELECT set_config('request.jwt.claims','{}',true);
DO $$ BEGIN
 ASSERT (SELECT count(*) FROM public.special_consideration_catalog WHERE category='Luma test')=3, 'Guest catalog';
 ASSERT (SELECT count(*) FROM public.special_considerations WHERE slug LIKE 'luma-test-%')=1, 'Guest preview only';
 ASSERT (SELECT count(*) FROM public.special_consideration_deep_dives)=0, 'Guest no premium';
 ASSERT NOT has_table_privilege(current_user,'public.special_consideration_imports','SELECT'), 'Archive private';
 ASSERT NOT has_table_privilege(current_user,'public.special_consideration_catalog','UPDATE'), 'No publishing';
END $$;
RESET ROLE;

SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claims',
 jsonb_build_object('sub',current_setting('luma.test_user'),'is_anonymous',true)::text,true);
DO $$ BEGIN
 ASSERT (SELECT count(*) FROM public.special_considerations WHERE slug LIKE 'luma-test-%')=1, 'Anonymous signed-in user limited to preview';
 ASSERT (SELECT count(*) FROM public.special_consideration_deep_dives)=0, 'Anonymous cannot use premium entitlement';
 ASSERT NOT has_table_privilege(current_user,'public.luma_content_entitlements','INSERT'), 'Cannot self-grant subscription';
 ASSERT NOT has_table_privilege(current_user,'public.luma_content_entitlements','UPDATE'), 'Cannot change expiry';
END $$;
SELECT set_config('request.jwt.claims',
 jsonb_build_object('sub',current_setting('luma.test_user'),'is_anonymous',false)::text,true);
DO $$ BEGIN
 ASSERT (SELECT count(*) FROM public.special_considerations WHERE slug LIKE 'luma-test-%')=2, 'Account basic';
 ASSERT (SELECT count(*) FROM public.special_consideration_deep_dives WHERE slug='luma-test-account')=1, 'Premium allowed';
 ASSERT (SELECT count(*) FROM public.special_considerations WHERE slug='luma-test-draft')=0, 'Draft hidden from member';
END $$;
RESET ROLE;
UPDATE public.luma_content_entitlements SET valid_until=now()-interval '1 second'
WHERE user_id=current_setting('luma.test_user')::uuid;
SET LOCAL ROLE authenticated;
DO $$ BEGIN
 ASSERT (SELECT count(*) FROM public.special_consideration_deep_dives WHERE slug='luma-test-account')=0, 'Expired premium denied';
 ASSERT (SELECT count(*) FROM public.special_considerations WHERE slug LIKE 'luma-test-%')=2, 'Free account keeps basic';
END $$;
RESET ROLE;
UPDATE public.luma_content_entitlements SET valid_until=now()+interval '1 hour',revoked_at=now()
WHERE user_id=current_setting('luma.test_user')::uuid;
SET LOCAL ROLE authenticated;
DO $$ BEGIN
 ASSERT (SELECT count(*) FROM public.special_consideration_deep_dives WHERE slug='luma-test-account')=0, 'Revoked premium denied';
END $$;
RESET ROLE;
ROLLBACK;
SELECT 'PASS: guest, anonymous, free, premium, expired, revoked, draft and write protection; fixtures rolled back' AS result;
