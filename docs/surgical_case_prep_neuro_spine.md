# Neuro & Spine surgical case expansion

October 5, 2026 source milestone: 29 expanded or added adult references, comprising 22 expanded records and seven additions. Neuro & Spine displays 31 canonical entries in eight groups; the total adult/OB catalog contains 313 unique references.

## Scope and preservation

- **New coverage:** Neuro/spine framework, posterior fossa, intracranial AVM resection, spontaneous intracerebral hemorrhage evacuation, adult spinal deformity, spinal cord tumors and emergency response.
- **Expanded coverage:** Cranial tumor/trauma, awake mapping, aneurysm/endovascular stroke, CSF diversion, cervical and lumbar surgery, neuromonitoring, DBS, epilepsy and SCS.
- **Preserved material:** All 283 untargeted JSON records, the manual laparoscopic cholecystectomy entry and canonical routes remain intact against baseline `21256ef7521e28ea63287ad7ceb11508279a6a42`. Existing pituitary and adult craniopharyngioma content is reused unchanged. The prior manually reviewed TBI airway/ventilation section is preserved verbatim, including its sources.
- **Structure:** Four quick-overview bullets with expandable source-linked sections, totaling 850 bullets across the 29 authored references. Adult-only scope; no pediatric scoliosis protocol.

## Evidence safeguards

- **Stroke:** Qualified post-EVT blood-pressure recommendations use the [2026 AHA/ASA guideline](https://dhhs.ne.gov/OEHS%20Stroke%20Advisory%20Task%20Force%20Documents/Early%20Mnmgt%20of%20AIS.pdf), superseding the older institutional handbook's conflicting routine low post-reperfusion target.
- **TBI:** Severe-TBI ICP/CPP targets are not generalized to other operations; prior normocapnia wording and individualized rescue ventilation remain intact ([BTF](https://braintrauma.org/coma/guidelines/severe-tbi)).
- **IONM:** Signal change prompts immediate team communication and surgical pause with parallel surgical, technical, anesthetic and physiologic assessment, not sequential troubleshooting before notifying the surgeon ([2024 guideline](https://pmc.ncbi.nlm.nih.gov/articles/PMC10964898/)).
- **Airway:** Post-ACDF critical hematoma is an immediate airway/surgical response, without delaying rescue for imaging ([systematic review](https://pmc.ncbi.nlm.nih.gov/articles/PMC11467286/)).
- **EVD:** Drainage, leveling and transport clamping are individualized rather than a blanket clamp-for-every-transfer rule ([SNACC](https://www.snacc.org/wp-content/uploads/2018/03/SNACC_EVD_Guidelines.pdf)).
- **SCS:** Percutaneous trial-lead feedback safeguards are distinguished from paddle implants and care of an existing device ([consensus](https://pmc.ncbi.nlm.nih.gov/articles/PMC10370290/)).

## Technical validation and release boundary

All 64 targeted Flutter tests pass; targeted static analysis reports no issues and the release web preview builds. Phone and tablet visual checks covered grouped navigation, overview, detailed BP content, search/reset and section expansion. An initial regression failure caught replacement of the prior TBI ventilation correction; the builder now preserves it exactly and the unchanged regression test passes.

These remain clinical-review drafts. Technical checks are not clinical signoff, native acceptance, production activation, Supabase changes or authorization for a native/TestFlight/App Store build or release.
