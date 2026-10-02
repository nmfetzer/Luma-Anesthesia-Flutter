import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHmac } from 'node:crypto';
import { configFrom, existingOwnership, checkOverlap, validatePrice, checkoutPayload,
  verifySession, verifyIntent, safeCheckoutUrl, createHandler, setupStatus, PRODUCTS } from '../server/core.mjs';
import { verifyEvent, adapters } from '../server/adapters.mjs';

const uid = '11111111-1111-4111-8111-111111111111';
const oid = '22222222-2222-4222-8222-222222222222';
const env = {
  CE_STRIPE_TEST_ENABLED: 'true', STRIPE_TEST_SECRET_KEY: 'sk_test_fixture_only',
  STRIPE_TEST_WEBHOOK_SECRET: 'whsec_fixture_only',
  CE_TEST_PORTAL_ORIGIN: 'https://private-preview.example',
  LUMA_AUTH_SUPABASE_URL: 'https://existing-auth.example',
  LUMA_AUTH_PUBLIC_KEY: 'sb_publishable_fixture',
  CE_TEST_LEDGER_URL: 'https://isolated-ledger.example',
  CE_TEST_LEDGER_SERVICE_KEY: 'test-fixture-not-a-real-key', CE_TEST_USER_IDS: uid,
  STRIPE_TEST_PRICE_MEDICATION: 'price_testMedication', STRIPE_TEST_PRICE_UNCOMMON: 'price_testUncommon',
  STRIPE_TEST_PRICE_LEGAL: 'price_testLegal', STRIPE_TEST_PRICE_BUNDLE: 'price_testBundle',
};
const config = configFrom(env);
const order = () => ({
  id: oid, user_id: uid, product_code: 'medication', price_id: config.prices.medication,
  amount: 24999, state: 'pending', created_at: new Date().toISOString(), session_id: null,
});
const price = () => ({
  id: config.prices.medication, livemode: false, active: true, type: 'one_time',
  recurring: null, currency: 'usd', unit_amount: 24999, billing_scheme: 'per_unit',
});
const intent = () => ({
  id: 'pi_fixture', livemode: false, status: 'succeeded', amount: 24999, currency: 'usd',
  metadata: { ce_test_order: oid, luma_user_id: uid, integration: 'ce-stripe-test-v1' },
  latest_charge: { id: 'ch_fixture', livemode: false, paid: true, payment_intent: 'pi_fixture',
    refunded: false, amount_refunded: 0, disputed: false },
});
const session = () => ({
  id: 'cs_test_fixture', livemode: false, mode: 'payment', client_reference_id: uid,
  metadata: { ce_test_order: oid, luma_user_id: uid, integration: 'ce-stripe-test-v1' },
  currency: 'usd', amount_total: 24999, payment_status: 'paid', status: 'complete',
  payment_intent: intent(),
  line_items: { has_more: false, data: [{ quantity: 1, price: price() }] },
});
function fixture() {
  const calls = [];
  const record = order();
  const deps = {
    user: async () => ({ id: uid, is_anonymous: false }),
    existingPurchases: async () => [],
    store: {
      list: async () => [], get: async () => record,
      reserve: async (...args) => { calls.push(['reserve', ...args]); return record; },
      attach: async (...args) => calls.push(['attach', ...args]),
      apply: async (...args) => calls.push(['apply', ...args]),
    },
    stripe: {
      price: async () => price(), session: async () => ({ ...session(), status: 'open', payment_status: 'unpaid' }),
      intent: async () => intent(), charge: async () => intent().latest_charge,
      create: async (body, key) => {
        calls.push(['create', body, key]);
        return { ...session(), status: 'open', payment_status: 'unpaid',
          url: 'https://checkout.stripe.com/c/pay/cs_test_fixture' };
      },
    },
    verifyEvent: async raw => JSON.parse(raw), // Signature tests separately exercise real HMAC.
  };
  return { calls, deps, record };
}
function request(path, body = {}, headers = {}) {
  return new Request(`https://test-backend.example/ce-stripe-test/${path}`, {
    method: 'POST', headers: { origin: config.origin, authorization: 'Bearer fixture',
      'Content-Type': 'application/json', ...headers }, body: JSON.stringify(body),
  });
}

