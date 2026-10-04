/// Adult regional references adapted from the Base44 topic inventory.
/// Clinical publication requires owner review. No patient-specific calculator.
class RegionalSource {
  const RegionalSource(this.label, this.url);
  final String label, url;
}

const regionalSources = <String, RegionalSource>{
  'is': RegionalSource(
    'NYSORA · Interscalene',
    'https://www.nysora.com/regional-anesthesia/techniques/ultrasound-guided-interscalene-brachial-plexus-block/',
  ),
  'sc': RegionalSource(
    'NYSORA · Supraclavicular',
    'https://www.nysora.com/regional-anesthesia/techniques/ultrasound-guided-supraclavicular-brachial-plexus-block/',
  ),
  'ic': RegionalSource(
    'NYSORA · Infraclavicular',
    'https://www.nysora.com/regional-anesthesia/techniques/ultrasound-guided-infraclavicular-brachial-plexus-block/',
  ),
  'ax': RegionalSource(
    'NYSORA · Axillary',
    'https://www.nysora.com/regional-anesthesia/techniques/ultrasound-guided-axillary-brachial-plexus-block/',
  ),
  'fn': RegionalSource(
    'NYSORA · Femoral',
    'https://www.nysora.com/regional-anesthesia/techniques/ultrasound-guided-femoral-nerve-block/',
  ),
  'ac': RegionalSource(
    'NYSORA · Saphenous / adductor canal',
    'https://www.nysora.com/regional-anesthesia/techniques/ultrasound-guided-saphenous-subsartorius-adductor-canal-nerve-block/',
  ),
  'ps': RegionalSource(
    'NYSORA · Popliteal sciatic',
    'https://www.nysora.com/regional-anesthesia/techniques/ultrasound-guided-popliteal-sciatic-block/',
  ),
  'tap': RegionalSource(
    'NYSORA · TAP and quadratus lumborum',
    'https://www.nysora.com/regional-anesthesia/techniques/ultrasound-guided-transversus-abdominis-plane-quadratus-lumborum-blocks/',
  ),
  'esp': RegionalSource(
    'NYSORA · Erector spinae plane',
    'https://www.nysora.com/regional-anesthesia/techniques/erector-spinae-plane-block/',
  ),
  'peng': RegionalSource(
    'Healthcare · PENG anatomy and quadriceps weakness',
    'https://pmc.ncbi.nlm.nih.gov/articles/PMC9408030/',
  ),
  'ipack': RegionalSource(
    'NYSORA · iPACK technique and role',
    'https://nysora.com/education-news/tips-for-the-ipack-block/',
  ),
  'ipack-risk': RegionalSource(
    'Brazilian Journal of Anesthesiology · iPACK motor outcomes',
    'https://pmc.ncbi.nlm.nih.gov/articles/PMC9373452/',
  ),
  'spinal': RegionalSource(
    'NYSORA · Spinal anesthesia',
    'https://nysora.com/regional-anesthesia/techniques/spinal-anesthesia-2/',
  ),
  'epidural': RegionalSource(
    'NYSORA · Epidural anesthesia and analgesia',
    'https://www.nysora.com/regional-anesthesia/techniques/epidural-anesthesia-analgesia/',
  ),
  'asra': RegionalSource(
    'ASRA · Antithrombotic guideline, fifth edition',
    'https://rapm.bmj.com/content/early/2025/01/21/rapm-2024-105766',
  ),
  'infection': RegionalSource(
    'ASRA · Infection control guideline, 2025',
    'https://doi.org/10.1136/rapm-2024-105651',
  ),
  'nerve': RegionalSource(
    'ASRA · Second neurologic complications advisory',
    'https://rapm.bmj.com/content/rapm/40/5/401.full.pdf',
  ),
  'last': RegionalSource(
    'ASRA · LAST cognitive aid, 2020',
    'https://asra.com/docs/default-source/guidelines-articles/local-anesthetic-systemic-toxicity-rgb.pdf?sfvrsn=33b348e_2',
  ),
  'exparel': RegionalSource(
    'EXPAREL · US prescribing information',
    'https://www.exparel.com/prescribing-information.pdf',
  ),
};

class RegionalSection {
  const RegionalSection(this.title, this.bullets, this.sources);
  final String title;
  final List<String> bullets, sources;
}

class RegionalTopic {
  const RegionalTopic(
    this.id,
    this.title,
    this.category,
    this.summary,
    this.aliases,
    this.sections, {
    this.related = const [],
  });
  final String id, title, category, summary, aliases;
  final List<RegionalSection> sections;
  final List<String> related;
  String get route => '/regional-procedures/$id';
}

const regionalCategories = [
  'All',
  'Safety & medications',
  'Upper extremity',
  'Lower extremity',
  'Truncal',
  'Neuraxial',
  'Planning & recovery',
];

