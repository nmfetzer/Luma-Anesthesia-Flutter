-- Additive live Stripe bridge. Does not release courses or change bonus rules.
begin;
create schema ce_stripe_live;
revoke all on schema ce_stripe_live from public,anon,authenticated;
do $$
declare t text; d text;
begin
  foreach t in array array['luma_ce_bonus_products','luma_ce_bonus_refunds',
    'ce_course1_store_products','ce_course2_store_products','ce_course3_store_products'] loop
    execute format('alter table public.%I drop constraint %I',t,t||'_store_check');
    execute format('alter table public.%I add constraint %I check (store in (''APP_STORE'',''PLAY_STORE'',''STRIPE''))',t,t||'_store_check');
  end loop;
  -- Preserve the Apple reviewer wrapper and all readiness logic.
  -- Only include verified Stripe ownership in the normal native paywall status.
  select pg_get_functiondef('luma_review.luma_ce_checkout_status()'::regprocedure) into d;
  if position('WHERE user_id=uid AND store=''APP_STORE'' AND revoked_at IS NULL' in d)=0 then
    raise exception 'Native checkout definition changed; review before applying';
  end if;
  execute replace(d,
    'WHERE user_id=uid AND store=''APP_STORE'' AND revoked_at IS NULL',
    'WHERE user_id=uid AND store IN (''APP_STORE'',''STRIPE'') AND revoked_at IS NULL');
end $$;
create table ce_stripe_live.products (
  code text primary key,
  product_id text unique not null,
  price_id text unique not null,
  amount integer not null,
  courses integer[] not null
);
insert into ce_stripe_live.products values
 ('medication','Medication_Review_for_the_Experienced_CRNA','price_1UKH9BLbhEgJbqRtjRpHlVRq',24999,array[1]),
 ('uncommon','uncommon_anesthesia_events','price_1UKHQCLbhEgJbqRtUGbwtIkh',24999,array[2]),
 ('legal','legal_essentials_CRNA','price_1UKHS7LbhEgJbqRtbTxjGig8',24999,array[3]),
 ('bundle','3_course_bundle_pack','price_1UM41BLbhEgJbqRtks7urAQN',69999,array[1,2,3]);
insert into public.luma_ce_bonus_products(store,product_id,bonus_months,enabled)
select 'STRIPE',product_id,case when code='bundle' then 3 else 1 end,true from ce_stripe_live.products;
insert into public.ce_course1_store_products select 'STRIPE',product_id from ce_stripe_live.products where 1=any(courses);
insert into public.ce_course2_store_products select 'STRIPE',product_id from ce_stripe_live.products where 2=any(courses);
insert into public.ce_course3_store_products select 'STRIPE',product_id from ce_stripe_live.products where 3=any(courses);
create table ce_stripe_live.orders (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id),
 product_code text not null references ce_stripe_live.products(code),
 price_id text not null, amount integer not null,
 created_at timestamptz not null default now(),
 state text not null default 'pending' check(state in ('pending','paid','refunded','expired')),
 session_id text unique, payment_intent text unique, purchased_at timestamptz
);
create unique index ce_stripe_one_pending on ce_stripe_live.orders(user_id) where state='pending';
create table ce_stripe_live.events (
 event_id text primary key, order_id uuid not null references ce_stripe_live.orders(id),
 state text not null, recorded_at timestamptz not null default now()
);
alter table ce_stripe_live.products enable row level security;
alter table ce_stripe_live.orders enable row level security;
alter table ce_stripe_live.events enable row level security;
revoke all on all tables in schema ce_stripe_live from public,anon,authenticated;

create function ce_stripe_live.owned(p_user uuid) returns integer[]
language sql stable security definer set search_path='' as $$
 select coalesce(array_agg(distinct m.n),'{}') from public.luma_ce_bonus_purchases p
 join (select 1 n,store,product_id from public.ce_course1_store_products
   union all select 2,store,product_id from public.ce_course2_store_products
   union all select 3,store,product_id from public.ce_course3_store_products) m
 on m.store=p.store and m.product_id=p.product_id
 where p.user_id=p_user and p.revoked_at is null;
