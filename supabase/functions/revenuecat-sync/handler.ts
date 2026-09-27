import { verifiedSnapshot } from "./validation.ts";

export interface SyncDependencies {
  enabled: boolean;
  reviewAllowed(authorization: string, userId: string): Promise<boolean>;
  user(authorization: string): Promise<string | null>;
  subscriber(userId: string): Promise<unknown>;
  record(userId: string, snapshot: ReturnType<typeof verifiedSnapshot>, sandbox: boolean): Promise<void>;
  access(authorization: string): Promise<boolean>;
  now(): number;
}
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status, headers: { ...cors, "Content-Type": "application/json", "Cache-Control": "no-store" },
  });

export function createHandler(deps: SyncDependencies) {
  return async (request: Request): Promise<Response> => {
    if (request.method === "OPTIONS") return new Response("ok", { headers: cors });
    if (request.method !== "POST") return json({ error: "Method not allowed" }, 405);
    if (!deps.enabled) return json({ error: "Billing unavailable" }, 503);
    const authorization = request.headers.get("Authorization") ?? "";
    if (!authorization.startsWith("Bearer ")) return json({ error: "Sign in required" }, 401);
    try {
      // Body is deliberately ignored: no client-supplied UUID/receipt/access.
      const user = await deps.user(authorization);
      if (!user) return json({ error: "Sign in required" }, 401);
      const reviewer = await deps.reviewAllowed(authorization, user);
      const snapshot = verifiedSnapshot(await deps.subscriber(user), deps.now(), reviewer);
      if (snapshot.sandbox === true) {
        // Do not replace a production lease with a sandbox snapshot, even an
        // expired/refunded one. Ineligible sandbox receipts confer no access.
        if (reviewer) await deps.record(user, snapshot, true);
      } else {
        await deps.record(user, snapshot, false);
        // An empty/production response must also clear an old test lease.
        if (reviewer) await deps.record(user, { ...snapshot, active: false }, true);
      }
      const active = await deps.access(authorization);
      if (typeof active !== "boolean") throw new Error("Invalid access response");
      return json({ user_id: user, active });
    } catch {
      // Never log tokens, receipts, personal details or provider payloads.
      return json({ error: "Verification temporarily unavailable" }, 503);
    }
  };
}