const regionalTopics = <RegionalTopic>[
  RegionalTopic(
    'safety',
    'Regional safety essentials',
    'Safety & medications',
    'Patient selection, monitoring, sedation, and injection safeguards.',
    'consent contraindications ultrasound pressure paresthesia screening',
    [
      RegionalSection(
        'Selection is a risk–benefit decision',
        [
          'Match the technique to the operation, expected sensory territory, pulmonary reserve, neurologic baseline, and ability to tolerate sympathectomy or motor block.',
          'Document preexisting sensory or motor findings and discuss incomplete block, nerve injury, and alternative anesthesia plans. Existing neuropathy calls for individualized assessment, not automatic clearance or automatic exclusion.',
          'Review antithrombotic therapy and infection risk before needle placement and again before catheter removal. Ultrasound guidance does not waive those precautions.',
        ],
        ['nerve', 'asra', 'infection'],
      ),
      RegionalSection(
        'Monitoring and readiness',
        [
          'Establish appropriate monitoring and IV access; have trained help, airway equipment, cardiovascular support, and a LAST rescue kit immediately available.',
          'Use ultrasound to identify nerves, vessels, pleura, and the intended fascial plane. Visualization reduces uncertainty but cannot guarantee safe needle placement or eliminate nerve injury.',
          'Avoid routine deep sedation or general anesthesia for adult block placement when it prevents reporting unusual symptoms. Document a specific risk–benefit rationale when an exception is appropriate.',
        ],
        ['spinal', 'nerve', 'last'],
      ),
      RegionalSection(
        'Injection warning signs',
        [
          'Severe paresthesia, pain on injection, unexpected resistance, or an unclear needle tip should prompt stopping and reassessment rather than forceful injection.',
          'Use repeated aspiration, incremental injection, and observation of spread as complementary safeguards. No single maneuver excludes intravascular or intraneural placement.',
          'A pressure reading is not a guarantee of safety. Neither a painless injection nor reassuring ultrasound alone rules out nerve injury.',
        ],
        ['nerve', 'ax', 'ic'],
      ),
    ],
    related: ['anticoagulation', 'infection', 'last', 'neurologic-injury'],
  ),
  RegionalTopic(
    'anticoagulation',
    'Antithrombotics & catheter timing',
    'Safety & medications',
    'Separate placement, removal, and postoperative dosing.',
    'ASRA apixaban Eliquis rivaroxaban Xarelto dabigatran Pradaxa enoxaparin Lovenox heparin warfarin clopidogrel aspirin hold restart INR',
    [
      RegionalSection(
        'How to use these intervals',
        [
          'These selected ASRA fifth-edition recommendations concern neuraxial and deep plexus/peripheral blocks. They are not a complete drug list or an automatic procedural-clearance tool.',
          'Determine the actual drug, indication, low- versus high-dose regimen, last administration, renal function, other hemostasis-altering drugs, and intended catheter plan. A reduced tablet strength may still represent a high-dose indication.',
          'For other peripheral techniques, assess compressibility, vascularity, and the consequences of bleeding. Do not substitute a generic “shorter hold is safe” rule.',
          'Placement/removal intervals and surgical hemostasis requirements must both be satisfied. Traumatic puncture and impaired clearance may require additional delay. Do not stop or restart prescribed therapy without a coordinated plan.',
        ],
        ['asra'],
      ),
      RegionalSection(
        'Apixaban',
        [
          'High dose: discontinue at least 72 hours before needle placement. Needle placement or catheter removal should precede the first postoperative dose by at least 24 hours.',
          'Low dose: discontinue at least 36 hours before needle placement. Needle placement or catheter removal should precede the first postoperative dose by at least 6 hours.',
          'If the interval is shorter, consult the guideline on drug-specific testing: residual apixaban <30 ng/mL or residual anti-Xa activity ≤0.1 IU/mL is suggested as acceptable. A routine normal PT/INR is not a substitute for the appropriate assay.',
          'Unexpected dosing with a catheter in place requires a separate withholding/testing plan before removal. After traumatic neuraxial puncture, the manufacturer recommends delaying the next apixaban dose 48 hours.',
        ],
        ['asra'],
      ),
      RegionalSection(
        'Rivaroxaban',
        [
          'High dose: hold at least 72 hours; needle placement or catheter removal at least 24 hours before the first postoperative dose.',
          'Low dose: hold at least 24 hours, or 30 hours when CrCl <30 mL/min; needle placement or catheter removal at least 6 hours before the first postoperative dose.',
          'The guideline allows consideration of a drug-specific level <30 ng/mL or residual anti-Xa activity ≤0.1 IU/mL. Confirm assay availability and applicability rather than using an uncalibrated result.',
          'After traumatic neuraxial puncture, the manufacturer recommends delaying the next rivaroxaban dose 24 hours. Unexpected dosing with an indwelling catheter requires reassessment before removal.',
        ],
        ['asra'],
      ),
      RegionalSection(
        'Dabigatran',
        [
          'High dose: hold at least 72 hours with CrCl ≥50 mL/min, or 120 hours with CrCl 30–49 mL/min. Needle placement/removal should be at least 24 hours before the first postoperative dose.',
          'Low dose: hold at least 48 hours; needle placement/removal at least 6 hours before the first postoperative dose.',
          'For CrCl <30 mL/min, ASRA suggests avoiding neuraxial/deep plexus blocks unless a measured dabigatran level is <30 ng/mL. Shortened intervals and unexpected dosing need the full assay-based guidance.',
        ],
        ['asra'],
      ),
      RegionalSection(
        'LMWH: placement is not the restart interval',
        [
          'Wait at least 12 hours after low-dose LMWH and at least 24 hours after high-dose LMWH before needle placement. Renal impairment and advanced age may prolong effect; consult the guideline regarding residual anti-Xa assessment.',
          'Twice-daily low-dose postoperative LMWH: first dose the following day and at least 12 hours after placement. Remove the catheter before initiating LMWH; wait at least 4 hours after removal to administer it.',
          'Once-daily low-dose postoperative LMWH: first dose at least 12 hours after placement; second dose no sooner than 24 hours after the first. If a catheter remains, avoid additional hemostasis-altering drugs. Remove at least 12 hours after the last dose and wait at least 4 hours before the next.',
          'High-dose postoperative LMWH: generally resume 24 hours after non-high-bleeding-risk surgery or 48–72 hours after high-bleeding-risk surgery. Remove the catheter at least 4 hours before the first dose; that dose must also be at least 24 hours after needle/catheter placement, whichever is later.',
        ],
        ['asra'],
      ),
      RegionalSection(
        'UFH and warfarin',
        [
          'IV UFH: stop the infusion for at least 4–6 hours and confirm normal coagulation status before placement. Delay IV heparin at least 1 hour after needle placement; catheter management requires its own guideline-based plan.',
          'Low-dose subcutaneous UFH, 5,000 units twice or three times daily: placement at least 4–6 hours after administration or assessment of normal coagulation status. With postoperative low-dose UFH, removal is at least 4–6 hours after a dose; subsequent UFH may be immediate.',
          'Higher subcutaneous UFH regimens need longer intervals. Check platelets with UFH exposure beyond 4 days because of HIT risk; do not apply low-dose timing to higher-dose regimens.',
          'Warfarin: stop at least 5 days before placement and confirm INR has normalized to the local laboratory range. Catheter removal is recommended with INR <1.5; this removal threshold is not the insertion criterion. Continue neurologic assessment for at least 48 hours after removal.',
        ],
        ['asra'],
      ),
      RegionalSection(
        'Aspirin and P2Y12 inhibitors',
        [
          'Aspirin/NSAIDs alone have no ASRA-specific timing restriction for these regional techniques. Combination therapy or another coagulopathy changes the risk assessment.',
          'Before placement: clopidogrel 5–7 days; prasugrel 7–10 days; ticagrelor 5 days. Coordinate interruption carefully, especially after coronary stenting.',
          'Do not treat all antiplatelets alike. Catheter maintenance and loading-dose restart rules differ; prasugrel/ticagrelor are not compatible with routine indwelling neuraxial catheter maintenance.',
          'For clopidogrel, prasugrel, or ticagrelor, resumption may be immediate after placement/removal if no loading dose is given. If a loading dose is given, ASRA suggests 6 hours after catheter removal. Surgical hemostasis may require a longer delay.',
        ],
        ['asra'],
      ),
    ],
    related: ['epidural', 'spinal', 'neurologic-injury'],
  ),
  RegionalTopic(
    'infection',
    'Asepsis & regional catheter infection',
    'Safety & medications',
    'Preparation, ultrasound barriers, and early recognition.',
    'sterile chlorhexidine sepsis bacteremia epidural abscess catheter fever',
    [
      RegionalSection(
        'Preparation and equipment',
        [
          'Use hand hygiene, appropriate cap/mask, sterile gloves, sterile draping, and procedure-appropriate skin antisepsis. ASRA favors chlorhexidine-based preparations when appropriate; follow product and facility instructions and allow adequate drying.',
          'Keep antiseptic solution away from needles, injectate, and neuraxial equipment. Allergy, product labeling, and the intended procedure may require an alternative preparation.',
          'Clean/disinfect the ultrasound transducer before and after use. Use a single-use sterile cover and sterile gel for regional procedures; continuous catheter insertion requires a long sterile sheath protecting the adjacent cable.',
          'A probe cover does not replace cleaning and disinfection. Match barriers and disinfection level to the procedure and any indwelling device.',
        ],
        ['infection'],
      ),
      RegionalSection(
        'Infection and patient selection',
        [
          'Do not pass a needle through infected skin. A remote, localized, controlled infection does not have the same risk implications as untreated systemic infection.',
          'Selected single-injection blocks away from a well-controlled infection may be considered case by case. Continuous catheter safety in that setting is uncertain and is not preferred.',
          'For neuraxial techniques, systemic infection assessment includes treatment, hemodynamic stability, coagulation, and the risk of introducing organisms. Do not use a blanket “all sepsis is safe” or “all sepsis is identical” rule.',
        ],
        ['infection', 'spinal', 'epidural'],
      ),
      RegionalSection(
        'Catheter reassessment and red flags',
        [
          'Review ongoing need and signs of infection. Peripheral catheter use beyond 4–5 days warrants individualized risk–benefit assessment and careful monitoring rather than an automatic extension.',
          'Back pain, fever, new weakness, or altered sensation after neuraxial procedures may indicate epidural abscess; the classic triad is often absent.',
          'Suspected epidural abscess requires prompt imaging and urgent specialist involvement. MRI is preferred; use appropriate alternative imaging if waiting for MRI would delay diagnosis.',
        ],
        ['infection'],
      ),
    ],
    related: ['neurologic-injury', 'epidural', 'selection-recovery'],
  ),
  RegionalTopic(
    'local-anesthetics',
    'Local anesthetic selection & dose safety',
    'Safety & medications',
    'Total exposure, formulation, and practical safety limits.',
    'lidocaine bupivacaine ropivacaine mepivacaine chloroprocaine maximum dose concentration milligrams adjuvant dexamethasone',
    [
      RegionalSection(
        'Dose is more than a volume',
        [
          'Select the agent, concentration, total mass, and technique together. A volume used for an epidural, intrathecal injection, peripheral block, or infiltration is not interchangeable across routes.',
          'Account for all planned local anesthetic exposure, including bilateral blocks, surgeon infiltration, additional blocks, and catheter boluses/infusions. Toxicity is additive when local anesthetics are combined.',
          'This section deliberately does not provide a universal weight-based maximum-dose calculator. Use the specific product label, institutional protocol, patient factors, and the Drug Library rather than treating a generic limit as proof of safety.',
        ],
        ['epidural', 'spinal', 'exparel', 'tap'],
      ),
      RegionalSection(
        'Match the drug to the clinical goal',
        [
          'Concentration influences block density, while total dose, site, and distribution influence spread and duration. Choose differently for surgical anesthesia, analgesia, and a continuous infusion.',
          'Motor block can outlast the desired analgesic window. Consider recovery needs and safe mobilization rather than selecting solely for the longest possible block.',
          'For neuraxial administration, verify that the exact formulation and route are appropriate. Do not substitute a liposomal product for conventional bupivacaine or convert doses between them.',
          'Perineural adjuvants and mixtures require their own evidence, compatibility, route-labeling, and local-policy review. The legacy fixed adjuvant recipes are not carried forward as default orders.',
        ],
        ['epidural', 'spinal', 'ac', 'ps', 'exparel'],
      ),
      RegionalSection(
        'Risk reduction does not end after injection',
        [
          'Use incremental administration and observe the patient and spread. Repeated negative aspiration does not eliminate intravascular injection risk.',
          'Early CNS symptoms can include circumoral numbness, metallic taste, tinnitus, agitation, or seizures; cardiovascular toxicity can progress to instability or arrest.',
          'Keep the LAST response resource available wherever local anesthetics are administered. Sedation can make early symptoms harder to recognize.',
        ],
        ['exparel', 'nerve', 'last'],
      ),
    ],
    related: ['liposomal-bupivacaine', 'last', 'selection-recovery'],
  ),
  RegionalTopic(
    'liposomal-bupivacaine',
    'Liposomal bupivacaine: label boundaries',
    'Safety & medications',
    'Approved adult blocks, compatibility, and cumulative exposure.',
    'EXPAREL 133 266 milligrams liposome 96 hours admixture',
    [
      RegionalSection(
        'Adult label-supported regimens',
        [
          'Interscalene brachial plexus block: 133 mg. Sciatic nerve block in the popliteal fossa: 133 mg.',
          'Adductor canal block: 133 mg (10 mL) admixed with 50 mg (10 mL) of 0.5% bupivacaine HCl, total volume 20 mL, as described in the US label.',
          'Adult local infiltration: up to a maximum total dose of 266 mg, individualized to the surgical site and patient. This is not “266 mg per side” and is not a universal dose for fascial-plane blocks.',
          'Safety and effectiveness for regional analgesia using other nerve blocks have not been established in the label. TAP, QL, ESP, and PENG are not additional approved nerve-block indications in the cited label.',
        ],
        ['exparel'],
      ),
      RegionalSection(
        'Compatibility and timing',
        [
          'Do not admix with lidocaine or other non-bupivacaine local anesthetics. EXPAREL may follow local lidocaine administration after at least 20 minutes.',
          'When bupivacaine HCl is administered in the same syringe or immediately before EXPAREL, its milligram-dose ratio to EXPAREL must not exceed 1:2. Toxic effects remain additive.',
          'The label advises avoiding additional local anesthetics within 96 hours after administration. Follow the complete labeled perioperative regimen and reconcile all concurrent/local anesthetic exposure rather than interpreting isolated lines independently.',
          'Do not dilute with water or other hypotonic agents. It is not interchangeable with conventional bupivacaine and is not recommended for epidural, intrathecal, intravascular, or intra-articular administration.',
        ],
        ['exparel'],
      ),
      RegionalSection(
        'Handoff and follow-up',
        [
          'Communicate product, dose, site, time, and other local anesthetics administered to the receiving team. The label recommends cardiovascular, neurologic, and vital-sign monitoring during and after injection.',
          'Do not promise a guaranteed duration of analgesia or assume that a liposomal formulation eliminates the need for supplemental analgesia.',
        ],
        ['exparel'],
      ),
    ],
    related: ['local-anesthetics', 'last'],
  ),
  RegionalTopic(
    'last',
    'Local anesthetic systemic toxicity (LAST)',
    'Safety & medications',
    'Recognition and the ASRA rescue reference, not standard ACLS alone.',
    'lipid rescue intralipid seizure toxicity cardiovascular arrest emulsion',
    [
      RegionalSection(
        'Recognize and escalate',
        [
          'Stop local anesthetic administration when toxicity is suspected; call for help and obtain the LAST rescue kit. Support oxygenation/ventilation and circulation while preparing lipid rescue.',
          'CNS symptoms may progress from tinnitus, metallic taste, circumoral symptoms, or agitation to seizures; arrhythmia, hypotension, or arrest may occur. Do not require a classic prodrome before considering LAST.',
          'ASRA recommends considering lipid emulsion early and notifying a cardiopulmonary bypass team when appropriate. LAST resuscitation differs from conventional ACLS.',
        ],
        ['exparel', 'last'],
      ),
      RegionalSection(
        '20% lipid emulsion: ASRA cognitive-aid doses',
        [
          'Over 70 kg: bolus approximately 100 mL over 2–3 minutes; infuse approximately 250 mL over 15–20 minutes.',
          'Under 70 kg: bolus approximately 1.5 mL/kg over 2–3 minutes; infuse approximately 0.25 mL/kg/min. The aid suggests a pump when weight is under 40 kg.',
          'If instability persists: repeat the bolus and double the infusion. Continue lipid for more than 15 minutes after hemodynamic stability; maximum total lipid dose 12 mL/kg.',
          'Use the linked ASRA aid and local emergency protocol for dosing and execution. These are reference values, not an automated patient-specific calculation.',
        ],
        ['last'],
      ),
      RegionalSection(
        'Seizures and resuscitation differences',
        [
          'Ensure an adequate airway; benzodiazepines are preferred for seizures. If only propofol is available, the aid describes low doses, such as 20 mg increments; propofol is not a substitute for lipid emulsion.',
          'Use smaller-than-usual epinephrine doses; ASRA advises starting with less than 1 mcg/kg.',
          'Avoid additional local anesthetics, beta-blockers, calcium-channel blockers, and vasopressin during LAST resuscitation.',
        ],
        ['last'],
      ),
      RegionalSection(
        'Observation after stabilization',
        [
          'ASRA lists observation for 2 hours after seizure and 4–6 hours after cardiovascular instability, with monitoring as appropriate after cardiac arrest.',
          'Observation duration is individualized to the clinical course and setting; recurrent symptoms or instability require escalation rather than discharge at a preset timer.',
        ],
        ['last'],
      ),
    ],
    related: ['local-anesthetics', 'liposomal-bupivacaine'],
  ),
  RegionalTopic(
    'neurologic-injury',
    'Neurologic injury: prevention & escalation',
    'Safety & medications',
    'Baseline findings, warning signs, and urgent deficit evaluation.',
    'nerve injury neuropathy paresthesia epidural hematoma weakness foot drop MRI',
    [
      RegionalSection(
        'Before and during the block',
        [
          'Document preexisting neurologic findings and discuss the interaction of patient disease, surgery, positioning, tourniquet use, and regional anesthesia.',
          'With acquired neuropathy, ASRA advises considering lower local anesthetic concentration or dose and reducing/eliminating epinephrine as part of an individualized assessment.',
          'Stop needle movement/injection for severe paresthesia or pain and reassess. Ultrasound, nerve stimulation, and injection-pressure monitoring are complementary tools, not guarantees against injury.',
          'Maintain perfusion during neuraxial anesthesia; substantial or prolonged hypotension warrants correction rather than waiting for the block to regress.',
        ],
        ['nerve'],
      ),
      RegionalSection(
        'Do not label every deficit an expected block',
        [
          'Unexpectedly prolonged, recurrent, progressive, severe, or anatomically inconsistent weakness or sensory change needs assessment. Compare with the drug, expected duration, baseline examination, and surgical territory.',
          'New deficit after initial recovery is particularly concerning. Reduce or stop a local anesthetic infusion when appropriate while evaluating, but do not let serial reassessment delay imaging for a suspected compressive lesion.',
          'Suspected spinal cord dysfunction requires emergent neuroimaging and specialist evaluation. MRI is preferred; CT/CT myelography may be appropriate if MRI would delay exclusion of compression.',
        ],
        ['nerve'],
      ),
      RegionalSection(
        'Follow-up and documentation',
        [
          'Communicate the distribution, motor and sensory findings, progression, timing, anticoagulant exposure, and catheter status to the evaluating team.',
          'Peripheral deficits that are severe, progressive, or difficult to localize warrant neurologic evaluation. Electrodiagnostic testing often characterizes axonal injury best after about 3 weeks; that timing does not justify delaying an urgent clinical evaluation.',
          'Fever or back pain may indicate infection even without the full epidural-abscess triad. Arrange an explicit follow-up pathway rather than asking a patient simply to wait for numbness to fade.',
        ],
        ['nerve', 'infection'],
      ),
    ],
    related: ['infection', 'anticoagulation', 'selection-recovery'],
  ),
  RegionalTopic(
    'interscalene',
    'Interscalene brachial plexus block',
    'Upper extremity',
    'Shoulder coverage with important respiratory trade-offs.',
    'shoulder rotator cuff humerus C5 C6 phrenic diaphragm',
    [
      RegionalSection(
        'Useful coverage and limitations',
        [
          'Commonly used for shoulder and proximal upper-arm procedures. Coverage of C8–T1 is less reliable, so it is not a dependable stand-alone choice for hand or wrist surgery.',
          'Clavicular surgery may require additional cervical-plexus coverage. Match the actual incision and deeper structures rather than relying on the operation name alone.',
        ],
        ['is'],
      ),
      RegionalSection(
        'Anatomy and ultrasound orientation',
        [
          'Identify the brachial plexus between anterior and middle scalene muscles, lateral to the carotid artery and internal jugular vein.',
          'If identification is difficult, trace the plexus cephalad from the supraclavicular region. Use Doppler to identify vessels and maintain needle-tip visualization.',
          'The objective is appropriate perineural spread, not injection into a root. High resistance or a concerning needle–nerve relationship warrants stopping and repositioning.',
        ],
        ['is', 'nerve'],
      ),
      RegionalSection(
        'Respiratory and neurologic cautions',
        [
          'Hemidiaphragmatic paresis is common; incidence varies by technique and volume. Low-volume approaches may reduce but do not eliminate risk, and may compromise block reliability or duration.',
          'Limited pulmonary reserve, contralateral diaphragmatic dysfunction, and the consequences of bilateral diaphragmatic impairment materially affect selection.',
          'Horner syndrome or hoarseness can follow spread to adjacent structures. Assess breathing/airway symptoms rather than dismissing all such findings as harmless expected effects.',
        ],
        ['is'],
      ),
      RegionalSection(
        'Recovery and catheter planning',
        [
          'Plan postoperative respiratory observation according to patient risk and the technique. Continuous infusion can extend both analgesia and unwanted effects.',
          'Confirm catheter spread and function, monitor the insertion site, and provide instructions for an insensate arm and for new respiratory or neurologic symptoms.',
        ],
        ['is', 'infection', 'nerve'],
      ),
    ],
    related: ['safety', 'liposomal-bupivacaine', 'neurologic-injury'],
  ),
  RegionalTopic(
    'supraclavicular',
    'Supraclavicular brachial plexus block',
    'Upper extremity',
    'Dense upper-limb coverage; pleural and diaphragmatic risks remain.',
    'elbow forearm wrist hand first rib subclavian pneumothorax',
    [
      RegionalSection(
        'Coverage and gaps',
        [
          'Useful for arm, elbow, forearm, and hand surgery. Confirm distribution before incision; block location does not guarantee every terminal territory is anesthetized.',
          'The intercostobrachial nerve supplies proximal medial-arm skin and is not reliably covered by a brachial plexus block. Tourniquet/incision requirements may require supplementation.',
        ],
        ['sc'],
      ),
      RegionalSection(
        'Key ultrasound relationships',
        [
          'Identify the plexus posterior/superficial to the subclavian artery, with the first rib and pleura deep to the target region.',
          'Distinguish first rib from pleura and use Doppler for intervening vessels. Keep the needle tip continuously identifiable; a visible shaft alone is not adequate.',
          'Seek appropriate spread around the plexus without forceful injection or unnecessary needle passes.',
        ],
        ['sc'],
      ),
      RegionalSection(
        'Risk and postoperative assessment',
        [
          'Pneumothorax is uncommon with experienced ultrasound-guided practice but remains possible and may present later. New chest pain, dyspnea, or hypoxemia warrants assessment.',
          'Phrenic involvement is less common than with interscalene block but cannot reliably be avoided. Consider a more distal approach when loss of diaphragmatic function would be poorly tolerated.',
          'Vascular puncture, LAST, incomplete block, and neurologic injury remain relevant despite ultrasound guidance.',
        ],
        ['sc', 'nerve'],
      ),
    ],
    related: ['infraclavicular', 'axillary', 'last'],
  ),
  RegionalTopic(
    'infraclavicular',
    'Infraclavicular brachial plexus block',
    'Upper extremity',
    'Cord-level anesthesia below the shoulder and a stable catheter site.',
    'elbow wrist hand cords axillary artery continuous catheter',
    [
      RegionalSection(
        'Clinical role',
        [
          'Useful for arm, elbow, forearm, and hand surgery below the shoulder. The proximal medial-arm skin supplied by the intercostobrachial nerve may require supplementation.',
          'The chest-wall location can support catheter stability when prolonged analgesia is desired.',
        ],
        ['ic'],
      ),
      RegionalSection(
        'Anatomy and imaging',
        [
          'Image the axillary artery deep to pectoralis major and minor. The cords lie around the artery; individual positions vary and should not be treated as fixed clock-face coordinates.',
          'Identify the axillary vein and pleura as well as the artery. Appropriate spread posterior, cephalad, and caudad to the artery can reach the cords even when each cord is not distinct.',
          'Depth increases the importance of needle-tip visualization and a controlled injection. Reassess poor spread rather than forcing injection across a fascial barrier.',
        ],
        ['ic'],
      ),
      RegionalSection(
        'Limits and ongoing care',
        [
          'A more distal approach may be preferable when respiratory reserve is limited, but do not label any technique categorically “zero risk.” Pleural, vascular, neurologic, and toxicity risks still require assessment.',
          'Motor block is expected and can persist. Protect the limb and align catheter duration with benefit and infection risk.',
          'For a catheter, verify spread and function and reassess the insertion site and ongoing need.',
        ],
        ['sc', 'ic', 'infection'],
      ),
    ],
    related: ['axillary', 'selection-recovery', 'anticoagulation'],
  ),
  RegionalTopic(
    'axillary',
    'Axillary brachial plexus block',
    'Upper extremity',
    'Distal upper-limb coverage without approaching the neck or pleura.',
    'median ulnar radial musculocutaneous hand wrist forearm',
    [
      RegionalSection(
        'Coverage and exclusions',
        [
          'Useful for elbow, forearm, and hand surgery when the relevant terminal branches, including musculocutaneous, are covered.',
          'The axillary nerve has already left the plexus; shoulder/deltoid skin is not covered. Proximal medial-arm skin and tourniquet discomfort may require separate assessment.',
        ],
        ['ax'],
      ),
      RegionalSection(
        'Anatomy and practical limitations',
        [
          'Identify the axillary artery, surrounding veins, and median, ulnar, and radial nerves. Nerve positions are variable, not a universal diagram.',
          'The musculocutaneous nerve is commonly separate from the perivascular cluster, within or between coracobrachialis and biceps; identify it rather than assuming a perivascular injection covers it.',
          'Avoid excessive arm abduction. Light transducer pressure and Doppler help reveal compressible veins that could otherwise be obscured.',
        ],
        ['ax'],
      ),
      RegionalSection(
        'Injection and recovery',
        [
          'Observe spread; absent visible spread during injection should prompt stopping and reassessment for intravascular or incorrect placement.',
          'The approach avoids the characteristic pleural and phrenic concerns of more proximal blocks, but still carries risks of LAST, vessel injury, nerve injury, and incomplete anesthesia.',
          'Protect the blocked limb and verify recovery expectations and follow-up before discharge.',
        ],
        ['ax', 'nerve'],
      ),
    ],
    related: ['safety', 'last', 'selection-recovery'],
  ),
  RegionalTopic(
    'femoral',
    'Femoral nerve block',
    'Lower extremity',
    'Anterior thigh and knee analgesia with quadriceps motor block.',
    'hip fracture patella quadriceps fascia iliaca falls',
    [
      RegionalSection(
        'Coverage and use',
        [
          'Useful for femoral, patellar, quadriceps-tendon, and knee procedures and hip-fracture analgesia.',
          'Coverage includes anterior/medial thigh and a variable medial leg/foot territory. Do not assume it supplies complete hip, posterior knee, or whole-leg surgical anesthesia.',
        ],
        ['fn', 'ipack'],
      ),
      RegionalSection(
        'Ultrasound relationships',
        [
          'At the femoral crease, identify the femoral artery, vein, fascia iliaca, and iliopsoas. The nerve lies lateral to the artery and deep to fascia iliaca.',
          'Confirm the correct fascial plane and local anesthetic spread. The vein may be concealed by probe pressure; use Doppler and release pressure when necessary.',
          'Injection in the wrong fascial plane can fail despite an apparently nearby needle. Do not overcome resistance with force.',
        ],
        ['fn'],
      ),
      RegionalSection(
        'Motor and catheter implications',
        [
          'Femoral motor blockade can impair quadriceps function. Assess strength and provide assisted mobilization/fall precautions rather than equating pain relief with safe weight-bearing.',
          'An adductor canal technique may better support motor-sparing goals for selected knee procedures, but its coverage and residual motor risk also require assessment.',
          'The mobile groin and shallow nerve location can make catheter dislodgement a problem; secure, assess function, and monitor the site.',
        ],
        ['fn', 'ac'],
      ),
    ],
    related: ['adductor-canal', 'peng', 'selection-recovery'],
  ),
  RegionalTopic(
    'adductor-canal',
    'Adductor canal / saphenous block',
    'Lower extremity',
    'Medial leg coverage and knee analgesia; motor sparing is not absolute.',
    'saphenous subsartorius knee TKA femoral triangle quadriceps',
    [
      RegionalSection(
        'Clinical role and coverage',
        [
          'Useful for knee analgesia within a multimodal plan and for medial foot/ankle coverage when supplementing a sciatic block.',
          'The saphenous nerve is a sensory branch of the femoral nerve supplying the medial leg/foot and infrapatellar territory. It does not cover the entire knee or replace a sciatic block for other foot territories.',
        ],
        ['ac', 'ps'],
      ),
      RegionalSection(
        'Anatomy and motor limitations',
        [
          'At mid-thigh, identify sartorius over the femoral vessels, vastus medialis laterally, and adductor muscle medially. The saphenous nerve is typically close to the femoral artery.',
          'A proximal subsartorial/femoral-triangle injection is not identical to a distal canal or below-knee saphenous block. Location and spread affect coverage and motor involvement.',
          'Larger or more proximal injections may affect the branch to vastus medialis or femoral motor territory. Assess quadriceps function and assist ambulation even when the goal is motor sparing.',
        ],
        ['ac'],
      ),
      RegionalSection(
        'Completing the analgesic plan',
        [
          'Posterior knee pain may require a complementary modality such as periarticular infiltration or iPACK, selected according to the surgical plan and cumulative local anesthetic exposure.',
          'For continuous techniques, reassess benefit, catheter function, mobility, and infection risk. A label-supported liposomal regimen exists, but it has specific dose and compatibility requirements.',
        ],
        ['ipack', 'infection', 'exparel'],
      ),
    ],
    related: ['ipack', 'liposomal-bupivacaine', 'selection-recovery'],
  ),
  RegionalTopic(
    'ipack',
    'iPACK: posterior knee analgesia',
    'Lower extremity',
    'A posterior capsular supplement, not a stand-alone surgical block.',
    'TKA total knee arthroplasty posterior capsule popliteal foot drop',
    [
      RegionalSection(
        'Target and role',
        [
          'iPACK means infiltration between the popliteal artery and posterior capsule of the knee. It targets articular sensory branches while aiming to avoid the tibial and common peroneal motor trunks.',
          'It is commonly considered as a posterior-pain supplement to adductor canal or femoral techniques; select the combination within a multimodal surgical plan.',
        ],
        ['ipack'],
      ),
      RegionalSection(
        'Imaging and limitations',
        [
          'Identify the popliteal artery, distal femur, and posterior capsular plane. The intended plane is not the popliteal sciatic nerve sheath.',
          'Do not assume posterior analgesia covers anterior incision pain or provides full surgical anesthesia. Reconcile all local anesthetics used for companion blocks and surgeon infiltration.',
        ],
        ['ipack', 'ipack-risk', 'exparel'],
      ),
      RegionalSection(
        'Motor function still needs assessment',
        [
          'The motor-sparing goal is not a guarantee. Temporary foot drop has been reported, plausibly from spread to the common peroneal nerve.',
          'Document baseline and postoperative dorsiflexion/other relevant motor findings. New or persistent deficits require assessment for block spread, surgical injury, or another cause rather than automatic reassurance.',
        ],
        ['ipack-risk', 'nerve'],
      ),
    ],
    related: ['adductor-canal', 'neurologic-injury', 'local-anesthetics'],
  ),
  RegionalTopic(
    'popliteal',
    'Popliteal sciatic nerve block',
    'Lower extremity',
    'Foot and ankle coverage with a medial saphenous gap.',
    'Achilles tibial common peroneal ankle foot sciatic',
    [
      RegionalSection(
        'Coverage',
        [
          'Useful for foot, ankle, and Achilles procedures. It blocks motor and sensory function below the knee, except the medial leg/foot supplied by the saphenous nerve.',
          'Supplement medial territory when the incision requires it. Hamstring function is spared, but foot/calf motor function and safe ambulation can be affected.',
        ],
        ['ps'],
      ),
      RegionalSection(
        'Anatomy and ultrasound orientation',
        [
          'Identify the popliteal artery and vein, tibial nerve, and common peroneal nerve. Trace proximally to their convergence; bifurcation height varies.',
          'The branches share a connective-tissue sheath near their separation. The objective is spread around the relevant components, not fascicular injection.',
          'High resistance or poor visualization warrants stopping/reassessment. Confirm distribution around both branches rather than relying on one motor response.',
        ],
        ['ps', 'nerve'],
      ),
      RegionalSection(
        'Recovery and catheter plan',
        [
          'Protect the insensate foot and plan safe assisted mobilization. A longer analgesic block may also prolong motor impairment.',
          'For a catheter, verify spread and secure the system; assess ongoing benefit, site condition, and block distribution.',
          'A label-supported liposomal-bupivacaine regimen exists for adult popliteal sciatic block; its dose and compatibility restrictions differ from conventional local anesthetics.',
        ],
        ['ps', 'infection', 'exparel'],
      ),
    ],
    related: ['adductor-canal', 'liposomal-bupivacaine', 'selection-recovery'],
  ),
  RegionalTopic(
    'tap',
    'Transversus abdominis plane (TAP) block',
    'Truncal',
    'Abdominal-wall analgesia, not reliable visceral analgesia.',
    'abdominal cesarean hernia subcostal lateral TAP',
    [
      RegionalSection(
        'Coverage follows the approach',
        [
          'TAP blocks target somatic abdominal-wall afferents; visceral surgical pain still requires other analgesic modalities.',
          'Subcostal, lateral, and posterior approaches are not interchangeable. Match the injection location to the incision and expected distribution; do not assign one universal dermatomal range to all TAP techniques.',
        ],
        ['tap'],
      ),
      RegionalSection(
        'Anatomy and imaging',
        [
          'For a lateral approach, identify external oblique, internal oblique, transversus abdominis, and the peritoneal boundary. The target is the plane between internal oblique and transversus abdominis.',
          'Subcostal anatomy and targets differ. Maintain visualization of the needle tip and deeper abdominal structures rather than following a fixed depth.',
          'Spread in the correct plane matters more than a visible volume alone; intramuscular or deeper-than-intended injection changes both efficacy and risk.',
        ],
        ['tap'],
      ),
      RegionalSection(
        'Bilateral dosing and limitations',
        [
          'Account for the combined dose from both sides and all other local anesthetics. Large-volume fascial-plane techniques can still produce systemic toxicity.',
          'TAP and QL should be presented as separate techniques with different targets and risks. Do not use the old “266 mg liposomal bupivacaine per side” recipe.',
          'EXPAREL has no established label indication for regional analgesia by TAP block in the cited US prescribing information.',
        ],
        ['tap', 'exparel'],
      ),
    ],
    related: ['quadratus-lumborum', 'local-anesthetics', 'last'],
  ),
  RegionalTopic(
    'quadratus-lumborum',
    'Quadratus lumborum (QL) block',
    'Truncal',
    'Approach-dependent abdominal analgesia with deeper anatomical risks.',
    'QL QLB transmuscular abdominal psoas lumbar plexus',
    [
      RegionalSection(
        'Distinct from TAP',
        [
          'Lateral, posterior, and transmuscular QL approaches use different fascial targets and can produce different distributions. Treat “QL block” as a family of techniques.',
          'Somatic and possible visceral effects depend on spread and approach; do not promise a fixed dermatomal range or guaranteed visceral analgesia.',
        ],
        ['tap'],
      ),
      RegionalSection(
        'Anatomical orientation',
        [
          'Identify quadratus lumborum, psoas, the relevant fascial layers, and adjacent retroperitoneal structures. For the transmuscular approach, the target is between QL and psoas.',
          'Identify the kidney and use Doppler for regional vessels. A deeper approach has different consequences for inadvertent vascular or organ injury than a superficial TAP injection.',
        ],
        ['tap'],
      ),
      RegionalSection(
        'Safety and recovery',
        [
          'Spread to the lumbar plexus can cause lower-extremity weakness. Assess strength and assisted-mobility needs rather than assuming a purely sensory abdominal block.',
          'Large volumes and bilateral treatment require careful total-dose accounting. Vascularity and depth increase the importance of toxicity and bleeding-risk planning.',
          'Use technique-specific anticoagulation assessment, including whether the target is deep/noncompressible, rather than assuming every fascial-plane block is low risk.',
        ],
        ['tap', 'asra'],
      ),
    ],
    related: ['tap', 'anticoagulation', 'selection-recovery'],
  ),
  RegionalTopic(
    'esp',
    'Erector spinae plane (ESP) block',
    'Truncal',
    'A paraspinal fascial-plane technique with variable spread.',
    'rib thoracic erector spinae transverse process ESPB',
    [
      RegionalSection(
        'Target and proposed mechanism',
        [
          'The target plane is deep to erector spinae and superficial to the transverse process. Cranio-caudal spread and diffusion toward adjacent spaces may contribute to analgesia.',
          'The mechanism and optimal indications remain incompletely defined. Do not promise epidural-equivalent coverage or a fixed sensory extent based on the injection level alone.',
        ],
        ['esp'],
      ),
      RegionalSection(
        'Ultrasound landmarks',
        [
          'Identify the transverse process in a paramedian sagittal view. At upper thoracic levels, trapezius and rhomboid may overlie erector spinae.',
          'Lamina indicates a more medial view; ribs with intervening pleura indicate a more lateral view. Confirm the bony target before interpreting the needle endpoint.',
          'Observe separation deep to the muscle and above the transverse process; an uncertain tip or unintended spread warrants reassessment.',
        ],
        ['esp'],
      ),
      RegionalSection(
        'Limits and risk planning',
        [
          'Assess actual analgesic distribution and maintain a rescue/multimodal analgesic plan. A successful-looking fascial injection is not confirmation of complete surgical anesthesia.',
          'Total local anesthetic exposure, infection prevention, and the bleeding consequences of the selected depth/site still apply.',
          'The cited EXPAREL label does not establish ESP as an approved regional nerve-block indication.',
        ],
        ['esp', 'asra', 'infection', 'exparel'],
      ),
    ],
    related: ['local-anesthetics', 'anticoagulation', 'infection'],
  ),
  RegionalTopic(
    'peng',
    'Pericapsular nerve group (PENG) block',
    'Lower extremity',
    'Anterior hip-capsule analgesia; quadriceps sparing is not assured.',
    'hip fracture arthroplasty femoral obturator iliopsoas motor sparing',
    [
      RegionalSection(
        'Anatomy and intended coverage',
        [
          'PENG targets articular branches supplying the anterior hip capsule, including femoral, obturator, and accessory obturator contributions.',
          'The described target lies deep to the iliopsoas tendon near the iliopubic/iliopectineal bony region. Correct fascial relationships matter; anatomy and spread are more complex than a single target dot.',
        ],
        ['peng'],
      ),
      RegionalSection(
        'Analgesia is not complete operative anesthesia',
        [
          'The intent is hip-capsule analgesia. Do not assume complete skin-incision coverage, posterior hip coverage, or dependable stand-alone surgical anesthesia.',
          'Reports of wider anesthesia may involve additional blocks, infiltration, sedation, or extra-plane spread. Plan the primary anesthetic separately.',
        ],
        ['peng'],
      ),
      RegionalSection(
        'Nonzero motor risk',
        [
          'Quadriceps weakness has been reported in clinical studies and can result from spread to the femoral nerve proper. The label “motor-sparing” describes an aim, not a guarantee.',
          'Needle location and injectate volume can affect spread. Assess postoperative motor function and provide fall precautions.',
          'Do not describe PENG as categorically superior to femoral block for every hip-fracture patient; select within the operation, patient risks, and local expertise.',
        ],
        ['peng'],
      ),
    ],
    related: ['femoral', 'neurologic-injury', 'selection-recovery'],
  ),
  RegionalTopic(
    'epidural',
    'Epidural anesthesia & analgesia',
    'Neuraxial',
    'Segmental blockade with catheter-dependent dosing and follow-up.',
    'labor thoracic lumbar catheter test dose top up hypotension',
    [
      RegionalSection(
        'Clinical role and anatomy',
        [
          'Epidural local anesthetic acts on spinal nerve roots outside the dura. Catheter level, concentration, volume, and total dose influence distribution and density.',
          'Uses include labor analgesia and selected thoracic, abdominal, pelvic, and lower-extremity procedures, alone or with general anesthesia.',
          'Choose the catheter level to match the surgical target rather than using a universal volume or a fixed “milliliters per segment” order.',
        ],
        ['epidural'],
      ),
      RegionalSection(
        'Selection and placement',
        [
          'Assess consent, infection at the intended site, hemostasis, antithrombotic exposure, neurologic baseline, and hemodynamic reserve.',
          'Severe coagulation abnormality and obstructed CSF flow/mass-effect intracranial pathology are major concerns. Fixed-output states and systemic infection require individualized specialist-level risk–benefit assessment.',
          'An adult who can report atypical pain or paresthesia provides useful information; deep sedation or general anesthesia for placement needs a specific rationale.',
        ],
        ['epidural', 'asra', 'nerve'],
      ),
      RegionalSection(
        'Catheter dosing and failed block',
        [
          'Reassess catheter location/function before boluses, use repeated aspiration and incremental dosing, and monitor for intravascular or intrathecal effects.',
          'A traditional test dose has limitations in labor, under anesthesia, and with beta-blockade. A negative test does not guarantee that later doses are safe.',
          'Patchy, unilateral, or inadequate anesthesia requires reassessment or replacement; repeated large top-ups of an uncertain catheter can increase risk.',
        ],
        ['epidural'],
      ),
      RegionalSection(
        'High block, removal, and recovery',
        [
          'Progressive hypotension/bradycardia, ascending weakness, difficulty speaking, respiratory compromise, or altered consciousness require prompt evaluation and support of airway, ventilation, and circulation.',
          'Plan catheter removal around the current antithrombotic regimen. Removal itself is a bleeding-risk event, not merely a nursing convenience.',
          'New, recurrent, prolonged, or progressive deficits need urgent assessment; do not assume all weakness is the infusion. Monitor for infection and communicate a clear recovery/follow-up plan.',
        ],
        ['epidural', 'asra', 'nerve', 'infection'],
      ),
    ],
    related: ['anticoagulation', 'spinal', 'neurologic-injury'],
  ),
  RegionalTopic(
    'spinal',
    'Spinal (subarachnoid) anesthesia',
    'Neuraxial',
    'Intrathecal anesthesia shaped by dose, baricity, position, and physiology.',
    'intrathecal cesarean hip knee TURP bupivacaine high spinal hypotension',
    [
      RegionalSection(
        'Clinical role and anatomy',
        [
          'Local anesthetic is delivered into CSF in the subarachnoid space. Common uses include selected lower abdominal, pelvic, perineal, obstetric, and lower-extremity operations.',
          'Lumbar puncture is generally performed at L3–4 or L4–5, recognizing anatomical variability and the limitations of surface landmarks.',
          'Dose, solution baricity, and patient position are major determinants of spread. Volume alone cannot define the expected block height or duration.',
        ],
        ['spinal'],
      ),
      RegionalSection(
        'Selection and physiological risk',
        [
          'Assess refusal, injection-site infection, severe uncorrected hypovolemia, drug allergy, hemostasis, and intracranial pathology with a risk of herniation from altered CSF pressure.',
          'Not all elevated intracranial-pressure states are equivalent; mass effect/obstructed flow differs from idiopathic intracranial hypertension. Seek appropriate specialist input.',
          'Systemic infection, fixed-output cardiac disease, and preexisting neurologic disease require individualized assessment. A single label should not replace evaluation of severity, treatment, and physiologic reserve.',
        ],
        ['spinal', 'epidural', 'asra', 'nerve'],
      ),
      RegionalSection(
        'Assess the block before surgery',
        [
          'Confirm an appropriate sensory distribution and clinical conditions before incision. Maintain monitoring, IV access, and immediate resuscitation capability.',
          'Avoid oversedation; it can obscure symptoms and compromise ventilation. Treat hypotension and bradycardia promptly rather than relying on spontaneous regression.',
          'An inadequate block requires reassessment of mechanism and the remaining drug effect. Do not reflexively repeat a full intrathecal dose; excessive dosing or maldistribution may cause high block or neurologic injury.',
        ],
        ['spinal', 'nerve'],
      ),
      RegionalSection(
        'Recognize excessive spread and delayed problems',
        [
          'Unexpected ascending weakness, dyspnea, cardiovascular compromise, or altered consciousness should trigger immediate evaluation and airway/circulatory support as needed.',
          'Protect insensate limbs and monitor recovery. New or progressive neurologic symptoms are not routine postoperative findings and require urgent assessment.',
          'Maintain a plan for post-dural-puncture symptoms, urinary retention, and safe mobilization rather than ending follow-up once surgery is complete.',
        ],
        ['spinal', 'nerve'],
      ),
    ],
    related: ['epidural', 'anticoagulation', 'neurologic-injury'],
  ),
  RegionalTopic(
    'selection-recovery',
    'Block selection & postoperative recovery',
    'Planning & recovery',
    'Coverage, motor goals, catheter follow-up, and safe mobilization.',
    'choose block surgery bundle shoulder knee hip foot abdomen discharge rebound pain',
    [
      RegionalSection(
        'Upper limb: match the operation, not just the limb',
        [
          'Shoulder/proximal humerus: consider interscalene coverage and its respiratory trade-offs. Clavicular skin may need additional cervical-plexus coverage.',
          'Elbow/forearm/hand: supraclavicular, infraclavicular, or axillary approaches may fit, with different anatomy, catheter practicality, and pulmonary implications.',
          'For upper-arm tourniquet or medial proximal skin, account for intercostobrachial territory outside the brachial plexus.',
        ],
        ['is', 'sc', 'ic', 'ax'],
      ),
      RegionalSection(
        'Lower limb and trunk: analgesia versus anesthesia',
        [
          'Knee: adductor canal analgesia may be paired with a posterior modality when needed. Neither motor sparing nor complete surgical anesthesia is guaranteed by the combination.',
          'Foot/ankle: popliteal sciatic coverage leaves a medial saphenous gap. Hip-capsule analgesia from PENG does not replace the primary surgical anesthetic.',
          'Abdominal incision pain: select a TAP/QL approach to match the incision, but plan for visceral pain and cumulative bilateral dosing. ESP spread and coverage remain variable.',
        ],
        ['ac', 'ipack', 'ps', 'peng', 'tap', 'esp'],
      ),
      RegionalSection(
        'Recovery and handoff',
        [
          'Assess actual sensory and motor effects before unassisted mobilization. Protect insensate limbs; a motor-sparing intention does not establish safe walking.',
          'Communicate block location, agent/formulation, total dose, time, catheter regimen, and any procedural concerns. Maintain a plan for inadequate or wearing-off analgesia within the overall perioperative regimen.',
          'Reassess catheters for function, need, infection signs, and anticoagulant timing before removal. Give clear instructions for urgent symptoms and a way to reach the clinical team.',
          'New dyspnea, progressive weakness, unexpected recurrent deficit, or signs of infection require assessment rather than reassurance based on the block name.',
        ],
        ['ac', 'ps', 'exparel', 'infection', 'asra', 'nerve', 'is', 'sc'],
      ),
    ],
    related: ['safety', 'infection', 'neurologic-injury'],
  ),
];

