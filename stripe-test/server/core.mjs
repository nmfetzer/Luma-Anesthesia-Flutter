// Test-only server domain. No production entitlement/certificate writes.
export const PRODUCTS = Object.freeze({
  medication: { apple: 'Medication_Review_for_the_Experienced_CRNA', cents: 24999, courses: [1] },
  uncommon: { apple: 'uncommon_anesthesia_events', cents: 24999, courses: [2] },
  legal: { apple: 'legal_essentials_CRNA', cents: 24999, courses: [3] },
  bundle: { apple: '3_course_bundle_pack', cents: 69999, courses: [1, 2, 3] },
});
const LIVE_PRICES = new Set([
  'price_1UKH9BLbhEgJbqRtjRpHlVRq', 'price_1UKHQCLbhEgJbqRtUGbwtIkh',
  'price_1UKHS7LbhEgJbqRtbTxjGig8', 'price_1UM41BLbhEgJbqRtks7urAQN',
]);
export class Fault extends Error {
  constructor(status, message) { super(message); this.status = status; }
}
export function requireThat(ok, message, status = 400) {
  if (!ok) throw new Fault(status, message);
}
function ledgerCredential(env, ledgerOrigin) {
  if (env.SUPABASE_URL) {
    requireThat(new URL(env.SUPABASE_URL).origin === ledgerOrigin,
      'The test ledger must match this function project.', 503);
    // Use only this isolated function project's built-in server credential.
    // No need to copy a database secret through a browser or into this repo.
    const keys = JSON.parse(env.SUPABASE_SECRET_KEYS || '{}');
    if (typeof keys.default === 'string' && keys.default.startsWith('sb_secret_')) {
      return keys.default;
    }
    return env.SUPABASE_SERVICE_ROLE_KEY || env.CE_TEST_LEDGER_SERVICE_KEY;
  }
  return env.CE_TEST_LEDGER_SERVICE_KEY; // Explicit credential for local runtimes.
}
export function configFrom(env) {
  requireThat(env.CE_STRIPE_TEST_ENABLED === 'true', 'Test checkout is not configured.', 503);
  requireThat(/^(sk|rk)_test_/.test(env.STRIPE_TEST_SECRET_KEY ?? ''), 'A test-only Stripe key is required.', 503);
  requireThat(/^whsec_/.test(env.STRIPE_TEST_WEBHOOK_SECRET ?? ''), 'Webhook configuration is missing.', 503);
  const origin = new URL(env.CE_TEST_PORTAL_ORIGIN);
  requireThat(origin.protocol === 'https:' ||
    (origin.protocol === 'http:' && ['localhost', '127.0.0.1'].includes(origin.hostname)),
    'Invalid portal origin.', 503);
  requireThat(origin.pathname === '/' && !origin.search && !origin.hash && !origin.username,
    'Use an origin, not a return URL.', 503);
  const authUrl = new URL(env.LUMA_AUTH_SUPABASE_URL);
  const ledgerUrl = new URL(env.CE_TEST_LEDGER_URL);
  requireThat(authUrl.protocol === 'https:' && ledgerUrl.protocol === 'https:' &&
    authUrl.origin !== ledgerUrl.origin &&
    ledgerUrl.hostname !== 'xuckkusbbcxplpqclbxt.supabase.co' &&
    [authUrl, ledgerUrl].every(u => !u.username && !u.password && u.pathname === '/' && !u.search && !u.hash),
    'Test ledger must be in a separate HTTPS project.', 503);
  requireThat(/^sb_publishable_/.test(env.LUMA_AUTH_PUBLIC_KEY ?? ''),
    'Use only the Luma public publishable key for read-only account checks.', 503);
  const ledgerKey = ledgerCredential(env, ledgerUrl.origin);
  requireThat(typeof ledgerKey === 'string' && ledgerKey.length > 0,
    'The test project server credential is unavailable.', 503);
  const testers = new Set((env.CE_TEST_USER_IDS ?? '').split(',').map(x => x.trim()).filter(Boolean));
  requireThat(testers.size > 0 && [...testers].every(x => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(x)),
    'Explicit test account IDs are required.', 503);
  const prices = Object.fromEntries(Object.keys(PRODUCTS).map(code => {
    const id = env[`STRIPE_TEST_PRICE_${code.toUpperCase()}`];
    requireThat(/^price_[A-Za-z0-9]+$/.test(id ?? '') && !LIVE_PRICES.has(id),
      'Separate test Price IDs are required.', 503);
    return [code, id];
  }));
  requireThat(new Set(Object.values(prices)).size === 4, 'Each test product needs its own price.', 503);
  return {
    stripeKey: env.STRIPE_TEST_SECRET_KEY, webhookSecret: env.STRIPE_TEST_WEBHOOK_SECRET,
    origin: origin.origin, authUrl: authUrl.origin, authKey: env.LUMA_AUTH_PUBLIC_KEY,
    ledgerUrl: ledgerUrl.origin, ledgerKey, testers, prices,
  };
}

