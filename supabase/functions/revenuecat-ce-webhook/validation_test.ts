import { appleProducts, authorized, parseEvent } from "./validation.ts";
import { assert, fixture, now, throws, user } from "./fixtures_test.ts";

for (const product of appleProducts) {
  Deno.test(`accept confirmed Apple product ${product}`, () => {
    const e = parseEvent(fixture({ product_id: product }), "apple-app", now);
    assert(!("ignored" in e) && e.userId === user && e.productId === product);
    assert(e.purchasedAt === new Date(now - 86400000).toISOString());
  });
}
for (
  const [field, value, reason] of [
    ["app_id", "other-app", "other_app"],
    ["store", "PLAY_STORE", "other_store"],
    ["environment", "SANDBOX", "non_production"],
    ["product_id", "Luma_Anesthesia_App_Monthly", "other_product"],
    ["type", "RENEWAL", "other_event"],
  ] as const
) {
  Deno.test(`ignore ${reason}`, () => {
    const e = parseEvent(fixture({ [field]: value }), "apple-app", now);
    assert("ignored" in e && e.ignored === reason);
  });
}
Deno.test("dashboard test never grants", () => {
  const e = parseEvent(
    { api_version: "1.0", event: { type: "TEST" } },
    "apple-app",
    now,
  );
  assert("ignored" in e && e.ignored === "test");
});
Deno.test("explicit isolated test mode accepts sandbox", () => {
  const e = parseEvent(
    fixture({ environment: "SANDBOX" }),
    "apple-app",
    now,
    true,
  );
  assert(!("ignored" in e));
});
Deno.test("anonymous alias plus exactly one account resolves safely", () => {
  const e = parseEvent(
    fixture({
      app_user_id: "$RCAnonymousID:123",
      original_app_user_id: "$RCAnonymousID:123",
      aliases: [user],
    }),
    "apple-app",
    now,
  );
  assert(!("ignored" in e) && e.userId === user);
});
for (
  const changes of [
    { aliases: [user, "bbbbbbbb-bbbb-cccc-dddd-eeeeeeeeeeee"] },
    {
      app_user_id: "$RCAnonymousID:1",
      original_app_user_id: "$RCAnonymousID:1",
      aliases: [],
    },
    { aliases: null },
    { purchased_at_ms: now + 600000 },
    { purchased_at_ms: "2026-09-26" },
    { event_timestamp_ms: null },
    { transaction_id: "" },
    { is_family_share: true },
    { expiration_at_ms: now + 500000 },
    { type: "REFUND_REVERSED" },
    { type: "CANCELLATION", cancel_reason: "UNSUBSCRIBE" },
    { type: "TRANSFER", app_id: undefined, environment: undefined },
  ]
) {
  Deno.test(`reject unsafe event ${JSON.stringify(changes)}`, () =>
    throws(() => parseEvent(fixture(changes), "apple-app", now)));
}
Deno.test("refund uses transaction even after customer identity changed", () => {
  const e = parseEvent(
    fixture({
      type: "CANCELLATION",
      cancel_reason: "CUSTOMER_SUPPORT",
      app_user_id: "other",
      aliases: [],
      original_app_user_id: "other",
    }),
    "apple-app",
    now,
  );
  assert(!("ignored" in e) && e.kind === "CANCELLATION" && e.userId === null);
});
Deno.test("authorization fails closed", async () => {
  const secret = "test-only-not-a-real-secret-0123456789";
  assert(await authorized(`Bearer ${secret}`, secret));
  assert(!await authorized("Bearer wrong", secret));
  assert(!await authorized(null, secret));
  assert(!await authorized("Bearer short", "short"));
});
