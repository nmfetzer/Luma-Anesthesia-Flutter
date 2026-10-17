// This preview intentionally talks only to the isolated simulator, never production.
const API=location.hostname==='127.0.0.1'||location.hostname==='localhost'?'/api':'__PORT_4317__/api';
const $=s=>document.querySelector(s);
const escape=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const money=n=>new Intl.NumberFormat('en-US',{style:'currency',currency:'USD'}).format(n/100);
let workspace=new URLSearchParams(location.hash.slice(1)).get('test'),state,view='checkout',selected=new URLSearchParams(location.search).get('product')||'medication',busy=false;
const product=()=>state.products.find(p=>p.code===selected)||state.products[1];
const order=()=>state.orders.find(o=>o.id===state.lastOrder);
const setError=e=>{$('#error').textContent=e||'';$('#error').hidden=!e;};
async function call(action,body={}){
  const r=await fetch(`${API}/${action}`,{method:'POST',headers:{'Content-Type':'application/json',...(workspace?{'X-Test-Workspace':workspace}:{})},body:JSON.stringify(body)});
  const data=await r.json();if(!r.ok)throw new Error(data.error||'Unable to reach the test service.');
  if(!data.testOnly)throw new Error('Test-mode confirmation is missing. Stopped for safety.');
  return data;
}
async function run(fn){
  if(busy)return;busy=true;setError('');document.querySelectorAll('button').forEach(b=>b.disabled=true);
  try{await fn();}catch(e){setError(e.message);}finally{busy=false;document.querySelectorAll('button').forEach(b=>b.disabled=false);}
}
function go(v){view=v;render();$('#main').focus({preventScroll:true});window.scrollTo(0,0);}
function heading(title,copy,stage=1){return `<p class="steps">${stage===1?'<b>Checkout</b>':'Checkout'} <span aria-hidden="true"> / </span> ${stage===2?'<b>Activate access</b>':'Activate access'} <span aria-hidden="true"> / </span> ${stage===3?'<b>My courses</b>':'My courses'}</p><p class="eyebrow">CE HALO · PURCHASE-FIRST PREVIEW</p><h1>${title}</h1><p class="intro">${copy}</p>`;}
function field(id,label,value='',type='text',extra=''){return `<div class="field"><label for="${id}">${label}</label><input id="${id}" name="${id}" type="${type}" value="${escape(value)}" ${extra}></div>`;}
function catalog(){
 return heading('Choose your next course.','Buy directly. Finish your learner account after payment.')+state.products.map((p,i)=>`<article class="course ${i===0?'featured':''}"><div>${i===0?'<p class="eyebrow">THE COMPLETE COLLECTION</p>':''}<h3>${p.title}</h3><p>${p.description}</p></div><span class="price">${money(p.cents)}</span><div class="actions"><span class="tag">One-time purchase · Preview price</span><button class="primary buy" data-product="${p.code}">Buy ${i===0?'the bundle':'course'}</button></div></article>`).join('');
}
function checkout(){
 const p=product(),pending=order();
 if(pending?.processing)return heading('Your test payment is processing.','Do not pay again. Access will be available to activate once payment is confirmed.')+`<div class="formbox"><p>${escape(state.products.find(p=>p.code===pending.product).title)}</p><p class="orderinfo">Email: ${escape(pending.email)}</p><button id="confirmdelayed" class="primary wide">Simulate delayed payment confirmation</button><p class="under">A live checkout would wait for the verified payment event. This is a test control.</p></div>`;
 return heading('You’re one step from your course.','No account needed to purchase. Activate your access after checkout.')+`<form id="checkoutform" class="formbox"><div class="total"><span>${p.title}</span><strong>${money(p.cents)}</strong></div>${field('email','Email for course access',state.user?.email||'learner@example.test','email','required maxlength="120" autocomplete="off"')}<p class="help">Already use Luma? Use that same email so your courses stay together. Test addresses must end in .test.</p>${field('name','Full name (use fictional information)',state.user?state.user.first+' '+state.user.last:'Alex Sample','text','required maxlength="100" autocomplete="off"')}<label class="check"><input id="ack" type="checkbox" required><span>I understand that after payment I’ll verify this email and finish my learner profile before accessing the course.</span></label><div class="passwordnote"><strong>Payment simulation</strong><br>No card details are needed or collected. In the live version, Stripe would securely collect payment on this checkout step.</div><p class="under">One-time payment. No automatic subscription. Credit and certificates require completing course requirements.</p><button type="submit" class="primary wide">Complete test purchase · ${money(p.cents)}</button><details class="testing"><summary>Test a payment problem</summary><div class="stack"><button type="button" id="decline" class="secondary">Simulate a declined payment</button><button type="button" id="delay" class="secondary">Simulate a delayed payment</button></div></details></form><div class="row"><button id="browse" class="text">Choose a different course</button><button id="signin" class="text">Already purchased? Sign in</button></div>`;
}
function activation(){
 const o=order();
 if(!o)return login();
 if(o.status==='needs-review')return heading('Let’s resolve an overlapping purchase.','This test account already owns part of this purchase. Existing progress has not changed.',2)+`<div class="formbox"><p>In the live flow, purchase support would review the overlap before any refund or reassignment. This preview does not simulate a refund.</p><button class="primary" id="library">View existing test courses</button></div>`;
 const u=state.user,matching=u?.email===o.email;
 let content=heading('Your purchase is saved.','Finish activation below. You do not need to purchase again.',2)+`<div class="successbox"><span class="badge">TEST PAYMENT CONFIRMED</span><h2>${escape(state.products.find(p=>p.code===o.product).title)}</h2><p class="orderinfo">${escape(o.receipt)} · ${money(o.cents)} · ${escape(o.email)}</p><p class="help">A receipt and activation instructions are in the test inbox. You can leave and return using this test link.</p></div>`;
 if(!matching){
  content+=`<form id="verifyform" class="formbox"><h2>Verify your course email</h2><p class="intro">We’ll connect your purchase to <strong>${escape(o.email)}</strong>, whether your account is new or already exists.</p>`;
  if(u)content+=`<p class="inboxtip">You are currently signed in as ${escape(u.email)}. Verify the purchase email to switch safely.</p>`;
  content+=`<button type="button" class="secondary" id="sendcode">Send test verification code</button>${field('code','Six-digit email code','','text','inputmode="numeric" pattern="[0-9]{6}" maxlength="6" required autocomplete="off"')}<p class="inboxtip">No email is sent. Open <button type="button" class="text openinbox">Test inbox</button> to read the simulated code.</p><button type="submit" class="primary wide">Verify email & continue</button></form>`;
 }else if(!u.profileComplete){
  content+=profile();
 }else{
  content+=`<div class="formbox"><h2>Welcome back, ${escape(u.first)}.</h2><p>Your verified account is ready. This purchase will be added to the same course library without resetting your existing progress.</p><button id="activate" class="primary wide">Activate my course access</button></div>`;
 }
 return content+`<button id="leavelater" class="text">Leave and finish activation later</button>`;
}
function profile(){
 const parts=(order()?.email===state.user.email?order().name:'').trim().split(/\s+/);
 return `<form id="profileform" class="formbox"><h2>Finish your learner profile</h2><p class="intro">Your email is verified. Confirm your details below; no additional payment is needed.</p>${field('verified','Verified email',state.user.email,'email','readonly')}${field('first','First name',state.user.first||parts[0]||'','text','required maxlength="50" autocomplete="off"')}${field('last','Last name',state.user.last||parts.slice(1).join(' '),'text','required maxlength="50" autocomplete="off"')}<div class="field"><label for="profession">Professional role</label><select id="profession" required><option value="">Select your role</option>${['CRNA','SRNA','RN','Physician','Other clinician'].map(x=>`<option>${x}</option>`).join('')}</select></div><label class="check"><input id="accept" type="checkbox" required><span>I understand this is a fictional learner profile. Production will require the applicable terms and learner-record details before course access.</span></label><p class="passwordnote">Passwordless concept: a verified email code signs you in. No new password is requested in this preview. Existing live Luma sign-in is unchanged.</p><button class="primary wide" type="submit">Finish setup & activate access</button></form>`;
}
function login(){
 return heading('Your courses are waiting.','Use the email from checkout. New purchases stay saved even if you left before activation.',2)+`<form id="loginform" class="formbox">${field('loginemail','Purchase or account email',order()?.email||'returning@example.test','email','required autocomplete="off"')}<button class="secondary" id="requestlogin" type="button">Send test sign-in code</button>${field('logincode','Six-digit email code','','text','inputmode="numeric" pattern="[0-9]{6}" maxlength="6" required')}<p class="inboxtip">Read your code in the <button class="text openinbox" type="button">Test inbox</button>. No actual email is sent.</p><button type="submit" class="primary wide">Verify & find my courses</button></form><button id="browse" class="text">Back to course selection</button>`;
}
function library(){
 const u=state.user;if(!u)return login();
 if(!u.profileComplete)return heading('Finish your learner profile.','Your email is verified. Complete your information before opening courses.',2)+profile();
 return heading(`Welcome, ${escape(u.first)}.`,'Your verified email keeps purchases and learning progress together.',3)+`<p class="orderinfo">${escape(u.email)} · ${escape(u.profession)} <span class="badge">TEST ACCOUNT</span></p>`+
 (u.courses.length?u.courses.map(c=>{const p=state.products.find(p=>p.courses.length===1&&p.courses[0]===c);return `<article class="courseowned"><h3>${p.title}</h3><p class="muted">Sample progress: ${u.progress[c]||0}%</p><progress value="${u.progress[c]||0}" max="100" aria-label="Sample course progress"></progress><div class="row"><button class="secondary opencourse" data-course="${c}">${u.progress[c]?'Continue':'Open'} test course</button></div></article>`;}).join(''):'<div class="formbox"><p>No activated test courses yet. Complete activation for your saved purchase or choose a course.</p></div>')+
 state.orders.filter(o=>o.email===u.email&&o.status==='paid').map(o=>`<div class="note"><p>You have a saved purchase awaiting activation.</p><button class="primary resume" data-id="${o.id}">Activate saved purchase</button></div>`).join('')+`<div class="row"><button id="browse" class="text">Browse courses</button><button id="signout" class="text">Sign out</button></div>`;
}
function render(){
 setError('');
 $('#app').innerHTML=view==='catalog'?catalog():view==='checkout'?checkout():view==='activation'?activation():view==='library'?library():view==='course'?heading('This is your course entry point.','The purchase flow is complete. Actual lesson PDFs, quizzes, certificates and CE reporting are intentionally not connected in this test.',3)+`<div class="formbox"><p>Your simulated course ownership is saved to this test account. No live learner record was created.</p><button id="library" class="primary">Back to my courses</button></div>`:login();
 $('#mailcount').textContent=state.outbox.length;
 bind();
}
function on(id,event,fn){const x=document.getElementById(id);if(x)x.addEventListener(event,fn);}
async function purchase(result){
 const form=$('#checkoutform');if(!form.reportValidity())return;
 await run(async()=>{
  state=await call('checkout',{product:product().code,email:$('#email').value,name:$('#name').value,ack:$('#ack').checked});
  state=await call('payment',{orderId:state.lastOrder,result});
  go(result==='delayed'?'checkout':'activation');
 });
}
async function afterVerification(){
 const matching=state.orders.find(o=>o.email===state.user.email&&['paid','needs-review'].includes(o.status));
 if(matching){state=await call('resume',{orderId:matching.id});go('activation');}
 else go('library');
}
function bind(){
 document.querySelectorAll('.buy').forEach(b=>b.onclick=()=>{selected=b.dataset.product;go('checkout');});
 document.querySelectorAll('.openinbox').forEach(b=>b.onclick=showInbox);
 document.querySelectorAll('.opencourse').forEach(b=>b.onclick=()=>go('course'));
 document.querySelectorAll('.resume').forEach(b=>b.onclick=()=>run(async()=>{state=await call('resume',{orderId:b.dataset.id});go('activation');}));
 on('checkoutform','submit',e=>{e.preventDefault();purchase('success');});
 on('decline','click',()=>purchase('declined'));on('delay','click',()=>purchase('delayed'));
 on('confirmdelayed','click',()=>run(async()=>{state=await call('payment',{orderId:state.lastOrder,result:'success'});go('activation');}));
 on('browse','click',()=>go('catalog'));on('signin','click',()=>go('login'));
 on('sendcode','click',()=>run(async()=>{state=await call('request-code',{email:order().email});render();showInbox();}));
 on('verifyform','submit',e=>{e.preventDefault();run(async()=>{state=await call('verify',{code:$('#code').value});await afterVerification();});});
 on('requestlogin','click',()=>run(async()=>{
  const el=$('#loginemail');if(!el.reportValidity())return;
  state=await call('request-code',{email:el.value});$('#mailcount').textContent=state.outbox.length;showInbox();
 }));
 on('loginform','submit',e=>{e.preventDefault();run(async()=>{
  if($('#loginemail').value.trim().toLowerCase()!==state.challengeEmail)throw new Error('Request a code for the email entered above.');
  state=await call('verify',{code:$('#logincode').value});await afterVerification();
 });});
 on('profileform','submit',e=>{e.preventDefault();run(async()=>{
  state=await call('profile',{first:$('#first').value,last:$('#last').value,profession:$('#profession').value,accept:$('#accept').checked});
  if(order()?.status==='paid'){state=await call('claim',{orderId:state.lastOrder});go(order().status==='needs-review'?'activation':'library');}else go('library');
 });});
 on('activate','click',()=>run(async()=>{state=await call('claim',{orderId:state.lastOrder});go(order().status==='needs-review'?'activation':'library');}));
 on('leavelater','click',()=>run(async()=>{state=await call('signout');go('login');}));
 on('library','click',()=>go('library'));on('signout','click',()=>run(async()=>{state=await call('signout');go('login');}));
}
function showInbox(){
 $('#messages').innerHTML=state.outbox.length?[...state.outbox].reverse().map(m=>`<article class="message"><small>TO ${escape(m.email)} · SIMULATED EMAIL</small><h3>${escape(m.title)}</h3>${m.kind==='code'?`<code>${escape(m.body)}</code><p class="help">Five-minute expiry. Most recent code only.</p>`:`<p>${escape(m.body)}</p>`}${m.orderId?`<button class="secondary mailresume" data-id="${m.orderId}">Return to activation</button>`:''}</article>`).join(''):'<p>No messages yet. Complete a test purchase or request a sign-in code.</p>';
 document.querySelectorAll('.mailresume').forEach(b=>b.onclick=()=>run(async()=>{state=await call('resume',{orderId:b.dataset.id});$('#mail').close();go('activation');}));
 if(!$('#mail').open)$('#mail').showModal();
}
async function init(fresh=false){
 await run(async()=>{
  if(fresh||!workspace){const w=await call('workspace');workspace=w.id;location.hash='test='+workspace;}
  state=await call('state');
  if(!state.products.some(p=>p.code===selected))selected='medication';
  const o=order();view=o?.status==='paid'||o?.status==='needs-review'?'activation':state.user?'library':'checkout';
  render();
 });
}
$('#brand').onclick=e=>{e.preventDefault();if(state)go('catalog');};
$('#returning').onclick=()=>{if(state)go(state.user?'library':'login');};
$('#inbox').onclick=()=>{if(state)showInbox();};
$('#newtest').onclick=()=>init(true);
await init();
