# Surgical Case Prep: Original Library Reconciliation

Reconciled October 6, 2026 against the saved source titled “Surgical Case Prep: Adult and OB Library Review,” its 242-row audit and the separately maintained laparoscopic cholecystectomy reference. The local PDF path provided in chat was not opened; this comparison uses the matching saved Markdown source, not a byte-for-byte comparison of the downloaded PDF.

## Result

- All 243 original inventory entries are accounted for. One former combined burn entry is now two clinically distinct references, with the old route retained as a gated route to Burns.
- All 312 JSON records from the immediately preceding 313-entry milestone remain. Every pre-existing detail section and quick-overview bullet/source is retained by this final batch; replaced quick overviews are kept as additional overview context beneath the expanded material.
- All nine OB records are unchanged from the preceding milestone. The manual laparoscopic cholecystectomy file is unchanged.
- This is an inventory and technical preservation check, not a claim that every sentence from the original 252,000-word draft remains verbatim after all earlier specialty revisions. Earlier evidence-based revisions may replace or qualify older wording.
- Historical correction counts, source-review notes and unresolved gaps remain in the original review/audit/register. They are review documentation, not bedside instructions and not newly resolved by this comparison.

## Final batch

| Specialty | Expanded or added | New unique records |
|---|---:|---:|
| NORA | 15 | 11 |
| OPHTHALMOLOGY | 13 | 8 |
| PLASTIC | 17 | 7 |
| TRAUMA | 11 | 7 |
| UROLOGY | 14 | 3 |
| VASCULAR | 14 | 2 |

The resulting catalog contains 351 unique case/reference entries across 22 specialties, including nine OB entries. It includes frameworks and emergency references, so this is not a count of distinct operations. Cross-listings are not counted twice.

## Original inventory mapping

