-- Owner-authorized October 2, 2026. Operational activation, NOT an automatic
-- migration. Does not publish an App Store binary, award credit, or take payment.
-- Requires the public_purchase_account_routing migration first.
begin;
do $$
declare n integer; ready boolean; expected integer; product text; module_count integer;
begin
  if position('public.luma_ce_bonus_purchases' in
    pg_get_functiondef('luma_review.is_tester(uuid)'::regprocedure))=0
  then raise exception 'Production-account routing safeguard missing'; end if;
  if current_date not between date '2026-10-01' and date '2029-09-30'
  then raise exception 'Outside approved course dates'; end if;
  for n,expected,product in select * from (values
    (1,11,'Medication_Review_for_the_Experienced_CRNA'),
    (2,10,'uncommon_anesthesia_events'),
    (3,11,'legal_essentials_CRNA')) x(n,expected,product)
  loop
    execute format(
      'select count(*)=1 and bool_and(
        jsonb_array_length(metadata->''modules'')=$1
        and (select sum((m->>''credits'')::numeric)
          from jsonb_array_elements(metadata->''modules'') m)=20
      ) from public.ce_course%s_catalog',n) into ready using expected;
    if ready is distinct from true then raise exception 'Incomplete course %',n; end if;
    execute format(
      'select count(*)=1 and bool_and(approved_at is not null
        and nullif(signature_png_base64,'''') is not null
        and nullif(signer_name,'''') is not null
        and nullif(provider_city_state,'''') is not null)
       from public.ce_course%s_certificate_settings',n) into ready;
    if ready is distinct from true then raise exception 'Certificate setup incomplete %',n; end if;
    execute format(
      'select count(*)=2 from public.ce_course%s_store_products
       where store=''APP_STORE'' and product_id in ($1,''3_course_bundle_pack'')',n)
      into ready using product;
    if ready is distinct from true then raise exception 'Product mapping incomplete %',n; end if;
    execute format(
      'select count(*),bool_and(
         p.data->>''sha256''=m->>''document_sha256''
         and encode(sha256(decode(p.data->>''base64'',''base64'')),''hex'')=p.data->>''sha256''
         and jsonb_array_length(q.data)=(m->>''bank_size'')::integer
         and jsonb_array_length(q.data)>=(m->>''question_count'')::integer
         and p.id is not null and q.id is not null)
       from public.ce_course%s_catalog c
       cross join lateral jsonb_array_elements(c.metadata->''modules'') m
       left join public.ce_course%s_resources p
         on p.id=coalesce(m->>''resource_prefix'',''ketamine'')||''_pdf''
       left join public.ce_course%s_resources q
         on q.id=coalesce(m->>''resource_prefix'',''ketamine'')||''_questions''',n,n,n)
      into module_count,ready;
    if module_count<>expected or ready is distinct from true
    then raise exception 'Missing/mismatched module resources %',n; end if;
  end loop;
  if (select count(*) from public.luma_ce_bonus_products where store='APP_STORE'
    and product_id in ('Medication_Review_for_the_Experienced_CRNA',
      'uncommon_anesthesia_events','legal_essentials_CRNA','3_course_bundle_pack'))<>4
  then raise exception 'Expected four Apple CE products'; end if;
end $$;
update public.luma_billing_controls set customer_subscriptions_enabled=true
  where singleton;
-- Retain sandbox self-enrollment for App Review/TestFlight. Actual receipts,
-- not build flags or account enrollment, control the purchase environment.
update public.luma_ce_bonus_products set enabled=true
  where store='APP_STORE' and product_id in (
    'Medication_Review_for_the_Experienced_CRNA','uncommon_anesthesia_events',
    'legal_essentials_CRNA','3_course_bundle_pack');
update public.ce_course1_catalog set released=true,
  metadata=metadata||'{"released":true,"purchases_enabled":true}'::jsonb
  where id='1047239';
update public.ce_course2_catalog set released=true,
  metadata=metadata||'{"released":true,"purchases_enabled":true}'::jsonb
  where id='1047241';
update public.ce_course3_catalog set released=true,
  metadata=metadata||'{"released":true,"purchases_enabled":true}'::jsonb
  where id='1047243';
update public.ce_course1_certificate_settings set enabled=true where course_id='1047239';
update public.ce_course2_certificate_settings set enabled=true where course_id='1047241';
update public.ce_course3_certificate_settings set enabled=true where course_id='1047243';
commit;
