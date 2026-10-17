import test from 'node:test';
import assert from 'node:assert/strict';
import {createWorkspace,act} from './core.mjs';
const now=1000000;
const setup=(product='medication',email='learner@example.test')=>{const w=createWorkspace(now);act(w,'checkout',{product,email,name:'Alex Sample',ack:true},now);return w;};
const pay=w=>act(w,'payment',{orderId:w.lastOrder,result:'success'},now);
const verify=(w,email='learner@example.test')=>{act(w,'request-code',{email},now);return act(w,'verify',{code:w.challenge.code},now);};
const profile=w=>act(w,'profile',{first:'Alex',last:'Sample',profession:'CRNA',accept:true},now);
test('purchase before account exists; no entitlement before verification and profile',()=>{
 const w=setup();assert.equal(w.accounts['learner@example.test'],undefined);pay(w);
 assert.throws(()=>act(w,'claim',{orderId:w.lastOrder},now),/Verify/);verify(w);
 assert.throws(()=>act(w,'claim',{orderId:w.lastOrder},now),/profile/);profile(w);
 act(w,'claim',{orderId:w.lastOrder},now);assert.deepEqual(w.accounts['learner@example.test'].courses,[1]);
});
test('duplicate payment and activation are idempotent',()=>{
 const w=setup('bundle');pay(w);pay(w);assert.equal(w.outbox.length,1);verify(w);profile(w);
 act(w,'claim',{orderId:w.lastOrder},now);act(w,'claim',{orderId:w.lastOrder},now);
 assert.deepEqual(w.accounts['learner@example.test'].courses,[1,2,3]);
});
test('verified returning learner retains account identity and course progress',()=>{
 const w=setup('uncommon','returning@example.test'),id=w.accounts['returning@example.test'].id;pay(w);verify(w,'returning@example.test');
 act(w,'claim',{orderId:w.lastOrder},now);assert.equal(w.accounts['returning@example.test'].id,id);
 assert.deepEqual(w.accounts['returning@example.test'].courses,[1,2]);assert.equal(w.accounts['returning@example.test'].progress[1],38);
});
test('unpaid or processing orders cannot be claimed',()=>{
 const w=setup();verify(w);profile(w);assert.throws(()=>act(w,'claim',{orderId:w.lastOrder},now),/Payment/);
 act(w,'payment',{orderId:w.lastOrder,result:'delayed'},now);
 assert.throws(()=>act(w,'claim',{orderId:w.lastOrder},now),/Payment/);
});
test('wrong email cannot claim a paid order',()=>{
 const w=setup();pay(w);verify(w,'someone@example.test');profile(w);
 assert.throws(()=>act(w,'claim',{orderId:w.lastOrder},now),/same email/);
});
test('wrong expired and reused codes fail',()=>{
 const w=setup();act(w,'request-code',{email:'learner@example.test'},now);const code=w.challenge.code;
 assert.throws(()=>act(w,'verify',{code:'000000'},now),/incorrect/);
 assert.throws(()=>act(w,'verify',{code},now+300001),/expired/);
 verify(w);assert.throws(()=>act(w,'verify',{code},now),/missing/);
});
test('resend invalidates old challenge; five wrong attempts lock challenge',()=>{
 const w=setup();act(w,'request-code',{email:'learner@example.test'},now);
 for(let i=0;i<5;i++)assert.throws(()=>act(w,'verify',{code:'000000'},now),/incorrect/);
 assert.throws(()=>act(w,'verify',{code:w.challenge.code},now),/Too many/);
 verify(w);assert.ok(w.session);
});
test('test-only addresses enforced; caller cannot choose price or entitlement',()=>{
 assert.throws(()=>setup('medication','real@gmail.com'),/fictional/);
 assert.throws(()=>setup('invented'),/valid course/);
 const w=createWorkspace(now);act(w,'checkout',{product:'medication',email:'x@example.test',name:'Fake Name',ack:true,cents:1,courses:[1,2,3]},now);
 assert.equal(w.orders[0].cents,24999);assert.deepEqual(w.orders[0].courses,[1]);
});
test('saved paid order survives leaving, serialization and sign-in',()=>{
 let w=setup();pay(w);act(w,'signout',{},now);w=JSON.parse(JSON.stringify(w));
 verify(w);profile(w);act(w,'claim',{orderId:w.lastOrder},now);assert.equal(w.orders[0].status,'claimed');
});
test('overlap after signed-out purchase is held without destroying ownership',()=>{
 const w=setup('bundle','returning@example.test');pay(w);verify(w,'returning@example.test');
 act(w,'claim',{orderId:w.lastOrder},now);assert.equal(w.orders[0].status,'needs-review');
 assert.deepEqual(w.accounts['returning@example.test'].courses,[1]);assert.equal(w.accounts['returning@example.test'].progress[1],38);
});
test('known signed-in overlap rejected before payment',()=>{
 const w=createWorkspace(now);verify(w,'returning@example.test');
 assert.throws(()=>act(w,'checkout',{product:'bundle',email:'returning@example.test',name:'Jordan Sample',ack:true},now),/already owns/);
});
test('decline grants nothing; unpaid cancellation is allowed',()=>{
 const w=setup();assert.throws(()=>act(w,'payment',{orderId:w.lastOrder,result:'declined'},now),/declined/);
 assert.equal(w.orders[0].status,'pending');act(w,'cancel',{orderId:w.lastOrder},now);assert.equal(w.orders[0].status,'canceled');
});
