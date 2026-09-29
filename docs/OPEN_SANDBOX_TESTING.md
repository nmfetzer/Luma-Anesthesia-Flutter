# Luma Anesthesia: Open TestFlight Purchase Testing

Status: prepared and tested locally; not applied to production. This changes sandbox eligibility, not customer sales or free access.

## Requested behavior

Apple App Review and invited TestFlight testers can register and verify their own fresh Luma accounts. The developer does not need to know or approve their emails in advance. Apple purchase-testing accounts are distinct from Luma logins. Apple still asks developers of account-based apps to supply active demo login credentials or a fully featured demo mode; reviewers should not be forced to depend only on registration ([App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)).

## Exact production change proposed

Target: Supabase project `xuckkusbbcxplpqclbxt`.

Migration: `supabase/migrations/20260929020000_open_sandbox_testing.sql`.

- Add `public.luma_billing_controls.sandbox_self_enrollment_enabled` and set it to true.
- Add private `luma_review.try_open_enrollment(uuid)`. It accepts only the signed-in caller's ID and enrolls a fresh, verified, non-anonymous, non-banned account for 60 days.
- Reuse the existing enrollment exclusions: no owner/provider accounts, production purchase history, production entitlements, or real learner/certificate state.
- Invoke that helper from `public.luma_billing_policy()` and `public.luma_ce_checkout_status()`, so subscription-first and CE-first testing both work.
- Preserve revocation, expiry, purchase history, and bonus caps. Policy refresh does not renew or revive enrollment.
- Preserve the private sandbox ledgers and service-only receipt-writing functions.
- Leave `customer_subscriptions_enabled=false`, real CE products disabled, and course publication status unchanged.

The backend does not claim to identify TestFlight from a client flag. These policy endpoints make eligible accounts available for sandbox testing; the existing iOS review-build flag controls checkout presentation, and the existing trusted RevenueCat handlers validate the actual transaction environment. Enrollment alone grants no paid content, administrator role, real CE credit, or official certificate.

## Remaining acceptance work

- Apply the exact migration only after production approval.
- The existing build made with `scripts/build_apple_review.sh` can use this backend change without a rebuild. The separate welcome-card layout improvement does require a new app build.
- RevenueCat must accept sandbox purchases for these users and send Sandbox plus Production CE events to the correct existing webhook. Dashboard restrictions have not been verified by this patch.
- Use email registration while Apple and Google providers remain disabled. Social-provider configuration is a separate unfinished task.
- Verify a real TestFlight purchase and restore for subscriptions and CE courses, and confirm only purchased content unlocks.
- Existing customer logic prevents buying a redundant subscription while a CE purchase's complimentary clinical access is active. Test subscriptions first, or use a separate fresh Luma account for that scenario. The patch does not remove this protection.
- Sandbox CE learning and certificates stay clearly marked as previews and cannot award reportable credit.
- Offline sandbox entitlement refresh and prelaunch participation-date handling require their own native acceptance checks; this change does not certify them.

## Verification

The disposable local PostgreSQL harness exercises the original sandbox integration tests, new automatic enrollment tests, and three production regression suites. New checks cover fresh and CE-first accounts, denied anonymous/unverified/banned/owner/production accounts, no free access, verified sandbox course unlocking, revocation, expiry, repeated calls, private permissions, and the enrollment kill switch.

To stop new automatic enrollment, an administrator can set `sandbox_self_enrollment_enabled=false`. That does not revoke accounts already enrolled; use the existing reviewer-revocation function for those accounts.
