// The private resource table denies all learner/anonymous reads.
// Service credentials remain inside this authenticated edge function.
let cached;
export async function loadAssets() {
  if (!cached) cached = (async () => {
    const base = Deno.env.get('SUPABASE_URL');
    const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    const response = await fetch(
      `${base}/rest/v1/ce_course2_resources?id=eq.certificate_assets_v1&select=data`,
      {headers:{apikey:key,Authorization:`Bearer ${key}`}},
    );
    if (!response.ok) throw Error('Certificate template unavailable');
    const rows = await response.json();
    const assets = rows[0]?.data;
    if (!assets?.standardTemplate || !assets?.compactTemplate ||
        !assets?.fontBase64 || !assets?.signatureBase64) {
      throw Error('Certificate template incomplete');
    }
    return assets;
  })().catch(error => { cached = undefined; throw error; });
  return cached;
}
