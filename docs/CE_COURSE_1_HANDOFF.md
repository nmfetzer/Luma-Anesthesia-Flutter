# CE HALO Course 1: implementation and launch checklist

> Updated September 27, 2026: see [Module 2 and provider records](CE_MODULE_2_FINAL_HANDOFF.md) for the current two-module implementation, one-time course registration and provider records export. That update supersedes the original module-count and evaluation-signature descriptions below.

Course 1 is staged in the Luma Anesthesia Flutter codebase and Supabase project `xuckkusbbcxplpqclbxt`. This is a learning-flow implementation, not an active store checkout or an App Store release.

## Course and content

- **Title:** A Medication Review for the Experienced CRNA.
- **Approval:** 20.00 MAC Ed CE credits; Course ID / Code Number 1047239; approval period October 1, 2026 through September 30, 2029.
- **Designations:** Up to 17.50 Pharmacology & Therapeutics credits and up to 2.50 Pain Management credits for the complete program. The exact supplied AANA statements appear in the course information.
- **First module:** Ketamine & Anesthesia, 2.0 credits allocated as 1.5 Pharmacology & Therapeutics and 0.5 Pain Management.
- **Learner document:** The revised 17-page PDF, including the approved branded cover and DrOracle practice discussion, is stored privately in Supabase. SHA-256: `9f66d7c49006d02297dd6c27113ce0ebd15f377202f1665cd3b7b108617dc8e6`.
- **Remaining content:** Ten modules are not loaded. No placeholder clinical content or full-program completion is generated.
- **Contact:** info@cehalo.com. CE Portal reporting class 196397 remains provider-only and is not a quiz question or learner requirement.

## Learner flow

After a verified course purchase, a permanent signed-in account must supply full name, credentials, optional AANA ID, and completion location. The learner opens the PDF, acknowledges reviewing it, takes the assessment, and completes the evaluation after passing.

The quiz presents 15 questions from the revised 25-question bank. It requires 12 correct answers (80%) and allows three attempts. A randomized, snapshotted set of three forms shares exactly seven questions between any pair of forms. Starting and resuming an unfinished attempt does not consume another attempt.

Every question offers a hint that eliminates two incorrect choices, leaving the correct choice and one incorrect choice. Hint use and eliminated options persist on the server with the attempt. If a hint removes a previously selected response, the selection clears and must be answered again. There is no hint score penalty. Correct answers and rationales are not returned to the production client.

The evaluation retains six learning-objective ratings, five program ratings, two written responses, an acknowledgment and full-name signature. Completion records snapshot the learner details, actual completion location and server timestamp. A location entry is documentation, not a guarantee of tax deductibility or reimbursement.

Certificates, full-program completion and AANA reporting are intentionally not implemented. The hint-assisted assessment is a new delivery feature requested by the provider; confirm that the final delivery and retake design remains consistent with the approved independent-study requirements before enabling sales.

## Creator access and security

The existing permanent account associated with `nmfetzer@me.com` has a server-side reviewer grant. Sign in with that account and open CE HALO to use **Open provider preview**, without purchasing or modifying a store receipt.

Reviewer activity is explicitly marked as preview and earns zero official credits. It cannot silently turn into a credit-bearing learner record. The public design preview is separate and memory-only; reload it to reset the demonstration.

The production gate is enforced in Supabase, not merely hidden buttons. Ordinary clinical subscribers do not automatically own the course. Private resources, question keys, reviewer grants and learner records deny direct anonymous/authenticated table access. The narrowly scoped `ce_course1` RPC checks authentication, verified ownership or reviewer access, prerequisites and completion state. Row locking serializes concurrent attempts; submissions and evaluations are idempotent.

The first PDF is kept as a private base64 document in Postgres and returned only by the gated document RPC. It is not publicly hosted or in the production Flutter asset bundle. For a larger library, migrate documents to private Supabase Storage with short-lived signed URLs. The production mobile and portal builds never import `ce_demo_repository.dart` or `ce_demo_data.dart`.

The private provider-side seed is retained under `supabase/seed/course1_content.sql`; it contains the PDF and question bank and must never be copied into a public web directory or Flutter asset manifest. The migrations are the reproducible schema/API equivalent of the live `course1_learning_tables` and `course1_learning_api` migrations applied during this session.

## Price and included Luma access

