// No browser-provided amount, email, paid flag or user ID is trusted for a grant.
import { PRODUCTS, ORIGIN, PROJECT, validatePrice } from './core.mjs';
import { Fault, requireThat, safeCheckoutUrl } from '../../stripe-test/server/core.mjs';
export const GUEST = 'ce-stripe-guest-v1';
// Immutable, owner-supplied deployment. Catalog inspection only; no payment,
// account lookup, claims, or arbitrary Netlify origins are authorized here.
export const CATALOG_PREVIEW = 'https://6ac6f38d36c36480ba724497--mellifluous-tartufo-a5c6b2.netlify.app';
const UUID = /^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$/i;
export function guestPayload(o) {
  return { mode: 'payment', 'payment_method_types[0]': 'card',
    'line_items[0][price]': o.price_id, 'line_items[0][quantity]': '1',
    client_reference_id: o.id, 'metadata[integration]': GUEST, 'metadata[guest_order]': o.id,
    'payment_intent_data[metadata][integration]': GUEST,
    'payment_intent_data[metadata][guest_order]': o.id,
    'custom_text[submit][message]': 'Use your Luma email if you already have an account. After payment, verify that email and complete your learner profile to activate course access.',
    success_url: `${ORIGIN}/?ce_guest=return#/ce-purchase?product=${PRODUCTS[o.product_code].product}`,
    cancel_url: `${ORIGIN}/?ce_guest=cancel#/ce-purchase?product=${PRODUCTS[o.product_code].product}`,
    expires_at: String(Math.floor(Date.parse(o.created_at) / 1000) + 3600),
    'adaptive_pricing[enabled]': 'false' };
}
export function verifyGuestSession(s,o) {
  const lines=s?.line_items;
  requireThat(s?.livemode===true && s.id?.startsWith('cs_live_') && s.mode==='payment' &&
    s.client_reference_id===o.id && s.metadata?.integration===GUEST &&
    s.metadata.guest_order===o.id && s.currency==='usd' && s.amount_total===o.amount &&
    lines?.has_more===false && lines.data?.length===1 && lines.data[0].quantity===1 &&
    lines.data[0].price?.id===o.price_id && lines.data[0].price.livemode===true &&
    (!o.session_id || o.session_id===s.id),'Checkout verification failed.',409);
  return s.status==='complete' && s.payment_status==='paid';
}
export function verifyGuestIntent(pi,o) {
  const c=pi?.latest_charge;
  requireThat(pi?.id?.startsWith('pi_') && pi.livemode===true && pi.status==='succeeded' &&
    pi.amount===o.amount && pi.amount_received===o.amount && pi.currency==='usd' &&
    pi.metadata?.integration===GUEST && pi.metadata.guest_order===o.id &&
    (!o.payment_intent || pi.id===o.payment_intent) &&
    c && typeof c==='object' && c.livemode===true && c.paid===true &&
    c.payment_intent===pi.id && c.currency==='usd' && c.amount===o.amount &&
    Number.isInteger(c.created) && c.created*1000>=Date.parse(o.created_at)-60000,
    'Payment verification failed.',409);
  return {state:c.refunded || c.amount_refunded>0 || c.disputed?'refunded':'paid',
    purchasedAt:new Date(c.created*1000).toISOString()};
}
// Call ONLY after auth /user has validated this exact bearer. Claims alone are NOT authentication.
export function requireFreshEmailProof(token,user,now=Date.now()/1000) {
  let claims;
  try { claims=JSON.parse(atob(token.replace(/^Bearer /,'').split('.')[1].replace(/-/g,'+').replace(/_/g,'/'))); } catch {}
  requireThat(user?.id && user.is_anonymous===false && user.email_confirmed_at &&
    claims?.sub===user.id && claims.iss===`${PROJECT}/auth/v1` && claims.aud==='authenticated' &&
    claims.exp>now && claims.session_id &&
    claims.amr?.some(x=>['otp','magiclink'].includes(x.method) &&
      Number.isFinite(x.timestamp) && x.timestamp<=now+30 && x.timestamp>=now-1800),
    'Verify your purchase email using a fresh email link before activating access.',401);
}
export function createGuest(config,deps) {
  const headers={'Content-Type':'application/json','Cache-Control':'no-store',
    'Access-Control-Allow-Origin':ORIGIN,Vary:'Origin',
    'Access-Control-Allow-Headers':'authorization, content-type','Access-Control-Allow-Methods':'POST, OPTIONS'};
  const reply=(status,data)=>new Response(JSON.stringify(data),{status,headers});
  async function settle(event) {
    requireThat(event.livemode===true,'Live event required.');
    if(!['checkout.session.completed','checkout.session.async_payment_succeeded',
      'checkout.session.expired','charge.refunded','charge.dispute.created'].includes(event.type)) return;
    let o,s,pi,email=null;
    if(event.type.startsWith('checkout.session.')) {
      s=await deps.stripe.session(event.data.object.id);
      if(s.metadata?.integration!==GUEST)return;
      o=await deps.guestStore.get(s.metadata.guest_order);
      requireThat(o,'Purchase not found.',409);
      const paid=verifyGuestSession(s,o);
      if(s.status==='expired') {
        await deps.guestStore.apply(o.id,event.id,s.id,null,'expired',null,null); return;
      }
      if(!paid)return;
      email=s.customer_details?.email?.trim().toLowerCase();
      requireThat(typeof email==='string' && email.length<=254 && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email),
        'Purchase email needs support review.',409);
      pi=typeof s.payment_intent==='string'?await deps.stripe.intent(s.payment_intent):s.payment_intent;
    } else {
      const obj=event.data.object;
      const charge=await deps.stripe.charge(event.type==='charge.refunded'?obj.id:obj.charge);
      if(!charge.payment_intent)return;
      pi=await deps.stripe.intent(charge.payment_intent);
      if(pi.metadata?.integration!==GUEST)return;
      o=await deps.guestStore.get(pi.metadata.guest_order);
      requireThat(o,'Purchase not found.',409);
    }
    const verified=verifyGuestIntent(pi,o);
    if(!s && verified.state!=='refunded')return;
    await deps.guestStore.apply(o.id,event.id,s?.id??null,pi.id,verified.state,verified.purchasedAt,email);
  }
  async function reconcile(o) {
    if(!o.session_id)return;
    const s=await deps.stripe.session(o.session_id);
    verifyGuestSession(s,o);
    if(s.status==='complete'||s.status==='expired')await settle({
      id:`guest_reconcile_${s.id}_${s.status}_${s.payment_status}`,livemode:true,
      type:s.status==='expired'?'checkout.session.expired':'checkout.session.completed',
      data:{object:{id:s.id}}});
  }
  const handle=async request=>{
    try {
      const previewRoute=new URL(request.url).pathname.split('/').at(-1);
      if(request.headers.get('origin')===CATALOG_PREVIEW && previewRoute==='guest-catalog') {
        const previewHeaders={...headers,'Access-Control-Allow-Origin':CATALOG_PREVIEW};
        if(request.method==='OPTIONS')return new Response(null,{status:204,headers:previewHeaders});
        requireThat(request.method==='POST','POST required.',405);
        return new Response(JSON.stringify({live:true,...await deps.guestStore.catalog(),enabled:false}),
          {status:200,headers:previewHeaders});
      }
      requireThat(request.headers.get('origin')===ORIGIN,'Origin not allowed.',403);
      if(request.method==='OPTIONS')return new Response(null,{status:204,headers});
      const route=new URL(request.url).pathname.split('/').at(-1);
      requireThat(request.method==='POST','POST required.',405);
      const raw=await request.text();
      requireThat(raw.length<=8192,'Request too large.',413);
      const body=JSON.parse(raw||'{}');
      if(route==='guest-catalog')return reply(200,{live:true,...await deps.guestStore.catalog()});
      if(route==='guest-checkout') {
        requireThat(config.enabled,'Checkout is unavailable.',503);
        requireThat(UUID.test(body.request_id||'') && Object.hasOwn(PRODUCTS,body.product_code) &&
          Object.keys(body).length===2,'Choose a course.');
        validatePrice(await deps.stripe.price(PRODUCTS[body.product_code].price),body.product_code);
        const o=await deps.guestStore.reserve(body.request_id,body.product_code);
        const p=PRODUCTS[body.product_code];
        requireThat(o.id===body.request_id && o.product_code===body.product_code &&
          o.amount===p.cents && o.price_id===p.price,
          'This checkout has already finished. Verify your purchase email to recover access.',409);
        if(o.state==='paid')return reply(200,{live:true,paid:true});
        if(o.state==='expired')return reply(200,{live:true,expired:true});
        requireThat(o.state==='pending','Contact CE HALO support about this payment before purchasing again.',409);
        requireThat(o.session_id || Date.parse(o.created_at)>Date.now()-25*60000,
          'This checkout has expired. Start a new checkout only if you have not paid.',409);
        const s=o.session_id?await deps.stripe.session(o.session_id):
          await deps.stripe.create(guestPayload(o),`ce-guest-v1-${o.id}`);
        const full=await deps.stripe.session(s.id);
        verifyGuestSession(full,o);
        if(full.status!=='open') {
          await reconcile({...o,session_id:s.id});
          if(full.status==='expired' && full.payment_status==='unpaid')return reply(200,{live:true,expired:true});
          return reply(200,{live:true,paid:true});
        }
        await deps.guestStore.attach(o.id,s.id);
        return reply(200,{live:true,url:safeCheckoutUrl(s.url)});
      }
      requireThat(['guest-list','guest-claim'].includes(route),'Not found.',404);
      const token=request.headers.get('authorization');
      requireThat(/^Bearer \S+$/.test(token||''),'Verify your purchase email.',401);
      const user=await deps.user(token); // server validates JWT before we read AMR
      requireFreshEmailProof(token,user);
      if(route==='guest-list') {
        if(UUID.test(body.request_id||'')) {
          const pending=await deps.guestStore.get(body.request_id);
          if(pending)await reconcile(pending);
        }
        return reply(200,{live:true,...await deps.guestStore.list(user.id)});
      }
      requireThat(UUID.test(body.order_id||''),'Choose your saved purchase.');
      let o=await deps.guestStore.get(body.order_id);
      requireThat(o && o.email===user.email?.trim().toLowerCase() &&
        (!o.claimed_by || o.claimed_by===user.id),'Purchase does not match your verified email.',403);
      await reconcile(o);
      o=await deps.guestStore.get(o.id);
      requireThat(o.state==='paid','Payment is not available for activation. Contact CE HALO support.',409);
      // Recheck live charge immediately before granting; webhook delivery can lag.
      const intent=await deps.stripe.intent(o.payment_intent);
      const payment=verifyGuestIntent(intent,o);
      if(payment.state==='refunded') {
        await deps.guestStore.apply(o.id,`guest_revoke_${o.payment_intent}`,null,o.payment_intent,
          'refunded',payment.purchasedAt,null);
        throw new Fault(409,'This payment was refunded or disputed. Contact CE HALO support.');
      }
      if(o.claimed_by===user.id)return reply(200,{live:true,claimed:true});
      requireThat(typeof body.full_name==='string' && body.full_name.trim().length>=2 &&
        body.full_name.trim().length<=120 &&
        ['CRNA','SRNA','RN','Physician','Other clinician'].includes(body.role) &&
        body.accept===true,'Complete your learner profile and acknowledge the account security step.');
      requireThat(typeof body.password==='string' && body.password.length>=12 && body.password.length<=128,
        'Use a password of 12 to 128 characters.');
      // Prevent pre-registered, unverified account credentials retaining access.
      // UI explicitly discloses password replacement and other-session sign-out.
      await deps.secureAccount(token,body.password);
      const result=await deps.guestStore.claim(o.id,user.id,body.full_name.trim(),body.role);
      return reply(200,{live:true,...result});
    } catch(e) {
      return reply(e instanceof Fault?e.status:503,{error:e instanceof Fault?e.message:
        'Checkout could not be completed. If you paid, do not pay again; contact CE HALO support.'});
    }
  };
  return {settle,handle};
}
