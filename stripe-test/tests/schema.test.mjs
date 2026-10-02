import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

const { PGlite } = await import(process.env.PGLITE_MODULE || '@electric-sql/pglite');
let db;
const uid = '11111111-1111-4111-8111-111111111111';
before(async () => {
  db = new PGlite();
  await db.exec('create role anon; create role authenticated; create role service_role;');
  await db.exec(await readFile(new URL('../draft-schema.sql', import.meta.url), 'utf8'));
});
beforeEach(async () => {
  await db.exec('truncate ce_stripe_test.events, ce_stripe_test.orders;');
});
after(async () => { await db.close(); });
async function reserve(code = 'medication', baseline = 0) {
  const { rows } = await db.query(
    'select public.ce_stripe_test_reserve($1,$2,$3,$4,$5) as value',
    [uid, code, `price_${code}`, code === 'bundle' ? 69999 : 24999, baseline]);
  return rows[0].value;
}
async function apply(order, event, state, session = `cs_test_${order.id}`, intent = `pi_${order.id}`) {
  return db.query('select public.ce_stripe_test_apply($1,$2,$3,$4,$5)',
    [order.id, event, session, intent, state]);
}
async function get(order) {
  const { rows } = await db.query('select public.ce_stripe_test_get($1) as value', [order.id]);
  return rows[0].value;
}
test('SQL reserves once and blocks simultaneous different-product checkout', async () => {
  const a = await reserve(), b = await reserve();
  assert.equal(a.id, b.id);
  await assert.rejects(reserve('legal'), /pending test checkout/);
});
test('SQL session attach accepts test IDs only and rejects reassignment', async () => {
  const o = await reserve();
  await assert.rejects(db.query('select public.ce_stripe_test_attach($1,$2)', [o.id, 'cs_live_bad']));
  await db.query('select public.ce_stripe_test_attach($1,$2)', [o.id, 'cs_test_one']);
  await assert.rejects(db.query('select public.ce_stripe_test_attach($1,$2)', [o.id, 'cs_test_two']));
});
test('SQL duplicate events and distinct completion events never double-award', async () => {
  const o = await reserve();
  await apply(o, 'evt_one', 'paid');
  await apply(o, 'evt_one', 'paid');
  await apply(o, 'evt_two', 'paid');
  assert.equal((await get(o)).simulated_bonus_months, 1);
  assert.equal((await get(o)).state, 'paid');
  const { rows } = await db.query('select count(*)::int as n from ce_stripe_test.events');
  assert.equal(rows[0].n, 2);
});
test('SQL paid overlap denies same course or overlapping bundle', async () => {
  const o = await reserve(); await apply(o, 'evt_paid', 'paid');
  await assert.rejects(reserve(), /ownership overlaps/);
  await assert.rejects(reserve('bundle'), /ownership overlaps/);
  const next = await reserve('legal'); await apply(next, 'evt_legal', 'paid');
  assert.equal((await get(next)).simulated_bonus_months, 0);
});
test('SQL full bundle grants only three simulated months; refund does not reset', async () => {
  const o = await reserve('bundle'); await apply(o, 'evt_bundle', 'paid');
  assert.equal((await get(o)).simulated_bonus_months, 3);
  await apply(o, 'evt_refund', 'refunded');
  const next = await reserve('medication'); await apply(next, 'evt_next', 'paid');
  assert.equal((await get(next)).simulated_bonus_months, 0);
});
test('SQL respects real historical bonus baseline without writing real grants', async () => {
  const o = await reserve('bundle', 1); await apply(o, 'evt_bundle', 'paid');
  assert.equal((await get(o)).simulated_bonus_months, 2);
  assert.equal((await db.query("select to_regclass('public.luma_ce_bonus_purchases') as r")).rows[0].r, null);
});
test('SQL refund before completion cannot resurrect access or reset award budget', async () => {
  const o = await reserve();
  await apply(o, 'evt_refund_first', 'refunded', null);
  await apply(o, 'evt_paid_late', 'paid');
  assert.equal((await get(o)).state, 'refunded');
  assert.equal((await get(o)).simulated_bonus_months, 1);
  const next = await reserve('bundle'); await apply(next, 'evt_bundle', 'paid');
  assert.equal((await get(next)).simulated_bonus_months, 2);
});
test('SQL expiry grants nothing; late expiry cannot remove verified payment', async () => {
  const o = await reserve();
  await apply(o, 'evt_expire', 'expired', `cs_test_${o.id}`, null);
  assert.equal((await get(o)).simulated_bonus_months, 0);
  const next = await reserve(); await apply(next, 'evt_paid', 'paid');
  await apply(next, 'evt_late_expire', 'expired', `cs_test_${next.id}`, null);
  assert.equal((await get(next)).state, 'paid');
  assert.equal((await get(next)).simulated_bonus_months, 1);
});
test('SQL ledger and RPC are inaccessible to anonymous/authenticated roles', async () => {
  for (const role of ['anon', 'authenticated']) {
    await db.exec(`set role ${role}`);
    await assert.rejects(db.query('select public.ce_stripe_test_list($1)', [uid]), /permission denied/);
    await assert.rejects(db.query('select * from ce_stripe_test.orders'), /permission denied/);
    await db.exec('reset role');
  }
});
test('SQL can execute through service role only; returns account-scoped list', async () => {
  const o = await reserve();
  await db.exec('set role service_role');
  const { rows } = await db.query('select public.ce_stripe_test_list($1) as value', [uid]);
  assert.equal(rows[0].value.length, 1);
  assert.equal(rows[0].value[0].id, o.id);
  await db.exec('reset role');
});
test('SQL cannot be installed over a production-shaped database', async () => {
  const isolated = new PGlite();
  try {
    await isolated.exec('create role anon; create role authenticated; create role service_role; create table public.luma_ce_bonus_purchases(id int);');
    await assert.rejects(isolated.exec(await readFile(new URL('../draft-schema.sql', import.meta.url), 'utf8')),
      /never install Stripe test ledger/);
  } finally { await isolated.close(); }
});
