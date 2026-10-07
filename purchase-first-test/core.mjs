// Isolated UX simulation. No Stripe, Supabase, real authentication or CE awards.
import { randomBytes, randomInt, timingSafeEqual } from 'node:crypto';
export const products = [
  {code:'bundle',title:'The three-course collection',description:'Medication review, uncommon events and legal essentials in one collection.',cents:69999,courses:[1,2,3]},
  {code:'medication',title:'A Medication Review for the Experienced CRNA',description:'A focused pharmacology refresh for anesthesia professionals.',cents:24999,courses:[1]},
  {code:'uncommon',title:'Uncommon but Catastrophic Anesthesia Events',description:'Complex and high-consequence perioperative events.',cents:24999,courses:[2]},
  {code:'legal',title:'Legal Essentials for the CRNA',description:'The legal and professional responsibilities of anesthesia practice.',cents:24999,courses:[3]},
];
export class Fault extends Error { constructor(message,status=400){super(message);this.status=status;} }
const requireThat=(yes,message,status)=>{if(!yes)throw new Fault(message,status);};
const token=()=>randomBytes(24).toString('hex');
export function email(raw){
  const e=String(raw||'').trim().toLowerCase();
  requireThat(e.length<=120&&/^[a-z0-9._+-]+@[a-z0-9.-]+\.test$/.test(e),'Use a fictional address ending in .test, such as learner@example.test.');
  return e;
}
export function createWorkspace(now=Date.now()){
  return {created:now,orders:[],accounts:{'returning@example.test':{id:token(),email:'returning@example.test',first:'Jordan',last:'Sample',profession:'CRNA',profileComplete:true,courses:[1],progress:{1:38}}},session:null,challenge:null,outbox:[],requests:[]};
}
export function act(w,action,b={},now=Date.now()){
  requireThat(now-w.created<86400000,'This test session expired. Start a new test.',410);
  const order=()=>{const o=w.orders.find(o=>o.id===b.orderId);requireThat(o,'Test order not found.',404);return o;};
  const user=()=>{
    requireThat(w.session&&w.session.expires>now,'Verify your test email before continuing.',401);
    return w.accounts[w.session.email];
  };
  if(action==='checkout'){
    const p=products.find(p=>p.code===b.product);requireThat(p,'Choose a valid course.');
    const e=email(b.email);
    requireThat(b.ack===true,'Confirm the course-access email notice.');
    const n=String(b.name||'').trim();requireThat(n.length>=2&&n.length<=100,'Enter a fictional full name.');
    // Only authenticated accounts are checked for prepayment ownership.
    if(w.session?.expires>now&&w.session.email===e){
      requireThat(!p.courses.some(c=>w.accounts[e].courses.includes(c)),'Your test account already owns part or all of this selection. Choose an unowned course.');
    }
    const existing=w.orders.find(o=>o.email===e&&o.product===p.code&&['pending','paid'].includes(o.status));
    if(existing){w.lastOrder=existing.id;return snapshot(w,now);}
    requireThat(w.orders.length<30,'Start a new test to create more orders.',429);
    const o={id:token(),email:e,name:n,product:p.code,cents:p.cents,courses:p.courses,status:'pending',created:now};
    w.orders.push(o);w.lastOrder=o.id;
  } else if(action==='payment'){
    const o=order();
    requireThat(['pending','paid','claimed'].includes(o.status),'This order cannot be paid.');
    if(o.status==='pending'){
      requireThat(['success','declined','delayed'].includes(b.result),'Unknown payment result.');
      if(b.result==='declined')throw new Fault('Test payment declined. Nothing was charged. Try the successful test payment.');
      if(b.result==='delayed'){o.processing=true;return snapshot(w,now);}
      o.processing=false;o.status='paid';o.receipt=`TEST-${w.orders.indexOf(o)+1}`;
      w.outbox.push({kind:'receipt',email:o.email,title:'Your test purchase is saved',body:'Payment simulation complete. Return to this test and verify this email to activate access.',orderId:o.id});
    }
  } else if(action==='cancel'){
    const o=order();requireThat(o.status==='pending'&&!o.processing,'A paid or processing order cannot be canceled here.');
    o.status='canceled';w.lastOrder=null;
  } else if(action==='request-code'){
    const e=email(b.email);
    w.requests=w.requests.filter(t=>now-t<60000);
    requireThat(w.requests.length<5,'Too many codes. Wait one minute and try again.',429);
    w.requests.push(now);
    const code=String(randomInt(100000,1000000));
    w.challenge={email:e,code,expires:now+300000,attempts:0};
    w.outbox.push({kind:'code',email:e,title:'Your test sign-in code',body:code});
  } else if(action==='verify'){
    const c=w.challenge;requireThat(c&&c.expires>now,'Code expired or missing. Request a new code.');
    requireThat(c.attempts<5,'Too many attempts. Request a new code.',429);c.attempts++;
    const guess=String(b.code||'');
    requireThat(/^\d{6}$/.test(guess)&&timingSafeEqual(Buffer.from(c.code),Buffer.from(guess)),'That code is incorrect. Check the test inbox.');
    const e=c.email;
    w.accounts[e]??={id:token(),email:e,profileComplete:false,courses:[],progress:{}};
    w.session={email:e,expires:now+3600000};w.challenge=null;
  } else if(action==='profile'){
    const u=user();
    const first=String(b.first||'').trim(),last=String(b.last||'').trim();
    requireThat(first.length>=1&&last.length>=1&&first.length<=50&&last.length<=50,'Enter both first and last name.');
    requireThat(['CRNA','SRNA','RN','Physician','Other clinician'].includes(b.profession),'Choose your professional role.');
    requireThat(b.accept===true,'Confirm the learner-profile acknowledgment.');
    Object.assign(u,{first,last,profession:b.profession,profileComplete:true});
  } else if(action==='claim'){
    const u=user(),o=order();
    requireThat(u.profileComplete,'Complete your learner profile first.');
    requireThat(o.email===u.email,'Verify the same email used for this test purchase.',403);
    requireThat(['paid','claimed'].includes(o.status),'Payment must be confirmed before activation.');
    if(o.status==='paid'){
      if(o.courses.some(c=>u.courses.includes(c))){
        o.status='needs-review';
        w.outbox.push({kind:'support',email:u.email,title:'Overlapping test purchase',body:'No existing course progress was changed. In production, this needs a purchase-support/refund review; no automatic refund is simulated.'});
      }else{u.courses=[...new Set([...u.courses,...o.courses])];o.status='claimed';o.accountId=u.id;}
    }
  } else if(action==='resume'){w.lastOrder=order().id;}
  else if(action==='signout'){w.session=null;w.challenge=null;}
  else if(action!=='state')throw new Fault('Unknown test action.',404);
  return snapshot(w,now);
}
export function snapshot(w,now=Date.now()){
  const u=w.session?.expires>now?w.accounts[w.session.email]:null;
  return {testOnly:true,products,user:u||null,orders:w.orders,outbox:w.outbox.slice(-15),lastOrder:w.lastOrder||null,challengeEmail:w.challenge?.email||null};
}
