// Recovers Apple CE purchases the webhook could not attribute (offer-code
// redemptions outside the app, guest-session aliases, restore transfers).
// Source of truth is RevenueCat's server REST response for the signed-in
// account, never client CustomerInfo. Granting stays in the existing
// record_verified_ce_bonus RPC, which rejects guests, refuses to move a
// transaction between accounts, honors refunds and enforces the bonus cap.
export const appleCeProducts = new Set([
  "Medication_Review_for_the_Experienced_CRNA",
  "uncommon_anesthesia_events",
  "legal_essentials_CRNA",
  "3_course_bundle_pack",
]);

export type CePurchase = {
  transactionId: string;
  productId: string;
  purchasedAt: string;
};

function record(value: unknown): Record<string, any> | null {
  return value && typeof value === "object" && !Array.isArray(value)
    ? value as Record<string, any>
    : null;
}

/** Production App Store CE purchases owned by this RevenueCat customer. */
export function verifiedCePurchases(body: unknown, now: number): CePurchase[] {
  const data = record(body);
  const subscriber = record(data?.subscriber);
  const checked = data?.request_date_ms;
  if (
    !subscriber || typeof checked !== "number" || !Number.isFinite(checked) ||
    Math.abs(checked - now) > 5 * 60_000
  ) return [];
  const all = record(subscriber.non_subscriptions);
  if (!all) return [];
  const result: CePurchase[] = [];
  for (const productId of appleCeProducts) {
    const entries = all[productId];
    if (!Array.isArray(entries)) continue;
    for (const raw of entries) {
      const e = record(raw);
      if (!e) continue;
      // Production Apple purchases only. Sandbox/reviewer grants keep their
      // own isolated path; Family Sharing still requires manual review.
      if (e.store !== "app_store" || e.is_sandbox !== false) continue;
      if (e.ownership_type != null && e.ownership_type !== "PURCHASED") continue;
      if (e.refunded_at) continue;
      const id = e.store_transaction_id;
      if (typeof id !== "string" || !id.trim() || id.length > 256) continue;
      const purchased = Date.parse(e.purchase_date);
      if (!Number.isFinite(purchased) || purchased > now + 5 * 60_000) continue;
      result.push({
        transactionId: id,
        productId,
        purchasedAt: new Date(purchased).toISOString(),
      });
    }
  }
  return result;
}
