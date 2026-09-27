// Diagnostics content. This is a review draft, not a released library.
// Intervals are examples from the linked source, never treatment thresholds.
import 'lab_clinical_guidance.dart';
export 'lab_clinical_guidance.dart';

class DiagnosticCategory {
  const DiagnosticCategory(
    this.id,
    this.title,
    this.description,
    this.keywords,
  );
  final String id;
  final String title;
  final String description;
  final String keywords;
}

const diagnosticCategories = [
  DiagnosticCategory(
    'labs',
    'Lab Values',
    'Lab interpretation, coagulation, and critical abnormalities.',
    'CBC BMP CMP sodium potassium hemoglobin platelets electrolytes laboratory INR aPTT ACT heparin coagulation fibrinogen troponin lactate lactic acid CK CPK CK-MB CKMB',
  ),
  DiagnosticCategory(
    'abg',
    'ABG & Acid–Base',
    'Blood gases, acid–base patterns, and compensation.',
    'arterial blood gas bicarbonate pH PaCO2 oxygenation',
  ),
  DiagnosticCategory(
    'pfts',
    'Pulmonary Function Tests',
    'Spirometry, lung volumes, and diffusion capacity.',
    'PFT FEV1 FVC TLC DLCO pulmonary',
  ),
  DiagnosticCategory(
    'echo',
    'Echo / TEE',
    'Cardiac views, ventricular function, and valve assessment.',
    'echocardiography transesophageal transthoracic TTE',
  ),
  DiagnosticCategory(
    'imaging',
    'Imaging',
    'Chest imaging, lines and tubes, CT, and MRI safety.',
    'radiology CXR xray radiograph computed tomography',
  ),
  DiagnosticCategory(
    'pocus',
    'POCUS',
    'Focused cardiac, lung, gastric, and airway ultrasound.',
    'point of care ultrasound gastric airway IVC perfusion',
  ),
  DiagnosticCategory(
    'carotid',
    'Carotid Doppler',
    'Duplex findings, stenosis assessment, and perioperative context.',
    'duplex vascular carotid ultrasound stenosis',
  ),
];

List<DiagnosticCategory> searchDiagnosticCategories(String query) {
  final words = query.trim().toLowerCase().split(RegExp(r'\s+'));
  return diagnosticCategories.where((item) {
    final text =
        '${item.title} ${item.description} ${item.keywords}'.toLowerCase();
    return words.every(text.contains);
  }).toList();
}

class LabReference {
  const LabReference(
    this.id,
    this.title,
    this.group,
    this.interval,
    this.bullets,
    this.intervalUrl,
    this.explanationUrl, {
    this.aliases = '',
    this.intervalLabel = 'MedlinePlus · Reference interval',
    this.explanationLabel = 'MedlinePlus · Test interpretation',
    this.hasExampleInterval = true,
  });
  final String id;
  final String title;
  final String group;
  final String interval;
  final List<String> bullets;
  final String intervalUrl;
  final String explanationUrl;
  final String aliases;
  final String intervalLabel;
  final String explanationLabel;
  final bool hasExampleInterval;
  List<LabClinicalSection> get clinicalSections =>
      labClinicalGuidance[id] ?? const [];
  bool get hasUrgentContext => clinicalSections.any((s) => s.urgent);
}

const labResultsGuide =
    'https://medlineplus.gov/lab-tests/how-to-understand-your-lab-results/';
const _cmpRanges = 'https://medlineplus.gov/ency/article/003468.htm';
const _cmpMeaning =
    'https://medlineplus.gov/lab-tests/comprehensive-metabolic-panel-cmp/';
const _cbcRanges = 'https://medlineplus.gov/ency/article/003642.htm';
const _cbcMeaning =
    'https://medlineplus.gov/lab-tests/complete-blood-count-cbc/';
const _platelets = 'https://medlineplus.gov/ency/article/003647.htm';

