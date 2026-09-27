export const now = Date.UTC(2026, 8, 27, 16);
export const user = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee";
export const fixture = (overrides: Record<string, unknown> = {}) => ({
  api_version: "1.0",
  event: {
    id: "event-1",
    type: "NON_RENEWING_PURCHASE",
    app_id: "apple-app",
    store: "APP_STORE",
    environment: "PRODUCTION",
    product_id: "Medication_Review_for_the_Experienced_CRNA",
    transaction_id: "apple-transaction-1",
    app_user_id: user,
    original_app_user_id: user,
    aliases: [user],
    purchased_at_ms: now - 86400000,
    event_timestamp_ms: now - 1000,
    expiration_at_ms: null,
    is_family_share: false,
    ...overrides,
  },
});
export function assert(
  value: unknown,
  message = "Assertion failed",
): asserts value {
  if (!value) throw new Error(message);
}
export function throws(action: () => unknown) {
  let failed = false;
  try {
    action();
  } catch {
    failed = true;
  }
  assert(failed, "Expected rejection");
}
