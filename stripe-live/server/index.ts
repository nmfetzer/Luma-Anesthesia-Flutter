import { configFrom, createHandler, setupStatus, ORIGIN } from './core.mjs';
import { adapters } from './adapters.mjs';
// Authorization: browser routes validate Luma tokens at /auth/v1/user;
// webhook route validates the exact raw-body Stripe signature before processing.
Deno.serve(async (request: Request) => {
  const env = Deno.env.toObject();
  const headers = { 'Content-Type': 'application/json', 'Cache-Control': 'no-store',
    'Access-Control-Allow-Origin': ORIGIN, 'Vary': 'Origin',
    'Access-Control-Allow-Headers': 'authorization, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS' };
  if (request.method === 'GET' && new URL(request.url).pathname.endsWith('/setup-status')) {
    return new Response(JSON.stringify(setupStatus(env)), { headers });
  }
  if (request.method === 'OPTIONS' && request.headers.get('origin') === ORIGIN) {
    return new Response(null, { status: 204, headers });
  }
  try {
    const config = configFrom(env);
    return await createHandler(config, adapters(config))(request);
  } catch {
    return new Response(JSON.stringify({ error: 'Website checkout is not configured yet.' }),
      { status: 503, headers });
  }
});
