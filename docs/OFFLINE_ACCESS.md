# Offline reference access

Implemented September 27, 2026. This adds downloadable clinical references to the installed Flutter app, not offline account services or CE course downloads.

## How to use

1. Open **Account → Offline downloads**, or use the app menu.
2. While connected, select **Download / update references** and wait for the completion message.
3. Keep the same account signed in when using paid references without internet.
4. Update downloads regularly. A downloaded-copy banner shows the saved date when local content is used.

## Included content

- **Free references:** Drug Library public fields, vasopressor/infusion medication content, blood products, Quick References, and free published Crisis Hub references.
- **Protected references:** Published Crisis Hub and Pathophysiology & Anesthesia Considerations content, plus available medication and pathophysiology Deep Dives, when verified paid or complimentary access permits them.
- **Provider support:** Mental Health & Recovery information remains bundled and free. Calling a help number still requires telephone service.
- **Typography:** Fraunces, Inter, and JetBrains Mono font assets are bundled so native styling does not depend on fetching Google Fonts.

## Access and storage safeguards

- Native public references use versioned files in application support storage.
- Protected records and the access lease are encrypted with AES-256-GCM. Their cache identifiers are authenticated; the encryption key uses platform secure storage.
- Paid copies are account-specific. Signing out, changing accounts, or receiving an authoritative access revocation removes protected copies.
- Offline paid access lasts no more than 72 hours after verification, or the actual entitlement expiration, whichever is earlier. Reconnect to verify again.
- Expiration and app-resume events refresh protected screens so already-open content is not intentionally left visible after access ends.
- Only connection failures permit local fallback. Authorization failures and malformed responses do not silently fall back to a protected copy.
- A failed or partial batch does not record a complete download. Previously saved records remain available where their access conditions still permit use.
- This is client-side access protection, not a claim of tamper-proof DRM on modified devices. Device-clock rollback detection is limited.

## Still needs internet

- Account creation, sign-in, password recovery, and server-side account operations.
- Purchases, restoration, and entitlement verification.
- External source websites and externally hosted algorithm PDFs.
- CE progress synchronization, completion, certificates, and course materials not separately downloaded by a future CE feature.
- First download and updates. A new installation is not shipped with the entire Supabase clinical library preloaded.

## Browser preview limitations

The nested Flutter preview uses session-only memory storage. It supports testing free downloaded references during that page session, but reloading can require internet. Protected downloads are disabled on web.

The web renderer can fetch its own fallback font during startup; the preview is not an installable native offline test. Unmodified browser builds also have browser-storage quota limits. Use the installed iOS or Android build for persistent protected downloads.

## Verification completed

- **Full Flutter suite before the final concurrent CE-library merge:** 516 tests passed. After that merge, all 42 targeted offline, CE-learning, CE-library, and app-navigation tests passed; the navigation expectation was updated for the new CE library screen.
- **Static analysis:** No errors or warnings; 108 informational lint findings remain in the combined app.
- **Release compilation:** Flutter web release preview built successfully after merging the concurrent CE and billing changes.
- **New offline tests:** 23 tests covering cache encryption, account separation, sign-out, expiry, corruption, clock rollback, partial downloads, storage failures, public-only web behavior, entitlement and CE-bonus expiry, and file-backed storage across cache instances.
- **Live public download:** The preview downloaded the public reference batch, including 778 medication records, and reported completion.
- **Network-interruption browser check:** With Supabase requests blocked, the Drug Library catalog, cardiac medication category, Adenosine clinical body, and Quick Reference catalog reopened. The drug screen displayed the downloaded-copy date.
- **Visual checks:** Downloads screen reviewed at 390×844 and 1024×1366; clinical detail and offline banner reviewed at 390×844.
- No clinical wording or production Supabase permissions were changed for offline access. No purchases were enabled.

## Native release checks still required

These checks have not been completed on a physical iPhone, iPad, or Android device in this environment:

1. Build the current native app with the new plugins and verify iOS Keychain entitlements/provisioning.
2. Sign in with a verified test entitlement and download references.
3. Enable airplane mode, force-quit, relaunch, and open representative content from every included reference group, including Deep Dives.
4. Confirm paid content locks at the lease deadline; confirm signing out removes paid copies but retains free references.
5. Reconnect and verify refresh, expired/revoked access, and interrupted-download recovery.
6. Confirm behavior with limited storage and after a device restart.

Automated file-storage tests use a mocked secure-key store. They do not replace physical-device Keychain/Keystore or airplane-mode verification.
