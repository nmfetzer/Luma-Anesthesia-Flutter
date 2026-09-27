/// Initial Diagnostics content. This is a review draft, not a released library.
/// Intervals are examples from the linked source, never treatment thresholds.
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
    'Chemistry, renal markers, liver tests, and blood counts.',
    'CBC BMP CMP sodium potassium hemoglobin platelets electrolytes laboratory',
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
    'Focused cardiac, lung, vascular, and abdominal ultrasound.',
    'point of care ultrasound FAST',
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
  });
  final String id;
  final String title;
  final String group;
  final String interval;
  final List<String> bullets;
  final String intervalUrl;
  final String explanationUrl;
  final String aliases;
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
];

List<LabReference> searchLabReferences(String query, {String group = 'All'}) {
  final words = query.trim().toLowerCase().split(RegExp(r'\s+'));
  return labReferences.where((item) {
    final text =
        '${item.title} ${item.group} ${item.aliases} ${item.bullets.join(' ')}'
            .toLowerCase();
    return (group == 'All' || group == item.group) &&
        words.every(text.contains);
  }).toList();
}
