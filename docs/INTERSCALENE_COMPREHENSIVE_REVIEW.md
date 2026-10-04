# Interscalene: Comprehensive Reference Preview

Prepared October 4, 2026. This is a clinical-content and interface proposal awaiting owner review. It has not been pushed to GitHub or uploaded to TestFlight.

## What changed

Only Interscalene receives the comprehensive layout. Other Regional references retain their existing layout and content.

- Always-visible clinical summary.
- Twelve expandable detailed sections covering selection, respiratory risk and alternatives, anatomy, equipment/positioning, technique safeguards, medication context, adjuvants, block assessment, complications, catheters, recovery, and evidence.
- Seven section shortcuts, full-text search within the detailed sections, and expand/collapse controls.
- Source buttons adjacent to the relevant clinical sections.
- Existing homepage search, subscription boundary, Home navigation, and bundled offline text retained.

## Clinical boundaries and source review

- Technique and anatomy were independently synthesized from the [NYSORA interscalene atlas](https://www.nysora.com/regional-anesthesia/techniques/ultrasound-guided-interscalene-brachial-plexus-block/), with complication context from [StatPearls](https://www.ncbi.nlm.nih.gov/sites/books/NBK519491/?report=printable). No Vargo text, screenshots, or publisher illustrations are embedded.
- The ultrasound atlas opens externally. Real ultrasound images have not been licensed or bundled for offline use, and no simulated ultrasound images were generated.
- Respiratory selection and alternatives draw on the [2023 pulmonary-risk review](https://pmc.ncbi.nlm.nih.gov/articles/PMC10219177/) and [2025 systematic review](https://pubmed.ncbi.nlm.nih.gov/40494113/). The reference avoids universal paralysis rates and clearly notes that the 2025 review searched only through December 2022.
- Catheter/recovery context draws on the [outpatient shoulder review](https://pmc.ncbi.nlm.nih.gov/articles/PMC11630655/), published online in 2024 and in the 2025 journal issue. Its mixed comparative findings are not presented as a mandate for routine continuous catheters.
- Injection and neurologic safeguards use the [ASRA second neurologic complications advisory](https://rapm.bmj.com/content/rapm/40/5/401.full.pdf). Infection precautions use the [ASRA infection-control guideline](https://doi.org/10.1136/rapm-2024-105651). Catheter bleeding considerations link to the [ASRA fifth-edition antithrombotic guideline](https://rapm.bmj.com/content/early/2025/01/21/rapm-2024-105766).
- EXPAREL indication, 133-mg adult interscalene dose, compatibility, and the 96-hour additional-local-anesthetic warning link directly to the [US prescribing information](https://www.exparel.com/prescribing-information.pdf).
- Rebound-pain evidence includes the [2026 network meta-analysis](https://pmc.ncbi.nlm.nih.gov/articles/PMC13446866/), with heterogeneity and indirect-comparison limitations stated.
- Emergency cross-references include the [ASRA LAST aid](https://asra.com/docs/default-source/guidelines-articles/local-anesthetic-systemic-toxicity-rgb.pdf?sfvrsn=33b348e_2).

## Important distinctions

- A published volume range is identified as context, not a universal regimen.
- Concentration-to-milligram arithmetic is explicitly not a dose recommendation or toxicity threshold.
- No universal catheter infusion rate, fixed needle-depth limit, or automatic dosing calculator is introduced.
- No claim that low volume, negative aspiration, nerve stimulation, or pressure monitoring guarantees safety.
- No claim that an analgesic shoulder alternative automatically provides complete surgical anesthesia.
- Clinical content remains a reference for trained clinicians and requires owner review before publication. Software testing is not clinical certification.

## Verification and release scope

- 175 targeted Flutter tests passed, including new accordion/search/shortcut tests, all expanded sections at doubled text size, Regional paid-access tests, homepage navigation/search, Diagnostics regression, and offline-access tests.
- Targeted static analysis passed with no issues.
- No Supabase schema, production data, billing configuration, AI, or CE changes are included.
- Preview-only access injection remains in a separate local preview checkout and is not part of the production proposal.
- A future approved GitHub push would prepare source code for a subsequent build. It would not update an installed TestFlight build or publish an App Store release.