The requested U.S. price is **$249.99**. This is configured as the planned price and displayed as planned, not as a verified live store price. Production checkout must display the localized price returned by the store rather than hard-coding USD.

- **Individual CE purchase:** One complimentary calendar month of Luma clinical access, once per account across stores.
- **Bundle purchase:** Three complimentary calendar months, once per account across stores.
- **Repeat purchases and restores:** Do not restart or extend the same benefit.
- **Timing:** Benefits begin on the original verified purchase date; month-end dates are clamped. Windows overlap rather than adding unused days.
- **Existing subscriptions:** Remain independent. A CE bonus does not pause billing or reimburse an existing subscription.
- **Renewal:** The bonus itself does not enroll the learner in an automatically renewing subscription.
- **Refunds:** Existing server-side revocation removes refunded purchase access without deleting an unrelated paid subscription.

The existing one-time benefit engine was regression-tested; it is not an Apple/Google receipt verifier. Apple provides transaction/entitlement and refund notification APIs, and Google recommends backend purchase verification before granting entitlement ([Apple In-App Purchase](https://developer.apple.com/in-app-purchase/); [Google Play billing security](https://developer.android.com/google/play/billing/security)).

The known Apple product mapping is `Medication_Review_for_the_Experienced_CRNA`, configured disabled. The Google product ID and bundle IDs are not assumed. StoreKit / Play Billing checkout, trusted receipt verification, account binding, store acknowledgment, restoration and refund webhooks still need integration and sandbox testing. Nothing in this change charges a user or enables sales.

## CE.cehalo.com web portal

The selected web address is **CE.cehalo.com**. Use the production entry point `lib/ce_portal_main.dart`; it opens CE HALO directly while using the same Supabase account, ownership, progress and completion records as the mobile app. The mobile entry point remains `lib/main.dart`.

Flutter supports both web deployment and native macOS releases, so a Mac app is optional rather than a prerequisite for desktop learning ([Flutter web deployment](https://docs.flutter.dev/deployment/web); [Flutter macOS deployment](https://docs.flutter.dev/deployment/macos)).

Before the portal is live:

1. Choose the production hosting destination and connect the `ce` DNS record under the existing `cehalo.com` domain using the host's required records.
2. Enable HTTPS and configure SPA fallback routing.
3. Add `https://ce.cehalo.com/?auth_callback=1` to the Supabase auth redirect allowlist. Keep the mobile callback and any existing production domains.
4. Test email confirmation, password reset, Apple/Google OAuth redirects where enabled, and switching between phone and desktop with the same account.
5. Deploy a production portal build, not the preview build. Keep purchases disabled until the complete course and billing integration are ready.

DNS, public hosting and auth-provider settings were not changed during this implementation. No learner-facing portal is claimed to be live at the selected address.

## Build and verification

```sh
flutter pub get
flutter analyze lib/ce lib/ce_portal_main.dart lib/ce_preview_main.dart
flutter test
flutter build web --release --no-wasm-dry-run -t lib/ce_portal_main.dart
```

The PDF reader is pinned to the tested pdfrx 2.6.5 release. This raises the project's Dart minimum to 3.13; use Flutter 3.47.5 / Dart 3.13.4 or a compatible newer stable toolchain before pulling dependencies. An older PDF-reader release failed dependency compilation on the tested SDK and was not retained. Native iOS/Android device builds, signing and store submission were not performed on this Linux sandbox.

The separate private design preview is built with `lib/ce_preview_main.dart`. Only that demo receives a copied learner PDF for its static test host. It has no Supabase login, payment or official CE writes.

Verification includes:

- SQL rollback tests for anonymous/unpaid denial, reviewer access, learner detail prerequisite, private PDF retrieval, 15-question forms, grading, hint correctness/persistence, seven-question retake overlap, idempotency and evaluation/completion rules.
- Existing CE benefit tests for calendar months, restore/replay, refunds, purchase identity and independent paid access.
- Flutter widget tests for phone/desktop layout and required learner details, plus preview assessment logic.
- Browser interaction tests through the PDF, 15 answers, hint, result, evaluation and preview completion, with desktop/mobile screenshots.

## Still required before selling

Complete the other ten modules, confirm the final assessment delivery, connect and test native billing on both stores, confirm Google and bundle product identifiers, and implement the certificate/reporting workflow in the planned later phase. Change the server release gate only after these launch requirements are satisfied. The first approval date is October 1, 2026; provider previews do not earn credits before it.
