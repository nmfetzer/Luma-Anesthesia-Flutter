# Luma Anesthesia: Special Considerations migration

The existing Base44-prepared content has been imported into Supabase. Flutter now has a connected Special Considerations library, category browsing, keyword search and a structured detail screen. Authentication setup was intentionally left for later.

## Imported content

| Category | Entries |
|---|---:|
| Cardiac | 10 |
| Endocrine & Metabolic | 20 |
| Hematology & Coagulation | 20 |
| Neuromuscular & Neuro | 20 |
| Syndromic / Congenital | 20 |
| Total | 90 |

- **Source preservation:** The 80 JSON records were retained unchanged in a private archival table. The 10 adult Cardiac Markdown records were structurally converted; their clinical sections were not rewritten. Both original source files are retained in the private project files.
- **Citation cleanup:** The earlier exporter included 32 author-checklist items as citations with empty URLs. They remain in the archived originals but are excluded from the app-facing reference lists. No replacement citations were invented.
- **Review status:** All basic entries and deep dives are `needs_review`. Earlier source review claims were archived, not treated as evidence of a new clinical review. Some deep dives remain outlines.
- **Publication:** Titles and categories are browsable now. The clinical prose remains server-side until explicitly reviewed and released. Importing these records did not publish them as medical guidance.

## Live Supabase structure

Project: `xuckkusbbcxplpqclbxt`. The additive migration `special_considerations_import_foundation` has already been applied. Do not rerun its CREATE TABLE statements on this project.

| Table | Purpose | Imported rows |
|---|---|---:|
| `special_consideration_catalog` | Titles, categories, tags, review and preview flags | 90 |
| `special_considerations` | Eight basic clinical sections and references | 90 |
| `special_consideration_deep_dives` | Separately protected extended content | 90 |
| `special_consideration_imports` | Private originals and checksums | 90 |
| `luma_content_entitlements` | Server-managed clinical subscription authority | No real entitlements created |

No medication records were changed. Import batches are insert-only and skip existing slugs rather than overwriting clinician edits.

## Flutter implementation

- **Navigation:** The existing home and drawer destination `/special-considerations` now opens the connected library.
- **Library:** Alphabetical categories and conditions, category counts, title/category/tag search, clear and back controls, no-match state, loading state and retry.
- **Detail:** Draft notice before release. Published entries render Markdown, collapsible clinical sections, references and related crisis-topic labels.
- **Brand:** Existing cream/navy/gold theme and Fraunces headings are retained.
- **Deep dives:** Separate, on-demand request. They are not included in the catalog or basic content response, and sign-out clears loaded protected content.
- **Dependency:** Added `flutter_markdown_plus: ^1.0.12`.

The code was prepared against Flutter repository commit `74f1f84`. The handoff patch adds the feature without replacing iOS/Android project folders. It does not include clinical source data.

## Access rules

- **Guest:** Browse titles and categories; read a designated basic preview only after clinical publication.
- **Registered account:** Read published basic entries. Anonymous-auth sessions do not qualify.
- **Subscribed account:** Read separately published deep dives with a valid, unrevoked server-managed entitlement.
- **Drafts:** Clinical text is unavailable through app roles, even to a subscribed user.
- **Writes:** App clients cannot publish entries, modify clinical content, read the original-import archive, or grant themselves entitlements.

The schema allows at most one guest preview per category. None has been selected or published. Billing provisioning is not connected, and no subscription or authentication screen was added in this migration. Existing profile subscription fields are not trusted by the new access rules.

## Verification completed

- **Content read-back:** All 90 archived records, checksums, titles, categories, clinical sections, deep dives and normalized tags matched the import source.
- **Repeat import:** Rerunning a batch left the stored records unchanged.
- **Database access tests:** Guest, anonymous-auth, registered account, premium, expired and revoked entitlement cases passed. Draft exclusion and client write protection passed. Test fixtures were rolled back.
- **Flutter tests:** 12 tests passed, covering search, category/draft navigation, error retry, empty state, basic denial, published rendering with synthetic fixtures, lazy deep-dive loading, unavailable deep dives, sign-out clearing, large text on a small screen and existing welcome startup.
- **Static checks:** No analyzer issues in `lib/special_considerations`.
- **Build:** Release web build succeeded with Flutter 3.47.5 / Dart 3.13.4.
- **Browser checks:** The live catalog and actual Supabase counts rendered at desktop and mobile sizes. Category selection, an initial keyword search and draft-detail navigation were exercised. Browser automation of repeated text-entry/clear cycles was inconclusive; the corresponding Flutter widget coverage passed. No claim of exhaustive browser validation is made.

This is migration and implementation verification, not a new clinical-content review. iOS/Android device builds, store signing and purchase flows were not tested.

## Remaining steps

- **Repository delivery:** The source changes are saved privately. No public GitHub push has been made without approval.
- **Clinical review:** Review the existing basic content and outlines, resolve incomplete references/content, and record the actual reviewer and date before changing publication status.
- **Account and subscriptions:** Connect the optional sign-in and subscription callbacks when that work resumes. Billing must update entitlements through a trusted server.
- **Crisis navigation:** Topic labels are preserved. Connect the optional callback only when the matching Crisis Hub destinations exist.

## Applying the source patch

The Supabase import is already complete. The patch is for the Flutter source only and can be applied to a clean checkout at the stated base revision. If the local project has diverged, stop on a failed check rather than forcing an overwrite.

```bash
cd ~/Documents/Luma-Anesthesia-Flutter
git apply --check ~/Downloads/Luma-Special-Considerations.patch &&
git apply ~/Downloads/Luma-Special-Considerations.patch &&
flutter pub get &&
flutter test &&
flutter run -d chrome
```

If the changes are later pushed to GitHub, use the approved GitHub update instead of also applying this patch.
