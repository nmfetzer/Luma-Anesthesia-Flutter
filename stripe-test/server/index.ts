// DRAFT entry point for a SEPARATE Supabase test project.
// Not under supabase/functions: ordinary production deploys must not include it.
import { configFrom, createHandler } from './core.mjs';
import { adapters } from './adapters.mjs';

Deno.serve(async (request: Request) => {
  try {
    const config = configFrom(Deno.env.toObject());
    return await createHandler(config, adapters(config))(request);
  } catch {
    return new Response(JSON.stringify({error: 'Stripe testing is disabled or not configured.'}), {
      status: 503, headers: {'Content-Type': 'application/json', 'Cache-Control': 'no-store'},
    });
  }
});
