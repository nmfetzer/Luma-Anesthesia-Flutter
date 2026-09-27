// REVIEW DRAFT: deploy as revenuecat-sync only after SQL + secrets are approved.
import { createClient } from "npm:@supabase/supabase-js@2";
import { verifiedSnapshot } from "./validation.ts";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (request.method !== "POST") return json({ error: "Method not allowed" }, 405);
  try {
    const url = Deno.env.get("SUPABASE_URL");
    const anon = Deno.env.get("SUPABASE_ANON_KEY");
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const rcKey = Deno.env.get("REVENUECAT_SECRET_API_KEY");
    // A second deployment gate prevents accidental activation from Flutter alone.
    if (Deno.env.get("LUMA_BILLING_SERVER_ENABLED") !== "true" ||
        !url || !anon || !serviceKey || !rcKey) return json({ error: "Billing unavailable" }, 503);
    const authorization = request.headers.get("Authorization") ?? "";
    if (!authorization.startsWith("Bearer ")) return json({ error: "Sign in required" }, 401);
    const userClient = createClient(url, anon, {
      global: { headers: { Authorization: authorization } },
      auth: { persistSession: false, autoRefreshToken: false },
    });
    // Validates token with Supabase Auth; never trusts a submitted UUID.
    const { data: { user }, error } = await userClient.auth.getUser();
    if (error || !user || user.is_anonymous) return json({ error: "Sign in required" }, 401);
    const admin = createClient(url, serviceKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const response = await fetch(
      `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(user.id)}`, {
        headers: { Authorization: `Bearer ${rcKey}`, Accept: "application/json" },
        signal: AbortSignal.timeout(10_000),
      });
    if (!response.ok) return json({ error: "Verification temporarily unavailable" }, 503);
    // Sandbox grants must use a separate test Supabase project, never production.
    const allowSandbox = Deno.env.get("LUMA_ALLOW_SANDBOX") === "true" &&
      new URL(url).hostname !== "xuckkusbbcxplpqclbxt.supabase.co";
    const snapshot = verifiedSnapshot(await response.json(), Date.now(), allowSandbox);
    const { error: writeError } = await admin.rpc("record_revenuecat_access", {
      p_user_id: user.id, p_active: snapshot.active, p_valid_until: snapshot.validUntil,
      p_checked_at: snapshot.checkedAt, p_product_id: snapshot.productId,
    });
    if (writeError) return json({ error: "Verification temporarily unavailable" }, 503);
    // Existing CE/owner grants remain valid, independently of this subscription.
    const { data: active, error: accessError } =
      await userClient.rpc("has_clinical_premium_access");
    if (accessError || typeof active !== "boolean") return json({ error: "Verification unavailable" }, 503);
    return json({ user_id: user.id, active });
  } catch (_) {
    // No tokens, receipt data, email, or provider response logged.
    return json({ error: "Verification temporarily unavailable" }, 503);
  }
});
