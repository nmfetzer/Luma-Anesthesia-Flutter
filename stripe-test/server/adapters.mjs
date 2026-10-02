import { Fault, requireThat } from './core.mjs';

// Direct HTTPS adapters. Secrets stay server-side, never in Flutter/build/web.
export function adapters(config, fetcher = fetch) {
  async function json(url, options) {
    const response = await fetcher(url, { ...options, signal: AbortSignal.timeout(15000) });
    if (!response.ok) throw new Fault(503, 'A required service could not verify this request.');
    if (response.status === 204) return null;
    return response.json();
  }
  const stripe = (path, body, key) => json(`https://api.stripe.com/v1/${path}`, {
    method: body ? 'POST' : 'GET',
    headers: {
      Authorization: `Bearer ${config.stripeKey}`,
      'Stripe-Version': '2024-06-20',
      ...(body ? { 'Content-Type': 'application/x-www-form-urlencoded', 'Idempotency-Key': key } : {}),
    },
    ...(body ? { body: new URLSearchParams(body).toString() } : {}),
  });
  const rpc = (name, body) => json(`${config.ledgerUrl}/rest/v1/rpc/ce_stripe_test_${name}`, {
    method: 'POST',
    headers: { apikey: config.ledgerKey, Authorization: `Bearer ${config.ledgerKey}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  return {
    user: token => json(`${config.authUrl}/auth/v1/user`, { headers: { apikey: config.authKey, Authorization: token } }),
    existingPurchases: async (token, user) => {
      const response = await fetcher(
        `${config.authUrl}/rest/v1/luma_ce_bonus_purchases?user_id=eq.${encodeURIComponent(user)}&select=store,product_id,revoked_at,awarded_months`,
        { headers: { apikey: config.authKey, Authorization: token, Prefer: 'count=exact' },
          signal: AbortSignal.timeout(15000) });
      requireThat(response.ok, 'Existing purchases could not be verified.', 503);
      const rows = await response.json();
      const total = response.headers.get('content-range')?.split('/').at(-1);
      requireThat(Array.isArray(rows) && /^\d+$/.test(total ?? '') && Number(total) === rows.length,
        'Complete purchase history could not be verified. No checkout was opened.', 503);
      return rows;
    },
    stripe: {
      price: id => stripe(`prices/${encodeURIComponent(id)}`),
      session: id => stripe(`checkout/sessions/${encodeURIComponent(id)}?expand[]=line_items&expand[]=payment_intent.latest_charge`),
      intent: id => stripe(`payment_intents/${encodeURIComponent(id)}?expand[]=latest_charge`),
      charge: id => stripe(`charges/${encodeURIComponent(id)}`),
      create: (body, key) => stripe('checkout/sessions', body, key),
    },
    store: {
      list: user => rpc('list', { p_user: user }),
      get: id => rpc('get', { p_id: id }),
      reserve: (user, code, price, amount, baseline) => rpc('reserve', {
        p_user: user, p_code: code, p_price: price, p_amount: amount, p_baseline: baseline,
      }),
      attach: (id, session) => rpc('attach', { p_id: id, p_session: session }),
      apply: (id, event, session, intent, state) => rpc('apply', {
        p_id: id, p_event: event, p_session: session, p_intent: intent, p_state: state,
      }),
    },
    verifyEvent,
  };
}

// Stripe signs timestamp.raw_body. Constant-work byte comparison after HMAC;
// multiple v1 signatures support signing-secret rotation.
export async function verifyEvent(raw, signature, secret, now = Date.now()) {
  requireThat(typeof signature === 'string', 'Missing webhook signature.', 400);
  const fields = signature.split(',').map(x => x.trim().split('='));
  const times = fields.filter(([k]) => k === 't');
  requireThat(times.length === 1 && /^\d+$/.test(times[0][1]), 'Invalid webhook timestamp.');
  const timestamp = Number(times[0][1]);
  requireThat(Math.abs(now / 1000 - timestamp) <= 300, 'Expired webhook signature.');
  const bytes = new TextEncoder();
  const key = await crypto.subtle.importKey('raw', bytes.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  const expected = new Uint8Array(await crypto.subtle.sign('HMAC', key, bytes.encode(`${timestamp}.${raw}`)));
  const valid = fields.filter(([k]) => k === 'v1').some(([, value]) => {
    if (!/^[0-9a-f]{64}$/i.test(value ?? '')) return false;
    let difference = 0;
    for (let i = 0; i < 32; i++) difference |= expected[i] ^ parseInt(value.slice(i * 2, i * 2 + 2), 16);
    return difference === 0;
  });
  requireThat(valid, 'Invalid webhook signature.');
  return JSON.parse(raw);
}
