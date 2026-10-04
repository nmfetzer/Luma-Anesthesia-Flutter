# Regional & Procedures: next-build review

Prepared October 4, 2026. Not yet clinically approved or pushed to GitHub.
This is a Flutter feature proposal, not a native TestFlight upload.

## Included

- Fourteen distinct adult block references, adapted from the twelve Base44 block cards. TAP and QL are separate; ESP and PENG are separate.
- Eight supporting references: general safety, antithrombotics/catheter timing, infection, local anesthetic safety, liposomal bupivacaine, LAST, neurologic injury, and selection/recovery.
- Bulleted clinical content, direct source links, related references, and Home navigation.
- Search within the section and direct-to-topic homepage results.
- Subscription protection on hub, direct topics, and related topics using the existing paid/complimentary entitlement gate.
- Bundled offline text; source websites require internet. Existing account-bound offline access lease applies. This is UI access control, not encryption of the bundled text.
- No new Supabase tables, new billing products, AI calls, patient-data collection, or medication calculator.

## Consolidated content changes for clinical review

- **Antithrombotics:** replace generic hold/restart rows with dose-, renal-, placement-, removal-, and restart-specific reference text. Explicitly label this a selected, incomplete drug reference rather than procedural clearance. Source: https://rapm.bmj.com/content/early/2025/01/21/rapm-2024-105766
- **Liposomal bupivacaine:** remove the legacy “266 mg per side” TAP recipe and unsupported universal fascial-plane block doses. Distinguish adult infiltration maximum from the approved adult perineural regimens, formulation compatibility, and the label’s 96-hour warning. Source: https://www.exparel.com/prescribing-information.pdf
- **Motor effects:** remove claims that PENG, iPACK, and adductor canal cannot cause weakness. Sources: https://pmc.ncbi.nlm.nih.gov/articles/PMC9408030/ and https://pmc.ncbi.nlm.nih.gov/articles/PMC9373452/ and https://www.nysora.com/regional-anesthesia/techniques/ultrasound-guided-saphenous-subsartorius-adductor-canal-nerve-block/
- **Respiratory risk:** replace fixed/universal phrenic-palsy assertions and categorical “safe in pulmonary compromise” labels with technique- and patient-dependent cautions. Sources: https://www.nysora.com/regional-anesthesia/techniques/ultrasound-guided-interscalene-brachial-plexus-block/ and https://www.nysora.com/regional-anesthesia/techniques/ultrasound-guided-supraclavicular-brachial-plexus-block/
- **Anatomical distinctions:** do not combine TAP with QL or ESP with PENG as if they were one procedure. Do not treat cord clock-face positions or sensory coverage as universal. Source links appear beside each clinical section in the app.
- **Infection/neurologic risk:** incorporate ASRA infection-control guidance and urgent evaluation of progressive/unexpected deficits without a reassuring “wait a fixed number of hours” rule. Sources: https://doi.org/10.1136/rapm-2024-105651 and https://rapm.bmj.com/content/rapm/40/5/401.full.pdf
- **LAST:** use the directly linked ASRA 2020 cognitive aid for reference values and explicitly distinguish LAST resuscitation from standard ACLS. Source: https://asra.com/docs/default-source/guidelines-articles/local-anesthetic-systemic-toxicity-rgb.pdf?sfvrsn=33b348e_2
- **Dosing tools:** do not migrate the legacy universal maximum-dose calculator, mixed-route onset/duration table, or fixed perineural adjuvant recipes. Reference text directs clinicians to product labeling, existing Drug Library, and local protocols.

## Boundaries

The PENG NYSORA URL in Base44 could not be fetched, so this page uses the fetched peer-reviewed PENG review instead. Other technique links and the cited ASRA/product documents were fetched during this review. No publisher illustrations or full articles were copied.

Clinical content remains subject to the owner's review and approval. Browser/widget tests do not establish native-device acceptance, clinical completeness for every regional technique, or App Store approval. Adult content only; the deferred pediatric pack remains separate.

## Technical verification

- 171 targeted Flutter tests passed together: Regional, homepage search, app routing, Diagnostics topic search/release, and offline-cache regression.
- New Regional source and tests passed targeted static analysis with no issues. Broader analysis reported only existing informational lints in the drawer/offline screen.
- Tests cover all 22 paid topic routes, the paid hub, access revocation, related-topic navigation, Home, missing-topic recovery, source-ID/related-ID integrity, local search with remote failure, and 320/375/820-pixel layouts at normal and doubled text scale.
- Clinical source text was not loaded into a new Supabase table. Existing production data and entitlement settings are unchanged.
