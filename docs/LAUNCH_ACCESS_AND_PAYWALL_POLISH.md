# Launch access and paywall polish

## Changes

- Vasopressors, Infusions & Transfusions now checks the existing server premium entitlement before constructing or fetching the section. Both medication and transfusion detail routes retain the gate.
- Account/access changes invalidate rendered premium content immediately; stale asynchronous checks cannot authorize a different account. Resume and periodic checks revalidate access. A connection failure may use only an existing, owner-bound, unexpired offline lease. An authoritative denial revokes the lease.
- The free Drug Library retains its public medication fields. This section-level subscription boundary does not pretend those shared public rows have become private. Existing Deep Dive server protection remains unchanged.
- One compact subscription page presents monthly USD $9.99 and yearly USD $69.99 reference prices when store prices are not yet loaded. Actual localized StoreKit/Google Play package pricing replaces them when available. Reference labels never enable checkout. No store products, prices, production checkout flags, or database records were changed.
- The paywall retains store renewal/cancellation wording, restore purchases, CE HALO privacy and EULA links, and a clear statement that CE purchases do not require an app subscription.
- Home is fixed above the paywall scroll area and added to CE library, course, learner PDF, purchase, certificate, provider-record, and password-reset headers. Existing reference-screen Home controls are retained.
- Decorative counts removed from Quick Reference cards, Pathophysiology category cards/header, Drug Library category rows, and vasopressor browse headers. CE learning progress and clinical numbers are unchanged.
- Vasopressor browsing fetches only vasoactive medication rows instead of the complete medication library. Full offline medication downloads still satisfy the smaller browse view. Concurrent Drug Library requests share one in-flight load.

## Verification

- 140 targeted Flutter tests passed: premium access/revocation/races, subscriptions, CE billing and learning, navigation, offline storage/recovery, search, and phone/tablet layouts.
- Flutter web release built successfully.
- Browser screenshots inspected at 430 × 932 and 820 × 1180; paywall prices and primary action are visible without scrolling. Small screens and enlarged text remain scrollable without hiding Home.
- Static analysis: no errors or warnings; 109 informational lint notices remain.

## Native handoff

These source changes require a new signed build to reach TestFlight. They do not remotely modify an already-installed IPA.

Pull `main`, then run `bash scripts/build_apple_review.sh <new-unused-build-number>` from the Flutter repository on the Mac. Upload only the resulting new archive. Do not reuse a submitted build number.

Still required on the new TestFlight build: regular unpaid-account gating, sandbox subscription purchase and restore, CE purchase, real iPhone/iPad scrolling, and device startup timing. No native speed percentage, App Review approval, or successful live checkout is claimed by the browser/unit tests.
