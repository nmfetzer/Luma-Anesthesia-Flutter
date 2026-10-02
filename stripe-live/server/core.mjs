// Live browser checkout only. Native billing and the isolated sandbox are separate.
import { Fault, requireThat, checkOverlap, safeCheckoutUrl } from '../../stripe-test/server/core.mjs';
export const PRODUCTS = Object.freeze({
  medication: { product: 'Medication_Review_for_the_Experienced_CRNA', price: 'price_1UKH9BLbhEgJbqRtjRpHlVRq', stripeProduct: 'prod_VKx3iR8Cg2nJ7x', cents: 24999, courses: [1] },
  uncommon: { product: 'uncommon_anesthesia_events', price: 'price_1UKHQCLbhEgJbqRtUGbwtIkh', stripeProduct: 'prod_VKxKft0Jb8rCmQ', cents: 24999, courses: [2] },
  legal: { product: 'legal_essentials_CRNA', price: 'price_1UKHS7LbhEgJbqRtbTxjGig8', stripeProduct: 'prod_VKxMar3xCVh9Z3', cents: 24999, courses: [3] },
  bundle: { product: '3_course_bundle_pack', price: 'price_1UM41BLbhEgJbqRtks7urAQN', stripeProduct: 'prod_VMncMejlpz0oyE', cents: 69999, courses: [1, 2, 3] },
});
export const ORIGIN = 'https://ce.cehalo.com';
export const PROJECT = 'https://xuckkusbbcxplpqclbxt.supabase.co';
export const INTEGRATION = 'ce-stripe-live-v1';
export function configFrom(env) {
  requireThat(env.SUPABASE_URL === PROJECT, 'Wrong server project.', 503);
  requireThat(/^(sk|rk)_live_/.test(env.CE_STRIPE_LIVE_SECRET_KEY || ''), 'Live payment configuration is incomplete.', 503);
  requireThat(/^whsec_/.test(env.CE_STRIPE_LIVE_WEBHOOK_SECRET || ''), 'Live webhook configuration is incomplete.', 503);
  const modern = JSON.parse(env.SUPABASE_SECRET_KEYS || '{}').default;
  const ledgerKey = modern?.startsWith('sb_secret_') ? modern : env.SUPABASE_SERVICE_ROLE_KEY;
  requireThat(typeof ledgerKey === 'string' && ledgerKey.length > 0, 'Server configuration is incomplete.', 503);
  return { origin: ORIGIN, ledgerUrl: PROJECT, ledgerKey,
    authUrl: PROJECT, authKey: 'sb_publishable_NXrT6ajzRKmpEfNKGh_G9g_Nd6RmEg7',
    stripeKey: env.CE_STRIPE_LIVE_SECRET_KEY, webhookSecret: env.CE_STRIPE_LIVE_WEBHOOK_SECRET,
    enabled: env.CE_STRIPE_LIVE_ENABLED === 'true' };
}
export function setupStatus(env) {
  const missing = ['CE_STRIPE_LIVE_SECRET_KEY', 'CE_STRIPE_LIVE_WEBHOOK_SECRET'].filter(k => !env[k]);
  try {
    const c = configFrom(env);
    return { live: true, configuration_ready: true, checkout_enabled: c.enabled, missing_settings: missing };
  } catch {
    return { live: true, configuration_ready: false, checkout_enabled: false, missing_settings: missing };
  }
}
export function validatePrice(price, code) {
  const p = PRODUCTS[code];
  requireThat(p && price?.id === p.price && price.product === p.stripeProduct &&
    price.livemode === true && price.active === true && price.type === 'one_time' &&
    price.recurring == null && price.currency === 'usd' && price.unit_amount === p.cents &&
    price.billing_scheme === 'per_unit' && !price.transform_quantity && !price.custom_unit_amount,
  'Course price could not be verified. No checkout was opened.', 503);
}
export function checkoutPayload(o) {
  return { mode: 'payment', 'payment_method_types[0]': 'card',
    'line_items[0][price]': o.price_id, 'line_items[0][quantity]': '1',
    client_reference_id: o.user_id,
    'metadata[integration]': INTEGRATION, 'metadata[ce_order]': o.id,
    'metadata[luma_user_id]': o.user_id,
    'payment_intent_data[metadata][integration]': INTEGRATION,
    'payment_intent_data[metadata][ce_order]': o.id,
    'payment_intent_data[metadata][luma_user_id]': o.user_id,
    success_url: `${ORIGIN}/?ce_checkout=return#/ce-purchase`,
    cancel_url: `${ORIGIN}/?ce_checkout=cancel#/ce-purchase`,
    expires_at: String(Math.floor(Date.parse(o.created_at) / 1000) + 3600),
    'adaptive_pricing[enabled]': 'false' };
}
export function verifySession(s, o) {
  const lines = s?.line_items?.data;
  requireThat(s?.id?.startsWith('cs_live_') && s.livemode === true && s.mode === 'payment' &&
    s.client_reference_id === o.user_id && s.metadata?.integration === INTEGRATION &&
    s.metadata.ce_order === o.id && s.metadata.luma_user_id === o.user_id &&
    s.currency === 'usd' && s.amount_total === o.amount &&
    lines?.length === 1 && s.line_items.has_more === false && lines[0].quantity === 1 &&
    lines[0].price?.id === o.price_id && lines[0].price.livemode === true &&
    (!o.session_id || o.session_id === s.id), 'Checkout verification failed.', 409);
  return s.status === 'complete' && s.payment_status === 'paid';
}
export function verifyIntent(pi, o) {
  const c = pi?.latest_charge;
  requireThat(pi?.id?.startsWith('pi_') && pi.livemode === true && pi.status === 'succeeded' &&
    pi.amount === o.amount && pi.amount_received === o.amount && pi.currency === 'usd' &&
    pi.metadata?.integration === INTEGRATION && pi.metadata.ce_order === o.id &&
    pi.metadata.luma_user_id === o.user_id &&
    c && typeof c === 'object' && c.livemode === true && c.paid === true &&
    c.amount === o.amount && c.currency === 'usd' && c.payment_intent === pi.id &&
    Number.isInteger(c.created) && c.created * 1000 >= Date.parse(o.created_at) - 60000,
  'Payment verification failed.', 409);
  return { revoked: c.refunded === true || c.amount_refunded > 0 || c.disputed === true,
    purchasedAt: new Date(c.created * 1000).toISOString() };
}
export function createHandler(config, deps) {
  const headers = { 'Content-Type': 'application/json', 'Cache-Control': 'no-store',
    'Access-Control-Allow-Origin': ORIGIN, Vary: 'Origin',
    'Access-Control-Allow-Headers': 'authorization, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS' };
  const respond = (status, body) => new Response(JSON.stringify(body), { status, headers });
  async function settle(event) {
    requireThat(event.livemode === true && typeof event.id === 'string', 'Live event required.');
    const type = event.type;
    if (!['checkout.session.completed', 'checkout.session.async_payment_succeeded',
      'checkout.session.expired', 'charge.refunded', 'charge.dispute.created'].includes(type)) return;
    let o, s, pi;
    if (type.startsWith('checkout.session.')) {
      s = await deps.stripe.session(event.data.object.id);
      if (s.metadata?.integration !== INTEGRATION) return;
      o = await deps.store.get(s.metadata.ce_order);
      requireThat(o, 'Order not found.', 409);
      const paid = verifySession(s, o);
      if (s.status === 'expired') {
        await deps.store.apply(o.id, event.id, s.id, null, 'expired', null);
        return;
      }
      if (!paid) return;
      pi = typeof s.payment_intent === 'string'
        ? await deps.stripe.intent(s.payment_intent) : s.payment_intent;
    } else {
      const obj = event.data.object;
      const charge = await deps.stripe.charge(type === 'charge.refunded' ? obj.id : obj.charge);
      requireThat(charge.livemode === true, 'Live charge required.');
      if (!charge.payment_intent) return;
      pi = await deps.stripe.intent(charge.payment_intent);
      if (pi.metadata?.integration !== INTEGRATION) return;
      o = await deps.store.get(pi.metadata.ce_order);
      requireThat(o, 'Order not found.', 409);
    }
    const { revoked, purchasedAt } = verifyIntent(pi, o);
    if (!type.startsWith('checkout.session.') && !revoked) return;
    await deps.store.apply(o.id, event.id, s?.id ?? null, pi.id,
      revoked ? 'refunded' : 'paid', purchasedAt);
  }
  return async request => {
    try {
      const route = new URL(request.url).pathname.split('/').filter(Boolean).at(-1);
      if (route === 'webhook') {
        requireThat(request.method === 'POST', 'POST required.', 405);
        const raw = await request.text();
        requireThat(raw.length <= 262144, 'Event too large.', 413);
        await settle(await deps.verifyEvent(raw, request.headers.get('stripe-signature'), config.webhookSecret));
        return respond(200, { received: true });
      }
      requireThat(request.headers.get('origin') === ORIGIN, 'Origin not allowed.', 403);
      if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers });
      requireThat(request.method === 'POST' && ['status', 'checkout'].includes(route), 'Not found.', 404);
      const token = request.headers.get('authorization');
      requireThat(/^Bearer \S+$/.test(token || ''), 'Sign in with your Luma account.', 401);
      const user = await deps.user(token);
      requireThat(user?.id && user.is_anonymous === false, 'Permanent sign-in required.', 401);
      let state = await deps.store.state(user.id);
      requireThat(state?.user_id === user.id, 'Account could not be verified.', 503);
      // Read back Stripe on returns; never trust URL parameters as proof of payment.
      for (const o of state.orders.filter(x => x.state === 'pending' && x.session_id)) {
        const s = await deps.stripe.session(o.session_id);
        if (s.status !== 'open') await settle({
          id: `reconcile_${s.id}_${s.status}`, livemode: true,
          type: s.status === 'expired' ? 'checkout.session.expired' : 'checkout.session.completed',
          data: { object: { id: s.id } } });
      }
      state = await deps.store.state(user.id);
      if (route === 'status') return respond(200, { ...state, live: true, checkout_enabled: config.enabled });
      requireThat(config.enabled, 'Website checkout is not enabled yet.', 503);
      const body = await request.json();
      requireThat(body && Object.keys(body).length === 1 && PRODUCTS[body.product_code], 'Choose a course.');
      const code = body.product_code;
      checkOverlap(code, state.existing_courses);
      requireThat(state.products.some(p => p.code === code && p.enabled),
        'This course is not currently available for purchase.', 409);
      validatePrice(await deps.stripe.price(PRODUCTS[code].price), code);
      // Returning via Stripe's cancel URL does not expire its hosted session.
      // On an explicit different-product checkout request, close the old session
      // at Stripe BEFORE releasing its database reservation or creating another.
      const previous = state.orders.find(o => o.state === 'pending' && o.product_code !== code);
      if (previous) {
        requireThat(previous.session_id,
          'A previous checkout needs support reconciliation. No second payment was started.', 409);
        const previousOrder = await deps.store.get(previous.id);
        requireThat(previousOrder?.user_id === user.id && previousOrder.session_id === previous.session_id,
          'Previous checkout identity could not be verified.', 409);
        let previousSession = await deps.stripe.session(previous.session_id);
        verifySession(previousSession, previousOrder);
        if (previousSession.status === 'open') {
          requireThat(previousSession.payment_status === 'unpaid',
            'Previous payment is being checked. Refresh course access before continuing.', 409);
          // A payment may finish concurrently, or a successful expiration request
          // may time out. Retrieve authoritative status in either case.
          try { await deps.stripe.expire(previous.session_id); } catch { /* recheck below */ }
          previousSession = await deps.stripe.session(previous.session_id);
          verifySession(previousSession, previousOrder);
        }
        if (previousSession.status === 'complete') {
          await settle({ id: `reconcile_${previousSession.id}_complete`, livemode: true,
            type: 'checkout.session.completed', data: { object: { id: previousSession.id } } });
          throw new Fault(409, 'Your previous checkout completed. Refresh course access before starting another purchase.');
        }
        requireThat(previousSession.status === 'expired' && previousSession.payment_status === 'unpaid',
          'Previous checkout is still open. Refresh course access before trying again.', 409);
        await settle({ id: `reconcile_${previousSession.id}_expired`, livemode: true,
          type: 'checkout.session.expired', data: { object: { id: previousSession.id } } });
      }
      const o = await deps.store.reserve(user.id, code);
      requireThat(o.user_id === user.id && o.product_code === code &&
        o.price_id === PRODUCTS[code].price && o.amount === PRODUCTS[code].cents &&
        o.state === 'pending', 'Order could not be verified.', 409);
      let s;
      if (o.session_id) s = await deps.stripe.session(o.session_id);
      else {
        requireThat(Date.parse(o.created_at) > Date.now() - 25 * 60000,
          'A previous checkout needs support reconciliation. No second charge was started.', 409);
        s = await deps.stripe.create(checkoutPayload(o), `ce-live-v1-${o.id}`);
      }
      requireThat(typeof s.id === 'string', 'Checkout could not be created.', 503);
      const verified = await deps.stripe.session(s.id);
      verifySession(verified, o);
      requireThat(verified.status === 'open', 'Payment status changed. Refresh access.', 409);
      const url = safeCheckoutUrl(s.url);
      await deps.store.attach(o.id, s.id);
      return respond(200, { live: true, user_id: user.id, url });
    } catch (e) {
      return respond(e instanceof Fault ? e.status : 503, { error: e instanceof Fault
        ? e.message : 'Payment service is unavailable. Refresh access before trying again.' });
    }
  };
}
