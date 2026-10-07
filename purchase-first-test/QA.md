# Purchase-First Test: Verification

October 7, 2026. This verifies the isolated simulator, not Stripe test-mode integration or production readiness.

- **Core tests:** Twelve Node tests pass for purchase-before-account, profile/verification gates, payment/activation idempotency, existing learner identity/progress, delayed/unpaid denial, wrong-email denial, OTP expiry/reuse/attempt limits, fictional-email enforcement, server-selected prices/courses, saved-order recovery, overlap handling and declines/cancellation.
- **Desktop:** Direct Medication Review checkout, successful simulated payment, incorrect-code rejection, verified email, required profile completion and activated course library exercised with browser controls.
- **Returning learner:** At 375 px, an existing fictional learner purchased Uncommon Events, retained Medication Review and its 38% sample progress, and saw both courses. A known overlapping bundle was blocked before payment.
- **Recovery:** Declined payment, delayed payment confirmation, leaving after payment, page reload, verification, prefilled profile and three-course activation exercised. Test course entry, sign-out and repeat sign-in checked.
- **Responsive:** Desktop and 375 px screenshots inspected; no horizontal overflow on phone checkout or library.
- **Isolation:** All authored files are inside `purchase-first-test/`. Production Flutter, Stripe/Supabase adapters, credentials, schemas, Netlify site and native files are unchanged.

The simulated inbox deliberately exposes codes within each fictional test workspace. This is a review aid and must not ship to production. The detailed live integration boundaries are in README.md.
