# Diagnostics: next-build completion

Prepared October 3, 2026. Publication pending approval.

## Included

- One compact **Diagnostics** home tile and drawer link, alongside Practice Guidelines.
- Seven areas: Lab Values, ABG & Acid–Base, Pulmonary Function Tests, Echo / TEE, Imaging, POCUS, and Carotid Doppler.
- Existing clinician-facing material: 35 laboratory references, 12 ABG topics and 29 topics across the other five modules.
- The ACT comparison chart remains at the beginning of the expanded ACT entry.
- Troponin, CK/CPK, CK-MB, lactate, BNP and NT-proBNP remain in the lab library.
- Search, category filters, expandable reference sections and direct source buttons.
- No reference-card counts on the home/Diagnostics cards or module listings.
- EKG remains excluded. AI, Case Prep, Regional & Procedures and Luma Academy remain deferred.

## Access and offline design

The production route uses the existing `PremiumAccessGate` and Supabase `has_clinical_premium_access` entitlement. Paid subscriptions and eligible complimentary CE access follow the existing access rules.

- The hub and every directly addressed sub-route require the same access check.
- Nested reference routes also have an access boundary. Sign-out, revocation or an account change removes the open protected view.
- Public production URLs cannot turn on review access. Only `lib/preview_main.dart` explicitly enables the review mode for the private preview.
- The existing reference text is bundled with the app, as it was for the earlier Diagnostics draft. No new Supabase content table or migration is needed for this implementation.
- Bundled text is not an encrypted server-delivered download. This is an in-app subscription boundary, not a claim of DRM or secrecy for code in the public repository.
- Native offline access requires a previously verified, account-bound entitlement lease. The existing maximum is 72 hours, or the entitlement expiration if sooner. First-time offline access cannot create a lease.
- External references still require internet. Browser preview behavior is not proof of native airplane-mode behavior; check on the installed build.

## Clinical scope

This completion preserves the four existing clinical-content files without changing their values, dosing statements or recommendations:

- `diagnostics_content.dart`
- `lab_clinical_guidance.dart`
- `abg_content.dart`
- `clinical_modules.dart`

A focused source spot-check confirmed the retained CPB ACT threshold and analyzer qualification ([STS/SCA/AmSECT guideline](https://pmc.ncbi.nlm.nih.gov/articles/PMC5850589/)), DKA potassium/bicarbonate/resolution criteria ([2024 adult hyperglycemic-crisis consensus](https://pmc.ncbi.nlm.nih.gov/articles/PMC11272983/)), recent bicarbonate-trial conclusion ([SODa-BIC trial](https://pubmed.ncbi.nlm.nih.gov/42283370/)), and native-carotid velocity criteria ([IAC recommendations](https://intersocietal.org/wp-content/uploads/2023/11/IAC-Updated-Recommendations-for-Carotid-Stenosis-Interpretation-Criteria_11.1.23.pdf)).

This is not a new independent clinical approval or an exhaustive re-review of every cited publication. Native production publication remains the owner's decision. No new patient-input calculators or AI functionality are added.

## QA inventory

- Home and drawer navigation; no Diagnostics item in Coming Soon.
- All seven categories open real references, not preparation placeholders.
- Hub search, module search, category filters, clear/reset and no-results states.
- ACT chart at top; clinician-oriented ABG content retained.
- Source-button launch and failure handling.
- Home return from hub and child sections.
- Subscription denial at hub and all seven deep routes.
- Revocation while a child reference is open, then back navigation.
- Native offline entitlement expiry and account isolation through the existing cache/gate tests.
- 320-, 375- and 820-pixel layouts, including enlarged text.
- Browser screenshots of phone, tablet and desktop views.
- Exploratory checks: empty search results and switching categories after a search.

## Verification results

- Full Flutter regression run: 662 passing checks and one obsolete test that expected Diagnostics to remain deferred. That test was corrected for the approved feature direction; the focused 22-test rerun passed, including all Diagnostics release/access checks and app route-factory checks.
- Targeted static analysis: no issues.
- Release web preview build: successful.
- Browser QA passed for all seven categories, ACT expansion and external source opening, ABG formula expansion, empty-search/clear behavior, Carotid expansion, and Home navigation.
- Screenshots inspected at 375-pixel phone, 820-pixel tablet and 1280-pixel desktop widths. Widget tests also covered 320-pixel layouts and double text scale.
- Clinical data files were verified unchanged against the GitHub baseline.
- No iOS archive or native-device airplane-mode test was performed in this Linux workspace.

## Release boundary

No CE website branch, course content, purchase product, account record, or production Supabase data is changed. A GitHub push does not upload a TestFlight build; the next native archive must be built and uploaded separately.
