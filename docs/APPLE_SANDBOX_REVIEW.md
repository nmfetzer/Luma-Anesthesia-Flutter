# Luma Anesthesia Apple Sandbox and App Review Setup

Deployed September 27, 2026 after explicit approval. The backend is live; enrollment of designated accounts, RevenueCat dashboard changes and signed-iPhone acceptance remain separate steps. Customer checkout stays disabled. This document is not a claim of App Review approval or a completed Apple purchase.

## Deployment record

- **Database:** project `xuckkusbbcxplpqclbxt`, applied migration `apple_sandbox_review`, recorded by Supabase as version `20260927205733`.
- **Repository migration:** `20260927230000_apple_sandbox_review.sql` contains the applied SQL. Its dependency-ordered filename is retained because earlier repository course migrations have later filename timestamps than their live application times. Do not blindly run `db push` against this project without reconciling the pre-existing migration-version differences; do not apply this migration twice.
- **CE webhook:** `revenuecat-ce-webhook` version 7, active, existing custom Authorization protection retained with gateway `verify_jwt=false`.
- **Subscription verifier:** `revenuecat-sync` version 4, active, gateway `verify_jwt=true`.
- **Live checks:** customer subscription control false; zero enabled real CE products; all three course catalogs unreleased; zero enrolled test accounts, sandbox purchases or sandbox subscription rows. Authenticated users cannot access the private schema, enroll themselves or write sandbox purchases. Both endpoints returned HTTP 401 to unauthenticated POSTs.
- **Local checks:** 51 Flutter tests and 55 Deno tests passed, both edge entry points passed type checking, and the disposable database integration test plus three production regression suites passed. Newer CE-library and offline-reference work from GitHub was preserved.

No account credentials, RevenueCat dashboard settings or Apple release settings were changed by this deployment. The following sections describe the remaining setup and acceptance work.

## What changes

- **Test ledger:** the private `luma_review` schema stores sandbox subscriptions, CE purchases, events, refunds and bonus accounting. No existing production rows are copied. The guarded migration copies the current tested bonus algorithm into the isolated schema.
- **Named test accounts:** only server-enrolled permanent Supabase UUIDs qualify. Enrollment expires within 60 days and can be revoked immediately. An empty allowlist is deployed; no owner or customer account is automatically enrolled. Enrollment itself grants no clinical content or courses.
- **Same app and products:** the existing Apple public SDK key, Apple app ID, product IDs, offerings and subscription entitlement are retained. The native submission build can use the production backend while server-verified sandbox activity goes to separate test records.
- **Customer guard:** both normal Flutter purchase flags stay false. A new server control for customer subscription checkout also starts false. Ordinary users in the review build cannot authorize subscription or CE checkout. This does not change availability of an older published app or its existing Apple subscriptions.
- **CE bonus rule:** first individual purchase grants one calendar month once; additional individuals grant zero; bundle-first grants three; bundle after the course bonus grants two. Refunds and restores do not reset the three-month limit. Sandbox grants do not consume real customer bonus eligibility.
- **Learning and certificates:** verified test ownership opens the existing courses, assessments and evaluations in preview state without putting testers in provider-reviewer tables. Preview completion awards zero credits. Preview certificates remain watermarked and cannot be issued as official CE certificates.
- **Expiry and revocation:** access checks require an active test enrollment even when a test purchase or subscription lease exists. Revoking enrollment does not erase its history or reset its bonus cap.

