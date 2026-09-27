import { createClient } from '@supabase/supabase-js';
import { renderCertificate } from './renderer.mjs';

const headers = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Cache-Control': 'no-store',
};
const json = (status: number, message: string) => new Response(JSON.stringify({error:message}), {
  status, headers:{...headers,'Content-Type':'application/json'},
});
Deno.serve(async request => {
  if (request.method === 'OPTIONS') return new Response('ok',{headers});
  if (request.method !== 'POST') return json(405,'POST required');
  try {
    const auth = request.headers.get('Authorization') ?? '';
    if (!auth.startsWith('Bearer ')) return json(401,'Sign in to retrieve your certificate.');
    const url = Deno.env.get('SUPABASE_URL')!;
    const userClient = createClient(url,Deno.env.get('SUPABASE_ANON_KEY')!,{
      global:{headers:{Authorization:auth}}, auth:{persistSession:false},
    });
    const {data:{user},error:authError} = await userClient.auth.getUser();
    if (authError || !user || user.is_anonymous) return json(401,'Sign in with a permanent account.');
    // This endpoint never accepts a user ID, certificate ID, PDF, date or credits.
    const body = await request.json().catch(()=>null);
    if (!body || Object.keys(body).some(k=>k!=='action') ||
        !['download','issue'].includes(body.action)) return json(400,'Invalid certificate request.');
    const {data:response,error} = await userClient.rpc('ce_course1_certificate',{
      p_action:body.action==='issue'?'issue':'status',
    });
    if (error) return json(403,error.message);
    const record = response?.certificate;
    if (response?.state !== 'issued' || record?.is_preview !== false) {
      return json(409,'Complete the course requirements before downloading an official certificate.');
    }
    const admin = createClient(url,Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,{auth:{persistSession:false}});
    // Look up the authenticated user's immutable award, not any supplied ID.
    const {data:award,error:awardError} = await admin.from('ce_course1_certificates')
      .select('id,user_id,archive_path,archive_sha256').eq('user_id',user.id).eq('course_id','1047239').single();
    if (awardError || award?.id !== record.id) return json(409,'Certificate record could not be verified.');
    const path = `${user.id}/${award.id}.pdf`;
    const bucket = admin.storage.from('ce-course1-certificates');
    let file = await bucket.download(path);
    if (file.error) {
      // Once an archive is recorded, never silently replace missing bytes.
      if (award.archive_path) return json(503,'The saved certificate is temporarily unavailable. Contact info@cehalo.com.');
      const bytes = await renderCertificate(record);
      const upload = await bucket.upload(path,bytes,{contentType:'application/pdf',upsert:false});
      if (upload.error && !['409','400'].includes(String(upload.error.statusCode))) {
        return json(503,'Unable to save your certificate. Please retry.');
      }
      // Concurrent retries always return the first saved object, never new bytes.
      file = await bucket.download(path);
      if (file.error || !file.data) return json(503,'Unable to retrieve your saved certificate. Please retry.');
    }
    const bytes = new Uint8Array(await file.data!.arrayBuffer());
    const hash = Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256',bytes)))
      .map(x=>x.toString(16).padStart(2,'0')).join('');
    if (award.archive_sha256 && award.archive_sha256!==hash) return json(503,'Certificate integrity check failed. Contact info@cehalo.com.');
    if (!award.archive_path) {
      const {error:saveError} = await admin.from('ce_course1_certificates').update({
        archive_path:path,archive_sha256:hash,archived_at:new Date().toISOString(),
      }).eq('id',award.id).is('archive_path',null);
      if (saveError) return json(503,'Certificate archive confirmation failed. Please retry.');
    }
    return new Response(bytes,{headers:{
      ...headers,'Content-Type':'application/octet-stream',
      'Content-Disposition':`attachment; filename="CE_HALO_1047239_${award.id}.pdf"`,
    }});
  } catch {
    // Never leak tokens, snapshot PII or storage paths in error output.
    return json(500,'Unable to prepare your certificate. Please retry or contact info@cehalo.com.');
  }
});
