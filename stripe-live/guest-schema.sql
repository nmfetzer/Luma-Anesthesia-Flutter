-- Additive purchase-first ledger. Install only with the matching server.
-- Kept OFF until the website and email-return path are deployed and checked.
begin;
create table ce_stripe_live.guest_settings (
 singleton boolean primary key default true check(singleton),
 enabled boolean not null default false
);
insert into ce_stripe_live.guest_settings values(true,false);
create table ce_stripe_live.guest_orders (
 id uuid primary key, product_code text not null references ce_stripe_live.products(code),
 price_id text not null, amount integer not null, created_at timestamptz not null default now(),
 state text not null default 'pending' check(state in ('pending','paid','expired','refunded')),
 session_id text unique, payment_intent text unique, purchased_at timestamptz,
 email text, claimed_by uuid references auth.users(id), claimed_at timestamptz,
 needs_review boolean not null default false
);
create index guest_email_lookup on ce_stripe_live.guest_orders(email);
create table ce_stripe_live.guest_events (
 event_id text primary key, order_id uuid not null references ce_stripe_live.guest_orders(id),
 recorded_at timestamptz not null default now()
);
alter table ce_stripe_live.guest_settings enable row level security;
alter table ce_stripe_live.guest_orders enable row level security;
alter table ce_stripe_live.guest_events enable row level security;
revoke all on ce_stripe_live.guest_settings,ce_stripe_live.guest_orders,ce_stripe_live.guest_events from public,anon,authenticated;

create function public.ce_stripe_guest_catalog() returns jsonb
language sql stable security definer set search_path='' as $$
 select jsonb_build_object('enabled', (select enabled from ce_stripe_live.guest_settings),
 'products',(select jsonb_agg(jsonb_build_object('code',code,'amount',amount,
 'enabled',ce_stripe_live.ready(code))) from ce_stripe_live.products));
