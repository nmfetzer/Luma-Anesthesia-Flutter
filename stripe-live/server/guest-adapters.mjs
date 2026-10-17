import { Fault, requireThat } from '../../stripe-test/server/core.mjs';
export function guestAdapters(config,fetcher=fetch) {
  async function rpc(name,body={}) {
    const r=await fetcher(`${config.ledgerUrl}/rest/v1/rpc/ce_stripe_guest_${name}`,{
      method:'POST',signal:AbortSignal.timeout(15000),
      headers:{apikey:config.ledgerKey,'Content-Type':'application/json',
        ...(config.ledgerKey.startsWith('sb_secret_')?{}:{Authorization:`Bearer ${config.ledgerKey}`})},
      body:JSON.stringify(body)});
    if(!r.ok) {
      const data=await r.json().catch(()=>({}));
      const messages={
        'Guest checkout disabled':'Purchase-first checkout is not open yet. Existing purchases are unchanged.',
        'Checkout capacity reached':'Checkout is busy. Please try again later.',
        'Course is not ready for purchase':'This course is not currently available for purchase.',
      };
      throw new Fault(503,messages[data.message]||'Your purchase could not be verified. If you paid, do not pay again; contact CE HALO support.');
    }
    return r.status===204?null:r.json();
  }
  return {
    guestStore:{
      catalog:()=>rpc('catalog'),
      reserve:(id,code)=>rpc('reserve',{p_id:id,p_code:code}),
      get:id=>rpc('get',{p_id:id}),
      attach:(id,session)=>rpc('attach',{p_id:id,p_session:session}),
      apply:(id,event,session,intent,state,purchasedAt,email)=>rpc('apply',{
        p_id:id,p_event:event,p_session:session,p_intent:intent,p_state:state,
        p_purchased_at:purchasedAt,p_email:email}),
      list:user=>rpc('list',{p_user:user}),
      claim:(id,user,name,role)=>rpc('claim',{p_id:id,p_user:user,p_name:name,p_role:role}),
    },
    secureAccount:async(token,password)=>{
      const headers={apikey:config.authKey,Authorization:token,'Content-Type':'application/json'};
      const r=await fetcher(`${config.authUrl}/auth/v1/user`,{
        method:'PUT',headers,body:JSON.stringify({password}),signal:AbortSignal.timeout(15000)});
      // Do not log or forward the password or raw Auth diagnostics.
      if(!r.ok) {
        const error=await r.json().catch(()=>({}));
        requireThat(error.code==='same_password',
          'Password setup could not be completed. Use a fresh email link and a strong, different password.',409);
      }
      const logout=await fetcher(`${config.authUrl}/auth/v1/logout?scope=others`,{
        method:'POST',headers,signal:AbortSignal.timeout(15000)});
      requireThat(logout.ok,'Account security could not be completed. Your payment is saved; retry activation.',503);
    },
  };
}
