# Apple CE purchase-to-bonus connection

## Status

The Apple-only webhook and database adapter were deployed to production with
Nicole's explicit approval on September 27, 2026. The endpoint remains disabled
until its secret and exact RevenueCat Apple app ID are configured. This is not a claim of
a completed App Store purchase, enabled CE checkout, or completed store testing.

- Migration: `20260927163821_revenuecat_ce_webhook.sql`.
- Edge Function: `revenuecat-ce-webhook`, deployed version 1.
- 35 TypeScript tests and the entrypoint type-check passed.
- SQL integration tests passed locally and on production Supabase, with all
  production fixtures rolled back.
- Unauthenticated production POST returned HTTP 503 with
  `CE webhook not configured`, confirming the configuration gate is closed.
- Postflight confirmed four disabled Apple products, zero event/purchase/refund
  rows, and no grant RPC access for anonymous or authenticated client roles.

The existing three-month cap is unchanged: course first gives one month;
bundle first gives three; bundle after a course gives only two additional months.
Additional course purchases grant no more months. Course ownership is recorded
even when no bonus is awarded. Refunds never reset lifetime eligibility.

## Data flow

RevenueCat verifies the store purchase and sends an authenticated notification.
The handler validates its authorization header, exact Apple app, environment,
confirmed product ID, transaction identity and permanent Supabase account, then
calls the service-only `process_revenuecat_ce_event` RPC. That operation atomically
records the event and calls the existing purchase or refund function. Flutter
continues to read server-owned course and clinical access; no client flag grants
access and no RevenueCat secret is embedded in Flutter.

The handler uses RevenueCat's configurable Authorization header, checks it before
parsing the body, and acknowledges delivery only after the database operation
succeeds. RevenueCat documents duplicate delivery and retries, so both event IDs
and store transaction IDs are checked independently
([RevenueCat webhooks](https://www.revenuecat.com/docs/integrations/webhooks)).

## Exact Apple mappings

| Apple product | Product kind / maximum benefit |
|---|---|
| `Medication_Review_for_the_Experienced_CRNA` | Individual course, one month once |
| `uncommon_anesthesia_events` | Individual course, same once-only allowance |
| `legal_essentials_CRNA` | Individual course, same once-only allowance |
| `3_course_bundle_pack` | Bundle, three-month lifetime total |

The bundle is added to the existing Medication Review ownership mapping.
All four product records remain disabled until deliberate activation. No Google
or Stripe products are added. The other two courses' learning experiences and
ownership gates still need their own course integration; recording a verified
purchase does not create a missing course.

## Production configuration

The `supabase/functions/revenuecat-ce-webhook/` entrypoint and its local
dependencies are deployed as `revenuecat-ce-webhook`. Supabase's gateway JWT check is disabled
for this endpoint only: RevenueCat does not send a Supabase user JWT, and the
handler performs its own mandatory webhook authorization. Do not disable
authorization inside the handler.

Set these server-only Supabase Edge Function secrets:

- `REVENUECAT_CE_WEBHOOK_SECRET`: a new high-entropy random secret of at least
  32 characters. Store it in a password manager and Supabase, not chat or Git.
- `REVENUECAT_CE_APP_ID`: the RevenueCat public app ID for **Luma Anesthesia App
  (App Store)**. This is not project ID `69adc637`, the Apple numeric app ID, or
  bundle ID.
- `LUMA_CE_WEBHOOK_ENABLED=true`: enable only after the secret and app are set.

This connection does not require a RevenueCat REST API key and does not modify
the separate subscription verification draft.

In project **Luma Educational Apps**, add a dedicated webhook configuration:

- Name: `Luma Apple CE bonuses`.
- URL: `https://xuckkusbbcxplpqclbxt.supabase.co/functions/v1/revenuecat-ce-webhook`.
- Authorization header: `Bearer <the same webhook secret>`.
- App filter: **Luma Anesthesia App (App Store)** only.
- Environment: production.
- Events: `NON_RENEWING_PURCHASE`, `CANCELLATION`, `REFUND_REVERSED`, `TRANSFER`
  and dashboard test events where selectable.

RevenueCat documents the dashboard configuration and per-app/environment/event
filters in its [webhook setup guide](https://www.revenuecat.com/docs/integrations/webhooks).

Before customer sales, confirm RevenueCat's restore/transfer behavior preserves
original account ownership. Do not enable automatic purchase transfers between
permanent Luma accounts. Require a permanent Luma login before CE checkout and
use its Supabase UUID as the RevenueCat App User ID.

## Deliberate product activation

After signed native acceptance testing and dashboard verification, activate only
the four confirmed Apple CE product records. This SQL is an activation step, not
part of the deployment migration:

```sql
UPDATE public.luma_ce_bonus_products SET enabled = true
WHERE store = 'APP_STORE' AND product_id IN (
  'Medication_Review_for_the_Experienced_CRNA',
  'uncommon_anesthesia_events',
  'legal_essentials_CRNA',
  '3_course_bundle_pack'
);
```

Activating product records does not enable native CE checkout or release staged
course content. Those gates are intentionally unchanged.

## Refunds, identity and operational handling

- `NON_RENEWING_PURCHASE` records the original store transaction and purchase
  date, not today's processing date.
- `CANCELLATION` with `CUSTOMER_SUPPORT` revokes the matching CE transaction.
  Refunds also work if the product was later disabled or the purchase
  notification has not yet arrived.
- Refunds are matched by transaction, not the customer's current aliases.
- `REFUND_REVERSED`, transfers, family-shared purchases, ambiguous permanent
  accounts and unexpected cancellation reasons return a visible failed delivery
  requiring manual review. They never mint a new bonus.
- Unrelated products/apps/stores and production sandbox events are acknowledged
  without changing access. Dashboard `TEST` events never create a grant.
- A failed database call returns a retryable failure, not a false success.
  Duplicate matching event IDs return success without changing the original grant.
- A successful webhook does not force-refresh an already-open screen. The app
  should re-fetch course/clinical status after CE checkout and when resumed;
  native CE checkout and its post-purchase UI remain unfinished.

Event meanings and identity fields follow RevenueCat's
[event documentation](https://www.revenuecat.com/docs/integrations/webhooks/event-types-and-fields).
Monitor failed deliveries in RevenueCat and replay them after correcting the
problem. RevenueCat retries a failed event up to five times; this implementation
does not add a separate perpetual reconciliation worker
([retry documentation](https://www.revenuecat.com/docs/integrations/webhooks)).

## Testing

Run:

```sh
deno test supabase/functions/revenuecat-ce-webhook/validation_test.ts \
  supabase/functions/revenuecat-ce-webhook/handler_test.ts
deno check supabase/functions/revenuecat-ce-webhook/index.ts
psql -v ON_ERROR_STOP=1 -f supabase/tests/revenuecat_ce_webhook.sql
```

The SQL test uses a transaction and rolls back all fixtures, including temporary
product enablement. It covers duplicate/mismatched events, atomic failure,
course-plus-bundle awards, additional courses, refunds, refund-first ordering,
bundle ownership mapping and client privilege denial. Handler tests cover
authorization, malformed payloads, account identity, unrelated products,
sandbox rejection and database-failure retry behavior.

Use a separate Supabase test project for real Apple sandbox purchases. Only in
that project may `LUMA_CE_ALLOW_SANDBOX=true` be set; the handler explicitly refuses
sandbox grants in production project `xuckkusbbcxplpqclbxt`. Isolated test database
product records must also be enabled. A dashboard test alone does not prove
that real purchases, refund events, account switching or native checkout work.
