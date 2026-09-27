# CE bonus access and Luma AI

## Implementation status

The CE bonus migration is applied to production Supabase and tested, but
CE purchase activation is not connected. No customer access is granted,
and no purchase is initiated by this policy update.
CE checkout remains disabled. Luma AI is a
visual preview, not a connected AI service.

## Complimentary app access

- **Single course:** one calendar month of clinical premium access, one time.
- **Bundle:** three calendar months if no bonus was awarded; otherwise two
  additional months after a course's one-month bonus. Three months maximum
  per permanent account across stores, including expired or revoked awards.
- **No subscription required:** CE purchase/access remains separate.
- **No automatic subscription:** expiry never initiates a charge.
- **Automatic grant:** a trusted receipt-verification service invokes
  `record_verified_ce_bonus` with the authenticated Supabase user ID and
  verified store, transaction ID, product ID, and original purchase timestamp.
- **Product mapping:** populate `luma_ce_bonus_products` only with verified
  App Store / Play Store product IDs; map single courses to 1 and bundles to 3.
  The database ships with no enabled products.
- **Restores and retries:** the same store transaction is recorded once and
  never extends a bonus. Transaction reassignment to another account is rejected.
- **Refunds:** call `revoke_verified_ce_bonus` after verifying the refund.
  Refund-first delivery is retained so a late purchase cannot reinstate access.
- **Paid access preserved:** CE grants are separate from subscription/owner
  grants. Refunding a course does not cancel an independently paid subscription.

Nicole approved the maximum-three-month rule on September 27, 2026. Additional
individual courses grant zero months. A bundle-first purchase grants three
months; a bundle after a course grants only two more. `bonus_months` records
product kind; `awarded_months` records the actual award, even after refund.
The account advisory lock serializes purchases across stores before summing
lifetime awards. Course ownership records are retained even with zero bonus.

An upgrade follows the unexpired, unrevoked CE window, or starts on the
original verified bundle purchase date if that window has ended. Calendar
months are calculated in UTC and clamped at month-end. Restoring never uses
today as a new start date. Queued bundle access has its own start date: refunding
the earlier course does not make the queued interval begin early.
Paid subscriptions are not paused, reimbursed or rebilled by this mechanism.
Do not promise deferred paid billing to a currently paying subscriber.

The cap migration stops for manual review if legacy awards already exceed
three months; it never silently removes existing customer benefits. Product
enablement and Google configuration are unchanged. The shared cap applies
to any future verified purchase adapter using the same Supabase account UUID;
web/Stripe purchase ingestion is not implemented by this change.

Database checks passed locally and on Supabase for month-end expiry, repeat
purchase limits, restores, identity mismatches, refunds, refund-first delivery,
RLS and preservation of independent paid access. Test fixtures were rolled back.
At verification there were zero enabled CE products and zero customer bonus rows.

### September 27 three-month-cap verification

- Applied `20260927154627_ce_bonus_three_month_cap.sql` to production.
- Passed both `supabase/tests/ce_bonus_access.sql` and
  `supabase/tests/ce_bonus_three_month_cap.sql` on isolated PostgreSQL and
  production Supabase. Production fixtures were rolled back.
- Concurrent local course/bundle transactions produced awards of 1 and 2
  months, with the bundle following the course expiry.
- Verified production still has zero purchase/refund rows and zero enabled
  CE products; anonymous/authenticated clients cannot invoke the grant RPC.
- Updated Flutter policy wording, bundled course metadata, seed metadata and
  paywall widget assertions. Flutter widget tests were not executed in this
  environment because the required Flutter/Dart toolchain is not installed.
- No Google products, paid entitlements, subscription billing, or native
  purchase feature flags were changed. Automatic CE receipt verification and
  activation remain a separate unfinished integration.

Before launch: connect native billing, server receipt verification and refund
notifications; test purchase, restore, duplicate events, account switching,
expiry, refund, and an existing paid subscription on both platforms. No client
may call the service-only purchase/refund functions or possess a service key.

## Luma AI credit proposal

The owner pays the selected AI provider's API usage bill separately. App
subscription income and additional credit-pack sales are intended to fund that
cost. No provider, credit quantity, prices, or cost estimates are approved yet.

- Include a clearly defined credit allowance in eligible subscriptions.
- Sell additional credits as optional consumable store purchases.
- Keep credit balances server-side and tied to the authenticated account.
- Credit only verified transactions; never a client-reported purchase success.
- Use a ledger with unique purchase/request IDs, atomic reservation and
  settlement, and refund/reversal records. Never just decrement a client counter.
- Define one credit in user-facing terms before launch. If advanced requests
  cost more, disclose their cost before submission.
- Reserve credits before calling AI. Release them on a failed request. Retried
  requests must not double-charge; use a request ID and persisted response.
- Purchased credits do not expire. The conservative proposed default is also
  to retain unused included credits, pending final store/product review.
- No automatic credit-pack purchase. Ask users to confirm through store billing.
- Nicole confirmed that CE complimentary access includes the same AI-credit
  allowance as subscription access. The quantity and cadence still need to be
  costed and configured. Repeated purchases/restores must never duplicate an
  allowance grant; use an account-and-allowance-period uniqueness key.
- Add server-side rate limits, context/output limits and a provider spending
  ceiling before enabling generation.

Apple permits consumable credits in subscriptions and says purchased credits
may not expire ([App Review Guidelines, 3.1.1 and 3.1.2(a)](https://developer.apple.com/app-store/review/guidelines/)).
Google defines consumable products as repeat-purchasable items that are consumed
for in-app content ([Play Billing](https://developer.android.com/google/play/billing/one-time-products)).

## Clinical AI safeguards

Luma is an educational/reference assistant, not autonomous clinical decision
support. Do not invite patient identifiers or present generated medication doses
as verified orders. Prefer retrieval from reviewed Luma references, display
sources, explain uncertainty, and redirect emergencies to established protocols.
Clearly identify the selected AI provider and data handling, and request explicit
permission before sharing personal data with third-party AI, as required by
[Apple's privacy rules](https://developer.apple.com/app-store/review/guidelines/).
No message field or network AI request is enabled in the current preview.

## Pricing decision

Measure representative Luma requests using the intended prompt, clinical
reference context, model, output limits and retry behavior. Include provider
usage, database/hosting, store fees, taxes and support in the pricing model.
Only then choose the included monthly allowance and credit-pack prices.
Do not equate one app credit with one provider token or assume all questions cost
the same to process.
