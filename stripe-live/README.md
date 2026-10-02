# CE HALO live website checkout

Production target: `https://ce.cehalo.com`. Marketing remains at GoDaddy. Add a marketing button to the portal; do not redirect the whole root domain or create a GoDaddy store for these courses.

## Scope and authorization

Prepared after the owner's explicit live-setup authorization. Branch: `ce-web/portal-setup`. Do not merge into main. `stripe-test` stays isolated and unchanged.

The new Edge Function is `ce-stripe-live` in the existing Luma Supabase project `xuckkusbbcxplpqclbxt`. Browser routes verify the permanent Luma user through Supabase Auth; webhooks verify the raw-body Stripe signature. Keys remain server-side. `verify_jwt=false` is required for Stripe webhooks; the function supplies its own authentication.

`schema.sql` adds private orders/events and a STRIPE store mapping to the existing ownership ledger. It reuses, rather than replaces, existing bonus recording and revocation functions. It adds verified STRIPE ownership to the existing normal native paywall ownership lookup while preserving the Apple reviewer wrapper and course readiness checks. It does not change native purchase handlers, login providers, RevenueCat configuration, course release flags, certificate settings, progress, assessments, or existing purchase rows.

## Secrets and activation

In the production project's Edge Function secrets, set:

- `CE_STRIPE_LIVE_SECRET_KEY`: live Stripe restricted key for account `acct_1TkNobLbhEgJbqRt`. Permissions: Checkout Sessions Write, Prices Read, Payment Intents Read, Charges Read.
- `CE_STRIPE_LIVE_WEBHOOK_SECRET`: the live endpoint's signing secret.
- `CE_STRIPE_LIVE_ENABLED`: `false` until credentials, delivery, Flutter tests/build, and the deployed checkout have been checked. Set `true` only for activation.

No user-supplied Supabase service key is needed. The function uses its own runtime credential.

Create a live snapshot webhook destination for:

`https://xuckkusbbcxplpqclbxt.supabase.co/functions/v1/ce-stripe-live/webhook`

Events: `checkout.session.completed`, `checkout.session.async_payment_succeeded`, `checkout.session.expired`, `charge.refunded`, `charge.dispute.created`.

`GET /setup-status` returns missing setting names, not secret values. A ready configuration only checks key formats, not permissions or webhook delivery. The backend checks each live price before opening checkout. No test-mode card should be used in live checkout.

## Website build

In the separate Mac folder, pull this branch, then:

```sh
flutter pub get
flutter test test/ce_web_checkout_test.dart test/ce_paywalls_test.dart test/subscription_billing_test.dart test/social_auth_test.dart
flutter analyze lib/ce/web/ce_web_checkout.dart lib/ce/ce_purchase_screen.dart lib/ce_portal_main.dart test/ce_web_checkout_test.dart
flutter build web --release -t lib/ce_portal_main.dart --dart-define=LUMA_CE_STRIPE_LIVE_ENABLED=true
ditto -c -k build/web build/ce-portal-site.zip
open -R build/ce-portal-site.zip
```

Upload the contents of `build/web` or the ZIP to the existing Netlify project. Neither the live flag nor endpoint is a secret. Never place a Stripe secret in Flutter, Netlify static files, git, or chat. Do not upload an old build. This workstation may lack Flutter; successful Node/Postgres tests are not a Flutter compile result.

## Purchase and access behavior

- Three individual courses: USD249.99 each. Bundle: USD699.99. One-time payment, quantity one, existing fixed live prices. Tax behavior is unchanged from those configured prices; no new tax or discount policy is configured.
- Immutable Luma UUID identifies the learner, not the payer's email or URL parameters.
- Paid session, price, amount, metadata, payment intent and charge are independently retrieved/verified before fulfillment. URL returns alone never grant access.
- Fulfillment is atomic and idempotent. Existing paid ownership uses shared course mappings, including configured Apple/Google purchases. Unknown Google products are not magically integrated.
- Shared bonus rules remain first individual month once, bundle total three, maximum three lifetime across channels, refunds do not reset eligibility. No subscription is created.
- Known owned courses and partially owned bundles cannot be purchased on the portal. Bundle upgrades are not implemented.
- Refunds, including partial refunds, and disputes revoke this Stripe purchase; unrelated purchases remain. A resolved dispute does not auto-restore access; manual review is required.
- Disabling `CE_STRIPE_LIVE_ENABLED` stops new checkout but keeps verified webhook processing available.
- At most one pending web order per account. Returning to the portal reconciles its Stripe session. A stale reserved order without a session remains blocked for operator reconciliation instead of risking a second charge.
- A purchase on another channel while Stripe Checkout is already open can still overlap; there is no cross-provider atomic purchase lock. Review/refund overlapping payments through support. Never claim cross-provider races are impossible.
- Existing GoDaddy store purchases and standalone Stripe Payment Links are not imported. They need verified order-to-Luma-account reconciliation before granting ownership.

## Verification and rollback

Run Node tests with PGlite available:

```sh
PGLITE_MODULE=/absolute/path/to/pglite/dist/index.js node --test stripe-live/tests/*.test.mjs stripe-test/tests/*.test.mjs
```

Verify signed-out and ordinary signed-in accounts, owned-course access, pending/success/cancel handling, webhook retries and refund behavior. A real end-to-end charge needs separate explicit permission; none is created just by setup.

Operational rollback: set the live enabled flag false and restore the prior Netlify build if needed. Keep the ledger, product mappings, webhook processing and verified existing ownership intact. Do not drop paid records or remove STRIPE mappings after transactions exist.

Implementation references: [Stripe hosted Checkout](https://docs.stripe.com/payments/accept-a-payment?payment-ui=checkout&ui=stripe-hosted), [Stripe webhooks](https://docs.stripe.com/webhooks), [Supabase Edge Function secrets](https://supabase.com/docs/guides/functions/secrets).