// Public, local-only configuration check: no credentials/values/account IDs
// are returned and no Stripe, auth or database requests are made.
export function setupStatus(env) {
  const required = [
    'STRIPE_TEST_SECRET_KEY', 'STRIPE_TEST_WEBHOOK_SECRET',
    'CE_TEST_PORTAL_ORIGIN', 'LUMA_AUTH_SUPABASE_URL', 'LUMA_AUTH_PUBLIC_KEY',
    'CE_TEST_LEDGER_URL', 'CE_TEST_USER_IDS',
    ...Object.keys(PRODUCTS).map(code => `STRIPE_TEST_PRICE_${code.toUpperCase()}`),
  ];
  const status = {
    test_only: true,
    checkout_enabled: env.CE_STRIPE_TEST_ENABLED === 'true',
    configuration_ready: false,
    missing_settings: required.filter(name => !env[name]),
  };
  try {
    // Validate a copy; this never changes the real enable flag or starts a handler.
    configFrom({ ...env, CE_STRIPE_TEST_ENABLED: 'true' });
    return { ...status, configuration_ready: true };
  } catch (error) {
    return { ...status, issue: error instanceof Fault ? error.message : 'Invalid test configuration.' };
  }
}

// Reads the existing RLS-protected purchase ledger, not a client's claim.
// Unknown Google/other product mappings fail closed until independently verified.
export function existingOwnership(rows) {
  requireThat(Array.isArray(rows), 'Existing course ownership could not be verified.', 503);
  const courses = new Set();
  let used = 0;
  for (const row of rows) {
    requireThat(Number.isInteger(row.awarded_months) && row.awarded_months >= 0 &&
      row.awarded_months <= 3, 'Existing bonus history requires review.', 503);
    used += row.awarded_months; // Includes refunded/expired awards: no reset.
    if (row.revoked_at != null) continue;
    const product = row.store === 'APP_STORE'
      ? Object.values(PRODUCTS).find(x => x.apple === row.product_id) : null;
    requireThat(product, 'An existing store purchase needs mapping review. No new checkout was opened.', 409);
    product.courses.forEach(n => courses.add(n));
  }
  requireThat(used <= 3, 'Existing bonus history requires review.', 503);
  return { courses: [...courses], used };
}
export function checkOverlap(code, courses) {
  const target = PRODUCTS[code];
  requireThat(target, 'Unknown course.');
  const overlap = target.courses.filter(n => courses.includes(n));
  requireThat(overlap.length === 0,
    code === 'bundle' && overlap.length < 3
      ? 'You already own part of this bundle. Choose an unowned individual course; a bundle upgrade policy is not enabled.'
      : 'This course is already owned. Return to the course library.', 409);
}
export function validatePrice(price, code, config) {
  requireThat(price?.id === config.prices[code] && price.livemode === false &&
    price.active === true && price.type === 'one_time' && price.recurring == null &&
    price.currency === 'usd' && price.unit_amount === PRODUCTS[code].cents &&
    price.billing_scheme === 'per_unit' && !price.transform_quantity && !price.custom_unit_amount,
  'Test price verification failed.', 503);
}
export function checkoutPayload(order, config) {
  // Never accepts return URLs, amounts, prices, email identity or metadata from a browser.
  return {
    mode: 'payment', 'payment_method_types[0]': 'card',
    'line_items[0][price]': order.price_id, 'line_items[0][quantity]': '1',
    client_reference_id: order.user_id,
    'metadata[ce_test_order]': order.id, 'metadata[luma_user_id]': order.user_id,
    'metadata[integration]': 'ce-stripe-test-v1',
    'payment_intent_data[metadata][ce_test_order]': order.id,
    'payment_intent_data[metadata][luma_user_id]': order.user_id,
    'payment_intent_data[metadata][integration]': 'ce-stripe-test-v1',
    success_url: `${config.origin}/?ce_checkout=return#/ce-purchase`,
    cancel_url: `${config.origin}/?ce_checkout=cancel#/ce-purchase`,
    // Stripe requires at least 30 minutes from creation. An hour from reservation
    // leaves >35 minutes throughout our 25-minute creation/retry window.
    expires_at: String(Math.floor(Date.parse(order.created_at) / 1000) + 3600),
    'adaptive_pricing[enabled]': 'false',
  };
}
export function verifySession(session, order) {
  const lines = session?.line_items?.data;
  requireThat(session?.id?.startsWith('cs_test_') && session.livemode === false && session.mode === 'payment' &&
    session.client_reference_id === order.user_id &&
    session.metadata?.luma_user_id === order.user_id &&
    session.metadata?.ce_test_order === order.id &&
    session.metadata?.integration === 'ce-stripe-test-v1' &&
    session.currency === 'usd' && session.amount_total === order.amount &&
    lines?.length === 1 && session.line_items.has_more === false &&
    lines[0].quantity === 1 && lines[0].price?.id === order.price_id &&
    lines[0].price?.livemode === false &&
    (!order.session_id || order.session_id === session.id),
  'Session verification failed.', 409);
  return session.status === 'complete' && session.payment_status === 'paid';
}
export function verifyIntent(pi, order) {
  requireThat(pi && typeof pi === 'object' && pi.livemode === false &&
    pi.status === 'succeeded' && pi.amount === order.amount && pi.currency === 'usd' &&
    pi.metadata?.ce_test_order === order.id && pi.metadata?.luma_user_id === order.user_id &&
    pi.metadata?.integration === 'ce-stripe-test-v1', 'Payment verification failed.', 409);
  const charge = pi.latest_charge;
  requireThat(charge && typeof charge === 'object' && charge.livemode === false &&
    charge.paid === true && charge.payment_intent === pi.id,
  'Charge verification failed.', 409);
  // Any partial refund or dispute conservatively removes simulated ownership.
  return charge.refunded === true || charge.amount_refunded > 0 || charge.disputed === true;
}
export function safeCheckoutUrl(raw) {
  const url = new URL(raw);
  requireThat(url.protocol === 'https:' && url.hostname === 'checkout.stripe.com' &&
    !url.port && !url.username && !url.password, 'Unexpected checkout URL.', 503);
  return url.toString();
}

