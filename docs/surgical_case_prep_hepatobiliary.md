# Hepatobiliary surgical case expansion

October 5, 2026 source milestone: 12 expanded/added adult references, with 10 additions and two replacements (hepatic resection and liver transplant). Total unique adult/OB catalog: 306. HPB displays 21 references in six groups; existing endocrine, GI, gallbladder and pancreatic records are reused through canonical routes.

## Scope

- **New coverage:** HPB framework, cirrhosis/portal-hypertension planning, living-donor hepatectomy, bile duct exploration, biliary reconstruction, cholangitis/drainage, pancreatic enucleation, pancreatitis/necrosis intervention, TIPS and HPB hemorrhage/bile-leak emergencies.
- **Expanded coverage:** Major liver resection, vascular control, gas embolism and liver failure; transplant phase-specific hemodynamics, metabolic preparation and postoperative care.
- **Preserved material:** All 293 untargeted JSON records and manual laparoscopic cholecystectomy remain unchanged against baseline `9595f3f1927270fa6a10b6ce94f98366fc112f2d`. Whipple, ERCP, distal pancreatectomy and endocrine syndrome content is not duplicated or overwritten.

## Evidence safeguards

- **Low CVP:** Phase-specific with perfusion reassessment, not indiscriminate dehydration ([ERAS 2022](https://pmc.ncbi.nlm.nih.gov/articles/PMC9726826/)).
- **Cirrhotic coagulation:** INR is not a global bleeding-risk measure; no routine prophylactic plasma normalization or blanket neuraxial clearance by TEG ([AASLD 2024](https://www.aasld.org/liver-fellow-network/core-series/clinical-pearls/peri-procedural-management-bleeding-risk-cirrhosis)).
- **Cholangitis:** The conditional 48-hour recommendation is not permission to wait in deteriorating shock; unstable patients may need drainage alone ([ASGE 2021](https://www.asge.org/docs/default-source/default-document-library/piis0016510720351117.pdf?sfvrsn=bad7c25d_1)).
- **Pancreatitis:** Reassessed moderate hydration, no routine antibiotics for sterile disease, delayed necrosis intervention only when stable ([ACG 2024 highlights](https://webfiles.gi.org/links/journals/AJG-Clinical-Guidelines-Highlights-Acute-Pancreatitis-2024-FINAL.pdf)).
- **TIPS:** Cardiopulmonary selection, increased preload and encephalopathy risks; no universally superior anesthesia technique ([ALTA consensus](https://escholarship.org/content/qt3478x01k/qt3478x01k_noSplash_00feef10543e8c64e36e56fc568e7942.pdf?t=sl6kfc)).
- **Donors:** Healthy donor safety and limited comparative evidence explicitly distinguished from recipient physiology ([2022 donor review](https://deepblue.lib.umich.edu/bitstream/handle/2027.42/172954/ctr14690.pdf?sequence=2)).

## Validation and boundaries

All 60 targeted tests passed, targeted static analysis was clean and the release web preview built. Phone/tablet visual checks covered grouped navigation, hepatic-resection overview/details and search/reset. Updated records contain 386 source-linked bullets.

Clinical drafts and release-deferred gates remain intact. Source integration is not clinical signoff, production activation, Supabase mutation or native/TestFlight/App Store build/upload/release.
