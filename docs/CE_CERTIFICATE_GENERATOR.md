# CE HALO Course 1 · Certificate Generator Handoff

The approved certificate design is integrated with server-authorized award records, private PDF archives, and provider-only reporting. Course 2 uses the same layout with its own title, approval, credit designations, records, and archive.

## Using the certificate area

- **Creator preview:** Open a course, complete the single course registration, and choose “Course certificate” followed by “Preview certificate design.” Creator access does not require a purchase and awards no credits.
- **Registration:** Name, credentials, optional AANA ID, completion location, and participation dates are saved once per account and course. Evaluations do not repeat those identity fields.
- **Location:** The certificate says “Location of Completion,” without “learner-reported.”
- **Dates:** Learners enter their participation range. The actual completion date comes from recorded activity, not the date the PDF is downloaded.
- **Design:** Portrait US Letter, original CE HALO logo, double navy border, gold rule, signature above approval wording, and provider identity “Nicole M. Fetzer, MS, CRNA.”

## Official records and downloads

An award requires a non-preview account, a verified course entitlement, released course, enabled and approved certificate settings, validated participation dates, and completion of every required module, quiz, and evaluation. Course 1 requires eleven modules; Course 2 requires ten.

The server saves an immutable award snapshot. The authenticated download function renders the approved template, stores the PDF in a private bucket, and records its SHA-256 checksum. Subsequent downloads retrieve those archived bytes rather than regenerating a certificate from edited registration details.

- **Monthly records:** Choose “Provider records” inside the relevant course, then “Full-course certificates,” select the month, and export CSV. Module activity and evaluations are a separate view.
- **Reporting:** Course 1 uses Course ID 1047239 and reporting class 196397. Course 2 uses Course ID 1047241 and reporting class 196400. Class numbers remain in provider records, not learner certificates.
- **Manual AANA submission:** Exporting a CSV or generating a certificate does not submit credits to AANA. Confirm the portal’s current import requirements before uploading.
- **Corrections:** Do not overwrite issued awards or archived PDFs. A formal correction/revocation workflow has not been added.

## Current release state

The approved design and signature are stored for both courses. Both courses remain unreleased for ordinary learners, official issuance is disabled, and there are zero official awards.

The backend certificate functions and private archives are deployed. Local PDF rendering, browser previews/downloads, database authorization, immutable records, provider exports, and anonymous-download rejection were tested. No real certificate was issued and no learner email was sent during testing.

Native iOS/Android purchase and download/share testing, end-to-end authorized official issuance in a controlled test environment, and launch configuration remain required. Course 2 store-product mapping and price have deliberately not been invented.

## Account changes

- **Forgot password:** My Account offers an email-reset request and a new-password screen reached by the Supabase recovery callback. Request confirmation is generic to avoid disclosing account existence.
- **Restore Purchases:** My Account uses the existing signed-in RevenueCat/store restoration and server verification flow. It never starts a new purchase. Web users are directed to the configured mobile app.
- **Welcome screens:** Completing onboarding is remembered locally. Routine reopening or signing out does not clear it; new devices/browser profiles or cleared local storage can show onboarding again.
- **Remaining verification:** Test a real reset email on iOS, Android, and the intended web origin. Supabase’s permitted redirect URLs must include `com.luma.anesthesia://login-callback/` and the chosen web origins. The future CE domain is not configured in this update.

## Mac preview

From the existing Luma Anesthesia Flutter repository folder:

```bash
git switch main && git pull --ff-only origin main && flutter pub get && flutter run -d chrome
```

For the CE portal instead:

```bash
git switch main && git pull --ff-only origin main && flutter pub get && flutter run -d chrome -t lib/ce_portal_main.dart
```
