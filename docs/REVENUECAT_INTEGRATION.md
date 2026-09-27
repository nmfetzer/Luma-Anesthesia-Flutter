# Luma Anesthesia RevenueCat Integration

## Status

Flutter integration is implemented with checkout disabled by default. This is not a claim of a completed real-device purchase, deployed billing backend, or store-submission readiness. Existing CE and Quick Reference work was preserved; no RevenueCat dashboard products, offerings, entitlements, or live Supabase data were changed.

## Existing configuration used

User-supplied RevenueCat screenshots identify project `69adc637`, offering `default`, and entitlement `Luma Anesthesia App Pro` (REST identifier `entla7db5fefda`). The integration uses the exact entitlement identifier, not the REST ID.

| Platform | Monthly | Annual |
|---|---|---|
| Apple | `Luma_Anesthesia_App_Monthly` | `Luma_Anesthesia_Yearly_Pro` |
| Google Play | `luma_anesthesia_app_monthly:monthly` | `luma_anesthesia_yearly_pro:yearly` |

Only `$rc_monthly` and `$rc_annual` packages containing these matching products and periods are displayed. Shared Nurse and ICU/lifetime mappings are left untouched and cannot be selected by this code.

The September 27 RevenueCat Apps screenshot confirms `com.base6a35a143e93e5ed18ad346be.app` for both Luma Anesthesia store entries. Flutter's iOS Debug/Profile/Release bundle identifiers and Android application ID now match it. RunnerTests uses the same identifier with `.RunnerTests` appended. Android's Kotlin namespace and the existing `com.luma.anesthesia` OAuth callback scheme are unchanged. Public SDK keys remain masked in the supplied screenshot and are not configured.

## Implemented

- RevenueCat `purchases_flutter` integration, resolved locally to 10.13.2.
- Existing celestial/cream paywall preserved, with store-provided localized prices instead of invented preview prices.
- Purchase, restore, refresh, cancellation, pending-payment, unavailable-store, verification-failure, and duplicate-tap handling.
- Supabase user UUID used for RevenueCat identity; no email used as the customer ID.
- Serialized store operations and stale-result rejection on sign-out/account change.
- App start, resume, and five-minute foreground/runtime refresh path.
- No native checkout in Chrome, no secret API keys in Flutter, no direct client entitlement writes.
- Crisis references and Drug Library Deep Dives recheck server access after returning from the paywall.
- Free content messaging, legal links, renewal disclosure, and separate CE access preserved.
- AI credits and CE purchases are not enabled by this change.

The SDK uses app-specific public keys, configured separately for Apple and Google, as described in [RevenueCat’s configuration documentation](https://www.revenuecat.com/docs/getting-started/configuring-sdk). Customer identity follows the explicit app-user-ID approach in [RevenueCat’s customer identification documentation](https://www.revenuecat.com/docs/customers/identifying-customers).

## Backend draft, not deployed

Files are intentionally under `supabase/billing-draft/`, outside automatic migrations and functions deployment directories.

- `revenuecat_access.sql`: adds an isolated, server-owned subscription table and extends the existing access function without changing manual/owner entitlements or CE grants.
- `revenuecat-sync/index.ts`: validates the Supabase JWT, derives the user UUID from Auth, fetches the RevenueCat subscriber server-to-server, records a verified snapshot, then checks the real premium-access RPC.
- `validation.ts`: enforces entitlement, product, store, expiry, sandbox rules, and bounded access leases.
- `validation_test.ts`: checks active, expired, refunded, canceled, mismatched, malformed, and sandbox scenarios.

The draft grants at most a 15-minute lease, refreshed while the app is used, so a stale record cannot confer subscription access indefinitely. Canceled auto-renewal retains access through the paid expiration; refund/transfer changes are reflected on refresh or lease expiry. This trades offline paid-reference availability for fail-closed verification. It does not remotely erase clinical content already displayed or downloaded. Existing owner/CE access is independent.

No webhook is deployed. The bounded-lease design avoids depending on webhook delivery for expiration, but live refund/transfer behavior and provider API field shapes must be tested against real sandbox customers before release. Billing retries are user-triggered or periodic; this release draft does not implement grace-period access beyond the verified paid expiry.

## Activation requirements

1. Native app identifiers now match the existing RevenueCat entries. Verify matching Apple provisioning and Google upload signing before native testing; the Android release target still uses debug signing and is not submission-ready.
2. Obtain the Luma Anesthesia Apple and Google public SDK keys. Do not use Nurse keys, a test-store key, or a secret REST key in Flutter.
3. Select the correct saved RevenueCat REST credential. Two saved entries currently have the same name/host, so neither was chosen arbitrarily.
4. Review and approve the exact SQL and Edge Function deployment. Set the server-only secret through Supabase secrets, never commit it.
5. Use a separate test Supabase environment for sandbox grants. This draft explicitly blocks sandbox grants in production project `xuckkusbbcxplpqclbxt`.
6. Test purchase and restore on signed iOS/Android builds, then enable the production build flag only after acceptance.

Apple requires the In-App Purchase capability and supported platform setup; Android purchase activity configuration must also be correct, per [RevenueCat’s Flutter installation guide](https://www.revenuecat.com/docs/getting-started/installation/flutter). Current Android activity uses `singleTop`; actual signing, store-app matching, and native capability checks remain pending.

### Flutter build configuration

Default: `LUMA_BILLING_ENABLED=false`. The web path remains non-purchasing even if the flag is true.

For a configured, approved native test build only:

```sh
flutter run \
  --dart-define=LUMA_BILLING_ENABLED=true \
  --dart-define=REVENUECAT_APPLE_PUBLIC_KEY=YOUR_APPLE_PUBLIC_SDK_KEY \
  --dart-define=REVENUECAT_GOOGLE_PUBLIC_KEY=YOUR_GOOGLE_PUBLIC_SDK_KEY
```

The code rejects keys without the expected `appl_`/`goog_` prefix. These placeholders are not live credentials.

### Server configuration

- `REVENUECAT_SECRET_API_KEY`: correct RevenueCat v1-compatible secret; server only.
- `LUMA_BILLING_SERVER_ENABLED=true`: independent server activation switch.
- Supabase-provided URL, anon key, and service-role key.
- `LUMA_ALLOW_SANDBOX=true`: test environment only, explicitly rejected for the production project.
- Deploy as `revenuecat-sync` after applying the reviewed SQL. Auth is validated inside the handler; configure the Edge Function gateway appropriately for the project's JWT signing setup.

## Native acceptance checks

- Fresh signed-in user: each plan shows its actual store price and correct period.
- Successful Apple and Google test purchase: only the matching Supabase account gains access.
- Cancel, pending approval, network failure, missing product, wrong key: no fabricated access.
- Restore after reinstall: access returns without a second charge.
- Account A signs out, account B signs in: no inherited client state; confirm RevenueCat restore/transfer policy matches the intended ownership rule.
- Cancel auto-renewal, refund, expiration, renewal, and transfer: verify server state and lease expiry.
- Native app resumes after pending approval: access refreshes.
- Existing CE bonus and owner grants remain valid; no changes to other sessions' course/Quick Reference files.

These checks require native store/sandbox testing, not just the Chrome preview.
