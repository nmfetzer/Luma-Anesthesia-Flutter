# Apple public-launch activation

Owner authorized public-launch activation on October 2, 2026. The backend activation is applied and verified; no signed IPA was built, uploaded, submitted, or released by this operation.

## Verified live state

- Customer subscription checkout: enabled.
- Apple CE products: all four enabled, including the three-course bundle.
- Courses 1047239, 1047241, and 1047243: released.
- Official certificate issuance settings: enabled for all three courses. Existing completion, payment, approval-date, preview, and identity checks remain mandatory.
- Sandbox self-enrollment: enabled. Existing valid test accounts remain eligible.
- Sandbox CE products: all four remain enabled in the separate private ledger.
- AI, deferred app sections, Google sign-in configuration, and website payments: not activated by this work.
- Deletion requests and notifications remain enabled; actual deletion fulfillment remains an operator workflow.

This status supersedes older “customer sales off” and “courses unreleased” notes in historical deployment documents. Store product approval, pricing, agreements, bank/tax status, and release availability were not changed or independently reverified.

## Sandbox and real purchases

The same release configuration permits both server-authorized sandbox review and production checkout. Enrollment alone grants no purchased content. The existing trusted RevenueCat adapters use verified transaction environments to route sandbox purchases into private test ledgers, not production ledgers.

Migration `20261002143504_public_purchase_account_routing.sql` stops an enrolled account from being routed to sandbox ownership after verified production purchases or other production learner/provider activity. It does not convert preview progress into official CE completion or move test receipts into production. Use a separate fresh Luma account for review rather than an administrator or an account with production learning/purchases.

Sandbox learners can test course learning and preview certificates. Their preview certificates award zero reportable credit. No real AANA credit is awarded merely by sandbox testing.

Apple confirms App Review assesses purchases in the sandbox without financial charges ([Apple review guidance](https://developer.apple.com/forums/tags/app-review?page=17&sortBy=newest)). TestFlight purchases also use the sandbox and do not carry into production ([Apple In-App Purchase](https://developer.apple.com/in-app-purchase/)).

## Verification performed

- All 32 live module PDF byte checksums match the stored checksums and catalog.
- All 32 question banks match their declared bank sizes.
- Each course totals 20 credits; module counts are 11, 10, and 11.
- All three certificate configurations contain approval and signature data.
- Disposable database integration/regression checks passed, including blocked incomplete activation, successful complete activation, sandbox/production isolation, and real-purchase account transition.
- 27 focused Flutter billing tests passed.
- Release script passes Bash syntax checking. Git whitespace checks passed.
- CE webhook rejects unauthenticated requests with HTTP 401 rather than the configuration-disabled response. This does not prove real delivery of a purchase event.

## Build on the signing Mac

Pull the updated `main` branch, then use the new script with a build number not previously uploaded for version 3.0.0:

```sh
git pull --ff-only origin main
bash scripts/build_apple_release.sh NEW_UNUSED_BUILD_NUMBER
```

Replace `NEW_UNUSED_BUILD_NUMBER` with the actual integer. This script sets:

```text
LUMA_APPLE_REVIEW_ENABLED=true
LUMA_BILLING_ENABLED=true
LUMA_CE_BILLING_ENABLED=true
```

Do not use the review-only script for the public-launch candidate: it deliberately leaves customer build flags off. The new script checks the actual archive version/build and rejects an archive containing legacy PDFium.

Before submission, test that exact signed binary on a fresh non-admin account: subscription purchase/restore, all CE product availability, at least one complete CE purchase-to-unlock flow, complimentary-access handling, account switching, PDF viewing, offline downloads, deletion UI, and small-iPhone/iPad layouts. These native acceptance checks have not been newly completed by the backend activation.

Supply working reviewer login/access instructions through App Store Connect's private App Review Information. Do not commit reviewer credentials to Git. Do not promise a fully verified App Review experience until the signed-device acceptance checks pass.

## Operational files

- Guarded activation: `supabase/operations/activate_apple_public_launch.sql` (already applied; do not rerun routinely).
- Routing migration: `supabase/migrations/20261002143504_public_purchase_account_routing.sql` (already applied).
- Local regression command: `node scripts/test_apple_review_db.mjs`.

No notifications, charges, certificates, or AANA submissions were generated by the activation itself.
