# EKG migration status

The private Flutter preview now exposes a clinical draft through Diagnostics.
Normal `main.dart` builds do not enable that draft. Special Considerations
signoff does not imply approval of this new module.

## Implemented

- Twenty requested rhythm cards with the four specified headings.
- Eight ischemia/territory references, including aVR and right ventricular topics.
- Six electrolyte topics, including hypermagnesemia.
- Intervals, monitor leads/artifact, high-yield anesthesia findings.
- Pacemaker/ICD preoperative planning, magnet effects, EMI, and recovery.
- Normal sinus rhythm and nonshockable arrest reference extras from the
  Base44 module's topic organization.
- Search, category filtering, reference links, detail navigation and Home.

## Source reconciliation

Adapted from the supplied `Luma_EKG_Module_Specification.docx` and
`nmfetzer/luma-anesthesia` Base44 EKG components. Base44 wording was not copied
wholesale. The draft removes old fixed cardioversion doses and the older atropine
range rather than introducing another unreviewed dosing table.

Important revisions:

- New LBBB is not automatically labeled proof of acute occlusion.
- aVR elevation/diffuse ST depression is not labeled diagnostic of left-main
  occlusion ([LITFL discussion](https://litfl.com/st-depression-does-not-localise/)).
- Pre-excited AF cautions use the newer guideline rather than the older review
  recommending amiodarone ([2023 AF guideline](https://pmc.ncbi.nlm.nih.gov/articles/PMC11104284/)).
- Sustained polymorphic VT prioritizes immediate defibrillation
  ([2025 AHA executive summary](https://cpr.heart.org/en/resuscitation-science/cpr-and-ecc-guidelines/executive-summary)).
- ICD magnets do not make pacing asynchronous; Micra has no magnet response,
  while some other leadless devices do
  ([AHA device statement summary](https://www.acc.org/latest-in-cardiology/ten-points-to-remember/2024/07/17/14/48/periprocedural-management-and)).
- No fixed electrolyte concentration is inferred from an ECG pattern.

## Still required before clinical release

Clinician review of each card, tighter topic-specific source coverage where only
the ECG index supports a draft topic, and finalized management/monitoring depth.
The current draft is concise, not a verbatim migration of every Base44 paragraph.
Base44 rhythm imagery, an interactive lead diagram, and the QTc calculator have
not been migrated. The specification's Miller, Barash and UpToDate references
were not accessed and are not represented as reviewed.

EKG is currently bundled in the owner preview, not loaded into Supabase.
Choose the final publication/access model before adding server content or
enabling the module in production.
