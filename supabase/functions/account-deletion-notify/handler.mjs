// Server-only dispatcher: no erasure or caller-controlled email payload.
const reply = (status, data) => new Response(JSON.stringify(data), {
  status, headers: { "Content-Type": "application/json", "Cache-Control": "no-store" },
});
export function createHandler({ authorize, configured, claim, send, finish, healthy }) {
  return async (req) => {
    if (req.method !== "POST") return reply(405, { error: "method_not_allowed" });
    try {
      if (!await authorize(req.headers.get("x-deletion-worker-token") ?? "")) {
        return reply(401, { error: "unauthorized" });
      }
    } catch {
      return reply(503, { error: "authorization_unavailable" });
    }
    if (!configured) return reply(503, { error: "not_configured" });
    // Body intentionally unused: this endpoint ONLY drains stored jobs.
    let accepted = 0, failed = 0;
    try {
      const jobs = await claim();
      for (const job of jobs) {
        let providerId = null;
        let errorCode = null;
        try {
          providerId = await send(job);
          if (!providerId) throw new Error("missing_receipt");
        } catch {
          errorCode = "provider_send_failed"; // Never log provider bodies or PII.
        }
        // A failed save preserves the lease/idempotency key for safe retry.
        const recorded = await finish(job, providerId, errorCode);
        if (recorded && providerId) accepted++;
        else failed++;
      }
      if (failed === 0) await healthy();
      return reply(failed ? 503 : 200, { accepted, failed });
    } catch {
      return reply(503, { error: "queue_unavailable" });
    }
  };
}

export async function sendMail(job, key, fetcher = fetch) {
  const response = await fetcher("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${key}`,
      "Content-Type": "application/json",
      "Idempotency-Key": `luma-deletion-${job.id}`,
    },
    body: JSON.stringify({
      from: "CE HALO <info@cehalo.com>", reply_to: "info@cehalo.com",
      to: [job.recipient], subject: job.subject, text: job.body,
    }),
    signal: AbortSignal.timeout(10_000),
  });
  if (!response.ok) throw new Error("provider_send_failed");
  const receipt = await response.json();
  if (typeof receipt.id !== "string" || !receipt.id) throw new Error("missing_receipt");
  return receipt.id;
}
