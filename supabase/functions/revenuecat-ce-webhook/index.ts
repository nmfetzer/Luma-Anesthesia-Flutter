import { createClient } from "npm:@supabase/supabase-js@2.99.3";
import { handle } from "./handler.ts";

Deno.serve(async (request: Request) => {
  const url = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!url || !serviceKey) return new Response("Unavailable", { status: 503 });
  const admin = createClient(url, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  return await handle(request, {
    config: {
      enabled: Deno.env.get("LUMA_CE_WEBHOOK_ENABLED") === "true",
      secret: Deno.env.get("REVENUECAT_CE_WEBHOOK_SECRET") ?? "",
      appId: Deno.env.get("REVENUECAT_CE_APP_ID") ?? "",
      // Accepted only through the isolated RPC, which checks the server-managed
      // reviewer allowlist. Never send sandbox data to the production ledger.
      allowSandbox: true,
    },
    record: async (args, environment) => {
      const rpc = environment === "SANDBOX"
        ? "process_revenuecat_ce_sandbox_event" : "process_revenuecat_ce_event";
      const { error } = await admin.rpc(rpc, args);
      return { error };
    },
  });
});
