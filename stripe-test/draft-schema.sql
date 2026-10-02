-- NOT A PRODUCTION MIGRATION. Install only after approval in a separate test project.
-- Same Luma UUIDs are identifiers only; no auth users or course records are copied.
begin;
do $$ begin
  if to_regclass('public.luma_ce_bonus_purchases') is not null
     or to_regclass('public.ce_course1_catalog') is not null then
    raise exception 'STOP: never install Stripe test ledger in the Luma production project';
  end if;
end; $$;
create schema ce_stripe_test;
revoke all on schema ce_stripe_test from public, anon, authenticated;
create table ce_stripe_test.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  product_code text not null check(product_code in ('medication','uncommon','legal','bundle')),
  price_id text not null check(price_id like 'price_%'),
  amount integer not null check(amount in (24999,69999)),
  created_at timestamptz not null default now(),
  state text not null default 'pending' check(state in ('pending','paid','refunded','expired')),
  session_id text unique,
  payment_intent text unique,
  bonus_baseline integer not null check(bonus_baseline between 0 and 3),
  simulated_bonus_months integer not null default 0 check(simulated_bonus_months between 0 and 3),
  settled_at timestamptz
);
create table ce_stripe_test.events (
  event_id text primary key,
  order_id uuid not null references ce_stripe_test.orders(id),
  state text not null,
  recorded_at timestamptz not null default now()
);
alter table ce_stripe_test.orders enable row level security;
alter table ce_stripe_test.events enable row level security;
revoke all on all tables in schema ce_stripe_test from public,anon,authenticated;

create function public.ce_stripe_test_list(p_user uuid) returns jsonb
language sql security definer set search_path='' as $$
 select coalesce(jsonb_agg(to_jsonb(o) order by created_at),'[]')
 from ce_stripe_test.orders o where user_id=p_user;
$$;
create function public.ce_stripe_test_get(p_id uuid) returns jsonb
language sql security definer set search_path='' as $$
 select to_jsonb(o) from ce_stripe_test.orders o where id=p_id;
$$;
create function public.ce_stripe_test_reserve(p_user uuid,p_code text,p_price text,p_amount integer,p_baseline integer)
returns jsonb language plpgsql security definer set search_path='' as $$
declare prior ce_stripe_test.orders%rowtype; result ce_stripe_test.orders%rowtype;
begin
 perform pg_advisory_xact_lock(hashtextextended('stripe-test:'||p_user::text,0));
 if p_amount <> (case when p_code='bundle' then 69999 else 24999 end) then
   raise exception 'Unexpected price';
 end if;
 if exists(select 1 from ce_stripe_test.orders where user_id=p_user and state='paid'
   and (product_code=p_code or product_code='bundle' or p_code='bundle')) then
   raise exception 'Existing simulated ownership overlaps purchase';
 end if;
 select * into prior from ce_stripe_test.orders where user_id=p_user and state='pending'
   order by created_at limit 1;
 if found then
   if prior.product_code<>p_code or prior.price_id<>p_price then
     raise exception 'Finish or reconcile pending test checkout first';
   end if;
   return to_jsonb(prior);
 end if;
 insert into ce_stripe_test.orders(user_id,product_code,price_id,amount,bonus_baseline)
 values(p_user,p_code,p_price,p_amount,p_baseline) returning * into result;
 return to_jsonb(result);
end; $$;
create function public.ce_stripe_test_attach(p_id uuid,p_session text) returns void
language plpgsql security definer set search_path='' as $$
declare o ce_stripe_test.orders%rowtype;
begin
 select * into strict o from ce_stripe_test.orders where id=p_id for update;
 if o.session_id is not null and o.session_id<>p_session then raise exception 'Session mismatch'; end if;
 if p_session not like 'cs_test_%' then raise exception 'Test session required'; end if;
 update ce_stripe_test.orders set session_id=p_session where id=p_id;
end; $$;
create function public.ce_stripe_test_apply(p_id uuid,p_event text,p_session text,p_intent text,p_state text)
returns void language plpgsql security definer set search_path='' as $$
declare o ce_stripe_test.orders%rowtype; used integer; award integer; existing_event ce_stripe_test.events%rowtype;
begin
 select * into strict o from ce_stripe_test.orders where id=p_id;
 perform pg_advisory_xact_lock(hashtextextended('stripe-test:'||o.user_id::text,0));
 select * into strict o from ce_stripe_test.orders where id=p_id for update;
 if p_state not in ('paid','refunded','expired') or p_event is null then raise exception 'Invalid state'; end if;
 if p_session is not null and (p_session not like 'cs_test_%' or
     (o.session_id is not null and o.session_id<>p_session)) then raise exception 'Session mismatch'; end if;
 if p_intent is not null and o.payment_intent is not null and o.payment_intent<>p_intent then
   raise exception 'Payment mismatch';
 end if;
 if p_state in ('paid','refunded') and p_intent is null then raise exception 'Verified intent required'; end if;
 select * into existing_event from ce_stripe_test.events where event_id=p_event;
 if found then
   if existing_event.order_id<>p_id then raise exception 'Event mismatch'; end if;
   return;
 end if;
 -- Lifetime simulation budget includes refunded orders and previously used real months.
 -- Never updates real bonus dates, subscriptions, ownership, progress or certificates.
 select greatest(o.bonus_baseline,coalesce(max(bonus_baseline),0)) + coalesce(sum(simulated_bonus_months),0)
 into used from ce_stripe_test.orders where user_id=o.user_id;
 award := case
   when o.settled_at is not null then o.simulated_bonus_months
   when p_state='expired' then 0
   when o.product_code='bundle' then greatest(0,3-used)
   when used=0 then 1 else 0 end;
 insert into ce_stripe_test.events(event_id,order_id,state) values(p_event,p_id,p_state);
 update ce_stripe_test.orders set
   session_id=coalesce(session_id,p_session),payment_intent=coalesce(payment_intent,p_intent),
   state=case
     when state='refunded' or p_state='refunded' then 'refunded'
     when state='paid' or p_state='paid' then 'paid' else p_state end,
   simulated_bonus_months=award,
   settled_at=case when p_state='expired' then settled_at else coalesce(settled_at,now()) end
 where id=p_id;
end; $$;
revoke all on function public.ce_stripe_test_list(uuid),public.ce_stripe_test_get(uuid),
 public.ce_stripe_test_reserve(uuid,text,text,integer,integer),
 public.ce_stripe_test_attach(uuid,text),public.ce_stripe_test_apply(uuid,text,text,text,text)
 from public,anon,authenticated;
grant execute on function public.ce_stripe_test_list(uuid),public.ce_stripe_test_get(uuid),
 public.ce_stripe_test_reserve(uuid,text,text,integer,integer),
 public.ce_stripe_test_attach(uuid,text),public.ce_stripe_test_apply(uuid,text,text,text,text)
 to service_role;
commit;
