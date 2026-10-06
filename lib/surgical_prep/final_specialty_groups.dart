// Canonical clinical references, grouped without duplicate case records.
const surgicalFinalSpecialtyGroups = <String, Map<String, List<String>>>{
  "NORA & procedures": {
    "Planning & rescue": [
      "nora-clinical-framework",
      "nora-emergency-response",
      "icu-bedside-procedures-under-anesthesia-sedation",
    ],
    "Imaging & radiation": [
      "mri-under-anesthesia-adult",
      "radiation-oncology-anesthesia-sbrt-srs-proton-adult",
      "brachytherapy-adult",
    ],
    "Brief therapeutic anesthesia": [
      "electroconvulsive-therapy-ect",
      "extracorporeal-shock-wave-lithotripsy",
    ],
    "Pulmonary diagnostics": ["ebus-tbna"],
    "Interventional radiology": [
      "ir-hemorrhage-embolization",
      "image-guided-liver-renal-ablation",
      "lung-tumor-ablation",
      "ct-guided-biopsy",
      "percutaneous-nephrostomy",
      "image-guided-abscess-drainage",
    ],
  },
  "Ophthalmology": {
    "Planning & safety": [
      "ophthalmology-clinical-framework",
      "ophthalmic-block-safety",
    ],
    "Anterior segment": [
      "cataract-surgery-phacoemulsification",
      "glaucoma-surgery",
    ],
    "Retina & cornea": [
      "retinal-detachment-repair-vitrectomy-scleral-buckle",
      "corneal-transplant-keratoplasty",
    ],
    "Extraocular & orbital": [
      "strabismus-repair-adult",
      "orbital-surgery",
      "enucleation-evisceration",
    ],
    "Trauma & emergencies": [
      "eye-trauma-repair-open-globe",
      "ophthalmic-emergency-response",
    ],
    "Lacrimal & eyelid": [
      "dacryocystorhinostomy",
      "blepharoplasty-upper-lower-eyelid",
    ],
  },
  "Plastic & reconstructive": {
    "Microsurgery & flap rescue": [
      "free-flap-anesthesia-framework",
      "head-neck-free-flap-reconstruction",
      "free-flap-compromise-rescue",
    ],
    "Breast reconstruction": [
      "pedicled-breast-flaps-tram-latissimus",
      "breast-reduction-mammoplasty",
      "breast-reconstruction-implant-based",
      "diep-free-flap-breast-reconstruction",
      "tissue-expander-placement",
    ],
    "Hand & limb reconstruction": [
      "digit-limb-replantation",
      "hand-digit-flap-coverage",
    ],
    "Body contouring & facial surgery": [
      "liposuction-fat-grafting",
      "abdominoplasty-tummy-tuck",
      "facelift-rhytidectomy",
      "gender-affirming-reconstructive-surgery",
      "panniculectomy",
      "rhinoplasty",
    ],
    "Grafts, wounds & local flaps": [
      "burn-reconstruction",
      "complex-wound-closure-debridement",
      "local-flap-rotational-flap-coverage",
      "pressure-ulcer-flap-reconstruction",
      "scar-revision",
      "split-thickness-full-thickness-skin-graft",
    ],
    "Craniofacial reconstruction": ["craniofacial-reconstruction-adult"],
    "Related canonical references": [
      "maxillofacial-trauma-surgery-panfacial-fractures",
      "burn-contracture-release-reconstruction",
    ],
  },
  "Trauma": {
    "Resuscitation & hemorrhage": [
      "polytrauma-anesthesia-framework",
      "trauma-massive-hemorrhage",
      "pelvic-trauma-hemorrhage",
      "damage-control-laparotomy",
      "exploratory-laparotomy-trauma",
    ],
    "Chest, neck & spinal injury": [
      "chest-trauma-anesthesia",
      "acute-spinal-cord-injury-trauma",
      "penetrating-neck-trauma",
      "emergency-thoracotomy-resuscitative-trauma",
    ],
    "Extremity injury & reperfusion": [
      "crush-injury-rhabdomyolysis",
      "fasciotomy-lower-extremity",
    ],
    "Related canonical references": [
      "craniotomy-for-traumatic-brain-injury-tbi",
      "maxillofacial-trauma-surgery-panfacial-fractures",
      "eye-trauma-repair-open-globe",
      "burn-wound-debridement-excision",
      "pelvic-fracture-fixation",
      "long-bone-orif-tibia-femur-humerus",
      "lower-extremity-amputation-bka-aka",
      "digit-limb-replantation",
    ],
  },
  "Urology": {
    "Planning & emergencies": [
      "urology-anesthesia-framework",
      "urologic-trauma-anesthesia",
    ],
    "Scrotal & genital surgery": [
      "testicular-torsion-adult",
      "hydrocelectomy-varicocelectomy",
      "orchiectomy-radical-simple",
      "orchiopexy-adult",
      "penile-prosthesis-implantation",
    ],
    "Lower tract & endoscopic surgery": [
      "artificial-urinary-sphincter-aus-implantation",
      "cystoscopy-diagnostic-flexible-rigid",
      "prostate-biopsy-trus-mri-fusion",
      "suprapubic-tube-spt-placement",
      "turbt-transurethral-resection-of-bladder-tumor",
      "turp-transurethral-resection-of-the-prostate",
      "urethral-dilation-stricture-repair",
    ],
    "Renal surgery & transplant": [
      "kidney-transplant",
      "nephrectomy-open-laparoscopic",
      "partial-nephrectomy-open-robotic-laparoscopic",
      "pyeloplasty-open-robotic",
      "robotic-nephrectomy-partial-or-radical",
    ],
    "Stones & drainage": [
      "laser-lithotripsy-holmium-thulium-laser",
      "percutaneous-nephrolithotomy-pcnl",
      "ureteral-stent-placement-removal",
      "ureteroscopy-urs",
    ],
    "Major pelvic & robotic surgery": [
      "radical-cystectomy-with-urinary-diversion",
      "robot-assisted-prostatectomy-ralp",
    ],
    "Related canonical references": [
      "extracorporeal-shock-wave-lithotripsy",
      "percutaneous-nephrostomy",
      "adrenalectomy-laparoscopic-robotic",
      "pheochromocytoma-resection",
    ],
  },
  "Vascular": {
    "Planning & perfusion": ["vascular-anesthesia-framework"],
    "Aortic surgery": [
      "thoracoabdominal-aortic-repair",
      "endovascular-aortic-repair-evar",
      "iliac-artery-bypass-aortobifemoral-bypass",
      "open-aaa-repair-elective",
      "ruptured-abdominal-aortic-aneurysm-raaa",
    ],
    "Dialysis access": [
      "av-fistula-creation-revision",
      "dialysis-graft-placement",
    ],
    "Carotid interventions": [
      "carotid-artery-stenting-cas-anesthesia-support",
      "carotid-endarterectomy-cea",
    ],
    "Limb & visceral circulation": [
      "embolectomy-thrombectomy-peripheral",
      "femoral-popliteal-bypass",
      "lower-extremity-amputation-bka-aka",
      "mesenteric-revascularization-open-endovascular",
      "peripheral-angiogram-diagnostic-arteriogram",
      "peripheral-angioplasty-arterial-stenting",
    ],
    "Venous procedures": [
      "varicose-vein-procedures-evla-phlebectomy-stripping",
    ],
    "Related canonical references": [
      "aortic-root-ascending-aorta-repair",
      "thoracic-aortic-aneurysm-repair-tevar-open-descending",
    ],
  },
};