test('disabled by default; no live keys, same-project ledger, or empty tester allowlist', () => {
  for (const patch of [
    { CE_STRIPE_TEST_ENABLED: undefined }, { STRIPE_TEST_SECRET_KEY: 'sk_live_no' },
    { CE_TEST_LEDGER_URL: env.LUMA_AUTH_SUPABASE_URL }, { CE_TEST_USER_IDS: '' },
    { CE_TEST_LEDGER_URL: 'https://xuckkusbbcxplpqclbxt.supabase.co' },
    { LUMA_AUTH_PUBLIC_KEY: 'sb_secret_not_allowed' },
    { CE_TEST_PORTAL_ORIGIN: 'https://private-preview.example/attacker/path' },
    { STRIPE_TEST_PRICE_MEDICATION: 'price_1UKH9BLbhEgJbqRtjRpHlVRq' },
    { STRIPE_TEST_PRICE_BUNDLE: env.STRIPE_TEST_PRICE_MEDICATION },
  ]) assert.throws(() => configFrom({ ...env, ...patch }));
});
test('live, recurring, inactive, wrong-price, or wrong-amount prices are denied', () => {
  validatePrice(price(), 'medication', config);
  for (const patch of [{ livemode: true }, { active: false }, { type: 'recurring' },
    { unit_amount: 1 }, { currency: 'eur' }, { id: 'price_other' },
    { recurring: { interval: 'month' } }, { transform_quantity: { divide_by: 2 } }]) {
    assert.throws(() => validatePrice({ ...price(), ...patch }, 'medication', config));
  }
});
test('Apple bundle is course ownership; refunds do not reset lifetime bonus budget', () => {
  assert.deepEqual(existingOwnership([
    { store: 'APP_STORE', product_id: PRODUCTS.bundle.apple, awarded_months: 2, revoked_at: null },
    { store: 'APP_STORE', product_id: PRODUCTS.medication.apple, awarded_months: 1, revoked_at: '2026-01-01' },
  ]), { courses: [1, 2, 3], used: 3 });
});
test('unknown store mapping and corrupt history fail closed', () => {
  assert.throws(() => existingOwnership([{ store: 'PLAY_STORE', product_id: 'unverified',
    awarded_months: 0, revoked_at: null }]));
  assert.throws(() => existingOwnership([{ awarded_months: 4, revoked_at: 'refunded' }]));
  assert.throws(() => existingOwnership(null));
});
test('same course and partial bundle repurchases are blocked; remaining course allowed', () => {
  assert.throws(() => checkOverlap('medication', [1]));
  assert.throws(() => checkOverlap('bundle', [1]), /part of this bundle/);
  assert.throws(() => checkOverlap('bundle', [1, 2, 3]), /already owned/);
  checkOverlap('uncommon', [1]);
});
test('checkout binds metadata and immutable server-selected price and return origin', () => {
  const body = checkoutPayload(order(), config);
  assert.equal(body.client_reference_id, uid);
  assert.equal(body['payment_intent_data[metadata][luma_user_id]'], uid);
  assert.equal(body['line_items[0][price]'], config.prices.medication);
  assert.equal(body['line_items[0][quantity]'], '1');
  assert.equal(body.mode, 'payment');
  assert.equal(body.success_url, `${config.origin}/?ce_checkout=return#/ce-purchase`);
  assert.equal(body['payment_method_types[0]'], 'card');
  const expiry = Number(body.expires_at) * 1000 - Date.now();
  assert.ok(expiry > 59 * 60000 && expiry <= 60 * 60000);
});
test('server revalidates exact session, price, account, amount, quantity and test mode', () => {
  assert.equal(verifySession(session(), order()), true);
  for (const patch of [{ livemode: true }, { client_reference_id: 'another' },
    { amount_total: 1 }, { currency: 'eur' }, { metadata: {} },
    { line_items: { data: [], has_more: false } },
    { line_items: { data: [{ quantity: 2, price: price() }], has_more: false } }]) {
    assert.throws(() => verifySession({ ...session(), ...patch }, order()));
  }
  assert.equal(verifySession({ ...session(), payment_status: 'unpaid' }, order()), false);
});
test('current payment and charge verified, partial refund or dispute revokes simulation', () => {
  assert.equal(verifyIntent(intent(), order()), false);
  assert.equal(verifyIntent({ ...intent(), latest_charge: { ...intent().latest_charge, amount_refunded: 1 } }, order()), true);
  assert.equal(verifyIntent({ ...intent(), latest_charge: { ...intent().latest_charge, disputed: true } }, order()), true);
  assert.throws(() => verifyIntent({ ...intent(), livemode: true }, order()));
  assert.throws(() => verifyIntent({ ...intent(), metadata: {} }, order()));
});
test('redirect allowlist rejects lookalike hosts, plaintext URLs and credentials', () => {
  for (const url of ['https://checkout.stripe.com.evil.test', 'http://checkout.stripe.com',
    'https://user:pass@checkout.stripe.com']) assert.throws(() => safeCheckoutUrl(url));
});
test('real signature verifier rejects altered payload, stale/future timestamp and missing signature', async () => {
  const now = Date.now(), t = Math.floor(now / 1000), body = '{"livemode":false}';
  const sign = (time, raw) => `t=${time},v1=${createHmac('sha256', 'whsec_fixture').update(`${time}.${raw}`).digest('hex')}`;
  assert.deepEqual(await verifyEvent(body, sign(t, body), 'whsec_fixture', now), { livemode: false });
  await assert.rejects(verifyEvent(`${body} `, sign(t, body), 'whsec_fixture', now));
  await assert.rejects(verifyEvent(body, sign(t - 301, body), 'whsec_fixture', now));
  await assert.rejects(verifyEvent(body, sign(t + 301, body), 'whsec_fixture', now));
  await assert.rejects(verifyEvent(body, null, 'whsec_fixture', now));
});
test('signed-out, anonymous, unapproved user and wrong origin never create checkout', async () => {
  for (const kind of ['signedout', 'anonymous', 'unapproved', 'origin']) {
    const f = fixture();
    if (kind === 'anonymous') f.deps.user = async () => ({ id: uid, is_anonymous: true });
    if (kind === 'unapproved') f.deps.user = async () => ({ id: oid, is_anonymous: false });
    const headers = kind === 'signedout' ? { authorization: '' }
      : kind === 'origin' ? { origin: 'https://evil.example' } : {};
    const response = await createHandler(config, f.deps)(request('checkout', { product_code: 'medication' }, headers));
    assert.ok([401, 403].includes(response.status));
    assert.equal(f.calls.length, 0);
  }
});
test('browser cannot supply account, price, amount or return URL', async () => {
  const f = fixture();
  const response = await createHandler(config, f.deps)(request('checkout', {
    product_code: 'medication', user_id: oid, price_id: 'price_live', return_url: 'https://evil.example',
  }));
  assert.equal(response.status, 400);
  assert.equal(f.calls.length, 0);
});
test('existing owned course blocks checkout before any Stripe write', async () => {
  const f = fixture();
  f.deps.existingPurchases = async () => [
    { store: 'APP_STORE', product_id: PRODUCTS.medication.apple, awarded_months: 1, revoked_at: null },
  ];
  const response = await createHandler(config, f.deps)(request('checkout', { product_code: 'medication' }));
  assert.equal(response.status, 409);
  assert.equal(f.calls.length, 0);
});
test('test checkout uses persistent order idempotency key and returns no secrets', async () => {
  const f = fixture();
  const response = await createHandler(config, f.deps)(request('checkout', { product_code: 'medication' }));
  assert.equal(response.status, 200);
  const data = await response.json();
  assert.deepEqual(data, { test_only: true, user_id: uid,
    url: 'https://checkout.stripe.com/c/pay/cs_test_fixture' });
  assert.equal(f.calls.find(x => x[0] === 'create')[2], `ce-test-v1-${oid}`);
});
test('checkout fails closed on Stripe live session response', async () => {
  const f = fixture();
  f.deps.stripe.create = async () => ({ ...session(), status: 'open', livemode: true });
  const response = await createHandler(config, f.deps)(request('checkout', { product_code: 'medication' }));
  assert.equal(response.status, 503);
  assert.equal(f.calls.filter(x => x[0] === 'attach').length, 0);
});
test('pending checkout is resumed rather than creating another session', async () => {
  const f = fixture();
  f.record.session_id = 'cs_test_fixture';
  f.deps.stripe.session = async () => ({ ...session(), status: 'open',
    payment_status: 'unpaid', url: 'https://checkout.stripe.com/c/pay/cs_test_fixture' });
  assert.equal((await createHandler(config, f.deps)(request('checkout', { product_code: 'medication' }))).status, 200);
  assert.equal(f.calls.filter(x => x[0] === 'create').length, 0);
});
test('status is read-only and never treats a success redirect as payment', async () => {
  const f = fixture();
  const response = await createHandler(config, f.deps)(request('status', { session_id: 'cs_test_fake', paid: true }));
  assert.equal(response.status, 200);
  const data = await response.json();
  assert.equal(data.production_access_granted, false);
  assert.deepEqual(data.test_courses, []);
  assert.equal(f.calls.length, 0);
});
test('webhook only records after paid session and intent revalidation', async () => {
  const f = fixture();
  f.deps.stripe.session = async () => session();
  const event = { id: 'evt_fixture', livemode: false, type: 'checkout.session.completed',
    data: { object: { id: 'cs_test_fixture' } } };
  const response = await createHandler(config, f.deps)(request('webhook', event));
  assert.equal(response.status, 200);
  assert.deepEqual(f.calls[0], ['apply', oid, 'evt_fixture', 'cs_test_fixture', 'pi_fixture', 'paid']);
});
test('unpaid and live webhook events grant nothing', async () => {
  const f = fixture();
  const event = { id: 'evt_unpaid', livemode: false, type: 'checkout.session.completed',
    data: { object: { id: 'cs_test_fixture' } } };
  f.deps.stripe.session = async () => ({ ...session(), payment_status: 'unpaid' });
  assert.equal((await createHandler(config, f.deps)(request('webhook', event))).status, 200);
  assert.equal(f.calls.length, 0);
  assert.equal((await createHandler(config, f.deps)(request('webhook', { ...event, livemode: true }))).status, 400);
});
test('refund before completion records terminal revocation with verified intent', async () => {
  const f = fixture();
  f.deps.stripe.intent = async () => ({ ...intent(),
    latest_charge: { ...intent().latest_charge, amount_refunded: 24999, refunded: true } });
  const response = await createHandler(config, f.deps)(request('webhook', {
    id: 'evt_refund', livemode: false, type: 'charge.refunded', data: { object: { id: 'ch_fixture' } },
  }));
  assert.equal(response.status, 200);
  assert.deepEqual(f.calls[0], ['apply', oid, 'evt_refund', null, 'pi_fixture', 'refunded']);
});
test('outbound adapter only writes isolated ledger or Stripe; auth backend is GET-only', async () => {
  const requests = [];
  const fakeFetch = async (url, options) => {
    requests.push({ url, ...options });
    if (url.includes('/luma_ce_bonus_purchases')) {
      return new Response('[]', { status: 200, headers: { 'Content-Range': '*/0' } });
    }
    return new Response('{}', { status: 200 });
  };
  const a = adapters(config, fakeFetch);
  await a.user('Bearer abc');
  await a.existingPurchases('Bearer abc', uid);
  await a.store.reserve(uid, 'medication', config.prices.medication, 24999, 0);
  await a.stripe.create(checkoutPayload(order(), config), 'fixture-idempotency');
  for (const r of requests.filter(r => r.url.startsWith(config.authUrl))) {
    assert.equal(r.method ?? 'GET', 'GET');
    assert.equal(r.headers.apikey, config.authKey);
    assert.notEqual(r.headers.apikey, config.ledgerKey);
  }
  assert.ok(requests[2].url.startsWith(config.ledgerUrl));
  assert.equal(requests[3].headers['Idempotency-Key'], 'fixture-idempotency');
});

