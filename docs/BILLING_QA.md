# Billing QA scope

This verification distinguishes automated code checks from native store acceptance.

## User-visible checks

- Existing navy/celestial background, cream card, and halo logo at 375px and desktop.
- Monthly/annual selection round-trip; no invented prices when store configuration is absent.
- Disabled purchase/restore in Chrome; no outside payment link or live charge.
- Legal links, account navigation, Home/close, separate CE link remain available.
- Fake configured store widget test displays localized prices and routes the selected purchase.
- Cancellation, pending, missing configuration, backend failure, repeated taps, and account-change handling.
- Backend validation rejects wrong-app products, wrong stores, expired/refunded/sandbox records, and malformed/stale data.
- Existing clinical and CE/Quick Reference tests still pass.

## Boundary

Native purchase, restore, renewal, refund, transfer, signing, and App Store/Play Store acceptance are not proven by browser or unit tests. Supabase SQL and Edge Function remain unapplied drafts until approved and configured.

## Results, September 27, 2026

- Full Flutter suite: 246 tests passed after incorporating Quick Reference commit `46cdf57`.
- Billing controller/paywall analyzer: no issues.
- Backend pure validation: eight Deno tests passed; Edge Function type-check passed.
- Production `lib/main.dart` and private `lib/preview_main.dart` release web builds succeeded.
- Playwright at 375 × 812 and 1280 × 1100: plan-selection round-trip, disabled Chrome purchase and restore controls, absence of invented prices, and account navigation passed. No page errors recorded.
- Visual inspection: cream card, navy celestial background, readable mobile disclosure and legal controls preserved.
- Legal link behavior and enlarged-text layout covered by Flutter widget tests.
- Real store transactions: not run. Live SQL and Edge Function: not deployed.
