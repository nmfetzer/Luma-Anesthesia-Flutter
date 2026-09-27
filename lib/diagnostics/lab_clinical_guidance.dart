/// Source-linked interpretation for the review-only adult lab library.
/// Each section's source supports its bullets; no patient-specific advice.
class LabClinicalSection {
  const LabClinicalSection(
    this.title,
    this.bullets,
    this.sourceLabel,
    this.url, {
    this.urgent = false,
  });
  final String title;
  final List<String> bullets;
  final String sourceLabel;
  final String url;
  final bool urgent;
}

const asraLabSource =
    'https://rapm.bmj.com/content/rapm/early/2025/01/21/rapm-2024-105766.full.pdf';
const traumaLabSource = 'https://doi.org/10.1186/s13054-023-04327-7';
const coagulationLabSource =
    'https://arupconsult.com/content/prolonged-clotting-time-evaluation';
const dicLabSource =
    'https://arupconsult.com/content/disseminated-intravascular-coagulation';
const xaLabSource = 'https://arupconsult.com/ati/direct-xa-inhibitor-levels';
const troponinLabSource =
    'https://www.acc.org/Latest-in-Cardiology/ten-points-to-remember/2019/01/21/14/44/Fourth-Universal-Definition-of-Myocardial-Infarction';
const sepsisLabSource =
    'https://www.sccm.org/clinical-resources/guidelines/guidelines/surviving-sepsis-campaign-international-guidelines-for-management-of-sepsis-and-septic-shock-2026';
const _aki =
    'https://www.merckmanuals.com/professional/nephrology/acute-kidney-injury/acute-kidney-injury-aki';
const _liver =
    'https://www.merckmanuals.com/professional/hepatic-and-biliary-disorders/testing-for-hepatic-and-biliary-disorders/laboratory-tests-of-the-liver-and-gallbladder';
const _acidBase =
    'https://www.merckmanuals.com/en-ca/professional/endocrine-and-metabolic-disorders/acid-base-regulation-and-disorders/acid-base-disorders';
const _preop =
    'https://www.merckmanuals.com/professional/special-subjects/care-of-the-surgical-patient/preoperative-evaluation';
const _cbc = 'https://medlineplus.gov/lab-tests/complete-blood-count-cbc/';
const _aabb = 'https://pubmed.ncbi.nlm.nih.gov/37824153/';
const _cirrhosis =
    'https://www.aasld.org/liver-fellow-network/core-series/clinical-pearls/peri-procedural-management-bleeding-risk-cirrhosis';

