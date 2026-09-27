# ABG & Acid–Base clinician preview QA

## Scope

- Replaces the previous fourteen-card teaching module with twelve adult perioperative references.
- Removes introductory lessons and synthetic student cases.
- Adds differential tables for unexplained acidosis, metabolic alkalosis and hypercapnia. Tables become labeled blocks on narrow screens.
- Keeps compensation, anion-gap and delta-gap formulas in one collapsible panel.
- Includes management considerations, anesthesia implications and pitfalls with direct source buttons.
- No patient-specific interpreter, dose calculator or automatic diagnosis.
- Existing preview-only guard remains. No production Supabase changes, GitHub push, access-rule changes or clinical signoff.

## Automated verification

- All 23 targeted Flutter tests passed: seven ABG tests plus Diagnostics, home search and home navigation regressions.
- Static analysis of Diagnostics and both reference test files: no issues.
- Release-mode Flutter web build completed.
- Tests cover source presence, twelve unique topics, differential data, DKA thresholds, current bicarbonate trial citations, search, group filters, empty-state reset, formula panel, mobile layout and the production draft guard.

## Rendered verification

- Desktop 1280 × 900 and mobile 375 × 812 screenshots inspected.
- Cream/navy/gold styling preserved; no horizontal clipping observed.
- Hub count is twelve and opens the rebuilt reference.
- Formula panel opens and closes.
- Metabolic filter plus “unexplained” returns two relevant cards. The intraoperative-acidosis reference expands to its table and bulleted content.
- Desktop renders a three-column differential table. Mobile renders labeled blocks with wrapping source labels.
- Unmatched search shows reset; reset restores the unfiltered list.
- Clicked the BJA Education acidosis differential source and confirmed https://pmc.ncbi.nlm.nih.gov/articles/PMC10874758/.
- Back returns to Diagnostics and Home to the main dashboard.
- No browser page errors observed. Browser session closed.

## Clinical sourcing

Fetched and checked the relevant content from these references. Source verification and software testing are not clinical approval.

- Perioperative metabolic acidosis: https://pmc.ncbi.nlm.nih.gov/articles/PMC10874758/
- Metabolic alkalosis and mixed disorders: https://pmc.ncbi.nlm.nih.gov/articles/PMC10028421/
- Adult hyperglycemic crises consensus (2024): https://pmc.ncbi.nlm.nih.gov/articles/PMC11272983/
- Metabolic alkalosis: https://www.merckmanuals.com/professional/nephrology/acid-base-regulation-and-disorders/metabolic-alkalosis
- Acid–base disorders: https://www.merckmanuals.com/professional/nephrology/acid-base-regulation-and-disorders/acid-base-disorders
- Compensation table: https://www.merckmanuals.com/professional/multimedia/table/primary-changes-and-compensations-in-simple-acid-base-disorders
- Respiratory disorders: https://www.openanesthesia.org/keywords/respiratory-acidosis-and-alkalosis/
- Tourniquet physiology: https://www.openanesthesia.org/keywords/perioperative-tourniquet-use/
- BICARICU-2 primary publication: https://pubmed.ncbi.nlm.nih.gov/41159812/
- SODa-BIC primary publication: https://pubmed.ncbi.nlm.nih.gov/42283370/
- Adult arterial/venous gas review (2025): https://pmc.ncbi.nlm.nih.gov/articles/PMC12387505/
- Sampling limitations: https://pmc.ncbi.nlm.nih.gov/articles/PMC3900096/
- Capnography: https://www.openanesthesia.org/wp-content/uploads/2024/10/08/ICU_one_pager_end_tidal_co2_v11.pdf
- Peri-intubation physiology: https://pmc.ncbi.nlm.nih.gov/articles/PMC4703154/

Older physiology reviews are used for the relevant mechanisms and limitations, not as blanket endorsement of all their recommendations. Bicarbonate content distinguishes the newer trials from older subgroup interpretations and does not generalize their results to every indication.
