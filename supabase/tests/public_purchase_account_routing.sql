-- Disposable local database only. No fixtures persist.
begin;
create function pg_temp.assert_true(ok boolean,message text)
returns void language plpgsql as $$
begin if ok is distinct from true then raise exception '%',message; end if; end $$;
insert into auth.users(id,is_anonymous,email_confirmed_at)
values ('cccccccc-0000-4000-8000-000000000001',false,now()),
       ('cccccccc-0000-4000-8000-000000000002',false,now());
select set_config('request.jwt.claims',
 '{"sub":"cccccccc-0000-4000-8000-000000000001","is_anonymous":false}',true);
select pg_temp.assert_true(
 (public.luma_billing_policy()->>'apple_review')::boolean,'fresh reviewer eligible');
select set_config('request.jwt.claims',
 '{"sub":"cccccccc-0000-4000-8000-000000000002","is_anonymous":false}',true);
select pg_temp.assert_true(
 (public.luma_billing_policy()->>'apple_review')::boolean,'future customer initially eligible');
-- Simulates only trusted production receipt processing in this disposable DB.
update public.luma_ce_bonus_products set enabled=true;
select public.record_verified_ce_bonus('APP_STORE','launch-real-ce',
 'Medication_Review_for_the_Experienced_CRNA',
 'cccccccc-0000-4000-8000-000000000002',now());
select pg_temp.assert_true(
 not (public.luma_billing_policy()->>'apple_review')::boolean,
 'verified real buyer leaves sandbox routing');
select pg_temp.assert_true(
 coalesce((public.luma_ce_checkout_status()->>'apple_review')::boolean,false)=false,
 'real buyer receives production checkout status');
select pg_temp.assert_true(
 (select (p->>'owned')::boolean
 from jsonb_array_elements(public.luma_ce_checkout_status()->'products') p
 where p->>'product_id'='Medication_Review_for_the_Experienced_CRNA'),
 'production ownership visible');
select set_config('request.jwt.claims',
 '{"sub":"cccccccc-0000-4000-8000-000000000001","is_anonymous":false}',true);
select pg_temp.assert_true(
 (public.luma_billing_policy()->>'apple_review')::boolean,'other reviewer unaffected');
select public.process_revenuecat_ce_sandbox_event(
 'launch-sandbox-ce','NON_RENEWING_PURCHASE','appbafd32b582','launch-sandbox-tx',
 '3_course_bundle_pack','cccccccc-0000-4000-8000-000000000001',now(),now());
select pg_temp.assert_true(
 (public.ce_course1('access','{}')->>'is_preview')::boolean,
 'sandbox course remains preview, never reportable credit');
select pg_temp.assert_true(
 not exists(select 1 from public.luma_ce_bonus_purchases
 where user_id='cccccccc-0000-4000-8000-000000000001'),
 'sandbox never writes real purchase');
select public.record_revenuecat_access(
 'cccccccc-0000-4000-8000-000000000001',true,now()+interval '10 minutes',
 now(),'Luma_Anesthesia_App_Monthly');
select pg_temp.assert_true(
 not (public.luma_billing_policy()->>'apple_review')::boolean,
 'verified production subscription leaves sandbox routing');
rollback;
