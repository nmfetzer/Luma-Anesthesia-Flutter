# CE bonus access and Luma AI

## Implementation status

The CE bonus migration is applied to production Supabase and tested, but
purchase activation is not connected. No CE store product IDs are invented,
no customer access is granted, and no purchase is initiated.
The Flutter paywall still disables checkout and restoration. Luma AI is a
visual preview, not a connected AI service.

## Complimentary app access

- **Single course:** one calendar month of clinical premium access, one time.
- **Bundle:** a one-time three-calendar-month bonus, not repeatable.
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

Nicole confirmed on September 24, 2026 that repeat purchases do not add more
free months. The implementation permits one course bonus and one bundle bonus
per account, with a lifetime uniqueness constraint; refunds do not reset that
eligibility. It uses original purchase-date activation and UTC calendar months.
A bundle bonus starts at its purchase date rather than stacking after the course
bonus. Paid subscriptions are not paused or rebilled by this mechanism; do not
promise a billing pause to a currently paying subscriber.

Database checks passed locally and on Supabase for month-end expiry, repeat
purchase limits, restores, identity mismatches, refunds, refund-first delivery,
RLS and preservation of independent paid access. Test fixtures were rolled back.
At verification there were zero enabled CE products and zero customer bonus rows.

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
