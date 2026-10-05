# Surgical Case Prep: Specialty Navigation, Bariatric and Burns

Updated October 5, 2026. This is a staged clinical-review milestone, not release approval. No GitHub push, Supabase change or TestFlight upload was performed.

## What changed

- **Navigation**: 22 specialty tiles replace the flat browsing list. A specialty opens its own procedure subtiles; root search still finds cases across specialties, and specialty search stays within the selected specialty.
- **Bariatric**: five cases, ordered Sleeve, Roux-en-Y, Lap Band, Duodenal Switch and SADI-S. The last two display “Less common procedure.”
- **Burns**: seven cases, ordered Debridement/Excision, Tangential Excision + STSG, Full-Thickness Graft/Flap, Escharotomy, Fasciotomy, Burn-Related Amputation and Contracture Release.
- **Reader**: each new case has a quick clinical overview plus 15 expandable, bulleted detail sections with source buttons. These remain clinical reference materials, not task checklists.
- **Counts**: 251 total adult/OB cases, comprising 250 bundled JSON records and the separate manual cholecystectomy reference. Categories outside Bariatric and Burns were preserved, not re-reviewed in this milestone.
- **Compatibility**: the old combined escharotomy/fasciotomy URL now opens the Burns specialty so readers can choose the correct procedure.

## Clinically important qualifications

- **Sleeve percentage**: approximately 80% refers to stomach removed. The cited 2024 MBSAQIP-based analysis reported at ASMBS in 2026 describes a sleeve share of 58.35%, with its study denominator explicitly identified; no 80%-of-all-cases claim was added ([ASMBS anatomy](https://asmbs.org/patients/bariatric-surgery-procedures/), [ASMBS study report](https://asmbs.org/news_releases/bariatric-surgery-procedures-fall-below-200000-first-time-since-2020-new-research-finds/)).
- **Gastric tubes**: avoid routine/blind NG placement, while distinguishing necessary surgeon-coordinated OG decompression and the intentionally placed calibration bougie ([BJA Education](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/)).
- **Bariatric drug scalars**: agent-specific guidance separates induction from maintenance, identifies older evidence and preserves actual-body-weight sugammadex dosing from the US label ([BJA drug review](https://academic.oup.com/bja/article/105/suppl_1/i16/236249?guestAccessKey=), [BRIDION label](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5171d883-fe8f-482c-97ab-40b00975b64a)).
- **Airway/GLP-1**: ramped/head-up airway preparation is the default where feasible, with individualized aspiration assessment rather than automatic cancellation or a universal GLP-1 hold ([SOBA 2025](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/), [multisociety GLP-1 guidance](https://www.asahq.org/about-asa/newsroom/news-releases/2024/10/new-multi-society-glp-1-guidance)).
- **Liver retraction**: possible traction-related vagal bradycardia is included, but the direct liver-retraction evidence is historical and no contemporary bariatric incidence is asserted ([historical review](https://link.springer.com/content/pdf/10.1007/BF03005473.pdf), [RCoA perioperative bradycardia review](https://rcoa.ac.uk/sites/default/files/documents/2023-11/NAP7_Chapter%2024_FINAL.pdf)).
- **Succinylcholine**: conservative avoidance after 24 hours following major burns; no guaranteed safe 24–48-hour window or automatic calendar-based restart date ([burn anesthesia review](https://pmc.ncbi.nlm.nih.gov/articles/PMC7121311/)).
- **Burn fluids**: the initial adult major-burn resuscitation estimate is distinguished from an hourly dose and from operative hemorrhage replacement; subsequent fluids require response-guided titration ([ABA guideline](https://pubmed.ncbi.nlm.nih.gov/38051821/), [AAFP interpretation](https://www.aafp.org/afp/2025/0800/practice-guidelines-resuscitation-patients-burns)).
- **Smoke toxicity**: standard pulse oximetry does not exclude CO poisoning; cyanide treatment depends on exposure and clinical suspicion, with hydroxocobalamin laboratory/dialysis interference flagged ([CDC CO guidance](https://www.cdc.gov/carbon-monoxide/hcp/clinical-guidance/index.html), [CYANOKIT label](https://dailymed.nlm.nih.gov/dailymed/lookup.cfm?setid=d56fcc8d-bd64-46ab-b0c0-2124bd745a6b)).
- **Burn pain**: background, procedural, donor-site and neuropathic pain are differentiated; amputation references include phantom limb pain without promising prevention by a single intervention ([ABA pain guideline](https://pmc.ncbi.nlm.nih.gov/articles/PMC7703676/), [amputation reference](https://www.ncbi.nlm.nih.gov/books/NBK546594/)).

## Verification and boundaries

- Targeted Flutter analysis: no issues.
- 175 targeted tests passed across the surgical catalog/reader, Diagnostics, Regional and premium-access gate.
- Tests cover the 251-record catalog, unique IDs, source URLs, specialty and legacy-route gating, case search, unknown-route recovery, Home navigation, small-width/double-text layout, expansion, source failures and access revocation.
- Private Flutter web build succeeded. Browser screenshots are preview evidence, not native iPhone/iPad acceptance or independent clinical signoff.
- Surgical Case Prep remains release-deferred. Production home/drawer activation and global homepage search are not enabled by this staged change.
- Reference text is bundled, but external sources still need internet. Native cold-offline entitlement and release-device acceptance remain separate tests.
- No existing clinical-review gaps in other specialties are resolved merely by adding specialty tiles.

## Review packets

- `BARIATRIC-REVIEW.md`: complete five-case drafts with per-bullet source links.
- `BURNS-REVIEW.md`: complete seven-case drafts with per-bullet source links.
- The older 243-case summary and original reconciliation register are historical baseline documents. They do not certify these replacement drafts or supersede this milestone’s scope.