$$;
create function ce_stripe_live.ready(p_code text) returns boolean
language plpgsql stable security definer set search_path='' as $$
declare p ce_stripe_live.products%rowtype; n integer; ok boolean;
begin
 select * into p from ce_stripe_live.products where code=p_code;
 if not found or current_date not between date '2026-10-01' and date '2029-09-30' then return false; end if;
 if not exists(select 1 from public.luma_ce_bonus_products where store='STRIPE' and product_id=p.product_id and enabled) then return false; end if;
 foreach n in array p.courses loop
   execute format('select exists(select 1 from public.ce_course%s_catalog c join public.ce_course%s_certificate_settings s on c.id=s.course_id where c.released and s.enabled and s.approved_at is not null and nullif(s.signature_png_base64,'''') is not null and jsonb_typeof(c.metadata->''modules'')=''array'' and jsonb_array_length(c.metadata->''modules'') >= $1 and exists(select 1 from public.ce_course%s_store_products where store=''STRIPE'' and product_id=$2))',n,n,n)
   into ok using case n when 1 then 11 when 2 then 10 else 1 end,p.product_id;
   if not ok then return false; end if;
 end loop;
 return true;
end $$;
create function public.ce_stripe_live_state(p_user uuid) returns jsonb
language plpgsql stable security definer set search_path='' as $$
begin
 if not exists(select 1 from auth.users where id=p_user and is_anonymous=false) then raise exception 'Permanent account required'; end if;
 return jsonb_build_object('user_id',p_user,'existing_courses',ce_stripe_live.owned(p_user),
  'orders',(select coalesce(jsonb_agg(jsonb_build_object('id',id,'product_code',product_code,'state',state,'session_id',session_id)),'[]') from ce_stripe_live.orders where user_id=p_user),
  'products',(select jsonb_agg(jsonb_build_object('code',code,'amount',amount,'currency','usd','enabled',ce_stripe_live.ready(code))) from ce_stripe_live.products));
end $$;
create function public.ce_stripe_live_get(p_id uuid) returns jsonb
language sql stable security definer set search_path='' as $$
 select to_jsonb(o) from ce_stripe_live.orders o where id=p_id;
$$;
create function public.ce_stripe_live_reserve(p_user uuid,p_code text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare p ce_stripe_live.products%rowtype; o ce_stripe_live.orders%rowtype;
begin
 perform pg_advisory_xact_lock(hashtextextended('stripe-live:'||p_user::text,0));
 if not exists(select 1 from auth.users where id=p_user and is_anonymous=false) then raise exception 'Permanent account required'; end if;
 select * into strict p from ce_stripe_live.products where code=p_code;
 if not ce_stripe_live.ready(p_code) then raise exception 'Course is not ready for purchase'; end if;
 if p.courses && ce_stripe_live.owned(p_user) then raise exception 'Already owned course or overlapping bundle'; end if;
 select * into o from ce_stripe_live.orders where user_id=p_user and state='pending';
 if found then
   if o.product_code<>p_code then raise exception 'Resolve pending checkout first'; end if;
   return to_jsonb(o);
 end if;
 insert into ce_stripe_live.orders(user_id,product_code,price_id,amount)
 values(p_user,p_code,p.price_id,p.amount) returning * into o;
 return to_jsonb(o);
end $$;
create function public.ce_stripe_live_attach(p_id uuid,p_session text) returns void
language plpgsql security definer set search_path='' as $$
declare o ce_stripe_live.orders%rowtype;
begin
 select * into strict o from ce_stripe_live.orders where id=p_id for update;
 if p_session is null or p_session not like 'cs_live_%' or (o.session_id is not null and o.session_id<>p_session) then raise exception 'Session mismatch'; end if;
 update ce_stripe_live.orders set session_id=p_session where id=p_id;
end $$;
create function public.ce_stripe_live_apply(p_id uuid,p_event text,p_session text,p_intent text,p_state text,p_purchased_at timestamptz)
returns void language plpgsql security definer set search_path='' as $$
declare o ce_stripe_live.orders%rowtype; e ce_stripe_live.events%rowtype; product text;
begin
 select * into strict o from ce_stripe_live.orders where id=p_id;
 perform pg_advisory_xact_lock(hashtextextended('stripe-live:'||o.user_id::text,0));
 select * into strict o from ce_stripe_live.orders where id=p_id for update;
 if p_state not in ('paid','refunded','expired') or nullif(p_event,'') is null then raise exception 'Invalid event'; end if;
 if p_session is not null and (p_session not like 'cs_live_%' or (o.session_id is not null and o.session_id<>p_session)) then raise exception 'Session mismatch'; end if;
 if o.payment_intent is not null and p_intent is not null and o.payment_intent<>p_intent then raise exception 'Intent mismatch'; end if;
 if p_state in ('paid','refunded') and (p_intent is null or p_intent not like 'pi_%' or p_purchased_at is null) then raise exception 'Verified payment required'; end if;
 if o.purchased_at is not null and p_purchased_at is not null and o.purchased_at<>p_purchased_at then raise exception 'Payment time mismatch'; end if;
 select * into e from ce_stripe_live.events where event_id=p_event;
 if found then
   if e.order_id<>p_id then raise exception 'Event identity mismatch'; end if;
   return;
 end if;
 select product_id into strict product from ce_stripe_live.products where code=o.product_code;
 if p_state in ('paid','refunded') then
   -- Shared existing function enforces cross-channel lifetime bonus rules.
   -- Recording a refund first retains lifetime award history but never opens access.
   if p_state='refunded' or o.state='refunded' then
     perform public.revoke_verified_ce_bonus('STRIPE',p_intent,now());
   end if;
   perform public.record_verified_ce_bonus('STRIPE',p_intent,product,o.user_id,p_purchased_at);
 end if;
 insert into ce_stripe_live.events(event_id,order_id,state) values(p_event,p_id,p_state);
 update ce_stripe_live.orders set session_id=coalesce(session_id,p_session),
  payment_intent=coalesce(payment_intent,p_intent),purchased_at=coalesce(purchased_at,p_purchased_at),
  state=case when state='refunded' or p_state='refunded' then 'refunded'
    when state='paid' or p_state='paid' then 'paid' else p_state end where id=p_id;
end $$;
revoke all on all functions in schema ce_stripe_live from public,anon,authenticated;
revoke all on function public.ce_stripe_live_state(uuid),public.ce_stripe_live_get(uuid),
 public.ce_stripe_live_reserve(uuid,text),public.ce_stripe_live_attach(uuid,text),
 public.ce_stripe_live_apply(uuid,text,text,text,text,timestamptz) from public,anon,authenticated;
grant execute on function public.ce_stripe_live_state(uuid),public.ce_stripe_live_get(uuid),
 public.ce_stripe_live_reserve(uuid,text),public.ce_stripe_live_attach(uuid,text),
 public.ce_stripe_live_apply(uuid,text,text,text,text,timestamptz) to service_role;
commit;