RegionalTopic? regionalTopic(String? id) =>
    regionalTopics.where((topic) => topic.id == id).firstOrNull;

String _normalize(String text) =>
    text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
final _tokens = {
  for (final t in regionalTopics)
    t.id: _normalize(
      '${t.title} ${t.category} ${t.summary} ${t.aliases} '
      '${t.sections.map((s) => '${s.title} ${s.bullets.join(' ')}').join(' ')}',
    ).split(RegExp(r'\s+')).toSet(),
};

List<RegionalTopic> searchRegionalTopics(
  String query, {
  String category = 'All',
}) {
  final words = _normalize(query)
      .split(' ')
      .where((w) => w.isNotEmpty)
      .toList();
  final results = regionalTopics
      .where(
        (t) =>
            (category == 'All' || t.category == category) &&
            words.every(
              (w) => _tokens[t.id]!.any((token) => token.startsWith(w)),
            ),
      )
      .toList();
  if (words.isNotEmpty) {
    int score(RegionalTopic t) {
      final title = _normalize(t.title).split(' ');
      return words.every(title.contains)
          ? 0
          : words.every((w) => title.any((token) => token.startsWith(w)))
          ? 1
          : 2;
    }

    results.sort((a, b) {
      final rank = score(a).compareTo(score(b));
      return rank == 0 ? a.title.compareTo(b.title) : rank;
    });
  }
  return results;
}
