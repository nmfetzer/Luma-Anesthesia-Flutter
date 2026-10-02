import { createClient } from "npm:@supabase/supabase-js@2.99.3";
import { createHandler, sendMail } from "./handler.mjs";

const url = Deno.env.get("SUPABASE_URL") ?? "";
const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const mailKey = Deno.env.get("RESEND_API_KEY") ?? "";
const configured = !!url && !!service && !!mailKey;
const client = url && service ? createClient(url, service, {
  auth: { persistSession: false, autoRefreshToken: false },
}) : null;
async function rpc(name: string, args = {}) {
  if (!client) throw new Error("not_configured");
  const { data, error } = await client.rpc(name, args);
  if (error) throw new Error("queue_unavailable");
  return data;
}
Deno.serve(createHandler({
  configured,
  async authorize(value: string) {
    if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.test(value)) {
      return false;
    }
    return await rpc("luma_consume_deletion_worker_token", { p_token: value }) === true;
  },
  claim: () => rpc("luma_deletion_claim_mail"),
  send: (job: {id: string; recipient: string; subject: string; body: string}) =>
    sendMail(job, mailKey),
  finish: (job: {id: string; lease_token: string}, providerId: string | null, code: string | null) =>
    rpc("luma_deletion_finish_mail", {
      p_id: job.id, p_lease: job.lease_token, p_provider_id: providerId, p_error_code: code,
    }),
  healthy: () => rpc("luma_deletion_worker_healthy"),
}));
