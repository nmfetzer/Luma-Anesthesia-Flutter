// DRAFT entry point for a SEPARATE Supabase test project.
// Not under supabase/functions: ordinary production deploys must not include it.
import { configFrom, createHandler, setupStatus } from './core.mjs';
import { adapters } from './adapters.mjs';

Deno.serve(async (request: Request) => {
  try {
    const env = Deno.env.toObject();
    if (new URL(request.url).pathname.split('/').at(-1) === 'setup-status') {
      if (request.method !== 'GET') {
        return new Response(null, { status: 405, headers: { Allow: 'GET' } });
      }
      return Response.json(setupStatus(env), { headers: { 'Cache-Control': 'no-store' } });
    }
    const config = configFrom(env);
    return await createHandler(config, adapters(config))(request);
  } catch {
    return new Response(JSON.stringify({error: 'Stripe testing is disabled or not configured.'}), {
      status: 503, headers: {'Content-Type': 'application/json', 'Cache-Control': 'no-store'},
    });
  }
});
