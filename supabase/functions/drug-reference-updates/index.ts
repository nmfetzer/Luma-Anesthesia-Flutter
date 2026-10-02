import { refreshSources } from './providers.mjs';

const headers = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Content-Type': 'application/json',
  'Cache-Control': 'no-store',
};
const reply = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {status, headers});
const base = Deno.env.get('SUPABASE_URL')!;
const service = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

async function rest(path: string, method = 'GET', body?: unknown) {
  const response = await fetch(`${base}/rest/v1/${path}`, {
    method,
    headers: {apikey: service, Authorization: `Bearer ${service}`,
      'Content-Type': 'application/json', Prefer: 'return=minimal'},
    body: body === undefined ? undefined : JSON.stringify(body),
    signal: AbortSignal.timeout(8000),
  });
  if (!response.ok) throw new Error('Reference cache unavailable');
  return response.status === 204 ? null : response.json();
}

Deno.serve(async req => {
  if (req.method === 'OPTIONS') return new Response('ok', {headers});
  if (req.method !== 'POST') return reply({error: 'Method not allowed'}, 405);
  try {
    const raw = await req.text();
    if (raw.length > 256) return reply({error: 'Invalid request'}, 400);
    const input = JSON.parse(raw);
    const id = input?.medication_id;
    if (typeof id !== 'string' || !/^[a-zA-Z0-9_-]{1,80}$/.test(id)) {
      return reply({error: 'Invalid medication'}, 400);
    }
    const apikey = req.headers.get('apikey');
    if (!apikey || apikey.length > 2048) return reply({error: 'Unauthorized'}, 401);
    // Custom project API-key validation supports modern sb_publishable keys,
    // including signed-out users. Only public medication identity is queried.
    // No user JWT, account identifier or patient information goes to providers.
    const lookup = await fetch(
      `${base}/rest/v1/medication?select=name&id=eq.${encodeURIComponent(id)}&limit=1`,
      {headers: {apikey}, signal: AbortSignal.timeout(8000)},
    );
    if (lookup.status === 401 || lookup.status === 403) {
      return reply({error: 'Unauthorized'}, 401);
    }
    if (!lookup.ok) throw new Error('Medication lookup unavailable');
    const meds = await lookup.json();
    if (!Array.isArray(meds) || !meds[0]?.name) return reply({error: 'Medication not found'}, 404);
    const cachePath = `drug_reference_cache?medication_id=eq.${encodeURIComponent(id)}`;
    const cached = await rest(`${cachePath}&select=payload`);
    const previous = cached?.[0]?.payload ?? {};
    const claimed = await rest('rpc/luma_claim_drug_reference_refresh', 'POST', {p_id: id});
    if (!claimed) {
      if (previous.schema === 1) return reply(previous);
      return reply({error: 'Refresh in progress; please retry shortly'}, 503);
    }
    let payload;
    try {
      payload = await refreshSources(
        meds[0].name, previous, fetch, Deno.env.get('OPENFDA_API_KEY') ?? '',
      );
    } catch (_) {
      return reply({error: 'Reference sources unavailable'}, 503);
    }
    const failed = payload.fda.refresh_failed || payload.dailymed.refresh_failed;
    await rest(cachePath, 'PATCH', {
      payload, next_refresh_at: new Date(Date.now() + (failed ? 15 * 60_000 : 12 * 3600_000)).toISOString(),
    });
    return reply(payload);
  } catch (_) {
    // Do not expose provider credentials, raw errors or database details.
    return reply({error: 'Reference update unavailable; use official source links'}, 503);
  }
});