const labReferences = [
  LabReference(
    'sodium',
    'Sodium (Na)',
    'Chemistry & Renal',
    '135–145 mEq/L',
    ['Electrolyte involved in fluid balance and acid–base balance.'],
    _cmpRanges,
    _cmpMeaning,
    aliases: 'Na+ BMP CMP electrolyte',
  ),
  LabReference(
    'potassium',
    'Potassium (K)',
    'Chemistry & Renal',
    '3.7–5.2 mEq/L',
    ['Electrolyte involved in fluid balance and acid–base balance.'],
    _cmpRanges,
    _cmpMeaning,
    aliases: 'K+ BMP CMP electrolyte',
  ),
  LabReference(
    'chloride',
    'Chloride (Cl)',
    'Chemistry & Renal',
    '96–106 mEq/L',
    ['Electrolyte involved in fluid balance and acid–base balance.'],
    _cmpRanges,
    _cmpMeaning,
    aliases: 'Cl BMP CMP electrolyte',
  ),
  LabReference(
    'co2',
    'Total CO₂ / Bicarbonate',
    'Chemistry & Renal',
    '23–29 mEq/L',
    [
      'The chemistry panel includes CO₂; bicarbonate is an electrolyte involved in acid–base balance.',
    ],
    _cmpRanges,
    _cmpMeaning,
    aliases: 'HCO3 CO2 bicarb BMP CMP',
  ),
  LabReference(
    'bun',
    'Blood Urea Nitrogen (BUN)',
    'Chemistry & Renal',
    '6–20 mg/dL',
    [
      'Waste product filtered from the blood by the kidneys and removed in urine.',
    ],
    _cmpRanges,
    _cmpMeaning,
    aliases: 'urea renal kidney BMP CMP',
  ),
  LabReference(
    'creatinine',
    'Creatinine',
    'Chemistry & Renal',
    '0.6–1.3 mg/dL',
    [
      'Waste product filtered from the blood by the kidneys.',
      'Reference values vary with age; use the reporting laboratory’s interval.',
    ],
    _cmpRanges,
    _cmpMeaning,
    aliases: 'Cr renal kidney BMP CMP',
  ),
  LabReference(
    'glucose',
    'Glucose (fasting)',
    'Chemistry & Renal',
    '70–100 mg/dL',
    [
      'Glucose is the body’s main source of energy.',
      'This source’s example interval is for a fasting sample; preparation and fasting status affect interpretation.',
    ],
    _cmpRanges,
    _cmpMeaning,
    aliases: 'blood sugar diabetes BMP CMP',
  ),
  LabReference(
    'calcium',
    'Total Calcium',
    'Chemistry & Renal',
    '8.5–10.2 mg/dL',
    [
      'Calcium is needed for nerve, muscle, and heart function.',
      'Most calcium in the body is stored in bones and teeth.',
    ],
    _cmpRanges,
    _cmpMeaning,
    aliases: 'Ca BMP CMP',
  ),
  LabReference(
    'albumin',
    'Albumin',
    'Liver & Proteins',
    '3.4–5.4 g/dL',
    ['The main protein in the blood; produced by the liver.'],
    _cmpRanges,
    _cmpMeaning,
    aliases: 'CMP protein',
  ),
  LabReference(
    'protein',
    'Total Protein',
    'Liver & Proteins',
    '6.0–8.3 g/dL',
    ['Measures total blood protein, including albumin and globulins.'],
    _cmpRanges,
    _cmpMeaning,
    aliases: 'CMP globulin',
  ),
  LabReference(
    'alp',
    'Alkaline Phosphatase (ALP)',
    'Liver & Proteins',
    '20–130 U/L',
    [
      'An enzyme included in the comprehensive metabolic panel.',
      'Interpret together with the other panel results, history, and medicines.',
    ],
    _cmpRanges,
    _cmpMeaning,
    aliases: 'CMP liver enzyme',
  ),
  LabReference(
    'alt',
    'Alanine Aminotransferase (ALT)',
    'Liver & Proteins',
    '4–36 U/L',
    [
      'An enzyme included in the comprehensive metabolic panel.',
      'Interpret together with the other panel results, history, and medicines.',
    ],
    _cmpRanges,
    _cmpMeaning,
    aliases: 'CMP SGPT liver enzyme',
  ),
  LabReference(
    'ast',
    'Aspartate Aminotransferase (AST)',
    'Liver & Proteins',
    '8–33 U/L',
    [
      'An enzyme included in the comprehensive metabolic panel.',
      'Interpret together with the other panel results, history, and medicines.',
    ],
    _cmpRanges,
    _cmpMeaning,
    aliases: 'CMP SGOT liver enzyme',
  ),
  LabReference(
    'bilirubin',
    'Total Bilirubin',
    'Liver & Proteins',
    '0.1–1.2 mg/dL',
    [
      'Waste product formed during breakdown of old red blood cells.',
      'The liver removes most bilirubin from the body.',
    ],
    _cmpRanges,
    _cmpMeaning,
    aliases: 'CMP liver',
  ),
  LabReference(
    'hemoglobin',
    'Hemoglobin (Hb)',
    'Blood Counts',
    'Male: 13–18 g/dL\nFemale: 12–16 g/dL',
    [
      'Iron-rich red blood cell protein that carries oxygen.',
      'Abnormal values can have several causes; assess with the clinical history and other results.',
    ],
    _cbcRanges,
    _cbcMeaning,
    aliases: 'Hgb CBC anemia oxygen',
  ),
  LabReference(
    'hematocrit',
    'Hematocrit (Hct)',
    'Blood Counts',
    'Male: 40–55%\nFemale: 36–48%',
    [
      'The fraction of whole blood composed of red blood cells.',
      'Abnormal values may accompany dehydration or anemia; the number alone does not establish a diagnosis.',
    ],
    _cbcRanges,
    _cbcMeaning,
    aliases: 'CBC anemia',
  ),
  LabReference(
    'wbc',
    'White Blood Cell Count (WBC)',
    'Blood Counts',
    '4,500–11,000 cells/µL',
    [
      'White blood cells help fight infection and other diseases.',
      'A high count may reflect infection or a medication reaction.',
      'A CBC with differential separately measures the types of white blood cells.',
    ],
    _cbcRanges,
    _cbcMeaning,
    aliases: 'CBC leukocytes infection',
  ),
  LabReference(
    'mcv',
    'Mean Corpuscular Volume (MCV)',
    'Blood Counts',
    '80–100 fL',
    ['The average size of red blood cells.'],
    _cbcRanges,
    _cbcMeaning,
    aliases: 'CBC anemia red cell indices',
  ),
  LabReference(
    'platelets',
    'Platelet Count',
    'Blood Counts',
    '150,000–400,000 platelets/µL',
    [
      'Platelets help blood clot.',
      'The example interval is from the dedicated platelet-count reference.',
    ],
    _platelets,
    _cbcMeaning,
    aliases: 'PLT CBC thrombocytes clotting',
  ),
  LabReference(
    'pt-inr',
    'PT / INR',
    'Coagulation',
    'PT: 11–13.5 seconds • INR: 0.8–1.1\nExample without anticoagulant therapy',
    [
      'PT assesses part of the clotting system. INR standardizes PT reporting for vitamin K antagonist monitoring.',
      'A warfarin treatment target is different from a healthy reference interval.',
    ],
    'https://medlineplus.gov/ency/article/003652.htm',
    coagulationLabSource,
    explanationLabel: 'ARUP Consult · Clotting-time interpretation',
    aliases: 'prothrombin warfarin clotting neuraxial',
  ),
  LabReference(
    'aptt',
    'aPTT / PTT',
    'Coagulation',
    '25–35 seconds',
    [
      'Measures part of the coagulation system and may be used to monitor heparin.',
      'The example interval is not an unfractionated-heparin treatment target; use the local assay and monitoring protocol.',
    ],
    'https://medlineplus.gov/ency/article/003653.htm',
    coagulationLabSource,
    explanationLabel: 'ARUP Consult · Clotting-time interpretation',
    aliases: 'activated partial thromboplastin heparin UFH clotting',
  ),
  LabReference(
    'act',
    'ACT / Activated Clotting Time',
    'Coagulation',
    'i-STAT Alinity Kaolin ACT baseline examples:\n74–137 sec (PREWRM) • 82–152 sec (NONWRM)',
    [
      'Rapid whole-blood assessment used to monitor high-dose heparin, particularly during cardiopulmonary bypass.',
      'Baseline reference ranges and anticoagulation targets answer different questions. Device, calibration, and procedure matter.',
    ],
    actDeviceSource,
    actGuidelineSource,
    intervalLabel: 'Abbott · Device-specific baseline ranges',
    explanationLabel: 'STS/SCA/AmSECT · CPB anticoagulation',
    aliases:
        'activated clotting time intraoperative intra-op heparin CPB bypass protamine antithrombin perfusion',
  ),
  LabReference(
    'fibrinogen',
    'Fibrinogen',
    'Coagulation',
    '200–400 mg/dL (2.0–4.0 g/L)',
    [
      'Liver-produced protein needed for clot formation.',
      'Interpret concentration with bleeding, platelet count, other coagulation tests, and serial trends.',
    ],
    'https://medlineplus.gov/ency/article/003650.htm',
    dicLabSource,
    explanationLabel: 'ARUP Consult · Consumption and DIC',
    aliases: 'factor I Clauss cryoprecipitate hemorrhage',
  ),
  LabReference(
    'anti-xa',
    'Anti-Xa / Direct Xa Inhibitor Levels',
    'Coagulation',
    'Drug-, assay-, and timing-specific',
    [
      'Confirm whether the test is calibrated for heparin or for a specific direct Xa inhibitor.',
      'Heparin anti-Xa activity and DOAC drug concentrations are not interchangeable results.',
    ],
    xaLabSource,
    asraLabSource,
    intervalLabel: 'ARUP Consult · Assay context',
    explanationLabel: 'ASRA · Regional-anesthesia guidance',
    hasExampleInterval: false,
    aliases: 'apixaban rivaroxaban edoxaban LMWH heparin DOAC',
  ),
  LabReference(
    'viscoelastic',
    'Viscoelastic Testing (TEG / ROTEM)',
    'Coagulation',
    'Device- and assay-specific intervals',
    [
      'Whole-blood clot assessment may complement conventional coagulation tests during major bleeding.',
      'Interpret within the local validated hemorrhage algorithm.',
    ],
    traumaLabSource,
    traumaLabSource,
    intervalLabel: 'European trauma guideline · Assay context',
    explanationLabel: 'European trauma guideline · Interpretation',
    hasExampleInterval: false,
    aliases:
        'thromboelastography rotational thromboelastometry VEM clot strength fibrinolysis',
  ),
  LabReference(
    'd-dimer',
    'D-dimer',
    'Coagulation',
    '≤500 ng/mL FEU\nMayo / HemosIL D-Dimer HS 500 example',
    [
      'Marker of fibrin breakdown; elevation is not specific to a single diagnosis.',
      'This card covers coagulation-pattern interpretation, not a stand-alone pulmonary embolism rule-out pathway.',
    ],
    dDimerIntervalSource,
    dicLabSource,
    intervalLabel: 'Mayo Clinic Laboratories · Assay-specific reference',
    explanationLabel: 'ARUP Consult · DIC interpretation',
    aliases: 'fibrin degradation DIC thrombosis',
  ),
  LabReference(
    'ionized-calcium',
    'Ionized Calcium',
    'Chemistry & Renal',
    '1.20–1.40 mmol/L (4.8–5.6 mg/dL)',
    [
      'Free calcium not attached to proteins.',
      'Use the local interval; published example intervals differ.',
    ],
    'https://medlineplus.gov/ency/article/003486.htm',
    traumaLabSource,
    explanationLabel: 'European trauma guideline · Transfusion context',
    aliases: 'iCa free calcium massive transfusion citrate',
  ),
  LabReference(
    'magnesium',
    'Magnesium (Mg)',
    'Chemistry & Renal',
    '1.7–2.2 mg/dL',
    [
      'Only a small proportion of total-body magnesium is measured in serum.',
      'An apparently normal serum value does not fully describe intracellular stores.',
    ],
    'https://medlineplus.gov/ency/article/003487.htm',
    'https://www.merckmanuals.com/professional/nephrology/electrolyte-disorders/hypomagnesemia',
    explanationLabel: 'Merck Manual · Hypomagnesemia',
    aliases: 'Mg2+ electrolyte',
  ),
  LabReference(
    'phosphate',
    'Phosphate / Phosphorus',
    'Chemistry & Renal',
    '2.8–4.5 mg/dL',
    [
      'Phosphate is important for nerve signaling and muscle contraction.',
      'Adult example only; children have a different reference interval.',
    ],
    'https://medlineplus.gov/ency/article/003478.htm',
    'https://www.merckmanuals.com/professional/nephrology/electrolyte-disorders/hypophosphatemia',
    explanationLabel: 'Merck Manual · Hypophosphatemia',
    aliases: 'PO4 phosphorus refeeding',
  ),
  LabReference(
    'lactate',
    'Lactate / Lactic Acid',
    'Perfusion & Cardiac Markers',
    '0.5–2.0 mmol/L\nMayo adult plasma L-lactate example',
    [
      'Trend in the clinical context rather than using a universal action cutoff.',
      'Elevation may reflect hypoperfusion, adrenergic stimulation, or reduced clearance; it is not an automatic fluid trigger.',
    ],
    lactateIntervalSource,
    sepsisLabSource,
    intervalLabel: 'Mayo Clinic Laboratories · Adult reference interval',
    explanationLabel: 'SCCM · Sepsis interpretation',
    aliases: 'lactic acid shock hypoperfusion',
  ),
  LabReference(
    'troponin',
    'Cardiac Troponin',
    'Perfusion & Cardiac Markers',
    'Use the local assay’s upper reference limit\nMayo hs-cTnT example: males ≤15 / females ≤10 ng/L',
    [
      'Use the reporting laboratory’s troponin assay, units, and upper reference limit.',
      'An elevated troponin indicates myocardial injury, not automatically infarction.',
    ],
    troponinIntervalSource,
    troponinLabSource,
    intervalLabel: 'Mayo Clinic Laboratories · Troponin T Gen 5 example',
    explanationLabel: 'ACC · Myocardial injury interpretation',
    hasExampleInterval: false,
    aliases: 'hs-cTn cTnI cTnT myocardial injury ischemia',
  ),
  LabReference(
    'ck',
    'Creatine Kinase / CPK',
    'Perfusion & Cardiac Markers',
    'Males: 39–308 U/L • Females: 26–192 U/L\nMayo adult total CK example',
    [
      'CK and CPK are names for the same total creatine kinase test.',
      'A muscle-injury marker, not a cardiac-specific test. Interpret postoperative elevations with the mechanism of injury and serial trends.',
    ],
    ckIntervalSource,
    rhabdomyolysisSource,
    intervalLabel: 'Mayo Clinic Laboratories · Adult CK interval',
    explanationLabel: 'AAST · Rhabdomyolysis interpretation',
    aliases: 'CK CPK creatine phosphokinase rhabdomyolysis muscle injury CK-MM',
  ),
  LabReference(
    'ck-mb',
    'CK-MB',
    'Perfusion & Cardiac Markers',
    '0.0–3.5 ng/mL\nAbbott i-STAT CK-MB mass example',
    [
      'A CK isoenzyme measured as mass on this platform; not equivalent to total CK activity or a CK-MB relative index.',
      'Less cardiac-specific than troponin. Surgical skeletal muscle injury can also elevate CK-MB.',
    ],
    ckMbIntervalSource,
    troponinLabSource,
    intervalLabel: 'Abbott · i-STAT CK-MB reference interval',
    explanationLabel: 'ACC · Preferred myocardial-injury biomarker',
    aliases: 'CKMB CK MB creatine kinase MB cardiac enzyme infarction',
  ),
];

List<LabReference> searchLabReferences(
  String query, {
  String group = 'All',
  bool urgentOnly = false,
}) {
  final words = query.trim().toLowerCase().split(RegExp(r'\s+'));
  return labReferences.where((item) {
    final text =
        '${item.title} ${item.group} ${item.aliases} ${item.bullets.join(' ')} '
                '${item.clinicalSections.map((s) => '${s.title} ${s.bullets.join(' ')}').join(' ')}'
            .toLowerCase();
    return (!urgentOnly || item.hasUrgentContext) &&
        (group == 'All' || group == item.group) &&
        words.every(text.contains);
  }).toList();
}
