# Surgical Case Prep: TestFlight Review Preparation

Prepared October 8, 2026 for Nicole’s final clinician review. This is source preparation, not a signed iOS archive, TestFlight upload, clinical signoff or public release.

## What changed

- The 351-reference adult/OB catalog is retained. The latest batch updates nine records: five gynecologic oncology/framework references, PAS, LVAD, ECMO and cardiac pregnancy.
- The previously unavailable [2026 ERAS full text](https://www.gynecologiconcology-online.net/article/S0090-8258(26)01999-2/fulltext) is now reconciled for anesthesia-facing topics: anemia, fasting/carbohydrate scope, fluids, analgesia/PONV, VTE prophylaxis and early recovery.
- Oncology VTE guidance now distinguishes cancer laparotomy from MIS, and explicitly separates surgical prophylaxis timing from [ASRA neuraxial requirements](https://rapm.bmj.com/content/early/2025/01/21/rapm-2024-105766).
- PAS has a directly attributed [ACOG/SMFM timing recommendation](https://www.acog.org/clinical/clinical-guidance/obstetric-care-consensus/articles/2018/12/placenta-accreta-spectrum), urgent-delivery exceptions and a visible warning about the unresolved [RCOG internal discrepancy](https://pmc.ncbi.nlm.nih.gov/articles/PMC13485456/).
- Case readers display draft status above the clinical overview and specific notices on the nine updated references. No recommendation has been labeled independently approved.

## Remaining clinician decisions, not missing code

- **PAS timing:** The verified RCOG text still contains different windows in its summary and section 10.2. No correction was verified; the PAS service must choose the applicable clinical pathway.
- **GLP-1 plan:** The ERAS hold/restart table differs from [ASA-endorsed multisociety risk-based guidance](https://www.asahq.org/about-asa/newsroom/news-releases/2024/10/new-multi-society-glp-1-guidance). Both are explained without creating an automatic medication order.
- **Specialist approval:** LVAD, ECMO and cardiac pregnancy still need independent specialist review. The reviewed evidence remains device/configuration/lesion-specific: [ARIES-HM3](https://pubmed.ncbi.nlm.nih.gov/37950897/), [VV-ECMO anticoagulation](https://www.frontiersin.org/journals/medicine/articles/10.3389/fmed.2025.1530411/full), and [ESC pregnancy guideline](https://academic.oup.com/eurheartj/article/46/43/4462/8234487?login=false).
- Other historical evidence limitations remain qualified rather than being converted into invented universal protocols. This batch is not a claim that all historical audit notes were adjudicated.

## Build behavior

The default public build still defers Surgical Case Prep. A dedicated internal build with `LUMA_SURGICAL_REVIEW=true` exposes the home tile, drawer entry, specialty routes and individual cases, including trailing-slash catalog routes.

The flag does not bypass premium access, grant purchases, change accounts, update Supabase or enable AI/EKG/Academy. URL query parameters cannot turn it on. The live CE website and its separate source branch are untouched.

## One Mac build command

From the updated native Flutter repository on the Mac with the existing Xcode signing setup:

```bash
read -r -p "Version (for example 3.0.0): " VERSION
read -r -p "Unused App Store Connect build number: " BUILD
bash scripts/build_surgical_testflight_review.sh "$VERSION" "$BUILD"
```

Choose the version and unused build number from App Store Connect; this document does not assume the previous submission is approved or that any particular number is free. The script verifies preservation, runs the review-mode tests, creates an IPA/archive, verifies its version/build and absence of legacy PDFium, and writes `build/ios/SURGICAL_REVIEW_ARCHIVE.txt`.

**This archive is for internal clinician TestFlight review only. Do not select it for public App Store release.** The script does not upload or submit it. Upload the resulting archive through the existing Xcode/App Store Connect workflow and restrict distribution to the intended internal reviewer(s).

## Final phone acceptance

1. Sign in with the intended review account and confirm it has the existing clinical access entitlement. Review mode itself grants none.
2. Open Surgical Case Prep from Home, browse specialties, search cases, open details and verify source links and the visible notices.
3. Review the changed cases and the rest of the library once; record only substantive corrections and final clinical decisions.
4. Check small-screen/large-text layout, sign-out/access revocation and offline reference behavior using a valid offline access lease. External source links still need connectivity.
5. Recheck CE access, PDF/certificate saving and purchase restoration on the actual iPhone/iPad. Source tests do not establish native acceptance.
6. Only after clinical approval and device acceptance, prepare a separate deliberate public-release change and new archive. Never remove review protections merely to make an unapproved archive look finished.

## Verification scope

- 218 regression tests passed across surgical content/layout/catalog, launch routing, Diagnostics, Regional & Procedures, CE/subscription billing and offline cache behavior.
- 13 review-mode tests passed with `LUMA_SURGICAL_REVIEW=true`, including real app route construction, unpaid catalog/specialty/case denial, small-screen large-text layout and warning placement.
- Targeted surgical/launch/test static analysis passed with no issues. A broader analysis also reports the pre-existing `anonKey` deprecation and drawer `const` suggestion; neither was introduced by this change.
- Production-entry release-mode web compilation passed with the review flag. This is a Dart/compiler check, not iOS acceptance; no website was deployed.
- Preservation checks retain 351 references and validate the exact correction chain. Shell syntax checks passed for the dedicated Mac build command.

No connected Mac is available in this session. An attempted iOS asset build stopped because Xcode’s `xcrun` is unavailable, so no native compilation, signing or TestFlight upload is claimed.
