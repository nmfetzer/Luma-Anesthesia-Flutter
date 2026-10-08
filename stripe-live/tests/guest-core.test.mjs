import {test} from 'node:test';
import assert from 'node:assert/strict';
import {GUEST,CATALOG_PREVIEW,guestPayload,verifyGuestSession,verifyGuestIntent,requireFreshEmailProof,createGuest} from '../server/guest.mjs';
import {PRODUCTS,PROJECT,ORIGIN} from '../server/core.mjs';
const id='11111111-1111-4111-8111-111111111111';
const o={id,product_code:'legal',price_id:PRODUCTS.legal.price,amount:24999,created_at:new Date().toISOString()};
const metadata={integration:GUEST,guest_order:id};
const s={id:'cs_live_fixture',livemode:true,mode:'payment',client_reference_id:id,metadata,currency:'usd',amount_total:24999,
  line_items:{has_more:false,data:[{quantity:1,price:{id:o.price_id,livemode:true}}]},status:'complete',payment_status:'paid'};
const pi={id:'pi_fixture',livemode:true,status:'succeeded',amount:24999,amount_received:24999,currency:'usd',metadata,
  latest_charge:{livemode:true,paid:true,amount:24999,currency:'usd',payment_intent:'pi_fixture',created:Math.floor(Date.now()/1000)}};
test('guest payload fixes price and return origin without inventing a learner identity',()=>{
  const p=guestPayload(o);
  assert.equal(p.client_reference_id,id);assert.equal(p['line_items[0][price]'],o.price_id);
  assert.equal(p.customer_email,undefined);assert.equal(p['metadata[luma_user_id]'],undefined);
  assert.ok(p.success_url.startsWith(ORIGIN));assert.equal(p.mode,'payment');
});
test('guest paid verification fails closed on amount, integration, session and intent identity',()=>{
  assert.equal(verifyGuestSession(s,o),true);assert.equal(verifyGuestIntent(pi,o).state,'paid');
  assert.throws(()=>verifyGuestSession({...s,amount_total:1},o));
  assert.throws(()=>verifyGuestSession({...s,metadata:{integration:'other',guest_order:id}},o));
  assert.throws(()=>verifyGuestSession(s,{...o,session_id:'cs_live_other'}));
  assert.throws(()=>verifyGuestIntent({...pi,amount_received:1},o));
  assert.throws(()=>verifyGuestIntent(pi,{...o,payment_intent:'pi_other'}));
  assert.equal(verifyGuestIntent({...pi,latest_charge:{...pi.latest_charge,disputed:true}},o).state,'refunded');
});
const user={id,email:'learner@example.test',is_anonymous:false,email_confirmed_at:new Date().toISOString()};
const now=Math.floor(Date.now()/1000);
const claims={sub:id,iss:`${PROJECT}/auth/v1`,aud:'authenticated',exp:now+3600,session_id:'fixture',
  amr:[{method:'otp',timestamp:now}]};
const token=c=>`Bearer header.${Buffer.from(JSON.stringify(c)).toString('base64url')}.validated-by-auth-before-use`;
test('fresh email proof rejects password/signup, expired proof and mismatched identities',()=>{
  requireFreshEmailProof(token(claims),user);
  for(const method of ['password','email/signup','token_refresh'])assert.throws(()=>requireFreshEmailProof(token({...claims,amr:[{method,timestamp:now}]}),user));
  assert.throws(()=>requireFreshEmailProof(token({...claims,amr:[{method:'otp',timestamp:now-3601}]}),user));
  assert.throws(()=>requireFreshEmailProof(token(claims),{...user,id:'other'}));
  assert.throws(()=>requireFreshEmailProof(token(claims),{...user,email_confirmed_at:null}));
});
test('guest server rejects arbitrary origins before touching payment or auth',async()=>{
  const g=createGuest({enabled:true},{});
  const r=await g.handle(new Request(`${PROJECT}/functions/v1/ce-stripe-live/guest-checkout`,{
    method:'POST',headers:{Origin:'https://attacker.example'},body:'{}'}));
  assert.equal(r.status,403);
});
test('guest activation validates the token at Auth before trusting its AMR',async()=>{
  let called=false;
  const g=createGuest({}, {user:async()=>{called=true;throw new Error('Invalid signature');}});
  const r=await g.handle(new Request(`${PROJECT}/functions/v1/ce-stripe-live/guest-list`,{
    method:'POST',headers:{Origin:ORIGIN,Authorization:token(claims)},body:'{}'}));
  assert.equal(called,true);assert.notEqual(r.status,200);
});
test('immutable deployment can only inspect catalog, never start or claim a payment',async()=>{
  const g=createGuest({enabled:true},{guestStore:{catalog:async()=>({enabled:true,products:[]})}});
  const request=route=>new Request(`${PROJECT}/functions/v1/ce-stripe-live/${route}`,{
    method:'POST',headers:{Origin:CATALOG_PREVIEW},body:'{}'});
  const catalog=await g.handle(request('guest-catalog'));
  assert.equal(catalog.status,200);
  assert.equal(catalog.headers.get('Access-Control-Allow-Origin'),CATALOG_PREVIEW);
  assert.equal((await catalog.json()).enabled,false);
  for(const route of ['guest-checkout','guest-list','guest-claim'])
    assert.equal((await g.handle(request(route))).status,403);
  const another=await g.handle(new Request(`${PROJECT}/functions/v1/ce-stripe-live/guest-catalog`,{
    method:'POST',headers:{Origin:'https://other--mellifluous-tartufo-a5c6b2.netlify.app'},body:'{}'}));
  assert.equal(another.status,403);
});
