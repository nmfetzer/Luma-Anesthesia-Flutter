# Surgical Case Prep: Historical Review Reconciliation

October 7, 2026. Bariatric, Burns and Colorectal only. This is a note-by-note coverage and source-correction record, not clinical approval or release authorization.

## Scope and results

Eleven historical cases contain 128 items: 65 review notes, 33 evidence gaps and 30 numerical flags. The old combined burn procedure now maps to separate escharotomy and fasciotomy entries. Ten current records received changes; this differs from the historical-case denominator because shared bariatric and burn guidance also applies to newer records.

- **scope-boundary-retained**: 29 items.
- **covered-in-current-draft**: 41 items.
- **updated-this-pass**: 20 items.
- **partially-covered-open**: 8 items.
- **identifier-or-provenance-not-treatment-number**: 8 items.
- **verified-qualified-number**: 11 items.
- **superseded-historical-wording**: 11 items.

- Covered means current draft coverage, not clinician approval.
- Scope boundary means an unsupported universal rule was deliberately not invented.
- Updated notes may still contain scientific uncertainty; status does not imply evidence certainty.
- Original numerical flags include identifiers, years and research descriptions, not only treatment thresholds.
- Previous PR #8 corrections are separate; other historical cases have not been adjudicated by this pass.

## Questions still explicitly open

- **Roux-en-Y Gastric Bypass (RYGB) (evidenceGap 2)**: Risk guidance and scoped multimodal prevention added. Exact RYGB-specific NSAID safety and a superior fixed PONV regimen remain unresolved.
- **Sleeve Gastrectomy (evidenceGap 1)**: Recognition and surgical escalation are covered; a validated sleeve-specific intraoperative leak-rescue algorithm is not established.
- **Burn Excision and Split-Thickness Skin Grafting (evidenceGap 1)**: 2026 comparative evidence is added, but is heterogeneous and not explicitly adult-only. Adult timing certainty remains open.
- **Burn Excision and Split-Thickness Skin Grafting (evidenceGap 2)**: ABA conditional TXA, a limited-graft negative trial and cell-salvage contamination evidence are supplied. Generalizability and reinfusion safety remain unresolved.
- **Escharotomy / Fasciotomy for Burns (evidenceGap 1)**: Practical procedural guidance is supplied; adult comparative evidence for a preferred escharotomy anesthetic remains limited.
- **Abdominoperineal Resection (APR) (reviewNote 3)**: Perineal pain and wound care are covered. Phantom-rectal-pain incidence and an evidence-based specific preventive regimen remain open; routine gabapentin is not justified.
- **Abdominoperineal Resection (APR) (evidenceGap 3)**: Perineal morbidity and follow-up are present; specialist chronic/phantom pain guidance remains incomplete.
- **Low Anterior Resection (LAR) (evidenceGap 3)**: Autonomic/bladder consequences are present; detailed ureteric-injury recognition and management remain a specialist evidence gap.

Existing separate holds remain: PAS guideline timing discrepancy, gynecologic-oncology 2026 full-text reconciliation, and specialist LVAD/ECMO/cardiac-pregnancy review. Native layout/PDF/offline acceptance and release authorization are separate. Other specialties’ historical notes remain outside this pass.

## Bariatric: Roux-en-Y Gastric Bypass (RYGB)

### reviewNote 1: scope-boundary-retained

Historical note (archived, not current instructions):

> The RYGB surgical review supplies operative anatomy and complication information but explicitly is not an anesthesia reference; anesthesia statements here rely mainly on broader bariatric guidance and general anesthesia standards.