| Original reference | Current canonical ID or replacement | Result |
|---|---|---|
| Roux-en-Y Gastric Bypass (RYGB) | `roux-en-y-gastric-bypass-rygb` | Present |
| Sleeve Gastrectomy | `sleeve-gastrectomy` | Present |
| Burn Excision and Split-Thickness Skin Grafting | `burn-excision-and-split-thickness-skin-grafting` | Present |
| Escharotomy / Fasciotomy for Burns | `escharotomy-fasciotomy-for-burns` → `burn-escharotomy` + `burn-fasciotomy` | Split, old route retained |
| Aortic Root / Ascending Aorta Repair | `aortic-root-ascending-aorta-repair` | Present |
| Aortic Valve Replacement (AVR) | `aortic-valve-replacement-avr` | Present |
| Bronchoscopy (Flexible / Rigid) | `bronchoscopy-flexible-rigid` | Present |
| CABG (Coronary Artery Bypass Grafting) | `cabg-coronary-artery-bypass-grafting` | Present |
| Cardiac Catheterization / PCI | `cardiac-catheterization-pci` | Present |
| Cardiac Valve Repair / Replacement (Open) | `cardiac-valve-repair-replacement-open` | Present |
| Chest Wall Resection and Reconstruction | `chest-wall-resection-and-reconstruction` | Present |
| Decortication (Pleural) | `decortication-pleural` | Present |
| ECMO Cannulation / Decannulation | `ecmo-cannulation-decannulation` | Present |
| Esophagectomy (Ivor Lewis / McKeown / Minimally Invasive) | `esophagectomy-ivor-lewis-mckeown-minimally-invasive` | Present |
| Heart Transplant | `heart-transplant` | Present |
| Lobectomy (VATS / Open) | `lobectomy-vats-open` | Present |
| Lung Transplant (Single / Double) | `lung-transplant-single-double` | Present |
| LVAD Placement (Left Ventricular Assist Device) | `lvad-placement-left-ventricular-assist-device` | Present |
| Mediastinoscopy | `mediastinoscopy` | Present |
| Pericardial Window | `pericardial-window` | Present |
| Pleurodesis (Chemical / Surgical VATS) | `pleurodesis-chemical-surgical-vats` | Present |
| Pneumonectomy | `pneumonectomy` | Present |
| Thoracic Aortic Aneurysm Repair (TEVAR / Open Descending) | `thoracic-aortic-aneurysm-repair-tevar-open-descending` | Present |
| Thoracotomy (Open) / Exploratory Thoracotomy | `thoracotomy-open-exploratory-thoracotomy` | Present |
| Thymectomy (VATS / Open / Robotic) | `thymectomy-vats-open-robotic` | Present |
| VATS Wedge Resection | `vats-wedge-resection` | Present |
| Abdominoperineal Resection (APR) | `abdominoperineal-resection-apr` | Present |
| Anal Fistula Repair (Fistulotomy / LIFT / Seton) | `anal-fistula-repair-fistulotomy-lift-seton` | Present |
| Bowel Obstruction Surgery (Open / Laparoscopic) | `bowel-obstruction-surgery-open-laparoscopic` | Present |
| Colectomy (Open / Laparoscopic / Robotic) | `colectomy-open-laparoscopic-robotic` | Present |
| Hemorrhoidectomy | `hemorrhoidectomy` | Present |
| Low Anterior Resection (LAR) | `low-anterior-resection-lar` | Present |
| Ostomy Creation / Reversal (Ileostomy / Colostomy) | `ostomy-creation-reversal-ileostomy-colostomy` | Present |
| Dental Rehabilitation Under General Anesthesia (Adult) | `dental-rehabilitation-under-general-anesthesia-adult` | Present |
| Orthognathic Surgery (Bimaxillary Osteotomy) | `orthognathic-surgery-bimaxillary-osteotomy` | Present |
| Adrenalectomy (Laparoscopic / Robotic) | `adrenalectomy-laparoscopic-robotic` | Present |
| Pheochromocytoma Resection | `pheochromocytoma-resection` | Present |
| Airway Foreign Body Removal | `airway-foreign-body-removal` | Present |
| Awake Fiber-Optic Intubation (AFOI) | `awake-fiber-optic-intubation-afoi` | Present |
| Functional Endoscopic Sinus Surgery (FESS) | `functional-endoscopic-sinus-surgery-fess` | Present |
| Laryngectomy (Total / Partial) | `laryngectomy-total-partial` | Present |
| Mastoidectomy | `mastoidectomy` | Present |
| Maxillofacial Trauma Surgery (Panfacial Fractures) | `maxillofacial-trauma-surgery-panfacial-fractures` | Present |
| Microlaryngoscopy / Vocal Cord Surgery | `microlaryngoscopy-vocal-cord-surgery` | Present |
| Myringotomy with Tube Placement (Adult) | `myringotomy-with-tube-placement-adult` | Present |
| Neck Dissection (Radical / Modified / Selective) | `neck-dissection-radical-modified-selective` | Present |
| Parotidectomy (Superficial / Total) | `parotidectomy-superficial-total` | Present |
| Septoplasty / Turbinate Reduction | `septoplasty-turbinate-reduction` | Present |
| Tonsillectomy and Adenoidectomy (T&A) (Adult) | `tonsillectomy-and-adenoidectomy-t-a-adult` | Present |
| Tracheal Intubation for Epiglottitis | `tracheal-intubation-for-epiglottitis` | Present |
| Tympanoplasty | `tympanoplasty` | Present |
| ASD / PFO Closure (Percutaneous) | `asd-pfo-closure-percutaneous` | Present |
| Atrial Fibrillation Ablation (Pulmonary Vein Isolation) | `atrial-fibrillation-ablation-pulmonary-vein-isolation` | Present |
| Atrial Flutter Ablation (Cavotricuspid Isthmus) | `atrial-flutter-ablation-cavotricuspid-isthmus` | Present |
| Cardiac Catheterization (Diagnostic) | `cardiac-catheterization-diagnostic` | Present |
| Elective Cardioversion (DCCV) | `elective-cardioversion-dccv` | Present |
| Electrophysiology (EP) Study | `electrophysiology-ep-study` | Present |
| ICD / AICD Placement | `icd-aicd-placement` | Present |
| Implantable Loop Recorder (ILR) Placement | `implantable-loop-recorder-ilr-placement` | Present |
| Lead Extraction (Transvenous) | `lead-extraction-transvenous` | Present |
| MitraClip / TEER (Transcatheter Edge-to-Edge Repair) | `mitraclip-teer-transcatheter-edge-to-edge-repair` | Present |
| Pacemaker / ICD Generator Change | `pacemaker-icd-generator-change` | Present |
| PCI with Hemodynamic Support (High-Risk PCI) | `pci-with-hemodynamic-support-high-risk-pci` | Present |
| Permanent Pacemaker Implantation | `permanent-pacemaker-implantation` | Present |
| SVT Ablation (AVNRT / AVRT) | `svt-ablation-avnrt-avrt` | Present |
| TAVR (Transcatheter Aortic Valve Replacement) | `tavr-transcatheter-aortic-valve-replacement` | Present |
| TEE-Guided Cardioversion | `tee-guided-cardioversion` | Present |
| Ventricular Tachycardia (VT) Ablation | `ventricular-tachycardia-vt-ablation` | Present |
| Watchman / Left Atrial Appendage Occlusion (LAAO) | `watchman-left-atrial-appendage-occlusion-laao` | Present |
| Abscess Incision and Drainage (I&D) | `abscess-incision-and-drainage-i-d` | Present |
| Appendectomy (Laparoscopic/Open) | `appendectomy-laparoscopic-open` | Present |
| Bowel Resection (Small / Large) | `bowel-resection-small-large` | Present |
| Breast Biopsy / Lumpectomy / Mastectomy | `breast-biopsy-lumpectomy-mastectomy` | Present |
| Diagnostic Laparoscopy / Lysis of Adhesions | `diagnostic-laparoscopy-lysis-of-adhesions` | Present |
| Feeding Tube Placement (PEG / J-tube) | `feeding-tube-placement-peg-j-tube` | Present |
| Femoral Hernia Repair | `femoral-hernia-repair` | Present |
| Hiatal Hernia Repair / Nissen Fundoplication | `hiatal-hernia-repair-nissen-fundoplication` | Present |
| Inguinal Hernia Repair (Open/Laparoscopic/Robotic) | `inguinal-hernia-repair-open-laparoscopic-robotic` | Present |
| Lower Extremity Amputation (Toe / Foot / BKA / AKA) | `lower-extremity-amputation-toe-foot-bka-aka` | Present |
| Perforated Viscus Repair | `perforated-viscus-repair` | Present |
| Pilonidal Cyst Excision | `pilonidal-cyst-excision` | Present |
| Port Placement / Removal (Mediport / PICC Port) | `port-placement-removal-mediport-picc-port` | Present |
| Robotic Cholecystectomy | `robotic-cholecystectomy` | Present |
| Robotic Hernia Repair / Abdominal Wall Reconstruction | `robotic-hernia-repair-abdominal-wall-reconstruction` | Present |
| Soft Tissue Mass Excision | `soft-tissue-mass-excision` | Present |
| Splenectomy (Laparoscopic/Open) | `splenectomy-laparoscopic-open` | Present |
| Thyroidectomy | `thyroidectomy` | Present |
| Tracheostomy Placement | `tracheostomy-placement` | Present |
| Umbilical / Ventral / Incisional Hernia Repair | `umbilical-ventral-incisional-hernia-repair` | Present |
| Wound Debridement | `wound-debridement` | Present |
| EGD (Upper Endoscopy) | `egd-upper-endoscopy` | Present |
| ERCP (Endoscopic Retrograde Cholangiopancreatography) | `ercp-endoscopic-retrograde-cholangiopancreatography` | Present |
| Cervical Cerclage | `cervical-cerclage` | Present |
| Cervical Cone Biopsy / LEEP | `cervical-cone-biopsy-leep` | Present |
| Dilation and Curettage (D&C) | `dilation-and-curettage-d-c` | Present |
| Endometrial Ablation | `endometrial-ablation` | Present |
| Gynecologic Oncology Staging Laparotomy | `gynecologic-oncology-staging-laparotomy` | Present |
| Hysteroscopy | `hysteroscopy` | Present |
| Laparoscopic Hysterectomy (TLH / LSH) | `laparoscopic-hysterectomy-tlh-lsh` | Present |
| Laparoscopic Ovarian Cystectomy / Oophorectomy | `laparoscopic-ovarian-cystectomy-oophorectomy` | Present |
| Myomectomy (Open / Laparoscopic) | `myomectomy-open-laparoscopic` | Present |
| Ovarian Cancer Debulking (Cytoreductive Surgery) | `ovarian-cancer-debulking-cytoreductive-surgery` | Present |
| Pelvic Organ Prolapse Repair / Colporrhaphy | `pelvic-organ-prolapse-repair-colporrhaphy` | Present |
| Postpartum Tubal Ligation | `postpartum-tubal-ligation` | Present |
| Robotic Hysterectomy | `robotic-hysterectomy` | Present |
| Robotic Myomectomy | `robotic-myomectomy` | Present |
| Sacrocolpopexy (Open / Robotic) | `sacrocolpopexy-open-robotic` | Present |
| Salpingectomy / Ectopic Pregnancy Surgery | `salpingectomy-ectopic-pregnancy-surgery` | Present |
| Total Abdominal Hysterectomy (TAH) | `total-abdominal-hysterectomy-tah` | Present |
| Vaginal Hysterectomy (VH) | `vaginal-hysterectomy-vh` | Present |
| Vulvar / Vaginal Procedures (Excision / Repair) | `vulvar-vaginal-procedures-excision-repair` | Present |
| Cubital Tunnel Release | `cubital-tunnel-release` | Present |
| Digit Amputation / Ray Resection | `digit-amputation-ray-resection` | Present |
| Dupuytren Contracture Release | `dupuytren-contracture-release` | Present |
| Ganglion Cyst Excision | `ganglion-cyst-excision` | Present |
| Hand Infection Incision and Drainage (Felon / Flexor Tenosynovitis) | `hand-infection-incision-and-drainage-felon-flexor-tenosynovitis` | Present |
| Nerve Repair (Digital / Peripheral) | `nerve-repair-digital-peripheral` | Present |
| Tendon Repair (Hand / Wrist) | `tendon-repair-hand-wrist` | Present |
| Hepatic Resection (Open / Laparoscopic) | `hepatic-resection-open-laparoscopic` | Present |
| Liver Transplant | `liver-transplant` | Present |
| Open Cholecystectomy | `open-cholecystectomy` | Present |
| Whipple Procedure (Pancreaticoduodenectomy) | `whipple-procedure-pancreaticoduodenectomy` | Present |
| ACDF (Anterior Cervical Discectomy and Fusion) | `acdf-anterior-cervical-discectomy-and-fusion` | Present |
| AVM Embolization (Endovascular) | `avm-embolization-endovascular` | Present |
| Awake Craniotomy | `awake-craniotomy` | Present |
| Burr Holes (Exploratory / Therapeutic) | `burr-holes-exploratory-therapeutic` | Present |
| Cervical Laminectomy / Laminoplasty | `cervical-laminectomy-laminoplasty` | Present |
| Craniotomy for Brain Tumor | `craniotomy-for-brain-tumor` | Present |
| Craniotomy for Cerebral Aneurysm (Clipping) | `craniotomy-for-cerebral-aneurysm-clipping` | Present |
| Craniotomy for Traumatic Brain Injury (TBI) | `craniotomy-for-traumatic-brain-injury-tbi` | Present |
| Deep Brain Stimulator (DBS) Placement | `deep-brain-stimulator-dbs-placement` | Present |
| Epilepsy Surgery (Temporal Lobectomy / Cortical Resection) | `epilepsy-surgery-temporal-lobectomy-cortical-resection` | Present |
| External Ventricular Drain (EVD) Placement | `external-ventricular-drain-evd-placement` | Present |
| Intracranial Aneurysm Coiling (Endovascular) | `intracranial-aneurysm-coiling-endovascular` | Present |
| Lumbar Laminectomy / Decompression | `lumbar-laminectomy-decompression` | Present |
| Mechanical Thrombectomy for Ischemic Stroke | `mechanical-thrombectomy-for-ischemic-stroke` | Present |
| MEP Monitoring — Anesthesia Considerations | `mep-monitoring-anesthesia-considerations` | Present |
| Neuro-Angiography / Cerebral Angiogram (Diagnostic) | `neuro-angiography-cerebral-angiogram-diagnostic` | Present |
| Spinal Cord Stimulator (SCS) Implantation | `spinal-cord-stimulator-scs-implantation` | Present |
| Spinal Fusion (TLIF/PLIF) | `spinal-fusion-tlif-plif` | Present |
| SSEP Monitoring — Anesthesia Considerations | `ssep-monitoring-anesthesia-considerations` | Present |
| Subdural / Epidural Hematoma Evacuation | `subdural-epidural-hematoma-evacuation` | Present |
| TLIF / OLIF / ALIF (Lumbar Interbody Fusion) | `tlif-olif-alif-lumbar-interbody-fusion` | Present |
| Transsphenoidal Pituitary Surgery (TSPS / Endoscopic) | `transsphenoidal-pituitary-surgery-tsps-endoscopic` | Present |
| Ventriculoperitoneal (VP) Shunt Placement / Revision | `ventriculoperitoneal-vp-shunt-placement-revision` | Present |
| Electroconvulsive Therapy (ECT) | `electroconvulsive-therapy-ect` | Present |
| ICU Bedside Procedures Under Anesthesia / Sedation | `icu-bedside-procedures-under-anesthesia-sedation` | Present |
| MRI Under Anesthesia (Adult) | `mri-under-anesthesia-adult` | Present |
| Radiation Oncology Anesthesia (SBRT / SRS / Proton) (Adult) | `radiation-oncology-anesthesia-sbrt-srs-proton-adult` | Present |
| Cesarean Section (Elective) | `cesarean-section-elective` | Present |
| Epidural Blood Patch | `epidural-blood-patch` | Present |
| External Cephalic Version (ECV) | `external-cephalic-version-ecv` | Present |
| High-Risk Obstetric Anesthesia — Cardiac Disease in Pregnancy | `high-risk-obstetric-anesthesia-cardiac-disease-in-pregnancy` | Present |
| Labor Epidural Placement | `labor-epidural-placement` | Present |
| Placenta Accreta Spectrum (PAS) — Cesarean Hysterectomy | `placenta-accreta-spectrum-pas-cesarean-hysterectomy` | Present |
| Postpartum Hemorrhage Management | `postpartum-hemorrhage-management` | Present |
| Preeclampsia / Severe Preeclampsia — Anesthesia Management | `preeclampsia-severe-preeclampsia-anesthesia-management` | Present |
| Urgent/Emergent C-Section (Category 1 & 2) | `urgent-emergent-c-section-category-1-2` | Present |
| Blepharoplasty (Upper / Lower Eyelid) | `blepharoplasty-upper-lower-eyelid` | Present |
| Cataract Surgery (Phacoemulsification) | `cataract-surgery-phacoemulsification` | Present |
| Eye Trauma Repair (Open Globe) | `eye-trauma-repair-open-globe` | Present |
| Retinal Detachment Repair (Vitrectomy/Scleral Buckle) | `retinal-detachment-repair-vitrectomy-scleral-buckle` | Present |
| Strabismus Repair (Adult) | `strabismus-repair-adult` | Present |
| ACL Reconstruction | `acl-reconstruction` | Present |
| Ankle ORIF | `ankle-orif` | Present |
| Carpal Tunnel Release | `carpal-tunnel-release` | Present |
| Distal Radius ORIF | `distal-radius-orif` | Present |
| External Fixator Placement | `external-fixator-placement` | Present |
| Hardware Removal | `hardware-removal` | Present |
| Hip Fracture Repair (ORIF/Hemiarthroplasty) | `hip-fracture-repair-orif-hemiarthroplasty` | Present |
| Irrigation and Debridement (I&D) of Joint / Wound | `irrigation-and-debridement-i-d-of-joint-wound` | Present |
| Knee Arthroscopy | `knee-arthroscopy` | Present |
| Laminectomy (Lumbar / Cervical) | `laminectomy-lumbar-cervical` | Present |
| Long Bone ORIF (Tibia / Femur / Humerus) | `long-bone-orif-tibia-femur-humerus` | Present |
| Lower Extremity Amputation (Orthopedic) — Toe / Ray / Transmetatarsal | `lower-extremity-amputation-orthopedic-toe-ray-transmetatarsal` | Present |
| Lumbar Discectomy / Microdiscectomy | `lumbar-discectomy-microdiscectomy` | Present |
| Pelvic Fracture Fixation | `pelvic-fracture-fixation` | Present |
| Rotator Cuff Repair (Arthroscopic) | `rotator-cuff-repair-arthroscopic` | Present |
| Scoliosis Correction (Posterior Spinal Fusion with Instrumentation) (Adult) | `scoliosis-correction-posterior-spinal-fusion-with-instrumentation-adult` | Present |
| Shoulder Arthroplasty (Total or Reverse) | `shoulder-arthroplasty-total-or-reverse` | Present |
| Shoulder Arthroscopy | `shoulder-arthroscopy` | Present |
| Spine Fusion (Posterior / TLIF / ALIF) | `spine-fusion-posterior-tlif-alif` | Present |
| Total Hip Arthroplasty (THA) | `total-hip-arthroplasty-tha` | Present |
| Total Knee Arthroplasty (TKA) | `total-knee-arthroplasty-tka` | Present |
| Trigger Finger Release | `trigger-finger-release` | Present |
| Abdominoplasty (Tummy Tuck) | `abdominoplasty-tummy-tuck` | Present |
| Breast Reconstruction (Implant-Based) | `breast-reconstruction-implant-based` | Present |
| Burn Reconstruction | `burn-reconstruction` | Present |
| Complex Wound Closure / Debridement | `complex-wound-closure-debridement` | Present |
| Craniofacial Reconstruction (Adult) | `craniofacial-reconstruction-adult` | Present |
| DIEP / Free Flap Breast Reconstruction | `diep-free-flap-breast-reconstruction` | Present |
| Facelift (Rhytidectomy) | `facelift-rhytidectomy` | Present |
| Gender-Affirming Reconstructive Surgery | `gender-affirming-reconstructive-surgery` | Present |
| Hand / Digit Flap Coverage | `hand-digit-flap-coverage` | Present |
| Local Flap / Rotational Flap Coverage | `local-flap-rotational-flap-coverage` | Present |
| Panniculectomy | `panniculectomy` | Present |
| Pressure Ulcer Flap Reconstruction | `pressure-ulcer-flap-reconstruction` | Present |
| Rhinoplasty | `rhinoplasty` | Present |
| Scar Revision | `scar-revision` | Present |
| Split-Thickness / Full-Thickness Skin Graft | `split-thickness-full-thickness-skin-graft` | Present |
| Tissue Expander Placement | `tissue-expander-placement` | Present |
| Damage Control Laparotomy | `damage-control-laparotomy` | Present |
| Emergency Thoracotomy (Resuscitative / Trauma) | `emergency-thoracotomy-resuscitative-trauma` | Present |
| Exploratory Laparotomy (Trauma) | `exploratory-laparotomy-trauma` | Present |
| Fasciotomy (Lower Extremity) | `fasciotomy-lower-extremity` | Present |
| Artificial Urinary Sphincter (AUS) Implantation | `artificial-urinary-sphincter-aus-implantation` | Present |
| Cystoscopy (Diagnostic / Flexible / Rigid) | `cystoscopy-diagnostic-flexible-rigid` | Present |
| Hydrocelectomy / Varicocelectomy | `hydrocelectomy-varicocelectomy` | Present |
| Kidney Transplant | `kidney-transplant` | Present |
| Laser Lithotripsy (Holmium / Thulium Laser) | `laser-lithotripsy-holmium-thulium-laser` | Present |
| Nephrectomy (Open / Laparoscopic) | `nephrectomy-open-laparoscopic` | Present |
| Orchiectomy (Radical / Simple) | `orchiectomy-radical-simple` | Present |
| Orchiopexy (Adult) | `orchiopexy-adult` | Present |
| Partial Nephrectomy (Open / Robotic / Laparoscopic) | `partial-nephrectomy-open-robotic-laparoscopic` | Present |
| Penile Prosthesis Implantation | `penile-prosthesis-implantation` | Present |
| Percutaneous Nephrolithotomy (PCNL) | `percutaneous-nephrolithotomy-pcnl` | Present |
| Prostate Biopsy (TRUS / MRI-Fusion) | `prostate-biopsy-trus-mri-fusion` | Present |
| Pyeloplasty (Open / Robotic) | `pyeloplasty-open-robotic` | Present |
| Radical Cystectomy with Urinary Diversion | `radical-cystectomy-with-urinary-diversion` | Present |
| Robot-Assisted Prostatectomy (RALP) | `robot-assisted-prostatectomy-ralp` | Present |
| Robotic Nephrectomy (Partial or Radical) | `robotic-nephrectomy-partial-or-radical` | Present |
| Suprapubic Tube (SPT) Placement | `suprapubic-tube-spt-placement` | Present |
| TURBT (Transurethral Resection of Bladder Tumor) | `turbt-transurethral-resection-of-bladder-tumor` | Present |
| TURP (Transurethral Resection of the Prostate) | `turp-transurethral-resection-of-the-prostate` | Present |
| Ureteral Stent Placement / Removal | `ureteral-stent-placement-removal` | Present |
| Ureteroscopy (URS) | `ureteroscopy-urs` | Present |
| Urethral Dilation / Stricture Repair | `urethral-dilation-stricture-repair` | Present |
| AV Fistula Creation / Revision | `av-fistula-creation-revision` | Present |
| Carotid Artery Stenting (CAS) — Anesthesia Support | `carotid-artery-stenting-cas-anesthesia-support` | Present |
| Carotid Endarterectomy (CEA) | `carotid-endarterectomy-cea` | Present |
| Dialysis Graft Placement | `dialysis-graft-placement` | Present |
| Embolectomy / Thrombectomy (Peripheral) | `embolectomy-thrombectomy-peripheral` | Present |
| Endovascular Aortic Repair (EVAR) | `endovascular-aortic-repair-evar` | Present |
| Femoral-Popliteal Bypass | `femoral-popliteal-bypass` | Present |
| Iliac Artery Bypass / Aortobifemoral Bypass | `iliac-artery-bypass-aortobifemoral-bypass` | Present |
| Lower Extremity Amputation (BKA / AKA) | `lower-extremity-amputation-bka-aka` | Present |
| Mesenteric Revascularization (Open / Endovascular) | `mesenteric-revascularization-open-endovascular` | Present |
| Open AAA Repair (Elective) | `open-aaa-repair-elective` | Present |
| Peripheral Angiogram / Diagnostic Arteriogram | `peripheral-angiogram-diagnostic-arteriogram` | Present |
| Peripheral Angioplasty / Arterial Stenting | `peripheral-angioplasty-arterial-stenting` | Present |
| Ruptured Abdominal Aortic Aneurysm (rAAA) | `ruptured-abdominal-aortic-aneurysm-raaa` | Present |
| Varicose Vein Procedures (EVLA / Phlebectomy / Stripping) | `varicose-vein-procedures-evla-phlebectomy-stripping` | Present |
| Laparoscopic cholecystectomy | `laparoscopic-cholecystectomy` | Present, manual reference unchanged |

## Review gates retained

Clinical review remains pending, including the original register’s specialist-review priorities for LVAD, ECMO and lesion-specific cardiac disease in pregnancy. Earlier numerical flags and evidence-gap notes are not silently marked complete. Adult-only scope remains; this work neither creates a pediatric IAP nor changes subscription entitlements. Production activation, native/offline acceptance, Supabase publication and TestFlight/App Store release are separate and have not been performed by this batch.
