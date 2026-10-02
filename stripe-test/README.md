# CE HALO Test-Only Stripe Preparation

Prepared for `ce-web/portal-setup` only. This is disabled-by-default source code, not an activated payment system. Nothing in this folder should be deployed or installed in the shared Luma production project without a separate review and approval.

## Test setup update, October 2, 2026

The owner approved an isolated Supabase project, `mgmvjvzprxyylezheqos` (CE HALO Website Test), schema installation, and disabled backend deployment. The original preparation checklist below describes the initial commit, not the current infrastructure state. The Mac subsequently passed all 36 selected Flutter tests, targeted analysis, and a release web build; local signed-in and signed-out screens were checked.

The hosted backend now obtains its database credential from its own Supabase environment; manually copying `CE_TEST_LEDGER_SERVICE_KEY` is no longer required. The configured ledger URL must match the runtime's own project URL, and the existing production-host prohibition still applies. New `sb_secret_` credentials use only the `apikey` header, with legacy credentials supported as a fallback, following [Supabase's key migration guidance](https://supabase.com/docs/guides/getting-started/migrating-to-new-api-keys).

GET `/setup-status` returns only the test-mode flag, whether configuration validates, missing setting names, and fixed error messages. It never returns environment values, keys, account IDs, or tokens; it makes no external requests, writes nothing, and cannot enable checkout. A ready result means configuration is structurally complete, not that key permissions, price amounts or webhook delivery have passed end-to-end testing.

The backend test suite now contains 39 passing local Node/PGlite tests, including automatic project-bound credential resolution, modern/legacy headers, and non-secret readiness checks. Existing production code, mobile files and the Flutter UI were not changed by this follow-up.

## Current status

- **Prepared:** A website-scoped paywall, same-account checks, Stripe-hosted test Checkout backend, signed-webhook verification, isolated test-order database draft, and automated tests.
- **Not activated:** No Stripe keys, sandbox prices, webhook endpoint, test database, or deployment was created by this preparation. The existing hosted website has not been replaced.
- **No real fulfillment:** Test payments only record simulated ownership and simulated bonus-month counts in the separate test ledger. They do not unlock production courses, create official certificates, change progress, or award real complimentary access.
- **Mobile preserved:** `main`, mobile login, native RevenueCat/Apple/Google code, existing production SQL, course repositories, and CE award logic are not modified. This work does not complete Google Play CE billing.
- **Flutter verification pending:** The sandbox used for preparation does not contain the project's compatible Flutter SDK. The nine new Flutter tests, existing Flutter regression tests, analyzer, release web build, and browser layout checks still need to run on the Mac before any upload.

## What changes in the website

`lib/ce_portal_main.dart` wraps the existing CE app in `CeWebCheckoutScope`. Only screens under this scope use the new website purchase screen. The mobile entry point continues to use its existing paywall.

Ordinary builds show “Website checkout not enabled.” The explicit test flag and a separate test-backend URL are both required to offer test Checkout. A permanent Luma sign-in, an approved account UUID, verified purchase history, an allowed website origin, and server-verified test prices are also required.

Recognized, non-revoked Apple purchase records show “Open course” rather than another purchase. The original course repository remains responsible for actual course access and progress; a paywall label is not an entitlement grant. Unknown active store/product mappings block checkout for review rather than guessing ownership.

If an account already owns part of the bundle, the test integration blocks a bundle purchase and directs the learner to unowned individual courses. Discounted bundle upgrades require a separately approved policy. Manual/admin grants and other access mechanisms are not inferred from the purchase ledger; existing course-library access is unchanged and those mechanisms require review before a real-money launch.

## How the prepared connection works

1. The learner signs in through the existing Luma account flow.
2. The browser sends its signed-in access token and a product code to the separate test backend.
3. The backend validates the user with Luma's existing authentication service and reads only that user's RLS-protected purchase history. It does not have a production service-role key.
4. The backend checks its tester allowlist, prevents known duplicate purchases, verifies a test-mode Stripe price, and reserves an isolated test order.
5. Stripe-hosted Checkout receives the server-chosen price and Luma account UUID. No amount, identity, price ID, or return destination is trusted from the browser.
6. A signed webhook is independently rechecked against Stripe's session, payment, charge, account, amount, currency, and product.
7. Only the separate test ledger is updated. Returning to a success URL does not prove payment; the learner refreshes account/test status.

Stripe-hosted Checkout and webhook-driven fulfillment are the relevant integration mechanisms, rather than a requirement to install an app from the Stripe marketplace ([hosted Checkout](https://docs.stripe.com/payments/accept-a-payment?payment-ui=checkout&ui=stripe-hosted), [Checkout fulfillment](https://docs.stripe.com/checkout/fulfillment), [Stripe Apps overview](https://docs.stripe.com/stripe-apps/how-stripe-apps-work)).

## Safety and bonus behavior

- **Isolation:** Backend configuration rejects live Stripe secret keys, the four known live price IDs, a ledger on the same host as authentication, and the known Luma production host as a ledger target. Stripe responses must independently report `livemode=false`.
- **No shared production writes:** Authentication and purchase-history access use GET requests with the existing public publishable key and learner token. Order/event writes go only to the configured separate test project.
- **Account binding:** The server takes identity from the validated Luma user, never from email text or browser-supplied metadata. Only explicitly approved permanent-account UUIDs can use the test backend.
- **Duplicate handling:** Per-account database locks, persistent order IDs, Stripe idempotency keys, unique session/payment IDs, and processed-event records prevent repeated awards. One pending test checkout per account is allowed.
- **Bonus simulation:** First individual course awards one simulated month once. Bundle awards up to three total, or two after a prior one-month award. Real historical awards and prior simulated awards count toward the three-month lifetime cap, including refunded awards. Actual dates/subscriptions are never written.
- **Refund handling:** Any partial refund or dispute conservatively removes simulated ownership. A delayed completion cannot resurrect refunded simulated ownership. The simulated lifetime award count is not reset.
- **Incomplete history:** Missing, truncated, unmapped, or inconsistent purchase history blocks new checkout rather than risking a duplicate purchase.
- **Secrets:** Server keys must never appear in Dart, `--dart-define`, Git, browser bundles, chat, or screenshots. Stripe recommends restricting access to secret keys and keeping them server-side ([key best practices](https://docs.stripe.com/keys-best-practices)).

The database schema stays outside `supabase/migrations` and the server stays outside `supabase/functions`, so ordinary production deployment commands do not discover them.

## Tests run during preparation

The 35 Node/PGlite tests passed using local fixtures and an in-memory PostgreSQL-compatible database. They cover authentication/origin rejection, live-mode rejection, server-selected prices and identity, current payment validation, real HMAC signature checks, duplicate and out-of-order events, refund/dispute handling, ownership overlap, bonus caps, isolated writes, SQL permissions, and production-shaped schema rejection.

These are not real Stripe transactions or deployed Supabase integration tests. PGlite exercises the SQL but does not establish hosted PostgREST configuration, cross-project JWT behavior, concurrent multi-connection behavior, real webhook delivery, or device/browser correctness.

To rerun the backend tests with Node 20 or newer:

```sh
cd stripe-test
npm install --ignore-scripts
npm test
```

To verify Flutter on the Mac from the website project folder:

```sh
flutter pub get
flutter analyze lib/ce/web/ce_web_checkout.dart lib/ce/ce_purchase_screen.dart lib/ce_portal_main.dart test/ce_web_checkout_test.dart
flutter test test/ce_web_checkout_test.dart test/ce_paywalls_test.dart test/subscription_billing_test.dart test/social_auth_test.dart
flutter build web --release -t lib/ce_portal_main.dart
```

The ordinary build above keeps Stripe test checkout disabled. Do not upload it until the tests and local preview are checked. Do not run `flutter upgrade` or merge mobile `main` just to perform this preparation.

## Next setup sequence, one stage at a time

1. **Review and local verification:** Bring this branch into the separate Mac website folder, run Flutter checks, then preview locally. Leave the existing mobile folder alone.
2. **Approve sandbox resources:** Confirm creation/use of a Stripe sandbox, four sandbox one-time prices, a separate Supabase test project, the test website origin, and the tester account UUIDs. No marketplace app installation is required for this direct implementation.
3. **Install only in the approved test project:** Review and manually apply `draft-schema.sql`. Confirm the project is not `xuckkusbbcxplpqclbxt`. The installation guard also refuses known production-shaped tables.
4. **Configure the test backend securely:** Supply the server-only values below through the deployment provider's secret settings. Never paste keys into chat or the Flutter build.
5. **Deploy only after separate approval:** A developer should place the three server files together in a dedicated `ce-stripe-test` Edge Function in the isolated project. Routes are POST `/checkout`, POST `/status`, and POST `/webhook`.
6. **Review gateway authentication:** A Luma JWT belongs to a different project from the test function, and Stripe sends no Supabase JWT. The dedicated test function therefore needs a gateway configuration that permits these requests to reach its own validation. If using Supabase's `verify_jwt=false`, scope it only to this isolated test function; the code must still validate every learner token and every webhook signature. Never change production function or global auth settings for this purpose.
7. **Register the sandbox webhook:** Use only the isolated function's `/webhook` URL, with `checkout.session.completed`, `checkout.session.async_payment_succeeded`, `checkout.session.expired`, `charge.refunded`, and `charge.dispute.created`. Store its signing secret securely. Test actual raw-body signature validation and retries before browser testing ([Stripe webhooks](https://docs.stripe.com/webhooks/quickstart)).
8. **Build a private test website:** Only after the backend and origin are approved, supply the two public Flutter flags described below. Keep normal builds disabled. Do not replace a public/live website with a tester-only build unintentionally.
9. **Run end-to-end acceptance tests:** Use an approved non-admin Luma account. Test a successful sandbox card purchase, cancellation, decline, reload, duplicate clicks, delayed/duplicate webhook, sign-out/account switch, known mobile ownership, partial-bundle ownership, refund, and dispute. Verify test rows appear and no production course/bonus rows change.
10. **Plan live fulfillment separately:** Approve real Stripe-to-course entitlement mapping, refund policy, Google product mapping, complimentary-access reconciliation, bundle-upgrade policy, tax configuration, and production rollout before any live payment is enabled.

This is a staged test integration, not a production-ready payment launch. Stripe tax behavior for the existing products has not been established by this work. There is deliberately no real-money toggle in this draft: a production version needs separate code review and approval.

## Configuration reference

### Server-only environment

| Variable | Required value |
|---|---|
| `CE_STRIPE_TEST_ENABLED` | Exactly `true`; otherwise backend is disabled |
| `STRIPE_TEST_SECRET_KEY` | Sandbox/test secret or suitable restricted key beginning `sk_test_` or `rk_test_` |
| `STRIPE_TEST_WEBHOOK_SECRET` | Signing secret for the isolated sandbox endpoint, beginning `whsec_` |
| `CE_TEST_PORTAL_ORIGIN` | Exact approved origin, no path/query; HTTPS, or local HTTP for `localhost` / `127.0.0.1` |
| `LUMA_AUTH_SUPABASE_URL` | Existing Luma project URL, read-only auth/ownership validation |
| `LUMA_AUTH_PUBLIC_KEY` | Existing `sb_publishable_` key, not a service-role/secret key |
| `CE_TEST_LEDGER_URL` | Separate approved HTTPS Supabase test project, never the Luma project |
| `CE_TEST_LEDGER_SERVICE_KEY` | Service-role credential from that separate test project only |
| `CE_TEST_USER_IDS` | Comma-separated permanent Luma account UUIDs approved for testing |
| `STRIPE_TEST_PRICE_MEDICATION` | Separately created sandbox price, USD 24999 cents, one-time |
| `STRIPE_TEST_PRICE_UNCOMMON` | Separately created sandbox price, USD 24999 cents, one-time |
| `STRIPE_TEST_PRICE_LEGAL` | Separately created sandbox price, USD 24999 cents, one-time |
| `STRIPE_TEST_PRICE_BUNDLE` | Separately created sandbox price, USD 69999 cents, one-time |

The adapter pins `Stripe-Version: 2024-06-20`. Compatibility of the complete request with the selected sandbox must be confirmed in the real API acceptance test. No Stripe API creation call has been made by the unit tests.

### Public Flutter flags, only after test deployment approval

| Flag | Purpose |
|---|---|
| `LUMA_CE_STRIPE_TEST_ENABLED=true` | Explicitly enables the tester-only checkout interface |
| `LUMA_CE_STRIPE_TEST_ENDPOINT` | HTTPS base URL of the dedicated test function, without a trailing action such as `/checkout` |

Both are non-secret settings. The existing production auth backend URL is rejected as a test endpoint. Do not put any Stripe key, signing secret, or database service key in these flags.

### Operational limitations to resolve in sandbox

- **Pending orders:** An interrupted session-creation attempt is retried with the same idempotency key for up to 25 minutes. The draft sets session expiration to one hour from reservation, leaving at least 30 minutes when it is created, consistent with Stripe's documented minimum ([Checkout Session creation](https://docs.stripe.com/api/checkout/sessions/create)). Older unresolved reservations stop new checkouts until an operator reconciles them; no blind second payment is opened.
- **Manual refresh:** The learner must refresh account/test status after returning from Checkout. There is no background polling or scheduled reconciliation service in this draft.
- **Refunds/disputes:** Simulated revocation is conservative and terminal. Successful dispute reversal or partial-refund restoration needs a reviewed future policy.
- **Rate limits:** Before exposing any test endpoint, review per-user request limits, hosting limits, payload limits, and error monitoring. The allowlist is not a substitute for operational controls.
- **Test database install:** The schema is a fresh-install draft, not an idempotent migration for rerunning over a populated project. Back up/review before later schema changes.
- **Shared progress:** This draft continues using the existing learning repository. Cross-device progress, evaluations, quizzes, certificate eligibility, and account recovery must still be checked in the intended browser environment; no test receipt bypasses their existing rules.

## Exact source boundaries

Existing files changed:

- `lib/ce_portal_main.dart`: website-only scope wrapper.
- `lib/ce/ce_purchase_screen.dart`: scope-based switch to the website screen.

New files:

- `lib/ce/web/ce_web_checkout.dart`
- `test/ce_web_checkout_test.dart`
- `stripe-test/server/core.mjs`
- `stripe-test/server/adapters.mjs`
- `stripe-test/server/index.ts`
- `stripe-test/draft-schema.sql`
- `stripe-test/tests/core.test.mjs`
- `stripe-test/tests/schema.test.mjs`
- `stripe-test/package.json`
- `stripe-test/README.md`

No modification to `lib/main.dart`, native billing implementation, shared Supabase configuration, existing course repositories, production functions/migrations, mobile platform folders, or dependency/release versions is part of this preparation.
