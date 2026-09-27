# Free Quick References

Owner direction on September 27, 2026: all Quick References are free, without a subscription or sign-in gate. Continue the requested charts for a single final owner review.

## Access boundary

- `quick_reference_catalog`: published metadata only for guests/authenticated clients.
- `quick_reference_sections`: published bodies readable by guests/authenticated clients, without an entitlement check.
- Unpublished metadata/bodies remain private. Clients cannot write either table.
- No other module's premium policies were changed. Earlier documentation describing premium Quick References is superseded by this decision.
- The welcome slide and browse view explicitly state free access.

## Content additions

The existing five guides are retained. Nineteen additional guides cover induction, hemodynamic support, infusions, measurements, SVT/AF/cardioversion, WPW, valves, antibiotic redosing, anticoagulant reversal, massive transfusion, opioids, local anesthetic maxima/LAST, PONV, neuromuscular blockade, bronchospasm, anaphylaxis, glucose, ACLS and PALS.

Clinical rows contain direct source links. Adult and pediatric scope notices differ; chart rendering is detected from the content instead of an allowlist of three guide IDs.

These are quick references for clinician review, not patient-specific orders, an independent clinical validation or a substitute for full algorithms, product labels and local protocols. No automated dosing calculator or universal glucose sliding scale was introduced.

## Current-source considerations

- [2025 AHA cardioversion](https://cpr.heart.org/-/media/CPR-Files/CPR-Guidelines-Files/2025-Algorithms/Algorithm-ACLS-Electrical-Cardioversion-250514.pdf?sc_lang=en) includes 200 J for both AF and flutter.
- [2025 PALS arrest](https://cpr.heart.org/-/media/CPR-Files/CPR-Guidelines-Files/2025-Algorithms/Algorithm-PALS-CA-250123.pdf?sc_lang=en) gives a 300 mg first-dose amiodarone maximum and 150 mg subsequent-dose maximum.
- [FDA Andexxa communication](https://www.fda.gov/safety/medical-product-safety-information/update-safety-andexxa-astrazeneca-fda-safety-communication) reports US sales ending December 22, 2025; older andexanet dosing charts are not carried forward as a routine US option.
- [ADA 2026](https://pmc.ncbi.nlm.nih.gov/articles/PMC12690180/) and [SAMBA ambulatory guidance](https://www.apsf.org/in-the-literature/society-for-ambulatory-anesthesia-updated-consensus-statement-on-perioperative-blood-glucose-management/) targets are distinguished, not falsely attributed to an ASA glucose cutoff.

## Reproducibility

Run `node tool/prepare_remaining_quick_reference_seed.mjs` to regenerate SQL and metadata without database writes. `supabase/tests/quick_references_access.sql` verifies guest/unpaid access and hidden drafts in a rollback-only transaction.

Run `flutter test` and `flutter analyze`. Deployment applies only the prepared content upserts and the two-table read-policy migration; content is not embedded in the Flutter client.