Surgical anatomy is distinguished from general bariatric anesthesia guidance; no RYGB-only protocol is claimed. ([ASMBS: bariatric procedure anatomy and differences](https://asmbs.org/patients/bariatric-surgery-procedures/); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/); [StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/); [ASMBS 2026 report: 2024 MBSAQIP-based procedure distribution](https://asmbs.org/news_releases/bariatric-surgery-procedures-fall-below-200000-first-time-since-2020-new-research-finds/); [SOBA 2025: airway management in patients living with obesity](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/); [ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [DailyMed: BRIDION US prescribing information, March 2026](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5171d883-fe8f-482c-97ab-40b00975b64a); [BJA 2010: drug-specific dose adjustment in obesity](https://academic.oup.com/bja/article/105/suppl_1/i16/236249?guestAccessKey=); [BMJ Case Reports: aspiration after gastric banding, 2013](https://pmc.ncbi.nlm.nih.gov/articles/PMC3794288/); [Reflex bradycardia during surgery: historical review](https://link.springer.com/content/pdf/10.1007/BF03005473.pdf))

Current coverage: `roux-en-y-gastric-bypass-rygb / procedure`, `roux-en-y-gastric-bypass-rygb / evidence`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 2: scope-boundary-retained

Historical note (archived, not current instructions):

> The ERAS guideline reports limited or low-quality evidence for several bariatric interventions. Its broad recommendations should not be mistaken for an RYGB-specific protocol.

ERAS recommendations are scoped to bariatric surgery and uncertainty is preserved. ([SOBA 2025: airway management in patients living with obesity](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/); [ERAS bariatric recommendations: 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [DailyMed: BRIDION US prescribing information, March 2026](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5171d883-fe8f-482c-97ab-40b00975b64a); [BJA 2010: drug-specific dose adjustment in obesity](https://academic.oup.com/bja/article/105/suppl_1/i16/236249?guestAccessKey=); [BMJ Case Reports: aspiration after gastric banding, 2013](https://pmc.ncbi.nlm.nih.gov/articles/PMC3794288/); [ASMBS 2026 report: 2024 MBSAQIP-based procedure distribution](https://asmbs.org/news_releases/bariatric-surgery-procedures-fall-below-200000-first-time-since-2020-new-research-finds/); [Reflex bradycardia during surgery: historical review](https://link.springer.com/content/pdf/10.1007/BF03005473.pdf); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/); [ASMBS: bariatric procedure anatomy and differences](https://asmbs.org/patients/bariatric-surgery-procedures/); [StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/))

Current coverage: `roux-en-y-gastric-bypass-rygb / evidence`, `roux-en-y-gastric-bypass-rygb / ponv-plan`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 3: covered-in-current-draft

Historical note (archived, not current instructions):

> Fluid statements have an important tension: the guideline favors individualized goal-directed therapy and cautions against both hypovolemia and hypervolemia, while also reporting possible harm from restrictive administration. No fixed volume is justified.

Individualized fluid management replaces a fixed restrictive volume. ([ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [Circulation: cardiovascular and ventilatory consequences of laparoscopy](https://www.ahajournals.org/doi/10.1161/circulationaha.116.023262); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/))

Current coverage: `roux-en-y-gastric-bypass-rygb / fluids`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 4: updated-this-pass

Historical note (archived, not current instructions):

> RYGB-specific NSAID safety is unresolved in the supplied material. The surgical source reports marginal ulcer prevalence, while ERAS describes opioid reduction with NSAIDs across bariatric surgery; neither establishes a universal RYGB NSAID rule.

ASMBS identifies NSAID-related marginal-ulcer risk and qualified PPI prophylaxis. A universally safe NSAID exposure remains unestablished. ([ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/); [StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/); [ASMBS: bariatric procedure anatomy and differences](https://asmbs.org/patients/bariatric-surgery-procedures/); [ASMBS marginal-ulcer risk and prophylaxis review (2024)](https://asmbs.org/wp-content/uploads/2024/11/American-Society-for-Metabolic-and-Bariatric-Surgery-literature-review-on-risk-factors-screening-recommendations-and-prophylaxis-for-marginal-ulcers-after-metabolic-and-bariatric-surgery.pdf))

Current coverage: `roux-en-y-gastric-bypass-rygb / analgesia`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 5: covered-in-current-draft

Historical note (archived, not current instructions):

> The operative source describes leak-test methods and defect closure but does not establish that a particular leak test or anesthetic response is mandatory.

Tube passage and leak testing are coordinated with the surgeon, not mandatory for every case. ([StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/); [ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/); [SOBA 2025: airway management in patients living with obesity](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/); [DailyMed: BRIDION US prescribing information, March 2026](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5171d883-fe8f-482c-97ab-40b00975b64a); [Circulation: cardiovascular and ventilatory consequences of laparoscopy](https://www.ahajournals.org/doi/10.1161/circulationaha.116.023262))

Current coverage: `roux-en-y-gastric-bypass-rygb / tubes`, `roux-en-y-gastric-bypass-rygb / intraop`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 6: updated-this-pass

Historical note (archived, not current instructions):

> The NMB recommendations apply only when neuromuscular blockers are used. TOF recovery guidance should not be generalized to cases without NMB.

Explicit quantitative adductor-pollicis TOF recovery is conditional on neuromuscular blocker use. ([SOBA 2025: airway management in patients living with obesity](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/); [ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [APSF summary of ASA neuromuscular blockade guidelines (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/))

Current coverage: `roux-en-y-gastric-bypass-rygb / emergence`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 7: scope-boundary-retained

Historical note (archived, not current instructions):

> Source 1 describes surgical leak-test methods but states that it does not specify airway management technique or monitoring beyond its examples; it does not establish an anesthesia-specific leak-test protocol.

No unsupported anesthesia-specific leak-test recipe has been added. ([StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/); [ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/); [SOBA 2025: airway management in patients living with obesity](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/); [DailyMed: BRIDION US prescribing information, March 2026](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5171d883-fe8f-482c-97ab-40b00975b64a); [Circulation: cardiovascular and ventilatory consequences of laparoscopy](https://www.ahajournals.org/doi/10.1161/circulationaha.116.023262))

Current coverage: `roux-en-y-gastric-bypass-rygb / tubes`, `roux-en-y-gastric-bypass-rygb / intraop`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 1: scope-boundary-retained

Historical note (archived, not current instructions):

> The supplied sources do not establish an RYGB-specific anesthetic protocol for airway technique, hemodynamic management, or intraoperative targets.

Patient-specific airway and perfusion guidance is supplied, not a claim of uniquely validated RYGB targets. ([SOBA 2025: airway management in patients living with obesity](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/); [StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/); [Circulation: cardiovascular and ventilatory consequences of laparoscopy](https://www.ahajournals.org/doi/10.1161/circulationaha.116.023262); [ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9))

Current coverage: `roux-en-y-gastric-bypass-rygb / airway`, `roux-en-y-gastric-bypass-rygb / hemodynamics`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 2: partially-covered-open

Historical note (archived, not current instructions):

> The supplied sources do not resolve RYGB-specific NSAID safety or provide a procedure-specific analgesia and PONV regimen.

Risk guidance and scoped multimodal prevention added. Exact RYGB-specific NSAID safety and a superior fixed PONV regimen remain unresolved. ([ERAS bariatric recommendations: 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/); [StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/); [ASMBS: bariatric procedure anatomy and differences](https://asmbs.org/patients/bariatric-surgery-procedures/); [ASMBS marginal-ulcer risk and prophylaxis review (2024)](https://asmbs.org/wp-content/uploads/2024/11/American-Society-for-Metabolic-and-Bariatric-Surgery-literature-review-on-risk-factors-screening-recommendations-and-prophylaxis-for-marginal-ulcers-after-metabolic-and-bariatric-surgery.pdf))

Current coverage: `roux-en-y-gastric-bypass-rygb / analgesia`, `roux-en-y-gastric-bypass-rygb / ponv-plan`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 1: identifier-or-provenance-not-treatment-number

Historical note (archived, not current instructions):

> Review nutritional status and relevant laboratory assessment; the RYGB review specifically identifies iron, vitamin B12, and folate deficiencies for evaluation.

B12 is a vitamin name, not a dosing threshold. ([SOBA 2025: airway management in patients living with obesity](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/); [StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/); [ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [ASA-led multisociety GLP-1 guidance](https://www.asahq.org/about-asa/newsroom/news-releases/2024/10/new-multi-society-glp-1-guidance); [BMJ Case Reports: aspiration after gastric banding, 2013](https://pmc.ncbi.nlm.nih.gov/articles/PMC3794288/); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/))

Current coverage: `roux-en-y-gastric-bypass-rygb / preop`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 2: identifier-or-provenance-not-treatment-number

Historical note (archived, not current instructions):

> Review medications for possible altered absorption after RYGB. Assess GLP-1/GIP therapy individually, considering gastrointestinal symptoms because these agents may delay gastric emptying.

GLP-1 identifies a drug pathway, not a dose or withholding interval. ([ASA-led multisociety GLP-1 guidance](https://www.asahq.org/about-asa/newsroom/news-releases/2024/10/new-multi-society-glp-1-guidance); [StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/); [BMJ Case Reports: aspiration after gastric banding, 2013](https://pmc.ncbi.nlm.nih.gov/articles/PMC3794288/))

Current coverage: `roux-en-y-gastric-bypass-rygb / glp1`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 3: verified-qualified-number

Historical note (archived, not current instructions):

> For bariatric surgery, use lung-protective tidal volumes of 6–8 mL/kg predicted body weight (PBW). Optimal PEEP and the role of recruitment maneuvers remain uncertain.

ERAS supports 6–8 mL/kg predicted body weight. This is not actual-weight dosing or a universal PEEP target. ([SOBA 2025: airway management in patients living with obesity](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/); [StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/); [Circulation: cardiovascular and ventilatory consequences of laparoscopy](https://www.ahajournals.org/doi/10.1161/circulationaha.116.023262); [ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/))

Current coverage: `roux-en-y-gastric-bypass-rygb / pulmonary`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 4: verified-qualified-number

Historical note (archived, not current instructions):

> When neuromuscular blockers have been administered, use quantitative monitoring and confirm TOF ratio at least 0.9 before extubation. The site recommendation is adductor pollicis, not eye muscles.

ASA quantitative TOF threshold is at least 0.9 at the adductor pollicis when a blocker was used. ([SOBA 2025: airway management in patients living with obesity](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/); [ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [APSF summary of ASA neuromuscular blockade guidelines (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/))

Current coverage: `roux-en-y-gastric-bypass-rygb / emergence`. Exact current bullets and section hashes are preserved in the JSON companion.

## Bariatric: Sleeve Gastrectomy

### reviewNote 1: covered-in-current-draft

Historical note (archived, not current instructions):

> The Base44 material is unverified and was not treated as evidence. Its fixed fluid total, mandatory RSI, universal videolaryngoscopy-first claim, specific drug regimens, and claims that sugammadex guarantees complete reversal were not carried forward as standards.

Unsupported fixed volumes, automatic RSI and reversal guarantees are absent. Current first-line videolaryngoscopy guidance is separately sourced to SOBA 2025; this does not restore the old never-direct-laryngoscopy claim. ([SOBA 2025: airway management in patients living with obesity](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/); [StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/); [ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [Circulation: cardiovascular and ventilatory consequences of laparoscopy](https://www.ahajournals.org/doi/10.1161/circulationaha.116.023262); [BJA 2010: drug-specific dose adjustment in obesity](https://academic.oup.com/bja/article/105/suppl_1/i16/236249?guestAccessKey=); [DailyMed: BRIDION US prescribing information, March 2026](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5171d883-fe8f-482c-97ab-40b00975b64a); [APSF summary of ASA neuromuscular blockade guidelines (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/))

Current coverage: `sleeve-gastrectomy / airway`, `sleeve-gastrectomy / fluids`, `sleeve-gastrectomy / scalars`, `sleeve-gastrectomy / emergence`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 2: scope-boundary-retained

Historical note (archived, not current instructions):

> The BMI eligibility statement in the Base44 fields reflects older thresholds. The supplied StatPearls review describes 2022 ASMBS/IFSO guidance supporting consideration of metabolic and bariatric surgery at BMI 35 kg/m² or more regardless of comorbidity, with selected lower-BMI cases also considered; this is not an individual eligibility determination.

No outdated BMI threshold is used to determine individual surgical eligibility. ([SOBA 2025: airway management in patients living with obesity](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/); [StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/); [ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [ASA-led multisociety GLP-1 guidance](https://www.asahq.org/about-asa/newsroom/news-releases/2024/10/new-multi-society-glp-1-guidance); [BMJ Case Reports: aspiration after gastric banding, 2013](https://pmc.ncbi.nlm.nih.gov/articles/PMC3794288/); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/))

Current coverage: `sleeve-gastrectomy / preop`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 3: covered-in-current-draft

Historical note (archived, not current instructions):

> The ERAS guideline favors individualized goal-directed fluid therapy and reports risks associated with both hypovolemia and hypervolemia; this does not support a universal restrictive fluid total.

Euvolemia and individualized therapy replace a universal restrictive total. ([ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [Circulation: cardiovascular and ventilatory consequences of laparoscopy](https://www.ahajournals.org/doi/10.1161/circulationaha.116.023262); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/))

Current coverage: `sleeve-gastrectomy / fluids`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 4: updated-this-pass

Historical note (archived, not current instructions):

> Neuromuscular monitoring and TOF thresholds apply when neuromuscular blocking drugs are used. They do not impose paralysis or quantitative TOF monitoring on every anesthetic approach.

Conditional quantitative TOF recovery is explicit; paralysis is not mandated. ([SOBA 2025: airway management in patients living with obesity](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/); [ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [APSF summary of ASA neuromuscular blockade guidelines (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/))

Current coverage: `sleeve-gastrectomy / emergence`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 5: scope-boundary-retained

Historical note (archived, not current instructions):

> The case report of sleeve gastrectomy under spinal anesthesia is a single case and does not establish routine regional anesthesia. Its reported patient outcome does not establish general safety.

A single spinal-anesthetic case report is not used as a routine-practice recommendation. ([SOBA 2025: airway management in patients living with obesity](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/); [StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/); [ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [DailyMed: BRIDION US prescribing information, March 2026](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5171d883-fe8f-482c-97ab-40b00975b64a); [BJA 2010: drug-specific dose adjustment in obesity](https://academic.oup.com/bja/article/105/suppl_1/i16/236249?guestAccessKey=); [BMJ Case Reports: aspiration after gastric banding, 2013](https://pmc.ncbi.nlm.nih.gov/articles/PMC3794288/); [ASMBS 2026 report: 2024 MBSAQIP-based procedure distribution](https://asmbs.org/news_releases/bariatric-surgery-procedures-fall-below-200000-first-time-since-2020-new-research-finds/); [Reflex bradycardia during surgery: historical review](https://link.springer.com/content/pdf/10.1007/BF03005473.pdf))

Current coverage: `sleeve-gastrectomy / airway`, `sleeve-gastrectomy / evidence`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 6: covered-in-current-draft

Historical note (archived, not current instructions):

> The provided sources do not establish routine arterial-line use, mandatory crossmatch, a universal DVT-prophylaxis regimen, fixed PONV prophylaxis, or a universal extubation-support protocol.

Monitoring, VTE, PONV and respiratory support are individualized rather than supplied as a universal regimen. ([StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/); [Circulation: cardiovascular and ventilatory consequences of laparoscopy](https://www.ahajournals.org/doi/10.1161/circulationaha.116.023262); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/); [ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [ASMBS: bariatric procedure anatomy and differences](https://asmbs.org/patients/bariatric-surgery-procedures/); [SOBA 2025: airway management in patients living with obesity](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/); [APSF summary of ASA neuromuscular blockade guidelines (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/))

Current coverage: `sleeve-gastrectomy / hemodynamics`, `sleeve-gastrectomy / complications`, `sleeve-gastrectomy / ponv-plan`, `sleeve-gastrectomy / emergence`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 1: partially-covered-open

Historical note (archived, not current instructions):

> The available sources do not provide a validated sleeve-specific intraoperative recognition and response pathway for suspected staple-line leak or other acute surgical complication.

Recognition and surgical escalation are covered; a validated sleeve-specific intraoperative leak-rescue algorithm is not established. ([StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/); [ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/); [SOBA 2025: airway management in patients living with obesity](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/); [DailyMed: BRIDION US prescribing information, March 2026](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5171d883-fe8f-482c-97ab-40b00975b64a); [Circulation: cardiovascular and ventilatory consequences of laparoscopy](https://www.ahajournals.org/doi/10.1161/circulationaha.116.023262); [ASMBS: bariatric procedure anatomy and differences](https://asmbs.org/patients/bariatric-surgery-procedures/))

Current coverage: `sleeve-gastrectomy / tubes`, `sleeve-gastrectomy / intraop`, `sleeve-gastrectomy / complications`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 2: updated-this-pass

Historical note (archived, not current instructions):

> The available sources do not establish a sleeve-specific PONV prophylaxis protocol or comparative regimen.

Bariatric multimodal prevention and reassessment are added with an explicit statement that no uniquely effective sleeve regimen is established. ([ERAS bariatric recommendations: 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/); [ASMBS: bariatric procedure anatomy and differences](https://asmbs.org/patients/bariatric-surgery-procedures/); [StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/))

Current coverage: `sleeve-gastrectomy / ponv-plan`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 1: identifier-or-provenance-not-treatment-number

Historical note (archived, not current instructions):

> Review medication effects and comorbidities, including weight-loss therapies that may delay gastric emptying, and plan individually for aspiration risk. The source describes individualized assessment rather than routine discontinuation of GLP-1 or dual GIP/GLP-1 therapies.

GLP-1 is not a medication dose. ([ASA-led multisociety GLP-1 guidance](https://www.asahq.org/about-asa/newsroom/news-releases/2024/10/new-multi-society-glp-1-guidance); [StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/); [BMJ Case Reports: aspiration after gastric banding, 2013](https://pmc.ncbi.nlm.nih.gov/articles/PMC3794288/))

Current coverage: `sleeve-gastrectomy / glp1`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 2: superseded-historical-wording

Historical note (archived, not current instructions):

> Optimize preoxygenation; a tight-fitting mask with 100% oxygen is standard, and HFNC may be an adjunct. Have video laryngoscopy and advanced airway devices available. Consider rapid-sequence or modified rapid-sequence induction when aspiration risk is significant.

Historical fixed 100% preoxygenation wording is replaced by current obesity-airway planning; no guarantee of safe apnea is implied. ([SOBA 2025: airway management in patients living with obesity](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/); [StatPearls: anesthetic considerations in bariatric surgery](https://www.ncbi.nlm.nih.gov/books/NBK603748/); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/))

Current coverage: `sleeve-gastrectomy / airway`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 3: verified-qualified-number

Historical note (archived, not current instructions):

> Residual neuromuscular blockade is associated with upper-airway obstruction, reintubation, atelectasis, pneumonia, and prolonged PACU stay. Quantitative TOF assessment at the adductor pollicis is recommended when monitoring blockade; confirm TOF ratio at least 0.9 before extubation.

Conditional TOF at least 0.9 is explicit and source-linked. ([SOBA 2025: airway management in patients living with obesity](https://pmc.ncbi.nlm.nih.gov/articles/PMC12351209/); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/); [ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [APSF summary of ASA neuromuscular blockade guidelines (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/))

Current coverage: `sleeve-gastrectomy / emergence`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 4: identifier-or-provenance-not-treatment-number

Historical note (archived, not current instructions):

> The ERAS guideline reports associations between both hypervolemia and hypovolemia and worse outcomes. Balanced crystalloids are supported over 0.9% saline; bariatric-specific evidence comparing crystalloids and colloids is sparse.

0.9% saline denotes a fluid concentration, not a prescribed volume or fixed resuscitation target. ([ERAS Society: bariatric perioperative care, 2021 update](https://link.springer.com/article/10.1007/s00268-021-06394-9); [Circulation: cardiovascular and ventilatory consequences of laparoscopy](https://www.ahajournals.org/doi/10.1161/circulationaha.116.023262); [BJA Education 2022: anaesthesia for bariatric surgery](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9125419/))

Current coverage: `sleeve-gastrectomy / fluids`. Exact current bullets and section hashes are preserved in the JSON companion.

## Burns: Burn Excision and Split-Thickness Skin Grafting

### reviewNote 1: updated-this-pass

Historical note (archived, not current instructions):

> The supplied acute-burn source is a narrative review with no systematic-review methods or evidence grading. Treat its descriptions of reported practice and expert recommendations accordingly.

The older narrative source is supplemented by the 2025 ABA guideline; its other descriptions are not retrospectively upgraded to graded evidence. ([ABA 2024: burn shock resuscitation guideline](https://pubmed.ncbi.nlm.nih.gov/38051821/); [BJA Education 2022: major burns, anesthesia, ICU and pain](https://pmc.ncbi.nlm.nih.gov/articles/PMC9073309/); [ABA 2020: adult burn pain management guideline](https://pmc.ncbi.nlm.nih.gov/articles/PMC7703676/); [Management of burns and anesthetic implications](https://pmc.ncbi.nlm.nih.gov/articles/PMC7121311/); [Anesthesiology: acute and perioperative care of burn injury](https://pmc.ncbi.nlm.nih.gov/articles/PMC4844008/); [ABA blood-product transfusion guideline (2025 full text)](https://doi.org/10.1093/jbcr/iraf021); [Tranburn randomized trial (2025)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12755343/); [Cell salvage in contaminated fields: scoping review (2026)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12768276/); [Burn excision timing: systematic review (2026; not adult-only)](https://pmc.ncbi.nlm.nih.gov/articles/PMC13309668/))

Current coverage: `burn-excision-and-split-thickness-skin-grafting / evidence`, `burn-excision-and-split-thickness-skin-grafting / blood-guideline`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 2: updated-this-pass

Historical note (archived, not current instructions):

> The Base44 claims that excision within 72 hours reduces mortality, that one unit of blood is lost per 1% TBSA excised, that an arterial line is mandatory, and that ketamine is the ideal anesthetic are not established by the supplied evidence.

No 72-hour mortality guarantee, unit-per-percent blood-loss calculator, mandatory arterial line or ideal anesthetic is used. Timing uncertainty is explicit. ([Burn excision timing: systematic review (2026; not adult-only)](https://pmc.ncbi.nlm.nih.gov/articles/PMC13309668/); [Anesthesiology: acute and perioperative care of burn injury](https://pmc.ncbi.nlm.nih.gov/articles/PMC4844008/); [BJA Education 2022: major burns, anesthesia, ICU and pain](https://pmc.ncbi.nlm.nih.gov/articles/PMC9073309/); [CDC: clinical guidance for carbon monoxide poisoning](https://www.cdc.gov/carbon-monoxide/hcp/clinical-guidance/index.html); [ABA 2020: adult burn pain management guideline](https://pmc.ncbi.nlm.nih.gov/articles/PMC7703676/))

Current coverage: `burn-excision-and-split-thickness-skin-grafting / timing-evidence`, `burn-excision-and-split-thickness-skin-grafting / blood`, `burn-excision-and-split-thickness-skin-grafting / access`, `burn-excision-and-split-thickness-skin-grafting / drugs`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 3: covered-in-current-draft

Historical note (archived, not current instructions):

> The source-supported blood-loss estimate differs from the Base44 figure and is itself an estimate from a review; it is not presented here as a reliable case-level prediction.

Blood loss is assessed for the actual excision and patient; narrative estimates are not a transfusion calculator. ([Anesthesiology: acute and perioperative care of burn injury](https://pmc.ncbi.nlm.nih.gov/articles/PMC4844008/); [BJA Education 2022: major burns, anesthesia, ICU and pain](https://pmc.ncbi.nlm.nih.gov/articles/PMC9073309/))

Current coverage: `burn-excision-and-split-thickness-skin-grafting / blood`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 4: updated-this-pass

Historical note (archived, not current instructions):

> The Base44 fixed hemoglobin goal, mandatory CVP/central access, routine TXA or cell saver, fixed warm-room setpoint, and specified drug infusion recipes are not established as universal procedure requirements by these sources.

Qualified adult transfusion and conditional TXA evidence replace an evidence gap, not a universal hemoglobin/CVP/drug/warming recipe. ([ABA blood-product transfusion guideline (2025 full text)](https://doi.org/10.1093/jbcr/iraf021); [Tranburn randomized trial (2025)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12755343/); [Cell salvage in contaminated fields: scoping review (2026)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12768276/); [Anesthesiology: acute and perioperative care of burn injury](https://pmc.ncbi.nlm.nih.gov/articles/PMC4844008/); [BJA Education 2022: major burns, anesthesia, ICU and pain](https://pmc.ncbi.nlm.nih.gov/articles/PMC9073309/))

Current coverage: `burn-excision-and-split-thickness-skin-grafting / blood-guideline`, `burn-excision-and-split-thickness-skin-grafting / blood-conservation-evidence`, `burn-excision-and-split-thickness-skin-grafting / temperature`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 5: covered-in-current-draft

Historical note (archived, not current instructions):

> The source describes succinylcholine-associated hyperkalemia risk beginning 48 hours after burn injury. This draft retains the hazard as a source-supported consideration without framing it as a universal drug rule for every patient or burn phase.

The current conservative burn succinylcholine warning is retained; an apparently safe 24–48-hour interval is not inferred from older wording. ([Management of burns and anesthetic implications](https://pmc.ncbi.nlm.nih.gov/articles/PMC7121311/); [Anesthesiology: acute and perioperative care of burn injury](https://pmc.ncbi.nlm.nih.gov/articles/PMC4844008/); [BJA Education 2022: major burns, anesthesia, ICU and pain](https://pmc.ncbi.nlm.nih.gov/articles/PMC9073309/))

Current coverage: `burn-excision-and-split-thickness-skin-grafting / blockade`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 6: scope-boundary-retained

Historical note (archived, not current instructions):

> The supplied material does not support a universal extubation destination, blood-product order, fluid total, or anesthetic regimen; these require individualized clinical judgment.

Resuscitation and extubation remain physiology-based rather than a universal operative regimen. ([ABA 2024: burn shock resuscitation guideline](https://pubmed.ncbi.nlm.nih.gov/38051821/); [Anesthesiology: acute and perioperative care of burn injury](https://pmc.ncbi.nlm.nih.gov/articles/PMC4844008/); [ABA burn shock resuscitation: full guideline](https://achpccg.com/wp-content/uploads/2024/02/Cartotto-et-al_2023_American-Burn-Association-CLinical-Practice-Guidelines-on-Burn-Shock-Resuscitation.pdf); [AAFP 2025: interpretation of ABA burn resuscitation guidance](https://www.aafp.org/afp/2025/0800/practice-guidelines-resuscitation-patients-burns); [Electrical injuries: historical burn-center review](https://academic.oup.com/jbcr/article/25/6/479/4733820); [BJA Education 2022: major burns, anesthesia, ICU and pain](https://pmc.ncbi.nlm.nih.gov/articles/PMC9073309/); [ABA 2020: adult burn pain management guideline](https://pmc.ncbi.nlm.nih.gov/articles/PMC7703676/))

Current coverage: `burn-excision-and-split-thickness-skin-grafting / fluids`, `burn-excision-and-split-thickness-skin-grafting / emergence`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 1: partially-covered-open

Historical note (archived, not current instructions):

> Contemporary adult, procedure-specific evidence comparing excision timing and operative approaches for patient-centered outcomes.

2026 comparative evidence is added, but is heterogeneous and not explicitly adult-only. Adult timing certainty remains open. ([Burn excision timing: systematic review (2026; not adult-only)](https://pmc.ncbi.nlm.nih.gov/articles/PMC13309668/))

Current coverage: `burn-excision-and-split-thickness-skin-grafting / timing-evidence`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 2: partially-covered-open

Historical note (archived, not current instructions):

> Comparative adult evidence for blood-conservation methods, including the effectiveness of TXA or cell salvage in this procedure.

ABA conditional TXA, a limited-graft negative trial and cell-salvage contamination evidence are supplied. Generalizability and reinfusion safety remain unresolved. ([ABA blood-product transfusion guideline (2025 full text)](https://doi.org/10.1093/jbcr/iraf021); [Tranburn randomized trial (2025)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12755343/); [Cell salvage in contaminated fields: scoping review (2026)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12768276/))

Current coverage: `burn-excision-and-split-thickness-skin-grafting / blood-conservation-evidence`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 3: updated-this-pass

Historical note (archived, not current instructions):

> A validated procedure-specific transfusion strategy or threshold for adult burn excision.

The 2025 adult major-burn RBC recommendation and active hemorrhage, acute brain injury and ACS qualifications are now explicit. ([ABA blood-product transfusion guideline (2025 full text)](https://doi.org/10.1093/jbcr/iraf021))

Current coverage: `burn-excision-and-split-thickness-skin-grafting / blood-guideline`. Exact current bullets and section hashes are preserved in the JSON companion.

## Burns: Escharotomy / Fasciotomy for Burns

### reviewNote 1: updated-this-pass

Historical note (archived, not current instructions):

> Base44 is unverified and was not treated as a source. The supplied procedure source supports local anesthetic infiltration of unburnt skin and optional sedation, but not the listed ketamine, propofol, fentanyl, or midazolam doses, ketamine infusion, or drug-specific plan.

Escharotomy now explicitly covers local anesthetic for unburnt extensions and selected sedation; this is not automatically the anesthetic plan for deep fasciotomy. ([StatPearls: escharotomy and reassessment](https://www.ncbi.nlm.nih.gov/sites/books/NBK482120/); [Anesthesiology: acute and perioperative care of burn injury](https://pmc.ncbi.nlm.nih.gov/articles/PMC4844008/); [ABA 2020: adult burn pain management guideline](https://pmc.ncbi.nlm.nih.gov/articles/PMC7703676/); [BJA Education 2022: major burns, anesthesia, ICU and pain](https://pmc.ncbi.nlm.nih.gov/articles/PMC9073309/); [Electrical injuries: historical burn-center review](https://academic.oup.com/jbcr/article/25/6/479/4733820))

Current coverage: `burn-escharotomy / procedure`, `burn-escharotomy / pain`, `burn-fasciotomy / procedure`, `burn-fasciotomy / pain`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 2: updated-this-pass

Historical note (archived, not current instructions):

> The claimed immediate peak-airway-pressure reduction of 10–20 cmH2O is not supported by the supplied sources. Chest release is intended to allow ventilation; response must be assessed rather than promised.

Repeat perfusion/respiratory assessment replaces a guaranteed 10–20 cm H2O response. ([StatPearls: escharotomy and reassessment](https://www.ncbi.nlm.nih.gov/sites/books/NBK482120/); [Anesthesiology: acute and perioperative care of burn injury](https://pmc.ncbi.nlm.nih.gov/articles/PMC4844008/); [BJA Education 2022: major burns, anesthesia, ICU and pain](https://pmc.ncbi.nlm.nih.gov/articles/PMC9073309/); [Management of burns and anesthetic implications](https://pmc.ncbi.nlm.nih.gov/articles/PMC7121311/); [Electrical injuries: historical burn-center review](https://academic.oup.com/jbcr/article/25/6/479/4733820))

Current coverage: `burn-escharotomy / procedure`, `burn-escharotomy / airway`, `burn-fasciotomy / procedure`, `burn-fasciotomy / airway`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 3: updated-this-pass

Historical note (archived, not current instructions):

> The claim that full-thickness eschar is insensate and therefore requires only sedation is not established in the supplied sources. The source specifically notes local anesthetic for unburnt skin into which the incision extends.

Do not equate eschar with an entirely painless procedure or omit analgesia for viable tissue. ([StatPearls: escharotomy and reassessment](https://www.ncbi.nlm.nih.gov/sites/books/NBK482120/); [Anesthesiology: acute and perioperative care of burn injury](https://pmc.ncbi.nlm.nih.gov/articles/PMC4844008/); [ABA 2020: adult burn pain management guideline](https://pmc.ncbi.nlm.nih.gov/articles/PMC7703676/); [BJA Education 2022: major burns, anesthesia, ICU and pain](https://pmc.ncbi.nlm.nih.gov/articles/PMC9073309/); [Electrical injuries: historical burn-center review](https://academic.oup.com/jbcr/article/25/6/479/4733820))

Current coverage: `burn-escharotomy / procedure`, `burn-escharotomy / pain`, `burn-fasciotomy / procedure`, `burn-fasciotomy / pain`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 4: covered-in-current-draft

Historical note (archived, not current instructions):

> The source supports usual timing within the first 48 hours after injury, but not a fixed 24–48-hour rule or timing independent of clinical assessment.

Release follows clinical compromise and urgent assessment, not a fixed 24–48-hour clock. ([StatPearls: escharotomy and reassessment](https://www.ncbi.nlm.nih.gov/sites/books/NBK482120/); [Anesthesiology: acute and perioperative care of burn injury](https://pmc.ncbi.nlm.nih.gov/articles/PMC4844008/); [Electrical injuries: historical burn-center review](https://academic.oup.com/jbcr/article/25/6/479/4733820))

Current coverage: `burn-escharotomy / procedure`, `burn-fasciotomy / procedure`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 5: covered-in-current-draft

Historical note (archived, not current instructions):

> The source supports bleeding as a possible complication, but not the Base44 assertion that no additional major blood loss is expected.

Hemorrhage readiness is individualized; no bloodless-procedure assurance is used. ([Anesthesiology: acute and perioperative care of burn injury](https://pmc.ncbi.nlm.nih.gov/articles/PMC4844008/); [BJA Education 2022: major burns, anesthesia, ICU and pain](https://pmc.ncbi.nlm.nih.gov/articles/PMC9073309/))

Current coverage: `burn-escharotomy / blood`, `burn-fasciotomy / blood`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 6: covered-in-current-draft

Historical note (archived, not current instructions):

> The supplied evidence does not justify treating loss of a distal Doppler signal as the sole indication, using a universal airway plan, or assuming a specific post-release ventilator response.

Absent pulse is not the only indication; airway and deep-compartment problems require independent assessment. ([StatPearls: escharotomy and reassessment](https://www.ncbi.nlm.nih.gov/sites/books/NBK482120/); [Anesthesiology: acute and perioperative care of burn injury](https://pmc.ncbi.nlm.nih.gov/articles/PMC4844008/); [BJA Education 2022: major burns, anesthesia, ICU and pain](https://pmc.ncbi.nlm.nih.gov/articles/PMC9073309/); [Management of burns and anesthetic implications](https://pmc.ncbi.nlm.nih.gov/articles/PMC7121311/); [Electrical injuries: historical burn-center review](https://academic.oup.com/jbcr/article/25/6/479/4733820))

Current coverage: `burn-escharotomy / procedure`, `burn-escharotomy / airway`, `burn-fasciotomy / procedure`, `burn-fasciotomy / airway`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 1: partially-covered-open

Historical note (archived, not current instructions):

> Adult-specific anesthetic evidence for escharotomy, including comparative evidence for local anesthesia alone versus sedation or general anesthesia.

Practical procedural guidance is supplied; adult comparative evidence for a preferred escharotomy anesthetic remains limited. ([StatPearls: escharotomy and reassessment](https://www.ncbi.nlm.nih.gov/sites/books/NBK482120/); [Anesthesiology: acute and perioperative care of burn injury](https://pmc.ncbi.nlm.nih.gov/articles/PMC4844008/); [ABA 2020: adult burn pain management guideline](https://pmc.ncbi.nlm.nih.gov/articles/PMC7703676/); [BJA Education 2022: major burns, anesthesia, ICU and pain](https://pmc.ncbi.nlm.nih.gov/articles/PMC9073309/); [Electrical injuries: historical burn-center review](https://academic.oup.com/jbcr/article/25/6/479/4733820))

Current coverage: `burn-escharotomy / procedure`, `burn-escharotomy / pain`, `burn-fasciotomy / procedure`, `burn-fasciotomy / pain`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 2: covered-in-current-draft

Historical note (archived, not current instructions):

> Procedure-specific adult guidance for airway management when chest-wall release is undertaken in a patient with respiratory compromise.

Respiratory compromise, airway planning and postrelease reassessment are covered without a guaranteed mechanical response. ([Anesthesiology: acute and perioperative care of burn injury](https://pmc.ncbi.nlm.nih.gov/articles/PMC4844008/); [BJA Education 2022: major burns, anesthesia, ICU and pain](https://pmc.ncbi.nlm.nih.gov/articles/PMC9073309/); [Management of burns and anesthetic implications](https://pmc.ncbi.nlm.nih.gov/articles/PMC7121311/); [StatPearls: escharotomy and reassessment](https://www.ncbi.nlm.nih.gov/sites/books/NBK482120/); [Electrical injuries: historical burn-center review](https://academic.oup.com/jbcr/article/25/6/479/4733820))

Current coverage: `burn-escharotomy / airway`, `burn-escharotomy / procedure`, `burn-fasciotomy / airway`, `burn-fasciotomy / procedure`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 3: scope-boundary-retained

Historical note (archived, not current instructions):

> Escharotomy-specific analgesia and PONV recommendations; the supplied sources do not establish a systemic regimen.

General burn analgesia and individualized recovery are supplied, not an escharotomy-specific fixed analgesic/PONV regimen. ([ABA 2020: adult burn pain management guideline](https://pmc.ncbi.nlm.nih.gov/articles/PMC7703676/); [BJA Education 2022: major burns, anesthesia, ICU and pain](https://pmc.ncbi.nlm.nih.gov/articles/PMC9073309/); [Anesthesiology: acute and perioperative care of burn injury](https://pmc.ncbi.nlm.nih.gov/articles/PMC4844008/))

Current coverage: `burn-escharotomy / pain`, `burn-escharotomy / emergence`, `burn-fasciotomy / pain`, `burn-fasciotomy / emergence`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 1: superseded-historical-wording

Historical note (archived, not current instructions):

> Fluid resuscitation-associated edema develops during the first 48 hours after burn. Escharotomy is usually performed within that period in relation to the injury and resuscitation-associated edema; need and timing depend on clinical assessment and response to treatment, as no objective measure defines the need.

The historical first-48-hours statement is not retained as a mandatory or safe waiting period. Clinical urgency governs release. ([StatPearls: escharotomy and reassessment](https://www.ncbi.nlm.nih.gov/sites/books/NBK482120/); [Anesthesiology: acute and perioperative care of burn injury](https://pmc.ncbi.nlm.nih.gov/articles/PMC4844008/); [Electrical injuries: historical burn-center review](https://academic.oup.com/jbcr/article/25/6/479/4733820))

Current coverage: `burn-escharotomy / procedure`, `burn-fasciotomy / procedure`. Exact current bullets and section hashes are preserved in the JSON companion.

## Colorectal: Abdominoperineal Resection (APR)

### reviewNote 1: covered-in-current-draft

Historical note (archived, not current instructions):

> Base44 is unverified and was not treated as an evidence source. Its fixed crystalloid volume, routine CVP and arterial-line claims, cell-saver and TXA use, epidural/TAP selection, and named induction or maintenance drugs are not established as APR-wide practice by the supplied sources.

Fixed fluid/CVP, mandatory lines, cell salvage, TXA and epidural-drug recipes are not imposed. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable))

Current coverage: `abdominoperineal-resection-apr / perfusion`, `abdominoperineal-resection-apr / analgesia`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 2: scope-boundary-retained

Historical note (archived, not current instructions):

> The source-supported discussion of presacral bleeding does not substantiate Base44's specific emergency maneuver, claims about suture ligation, or a prescribed blood-product setup. These details were omitted rather than converted into guidance.

Presacral hemorrhage anticipation and escalation are covered; detailed surgical hemostatic maneuvers are outside this anesthesia reference. ([StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/))

Current coverage: `abdominoperineal-resection-apr / bleeding`, `abdominoperineal-resection-apr / turn`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 3: partially-covered-open

Historical note (archived, not current instructions):

> The claimed APR syndrome frequency and recommendation to start gabapentin preemptively are unsupported by the supplied sources. They were omitted.

Perineal pain and wound care are covered. Phantom-rectal-pain incidence and an evidence-based specific preventive regimen remain open; routine gabapentin is not justified. ([StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/))

Current coverage: `abdominoperineal-resection-apr / perineum`, `abdominoperineal-resection-apr / analgesia`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 4: covered-in-current-draft

Historical note (archived, not current instructions):

> Base44's claims of routine preoperative chemoradiation, ureteral stents, and particular drug combinations are not universal recommendations in the provided evidence. Stents are described only as a consideration when injury concern is significant, and the source says they do not reduce injury risk.

Cancer treatment and ureteric-device planning are patient-specific, not routine mandates or injury-prevention guarantees. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [A practical approach to management of high-output stoma: clinical review](https://pmc.ncbi.nlm.nih.gov/articles/PMC5369744/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable))

Current coverage: `abdominoperineal-resection-apr / optimization`, `abdominoperineal-resection-apr / procedure`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 5: covered-in-current-draft

Historical note (archived, not current instructions):

> The applicable colorectal guideline supports individualized fluid management and selected goal-directed therapy; it does not support a fixed fluid total. Epidural analgesia is an option for open surgery with acute-pain-team support, not a universal requirement.

Current ERAS fluid principles and selected open-surgery epidural use are represented. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable))

Current coverage: `abdominoperineal-resection-apr / perfusion`, `abdominoperineal-resection-apr / analgesia`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 6: covered-in-current-draft

Historical note (archived, not current instructions):

> Quantitative TOF monitoring and a TOF ratio of at least 0.9 before extubation apply when neuromuscular blocking drugs are used; they are not a requirement for every anesthetic technique.

Quantitative neuromuscular recovery is conditional on blockade. ([OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [APSF: ASA/ESAIC neuromuscular blockade guideline summary (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/))

Current coverage: `abdominoperineal-resection-apr / recovery`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 1: covered-in-current-draft

Historical note (archived, not current instructions):

> APR-specific anesthesia guidance for airway strategy, anesthetic technique, ventilation, vascular access, and monitoring beyond general anesthesia standards.

Case setup, position changes, airway access and hemodynamics are expanded; these are not an APR-only randomized protocol. ([Multidisciplinary guidance: well-leg compartment syndrome after pelvic surgery (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6772077/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable); [Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/))

Current coverage: `abdominoperineal-resection-apr / positioning`, `abdominoperineal-resection-apr / turn`, `abdominoperineal-resection-apr / ventilation`, `abdominoperineal-resection-apr / perfusion`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 2: scope-boundary-retained

Historical note (archived, not current instructions):

> A validated anesthetic response and escalation protocol for major presacral hemorrhage, including APR-specific transfusion guidance.

Hemorrhage response is addressed without inventing an APR-specific transfusion ratio or threshold. ([StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/))

Current coverage: `abdominoperineal-resection-apr / bleeding`, `abdominoperineal-resection-apr / perfusion`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 3: partially-covered-open

Historical note (archived, not current instructions):

> APR-specific postoperative pain, phantom rectal pain, and perineal-wound surveillance guidance.

Perineal morbidity and follow-up are present; specialist chronic/phantom pain guidance remains incomplete. ([StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [Stoma Complications: clinical review (2024 issue)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11466528/); [Multidisciplinary guidance: well-leg compartment syndrome after pelvic surgery (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6772077/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/))

Current coverage: `abdominoperineal-resection-apr / perineum`, `abdominoperineal-resection-apr / postop`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 1: verified-qualified-number

Historical note (archived, not current instructions):

> The APR review gives no emergence or extubation protocol. If neuromuscular blocking drugs are used, the ASA guideline overview recommends quantitative monitoring at the adductor pollicis and confirming train-of-four ratio at least 0.9 before extubation.

TOF at least 0.9 is the conditional ASA recovery recommendation. ([OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [APSF: ASA/ESAIC neuromuscular blockade guideline summary (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/))

Current coverage: `abdominoperineal-resection-apr / recovery`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 2: verified-qualified-number

Historical note (archived, not current instructions):

> For elective colorectal surgery, offer a regular diet within 24 hours. After mid/lower rectal resection, urinary catheter removal is typically recommended within 24–48 hours, balancing urinary-retention risk after pelvic dissection against UTI risk; apply these recommendations to the operative and patient context.

Early feeding and catheter timing are qualified elective colorectal recommendations, not mandatory timing despite complex pelvic surgery or complications. ([OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [APSF: ASA/ESAIC neuromuscular blockade guideline summary (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/))

Current coverage: `abdominoperineal-resection-apr / recovery`. Exact current bullets and section hashes are preserved in the JSON companion.

## Colorectal: Anal Fistula Repair (Fistulotomy / LIFT / Seton)

### reviewNote 1: scope-boundary-retained

Historical note (archived, not current instructions):

> The supplied Base44 fields are unverified and were not treated as evidence. The fistula review is old and surgical in scope; it does not substantiate most anesthesia-specific field entries.

Updated surgical and ambulatory-anorectal guidance improves coverage; surgical guidance is not represented as comparative anesthesia evidence. ([ASCRS: anorectal abscess and fistula guideline (2022)](https://www.ascrsu.com/ascrs/view/ASCRS-Evidence-Based-Guidelines-and-Expert-Consensus/3982014/0/Management_of_Anorectal_Abscess__Fistula_in_Ano__and_Rectovaginal_Fistula__2022_); [Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/))

Current coverage: `anal-fistula-repair-fistulotomy-lift-seton / procedure`, `anal-fistula-repair-fistulotomy-lift-seton / technique`, `anal-fistula-repair-fistulotomy-lift-seton / evidence`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 2: scope-boundary-retained

Historical note (archived, not current instructions):

> The general ASA monitoring and postanesthesia standards support applicable monitoring and recovery statements but do not establish a fistula-specific anesthetic plan.

General ASA recovery standards are not described as fistula-specific trial results. ([Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/); [APSF: ASA/ESAIC neuromuscular blockade guideline summary (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/))

Current coverage: `anal-fistula-repair-fistulotomy-lift-seton / recovery`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 3: covered-in-current-draft

Historical note (archived, not current instructions):

> The colorectal enhanced-recovery guideline applies to elective colorectal resections and was not used to import its analgesia, fluid, or recovery recommendations into fistula surgery.

Major colorectal ERAS and hemorrhoid-specific analgesic regimens are not automatically imported. ([Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/); [PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/))

Current coverage: `anal-fistula-repair-fistulotomy-lift-seton / analgesia`, `anal-fistula-repair-fistulotomy-lift-seton / fluids`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 4: covered-in-current-draft

Historical note (archived, not current instructions):

> The fistula source is a surgical review, not an anesthesia reference. It mentions regional or general anesthesia for abscess surgery and possible anesthesia for seton placement, but does not provide a fistula-repair anesthetic plan.

Individual technique and positioning considerations now supplement limited original anesthesia coverage. ([Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/); [Multidisciplinary guidance: well-leg compartment syndrome after pelvic surgery (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6772077/))

Current coverage: `anal-fistula-repair-fistulotomy-lift-seton / technique`, `anal-fistula-repair-fistulotomy-lift-seton / positioning`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 1: covered-in-current-draft

Historical note (archived, not current instructions):

> Fistula-specific evidence establishing anesthetic technique, airway approach, positioning, analgesia/PONV strategy, fluid or bleeding management, and postoperative anesthesia-care priorities is not available in the supplied sources.

These practical domains are covered in the current draft, without a fixed drug regimen. ([Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/); [Multidisciplinary guidance: well-leg compartment syndrome after pelvic surgery (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6772077/); [PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/); [APSF: ASA/ESAIC neuromuscular blockade guideline summary (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/))

Current coverage: `anal-fistula-repair-fistulotomy-lift-seton / technique`, `anal-fistula-repair-fistulotomy-lift-seton / positioning`, `anal-fistula-repair-fistulotomy-lift-seton / local`, `anal-fistula-repair-fistulotomy-lift-seton / analgesia`, `anal-fistula-repair-fistulotomy-lift-seton / fluids`, `anal-fistula-repair-fistulotomy-lift-seton / recovery`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 2: scope-boundary-retained

Historical note (archived, not current instructions):

> Case-specific targets and a preferred anesthetic technique cannot be established from the available sources.

No universally superior anesthetic technique is claimed for every fistulotomy, LIFT or seton. ([Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/))

Current coverage: `anal-fistula-repair-fistulotomy-lift-seton / technique`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 1: superseded-historical-wording

Historical note (archived, not current instructions):

> If neuromuscular blocking drugs were used, quantitative monitoring is preferred and recovery to a TOF ratio of at least 0.9 should be confirmed before extubation; this does not apply to local or neuraxial cases without NMB.

Current wording retains conditional quantitative recovery without repeating the historical numeric threshold here; this does not invalidate the ASA at-least-0.9 standard. ([Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/); [APSF: ASA/ESAIC neuromuscular blockade guideline summary (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/))

Current coverage: `anal-fistula-repair-fistulotomy-lift-seton / recovery`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 2: identifier-or-provenance-not-treatment-number

Historical note (archived, not current instructions):

> The case-specific evidence is a 2001 surgical review, not an anesthesia reference; it supplies operative discussion but limited anesthetic detail. Its procedural recommendations should be interpreted within that scope.

2001 is historical source provenance; later cited guidance does not make that review contemporary. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/))

Current coverage: `anal-fistula-repair-fistulotomy-lift-seton / evidence`. Exact current bullets and section hashes are preserved in the JSON companion.

## Colorectal: Bowel Obstruction Surgery (Open / Laparoscopic)

### reviewNote 1: scope-boundary-retained

Historical note (archived, not current instructions):

> This is an unapproved reference draft, not a patient-specific plan or checklist.

Clinical draft status and final clinician review remain; source checking is not signoff. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/))

Current coverage: `bowel-obstruction-surgery-open-laparoscopic / evidence`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 2: covered-in-current-draft

Historical note (archived, not current instructions):

> The unverified Base44 assertion that RSI is mandatory and the stomach is never empty is not supported as a universal rule by the supplied obstruction review; it says many clinicians use RSI and discusses aspiration risk.

High aspiration risk commonly favors RSI with a cuffed tube, not an assertion that every presentation requires the identical approach. ([ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [Anesthetic management of intestinal obstruction: review (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC5062241/))

Current coverage: `bowel-obstruction-surgery-open-laparoscopic / airway`, `bowel-obstruction-surgery-open-laparoscopic / assessment`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 3: covered-in-current-draft

Historical note (archived, not current instructions):

> Base44 drug combinations and doses, routine cricoid pressure, universal preoperative NG placement, fixed supine positioning, arterial-line requirements, aggressive fluid totals, TXA, and early NG removal are not established by the supplied evidence and were not reproduced.

Fixed induction, cricoid, NG, line and fluid recipes are replaced by risk-based planning. ([ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [Anesthetic management of intestinal obstruction: review (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC5062241/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/))

Current coverage: `bowel-obstruction-surgery-open-laparoscopic / airway`, `bowel-obstruction-surgery-open-laparoscopic / decompression`, `bowel-obstruction-surgery-open-laparoscopic / monitoring`, `bowel-obstruction-surgery-open-laparoscopic / resuscitation`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 4: covered-in-current-draft

Historical note (archived, not current instructions):

> The elective colorectal recommendation against routine NG tubes does not negate possible decompression in intestinal obstruction; the patient population and clinical purpose differ.

Elective avoidance of routine NG does not prohibit therapeutic decompression in acute obstruction. ([ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [Anesthetic management of intestinal obstruction: review (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC5062241/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/))

Current coverage: `bowel-obstruction-surgery-open-laparoscopic / decompression`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 5: covered-in-current-draft

Historical note (archived, not current instructions):

> The obstruction review is older narrative evidence without grading. The elective colorectal ERP guideline is more formal but explicitly has limited applicability to nonelective obstruction surgery.

Emergency-laparotomy ERAS 2023 provides a more appropriate population than elective guidance alone. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/))

Current coverage: `bowel-obstruction-surgery-open-laparoscopic / evidence`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 1: covered-in-current-draft

Historical note (archived, not current instructions):

> Adult obstruction-specific evidence establishing airway technique selection and ventilation management.

Emergency airway and ventilation domains are supplied with shock and aspiration considerations. ([ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [Anesthetic management of intestinal obstruction: review (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC5062241/))

Current coverage: `bowel-obstruction-surgery-open-laparoscopic / airway`, `bowel-obstruction-surgery-open-laparoscopic / ventilation`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 2: covered-in-current-draft

Historical note (archived, not current instructions):

> Adult obstruction-specific guidance on operative approach, positioning, vascular access, and criteria for invasive monitoring.

Operative severity, monitoring and access are individualized to physiology and expected losses. ([Anesthetic management of intestinal obstruction: review (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC5062241/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/))

Current coverage: `bowel-obstruction-surgery-open-laparoscopic / assessment`, `bowel-obstruction-surgery-open-laparoscopic / monitoring`, `bowel-obstruction-surgery-open-laparoscopic / resuscitation`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 3: covered-in-current-draft

Historical note (archived, not current instructions):

> Adult obstruction-specific emergence, extubation, and postoperative destination criteria.

Physiology-based extubation, ongoing ventilation and postoperative escalation are covered. ([ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [APSF: ASA/ESAIC neuromuscular blockade guideline summary (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/))

Current coverage: `bowel-obstruction-surgery-open-laparoscopic / extubation`, `bowel-obstruction-surgery-open-laparoscopic / postop`. Exact current bullets and section hashes are preserved in the JSON companion.

## Colorectal: Colectomy (Open / Laparoscopic / Robotic)

### reviewNote 1: covered-in-current-draft

Historical note (archived, not current instructions):

> The Base44 claim that mechanical bowel preparation is optional or varies by surgeon is not an adequate summary of the supplied current elective-surgery guideline: ASCRS/SAGES recommends mechanical preparation combined with preoperative oral antibiotics. The older 2012 review disagrees about routine mechanical preparation; this draft gives precedence to the newer procedure-specific guideline for elective resection.

Current elective ASCRS/SAGES combined mechanical preparation and oral-antibiotic guidance replaces the older blanket no-preparation statement. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [A practical approach to management of high-output stoma: clinical review](https://pmc.ncbi.nlm.nih.gov/articles/PMC5369744/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/))

Current coverage: `colectomy-open-laparoscopic-robotic / optimization`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 2: covered-in-current-draft

Historical note (archived, not current instructions):

> Removed unsupported Base44 claims that ETT is universally required for colectomy, robotic docking necessarily prevents the surgeon from reaching the patient, and all robotic cases require a particular airway or emergence plan. The generic laparoscopy/robotics review prefers ETT but does not establish a colectomy-specific mandate.

Laparoscopic/robotic access and airway constraints are addressed without treating all colectomies identically. ([OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [Multidisciplinary guidance: well-leg compartment syndrome after pelvic surgery (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6772077/))

Current coverage: `colectomy-open-laparoscopic-robotic / ventilation`, `colectomy-open-laparoscopic-robotic / positioning`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 3: covered-in-current-draft

Historical note (archived, not current instructions):

> Removed Base44 prescriptions for routine crossmatch, CVP, cell saver, arterial line, epidural test dose, TXA, and fixed crystalloid totals: the supplied sources do not establish these as universal colectomy practices.

Fixed CVP/fluid, routine crossmatch, lines, cell salvage and TXA mandates are not reintroduced. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable))

Current coverage: `colectomy-open-laparoscopic-robotic / perfusion`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 4: scope-boundary-retained

Historical note (archived, not current instructions):

> The source describing an MGH ERAS pathway is institution-specific and conflicts with other supplied evidence on bowel preparation and some pathway details; it was not used as a universal recipe.

An institution-specific pathway is not treated as a universal standard. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/))

Current coverage: `colectomy-open-laparoscopic-robotic / evidence`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 5: covered-in-current-draft

Historical note (archived, not current instructions):

> The 2012 clinical review is older and itself notes evidence limitations. Generic laparoscopic/robotic physiology is useful for anticipating hazards but is not procedure-specific proof of a required technique.

Current guideline scope is distinguished from the older broad surgical review. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/))

Current coverage: `colectomy-open-laparoscopic-robotic / evidence`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 6: scope-boundary-retained

Historical note (archived, not current instructions):

> The supplied sources do not define an adult-only study population for the procedure-specific guideline; this draft uses the requested adult clinical-reference framing without asserting adult-specific trial evidence.

Elective guideline applicability is not recast as proof that every contributing trial was adult-only. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/))

Current coverage: `colectomy-open-laparoscopic-robotic / evidence`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 1: scope-boundary-retained

Historical note (archived, not current instructions):

> Colectomy-specific airway and anesthetic technique recommendations are not established by the supplied procedure-specific guideline.

Practical airway planning is present; no uniquely proven colectomy anesthetic protocol is claimed. ([OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [Multidisciplinary guidance: well-leg compartment syndrome after pelvic surgery (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6772077/))

Current coverage: `colectomy-open-laparoscopic-robotic / ventilation`, `colectomy-open-laparoscopic-robotic / positioning`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 2: scope-boundary-retained

Historical note (archived, not current instructions):

> No source provides a colectomy-specific transfusion threshold or detailed hemorrhage protocol.

Bleeding and perfusion planning do not invent a colectomy-specific transfusion threshold. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable))

Current coverage: `colectomy-open-laparoscopic-robotic / perfusion`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 1: identifier-or-provenance-not-treatment-number

Historical note (archived, not current instructions):

> For elective colorectal resection, the 2023 ASCRS/SAGES guideline supports mechanical bowel preparation combined with oral antibiotics. This differs from the older review's position against routine mechanical preparation; follow applicable current institutional and surgical protocols.

2023 is the cited guideline year, not a treatment number. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [A practical approach to management of high-output stoma: clinical review](https://pmc.ncbi.nlm.nih.gov/articles/PMC5369744/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/))

Current coverage: `colectomy-open-laparoscopic-robotic / optimization`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 2: superseded-historical-wording

Historical note (archived, not current instructions):

> Avoid intraoperative hypotension. The guideline notes association of MAP below 65 mm Hg, even briefly, with myocardial injury and acute kidney injury; this is a risk signal, not a universal individualized target.

Historical MAP-below-65 risk wording is replaced by individualized perfusion guidance, not a universal pressure goal. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable))

Current coverage: `colectomy-open-laparoscopic-robotic / perfusion`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 3: verified-qualified-number

Historical note (archived, not current instructions):

> When neuromuscular blockers are used, use quantitative monitoring at the adductor pollicis and confirm TOF ratio at least 0.9 before extubation. This recommendation does not apply to cases without neuromuscular blockade.

Conditional TOF at least 0.9 remains source-supported. ([OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [APSF: ASA/ESAIC neuromuscular blockade guideline summary (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/))

Current coverage: `colectomy-open-laparoscopic-robotic / recovery`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 4: verified-qualified-number

Historical note (archived, not current instructions):

> After elective colorectal surgery, offer a regular diet within 24 hours and encourage early progressive mobilization.

Diet within 24 hours is qualified to suitable elective colorectal recovery, not complications or obstruction. ([OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [APSF: ASA/ESAIC neuromuscular blockade guideline summary (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/))

Current coverage: `colectomy-open-laparoscopic-robotic / recovery`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 5: identifier-or-provenance-not-treatment-number

Historical note (archived, not current instructions):

> The principal procedure-specific source is the 2023 ASCRS/SAGES guideline for elective colon and rectal resections. It is not a dedicated anesthesia reference and does not specify airway management, positioning, vascular access, or detailed intraoperative monitoring protocols.

2023 identifies guideline provenance and population. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/))

Current coverage: `colectomy-open-laparoscopic-robotic / evidence`. Exact current bullets and section hashes are preserved in the JSON companion.

## Colorectal: Hemorrhoidectomy

### reviewNote 1: scope-boundary-retained

Historical note (archived, not current instructions):

> Base44 fields were treated as unverified, not as evidence. The grade III–IV indication, concurrent anorectal-anatomy considerations, bowel-preparation details, and outpatient status are not established by the supplied sources as general rules.

Surgical selection and preparation are not dictated by the old unverified grade/preparation claims. The newer preparation source is explicitly attributed. ([PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/); [Taiwan Society of Colon and Rectal Surgeons: hemorrhoid consensus (2025)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12572025/); [ASCRS hemorrhoid guideline (2024)](https://www.ascrsu.com/ascrs/view/ASCRS-Evidence-Based-Guidelines-and-Expert-Consensus/3982022/8/Management_of_Hemorrhoids__2024_); [ASRA antithrombotic guideline, fifth edition (2025)](https://rapm.bmj.com/content/early/2025/01/21/rapm-2024-105766))

Current coverage: `hemorrhoidectomy / procedure`, `hemorrhoidectomy / preparation-antithrombotics`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 2: covered-in-current-draft

Historical note (archived, not current instructions):

> Removed unsupported airway claims: prone-position LMA contraindication, ETT preference, and lithotomy LMA preference. The hemorrhoidectomy sources do not provide airway-device guidance.

Prone airway access and technique are individualized; no blanket LMA prohibition or preference is imposed. ([Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/); [Multidisciplinary guidance: well-leg compartment syndrome after pelvic surgery (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6772077/))

Current coverage: `hemorrhoidectomy / positioning`, `hemorrhoidectomy / technique`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 3: scope-boundary-retained

Historical note (archived, not current instructions):

> Removed the specific saddle-block posture, dose, sacral-level targeting, recovery time, and hemodynamic claims; these are not supported by the fetched sources.

No unsupported saddle-block drug/dose/posture recipe is supplied. ([Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/))

Current coverage: `hemorrhoidectomy / technique`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 4: covered-in-current-draft

Historical note (archived, not current instructions):

> The case-field claim that surgeon local infiltration dramatically reduces opioid use and provides a specified duration of analgesia is not established by the evidence supplied. Local techniques are described, but detailed comparative data are limited.

Local anesthetic safety and procedure context replace a guaranteed analgesic duration. ([Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/))

Current coverage: `hemorrhoidectomy / local`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 5: covered-in-current-draft

Historical note (archived, not current instructions):

> The fixed low-fluid target appears in the older 2007 review; it is presented only as a source-reported practice and not as a universal target. The 2022 pain review provides no fluid guidance.

Individualized fluid management replaces the historical 500 mL cap. ([Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/))

Current coverage: `hemorrhoidectomy / fluids`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 6: covered-in-current-draft

Historical note (archived, not current instructions):

> The case-field description of metronidazole as an anal-tissue anti-inflammatory was not used as a mechanism. The review reports pain outcomes for topical and oral metronidazole but does not establish that mechanism as the basis for a standard anesthetic plan.

Topical and oral metronidazole evidence are distinguished; a speculative mechanism is not treated as established. ([PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/))

Current coverage: `hemorrhoidectomy / bowel`, `hemorrhoidectomy / analgesia`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 7: scope-boundary-retained

Historical note (archived, not current instructions):

> Sitz baths are not presented as reliably analgesic: the systematic review reports that warm sitz baths did not provide better post-hemorrhoidectomy pain relief.

Sitz baths are not presented as reliably proven postoperative analgesia. ([PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/))

Current coverage: `hemorrhoidectomy / bowel`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 8: scope-boundary-retained

Historical note (archived, not current instructions):

> General ASA monitoring and PACU standards are applied only within their stated scope; they do not supply hemorrhoidectomy-specific airway, technique, or discharge protocols.

General ASA monitoring guidance is not described as hemorrhoid-specific evidence. ([Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/); [APSF: ASA/ESAIC neuromuscular blockade guideline summary (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/))

Current coverage: `hemorrhoidectomy / recovery`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 9: updated-this-pass

Historical note (archived, not current instructions):

> The supplied sources do not establish anticoagulant-management guidance for hemorrhoidectomy.

Drug indication, bleeding/thrombotic risk and neuraxial planning are separated. Rubber-band-ligation timing uncertainty is not generalized into an excisional-surgery hold table. ([Taiwan Society of Colon and Rectal Surgeons: hemorrhoid consensus (2025)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12572025/); [ASCRS hemorrhoid guideline (2024)](https://www.ascrsu.com/ascrs/view/ASCRS-Evidence-Based-Guidelines-and-Expert-Consensus/3982022/8/Management_of_Hemorrhoids__2024_); [ASRA antithrombotic guideline, fifth edition (2025)](https://rapm.bmj.com/content/early/2025/01/21/rapm-2024-105766))

Current coverage: `hemorrhoidectomy / preparation-antithrombotics`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 10: updated-this-pass

Historical note (archived, not current instructions):

> The preparation and fluid statements come from a 2007 clinical review; they should not be interpreted as current universal protocols.

Contemporary scoped preparation guidance is added; old source age does not justify reinstating a fluid cap. ([Taiwan Society of Colon and Rectal Surgeons: hemorrhoid consensus (2025)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12572025/); [ASCRS hemorrhoid guideline (2024)](https://www.ascrsu.com/ascrs/view/ASCRS-Evidence-Based-Guidelines-and-Expert-Consensus/3982022/8/Management_of_Hemorrhoids__2024_); [ASRA antithrombotic guideline, fifth edition (2025)](https://rapm.bmj.com/content/early/2025/01/21/rapm-2024-105766); [Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/))

Current coverage: `hemorrhoidectomy / preparation-antithrombotics`, `hemorrhoidectomy / fluids`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 1: scope-boundary-retained

Historical note (archived, not current instructions):

> Hemorrhoidectomy-specific criteria for choosing local anesthesia with sedation, spinal/regional anesthesia, or general anesthesia.

Technique and analgesic options are covered without claiming one best anesthetic for all patients. ([Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/); [PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/))

Current coverage: `hemorrhoidectomy / technique`, `hemorrhoidectomy / pudendal`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 2: updated-this-pass

Historical note (archived, not current instructions):

> Perioperative anticoagulant and antiplatelet management applicable to excisional hemorrhoidectomy.

Antithrombotic coordination and evidence-population limits are explicit; no unsupported fixed stop/restart intervals are added. ([Taiwan Society of Colon and Rectal Surgeons: hemorrhoid consensus (2025)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12572025/); [ASCRS hemorrhoid guideline (2024)](https://www.ascrsu.com/ascrs/view/ASCRS-Evidence-Based-Guidelines-and-Expert-Consensus/3982022/8/Management_of_Hemorrhoids__2024_); [ASRA antithrombotic guideline, fifth edition (2025)](https://rapm.bmj.com/content/early/2025/01/21/rapm-2024-105766))

Current coverage: `hemorrhoidectomy / preparation-antithrombotics`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 3: updated-this-pass

Historical note (archived, not current instructions):

> Current, procedure-specific bowel-preparation guidance and the relevance of the older cleansing-enema practice.

Full mechanical preparation is not required by the cited 2025 consensus; enema is optional under the surgical pathway. ([Taiwan Society of Colon and Rectal Surgeons: hemorrhoid consensus (2025)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12572025/); [ASCRS hemorrhoid guideline (2024)](https://www.ascrsu.com/ascrs/view/ASCRS-Evidence-Based-Guidelines-and-Expert-Consensus/3982022/8/Management_of_Hemorrhoids__2024_); [ASRA antithrombotic guideline, fifth edition (2025)](https://rapm.bmj.com/content/early/2025/01/21/rapm-2024-105766))

Current coverage: `hemorrhoidectomy / preparation-antithrombotics`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 4: covered-in-current-draft

Historical note (archived, not current instructions):

> Hemorrhoidectomy-specific airway and ventilation recommendations for prone or lithotomy positioning.

Airway access and positioning are addressed. ([Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/); [Multidisciplinary guidance: well-leg compartment syndrome after pelvic surgery (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6772077/))

Current coverage: `hemorrhoidectomy / positioning`, `hemorrhoidectomy / technique`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 5: covered-in-current-draft

Historical note (archived, not current instructions):

> Contemporary procedure-specific PONV prevention and discharge criteria.

Risk-based PONV and discharge considerations are supplied without a mandatory regimen. ([PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/); [Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/); [APSF: ASA/ESAIC neuromuscular blockade guideline summary (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/))

Current coverage: `hemorrhoidectomy / ponv`, `hemorrhoidectomy / recovery`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 1: superseded-historical-wording

Historical note (archived, not current instructions):

> A 2007 clinical review advises limiting intraoperative fluids to no more than 500 mL to help decrease urinary retention; this is a source-reported practice, not an individualized target.

The historical 500 mL cap is not current patient guidance. ([Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/))

Current coverage: `hemorrhoidectomy / fluids`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 2: superseded-historical-wording

Historical note (archived, not current instructions):

> A meta-analysis found lower pain scores at six and 24 hours with local anesthesia plus IV sedation than with spinal anesthesia. The review gives no specific patient-selection criteria.

Six- and 24-hour study pain comparisons are not retained as proof of universal technique superiority. ([Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/))

Current coverage: `hemorrhoidectomy / technique`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 3: superseded-historical-wording

Historical note (archived, not current instructions):

> If neuromuscular blocking drugs were used, confirm quantitative TOF ratio at least 0.9 before extubation; the recommendation is conditional on NMB use, not a requirement for local or neuraxial cases without blockade.

Current conditional quantitative-recovery wording does not repeat the old number here; ASA at-least-0.9 recovery remains applicable when blockade is used. ([Perioperative Management of the Ambulatory Anorectal Surgery Patient (2016)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4755778/); [APSF: ASA/ESAIC neuromuscular blockade guideline summary (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/))

Current coverage: `hemorrhoidectomy / recovery`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 4: identifier-or-provenance-not-treatment-number

Historical note (archived, not current instructions):

> The other procedure review is from 2007, reports inconsistent open-versus-closed findings, and provides no anesthesia-specific airway or monitoring protocol. Its practice statements require cautious interpretation.

2007 is old source provenance, not a current practice threshold. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/))

Current coverage: `hemorrhoidectomy / evidence`. Exact current bullets and section hashes are preserved in the JSON companion.

## Colorectal: Low Anterior Resection (LAR)

### reviewNote 1: scope-boundary-retained

Historical note (archived, not current instructions):

> The Base44 fields were treated as unverified and were not used as evidence. Source-supported claims are qualified where evidence is narrow or non-randomized.

Original Base44 statements remain unverified history, not evidence. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/))

Current coverage: `low-anterior-resection-lar / evidence`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 2: covered-in-current-draft

Historical note (archived, not current instructions):

> The source guideline’s recommendation for combined mechanical bowel preparation and oral antibiotics is more specific than the single-hospital ERAS protocol’s mechanical-preparation statement; the latter does not establish a contrary general recommendation.

Current elective combined preparation guidance is represented. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [A practical approach to management of high-output stoma: clinical review](https://pmc.ncbi.nlm.nih.gov/articles/PMC5369744/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/))

Current coverage: `low-anterior-resection-lar / optimization`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 3: scope-boundary-retained

Historical note (archived, not current instructions):

> The 40-patient LAR trial supports discussion of possible hemodynamic and pulmonary changes with pneumoperitoneum and Trendelenburg, but not routine nitroglycerin, universal invasive monitoring, or a fixed anesthetic regimen.

A small hemodynamic trial does not mandate arterial lines or nitroglycerin for every case. ([OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable))

Current coverage: `low-anterior-resection-lar / ventilation`, `low-anterior-resection-lar / perfusion`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 4: covered-in-current-draft

Historical note (archived, not current instructions):

> Base44 claims about anastomotic distance, leak-rate estimates and specific risk factors, diverting-stoma protection, routine ureteral stents, lithotomy compartment-syndrome prevention, fixed fluid volumes, cell salvage, and epidural/TAP selection were not established by the supplied sources and were excluded or qualified.

Positioning and pelvic consequences replace unsupported fixed-distance, leak-rate and stent guarantees; no individual risk calculator is implied. ([Multidisciplinary guidance: well-leg compartment syndrome after pelvic surgery (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6772077/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [Memorial Sloan Kettering: low anterior resection, patient education (2026)](https://www.mskcc.org/cancer-care/patient-education/about-your-low-anterior-resection-surgery); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable))

Current coverage: `low-anterior-resection-lar / positioning`, `low-anterior-resection-lar / pelvic`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 1: covered-in-current-draft

Historical note (archived, not current instructions):

> Procedure-specific adult evidence on positioning and prevention or management of positioning-related injury during LAR.

Prolonged lithotomy and well-leg compartment risks are covered with clinical escalation. ([Multidisciplinary guidance: well-leg compartment syndrome after pelvic surgery (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6772077/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/))

Current coverage: `low-anterior-resection-lar / positioning`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 2: scope-boundary-retained

Historical note (archived, not current instructions):

> LAR-specific evidence to stratify anastomotic leak risk and guide response to suspected leak; supplied cohort data do not establish individual risk factors or a management pathway.

Leak recognition and surgical escalation are covered, not a validated individualized risk score or surgical rescue algorithm. ([Memorial Sloan Kettering: low anterior resection, patient education (2026)](https://www.mskcc.org/cancer-care/patient-education/about-your-low-anterior-resection-surgery); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [Multidisciplinary guidance: well-leg compartment syndrome after pelvic surgery (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6772077/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/))

Current coverage: `low-anterior-resection-lar / postop`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 3: partially-covered-open

Historical note (archived, not current instructions):

> Procedure-specific guidance for recognition and management of pelvic autonomic nerve or ureteral injury.

Autonomic/bladder consequences are present; detailed ureteric-injury recognition and management remain a specialist evidence gap. ([Memorial Sloan Kettering: low anterior resection, patient education (2026)](https://www.mskcc.org/cancer-care/patient-education/about-your-low-anterior-resection-surgery); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [Multidisciplinary guidance: well-leg compartment syndrome after pelvic surgery (2019)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6772077/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/))

Current coverage: `low-anterior-resection-lar / pelvic`, `low-anterior-resection-lar / postop`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 1: verified-qualified-number

Historical note (archived, not current instructions):

> If neuromuscular blockade is used, use quantitative monitoring at the adductor pollicis and confirm TOF ratio ≥0.9 before extubation; this does not apply as a requirement to cases without neuromuscular blockade.

TOF at least 0.9 is conditional on neuromuscular blocker use. ([OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [APSF: ASA/ESAIC neuromuscular blockade guideline summary (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/))

Current coverage: `low-anterior-resection-lar / recovery`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 2: superseded-historical-wording

Historical note (archived, not current instructions):

> Avoid intraoperative hypotension; the guideline associates MAP below 65 mm Hg, even briefly, particularly with myocardial injury and acute kidney injury. It gives no LAR-specific transfusion threshold.

Historical MAP-below-65 association is not a universal LAR goal or transfusion trigger. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable))

Current coverage: `low-anterior-resection-lar / perfusion`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 3: verified-qualified-number

Historical note (archived, not current instructions):

> In the absence of surgical complications or hemodynamic instability, discontinue IV fluids early postoperatively. Offer a regular diet within 24 hours after elective colorectal surgery.

Early IV-fluid discontinuation and diet within 24 hours are qualified to stable, uncomplicated elective recovery. ([OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [APSF: ASA/ESAIC neuromuscular blockade guideline summary (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/))

Current coverage: `low-anterior-resection-lar / recovery`. Exact current bullets and section hashes are preserved in the JSON companion.

## Colorectal: Ostomy Creation / Reversal (Ileostomy / Colostomy)

### reviewNote 1: scope-boundary-retained

Historical note (archived, not current instructions):

> The supplied evidence is strongest for general elective colorectal enhanced-recovery principles and weakest for ostomy creation, colostomy reversal, and procedure-specific anesthesia. Do not present broad colorectal recommendations as ostomy-specific standards.

Actual operation and urgency govern applicability; elective resection evidence is not universal to all stoma work. ([Stoma Complications: clinical review (2024 issue)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11466528/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/))

Current coverage: `ostomy-creation-reversal-ileostomy-colostomy / procedure`, `ostomy-creation-reversal-ileostomy-colostomy / approach`, `ostomy-creation-reversal-ileostomy-colostomy / evidence`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 2: covered-in-current-draft

Historical note (archived, not current instructions):

> The loop-ileostomy closure survey is a practice survey with a 22% response rate; its opioid-practice description is internally inconsistent, so no opioid-use conclusion is drawn from it.

A contradictory practice-survey opioid statement is not used to choose analgesia. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable))

Current coverage: `ostomy-creation-reversal-ileostomy-colostomy / analgesia`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 3: scope-boundary-retained

Historical note (archived, not current instructions):

> The multimodal-pain study is retrospective and single-center. Its protocol and outcomes do not establish a preferred block, drug regimen, or general treatment effect.

A retrospective single-center regimen does not establish a preferred block. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable))

Current coverage: `ostomy-creation-reversal-ileostomy-colostomy / analgesia`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 4: updated-this-pass

Historical note (archived, not current instructions):

> No supplied source supports the Base44 claim that LMA is acceptable for reversal alone, or its proposed induction drugs, fluid volume, ketorolac regimen, or stoma-viability return-to-OR rule.

Airway selection remains individualized and new depth-based surgical escalation avoids a blanket stoma return-to-OR rule. ([Stoma Complications: surgical review](https://pmc.ncbi.nlm.nih.gov/articles/PMC11466528/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [A practical approach to management of high-output stoma: clinical review](https://pmc.ncbi.nlm.nih.gov/articles/PMC5369744/))

Current coverage: `ostomy-creation-reversal-ileostomy-colostomy / aspiration`, `ostomy-creation-reversal-ileostomy-colostomy / approach`, `ostomy-creation-reversal-ileostomy-colostomy / stoma`. Exact current bullets and section hashes are preserved in the JSON companion.

### reviewNote 5: updated-this-pass

Historical note (archived, not current instructions):

> No supplied source establishes a stoma-specific PACU viability assessment method or escalation threshold; the flagged complication bullet was removed.

Surgical depth assessment is added without instructions for blind bedside instrumentation. ([Stoma Complications: surgical review](https://pmc.ncbi.nlm.nih.gov/articles/PMC11466528/); [A practical approach to management of high-output stoma: clinical review](https://pmc.ncbi.nlm.nih.gov/articles/PMC5369744/))

Current coverage: `ostomy-creation-reversal-ileostomy-colostomy / stoma`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 1: scope-boundary-retained

Historical note (archived, not current instructions):

> Procedure-specific adult anesthesia guidance for ileostomy or colostomy creation and for colostomy reversal.

General perioperative coverage is available; no creation- or colostomy-reversal-specific superior anesthetic is established. ([Stoma Complications: clinical review (2024 issue)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11466528/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/))

Current coverage: `ostomy-creation-reversal-ileostomy-colostomy / procedure`, `ostomy-creation-reversal-ileostomy-colostomy / approach`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 2: updated-this-pass

Historical note (archived, not current instructions):

> Evidence-based criteria and testing strategy for anastomotic integrity before reversal.

2025 review of anastomotic testing is added, limited to defunctioning ileostomy contexts and very-low-certainty evidence. ([Stoma Complications: clinical review (2024 issue)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11466528/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [Anastomotic evaluation before ileostomy closure: 2025 systematic review](https://pmc.ncbi.nlm.nih.gov/articles/PMC12159718/))

Current coverage: `ostomy-creation-reversal-ileostomy-colostomy / closure`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 3: updated-this-pass

Historical note (archived, not current instructions):

> A source-supported PACU method and escalation criteria for assessing stoma viability after creation.

Superficial versus below-fascia ischemia/necrosis and urgent surgical escalation are distinguished. ([Stoma Complications: surgical review](https://pmc.ncbi.nlm.nih.gov/articles/PMC11466528/); [A practical approach to management of high-output stoma: clinical review](https://pmc.ncbi.nlm.nih.gov/articles/PMC5369744/))

Current coverage: `ostomy-creation-reversal-ileostomy-colostomy / stoma`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 4: covered-in-current-draft

Historical note (archived, not current instructions):

> Procedure-specific airway and anesthetic technique selection, emergence criteria, and fluid or bleeding data for ostomy procedures.

Airway, fluid and recovery domains are expanded around the actual procedure. ([Stoma Complications: clinical review (2024 issue)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11466528/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [A practical approach to management of high-output stoma: clinical review](https://pmc.ncbi.nlm.nih.gov/articles/PMC5369744/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable); [APSF: ASA/ESAIC neuromuscular blockade guideline summary (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/))

Current coverage: `ostomy-creation-reversal-ileostomy-colostomy / aspiration`, `ostomy-creation-reversal-ileostomy-colostomy / approach`, `ostomy-creation-reversal-ileostomy-colostomy / hydration`, `ostomy-creation-reversal-ileostomy-colostomy / perfusion`, `ostomy-creation-reversal-ileostomy-colostomy / recovery`. Exact current bullets and section hashes are preserved in the JSON companion.

### evidenceGap 5: updated-this-pass

Historical note (archived, not current instructions):

> complications: The supplied sources do not describe a PACU stoma-viability assessment method or escalation threshold.

The repeated stoma-assessment gap is addressed by the same explicit surgical-depth/escalation section; counted as an original note, not a second clinical change. ([Stoma Complications: surgical review](https://pmc.ncbi.nlm.nih.gov/articles/PMC11466528/); [A practical approach to management of high-output stoma: clinical review](https://pmc.ncbi.nlm.nih.gov/articles/PMC5369744/))

Current coverage: `ostomy-creation-reversal-ileostomy-colostomy / stoma`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 1: superseded-historical-wording

Historical note (archived, not current instructions):

> In this practice survey, respondents reported hand-sewn anastomoses in 45.2% of cases and stapled anastomoses in 54.8%; the survey reports practice patterns, not a comparison of their outcomes.

Hand-sewn/stapled survey percentages are not retained as comparative outcome guidance. ([Stoma Complications: clinical review (2024 issue)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11466528/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [Anastomotic evaluation before ileostomy closure: 2025 systematic review](https://pmc.ncbi.nlm.nih.gov/articles/PMC12159718/))

Current coverage: `ostomy-creation-reversal-ileostomy-colostomy / closure`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 2: verified-qualified-number

Historical note (archived, not current instructions):

> When neuromuscular blocking drugs are used, the cited ASA-guideline overview recommends quantitative monitoring and confirming train-of-four ratio at least 0.9 before extubation; this does not apply to cases without neuromuscular blockade.

Conditional quantitative TOF at least 0.9 is source-supported. ([OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [APSF: ASA/ESAIC neuromuscular blockade guideline summary (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/))

Current coverage: `ostomy-creation-reversal-ileostomy-colostomy / recovery`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 3: superseded-historical-wording

Historical note (archived, not current instructions):

> Avoid intraoperative hypotension in the colorectal guideline’s population; it associates even brief MAP below 65 mm Hg particularly with myocardial injury and acute kidney injury.

Historical MAP-below-65 association is replaced by individualized perfusion guidance. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [StatPearls: abdominoperineal resection (2024)](https://ncbi.nlm.nih.gov/books/NBK574568/?report=printable))

Current coverage: `ostomy-creation-reversal-ileostomy-colostomy / perfusion`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 4: verified-qualified-number

Historical note (archived, not current instructions):

> For patients undergoing elective colorectal surgery, offer a regular diet within 24 hours; early progressive mobilization is associated with shorter length of stay.

Early feeding within 24 hours is scoped to suitable elective colorectal recovery. ([OpenAnesthesia: laparoscopic and robotic surgery (2024)](https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/); [APSF: ASA/ESAIC neuromuscular blockade guideline summary (2023)](https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/); [ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/))

Current coverage: `ostomy-creation-reversal-ileostomy-colostomy / recovery`. Exact current bullets and section hashes are preserved in the JSON companion.

### numericalFlag 5: superseded-historical-wording

Historical note (archived, not current instructions):

> The closure survey describes Italian surgeons’ practice for loop ileostomy reversal after rectal cancer surgery; 219 SICCR members responded, for a 22% response rate. It is a practice survey, not an anesthesia guideline.

Survey sample and response-rate numbers are not current clinical treatment instructions. ([ASCRS/SAGES: enhanced recovery after colon and rectal surgery (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9839829/); [ERAS Society: emergency laparotomy, intraoperative and postoperative care (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10241558/); [PROSPECT: haemorrhoid surgery pain guideline (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11783633/))

Current coverage: `ostomy-creation-reversal-ileostomy-colostomy / evidence`. Exact current bullets and section hashes are preserved in the JSON companion.
