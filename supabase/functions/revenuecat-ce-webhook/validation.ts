// This parser accepts only authenticated RevenueCat server notifications.
// Never pass client CustomerInfo or an unverified purchase payload to it.
export const appleProducts = new Set([
  "Medication_Review_for_the_Experienced_CRNA",
  "uncommon_anesthesia_events",
  "legal_essentials_CRNA",
  "3_course_bundle_pack",
]);
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
export class InvalidEvent extends Error {}
export class ReviewRequired extends Error {}
export type CeEvent = {
  environment: "PRODUCTION" | "SANDBOX";
  eventId: string;
  kind: "NON_RENEWING_PURCHASE" | "CANCELLATION";
  appId: string;
  transactionId: string;
  productId: string;
  userId: string | null;
  purchasedAt: string;
  occurredAt: string;
};
function object(value: unknown): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new InvalidEvent("Object required");
  }
  return value as Record<string, unknown>;
}
function text(value: unknown): string {
  if (typeof value !== "string" || !value.trim() || value.length > 256) {
    throw new InvalidEvent("Invalid identifier");
  }
  return value;
}
function timestamp(value: unknown, now: number): string {
  if (
    typeof value !== "number" || !Number.isSafeInteger(value) ||
    value <= 0 || value > now + 300_000
  ) {
    throw new InvalidEvent("Invalid timestamp");
  }
  return new Date(value).toISOString();
}
export function parseEvent(
  body: unknown,
  expectedApp: string,
  now = Date.now(),
  allowSandbox = false,
): CeEvent | { ignored: string } {
  const envelope = object(body);
  if (envelope.api_version !== "1.0") {
    throw new InvalidEvent("Unknown API version");
  }
  const e = object(envelope.event);
  const kind = text(e.type);
  // Dashboard test events must never create a purchase or clinical grant.
  if (kind === "TEST") return { ignored: "test" };
  // Transfers can lack app/store/environment. Do not silently acknowledge one.
  if (kind === "TRANSFER" && (!e.app_id || e.app_id === expectedApp)) {
    throw new ReviewRequired("Transfer requires review");
  }
  if (e.app_id !== expectedApp) return { ignored: "other_app" };
  if (
    e.environment !== "PRODUCTION" &&
    !(allowSandbox && e.environment === "SANDBOX")
  ) {
    return { ignored: "non_production" };
  }
  // Transfers are not purchases and must not move a lifetime bonus to another account.
  if (e.store !== "APP_STORE") return { ignored: "other_store" };
  if (typeof e.product_id !== "string" || !appleProducts.has(e.product_id)) {
    return { ignored: "other_product" };
  }
  if (kind === "REFUND_REVERSED") {
    throw new ReviewRequired("Refund reversal requires review");
  }
  if (kind !== "NON_RENEWING_PURCHASE" && kind !== "CANCELLATION") {
    return { ignored: "other_event" };
  }
  if (kind === "CANCELLATION" && e.cancel_reason !== "CUSTOMER_SUPPORT") {
    throw new ReviewRequired("Unrecognized CE cancellation reason");
  }
  if (e.is_family_share !== false) {
    throw new ReviewRequired("Family sharing requires review");
  }
  if (e.expiration_at_ms !== null) {
    throw new ReviewRequired("Unexpected expiring CE product");
  }
  let userId: string | null = null;
  if (kind === "NON_RENEWING_PURCHASE") {
    if (!Array.isArray(e.aliases)) throw new InvalidEvent("Missing aliases");
    const identities = [e.app_user_id, e.original_app_user_id, ...e.aliases];
    const users = new Set(
      identities.filter(
        (id): id is string => typeof id === "string" && uuid.test(id),
      ).map((id) => id.toLowerCase()),
    );
    if (users.size !== 1) {
      throw new ReviewRequired("Permanent account identity is ambiguous");
    }
    userId = [...users][0];
  }
  // Refunds are keyed to the original transaction even if aliases later change.
  return {
    environment: e.environment as "PRODUCTION" | "SANDBOX",
    eventId: text(e.id),
    kind,
    appId: text(e.app_id),
    transactionId: text(e.transaction_id),
    productId: e.product_id,
    userId,
    purchasedAt: timestamp(e.purchased_at_ms, now),
    occurredAt: timestamp(e.event_timestamp_ms, now),
  };
}

export async function authorized(
  received: string | null,
  secret: string,
): Promise<boolean> {
  if (!received || received.length > 1024 || secret.length < 32) return false;
  const encode = new TextEncoder();
  const a = new Uint8Array(
    await crypto.subtle.digest("SHA-256", encode.encode(received)),
  );
  const b = new Uint8Array(
    await crypto.subtle.digest("SHA-256", encode.encode(`Bearer ${secret}`)),
  );
  let different = 0;
  for (let i = 0; i < a.length; i++) different |= a[i] ^ b[i];
  return different === 0;
}
