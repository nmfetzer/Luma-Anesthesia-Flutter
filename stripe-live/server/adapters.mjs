import { adapters as base, verifyEvent } from '../../stripe-test/server/adapters.mjs';
import { Fault } from '../../stripe-test/server/core.mjs';
export function adapters(config, fetcher = fetch) {
  const shared = base(config, fetcher);
  async function rpc(name, body) {
    const r = await fetcher(`${config.ledgerUrl}/rest/v1/rpc/ce_stripe_live_${name}`, {
      method: 'POST', signal: AbortSignal.timeout(15000),
      headers: { apikey: config.ledgerKey, 'Content-Type': 'application/json',
        ...(config.ledgerKey.startsWith('sb_secret_') ? {} : { Authorization: `Bearer ${config.ledgerKey}` }) },
      body: JSON.stringify(body) });
    if (!r.ok) throw new Fault(503, 'Course access could not be verified. No new payment was started.');
    return r.status === 204 ? null : r.json();
  }
  return { user: shared.user, stripe: shared.stripe, verifyEvent, store: {
    state: user => rpc('state', { p_user: user }),
    get: id => rpc('get', { p_id: id }),
    reserve: (user, code) => rpc('reserve', { p_user: user, p_code: code }),
    attach: (id, session) => rpc('attach', { p_id: id, p_session: session }),
    apply: (id, event, session, intent, state, purchasedAt) => rpc('apply', {
      p_id: id, p_event: event, p_session: session, p_intent: intent,
      p_state: state, p_purchased_at: purchasedAt }),
  } };
}
