import { verifiedSnapshot, entitlement } from "./validation.ts";
const now = Date.parse("2026-09-27T16:00:00Z");
function fixture(product = "Luma_Anesthesia_App_Monthly", store = "app_store") {
  return { request_date_ms: now, subscriber: {
    entitlements: { [entitlement]: {
      product_identifier: product, purchase_date: "2026-09-01T00:00:00Z",
      expires_date: "2026-10-01T00:00:00Z",
    } },
    subscriptions: { [product]: { store, is_sandbox: false,
      expires_date: "2026-10-01T00:00:00Z", refunded_at: null as string | null } },
  } };
}
function assert(condition: unknown) { if (!condition) throw new Error("Assertion failed"); }
Deno.test("approved monthly product gets at most a 15-minute lease", () => {
  const result = verifiedSnapshot(fixture(), now);
  assert(result.active);
  assert(Date.parse(result.validUntil) === now + 15 * 60_000);
});
Deno.test("wrong app and wrong store rejected", () => {
  assert(!verifiedSnapshot(fixture("Luma_Nurse_Monthly"), now).active);
  assert(!verifiedSnapshot(fixture("Luma_Anesthesia_App_Monthly", "stripe"), now).active);
});
Deno.test("Google product and base plan form accepted", () => {
  assert(verifiedSnapshot(fixture("luma_anesthesia_yearly_pro:yearly", "play_store"), now).active);
});
Deno.test("sandbox denied by default, allowed only with explicit test setting", () => {
  const f = fixture();
  f.subscriber.subscriptions.Luma_Anesthesia_App_Monthly.is_sandbox = true;
  assert(!verifiedSnapshot(f, now).active);
  assert(verifiedSnapshot(f, now, true).active);
});
Deno.test("refund and expiration rejected", () => {
  const f = fixture();
  f.subscriber.subscriptions.Luma_Anesthesia_App_Monthly.refunded_at = new Date(now).toISOString();
  assert(!verifiedSnapshot(f, now).active);
  const expired = fixture();
  expired.subscriber.entitlements[entitlement].expires_date = "2026-09-01T00:00:00Z";
  assert(!verifiedSnapshot(expired, now).active);
});
Deno.test("missing entitlement is a valid inactive snapshot", () => {
  const f = fixture();
  assert(!verifiedSnapshot({ ...f, subscriber: {
    ...f.subscriber, entitlements: {},
  } }, now).active);
});
Deno.test("malformed and stale responses cannot create a grant", () => {
  for (const input of [{}, { subscriber: {} }, { ...fixture(), request_date_ms: now - 600_000 }]) {
    let threw = false;
    try { verifiedSnapshot(input, now); } catch { threw = true; }
    assert(threw);
  }
});
Deno.test("cancellation retains access until paid expiration", () => {
  const f = fixture();
  Object.assign(f.subscriber.subscriptions.Luma_Anesthesia_App_Monthly,
    { unsubscribe_detected_at: new Date(now).toISOString() });
  assert(verifiedSnapshot(f, now).active);
});