RevenueCat can associate sandbox and production purchases with the same App User ID, which is why this implementation uses explicit receipt-environment routing and dedicated test accounts instead of treating an account as inherently sandbox ([RevenueCat sandbox documentation](https://www.revenuecat.com/docs/test-and-launch/sandbox)).

## Deployment order

The reviewed migration `supabase/migrations/20260927230000_apple_sandbox_review.sql` has been applied to project `xuckkusbbcxplpqclbxt`; do not reapply it. It adds isolated accounting and updates only the course-access/preview portions of the existing course functions. Guarded replacements abort on unexpected code drift; production accounting-function hashes must match the versions tested.

The deployment used the complete current runtime files from these directories:

- `supabase/functions/revenuecat-sync/`: retain `verify_jwt=true`.
- `supabase/functions/revenuecat-ce-webhook/`: retain `verify_jwt=false`; the handler itself requires the configured RevenueCat Authorization secret before parsing or writing.

No new secret is needed. Preserve `REVENUECAT_SECRET_API_KEY`, `LUMA_BILLING_SERVER_ENABLED`, `REVENUECAT_CE_WEBHOOK_SECRET`, `REVENUECAT_CE_APP_ID` and `LUMA_CE_WEBHOOK_ENABLED`. The owner reported saving the v1 API secret and server-enabled flag; an authenticated RevenueCat verification request still needs native validation. Old `LUMA_ALLOW_SANDBOX` / `LUMA_CE_ALLOW_SANDBOX` flags are no longer the authorization mechanism.

This change was reviewed and separately approved before deployment. Do not deploy the older `billing-draft` SQL or enable the real CE product flags.

## Dedicated accounts

Create separate ordinary Luma email/password accounts for testing, with verified sign-in and no real purchases, owner access or CE history. Do not use Nicole's owner account. Their permanent Supabase UUIDs are the RevenueCat App User IDs; the Apple sandbox Apple Account is a separate login.

Use at least separate subscription and CE test accounts: a CE bonus counts as active clinical access, so the existing duplicate-subscription protection will intentionally block a new subscription while that bonus is active. Use additional fresh accounts for bundle-first versus individual-then-bundle acceptance tests.

Enrollment is an explicit server/admin operation, never an app button or user-metadata flag:

```sql
-- Replace the UUID with the approved dedicated test account's permanent ID.
select public.enroll_luma_apple_reviewer(
  'DEDICATED-TEST-ACCOUNT-UUID'::uuid,
  now() + interval '30 days'
);
```

The migration does not run this command. Keep App Review credentials valid throughout review and renew the enrollment if needed; renewal does not reset purchase histories. To remove access immediately:

```sql
select public.revoke_luma_apple_reviewer('DEDICATED-TEST-ACCOUNT-UUID'::uuid);
```

Never commit account passwords, Apple sandbox passwords or secret keys. Put reviewer login credentials directly in App Store Connect's App Review Information fields; Apple asks for an active demo account or fully featured demo mode for account-based features ([Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)).

## RevenueCat dashboard

After the isolated backend has been deployed:

1. Edit only **Luma Apple CE bonuses** in project **Luma Educational Apps**.
2. Preserve the Apple app filter `appbafd32b582`, URL, Authorization header and all relevant events.
3. Change that webhook's environment filter from **Production only** to include **Sandbox and Production**. Do not change Nurse or older Base44 webhooks.
4. In project General settings, if sandbox access is restricted, add the designated Supabase UUIDs to **Allowed App User IDs only**. Do not replace or remove other apps' existing tester IDs. RevenueCat documents that these project-level settings determine which test purchases grant entitlements ([RevenueCat sandbox testing access](https://www.revenuecat.com/docs/projects/sandbox-access)).
5. Confirm offering `default` includes the exact monthly and annual Apple packages, and `crna_courses` includes all four CE products. Do not attach the permanent clinical entitlement to CE purchases.

Keep the real Apple `appl_...` SDK key, not RevenueCat's Test Store key: RevenueCat instructs developers to use platform-specific keys and platform sandbox testing before App Review ([RevenueCat sandbox testing](https://www.revenuecat.com/docs/test-and-launch/sandbox)).

## Native review build

On the developer's Mac, after pulling the approved commit, run:

```sh
bash scripts/build_apple_review.sh NEW_UNUSED_BUILD_NUMBER
```

Replace the final argument with an unused positive integer build number. The script builds version `3.0`, uses the existing public Apple SDK key, enables only the review build flag, and keeps both customer purchase flags false. Signing, provisioning and upload remain the developer's Mac/App Store Connect steps. The script does not upload, submit or release anything.

Test the exact intended submission build on a signed iPhone through Apple sandbox/TestFlight. A test-account allowlist cannot determine which Apple payment environment will open before checkout; do not use designated accounts to make purchases in a live production-store build. Do not change App Store availability as part of test setup.

In App Store Connect, choose **Manually release this version** so approval does not automatically publish the update; Apple's manual option holds an approved version in Pending Developer Release ([Apple version release options](https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/select-an-app-store-version-release-option/)). This does not stop sales in an older version already on the store.

## App Review notes draft

Fill in the dedicated credentials in App Review Information, not in this repository. Use this text only after the stated flows are confirmed on the uploaded build:

> Luma Anesthesia 3.0 includes free clinical reference content, separately purchased clinical subscriptions, and three individual CE courses plus a three-course bundle.
>
> Please use the dedicated review credentials supplied in App Review Information. The subscription-testing account and CE-testing account are separate because a CE purchase includes complimentary clinical access and the app prevents an unnecessary second subscription purchase while clinical access is active.
>
> For subscriptions, sign in with the subscription-testing account, open a locked clinical reference, select a monthly or annual plan, and complete the Apple sandbox purchase. Refresh access or Restore purchases is available on the subscription screen.
>
> For CE, sign in with the CE-testing account, open the Course library, view any course and select View CE purchase options. Complete a sandbox purchase, then tap Refresh CE access and return to the course. Each course includes registration, learning content, quizzes and evaluations. Restore CE purchases is available on the CE purchase screen.
>
> Sandbox purchases are verified by the server and stored separately from real purchases. On these dedicated review accounts, course activity and certificates are marked as previews and award zero actual CE credits. They do not affect real learners' CE records. For review before October 1, 2026, use October 1, 2026 as both participation dates on the preview registration form.
>
> A first individual CE purchase includes one complimentary clinical month once per account. A bundle includes up to three months total, or two additional months if the individual-course month was already awarded. Additional individual courses, refunds and restores do not reset this limit. CE purchases do not start auto-renewing subscriptions.
>
> Customer checkout remains disabled pending launch readiness, and this version will be manually released. The designated review accounts can exercise the purchase and learning flows through Apple's sandbox. Please contact info@cehalo.com if additional review access is needed.

Do not describe this as a separate hidden feature set or claim Apple approval is guaranteed. The difference is isolated testing, not a bypass of purchase verification or a promise to award accredited credit to reviewers.

## Acceptance before submission

- **Ordinary account:** review build loads, free content works, subscription checkout and all CE purchase buttons remain disabled; cannot self-enroll through metadata or API calls.
- **Subscription account:** monthly and annual native prices load; sandbox purchase unlocks premium references via the server; cancellations, refunds, expiration and restore behave correctly. Test each term without an existing active grant blocking checkout.
- **Individual then bundle:** first CE purchase grants one month; second individual grants zero; later bundle grants only two additional months. All owned courses remain available after bonus expiry while enrollment is active.
- **Bundle first:** fresh account gets all three courses and a three-month test bonus.
- **Learning:** complete a quiz and evaluation in each course; verify preview completion earns zero credits, certificate preview is watermarked, official issue remains blocked, and provider exports are unavailable.
- **Reinstall and account changes:** restoring a known verified purchase does not add bonus months; another account cannot inherit it. Ambiguous RevenueCat aliases/transfers fail for manual investigation, not silent reassignment.
- **Revocation:** revoke the tester and refresh; server content/course access stops despite cached purchase history. Previously displayed/downloaded content is not remotely erased.
- **Evidence:** inspect the actual sandbox event and backend rows. A Dashboard `TEST` event returning `ignored:test` is only a connectivity check, not purchase validation.

Historical CE transactions missing from the server ledger still require verified reconciliation; Restore does not guarantee RevenueCat will resend an old webhook. Do not reset test purchase history to simulate new lifetime eligibility; use a new dedicated account.

## Automated checks

The local disposable PostgreSQL test exercises real course functions with synthetic content, including registration, quiz, evaluation, zero-credit certificate preview, bonus math, duplicate deliveries, refund-first ordering, account isolation, revocation/expiry, private-schema permissions and unchanged production ledgers. It is not a content audit or a real Apple transaction.

Run:

```sh
node scripts/test_apple_review_db.mjs
npm exec --yes --package=deno -- deno test supabase/functions/revenuecat-ce-webhook/ supabase/functions/revenuecat-sync/
npm exec --yes --package=deno -- deno check supabase/functions/revenuecat-ce-webhook/index.ts supabase/functions/revenuecat-sync/index.ts
flutter test test/apple_review_policy_test.dart test/ce_billing_test.dart test/subscription_billing_test.dart
```

The database runner is local-only and creates/drops a disposable `luma_review_test_*` database. It requires local PostgreSQL/sudo and the Supabase-like roles `anon`, `authenticated` and `service_role`; it never uses a Supabase URL or credential.

## Hold and rollback

Do not delete purchase ledgers. Revoke designated accounts to stop test access; optionally return the CE webhook to Production only. Keep customer subscription control false and all real CE product flags false. If an edge deployment fails, stop and repair before changing dashboard filters or testing native purchases. Do not revert only the database while leaving newer edge functions that call its RPCs.

Release to real customers is a separate, explicitly approved operation after native acceptance, provider course/certificate release checks and store readiness. This change deliberately does not perform it.
