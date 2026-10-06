# General & Abdominal and GI/Endoscopy expansion

Source milestone: October 5, 2026. This update adds or expands 36 adult clinical-review references, with four quick-overview bullets and 10 expandable sections per reference. There are 864 bullets across this update; the overall catalog now has 288 unique adult/OB references.

## Scope

- **General & Abdominal:** 20 expanded/added references, organized alongside reused colorectal, bariatric, HPB and vascular records. The specialty view has 39 canonical references in six groups, including existing nonabdominal general procedures.
- **GI/Endoscopy:** 16 references in four groups: planning/routine endoscopy; biliary/pancreatic/advanced endoscopy; bleeding/esophageal emergencies; feeding access/small-bowel procedures.
- **Canonical records:** 19 existing JSON records expanded and 17 added. All 251 untargeted JSON records remain unchanged; the manual laparoscopic cholecystectomy record is unchanged.
- **No duplication:** PEG/J-tube, Whipple, bariatric and colorectal references retain their existing routes. Thyroidectomy remains accessible in Endocrine and by its original URL but is omitted from the General & Abdominal discovery view. Endocrine clinical content is unchanged; bronchoscopy remains separate.

## Selected evidence safeguards

- **ERCP:** Individualize MAC versus GA rather than prescribing GA solely for age, ASA classification or the procedure name. The 2023 recommendations are modified-Delphi consensus, not definitive comparative evidence ([ERCP consensus](https://pubmed.ncbi.nlm.nih.gov/37062671/)).
- **Upper-GI hemorrhage:** Selective airway protection, not routine prophylactic intubation for every patient, follows the May 2026 update ([ESGE peptic-ulcer bleeding guideline](https://www.esge.com/assets/downloads/pdfs/guidelines/2026_a-2863-8314.pdf)).
- **PEG:** Preserve the 2025 ASGE conditional suggestion against routinely withholding antiplatelets, while individualizing anticoagulants; very-low-certainty evidence is labeled ([ASGE gastrostomy guideline](https://www.sigeitalia.it/multimedia/files/attivita-scientifica/linee-guida/endoscopia-digestiva/2025-asge-gastrostomy-feeding-tubes.pdf)).
- **Variceal bleeding:** Do not treat cirrhotic INR as a direct hemostasis measure or prescribe routine FFP normalization ([Baveno VII](https://pmc.ncbi.nlm.nih.gov/articles/PMC11090185/)).
- **POEM:** Retained esophageal contents and clinically significant gas complications are emphasized without universal case-series rescue thresholds ([POEM anesthesia review](https://pmc.ncbi.nlm.nih.gov/articles/PMC9191809/)).
- **Hepatic surgery:** Low venous-pressure techniques during transection require perfusion monitoring and post-transection reassessment, not indiscriminate fluid restriction ([ERAS liver surgery recommendations](https://serval.unil.ch/resource/serval:BIB_C547BF1B443C.P001/REF.pdf)).

## Technical validation and release boundary

The 53 targeted Surgical Case Prep tests pass, targeted static analysis is clean, and the release web preview builds. Phone/tablet/desktop review covered specialty grouping, overview/detail presentation and search/expansion controls. Premium checks, source-failure handling and deferred-release tests remain intact.

These are clinical-review drafts. A source merge does not independently approve clinical content, activate deferred sections, modify Supabase, produce a native build or upload/release an app.
