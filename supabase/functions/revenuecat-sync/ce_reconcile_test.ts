import { verifiedCePurchases } from "./ce_reconcile.ts";
import { createHandler, type SyncDependencies } from "./handler.ts";
const now = Date.parse("2026-10-13T16:00:00Z");
function assert(value: unknown) { if (!value) throw new Error("Assertion failed"); }
const entry = (o: Record<string, unknown> = {}) => ({
  id: "rc1", is_sandbox: false, store: "app_store",
  store_transaction_id: "2000000123", purchase_date: "2026-10-13T15:03:40Z", ...o,
});
const body = (ns: Record<string, unknown>, at = now) => ({
  request_date_ms: at,
  subscriber: { entitlements: {}, subscriptions: {}, non_subscriptions: ns },
});
Deno.test("production Apple bundle redemption is recovered", () => {
  const r = verifiedCePurchases(body({ "3_course_bundle_pack": [entry()] }), now);
  assert(r.length === 1 && r[0].productId === "3_course_bundle_pack");
  assert(r[0].transactionId === "2000000123" && r[0].purchasedAt === "2026-10-13T15:03:40.000Z");
});
Deno.test("sandbox, other store, family share, refunded and unknown products skipped", () => {
  const r = verifiedCePurchases(body({
    "3_course_bundle_pack": [entry({ is_sandbox: true }), entry({ store: "play_store" }),
      entry({ ownership_type: "FAMILY_SHARED" }), entry({ refunded_at: "2026-10-13T15:30:00Z" })],
    "some_other_product": [entry()],
    "legal_essentials_CRNA": [entry({ store_transaction_id: "" }), entry({ purchase_date: "bad" })],
  }), now);
  assert(r.length === 0);
});
Deno.test("stale or malformed provider responses recover nothing", () => {
  assert(verifiedCePurchases(body({ "3_course_bundle_pack": [entry()] }, now - 10 * 60_000), now).length === 0);
  assert(verifiedCePurchases(null, now).length === 0);
  assert(verifiedCePurchases({ request_date_ms: now, subscriber: {} }, now).length === 0);
});
function deps(calls: string[]): SyncDependencies {
  return {
    enabled: true, reviewAllowed: async () => false, now: () => now,
    user: async () => "verified-user",
    subscriber: async () => body({ "3_course_bundle_pack": [entry()] }),
    record: async () => {}, access: async () => { calls.push("access"); return true; },
    reconcileCe: async (id, p) => { calls.push(`ce:${id}:${p.productId}`); },
  };
}
const req = () => new Request("https://example.test", {
  method: "POST", headers: { Authorization: "Bearer t" }, body: '{"user_id":"victim"}' });
Deno.test("handler reconciles for the verified account before reading access", async () => {
  const calls: string[] = [];
  const res = await createHandler(deps(calls))(req());
  assert(res.status === 200);
  assert(calls.join(",") === "ce:verified-user:3_course_bundle_pack,access");
});
Deno.test("CE reconcile failure never breaks subscription verification", async () => {
  const calls: string[] = [];
  const d = deps(calls); d.reconcileCe = async () => { throw new Error("db down"); };
  const res = await createHandler(d)(req());
  assert(res.status === 200 && (await res.json()).active === true);
});
