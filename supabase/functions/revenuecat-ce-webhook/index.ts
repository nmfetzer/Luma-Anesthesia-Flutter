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
      // Sandbox transactions can only grant in a separate test project.
      allowSandbox: Deno.env.get("LUMA_CE_ALLOW_SANDBOX") === "true" &&
        new URL(url).hostname !== "xuckkusbbcxplpqclbxt.supabase.co",
    },
    record: async (args) => {
      const { error } = await admin.rpc("process_revenuecat_ce_event", args);
      return { error };
    },
  });
});
