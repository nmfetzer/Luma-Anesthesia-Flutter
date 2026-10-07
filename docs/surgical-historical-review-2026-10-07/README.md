# Surgical Case Prep: Historical Specialty Review

October 7, 2026. This batch reconciles Bariatric, Burns and Colorectal historical notes against the current adult clinical-review drafts. It makes evidence-supported source changes without clinical signoff, production activation or native release.

## What was reviewed

| Specialty | Historical cases | Historical items |
|---|---:|---:|
| Bariatric | 2 | 25 |
| Burns | 2 | 19 |
| Colorectal | 7 | 84 |
| Total | 11 | 128 |

The 128 items comprise 65 review notes, 33 evidence gaps and 30 numerical flags. The historic combined escharotomy/fasciotomy entry maps to two current references; ten current records changed because some shared additions also apply to newer bariatric/burn cases.

- **Existing coverage:** 41 items already addressed in current drafts.
- **Scope boundaries:** 29 items deliberately do not supply unsupported universal protocols.
- **Updated content:** 20 historical items received supporting additions in this batch.
- **Open evidence:** Eight historical notes remain partially covered and explicitly open.
- **Numerical classification:** Eleven qualified numbers verified, eleven historical statements superseded, and eight identifiers/provenance flags distinguished from treatment numbers.

These are note dispositions, not 128 confirmed defects and not 120 clinical approvals. A scope boundary or updated note may still describe genuine uncertainty.

## Source changes

- **Bariatric:** Five references now explicitly retain conditional quantitative TOF recovery and scoped multimodal PONV planning. RYGB includes ASMBS marginal-ulcer/NSAID considerations and qualified PPI prophylaxis. ([ASA summary](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/), [ERAS](https://link.springer.com/article/10.1007/s00268-021-06394-9), [ASMBS](https://asmbs.org/wp-content/uploads/2024/11/American-Society-for-Metabolic-and-Bariatric-Surgery-literature-review-on-risk-factors-screening-recommendations-and-prophylaxis-for-marginal-ulcers-after-metabolic-and-bariatric-surgery.pdf))
- **Burns:** Two acute-excision references add adult major-burn transfusion scope/exceptions, conditional TXA guidance, the limited-graft trial distinction, cell-salvage uncertainty and qualified excision-timing evidence. Escharotomy gains explicit local-analgesia and reassessment coverage. ([ABA](https://doi.org/10.1093/jbcr/iraf021), [Tranburn](https://pmc.ncbi.nlm.nih.gov/articles/PMC12755343/), [cell salvage](https://pmc.ncbi.nlm.nih.gov/articles/PMC12768276/), [timing](https://pmc.ncbi.nlm.nih.gov/articles/PMC13309668/), [escharotomy](https://www.ncbi.nlm.nih.gov/sites/books/NBK482120/))
- **Colorectal:** Ostomy reversal now qualifies preclosure testing and surgical depth-based stoma assessment. Hemorrhoidectomy distinguishes its preparation and antithrombotic planning from colorectal resections, rubber-band ligation and neuraxial eligibility. ([closure review](https://pmc.ncbi.nlm.nih.gov/articles/PMC12159718/), [stoma complications](https://pmc.ncbi.nlm.nih.gov/articles/PMC11466528/), [Taiwan consensus](https://pmc.ncbi.nlm.nih.gov/articles/PMC12572025/), [ASCRS](https://www.ascrsu.com/ascrs/view/ASCRS-Evidence-Based-Guidelines-and-Expert-Consensus/3982022/8/Management_of_Hemorrhoids__2024_), [ASRA](https://rapm.bmj.com/content/early/2025/01/21/rapm-2024-105766))

## Remaining work

- **Eight partially covered notes:** RYGB-specific regimen uncertainty; sleeve leak-rescue evidence; adult burn timing; TXA/cell-salvage generalizability; comparative escharotomy anesthesia evidence; two APR chronic/phantom pain notes; detailed LAR ureteric-injury guidance.
- **Other specialties:** Not adjudicated by this pass. Prior PR #8 corrections remain separate; source updates do not automatically close every original note.
- **Existing holds:** PAS source timing discrepancy; 2026 gynecologic-oncology ERAS full-text reconciliation; specialist LVAD, ECMO and cardiac-pregnancy signoff.
- **Release acceptance:** Clinician approval, native PDF/layout/offline checks and release authorization remain separate from this technical source merge.

## Technical verification

- 101 targeted Flutter tests passed, including ten new tests and the updated exact hemorrhoidectomy section-count expectation.
- Targeted static analysis passed; production-entry release web compilation passed. No web preview was redeployed.
- Repeat migrations and reconciliation produced byte-identical files after Dart formatting.
- Exactly ten JSON records changed and 340 remained unchanged from baseline `f18d577c4acfc9014b16c313ba42d78603066ebe`; the manual lap-chole reference is unchanged.
- Preservation verification accounts for all 243 original routes, 312 historical records and 3,523 sections through current content or exact archived preimages, and validates 29 exact correction postimages across the two October batches.
- All 351 references remain present. Clinical-draft labels and deferred release routes remain intact.
- The initial test run exposed only an obsolete maximum section-count assertion after the additional hemorrhoidectomy section; the assertion was updated specifically for that case, then all 101 tests passed.

## Files and reproduction

- `HISTORICAL-RECONCILIATION.md`: all 128 original notes, dispositions, current-section locations and source links.
- `historical-reconciliation.json`: exact notes, current evidence excerpts and hashes, plus cases outside this pass.
- `UPDATED-DRAFTS.md`: changed current clinical sections with source URLs.
- `correction-ledger.json`: exact before/after records, hashes and reasons.
- `historical-audit-baseline.json`: immutable original audit, including obsolete text. Do not display archived preimages as current guidance.
- `qa/`: successful targeted tests, analysis and build logs.

Run from the app repository with Node and Flutter installed:

```sh
node scripts/update_surgical_historical_20261007.mjs
dart format lib/surgical_prep/surgical_index.dart
node scripts/reconcile_surgical_history_20261007.mjs
node scripts/verify_surgical_preservation.mjs
flutter test test/surgical_case_content_test.dart test/surgical_case_layout_test.dart test/surgical_catalog_test.dart test/surgical_clinical_updates_test.dart test/surgical_final_specialties_test.dart test/surgical_historical_review_test.dart
flutter analyze lib/surgical_prep test/surgical_catalog_test.dart test/surgical_historical_review_test.dart test/surgical_clinical_updates_test.dart
flutter build web --release --no-wasm-dry-run
```

The migration refuses unknown concurrent record changes. Later clinical edits require an explicit new correction ledger rather than silently rewriting this checkpoint.