$$;
create function public.ce_stripe_guest_reserve(p_id uuid,p_code text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare o ce_stripe_live.guest_orders%rowtype; p ce_stripe_live.products%rowtype;
begin
 perform pg_advisory_xact_lock(hashtextextended('stripe-guest-reserve',0));
 if not (select enabled from ce_stripe_live.guest_settings) then raise exception 'Guest checkout disabled'; end if;
 select * into strict p from ce_stripe_live.products where code=p_code;
 if not ce_stripe_live.ready(p_code) then raise exception 'Course is not ready for purchase'; end if;
 select * into o from ce_stripe_live.guest_orders where id=p_id;
 if found then
   if o.product_code<>p_code then raise exception 'Order product mismatch'; end if;
   return to_jsonb(o);
 end if;
 -- Global circuit breaker complements platform rate limits; no email enumeration.
 if (select count(*) from ce_stripe_live.guest_orders where created_at>now()-interval '1 hour')>=300 then
   raise exception 'Checkout capacity reached';
 end if;
 insert into ce_stripe_live.guest_orders(id,product_code,price_id,amount)
 values(p_id,p_code,p.price_id,p.amount) returning * into o;
 return to_jsonb(o);
end $$;
create function public.ce_stripe_guest_get(p_id uuid) returns jsonb
language sql stable security definer set search_path='' as $$
 select to_jsonb(o) from ce_stripe_live.guest_orders o where id=p_id;
$$;
create function public.ce_stripe_guest_attach(p_id uuid,p_session text) returns void
language plpgsql security definer set search_path='' as $$
declare o ce_stripe_live.guest_orders%rowtype;
begin
 select * into strict o from ce_stripe_live.guest_orders where id=p_id for update;
 if p_session is null or p_session not like 'cs_live_%'
   or (o.session_id is not null and o.session_id<>p_session) then raise exception 'Session mismatch'; end if;
 update ce_stripe_live.guest_orders set session_id=p_session where id=p_id;
end $$;
create function public.ce_stripe_guest_apply(p_id uuid,p_event text,p_session text,
 p_intent text,p_state text,p_purchased_at timestamptz,p_email text) returns void
language plpgsql security definer set search_path='' as $$
declare o ce_stripe_live.guest_orders%rowtype; e ce_stripe_live.guest_events%rowtype;
begin
 select * into strict o from ce_stripe_live.guest_orders where id=p_id for update;
 if p_state not in ('paid','refunded','expired') or nullif(p_event,'') is null then raise exception 'Invalid event'; end if;
 if p_session is not null and (p_session not like 'cs_live_%' or (o.session_id is not null and o.session_id<>p_session)) then raise exception 'Session mismatch'; end if;
 if o.payment_intent is not null and p_intent is not null and o.payment_intent<>p_intent then raise exception 'Intent mismatch'; end if;
 if p_state in ('paid','refunded') and (p_intent is null or p_intent not like 'pi_%' or p_purchased_at is null) then raise exception 'Payment required'; end if;
 if o.purchased_at is not null and p_purchased_at is not null and o.purchased_at<>p_purchased_at then raise exception 'Payment time mismatch'; end if;
 if o.email is not null and p_email is not null and o.email<>lower(btrim(p_email)) then raise exception 'Email mismatch'; end if;
 if p_state='paid' and coalesce(o.email,nullif(lower(btrim(p_email)),'')) is null then raise exception 'Email required'; end if;
 select * into e from ce_stripe_live.guest_events where event_id=p_event;
 if found then
   if e.order_id<>p_id then raise exception 'Event identity mismatch'; end if;
   return;
 end if;
 if (p_state='refunded' or o.state='refunded') and o.claimed_by is not null then
   perform public.revoke_verified_ce_bonus('STRIPE',coalesce(o.payment_intent,p_intent),now());
 end if;
 insert into ce_stripe_live.guest_events values(p_event,p_id,now());
 update ce_stripe_live.guest_orders set session_id=coalesce(session_id,p_session),
   payment_intent=coalesce(payment_intent,p_intent),purchased_at=coalesce(purchased_at,p_purchased_at),
   email=coalesce(email,nullif(lower(btrim(p_email)),'')),
   state=case when state='refunded' or p_state='refunded' then 'refunded'
     when state='paid' or p_state='paid' then 'paid' else p_state end where id=p_id;
end $$;
create function public.ce_stripe_guest_list(p_user uuid) returns jsonb
language plpgsql stable security definer set search_path='' as $$
declare mail text;
begin
 select lower(btrim(email)) into mail from auth.users where id=p_user and is_anonymous=false and email_confirmed_at is not null;
 if mail is null then raise exception 'Verified account required'; end if;
 return jsonb_build_object('user_id',p_user,'email',mail,'existing_courses',ce_stripe_live.owned(p_user),
 'orders',(select coalesce(jsonb_agg(jsonb_build_object('id',id,'product_code',product_code,
 'state',state,'claimed',claimed_by=p_user,'needs_review',needs_review)),'[]')
 from ce_stripe_live.guest_orders where email=mail and (claimed_by is null or claimed_by=p_user)));
end $$;
create function public.ce_stripe_guest_claim(p_id uuid,p_user uuid,p_name text,p_role text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare o ce_stripe_live.guest_orders%rowtype; p ce_stripe_live.products%rowtype; mail text;
begin
 -- Same account lock as the original checkout bridge.
 perform pg_advisory_xact_lock(hashtextextended('stripe-live:'||p_user::text,0));
 select * into strict o from ce_stripe_live.guest_orders where id=p_id for update;
 select lower(btrim(email)) into mail from auth.users where id=p_user and is_anonymous=false and email_confirmed_at is not null;
 if mail is null or o.email is distinct from mail then raise exception 'Purchase email mismatch'; end if;
 if o.claimed_by is not null and o.claimed_by<>p_user then raise exception 'Purchase already claimed'; end if;
 if o.state<>'paid' or o.payment_intent is null then raise exception 'Paid purchase required'; end if;
 if o.claimed_by=p_user then return jsonb_build_object('claimed',true); end if;
 if length(btrim(p_name)) not between 2 and 120 or p_role not in ('CRNA','SRNA','RN','Physician','Other clinician') then raise exception 'Learner profile required'; end if;
 select * into strict p from ce_stripe_live.products where code=o.product_code;
 if p.courses && ce_stripe_live.owned(p_user) then
   update ce_stripe_live.guest_orders set needs_review=true where id=p_id;
   return jsonb_build_object('claimed',false,'needs_review',true);
 end if;
 -- Only learner fields; never overwrite subscription state or CE progress.
 insert into public.user_profiles(id,full_name,role,is_guest)
 values(p_user,btrim(p_name),p_role,false)
 on conflict(id) do update set full_name=excluded.full_name,role=excluded.role,is_guest=false;
 perform public.record_verified_ce_bonus('STRIPE',o.payment_intent,p.product_id,p_user,o.purchased_at);
 update ce_stripe_live.guest_orders set claimed_by=p_user,claimed_at=now(),needs_review=false where id=p_id;
 return jsonb_build_object('claimed',true);
end $$;
revoke all on function public.ce_stripe_guest_catalog(),public.ce_stripe_guest_reserve(uuid,text),
 public.ce_stripe_guest_get(uuid),public.ce_stripe_guest_attach(uuid,text),
 public.ce_stripe_guest_apply(uuid,text,text,text,text,timestamptz,text),
 public.ce_stripe_guest_list(uuid),public.ce_stripe_guest_claim(uuid,uuid,text,text)
 from public,anon,authenticated;
grant execute on function public.ce_stripe_guest_catalog(),public.ce_stripe_guest_reserve(uuid,text),
 public.ce_stripe_guest_get(uuid),public.ce_stripe_guest_attach(uuid,text),
 public.ce_stripe_guest_apply(uuid,text,text,text,text,timestamptz,text),
 public.ce_stripe_guest_list(uuid),public.ce_stripe_guest_claim(uuid,uuid,text,text)
 to service_role;
commit;