const labClinicalGuidance = <String, List<LabClinicalSection>>{
  'sodium': [
    LabClinicalSection(
      'Interpretation & perioperative context',
      [
        'Interpret a low sodium with serum osmolality, glucose, volume status, medications, and the time course. Different causes require different treatment approaches.',
        'Acute neurologic deterioration, seizures, or markedly altered consciousness with hyponatremia require urgent assessment; severity is not determined by the sodium number alone.',
        'Rapid correction can cause osmotic demyelination. Chronic or uncertain-duration hyponatremia requires a monitored correction plan, not rapid normalization to the example interval.',
      ],
      'Merck Manual · Hyponatremia',
      'https://www.merckmanuals.com/professional/nephrology/electrolyte-disorders/hyponatremia',
      urgent: true,
    ),
  ],
  'potassium': [
    LabClinicalSection(
      'High potassium: urgent context',
      [
        'UK Kidney Association adult guidance classifies 6.0–6.4 mmol/L as moderate and ≥6.5 mmol/L as severe hyperkalemia. These are severity thresholds, not the reference interval.',
        'Severe hyperkalemia requires emergency assessment and treatment, with or without ECG changes. Do not use a reassuring tracing to dismiss a dangerous potassium result.',
        'Consider pseudohyperkalemia and specimen problems when a result is unexpected. Confirmation must not delay treatment of a clinically unstable patient.',
      ],
      'UK Kidney Association · Adult hyperkalemia guideline (2023)',
      'https://www.ukkidney.org/sites/default/files/FINAL%20VERSION%20-%20UKKA%20CLINICAL%20PRACTICE%20GUIDELINE%20-%20MANAGEMENT%20OF%20HYPERKALAEMIA%20IN%20ADULTS%20-%20191223_0.pdf',
      urgent: true,
    ),
    LabClinicalSection(
      'Low potassium: anesthesia relevance',
      [
        'Potassium <2.5 mEq/L is severe hypokalemia. Weakness, hypoventilation, paralysis, and arrhythmias are clinically important manifestations.',
        'Review losses, redistribution, and magnesium status. The laboratory interval is not a stand-alone rule for proceeding with or cancelling anesthesia.',
      ],
      'Merck Manual · Hypokalemia',
      'https://www.merckmanuals.com/en-ca/professional/endocrine-and-metabolic-disorders/electrolyte-disorders/hypokalemia',
      urgent: true,
    ),
  ],
  'chloride': [
    LabClinicalSection(
      'Interpretation with acid–base results',
      [
        'Interpret chloride with sodium, bicarbonate, and the anion gap rather than as an isolated abnormality.',
        'Low bicarbonate with relatively high chloride and a normal anion gap suggests hyperchloremic metabolic acidosis. Confirm the acid–base picture with clinical context and a blood gas when indicated.',
        'Mixed acid–base disorders can produce deceptively normal individual values.',
      ],
      'Merck Manual · Acid–base disorders',
      _acidBase,
    ),
  ],
  'co2': [
    LabClinicalSection(
      'Chemistry result versus blood gas',
      [
        'Chemistry-panel bicarbonate and blood-gas bicarbonate are obtained differently; the blood-gas bicarbonate is calculated from measured pH and carbon dioxide tension.',
        'Do not confuse a chemistry CO₂ concentration in mEq/L with PaCO₂, a partial pressure reported in mm Hg.',
        'Use pH, PaCO₂, anion gap, and expected compensation to distinguish primary metabolic disease from compensation or a mixed disorder. A low chemistry result alone does not establish the complete diagnosis.',
      ],
      'Merck Manual · Acid–base disorders',
      _acidBase,
    ),
  ],
  'bun': [
    LabClinicalSection(
      'Renal & perioperative interpretation',
      [
        'BUN may rise from gastrointestinal bleeding, increased protein catabolism, surgery, trauma, or glucocorticoids, as well as impaired renal function.',
        'Read BUN alongside creatinine trends, urine output, and the clinical picture. An isolated elevated BUN does not establish the mechanism of kidney injury.',
      ],
      'Merck Manual · Acute kidney injury',
      _aki,
    ),
  ],
  'creatinine': [
    LabClinicalSection(
      'Recognizing acute kidney injury',
      [
        'KDIGO diagnostic criteria include a creatinine rise ≥0.3 mg/dL within 48 hours, a rise to ≥1.5 times baseline within 7 days, or urine output <0.5 mL/kg/hour for 6 hours.',
        'A value still inside the laboratory interval can meet AKI criteria if it has risen sufficiently from baseline. Compare with prior results and urine output.',
        'Creatinine-based clearance estimates are unreliable while creatinine is changing rapidly. A reassuring estimated GFR must not substitute for assessment of evolving AKI.',
        'AKI can occur without oliguria. Hyperkalemia, severe acid–base disturbance, and volume overload are important associated complications.',
      ],
      'Merck Manual · AKI and KDIGO diagnostic criteria',
      _aki,
      urgent: true,
    ),
  ],
  'glucose': [
    LabClinicalSection(
      'Elective surgery: target is not a normal range',
      [
        'For adults with diabetes undergoing elective surgery, the Endocrine Society suggests preoperative glucose 100–180 mg/dL, including 1–4 hours before surgery.',
        'That recommendation applies when there is reasonable time for preoperative optimization. It is not the fasting reference interval and is not a universal cancellation threshold.',
        'Review diabetes therapy, nutrition or fasting status, renal function, and monitoring needs. Point-of-care confirmation is required for insulin adjustments when inpatient continuous glucose monitoring is used.',
      ],
      'Endocrine Society · Inpatient hyperglycemia guideline (2022)',
      'https://www.endocrine.org/clinical-practice-guidelines/inpatient-hyperglycemia-guideline-resources',
    ),
    LabClinicalSection(
      'Hypoglycemia: recognize and respond',
      [
        'Level 1 hypoglycemia is glucose <70 but ≥54 mg/dL; level 2 is <54 mg/dL.',
        'Level 3 describes severe hypoglycemia requiring another person’s assistance, regardless of a measured glucose value.',
        'Hypoglycemia can escalate rapidly. Use the institutional treatment pathway with prompt glucose reassessment; the fasting reference interval is not a reason to defer recognition of a low result.',
      ],
      'American Diabetes Association · Hypoglycemia recognition',
      'https://diabetesjournals.org/clinical/article/42/4/515/157097/Out-of-Sight-Out-of-Mind-A-Call-to-Action-for-the',
      urgent: true,
    ),
  ],
  'calcium': [
    LabClinicalSection(
      'Total versus biologically active calcium',
      [
        'Total calcium includes protein-bound calcium. Abnormal albumin or immunoglobulins can change total calcium and create a need for direct ionized calcium measurement.',
        'Do not treat the total and ionized values as interchangeable. Review the specimen’s units and the laboratory-specific interval.',
      ],
      'MedlinePlus · Ionized calcium',
      'https://medlineplus.gov/ency/article/003486.htm',
    ),
    LabClinicalSection(
      'Major bleeding & transfusion',
      [
        'During major trauma and massive transfusion, monitor ionized calcium and maintain it within the normal range. Use the separate Ionized Calcium card for trauma-specific cautions.',
      ],
      'European trauma bleeding guideline · Sixth edition (2023)',
      traumaLabSource,
    ),
  ],
  'albumin': [
    LabClinicalSection(
      'Synthetic function & limitations',
      [
        'Albumin can be reduced by advanced liver disease, inflammation, undernutrition, and renal, gastrointestinal, or skin protein loss.',
        'Its approximately 20-day half-life limits its ability to describe abrupt changes. A low albumin is not a specific diagnosis of liver failure or malnutrition.',
      ],
      'Merck Manual · Liver laboratory tests',
      _liver,
    ),
    LabClinicalSection(
      'Preoperative context',
      [
        'Low albumin is associated with increased perioperative morbidity and mortality. Assess the cause and overall nutritional and medical condition rather than treating a laboratory number as a complete risk assessment.',
      ],
      'Merck Manual · Preoperative evaluation',
      _preop,
    ),
  ],
  'protein': [
    LabClinicalSection(
      'Interpretation with the rest of the panel',
      [
        'Total protein combines albumin and globulins; it is not interchangeable with an albumin measurement.',
        'Interpret an abnormal result with the other panel results, medical history, and medications. A single CMP component does not establish a diagnosis.',
      ],
      'MedlinePlus · Comprehensive metabolic panel',
      'https://medlineplus.gov/lab-tests/comprehensive-metabolic-panel-cmp/',
    ),
  ],
  'alp': [
    LabClinicalSection(
      'Cholestatic pattern & nonhepatic sources',
      [
        'ALP is not liver-specific: bone, placenta, intestine, and other tissues contribute.',
        'Use the accompanying liver-test pattern and, when appropriate, GGT or 5′-nucleotidase to help establish a hepatic source.',
        'An ALP elevation alone does not quantify hepatic synthetic reserve or procedural bleeding risk.',
      ],
      'Merck Manual · Liver laboratory tests',
      _liver,
    ),
  ],
  'alt': [
    LabClinicalSection(
      'Hepatocellular injury is not synthetic function',
      [
        'ALT elevation suggests hepatocellular injury; serial measurements are more informative than a single result.',
        'Interpret alongside bilirubin, albumin, PT/INR, and clinical findings rather than using ALT alone as a measure of liver function.',
        'In acute liver failure, falling aminotransferases can reflect loss of viable hepatocytes rather than recovery.',
      ],
      'Merck Manual · Liver laboratory tests',
      _liver,
    ),
  ],
  'ast': [
    LabClinicalSection(
      'Extrahepatic sources & trend interpretation',
      [
        'AST occurs in skeletal muscle, heart, red blood cells, kidneys, and pancreas as well as liver. An elevation is not automatically hepatic.',
        'Review AST with ALT, bilirubin, and the clinical context. A ratio can support a pattern but does not establish the diagnosis alone.',
        'Falling aminotransferases in acute liver failure do not necessarily indicate improved liver function.',
      ],
      'Merck Manual · Liver laboratory tests',
      _liver,
    ),
  ],
  'bilirubin': [
    LabClinicalSection(
      'Fractionation & perioperative context',
      [
        'Unconjugated elevation can reflect increased production or impaired uptake or conjugation. Conjugated elevation suggests impaired bile formation or excretion.',
        'Interpret the direct and indirect fractions with the other liver tests and clinical findings; total bilirubin alone is an insensitive measure of hepatic dysfunction.',
      ],
      'Merck Manual · Liver laboratory tests',
      _liver,
    ),
  ],
  'hemoglobin': [
    LabClinicalSection(
      'Anemia & anticipated blood loss',
      [
        'CBC assessment is particularly relevant when substantial surgical blood loss is anticipated or the patient has symptoms or significant underlying disease.',
        'Testing should follow the procedure, history, medications, and comorbidities rather than routine testing of every healthy patient.',
      ],
      'Merck Manual · Preoperative evaluation',
      _preop,
    ),
    LabClinicalSection(
      'Transfusion: defined populations, not automatic triggers',
      [
        'AABB 2023 recommends considering transfusion below 7 g/dL for hemodynamically stable hospitalized adults.',
        'Clinicians may choose 7.5 g/dL for cardiac surgery, or 8 g/dL for orthopedic surgery or preexisting cardiovascular disease.',
        'These recommendations require clinical context and consideration of alternatives. They are not hemoglobin targets or instructions to wait for a number in active hemorrhage, shock, or acute myocardial infarction.',
      ],
      'AABB · Red blood cell transfusion guidelines (2023)',
      _aabb,
      urgent: true,
    ),
  ],
  'hematocrit': [
    LabClinicalSection(
      'Interpretation with the CBC',
      [
        'Hematocrit reflects the proportion of blood occupied by red cells. An abnormal result may accompany anemia or dehydration and requires clinical interpretation.',
        'Assess it with hemoglobin and the rest of the CBC rather than using an isolated hematocrit as a diagnosis.',
      ],
      'MedlinePlus · CBC interpretation',
      _cbc,
    ),
    LabClinicalSection(
      'No fixed perioperative hematocrit target',
      [
        'The AABB recommendations shown in this library use hemoglobin with population-specific clinical assessment; they do not define a universal target hematocrit for anesthesia.',
      ],
      'AABB · Red blood cell transfusion guidelines (2023)',
      _aabb,
    ),
  ],
  'wbc': [
    LabClinicalSection(
      'Infection assessment & differential',
      [
        'A high white count may reflect infection or a medication reaction. Interpret it with symptoms and the rest of the clinical evaluation, not as proof of infection.',
        'A CBC with differential describes individual white cell types and adds information beyond the total count.',
      ],
      'MedlinePlus · CBC interpretation',
      _cbc,
    ),
  ],
  'mcv': [
    LabClinicalSection(
      'Use with hemoglobin and other red-cell findings',
      [
        'MCV describes average red-cell size, while hemoglobin and hematocrit measure different aspects of the red-cell profile.',
        'An abnormal CBC may prompt further tests to establish the cause. MCV alone does not establish an anemia diagnosis or a transfusion indication.',
      ],
      'MedlinePlus · CBC interpretation',
      _cbc,
    ),
  ],
  'platelets': [
    LabClinicalSection(
      'Neuraxial decisions: obstetric evidence has limits',
      [
        'SOAP identifies a likely low spinal/epidural hematoma risk at ≥70,000/µL in selected obstetric patients with gestational thrombocytopenia, ITP, or hypertensive disorders of pregnancy, without additional risk factors.',
        'This is not a universal threshold for all patients, all causes of thrombocytopenia, or all procedures. Bleeding history, suspected DIC, etiology, trajectory, and competing risks matter.',
        'For suspected HELLP, SOAP considers verifying the platelet count within 6 hours of a planned neuraxial procedure or catheter removal reasonable.',
      ],
      'SOAP · Obstetric thrombocytopenia consensus statement (2021)',
      'https://www.soap.org/assets/docs/SOAP_Thrombocytopenia_Consensus_Statement_FINAL_STATEMENT.pdf',
    ),
    LabClinicalSection(
      'Falling platelets & evolving coagulopathy',
      [
        'Thrombocytopenia is not specific for DIC. Platelets can still be normal early in DIC; trends and the combined PT, fibrinogen, and D-dimer pattern are important.',
      ],
      'ARUP Consult · DIC evaluation',
      dicLabSource,
      urgent: true,
    ),
  ],
  'pt-inr': [
    LabClinicalSection(
      'Interpreting a prolonged result',
      [
        'Prolongation may reflect warfarin, vitamin K deficiency, liver disease, factor deficiency, DIC, or anticoagulant interference. Interpret PT with aPTT, platelets, and the bleeding history.',
        'Normal PT and aPTT do not exclude all bleeding disorders, qualitative platelet disorders, or clinically relevant DOAC exposure.',
      ],
      'ARUP Consult · Prolonged clotting time evaluation',
      coagulationLabSource,
    ),
    LabClinicalSection(
      'Warfarin and neuraxial procedures',
      [
        'ASRA recommends holding warfarin for at least 5 days and confirming INR normalization to the local laboratory range before needle placement.',
        'The ASRA catheter-removal recommendation of INR <1.5 is a separate recommendation. Do not use it as the needle-placement threshold.',
        'These statements do not replace the full anticoagulant-specific guideline, including assessment of other agents and clinical risk.',
      ],
      'ASRA · Antithrombotic guideline, fifth edition (2025)',
      asraLabSource,
    ),
    LabClinicalSection(
      'Cirrhosis: avoid treating INR as bleeding risk',
      [
        'INR alone does not predict procedural bleeding in cirrhosis. It does not capture the associated reduction in anticoagulant factors.',
        'AASLD advises against prophylactic plasma solely to correct the INR in cirrhosis; a target INR for that purpose does not exist. This does not establish neuraxial safety.',
      ],
      'AASLD · Procedural bleeding risk in cirrhosis',
      _cirrhosis,
    ),
  ],
  'aptt': [
    LabClinicalSection(
      'Pattern, medication, and clinical history',
      [
        'An isolated prolonged aPTT may reflect heparin, an intrinsic factor deficiency or inhibitor, or lupus anticoagulant.',
        'Some causes, such as factor XII deficiency, are not associated with clinical bleeding. Lupus anticoagulant may accompany thrombosis rather than a bleeding tendency.',
        'Unexplained prolongation warrants evaluation; do not equate every prolonged result with the same clinical risk.',
      ],
      'ARUP Consult · Prolonged clotting time evaluation',
      coagulationLabSource,
    ),
    LabClinicalSection(
      'Anticoagulant limitations',
      [
        'Routine PT/aPTT should not be used to quantify DOAC anticoagulation because reagent sensitivity varies.',
        'A normal result is not a substitute for drug-specific assessment, last-dose timing, dose, renal function, and the applicable regional-anesthesia guidance.',
      ],
      'ASRA · Antithrombotic guideline, fifth edition (2025)',
      asraLabSource,
    ),
  ],
  'fibrinogen': [
    LabClinicalSection(
      'Major bleeding: trauma-specific threshold',
      [
        'The 2023 European trauma guideline recommends fibrinogen replacement in major bleeding with Clauss fibrinogen ≤1.5 g/L or viscoelastic evidence of functional fibrinogen deficit.',
        'That is a treatment threshold for major traumatic bleeding, not the normal range and not a universal obstetric or procedural target.',
        'Use serial laboratory or viscoelastic assessment to guide ongoing correction within the applicable hemorrhage protocol.',
      ],
      'European trauma bleeding guideline · Sixth edition (2023)',
      traumaLabSource,
      urgent: true,
    ),
    LabClinicalSection(
      'A normal result can be misleading',
      [
        'Fibrinogen is an acute-phase reactant and can remain normal despite consumption early in DIC. Follow the trend and other coagulation results.',
      ],
      'ARUP Consult · DIC evaluation',
      dicLabSource,
    ),
  ],
  'anti-xa': [
    LabClinicalSection(
      'Assay calibration & timing',
      [
        'Drug-specific calibrated anti-Xa assays can quantify the named direct Xa inhibitor. Confirm the drug, assay calibration, units, and timing relative to the last dose.',
        'Published on-therapy drug concentrations are not validated therapeutic ranges for titrating a DOAC dose.',
        'Heparin, LMWH, fondaparinux, and direct Xa inhibitors can interfere with anti-Xa measurements when more than one agent is present.',
      ],
      'ARUP Consult · Direct Xa inhibitor levels',
      xaLabSource,
    ),
    LabClinicalSection(
      'Procedural assessment is drug-specific',
      [
        'Regional-anesthesia recommendations depend on the agent, dose, elapsed time, renal function, and residual drug assessment where indicated.',
        'Do not substitute a normal PT/aPTT or a generic anti-Xa “normal” value for those recommendations.',
      ],
      'ASRA · Antithrombotic guideline, fifth edition (2025)',
      asraLabSource,
    ),
  ],
  'viscoelastic': [
    LabClinicalSection(
      'Hemorrhage assessment',
      [
        'The European trauma guideline supports early repeated hemostatic assessment using conventional tests and/or viscoelastic methods.',
        'Functional fibrinogen deficit and delayed clot initiation can inform protocol-based treatment alongside the clinical bleeding picture.',
        'Results vary across methods and operators. Use the local device, assay, and validated algorithm rather than transferring numeric cutoffs between platforms.',
        'Conventional PT/aPTT measured at 37°C may fail to reflect coagulopathy at the patient’s hypothermic temperature.',
      ],
      'European trauma bleeding guideline · Sixth edition (2023)',
      traumaLabSource,
    ),
  ],
  'd-dimer': [
    LabClinicalSection(
      'DIC and nonspecific elevation',
      [
        'D-dimer can rise with DIC, trauma, venous thromboembolism, and other conditions. An elevated result alone does not diagnose a specific cause.',
        'When evaluating DIC, integrate the underlying disorder, platelet trend, PT, fibrinogen, and serial results.',
        'DIC can evolve dynamically; repeat testing may be informative when clinical suspicion remains despite an initially nondiagnostic result.',
      ],
      'ARUP Consult · DIC evaluation',
      dicLabSource,
    ),
  ],
  'ionized-calcium': [
    LabClinicalSection(
      'Major trauma & massive transfusion',
      [
        'The European trauma guideline recommends monitoring ionized calcium and maintaining it in the normal range, especially during massive transfusion.',
        'In transfusion-associated hypocalcemia, ionized calcium <0.9 mmol/L warrants prompt correction in this trauma guidance; <0.8 mmol/L is associated with dysrhythmias.',
        'Ionized calcium is pH-dependent. Use the reporting laboratory’s interval; the trauma guideline cites 1.1–1.3 mmol/L, whereas the linked MedlinePlus adult example is 1.20–1.40 mmol/L.',
        'These trauma-specific thresholds are not interchangeable with a total-calcium reference range.',
      ],
      'European trauma bleeding guideline · Sixth edition (2023)',
      traumaLabSource,
      urgent: true,
    ),
  ],
  'magnesium': [
    LabClinicalSection(
      'Refractory electrolyte abnormalities',
      [
        'Consider magnesium deficiency with unexplained hypocalcemia or refractory hypokalemia. A normal serum magnesium does not reliably exclude depleted total-body stores.',
        'Coexisting potassium and calcium abnormalities may be difficult to correct until magnesium is replenished.',
        'Monitor closely during replacement, particularly with renal insufficiency or repeated parenteral doses.',
      ],
      'Merck Manual · Hypomagnesemia',
      'https://www.merckmanuals.com/professional/nephrology/electrolyte-disorders/hypomagnesemia',
    ),
    LabClinicalSection(
      'Severe symptomatic deficiency',
      [
        'Severe hypomagnesemia is usually <1.25 mg/dL. Seizures or other severe symptoms require urgent monitored management; the symptoms and clinical context matter alongside the concentration.',
      ],
      'Merck Manual · Hypomagnesemia',
      'https://www.merckmanuals.com/professional/nephrology/electrolyte-disorders/hypomagnesemia',
      urgent: true,
    ),
  ],
  'phosphate': [
    LabClinicalSection(
      'Perioperative depletion & redistribution',
      [
        'Consider depletion or shifts during refeeding after undernutrition, DKA recovery, alcohol-related illness, and severe respiratory alkalosis.',
        'Profound deficiency can cause muscle weakness, rhabdomyolysis, hemolysis, and neurologic dysfunction.',
      ],
      'Merck Manual · Hypophosphatemia',
      'https://www.merckmanuals.com/professional/nephrology/electrolyte-disorders/hypophosphatemia',
    ),
    LabClinicalSection(
      'Severe deficiency & replacement cautions',
      [
        'Phosphate <1 mg/dL (<0.32 mmol/L) is severe hypophosphatemia. Severe symptoms or profound depletion require prompt assessment for monitored replacement.',
        'IV replacement requires attention to calcium, phosphate, potassium, and kidney function; overly rapid administration can cause hypocalcemia and other complications.',
      ],
      'Merck Manual · Hypophosphatemia',
      'https://www.merckmanuals.com/professional/nephrology/electrolyte-disorders/hypophosphatemia',
      urgent: true,
    ),
  ],
  'lactate': [
    LabClinicalSection(
      'Perfusion & response to resuscitation',
      [
        'In major trauma, serial lactate helps assess tissue hypoperfusion and bleeding severity and follow response to treatment.',
        'Interpret the trend with the clinical picture; a single number is not a complete assessment of perfusion.',
      ],
      'European trauma bleeding guideline · Sixth edition (2023)',
      traumaLabSource,
      urgent: true,
    ),
    LabClinicalSection(
      'Sepsis: elevated does not mean one cause',
      [
        'Surviving Sepsis Campaign 2026 suggests measuring lactate in adults with possible, probable, or definite sepsis or septic shock, and using serial measurements when lactate is elevated or shock is present.',
        'After the initial fluid bolus, individualize further fluids and monitor lactate decrement rather than continuing fluid administration until lactate normalizes.',
      ],
      'SCCM · Surviving Sepsis Campaign (2026)',
      sepsisLabSource,
    ),
  ],
  'troponin': [
    LabClinicalSection(
      'Myocardial injury versus infarction',
      [
        'At least one troponin above the assay’s 99th-percentile upper reference limit defines myocardial injury. There is no universal numeric cutoff across assays.',
        'Serial change and clinical evidence of ischemia are needed to distinguish acute myocardial infarction from other myocardial injury.',
        'Interpret perioperative elevation with symptoms, hemodynamics, relevant cardiac findings, and the local serial-sampling pathway. Do not label every elevation as infarction or dismiss it solely because kidney disease is present.',
      ],
      'ACC · Fourth Universal Definition of Myocardial Infarction',
      troponinLabSource,
      urgent: true,
    ),
  ],
};