test('truncated or uncounted purchase histories fail closed', async () => {
  for (const range of ['0-999/1001', null, '*/0']) {
    const a = adapters(config, async () => new Response('[{}]', {
      headers: range ? { 'Content-Range': range } : {},
    }));
    await assert.rejects(a.existingPurchases('Bearer fixture', uid), /Complete purchase history/);
  }
});

test('empty RPC responses are accepted without retrying a successful write', async () => {
  const a = adapters(config, async () => new Response(null, { status: 204 }));
  assert.equal(await a.store.attach(oid, 'cs_test_fixture'), null);
});

test('created and resumed checkouts must have the exact price and account before redirect', async () => {
  for (const resumed of [false, true]) {
    const f = fixture();
    if (resumed) f.record.session_id = 'cs_test_fixture';
    f.deps.stripe.session = async () => ({ ...session(), status: 'open', amount_total: 1 });
    const result = await createHandler(config, f.deps)(request('checkout', { product_code: 'medication' }));
    assert.equal(result.status, 409);
    assert.equal(f.calls.filter(x => x[0] === 'attach').length, 0);
  }
});

test('hosted runtime uses only its own project built-in server key', () => {
  const hosted = { ...env, CE_TEST_LEDGER_SERVICE_KEY: undefined,
    SUPABASE_URL: env.CE_TEST_LEDGER_URL,
    SUPABASE_SECRET_KEYS: JSON.stringify({ default: 'sb_secret_fixture' }) };
  assert.equal(configFrom(hosted).ledgerKey, 'sb_secret_fixture');
  assert.throws(() => configFrom({ ...hosted, SUPABASE_URL: 'https://another-project.example' }));
  assert.throws(() => configFrom({ ...hosted, SUPABASE_URL: env.LUMA_AUTH_SUPABASE_URL }));
});

