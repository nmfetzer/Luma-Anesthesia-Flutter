// Pure validation. No SDK/client entitlement data is accepted by this function.
export const entitlement = "Luma Anesthesia App Pro";
const apple = new Set(["Luma_Anesthesia_App_Monthly", "Luma_Anesthesia_Yearly_Pro"]);
const google = new Set([
  "luma_anesthesia_app_monthly", "luma_anesthesia_yearly_pro",
  "luma_anesthesia_app_monthly:monthly", "luma_anesthesia_yearly_pro:yearly",
]);

function object(value: unknown): Record<string, any> {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new Error("Malformed RevenueCat response");
  }
  return value as Record<string, any>;
}

export function verifiedSnapshot(body: unknown, now: number, allowSandbox = false) {
  const data = object(body);
  const subscriber = object(data.subscriber);
  const entitlements = object(subscriber.entitlements);
  const subscriptions = object(subscriber.subscriptions);
  const checked = data.request_date_ms;
  if (typeof checked !== "number" || !Number.isFinite(checked) ||
      Math.abs(checked - now) > 5 * 60_000) throw new Error("Stale provider response");
  const denied = { active: false, validUntil: new Date(now).toISOString(),
    checkedAt: new Date(checked).toISOString(), productId: null as string | null };
  const raw = entitlements[entitlement];
  if (!raw) return denied;
  const e = object(raw);
  const product = e.product_identifier;
  if (typeof product !== "string" || (!apple.has(product) && !google.has(product))) return denied;
  const s = object(subscriptions[product]);
  if ((apple.has(product) && s.store !== "app_store") ||
      (google.has(product) && s.store !== "play_store")) return denied;
  if (typeof s.is_sandbox !== "boolean" || (s.is_sandbox && !allowSandbox)) return denied;
  // Never infer lifetime access from null expiry. These are recurring products.
  const expires = Date.parse(e.expires_date);
  const subscriptionExpires = Date.parse(s.expires_date);
  const purchased = Date.parse(e.purchase_date);
  if (!Number.isFinite(expires) || !Number.isFinite(subscriptionExpires) ||
      !Number.isFinite(purchased) || purchased > now ||
      expires <= now || subscriptionExpires <= now || s.refunded_at) return denied;
  // Bounded lease: cancellation retains the paid term; refunds/transfers cannot
  // leave an indefinite DB grant if webhook delivery is absent.
  return { active: true, validUntil: new Date(Math.min(
    expires, subscriptionExpires, now + 15 * 60_000)).toISOString(),
    checkedAt: new Date(checked).toISOString(), productId: product };
}
