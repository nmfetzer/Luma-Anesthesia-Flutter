# CE HALO: Purchase-First Checkout Test

An isolated, functional UX simulation for review. The course purchase button goes directly to its checkout; it does not route through the library, module list, purchase-options page or mandatory sign-in screen. Live Stripe, Supabase, Netlify and mobile files are untouched.

## Try the flow

1. Open the preview. Medication Review checkout is selected immediately.
2. Keep `learner@example.test` and the fictional name, acknowledge the access notice, then complete the test purchase. No card field or real charge exists.
3. Send a test verification code. Read it in the built-in test inbox, close the inbox and enter the code.
4. Finish the fictional learner profile. The purchased course appears in the test library.

Choose a different course to test the bundle or other individual courses. Use `returning@example.test` for an existing test learner with Medication Review and 38% sample progress; buy Uncommon Events to confirm the same account retains progress. A signed-out overlapping purchase is flagged for review rather than destroying ownership or silently declaring a refund.

The preview uses passwordless email-code sign-in as a proposed UX choice. It does not change live passwords, providers or email-confirmation settings. Actual course lessons, learner reporting, certificates and complimentary subscription bonuses are not connected.

## Recovery and isolation

- Only fictional `.test` email addresses are accepted. Do not enter real names or other personal information.
- Each browser test has a random capability in its URL fragment. Keep the test link private; it permits access to that fictional workspace and its simulated inbox.
- Test state is stored server-side outside the public static folder. Reloading the same link retains the simulated purchase; a new test creates an independent workspace.
- Test sessions expire after 24 hours. This is not a durable customer-order store or production authentication implementation.
- A simulated payment callback marks an order paid before any redirect. The page cannot activate an unpaid, delayed or mismatched-email order.
- Repeated simulated payment/claim events are idempotent. OTP expiry, attempt limits and resend controls are enforced by the simulator.
- Declined/delayed payment controls are under “Test a payment problem.” These controls must never be present in a live checkout.

## Run locally

```sh
cd purchase-first-test
node --test core.test.mjs
node server.mjs
```

Open `http://127.0.0.1:4317/?product=medication`, or use `uncommon`, `legal` or `bundle`. `public/app.js` uses the local API on localhost and the private-preview proxy placeholder when deployed through Computer.

## What this test establishes

The intended path is **course purchase button → checkout/payment → activation → course library**. Email and payer name are collected on checkout; account verification and learner-profile completion happen after payment. The test demonstrates interactions and failure states, not real Stripe test-mode integration.

## Production implementation still required after UX approval

- Add a signed-out order/session flow alongside the current authenticated checkout. Preserve existing orders and UUID-based ownership; do not replace ownership with an email-string comparison.
- Create Stripe test-mode sessions with server-controlled prices, signed webhooks, validated paid status and atomic/idempotent order fulfillment. Keep pending purchases independent of account creation.
- Connect real email verification/claim tokens and recovery email delivery. A Stripe billing email alone is not proof of account ownership; never link to a preexisting unverified account solely by email.
- Attach a verified purchase to the authenticated immutable Luma user ID; retain existing Apple/RevenueCat ownership, progress, bonus limits, refund/dispute handling and duplicate-purchase protections.
- Decide and enforce the final learner fields, terms acceptance and passwordless-versus-existing-password UX. Do not globally weaken shared mobile authentication.
- Change GoDaddy purchase buttons to product-specific checkout entry URLs, while keeping “My courses” as the learner login route. Course-information pages can remain optional.
- Remove the misleading “Course purchase is not yet available” wording in the relevant website-only view once the production route is actually ready.
- Exercise real test-mode checkout, webhook retries, email delivery, lost return redirect, wrong/changed email, delayed payments, existing learners, overlapping purchases, refunds and cross-platform access before any separately approved live activation.

Do not deploy this simulator to the production Netlify site. No live backend migration or activation is included.

## QA inventory

- Direct checkout entry: first screen has email/name/payment action, not mandatory login or course navigation.
- New learner: purchase precedes account creation; email and profile gates precede activation.
- Returning learner: retains identity and sample progress when adding an unowned course.
- Recovery: leave after payment, reload same test URL, verify and activate without another payment.
- Error paths: invalid email, incorrect/expired code, declined/delayed payment, duplicate events, mismatched purchase email and overlapping ownership.
- Controls: course choice, buy, browse, sign-in, inbox open/close, send code, verify, profile submit, activate, leave/return, new test and test course entry.
- Responsive/keyboard: desktop and 375 px layouts, focus visibility, labels, form validation, no horizontal overflow, clear simulation labels.
