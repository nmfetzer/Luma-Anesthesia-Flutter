import { createClient } from "npm:@supabase/supabase-js@2.99.3";
import { createHandler } from "./handler.ts";

const url = Deno.env.get("SUPABASE_URL") ?? "";
const anon = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const rcKey = Deno.env.get("REVENUECAT_SECRET_API_KEY") ?? "";
const enabled = Deno.env.get("LUMA_BILLING_SERVER_ENABLED") === "true" &&
  !!url && !!anon && !!serviceKey && !!rcKey;
const options = { auth: { persistSession: false, autoRefreshToken: false } };
const userClient = (authorization: string) => createClient(url, anon, {
  ...options, global: { headers: { Authorization: authorization } },
});

Deno.serve(createHandler({
  enabled,
  async reviewAllowed(authorization, userId) {
    const { data, error } = await userClient(authorization).rpc("luma_billing_policy");
    if (error || data?.user_id !== userId || typeof data.apple_review !== "boolean") {
      throw new Error("Billing policy unavailable");
    }
    return data.apple_review;
  },
  now: Date.now,
  async user(authorization) {
    const { data: { user }, error } = await userClient(authorization).auth.getUser();
    return error || !user || user.is_anonymous ? null : user.id;
  },
  async subscriber(userId) {
    const response = await fetch(
      `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(userId)}`,
      { headers: { Authorization: `Bearer ${rcKey}`, Accept: "application/json" },
        signal: AbortSignal.timeout(10_000) },
    );
    if (!response.ok) throw new Error("Provider unavailable");
    return await response.json();
  },
  async record(userId, snapshot, sandbox) {
    const rpc = sandbox ? "record_revenuecat_sandbox_access" : "record_revenuecat_access";
    const { error } = await createClient(url, serviceKey, options).rpc(rpc, {
      p_user_id: userId, p_active: snapshot.active, p_valid_until: snapshot.validUntil,
      p_checked_at: snapshot.checkedAt, p_product_id: snapshot.productId,
    });
    if (error) throw new Error("Storage unavailable");
  },
  async access(authorization) {
    const { data, error } = await userClient(authorization).rpc("has_clinical_premium_access");
    if (error) throw new Error("Access unavailable");
    return data;
  },
}));
