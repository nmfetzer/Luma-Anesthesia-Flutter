import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHandler, PRODUCTS, ORIGIN, PROJECT, INTEGRATION } from '../server/core.mjs';
import { adapters } from '../server/adapters.mjs';

const uid = '11111111-1111-4111-8111-111111111111';
function fixture(mode = 'expire', same = false) {
  const calls = [];
  const old = { id: 'old-order', user_id: uid, product_code: 'medication',
    price_id: PRODUCTS.medication.price, amount: 24999, state: 'pending',
    session_id: 'cs_live_old', created_at: new Date().toISOString() };
  const next = { ...old, id: 'new-order', product_code: 'uncommon',
    price_id: PRODUCTS.uncommon.price, session_id: null };
  let stripeStatus = 'open';
  const session = (o, status, id) => ({
    id, status, livemode: true, mode: 'payment',
    payment_status: status === 'complete' ? 'paid' : 'unpaid',
    client_reference_id: uid, currency: 'usd', amount_total: o.amount,
    metadata: { integration: INTEGRATION, ce_order: o.id, luma_user_id: uid },
    line_items: { has_more: false, data: [{ quantity: 1, price: { id: o.price_id, livemode: true } }] },
    payment_intent: { id: 'pi_old', status: 'succeeded', livemode: true,
      amount: o.amount, amount_received: o.amount, currency: 'usd',
      metadata: { integration: INTEGRATION, ce_order: o.id, luma_user_id: uid },
      latest_charge: { paid: true, livemode: true, amount: o.amount, currency: 'usd',
        payment_intent: 'pi_old', created: Math.floor(Date.now() / 1000) } },
    url: 'https://checkout.stripe.com/c/pay/fixture',
  });
  const code = same ? 'medication' : 'uncommon';
  const deps = {
    user: async () => ({ id: uid, is_anonymous: false }),
    store: {
      state: async () => ({ user_id: uid, orders: old.state === 'pending' ? [old] : [],
        existing_courses: [], products: [{ code, enabled: true }] }),
      get: async () => old,
      reserve: async () => {
        calls.push('reserve');
        assert.ok(same || old.state === 'expired', 'must close old session and reservation first');
        return same ? old : next;
      },
      apply: async (...args) => { calls.push(args[4]); old.state = args[4]; },
      attach: async () => { calls.push('attach'); },
    },
    stripe: {
      price: async () => ({ id: PRODUCTS[code].price, product: PRODUCTS[code].stripeProduct,
        active: true, livemode: true, type: 'one_time', currency: 'usd',
        unit_amount: 24999, billing_scheme: 'per_unit' }),
      session: async id => id === 'cs_live_old' ? session(old, stripeStatus, id)
        : session(next, 'open', id),
      expire: async () => {
        calls.push('expire');
        if (mode === 'failure') throw new Error('permission denied');
        stripeStatus = mode === 'paid-race' ? 'complete' : 'expired';
        if (mode === 'timeout-after-expire') throw new Error('timeout');
      },
      create: async () => { calls.push('create'); return session(next, 'open', 'cs_live_new'); },
    },
  };
  const request = () => new Request(`${PROJECT}/functions/v1/ce-stripe-live/checkout`, {
    method: 'POST', headers: { Origin: ORIGIN, Authorization: 'Bearer fixture', 'Content-Type': 'application/json' },
    body: JSON.stringify({ product_code: code }),
  });
  return { calls, deps, request, old };
}
test('switching course expires unpaid session before reserving or opening another', async () => {
  const f = fixture();
  const r = await createHandler({ enabled: true }, f.deps)(f.request());
  assert.equal(r.status, 200);
  assert.deepEqual(f.calls, ['expire', 'expired', 'reserve', 'create', 'attach']);
});
test('same course resumes original checkout without expiration or a second create', async () => {
  const f = fixture('expire', true);
  const r = await createHandler({ enabled: true }, f.deps)(f.request());
  assert.equal(r.status, 200);
  assert.deepEqual(f.calls, ['reserve', 'attach']);
});
test('failed expiration leaves reservation intact and starts no new checkout', async () => {
  const f = fixture('failure');
  const r = await createHandler({ enabled: true }, f.deps)(f.request());
  assert.equal(r.status, 409);
  assert.equal(f.old.state, 'pending');
  assert.deepEqual(f.calls, ['expire']);
});
test('expiration timeout is safe when Stripe readback proves expired', async () => {
  const f = fixture('timeout-after-expire');
  const r = await createHandler({ enabled: true }, f.deps)(f.request());
  assert.equal(r.status, 200);
  assert.deepEqual(f.calls, ['expire', 'expired', 'reserve', 'create', 'attach']);
});
test('payment finishing during switch is reconciled, never followed by another checkout', async () => {
  const f = fixture('paid-race');
  const r = await createHandler({ enabled: true }, f.deps)(f.request());
  assert.equal(r.status, 409);
  assert.deepEqual(f.calls, ['expire', 'paid']);
  assert.match((await r.json()).error, /previous checkout completed/);
});
test('order identity mismatch cannot expire somebody else’s checkout', async () => {
  const f = fixture();
  f.deps.store.get = async () => ({ ...f.old, user_id: 'other-user' });
  assert.equal((await createHandler({ enabled: true }, f.deps)(f.request())).status, 409);
  assert.deepEqual(f.calls, []);
});
test('missing attached session stays blocked for reconciliation, not silently released', async () => {
  const f = fixture();
  f.old.session_id = null;
  assert.equal((await createHandler({ enabled: true }, f.deps)(f.request())).status, 409);
  assert.deepEqual(f.calls, []);
});
test('adapter returns safe conflict text without raw database details', async () => {
  const config = { ledgerUrl: PROJECT, ledgerKey: 'sb_secret_fixture' };
  const pending = adapters(config, async () => new Response(JSON.stringify({
    code: 'P0001', message: 'Resolve pending checkout first', details: 'private database data',
  }), { status: 400 }));
  await assert.rejects(pending.store.reserve(uid, 'uncommon'),
    e => e.status === 409 && !e.message.includes('private') && e.message.includes('Another checkout'));
});
test('expiration adapter sends only an authenticated idempotent Stripe POST', async () => {
  const requests = [];
  const a = adapters({ stripeKey: 'rk_live_fixture' }, async (url, options) => {
    requests.push({ url, options });
    return new Response(JSON.stringify({ status: 'expired' }));
  });
  await a.stripe.expire('cs_live_old');
  assert.equal(requests[0].url, 'https://api.stripe.com/v1/checkout/sessions/cs_live_old/expire');
  assert.equal(requests[0].options.method, 'POST');
  assert.equal(requests[0].options.headers['Idempotency-Key'], 'ce-live-switch-cs_live_old');
});
