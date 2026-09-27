# Luma Anesthesia Apple Purchase Wiring

Deployed September 27, 2026 after explicit owner approval. This implements guarded Apple CE checkout and the subscription verifier. It is not submission clearance or evidence of a real Apple purchase.

## Changes

- **CE purchase screen:** lists the three exact individual Apple products and bundle from RevenueCat offering `crna_courses`. Price labels come from the store, never a hard-coded charge.
- **One billing coordinator:** subscriptions and CE share the same identity and busy lock. Account changes invalidate pending results. Course purchases never start a subscription.
- **Server-authoritative access:** the Flutter SDK cannot grant CE ownership or clinical bonuses. Purchases call native checkout; the existing authenticated CE webhook records verified production transactions; the client reads server status. Delayed fulfillment tells the customer to refresh, not pay again.
- **Restore:** invokes RevenueCat restore under the permanent Supabase UUID, then reads the verified server ownership ledger. It does not award a new bonus. A historical purchase that predates the webhook and is absent from Supabase still needs verified server-side reconciliation; merely restoring is not guaranteed to replay an old webhook.
- **Catalog checks:** `luma_ce_checkout_status()` reports only the caller's ownership and release readiness. Purchases require enabled product mapping, a released course, approved/enabled certificate settings, loaded module metadata and the approved October 1, 2026 through September 30, 2029 course period. The bundle requires all three courses ready. This is not a clinical/content audit; provider release remains necessary.
- **Mappings:** individual and bundle Apple mappings are added for each existing course table. A missing course schema fails closed and needs its mappings added after that schema arrives.
- **Subscription verifier:** `revenuecat-sync` checks Supabase Auth, independently requests the RevenueCat subscriber, validates exact product/store/expiry, and records at most a 15-minute clinical-access lease. No client UUID, receipt or entitlement assertion is trusted. Owner/manual and existing CE access are preserved.

## Flags and unchanged scope

Both Flutter flags default to false:

```text
LUMA_BILLING_ENABLED
LUMA_CE_BILLING_ENABLED
```

The new CE flag is Apple-only. Android product IDs, Google configuration, existing RevenueCat webhooks, course content, certificate designs, and the three-month bonus algorithm are not changed.

The new subscription endpoint stays unavailable unless `LUMA_BILLING_SERVER_ENABLED=true` and all required secrets are present. The deployment does not set that flag, add a RevenueCat key, release courses, approve certificates, enable product grants or change App Store availability.

## Deployment payload

- Migration: `supabase/migrations/20260927193822_apple_purchase_wiring.sql`, version aligned with the live Supabase migration.
- New edge function: `supabase/functions/revenuecat-sync/`, deployed with JWT verification enabled.
- Existing CE webhook: unchanged.
- Intended project: `xuckkusbbcxplpqclbxt`.
- Intended GitHub branch: `nmfetzer/Luma-Anesthesia-Flutter`, `main`, preserving concurrent commits.

The live migration and JWT-protected `revenuecat-sync` version 1 were deployed. Production rollback-only access tests passed; zero subscription-access rows remain. All four Apple CE product flags remain false. Course 2 and Course 3 now each have their individual and bundle Apple ownership mappings. No secrets were changed.

Do not apply the older `supabase/billing-draft/revenuecat_access.sql` after this migration. It is an archived design input, not the canonical deployment.

## Tests completed locally

- **Flutter:** 50 targeted tests passed across CE billing and storefront, existing subscriptions/paywall, CE learning, account information/recovery, and native store identifiers.
- **Analyzer:** no issues in the changed billing code, CE screen, CE storefront and new tests.
- **Deno:** 15 subscription validation/handler tests passed; 35 existing CE webhook tests passed. New edge entrypoint type-check passed.
- **PostgreSQL:** migration applied in isolated local PostgreSQL; new access/readiness/privilege checks, existing lifetime-cap tests, and CE webhook idempotency/refund tests passed with rollback fixtures.

These are automated checks, not signed-iPhone StoreKit, TestFlight or App Review tests. No customer was charged.

## Remaining launch gates

- **Correct keys:** the owner supplied the Apple public `appl_...` SDK key from the Luma Anesthesia App (App Store) row on September 27; it is now the Flutter configuration default, with build-time override supported. This does not enable purchasing or establish a successful native connection. `appbafd32b582` is an app identifier, not that key. The existing secret key labeled `Perplexity`, API version 1, was visible masked in the owner's RevenueCat screenshot; its value still needs to be stored directly in Supabase as `REVENUECAT_SECRET_API_KEY`, never in Flutter, chat or GitHub. The two similarly named saved Computer credentials have not been selected arbitrarily.
- **Sandbox/App Review:** current production handlers intentionally reject sandbox grants. This change does not solve review-environment fulfillment. A secure review/sandbox path must be implemented and exercised using the exact intended submission build before upload. Simply testing a different backend and shipping a production build that rejects review purchases is not sufficient.
- **Course readiness:** all three catalogs, learning routes, quizzes, evaluations, certificate issuance, product mappings and release flags must be checked after the concurrent content work finishes. The third course must be complete before its individual product or the bundle is activated.
- **Restore history and transfers:** test existing customers, new users, sign-out, a second device, refunds, pending payments, and the configured RevenueCat restore/transfer policy. If any CE courses were sold before this webhook, reconcile their verified transactions into Supabase before promising restore coverage.
- **Store setup:** complete the Apple agreements/tax/banking and IAP metadata, confirm the offering/package mappings and Apple credentials, and submit the applicable IAPs with the app version.
- **Native acceptance:** verify both subscription terms, each individual course, bundle-first, course-then-bundle (one plus two months), restored purchases, refunds, and course certificate flow on signed iOS builds.

Customer sales must remain disabled until these gates are complete.
