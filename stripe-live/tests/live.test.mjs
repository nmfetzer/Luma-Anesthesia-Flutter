import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { configFrom, setupStatus, PRODUCTS, validatePrice, checkoutPayload,
  verifySession, verifyIntent, createHandler, ORIGIN, PROJECT, INTEGRATION } from '../server/core.mjs';
const { PGlite } = await import(process.env.PGLITE_MODULE || '@electric-sql/pglite');
const uid = '11111111-1111-4111-8111-111111111111';
const read = path => readFile(new URL(path, import.meta.url), 'utf8');
let db;
before(async () => {
  db = new PGlite();
  await db.exec(`create role anon; create role authenticated; create role service_role;
    create schema auth; create schema luma_review;
    create table auth.users(id uuid primary key,is_anonymous boolean);
    create function auth.uid() returns uuid language sql as $$ select '${uid}'::uuid $$;
    insert into auth.users values('${uid}',false);`);
  const initial = await read('../../supabase/migrations/20260925030000_ce_bonus_access.sql');
  await db.exec(initial.split('CREATE FUNCTION public.has_clinical_premium_access()')[0]);
  const cap = await read('../../supabase/migrations/20260927154627_ce_bonus_three_month_cap.sql');
  await db.exec(`begin; ${cap.split('CREATE OR REPLACE FUNCTION public.has_clinical_premium_access()')[0]} commit;`);
  for (let n = 1; n <= 3; n++) await db.exec(`
    create table public.ce_course${n}_catalog(id text primary key,released boolean,metadata jsonb);
    create table public.ce_course${n}_certificate_settings(course_id text,enabled boolean,approved_at timestamptz,signature_png_base64 text);
    create table public.ce_course${n}_store_products(store text check(store in ('APP_STORE','PLAY_STORE')),product_id text,primary key(store,product_id));
    insert into public.ce_course${n}_catalog values('${n}',true,'${JSON.stringify({ modules: Array(n === 1 ? 11 : n === 2 ? 10 : 1).fill({}) })}');
    insert into public.ce_course${n}_certificate_settings values('${n}',true,now(),'fixture-not-real-signature');`);
  for (const p of Object.values(PRODUCTS)) {
    await db.query("insert into public.luma_ce_bonus_products values('APP_STORE',$1,$2,true)",[p.product,p.courses.length === 3 ? 3 : 1]);
    for (const n of p.courses) await db.query(`insert into public.ce_course${n}_store_products values('APP_STORE',$1)`,[p.product]);
  }
  const native = await read('../../supabase/migrations/20260927193822_apple_purchase_wiring.sql');
  await db.exec(native.slice(native.indexOf('CREATE FUNCTION public.luma_ce_checkout_status()'),
    native.indexOf('REVOKE ALL ON FUNCTION public.luma_ce_checkout_status()'))
    .replace('CREATE FUNCTION public.luma_ce_checkout_status()', 'CREATE FUNCTION luma_review.luma_ce_checkout_status()'));
  await db.exec(await read('../schema.sql'));
});
after(async () => db?.close());
beforeEach(async () => {
  await db.exec(`truncate ce_stripe_live.events,ce_stripe_live.orders,public.luma_ce_bonus_purchases,public.luma_ce_bonus_refunds;
    update public.ce_course1_certificate_settings set enabled=true;`);
});
async function reserve(code='medication') {
  return (await db.query('select public.ce_stripe_live_reserve($1,$2) v',[uid,code])).rows[0].v;
}
async function apply(o,state='paid',event=`evt_${o.id}_${state}`) {
  await db.query('select public.ce_stripe_live_apply($1,$2,$3,$4,$5,$6)',[
    o.id,event,`cs_live_${o.id}`,state === 'expired' ? null : `pi_${o.id}`,state,
    state === 'expired' ? null : o.created_at]);
}
async function owned() { return (await db.query('select ce_stripe_live.owned($1) v',[uid])).rows[0].v; }
test('configuration rejects sandbox credentials and a different Supabase project', () => {
  const e = {SUPABASE_URL:PROJECT,SUPABASE_SERVICE_ROLE_KEY:'fixture',
    CE_STRIPE_LIVE_SECRET_KEY:'sk_live_fixture',CE_STRIPE_LIVE_WEBHOOK_SECRET:'whsec_fixture'};
  assert.equal(configFrom(e).enabled,false);
  assert.throws(()=>configFrom({...e,CE_STRIPE_LIVE_SECRET_KEY:'sk_test_fixture'}));
  assert.throws(()=>configFrom({...e,SUPABASE_URL:'https://other.supabase.co'}));
  assert.equal(setupStatus({}).checkout_enabled,false);
});
test('price and payment validation require live identity, exact amount and course', () => {
  const p=PRODUCTS.medication;
  const price={id:p.price,product:p.stripeProduct,livemode:true,active:true,type:'one_time',currency:'usd',unit_amount:p.cents,billing_scheme:'per_unit'};
  validatePrice(price,'medication');
  assert.throws(()=>validatePrice({...price,livemode:false},'medication'));
  assert.throws(()=>validatePrice({...price,unit_amount:1},'medication'));
  const o={id:'order',user_id:uid,price_id:p.price,amount:p.cents,created_at:new Date().toISOString()};
  const s={id:'cs_live_fixture',livemode:true,mode:'payment',client_reference_id:uid,
    metadata:{integration:INTEGRATION,ce_order:o.id,luma_user_id:uid},currency:'usd',amount_total:p.cents,
    line_items:{data:[{quantity:1,price:{id:p.price,livemode:true}}],has_more:false},status:'complete',payment_status:'paid'};
  assert.equal(verifySession(s,o),true);
  assert.throws(()=>verifySession({...s,client_reference_id:'someone-else'},o));
  const pi={id:'pi_fixture',livemode:true,status:'succeeded',amount:p.cents,amount_received:p.cents,
    currency:'usd',metadata:s.metadata,latest_charge:{livemode:true,paid:true,amount:p.cents,currency:'usd',
      payment_intent:'pi_fixture',created:Math.floor(Date.now()/1000)}};
  assert.equal(verifyIntent(pi,o).revoked,false);
  assert.equal(verifyIntent({...pi,latest_charge:{...pi.latest_charge,amount_refunded:1}},o).revoked,true);
  assert.throws(()=>verifyIntent({...pi,amount_received:0},o));
  const payload=checkoutPayload(o);
  assert.equal(payload.client_reference_id,uid);
  assert.equal(payload.success_url,`${ORIGIN}/?ce_checkout=return#/ce-purchase`);
  assert.equal(payload.mode,'payment');
});
test('live SQL idempotent fulfillment shares ownership and native owned flag', async () => {
  const o=await reserve(); await apply(o); await apply(o); await apply(o,'paid','evt_second');
  assert.deepEqual(await owned(),[1]);
  const rows=(await db.query('select * from public.luma_ce_bonus_purchases')).rows;
  assert.equal(rows.length,1); assert.equal(rows[0].store,'STRIPE'); assert.equal(rows[0].awarded_months,1);
  const native=(await db.query('select luma_review.luma_ce_checkout_status() v')).rows[0].v;
  assert.equal(native.products.find(p=>p.product_id===PRODUCTS.medication.product).owned,true);
});
test('Apple ownership blocks duplicate website course and overlapping bundle', async () => {
  await db.query("select public.record_verified_ce_bonus('APP_STORE','apple-fixture',$1,$2,now())",[PRODUCTS.medication.product,uid]);
  await assert.rejects(reserve(),/Already owned/);
  await assert.rejects(reserve('bundle'),/overlapping/);
  const o=await reserve('legal'); await apply(o);
  assert.equal((await db.query("select awarded_months from public.luma_ce_bonus_purchases where store='STRIPE'")).rows[0].awarded_months,0);
});
test('refund before completion never reopens access and retains lifetime cap', async () => {
  const o=await reserve(); await apply(o,'refunded'); await apply(o);
  assert.deepEqual(await owned(),[]);
  const b=await reserve('bundle'); await apply(b);
  assert.equal((await db.query("select awarded_months from public.luma_ce_bonus_purchases where product_id=$1",[PRODUCTS.bundle.product])).rows[0].awarded_months,2);
  await apply(b,'refunded');
  const next=await reserve('legal'); await apply(next);
  assert.equal((await db.query("select sum(awarded_months)::int n from public.luma_ce_bonus_purchases")).rows[0].n,3);
});
test('only one pending checkout per account, expiry permits retry without granting', async () => {
  const o=await reserve(); assert.equal((await reserve()).id,o.id);
  await assert.rejects(reserve('legal'),/pending checkout/);
  await apply(o,'expired'); assert.deepEqual(await owned(),[]);
  assert.notEqual((await reserve()).id,o.id);
});
test('course certificate gate fails closed without changing release settings', async () => {
  await db.exec('update public.ce_course1_certificate_settings set enabled=false');
  await assert.rejects(reserve(),/not ready/);
  await assert.rejects(reserve('bundle'),/not ready/);
  assert.equal((await reserve('legal')).product_code,'legal');
});
test('anonymous and authenticated users cannot call privileged payment functions', async () => {
  for(const role of ['anon','authenticated']) {
    await db.exec(`set role ${role}`);
    await assert.rejects(reserve(),/permission denied/);
    await assert.rejects(db.query('select * from ce_stripe_live.orders'),/permission denied/);
    await db.exec('reset role');
  }
});
test('disabled checkout rejects purchases but still acknowledges authenticated webhooks', async () => {
  const deps={user:async()=>({id:uid,is_anonymous:false}),
    store:{state:async()=>({user_id:uid,orders:[],existing_courses:[],products:[]})},
    verifyEvent:async()=>({id:'evt_ignored',livemode:true,type:'ignored'})};
  const handler=createHandler({enabled:false},deps);
  const r=await handler(new Request(`${PROJECT}/checkout`,{method:'POST',
    headers:{Origin:ORIGIN,Authorization:'Bearer fixture','Content-Type':'application/json'},
    body:JSON.stringify({product_code:'medication'})}));
  assert.equal(r.status,503);
  assert.equal((await handler(new Request(`${PROJECT}/webhook`,{method:'POST',body:'{}'}))).status,200);
  assert.equal((await handler(new Request(`${PROJECT}/status`,{method:'POST',headers:{Origin:'https://evil.example'}}))).status,403);
});