test('legacy hosted key remains supported without manually copying it', () => {
  const hosted = { ...env, CE_TEST_LEDGER_SERVICE_KEY: undefined,
    SUPABASE_URL: env.CE_TEST_LEDGER_URL, SUPABASE_SERVICE_ROLE_KEY: 'legacy-fixture' };
  assert.equal(configFrom(hosted).ledgerKey, 'legacy-fixture');
  assert.throws(() => configFrom({ ...hosted, SUPABASE_SERVICE_ROLE_KEY: undefined }));
});

test('new database secret goes on apikey only; legacy retains bearer compatibility', async () => {
  for (const key of ['sb_secret_fixture', 'legacy-fixture']) {
    const a = adapters({ ...config, ledgerKey: key }, async (_url, options) => {
      assert.equal(options.headers.apikey, key);
      assert.equal(options.headers.Authorization, key.startsWith('sb_secret_') ? undefined : `Bearer ${key}`);
      return new Response('[]');
    });
    await a.store.list(uid);
  }
});

test('setup status validates without enabling checkout or returning secret values', () => {
  const disabled = { ...env, CE_STRIPE_TEST_ENABLED: 'false' };
  assert.deepEqual(setupStatus(disabled), {
    test_only: true, checkout_enabled: false, configuration_ready: true, missing_settings: [],
  });
  assert.equal(disabled.CE_STRIPE_TEST_ENABLED, 'false');
  assert.throws(() => configFrom(disabled));
  const absent = setupStatus({ ...disabled, STRIPE_TEST_SECRET_KEY: undefined,
    STRIPE_TEST_WEBHOOK_SECRET: undefined });
  assert.deepEqual(absent.missing_settings, ['STRIPE_TEST_SECRET_KEY', 'STRIPE_TEST_WEBHOOK_SECRET']);
  assert.equal(absent.configuration_ready, false);
  const serialized = JSON.stringify(setupStatus({ ...disabled, LUMA_AUTH_SUPABASE_URL: env.STRIPE_TEST_SECRET_KEY }));
  assert.equal(serialized.includes(env.STRIPE_TEST_SECRET_KEY), false);
  assert.equal(serialized.includes(env.STRIPE_TEST_WEBHOOK_SECRET), false);
  assert.equal(serialized.includes(env.CE_TEST_LEDGER_SERVICE_KEY), false);
});
