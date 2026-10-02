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
    if (!r.ok) {
      // Only allowlisted business-rule messages cross the server boundary.
      // Never expose raw SQL, PostgREST diagnostics, credentials or account data.
      const data = await r.json().catch(() => ({}));
      const messages = {
        'Resolve pending checkout first': 'Another checkout is already open. Refresh course access and try again.',
        'Already owned course or overlapping bundle': 'You already own this course or part of this bundle. Refresh course access.',
        'Course is not ready for purchase': 'This course is not currently available for purchase.',
      };
      if (data.code === 'P0001' && messages[data.message]) {
        throw new Fault(409, messages[data.message]);
      }
      throw new Fault(503, 'Course access could not be verified. No new payment was started.');
    }
    return r.status === 204 ? null : r.json();
  }
  return { user: shared.user, stripe: {
    ...shared.stripe,
    expire: async id => {
      const r = await fetcher(`https://api.stripe.com/v1/checkout/sessions/${encodeURIComponent(id)}/expire`, {
        method: 'POST', signal: AbortSignal.timeout(15000),
        headers: { Authorization: `Bearer ${config.stripeKey}`, 'Stripe-Version': '2024-06-20',
          'Idempotency-Key': `ce-live-switch-${id}` },
      });
      if (!r.ok) throw new Fault(409, 'Previous checkout could not be closed. Refresh course access before trying again.');
      return r.json();
    },
  }, verifyEvent, store: {
    state: user => rpc('state', { p_user: user }),
    get: id => rpc('get', { p_id: id }),
    reserve: (user, code) => rpc('reserve', { p_user: user, p_code: code }),
    attach: (id, session) => rpc('attach', { p_id: id, p_session: session }),
    apply: (id, event, session, intent, state, purchasedAt) => rpc('apply', {
      p_id: id, p_event: event, p_session: session, p_intent: intent,
      p_state: state, p_purchased_at: purchasedAt }),
  } };
}
