# Guest purchases and in-app sign-in — go-live checklist

Branch: `fix/apple-review-signin-and-guest-purchase`
Purpose: App Review rejection of 3.0.0 (3), Guidelines 4 and 5.1.1(v).

Nothing in this branch has been applied to production. Every step below
changes live systems and needs the owner's approval first.

## What changed

- Guideline 4: native Sign in with Apple on iOS/macOS; Google opens in an
  in-app sheet, not Safari. Entitlement added to `ios/Runner/Runner.entitlements`.
- Guideline 5.1.1(v): Subscribe and Restore work without an account. The app
  starts an anonymous Supabase session only when someone taps Subscribe or
  Restore. No email, name or password is collected.
- A guest who paid and later signs in or registers gets an automatic store
  restore so the subscription moves to the account.
- CE courses, CE checkout, certificates, account deletion and reviewer drafts
  still require a registered account.
- Android: sandbox tester accounts follow the normal customer rule, so new
  Android accounts are no longer blocked from purchasing.
- Guests may receive sandbox tester status (owner-approved 2026-10-10) so App
  Review's sandbox purchase without an account unlocks content.

## Go-live order (server first; the current app is unaffected by it)

1. Supabase -> Authentication -> Sign In / Providers -> enable
   **Allow anonymous sign-ins**.
2. Apply `supabase/migrations/20261010120000_guest_subscription_purchases.sql`.
   It replaces five functions with their live definitions plus the guest
   condition. Local test: `node scripts/test_guest_subscriptions_db.mjs`.
3. Deploy `supabase/functions/revenuecat-sync` (only `index.ts` changed).
4. RevenueCat -> Project settings -> Restore behavior: confirm
   **Transfer to new App User ID** (needed for guest -> account moves).
5. Supabase -> Apple provider Client IDs:
   `com.cehalo.lumaanesthesia.signin,com.base6a35a143e93e5ed18ad346be.app`
   (done by owner 2026-10-10).
6. Build with `scripts/build_apple_release.sh` on a Mac, new build number.

## Verification run on 2026-10-10 (local only)

- Flutter: 958 passed; 6 pre-existing `compact_home_welcome_test` layout
  failures also fail on `main` without these changes.
- Database: 17 of 17 checks in `supabase/tests/guest_subscription_assertions.sql`.
- revenuecat-sync: 19 of 19 Deno tests; `deno check index.ts` clean.
- Not yet verified: on-device Sign in with Apple, a real sandbox purchase as
  a guest, and the guest -> account restore on a device.