export function createHandler(config, deps) {
  const headers = {
    'Content-Type': 'application/json', 'Cache-Control': 'no-store',
    'Access-Control-Allow-Origin': config.origin, 'Vary': 'Origin',
    'Access-Control-Allow-Headers': 'authorization, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
  };
  const respond = (status, data) => new Response(JSON.stringify(data), { status, headers });
  async function current(request) {
    const token = request.headers.get('authorization');
    requireThat(/^Bearer \S+$/.test(token ?? ''), 'Sign in with your Luma account.', 401);
    const user = await deps.user(token);
    requireThat(user?.id && user.is_anonymous === false, 'Permanent sign-in required.', 401);
    requireThat(config.testers.has(user.id), 'This account is not enabled for Stripe testing.', 403);
    const existing = existingOwnership(await deps.existingPurchases(token, user.id));
    const orders = await deps.store.list(user.id);
    const testCourses = [...new Set(orders.filter(o => o.state === 'paid')
      .flatMap(o => PRODUCTS[o.product_code].courses))];
    return { user, existing, orders, testCourses };
  }
  async function settle(event) {
    requireThat(event.livemode === false && typeof event.id === 'string',
      'Only test events are accepted.');
    if (!['checkout.session.completed', 'checkout.session.async_payment_succeeded',
      'checkout.session.expired', 'charge.refunded', 'charge.dispute.created'].includes(event.type)) {
      return { ignored: true };
    }
    let order, session, pi;
    if (event.type.startsWith('checkout.session.')) {
      session = await deps.stripe.session(event.data.object.id);
      order = await deps.store.get(session.metadata?.ce_test_order);
      requireThat(order, 'Unknown test order.', 409);
      const paid = verifySession(session, order);
      if (session.status === 'expired') {
        await deps.store.apply(order.id, event.id, session.id, null, 'expired');
        return { expired: true };
      }
      if (!paid) return { pending: true };
      pi = typeof session.payment_intent === 'string'
        ? await deps.stripe.intent(session.payment_intent) : session.payment_intent;
    } else {
      // Never trust refund amount or metadata from the event alone.
      const object = event.data.object;
      const charge = await deps.stripe.charge(event.type === 'charge.refunded' ? object.id : object.charge);
      requireThat(charge.livemode === false, 'Live charge rejected.');
      pi = await deps.stripe.intent(charge.payment_intent);
      order = await deps.store.get(pi.metadata?.ce_test_order);
      if (!order) return { ignored: true }; // Other test payments in this account.
    }
    const revoked = verifyIntent(pi, order);
    if (!event.type.startsWith('checkout.session.') && !revoked) return { ignored: true };
    await deps.store.apply(order.id, event.id, session?.id ?? null, pi.id, revoked ? 'refunded' : 'paid');
    return { verified_test_payment: true, production_access_granted: false };
  }
  return async request => {
    try {
      const route = new URL(request.url).pathname.split('/').filter(Boolean).at(-1);
      if (route === 'webhook') {
        requireThat(request.method === 'POST', 'POST required.', 405);
        const raw = await request.text();
        requireThat(raw.length <= 262144, 'Event too large.', 413);
        const event = await deps.verifyEvent(raw, request.headers.get('stripe-signature'), config.webhookSecret);
        return respond(200, await settle(event));
      }
      requireThat(request.headers.get('origin') === config.origin, 'Origin not allowed.', 403);
      if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers });
      requireThat(request.method === 'POST', 'POST required.', 405);
      requireThat(['status', 'checkout'].includes(route), 'Not found.', 404);
      const state = await current(request);
      if (route === 'status') return respond(200, {
        test_only: true, user_id: state.user.id, existing_courses: state.existing.courses,
        test_courses: state.testCourses,
        orders: state.orders.map(o => ({
          product_code: o.product_code, state: o.state,
          simulated_bonus_months: o.simulated_bonus_months,
        })),
        products: Object.entries(PRODUCTS).map(([code, p]) => ({ code, amount: p.cents, currency: 'usd' })),
        production_access_granted: false,
      });
      const body = await request.json();
      requireThat(body && Object.keys(body).length === 1 && typeof body.product_code === 'string',
        'Only a product selection is accepted.');
      const code = body.product_code;
      checkOverlap(code, [...state.existing.courses, ...state.testCourses]);
      const price = await deps.stripe.price(config.prices[code]);
      validatePrice(price, code, config);
      const order = await deps.store.reserve(state.user.id, code, price.id, PRODUCTS[code].cents, state.existing.used);
      requireThat(order.user_id === state.user.id && order.product_code === code &&
        order.price_id === price.id && order.amount === PRODUCTS[code].cents,
      'Pending order does not match. Refresh test status.', 409);
      requireThat(order.state === 'pending', 'A payment is already recorded. Refresh test status.', 409);
      let session;
      if (order.session_id) {
        session = await deps.stripe.session(order.session_id);
        if (session.status !== 'open') {
          await settle({ id: `reconcile_${session.id}_${session.status}`, livemode: false,
            type: session.status === 'expired' ? 'checkout.session.expired' : 'checkout.session.completed',
            data: { object: { id: session.id } } });
          throw new Fault(409, 'Previous checkout was reconciled. Refresh test status before trying again.');
        }
      } else {
        requireThat(Date.parse(order.created_at) > Date.now() - 25 * 60000,
          'A stale checkout needs operator reconciliation; no second payment was opened.', 409);
        session = await deps.stripe.create(checkoutPayload(order, config), `ce-test-v1-${order.id}`);
      }
      requireThat(session.id?.startsWith('cs_test_') && session.livemode === false && session.status === 'open' &&
        session.client_reference_id === state.user.id && session.metadata?.ce_test_order === order.id,
      'Test checkout verification failed.', 503);
      // Retrieve with line items even after create: never redirect to an unverified price.
      const verified = await deps.stripe.session(session.id);
      verifySession(verified, order);
      requireThat(verified.status === 'open', 'Checkout state changed. Refresh test status.', 409);
      const url = safeCheckoutUrl(session.url);
      await deps.store.attach(order.id, session.id);
      return respond(200, { test_only: true, user_id: state.user.id, url });
    } catch (error) {
      return respond(error instanceof Fault ? error.status : 503, {
        error: error instanceof Fault ? error.message : 'Test checkout is unavailable. No access was granted.',
      });
    }
  };
}
