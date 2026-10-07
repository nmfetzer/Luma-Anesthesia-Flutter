# Surgical Case Prep: October Clinical Correction Batch

October 7, 2026. This batch applies evidence-supported source corrections, not independent clinical approval. Clinical-draft labels and production-release gates remain in place.

## Scope and outcome

- **19 entries updated:** Nine Obstetric, seven Orthopedic, LVAD, ECMO and the gynecology framework.
- **69 overview/detail sections changed:** Includes clinical corrections, safety additions, source-scope clarifications and explicit evidence holds.
- **351 references retained:** 350 JSON entries plus the manual laparoscopic-cholecystectomy reference. No entries added or removed.
- **331 JSON records untouched:** Original identifiers and specialty assignments remain unchanged.
- **Audit trail preserved:** Exact before/after records, SHA-256 hashes and reasons are in `correction-ledger.json`; revised sections and their citations are in `UPDATED-DRAFTS.md`.

The source baseline is merged PR #7, commit `f7cbb7e7a97a9aafcba93fbb03d0a1b5dc221bf1`. The update script reconstructs from that baseline and rejects unrecorded concurrent content edits.

## Implemented clinical changes

- **Blood patch:** Replaced technique assumptions and conflicting platelet framing with qualified PDPH, obstetric platelet and antithrombotic guidance; added atypical-headache evaluation, symptom-limited injection and follow-up. ([Multisociety PDPH guideline](https://rapm.bmj.com/content/49/7/471), [SOAP platelet consensus](https://www.soap.org/assets/docs/Consensus/SOAP%20Consensus%20Statement%20Thrombocytopenia%202021.pdf))
- **Labor epidural:** Added qualified LMWH placement/removal/restart guidance and a source-linked LAST rescue reference. ([ASRA fifth edition](https://rapm.bmj.com/content/early/2025/01/21/rapm-2024-105766), [ASRA LAST checklist](https://asra.com/docs/default-source/guidelines-articles/local-anesthetic-systemic-toxicity-rgb.pdf?sfvrsn=33b348e_2))
- **Cesarean and other OB emergencies:** Added obstetric airway rescue/extubation coverage, scoped urgency definitions and neuraxial-morphine respiratory-monitoring guidance. ([OAA/DAS](https://pmc.ncbi.nlm.nih.gov/articles/PMC4606761/), [NICE NG192](https://www.nice.org.uk/guidance/ng192/chapter/recommendations), [SOAP full monitoring statement](https://www.soap.org/assets/COE/SOAP%20Consensus%20Statement%20Neuraxial%20Opioids%202019.pdf))
- **Hemorrhage and PAS:** Updated treatment TXA timing, blood-product/fibrinogen framing, individualized anesthesia and vascular-adjunct limits; PAS delivery-timing inconsistency is explicitly held for review rather than silently resolved. ([WHO/FIGO/ICM 2025](https://iris.who.int/server/api/core/bitstreams/88bf11a5-93b6-4d6b-bdaa-856b46c8ed3c/content), [RCOG 2026](https://pmc.ncbi.nlm.nih.gov/articles/PMC13485456/))
- **Preeclampsia and ECV:** Qualified the HELLP platelet-testing interval and expanded ECV hemodynamic, fetal-concern and recovery coverage without mandating neuraxial anesthesia. ([SOAP platelet consensus](https://www.soap.org/assets/docs/Consensus/SOAP%20Consensus%20Statement%20Thrombocytopenia%202021.pdf), [ECV anesthesia review](https://pmc.ncbi.nlm.nih.gov/articles/PMC7807965/), [ECV reference](https://www.statpearls.com/point-of-care/21471))
- **Cardiac pregnancy:** Added lesion-specific distinctions, PAH-specific postpartum monitoring and uterotonic cautions; specialist approval remains required. ([ESC 2025](https://academic.oup.com/eurheartj/article/46/43/4462/8234487?login=false), [cardiac-obstetric anesthesia review](https://pubs.asahq.org/anesthesiology/article/135/1/164/115827/Obstetric-Anesthesia-and-Heart-Disease-Practical))
- **LVAD and ECMO:** Clarified the HeartMate 3 aspirin-free evidence with continued VKA and added ECMO assay/clinical-context limits, without creating universal pump or anticoagulation rules. ([ARIES-HM3](https://pubmed.ncbi.nlm.nih.gov/37950897/), [Abbott labeling announcement](https://abbott.mediaroom.com/2024-08-21-Abbott-Advances-Heart-Failure-Management-with-Aspirin-Free-Regimen-for-Patients-Receiving-the-HeartMate-3-TM-Heart-Pump), [VV-ECMO review](https://www.frontiersin.org/journals/medicine/articles/10.3389/fmed.2025.1530411/full))
- **Orthopedic safety:** Added brain-level BP interpretation, shoulder-irrigation airway reassessment, cementation preparation, lower-leg compartment surveillance and current antithrombotic coordination. ([APSF](https://www.apsf.org/article/why-worry-about-blood-pressure-during-surgery-in-the-beach-chair-position/), [shoulder systematic review](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5954585/), [cemented hemiarthroplasty guideline](https://pmc.ncbi.nlm.nih.gov/articles/PMC6681143/), [lower-leg guideline](https://ra-uk.org/media/xbwbsr5c/regional_analgesia_for_lower_leg_trauma_and_the_risk_of_acute_compartment_syndrome.pdf), [ASRA](https://rapm.bmj.com/content/early/2025/01/21/rapm-2024-105766))

## Explicitly unresolved

- **Gynecologic oncology ERAS:** The 2026 update is identified, but the publisher full text was blocked by automated-access restrictions and a browser challenge. Current content remains attributed to accessible earlier sources; an abstract is not enough to reconcile the recommendations. ([ERAS Society index](https://erassociety.org/specialty/gynaecology/))
- **PAS delivery timing:** The accessed 2026 RCOG text gives 36+1–37+0 weeks in key recommendations and 35+0–36+6 in section 10.2 for the stated lower-risk subgroup, while also describing a different ACOG window. An authoritative clarification and PAS-service review are needed before adopting a new timing instruction. ([RCOG full text](https://pmc.ncbi.nlm.nih.gov/articles/PMC13485456/))
- **Independent specialist signoff:** LVAD, ECMO and cardiac pregnancy remain open. All nine OB entries are now source-updated, not clinician-approved.
- **Historical register:** The 857 evidence notes and 409 numerical flags have not all been adjudicated. This batch does not label unchanged notes as resolved, treat every number as an error or invent universal regimens where individualization is appropriate.
- **Native acceptance:** No iPhone/iPad offline, PDF, runtime layout or clinical usability acceptance was performed in this batch. Existing App Store review was not altered.

## Technical verification

The following checks passed against this batch:

- **91 targeted Flutter tests:** Catalog, content, layout, final-specialty regression and 11 new correction checks.
- **Targeted static analysis:** No issues found.
- **Release web compilation:** `flutter build web --release --no-wasm-dry-run`, using `lib/main.dart`.
- **Preservation verification:** 243 original inventory entries accounted for, 312 earlier records/3,523 detail sections verified against current content or exact archived correction preimages, and all 19 corrected postimages matched.
- **Release boundaries:** Clinical status remains draft; Surgical Case Prep routes remain deferred. No Supabase mutation, production activation, native build, TestFlight upload or App Store submission.

The preservation check intentionally validates superseded wording in the audit archive rather than reintroducing it into the clinical reader. Technical success does not establish medical accuracy or replace clinician signoff.
