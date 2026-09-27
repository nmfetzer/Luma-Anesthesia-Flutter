// Adult clinician reference drafts. No production publication or clinical signoff.
import 'abg_content.dart';

const pftSource =
    'https://www.swordmedical.ie/wp-content/uploads/2022/10/ERSATS-technical-standard-on-interpretive-.pdf';
const preopLungSource =
    'https://apccmpd.memberclicks.net/assets/AmbulatoryCareWorkgroup/Year_1_Scripts/2025/20_Preoperative_Pulmonary_Eval_2025.pdf';
const lungResectionSource =
    'https://air.unimi.it/bitstream/2434/1180118/2/Breathe.pdf';
const lungGuidelineSource = 'https://pubmed.ncbi.nlm.nih.gov/41232938/';
const rightHeartSource =
    'https://www.asecho.org/wp-content/uploads/2025/03/PIIS0894731725000379.pdf';
const echoSource = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC4676442/';
const diastolicSource =
    'https://www.asecho.org/wp-content/uploads/2025/07/Left-Ventricular-Diastolic-Function.pdf';
const asSource =
    'https://www.openanesthesia.org/keywords/aortic-stenosis-hemodynamic-management-comorbidities-and-treatment/';
const teeSource = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC11239508/';
const cxrSource = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC2700481/';
const atelectasisSource = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC9885487/';
const contrastSource =
    'https://geiselmed.dartmouth.edu/radiology/wp-content/uploads/sites/47/2024/08/ACR-contrast-2024.pdf';
const contrastAllergySource =
    'https://pmc.ncbi.nlm.nih.gov/articles/PMC12568759/';
const mrSource =
    'https://www.openanesthesia.org/keywords/magnetic-resonance-imaging-safety/';
const mrAdvancedSource =
    'https://www.openanesthesia.org/keywords/magnetic-resonance-imaging-safety-advanced/';
const pocusSource =
    'https://www.anzca.edu.au/getContentAsset/8ca3291d-4f5b-4434-8433-78bfcd239b7f/80feb437-d24d-46b8-a858-4a2a28b9b970/PG47-Perioperative-diagnostic-POCUS-2025.pdf';
const gastricSource = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC7808010/';
const lungUsSource = 'https://pmc.ncbi.nlm.nih.gov/articles/PMC8439137/';
const carotidCriteriaSource =
    'https://intersocietal.org/wp-content/uploads/2023/11/IAC-Updated-Recommendations-for-Carotid-Stenosis-Interpretation-Criteria_11.1.23.pdf';
const carotidGuidelineSource =
    'https://pure.amsterdamumc.nl/ws/files/163490149/Editors-choice--european-society-for-vascular-surgery-esvs-2023-clinical-practice-guidelines-on-the-management-of-at.pdf';

class ClinicalModule {
  const ClinicalModule(
    this.id,
    this.title,
    this.heading,
    this.description,
    this.hint,
    this.topics,
  );
  final String id, title, heading, description, hint;
  final List<AbgTopic> topics;
  List<String> get groups => ['All', ...topics.map((t) => t.group).toSet()];
}

List<AbgTopic> searchClinicalTopics(
  ClinicalModule module,
  String query, {
  String group = 'All',
}) {
  String normalize(String s) => s
      .toLowerCase()
      .replaceAll('₂', '2')
      .replaceAll('₁', '1')
      .replaceAll(RegExp('[–−-]'), ' ');
  final words = normalize(query).trim().split(RegExp(r'\s+'));
  return module.topics.where((t) {
    final text = normalize('${t.title} ${t.group} ${t.summary} ${t.aliases} '
        '${t.sections.map((s) => '${s.title} ${s.bullets.join(' ')}').join(' ')} '
        '${t.differential.map((r) => '${r.process} ${r.clues} ${r.focus}').join(' ')}');
    return (group == 'All' || t.group == group) && words.every(text.contains);
  }).toList();
}

const clinicalModules = <ClinicalModule>[
  ClinicalModule(
    'pfts',
    'Pulmonary Function Tests',
    'Pulmonary reserve & operative risk',
    'Interpret the pattern, reconcile discordant results, and identify what changes the anesthetic plan.',
    'DLCO, obstruction, bronchodilator…',
    pftTopics,
  ),
  ClinicalModule(
    'echo',
    'Echo / TEE',
    'Perioperative hemodynamic questions',
    'Ventricular function, filling, valves, and obstructive physiology. Read the study in its hemodynamic context.',
    'RV failure, tamponade, LVOTO…',
    echoTopics,
  ),
  ClinicalModule(
    'imaging',
    'Imaging',
    'Imaging that changes perioperative care',
    'Chest findings, device complications, contrast decisions, and safe care beyond the operating room.',
    'Atelectasis, pneumothorax, MRI…',
    imagingTopics,
  ),
  ClinicalModule(
    'pocus',
    'POCUS',
    'Focused answers at the bedside',
    'Cardiac, lung, gastric, and airway findings with practical limits. Focused ultrasound complements, not replaces, definitive assessment.',
    'B-lines, gastric, IVC, shock…',
    pocusTopics,
  ),
  ClinicalModule(
    'carotid',
    'Carotid Doppler',
    'Carotid findings in perioperative context',
    'Native-vessel grading, discordant studies, symptomatic disease, and care around carotid intervention.',
    'PSV, near occlusion, stent…',
    carotidTopics,
  ),
];

const pftTopics = <AbgTopic>[
  AbgTopic(
    'pft-pattern',
    'Obstruction, restriction, or a mixed pattern?',
    'Interpretation',
    'Use the ratio and TLC together; a low FVC alone is not restriction.',
    'FEV1 FVC TLC LLN z score spirometry',
    [
      AbgSection(
        'Read the physiology, not just the flag',
        [
          'Use the laboratory reference equation and lower limit of normal (LLN). The usual LLN is the fifth percentile, approximately z = −1.645; 80% predicted is not a universal normal boundary.',
          'A low FEV₁/FVC supports airflow obstruction. A fixed ratio of 0.70 can misclassify age-related normality; disease-specific diagnostic criteria and physiologic interpretation are not interchangeable.',
          'Check acceptability, repeatability, effort, and the flow–volume curves before interpreting a marginal result. Normal spirometry does not exclude pulmonary disease.',
        ],
        'ERS/ATS · PFT interpretation',
        pftSource,
      ),
      AbgSection(
        'What a low FVC can conceal',
        [
          'Low FVC with obstruction may reflect air trapping, not a second restrictive disorder. Confirm restriction with a TLC below its LLN.',
          'Low FEV₁ and FVC with a preserved ratio and normal TLC is a nonspecific pattern. Poor effort, small-airway disease, and evolving disease are possible; review prior testing and symptoms.',
          'Marked RV/TLC elevation supports air trapping. Measurement method matters: gas dilution may miss poorly ventilated trapped gas, while plethysmography can overestimate volumes in severe obstruction.',
        ],
        'ERS/ATS · Lung volumes',
        pftSource,
        caution: true,
      ),
      AbgSection(
        'Translate the result into a preoperative question',
        [
          'Ask whether the result explains dyspnea, identifies uncontrolled disease, or changes optimization and postoperative support.',
          'For nonthoracic surgery, do not use an isolated FEV₁ value as an automatic cancellation threshold. Procedure, urgency, exercise tolerance, and current respiratory status remain central.',
          'Escalate unexplained or newly worsened limitation rather than labeling every abnormal pattern as stable COPD.',
        ],
        'APCCMPD · Preoperative pulmonary evaluation',
        preopLungSource,
      ),
    ],
    differential: [
      AbgDifferential(
        'Obstruction',
        'FEV₁/FVC below LLN.',
        'Assess severity, bronchodilator response, symptoms, and air trapping; the pattern does not identify the cause by itself.',
        'ERS/ATS',
        pftSource,
      ),
      AbgDifferential(
        'Restriction',
        'TLC below LLN; ratio often preserved or high.',
        'Separate parenchymal disease from chest-wall, obesity-related, or neuromuscular limitation using clinical context and gas transfer.',
        'ERS/ATS',
        pftSource,
      ),
      AbgDifferential(
        'Mixed defect',
        'Both FEV₁/FVC and TLC below LLN.',
        'Confirm true restriction rather than inferring it from FVC; correlate with imaging and the history.',
        'ERS/ATS',
        pftSource,
      ),
    ],
  ),
  AbgTopic(
      'pft-response',
      'Bronchodilator response & unreliable spirometry',
      'Interpretation',
      'A meaningful response is not the same as an asthma diagnosis.',
      'reversibility asthma quality predicted post pre', [
    AbgSection(
      'Use the correct denominator',
      [
        'The 2022 ERS/ATS response criterion is an increase greater than 10% of the predicted value in FEV₁ or FVC.',
        'Response (%) = 100 × (post-bronchodilator − pre-bronchodilator) / predicted value. This is not a 10% increase from the baseline measurement.',
        'Some reports use earlier criteria. Identify the standard used before comparing reports or describing a change over time.',
      ],
      'ERS/ATS · Bronchodilator response',
      pftSource,
    ),
    AbgSection(
      'Interpret a positive or negative result',
      [
        'Bronchodilator responsiveness alone does not reliably distinguish asthma from COPD. A negative test does not exclude clinically important variable airflow obstruction.',
        'An FVC response may reflect reduced air trapping. Review changes in both FEV₁ and FVC rather than reading only the response label.',
        'Confirm pretest medication instructions, timing, adequate maneuvers, and repeatability when the finding is unexpected.',
      ],
      'ERS/ATS · Interpretation limits',
      pftSource,
    ),
    AbgSection(
      'Perioperative relevance',
      [
        'Current wheeze, recent exacerbation, infection, and a change from baseline may matter more immediately than a remote bronchodilator test.',
        'Use an abnormal result to guide disease assessment and optimization, not to independently prescribe a new chronic regimen or declare a patient fit for surgery.',
      ],
      'APCCMPD · Preoperative pulmonary evaluation',
      preopLungSource,
    ),
  ]),
  AbgTopic(
      'pft-dlco',
      'Low DLCO with or without abnormal spirometry',
      'Gas transfer',
      'Reconcile hemoglobin, lung volume, and the clinical differential.',
      'diffusion KCO VA anemia emphysema pulmonary vascular ILD', [
    AbgSection(
      'Verify what was measured',
      [
        'Interpret DLCO against the appropriate reference range and hemoglobin correction. Anemia can lower measured gas transfer without primary parenchymal disease.',
        'Review inspired volume, breath-hold quality, and alveolar volume (VA). DLCO, KCO, and VA describe related but different aspects of gas transfer.',
        'A normal KCO does not simply correct or normalize a low VA. Do not dismiss a low DLCO because DLCO/VA is within range.',
      ],
      'ERS/ATS · Gas transfer',
      pftSource,
    ),
    AbgSection(
      'Use the associated pattern',
      [
        'Low DLCO with preserved spirometry can warrant evaluation for pulmonary vascular disease, early parenchymal disease, emphysema, or anemia.',
        'Low DLCO with restriction raises concern for parenchymal loss or interstitial disease; preserved gas transfer in a restrictive pattern may suggest an extrapulmonary mechanism.',
        'Interpret an unexpectedly high DLCO in context, including asthma, increased pulmonary blood volume, or alveolar hemorrhage; it is not a stand-alone marker of good reserve.',
      ],
      'ERS/ATS · DLCO differential',
      pftSource,
    ),
    AbgSection(
      'Anesthesia implications',
      [
        'For lung resection, DLCO contributes risk information independently of FEV₁. A reassuring FEV₁ does not make a severely impaired DLCO irrelevant.',
        'Integrate gas transfer with planned resection, predicted postoperative function, functional capacity, and the multidisciplinary assessment.',
        'Do not convert DLCO directly into an oxygen prescription, ventilator setting, or single operability threshold.',
      ],
      'Breathe · Lung resection assessment',
      lungResectionSource,
    ),
  ]),
  AbgTopic(
      'pft-loop',
      'Flow–volume loops & suspected central airway obstruction',
      'Airway',
      'Loop morphology can prompt investigation but cannot clear the airway.',
      'stridor extrathoracic intrathoracic fixed tracheal stenosis', [
    AbgSection(
      'Recognize a pattern worth investigating',
      [
        'Variable extrathoracic obstruction tends to flatten the inspiratory limb. Variable intrathoracic obstruction tends to flatten the expiratory limb.',
        'Fixed central obstruction may flatten both inspiratory and expiratory limbs.',
        'Repeatability matters: submaximal inspiration, poor effort, and technical problems can mimic abnormal loop morphology.',
      ],
      'ERS/ATS · Central airway obstruction',
      pftSource,
    ),
    AbgSection(
      'Do not use a normal loop as airway clearance',
      [
        'A normal or equivocal loop does not exclude clinically important anatomic obstruction.',
        'Reconcile stridor, positional symptoms, prior airway instrumentation, and available imaging with the physiologic finding.',
        'Suspected central obstruction calls for anatomic assessment and an individualized airway plan rather than treatment as routine lower-airway bronchospasm.',
      ],
      'ERS/ATS · Interpretation limitations',
      pftSource,
      caution: true,
    ),
  ]),
  AbgTopic(
      'pft-resection',
      'Lung resection: predicted postoperative reserve',
      'Operative risk',
      'Move beyond preoperative FEV₁ and account for the functioning lung removed.',
      'ppoFEV1 ppoDLCO CPET VO2 lobectomy pneumonectomy', [
    AbgSection(
      'Estimate the remaining functional lung',
      [
        'Assess both FEV₁ and DLCO. Predicted postoperative values estimate remaining function after the proposed resection.',
        'Conceptually: predicted postoperative value = preoperative value × (1 − fraction of total functioning lung removed). Retain the original units or percent-predicted convention consistently.',
        'Simple segment counting assumes similar contribution from each functioning segment. Obstructed segments, emphysema, and heterogeneous perfusion can invalidate that assumption.',
      ],
      'Breathe · Predicted postoperative function',
      lungResectionSource,
    ),
    AbgSection(
      'When the estimate is not enough',
      [
        'Quantitative perfusion or imaging-based assessment can help when regional function is uneven, especially for pneumonectomy planning.',
        'Exercise assessment and CPET add information about integrated cardiopulmonary reserve when resting measurements are impaired or discordant.',
        'Predicted postoperative tests do not fully represent the immediate postoperative period; pain, atelectasis, complications, and recovery affect early function.',
      ],
      'Breathe · Functional evaluation',
      lungResectionSource,
    ),
    AbgSection(
      'Use a multidisciplinary fitness decision',
      [
        'The 2025 ERS/ESTS guideline integrates pulmonary function, split-lung function, exercise testing, cardiac assessment, comorbidity, and prehabilitation.',
        'Discuss the planned extent of resection and alternatives with the thoracic team. A single percentage should not substitute for the current institutional pathway or shared risk assessment.',
        'Record which guideline and prediction method were used rather than applying an unlabeled high-risk cutoff.',
      ],
      'ERS/ESTS 2025 · Guideline record',
      lungGuidelineSource,
    ),
  ]),
  AbgTopic(
      'pft-preop',
      'When PFTs change the anesthetic plan',
      'Operative risk',
      'Target testing to a clinical question rather than a routine clearance ritual.',
      'dyspnea COPD asthma optimization nonthoracic postoperative', [
    AbgSection(
      'Useful reasons to investigate',
      [
        'Unexplained dyspnea, a meaningful change in respiratory status, uncertain disease severity, or planning lung resection can justify targeted pulmonary assessment.',
        'Routine spirometry for every asymptomatic nonthoracic surgical patient is not a useful substitute for history and examination.',
        'Assess exercise tolerance, recent exacerbations, oxygen or ventilatory support, and prior postoperative respiratory complications.',
      ],
      'APCCMPD · Preoperative pulmonary evaluation',
      preopLungSource,
    ),
    AbgSection(
      'Link the findings to care',
      [
        'Identify opportunities to optimize active airway disease, infection, smoking-related risk, secretion management, and functional conditioning.',
        'Combine patient factors with procedure location, expected duration, urgency, and likely postoperative pain or respiratory limitation.',
        'Discuss postoperative monitoring and respiratory support when reserve is limited; avoid treating a test result as a guarantee of uncomplicated extubation.',
      ],
      'APCCMPD · Perioperative pulmonary risk',
      preopLungSource,
    ),
    AbgSection(
      'Avoid false precision',
      [
        'A stable abnormal result and an acute clinical deterioration are different problems. Review trends and the circumstances of testing.',
        'No isolated FEV₁ result universally contraindicates all surgery. The clinical decision depends on the operation and the patient, not a laboratory flag.',
      ],
      'APCCMPD · Decision context',
      preopLungSource,
      caution: true,
    ),
  ]),
];

const echoTopics = <AbgTopic>[
  AbgTopic(
    'echo-shock',
    'Hypotension: distinguish the hemodynamic phenotype',
    'Shock',
    'Assess both ventricles, obstruction, and forward flow before choosing a response.',
    'low output shock hypovolemia vasodilation LV RV VTI',
    [
      AbgSection(
        'Ask a focused hemodynamic question',
        [
          'Integrate ventricular size and function, pericardium, valve findings, and Doppler flow with blood pressure, rhythm, ventilation, and the procedural timeline.',
          'Mixed mechanisms are common. A patient can have vasodilation, ventricular dysfunction, and inadequate filling simultaneously.',
          'Repeat imaging after an intervention. A change in physiology may be more useful than one isolated image.',
        ],
        'Critical Care · Echo in shock',
        echoSource,
      ),
      AbgSection(
        'Forward flow is not the same as ejection fraction',
        [
          'Stroke volume ≈ LVOT cross-sectional area × LVOT VTI. With area in cm² and VTI in cm, stroke volume is in mL; cardiac output = stroke volume × heart rate.',
          'LVOT area = π × (diameter/2)². Diameter error is squared, so serial VTI may be more reproducible than repeatedly recalculating an uncertain diameter.',
          'Maintain sampling position, Doppler alignment, and comparable rhythm/loading when following trends. A small hyperdynamic LV does not by itself prove fluid responsiveness.',
        ],
        'Critical Care · Doppler assessment',
        echoSource,
        caution: true,
      ),
    ],
    differential: [
      AbgDifferential(
        'Low filling / vasodilation',
        'Small or hyperdynamic LV may be seen; chamber appearance alone is nonspecific.',
        'Correlate with bleeding, vasodilatory context, and a reversible dynamic assessment rather than reflexively giving fluid.',
        'Critical Care',
        echoSource,
      ),
      AbgDifferential(
        'LV pump dysfunction',
        'Reduced global function or new regional abnormality; forward flow may be low.',
        'Assess ischemia, loading, rhythm, and mechanical/valvular causes. Compare with baseline.',
        'Critical Care',
        echoSource,
      ),
      AbgDifferential(
        'RV or obstructive physiology',
        'RV dilation/dysfunction, septal shift, pericardial compression, or dynamic outflow obstruction.',
        'Identify the mechanism because indiscriminate fluid or inotropy may worsen some phenotypes.',
        'Critical Care',
        echoSource,
      ),
    ],
  ),
  AbgTopic(
      'echo-lv',
      'LV function, regional wall motion & low output',
      'Ventricles',
      'Read EF alongside loading conditions and effective forward flow.',
      'ejection fraction RWMA ischemia cardiomyopathy mitral regurgitation', [
    AbgSection(
      'What a reported EF does and does not say',
      [
        'EF is load dependent. Induction, vasodilation, positive-pressure ventilation, and vasoactive treatment can change the apparent performance.',
        'Preserved or hyperdynamic EF does not exclude low stroke volume, significant regurgitation, or impaired filling.',
        'Compare current findings with the prior study and the blood pressure and rhythm at acquisition.',
      ],
      'Critical Care · LV assessment',
      echoSource,
    ),
    AbgSection(
      'New regional dysfunction',
      [
        'Review more than one view before attributing a regional wall-motion abnormality to ischemia; image quality and existing abnormalities matter.',
        'New dysfunction during instability requires correlation with ECG, perfusion, procedural events, and other evidence of ischemia or mechanical complications.',
        'A focused examination cannot reliably exclude coronary ischemia or replace a comprehensive diagnostic study.',
      ],
      'Critical Care · Regional function',
      echoSource,
    ),
    AbgSection(
      'Perioperative interpretation',
      [
        'Follow effective forward flow and the response to treatment, not only a visual EF estimate.',
        'If hypotension persists despite a seemingly vigorous LV, reassess RV function, dynamic LV outflow obstruction, valve lesions, and vasodilatory or hypovolemic mechanisms.',
        'Document incomplete windows and uncertainty rather than calling an inadequately visualized ventricle normal.',
      ],
      'Critical Care · Integrated shock assessment',
      echoSource,
    ),
  ]),
  AbgTopic(
      'echo-rv',
      'RV dysfunction & pulmonary hypertension',
      'Ventricles',
      'Use multiple RV measures; pressure estimates can fail in severe disease.',
      'TAPSE S prime FAC RVSP PASP tricuspid PH septal D shaped', [
    AbgSection(
      'Useful reference measurements',
      [
        'ASE 2025 normal reference values include TAPSE >1.7 cm, tissue Doppler tricuspid S′ >9.5 cm/s, and RV fractional area change >35%.',
        'Assess size, global appearance, septal configuration, and more than one functional measure. TAPSE and S′ emphasize basal longitudinal motion, not all components of RV performance.',
        'Postoperative geometry, loading, and image alignment can alter these measurements; an isolated abnormal number should not define the whole RV phenotype.',
      ],
      'ASE 2025 · Right heart',
      rightHeartSource,
    ),
    AbgSection(
      'Read pressure estimates cautiously',
      [
        'Estimated RVSP = 4 × peak TR velocity² + estimated right atrial pressure, with velocity in m/s and pressure in mmHg.',
        'RVSP approximates pulmonary artery systolic pressure only when there is no RV outflow or pulmonic obstruction.',
        'Poor Doppler alignment, an incomplete TR envelope, severe TR, and inaccurate right atrial pressure estimation can mislead. Low estimated pressure is not reassuring when RV output is severely impaired.',
      ],
      'ASE 2025 · Pressure estimation',
      rightHeartSource,
      caution: true,
    ),
    AbgSection(
      'Clinical implications',
      [
        'Echo estimates the probability and consequences of pulmonary hypertension; right-heart catheterization establishes hemodynamic classification when indicated.',
        'Positive-pressure ventilation limits simple IVC-based pressure interpretation. Reassess in the actual ventilatory and hemodynamic context.',
        'RV dilation and septal flattening are not specific for acute pulmonary embolism. Chronic pressure overload, volume overload, and other causes require consideration.',
      ],
      'ASE 2025 · Integrated RV evaluation',
      rightHeartSource,
    ),
  ]),
  AbgTopic(
      'echo-diastolic',
      'Diastolic dysfunction & filling-pressure reports',
      'Filling & valves',
      'Use the preoperative report intelligently; do not transplant outpatient cutoffs into the OR.',
      'HFpEF E e prime E/e LA pressure atrial fibrillation', [
    AbgSection(
      'Read the report beyond “normal EF”',
      [
        'Review diastolic grade, estimated filling-pressure status, left atrial size, rhythm, and associated valve disease.',
        'Normal resting filling pressure does not exclude exertional HFpEF. Symptoms and the clinical trajectory remain important.',
        'The 2025 ASE approach is multiparametric and includes separate pathways for special populations; no single E/e′ value establishes the diagnosis.',
      ],
      'ASE 2025 · Diastolic function',
      diastolicSource,
    ),
    AbgSection(
      'Important scope boundary',
      [
        'The 2025 ASE diastolic guideline explicitly states that its algorithms should not be applied in intraoperative settings.',
        'Mitral inflow and other indices are affected by preload, heart rate, rhythm, and blood pressure. Do not turn a preoperative diagnostic threshold into an intraoperative fluid target.',
        'Use intraoperative findings as part of an integrated hemodynamic assessment, with expert interpretation when uncertainty would change treatment.',
      ],
      'ASE 2025 · Scope and limitations',
      diastolicSource,
      caution: true,
    ),
    AbgSection(
      'Situations that break simple interpretation',
      [
        'Atrial fibrillation requires appropriately selected and averaged cycles; E/A is not interpreted as it is in sinus rhythm.',
        'Mitral stenosis, significant mitral annular calcification, prosthetic mitral valves, and significant MR can invalidate routine filling-pressure assumptions.',
        'Tachycardia or conduction abnormalities can fuse inflow waves. Poor Doppler signals should be reported as inadequate, not used to produce a confident grade.',
      ],
      'ASE 2025 · Special populations',
      diastolicSource,
    ),
  ]),
  AbgTopic(
      'echo-as',
      'Aortic stenosis & discordant valve findings',
      'Filling & valves',
      'Severity, symptoms, flow, and the planned operation belong in the same assessment.',
      'AS valve gradient low flow low gradient aortic', [
    AbgSection(
      'Start with the whole valve report',
      [
        'Review valve anatomy, Doppler findings, LV function, associated lesions, and comparison with prior studies rather than relying on one gradient.',
        'Flow and Doppler alignment influence gradients. A low gradient during low output does not necessarily imply a mild lesion.',
        'A newly recognized or discordant important valve lesion warrants comprehensive echo and specialist assessment; a focused scan is not definitive valve grading.',
      ],
      'Critical Care · Valvular assessment',
      echoSource,
    ),
    AbgSection(
      'Anesthesia implications of significant AS',
      [
        'Preserve coronary perfusion and avoid abrupt loss of systemic vascular resistance. Maintain appropriate preload while avoiding indiscriminate fluid loading.',
        'Preserve sinus rhythm and avoid marked heart-rate extremes; both filling time and myocardial oxygen balance matter.',
        'Monitoring and vasoactive access should match severity, symptoms, comorbidity, and procedural stress. TEE can be useful when appropriate and safe.',
      ],
      'OpenAnesthesia · AS management',
      asSource,
    ),
    AbgSection(
      'Symptoms change the decision',
      [
        'Dyspnea, angina, or syncope in a patient with significant AS should prompt assessment of symptom attribution and valve-management options.',
        'Elective planning should distinguish compensated asymptomatic disease from symptomatic or decompensated disease.',
        'Do not use an anesthetic hemodynamic plan as a substitute for deciding whether valve evaluation or intervention is needed first.',
      ],
      'OpenAnesthesia · AS clinical context',
      asSource,
      caution: true,
    ),
  ]),
  AbgTopic(
    'echo-obstruction',
    'Tamponade versus dynamic LV outflow obstruction',
    'Shock',
    'Two obstructive mechanisms with very different responses to treatment.',
    'pericardial effusion LVOTO SAM systolic anterior motion',
    [
      AbgSection(
        'Pericardial fluid is not synonymous with tamponade',
        [
          'Assess the hemodynamic context, chamber compression, venous congestion, and Doppler findings together. Effusion size alone does not determine physiologic severity.',
          'Localized postoperative collections can produce atypical compression and may be missed in limited transthoracic views.',
          'An unstable patient with suspected pericardial compression needs urgent expert assessment and a drainage strategy; do not wait for every classic echo sign.',
        ],
        'Critical Care · Tamponade assessment',
        echoSource,
        caution: true,
      ),
      AbgSection(
        'Recognize dynamic LVOTO',
        [
          'Look for a small hyperdynamic ventricle, systolic anterior motion of the mitral valve, and a late-peaking outflow Doppler profile when acquired correctly.',
          'Reduced filling, reduced afterload, and increased contractility can worsen dynamic obstruction. Associated MR can contribute to deterioration.',
          'Escalating inotropy for presumed pump failure may worsen this phenotype. Reassess the mechanism and adjust loading and vasoactive strategy with appropriate expertise.',
        ],
        'Critical Care · Dynamic obstruction',
        echoSource,
        caution: true,
      ),
      AbgSection(
        'Confirm before simplifying',
        [
          'A technically limited study is not a negative study. Consider TEE or comprehensive imaging when the result would change urgent management and it can be obtained safely.',
          'Repeat assessment after treatment; loading changes can resolve or unmask dynamic obstruction.',
        ],
        'Critical Care · Serial evaluation',
        echoSource,
      ),
    ],
    differential: [
      AbgDifferential(
        'Pericardial compression',
        'Effusion or localized collection plus compatible hemodynamic effects.',
        'Urgent assessment of drainage and the cause; size alone is insufficient.',
        'Critical Care',
        echoSource,
      ),
      AbgDifferential(
        'Dynamic LVOTO',
        'Hyperdynamic small LV, SAM, late-peaking outflow signal.',
        'Avoid reflex escalation of inotropy; reassess preload, afterload, and contractility.',
        'Critical Care',
        echoSource,
      ),
    ],
  ),
  AbgTopic(
      'echo-tee',
      'TEE: value, contraindications & complications',
      'Safety',
      'A powerful perioperative examination with a separate procedural risk assessment.',
      'esophageal stricture varices dysphagia bleeding probe', [
    AbgSection(
      'Choose the modality deliberately',
      [
        'TEE may answer important questions when transthoracic windows are poor or rapid intraoperative hemodynamic assessment is needed.',
        'Balance the expected diagnostic benefit against esophageal, gastric, airway, and bleeding risks. Consider TTE or another modality when risk outweighs benefit.',
        'A focused TEE examination and a comprehensive diagnostic examination require different scope and expertise.',
      ],
      'Frontiers · TEE complications',
      teeSource,
    ),
    AbgSection(
      'Screen before probe placement',
      [
        'Known esophageal obstruction or stricture, suspected perforation, and active upper gastrointestinal bleeding are major concerns that can preclude examination.',
        'Prior esophageal or gastric surgery, dysphagia, radiation, varices, coagulopathy, and limited neck mobility require individualized review.',
        'Do not force advancement against resistance. Unexpected difficulty should prompt stopping and reassessing rather than repeated blind attempts.',
      ],
      'Frontiers · TEE safety',
      teeSource,
      caution: true,
    ),
    AbgSection(
      'After the examination',
      [
        'New chest or neck pain, dysphagia, bleeding, or unexplained deterioration may signal injury; esophageal complications can present late.',
        'Account for sedation-related airway obstruction, hypoxemia, and hemodynamic effects as well as mechanical probe complications.',
        'Document limitations, important findings, and any insertion difficulty or concern requiring follow-up.',
      ],
      'Frontiers · Recognition of complications',
      teeSource,
    ),
  ]),
];

const imagingTopics = <AbgTopic>[
  AbgTopic(
    'imaging-hypoxemia',
    'New hypoxemia: read the chest image in context',
    'Chest findings',
    'A portable film can narrow the differential but cannot exclude important disease.',
    'CXR opacity edema effusion atelectasis aspiration pneumonia',
    [
      AbgSection(
        'Before interpreting the opacity',
        [
          'Check projection, rotation, inspiratory volume, patient position, and prior images. AP portable imaging magnifies the heart and mediastinum.',
          'Low-volume or supine films can obscure dependent disease and mimic worsening pulmonary opacity.',
          'A normal or nonspecific portable film should not override persistent hypoxemia or a concerning clinical course.',
        ],
        'Critical Care radiography · Technique',
        cxrSource,
      ),
      AbgSection(
        'Match the image to the physiology',
        [
          'Volume loss, fissure displacement, and ipsilateral shift support atelectasis. Consider airway obstruction or compression rather than assuming diffuse lung injury.',
          'Consolidation can represent atelectasis, pneumonia, or alveolar flooding. Imaging alone often cannot establish the cause.',
          'Use ultrasound or CT when a specific unresolved question would change management and the patient can undergo the study safely.',
        ],
        'Anesthesiology · Perioperative atelectasis',
        atelectasisSource,
      ),
      AbgSection(
        'Avoid image-driven treatment without reassessment',
        [
          'Review airway patency, device position, ventilation, and the timeline of deterioration alongside the image.',
          'Recruitment and PEEP decisions should account for recruitability and hemodynamic tolerance, not simply the presence of an opacity.',
          'A radiographic improvement does not necessarily establish adequate gas exchange or resolution of the underlying mechanism.',
        ],
        'Anesthesiology · Clinical implications',
        atelectasisSource,
      ),
    ],
    differential: [
      AbgDifferential(
        'Atelectasis',
        'Opacity with volume loss or displaced fissures; dependent regions may be hidden.',
        'Look for obstruction, compression, low lung volume, or postoperative respiratory impairment.',
        'Anesthesiology',
        atelectasisSource,
      ),
      AbgDifferential(
        'Pleural effusion',
        'Upright blunting or a diffuse dependent veil on supine imaging.',
        'Ultrasound helps distinguish fluid from parenchymal opacity and assess distribution.',
        'Critical Care radiography',
        cxrSource,
      ),
      AbgDifferential(
        'Air-space process',
        'Consolidation without a specific radiographic etiology.',
        'Integrate aspiration/infection history, congestion, gas exchange, and serial assessment.',
        'Anesthesiology',
        atelectasisSource,
      ),
    ],
  ),
  AbgTopic(
      'imaging-devices',
      'Lines, tubes & unexpected postoperative deterioration',
      'Devices',
      'Trace each device and look for the complication, not only the tip.',
      'ETT endotracheal CVC PA catheter chest drain feeding tube', [
    AbgSection(
      'Airway and pleural devices',
      [
        'Identify the endotracheal tube tip relative to the carina and review for mainstem placement or a high position. Position can change with neck movement and patient repositioning.',
        'Mainstem intubation may produce contralateral collapse; deeper right-sided placement can obstruct right-upper-lobe ventilation.',
        'For a chest drain, assess the intrathoracic course and side-hole position as well as residual air/fluid and subcutaneous emphysema.',
      ],
      'Critical Care radiography · Devices',
      cxrSource,
    ),
    AbgSection(
      'Vascular devices',
      [
        'Trace the entire catheter course and compare with the intended vessel and device-specific target. An abnormal trajectory is more than a cosmetic positioning issue.',
        'Look for insertion-related pneumothorax, hemothorax, mediastinal abnormality, or evidence suggesting perforation.',
        'For a pulmonary artery catheter, assess for excessively peripheral migration; radiographic position and the pressure waveform should be reconciled.',
      ],
      'Critical Care radiography · Catheters',
      cxrSource,
    ),
    AbgSection(
      'When the film is not sufficient',
      [
        'Radiography does not replace immediate physiologic confirmation of airway or vascular placement.',
        'Do not use a feeding tube until its intended position has been confirmed through the applicable institutional pathway; inadvertent airway placement can be catastrophic.',
        'Acute instability after placement requires prompt clinical assessment. Do not wait for routine imaging before treating a strongly suspected life-threatening complication.',
      ],
      'Critical Care radiography · Complications',
      cxrSource,
      caution: true,
    ),
  ]),
  AbgTopic(
      'imaging-pleura',
      'Pneumothorax, pleural fluid & concealed pathology',
      'Chest findings',
      'Supine imaging changes where air and fluid appear.',
      'deep sulcus tension PTX pneumomediastinum subcutaneous emphysema', [
    AbgSection(
      'Supine pneumothorax is easy to miss',
      [
        'Pleural air may collect anteriorly or basally instead of at the apex. A deep, unusually lucent costophrenic sulcus can be a clue.',
        'Skin folds and other artifacts can mimic pleural lines. Correlate with lung markings, image edges, ultrasound, and the clinical context.',
        'Extensive subcutaneous emphysema can hide the pleural interface and underlying lung.',
      ],
      'Critical Care radiography · Extra-alveolar air',
      cxrSource,
    ),
    AbgSection(
      'Treat physiology, not a radiographic label',
      [
        'Tension pneumothorax is a clinical emergency; instability should not be allowed to progress while waiting for confirmatory imaging.',
        'Positive-pressure ventilation and low-compliance lungs may alter classic radiographic appearances.',
        'New neck or mediastinal air after airway instrumentation warrants consideration of airway or esophageal injury, not simply reassurance that air is outside the lung.',
      ],
      'Critical Care radiography · Clinical pitfalls',
      cxrSource,
      caution: true,
    ),
    AbgSection(
      'Pleural fluid on a portable film',
      [
        'Supine fluid can layer posteriorly as a veil-like opacity without obvious costophrenic blunting.',
        'Ultrasound can clarify fluid versus consolidated lung. CT may be needed for complex or unexplained pathology.',
        'Compare with prior imaging and the operation performed; an expected small postoperative collection and an enlarging collection with deterioration are different findings.',
      ],
      'Critical Care radiography · Pleural fluid',
      cxrSource,
    ),
  ]),
  AbgTopic(
      'imaging-contrast',
      'CT contrast: prior reactions, access & renal context',
      'Imaging safety',
      'Clarify what happened previously instead of treating every “iodine allergy” alike.',
      'iodinated contrast allergy shellfish AKI eGFR extravasation CTA', [
    AbgSection(
      'Differentiate allergic-like and physiologic reactions',
      [
        'Record the exact agent, reaction features, timing, severity, and treatment. Transient nausea or a vasovagal event is not equivalent to anaphylaxis.',
        'Seafood, shellfish, povidone-iodine, and an “iodine allergy” label alone should not determine iodinated contrast use.',
        'The 2025 ACR–AAAAI consensus favors an alternative iodinated agent rather than routine corticosteroid premedication for a prior mild immediate reaction.',
      ],
      'Korean Journal of Radiology · 2025 consensus summary',
      contrastAllergySource,
    ),
    AbgSection(
      'Higher-risk history',
      [
        'For prior moderate or severe allergic-like reactions, discuss alternative imaging and an individualized radiology/allergy plan.',
        'When contrast is necessary, agent substitution and selected premedication may be considered with emergency support available. Premedication does not make anaphylaxis impossible.',
        'Use the current institutional reaction pathway rather than automatically applying an old blanket steroid protocol.',
      ],
      'Korean Journal of Radiology · Risk-based approach',
      contrastAllergySource,
      caution: true,
    ),
    AbgSection(
      'Practical peri-anesthesia checks',
      [
        'Renal risk depends on kidney function, acute kidney injury, clinical circumstances, and the contrast agent. Discuss benefit, alternatives, and preventive strategy with radiology for high-risk patients.',
        'Only power-inject a central catheter or port when the specific device is rated for the intended injection and its manufacturer limits are met.',
        'Pain or swelling during injection requires stopping and assessing for extravasation. Routine contrast administration and sedation/anesthesia have different fasting considerations.',
      ],
      'ACR · Contrast manual, 2024',
      contrastSource,
    ),
  ]),
  AbgTopic(
      'imaging-mri',
      'MRI anesthesia: monitoring, devices & rescue',
      'Imaging safety',
      'The magnet remains active even when scanning stops.',
      'zone IV MR conditional safe burns hearing implants capnography', [
    AbgSection(
      'Screen the complete system',
      [
        'Confirm implant and equipment identity, labeling, and manufacturer conditions with the MR safety team. MR Conditional does not mean unrestricted use.',
        'Evaluate the actual device system and scan conditions rather than assuming that a device category or a previous uneventful MRI establishes safety.',
        'Screen personnel, transport equipment, oxygen supplies, pumps, airway equipment, and patient belongings before entry into restricted areas.',
      ],
      'OpenAnesthesia · MRI safety',
      mrSource,
    ),
    AbgSection(
      'Monitor despite limited access',
      [
        'Provide monitoring appropriate to anesthesia using MR-labeled equipment, with a reliable view of the patient and monitors.',
        'Anticipate restricted airway access, displaced connections during movement, and artifacts in ECG or other monitoring signals.',
        'Long sampling lines may delay or distort capnography. Evaluate waveform trends, ventilation, and circuit integrity rather than accepting a suspicious number at face value.',
      ],
      'OpenAnesthesia · MRI monitoring',
      mrSource,
    ),
    AbgSection(
      'Prevent burns and plan the exit',
      [
        'Avoid conductive loops and skin-to-skin contact; route and pad approved leads according to equipment instructions. Provide hearing protection and appropriate temperature surveillance.',
        'Have a rehearsed plan to remove the patient promptly from Zone IV to the designated resuscitation area for advanced resuscitation.',
        'Do not bring a conventional code cart or defibrillator into the magnet room. Stopping a sequence does not turn off the magnetic field.',
      ],
      'OpenAnesthesia · MRI hazards and rescue',
      mrSource,
      caution: true,
    ),
    AbgSection(
      'Remote-site preparation',
      [
        'Ensure MR-appropriate anesthesia equipment and a plan for oxygen, ventilation, medication delivery, and communication before the patient enters the bore.',
        'Acoustic noise and loss of direct access can conceal deterioration; the monitoring and rescue plan must remain workable throughout the examination.',
      ],
      'OpenAnesthesia · Advanced MRI safety',
      mrAdvancedSource,
    ),
  ]),
];

const pocusTopics = <AbgTopic>[
  AbgTopic(
      'pocus-shock',
      'Focused cardiac ultrasound for unexpected instability',
      'Cardiac & perfusion',
      'Define the question and look for a mechanism, not a complete diagnosis.',
      'shock hypotension LV RV effusion focused cardiac', [
    AbgSection(
      'High-value questions',
      [
        'Is there gross LV or RV dysfunction? Is the RV enlarged? Is a pericardial collection present? Is a major abnormality likely to explain the instability?',
        'Use more than one view when feasible and connect the findings to blood pressure, rhythm, oxygenation, and the surgical timeline.',
        'A focused study is not a comprehensive echocardiogram; important valve disease or uncertain findings should prompt formal assessment.',
      ],
      'ANZCA 2025 · Perioperative diagnostic POCUS',
      pocusSource,
    ),
    AbgSection(
      'Integrate rather than overcall',
      [
        'RV enlargement is not synonymous with pulmonary embolism. A small vigorous LV is not proof of fluid responsiveness.',
        'A pericardial effusion requires assessment for hemodynamic significance. Absence of a large circumferential collection does not exclude localized postoperative compression.',
        'Mixed shock mechanisms are common; reassess after treatment instead of anchoring on the first abnormality.',
      ],
      'Critical Care · Echo in shock',
      echoSource,
      caution: true,
    ),
    AbgSection(
      'Know when to escalate',
      [
        'Poor visualization is an indeterminate examination, not a normal result.',
        'Seek comprehensive imaging or expert assistance when the clinical question exceeds the operator’s scope or the scan is discordant with the patient.',
        'Store images and communicate the question, key findings, uncertainty, and resulting plan.',
      ],
      'ANZCA 2025 · Scope and reporting',
      pocusSource,
    ),
  ]),
  AbgTopic(
    'pocus-lung',
    'Lung ultrasound: pattern recognition without overdiagnosis',
    'Lung',
    'Sliding, artifacts, consolidation, and fluid are findings, not final etiologies.',
    'B lines A lines lung point sliding barcode pneumonia edema',
    [
      AbgSection(
        'Interpret the distribution',
        [
          'Assess bilateral and regional patterns rather than a single isolated image. B-lines indicate increased lung density but do not establish cardiogenic edema.',
          'A-lines can occur in aerated lung and pneumothorax; their meaning depends on pleural sliding and other findings.',
          'Consolidation must reach the pleura to be visualized. A normal accessible surface does not exclude deep central pathology.',
        ],
        'Journal of Ultrasonography · Lung signs',
        lungUsSource,
      ),
      AbgSection(
        'Do not equate absent sliding with pneumothorax',
        [
          'Apnea, mainstem intubation, pleural adhesions, pleurodesis, and other conditions can abolish sliding.',
          'A lung point supports pneumothorax, but failure to find one does not exclude it. Lung pulse or B-lines at a scanned point argue against pleural air at that location.',
          'M-mode barcode appearance reflects absent motion, not a unique diagnosis. Interpret it with the whole examination.',
        ],
        'Journal of Ultrasonography · Pleural signs',
        lungUsSource,
        caution: true,
      ),
      AbgSection(
        'Consolidation and postoperative hypoxemia',
        [
          'Tissue-like lung may represent atelectasis or pneumonia. Dynamic air bronchograms favor pneumonia but are not a stand-alone rule.',
          'Use airway position, secretion burden, pleural fluid, and the time course to distinguish reversible collapse from another process.',
          'Recruitment decisions need a hemodynamic and mechanical assessment; a dense ultrasound image is not an automatic instruction to increase pressure.',
        ],
        'Anesthesiology · Perioperative atelectasis',
        atelectasisSource,
      ),
    ],
    differential: [
      AbgDifferential(
        'Diffuse B-lines',
        'Interstitial or alveolar-interstitial pattern; etiology is nonspecific.',
        'Correlate with cardiac findings, fluid balance, and inflammatory or fibrotic disease.',
        'Lung ultrasound review',
        lungUsSource,
      ),
      AbgDifferential(
        'Absent sliding',
        'Pleural motion absent at the examined point.',
        'Consider PTX and non-PTX causes; integrate lung point, B-lines, lung pulse, and ventilation.',
        'Lung ultrasound review',
        lungUsSource,
      ),
      AbgDifferential(
        'Tissue-like lung',
        'Pleural-based consolidation with or without air bronchograms.',
        'Differentiate atelectasis, infection, and other causes using clinical and imaging context.',
        'Anesthesiology',
        atelectasisSource,
      ),
      AbgDifferential(
        'Pleural fluid',
        'Fluid collection with a visible diaphragm and adjacent lung.',
        'Confirm anatomy and distribution; ultrasound appearance alone does not reliably establish fluid chemistry.',
        'Lung ultrasound review',
        lungUsSource,
      ),
    ],
  ),
  AbgTopic(
      'pocus-gastric',
      'Gastric ultrasound when fasting status is uncertain',
      'Gastric & airway',
      'An adjunct to aspiration-risk assessment, not a guarantee of an empty stomach.',
      'antrum RLD solids clear fluid aspiration full stomach', [
    AbgSection(
      'When it may change the plan',
      [
        'Consider a focused gastric assessment when the intake history is uncertain or delayed emptying is suspected and the result could alter timing or airway strategy.',
        'Identify the antrum and relevant landmarks; evaluate in supine and right lateral decubitus (RLD) positions when feasible.',
        'An apparently empty antrum in supine position alone is insufficient to confidently classify the stomach as empty.',
      ],
      'BJA Education · Gastric ultrasound',
      gastricSource,
    ),
    AbgSection(
      'Interpretation',
      [
        'Solids, particulate material, or thick fluid imply increased concern regardless of a calculated volume.',
        'Clear fluid volume around or above 1.5 mL/kg is commonly used to distinguish higher-than-baseline gastric content in validated adult assessment; it is not an absolute aspiration threshold.',
        'Quantitative models apply to clear fluid and their validated populations and positions. Do not apply them to solids, altered anatomy, or an inadequately identified antrum.',
      ],
      'BJA Education · Gastric interpretation',
      gastricSource,
    ),
    AbgSection(
      'Limits that matter',
      [
        'Prior gastric surgery, a large hiatus hernia, body habitus, gas, or limited positioning can make the assessment unreliable.',
        'An inconclusive scan is not a low-risk result. Integrate symptoms, urgency, airway considerations, and institutional guidance.',
        'Ultrasound complements clinical risk assessment; it does not guarantee protection from regurgitation or aspiration.',
      ],
      'BJA Education · Gastric limitations',
      gastricSource,
      caution: true,
    ),
  ]),
  AbgTopic(
      'pocus-airway',
      'Airway ultrasound & suspected diaphragmatic impairment',
      'Gastric & airway',
      'Useful adjuncts with distinct limitations in a ventilated patient.',
      'cricothyroid membrane diaphragm phrenic paresis extubation tube', [
    AbgSection(
      'Airway applications',
      [
        'Trained operators may use ultrasound to identify the cricothyroid membrane and other airway anatomy when this adds value to planning.',
        'Ultrasound can assist selected airway assessments, but waveform capnography remains the standard for confirming ongoing tracheal ventilation when available and reliable.',
        'Do not allow an adjunctive scan to delay oxygenation or definitive airway management.',
      ],
      'ANZCA 2025 · Upper-airway POCUS',
      pocusSource,
      caution: true,
    ),
    AbgSection(
      'Diaphragm findings in context',
      [
        'Diaphragmatic impairment may contribute to postoperative atelectasis, particularly after thoracic surgery or a block affecting the phrenic nerve.',
        'Interpret motion in relation to spontaneous effort, ventilator assistance, position, pain, and the side examined.',
        'An abnormal motion assessment should be integrated with gas exchange, respiratory mechanics, lung findings, and the clinical trajectory rather than used as a stand-alone extubation decision.',
      ],
      'Anesthesiology · Diaphragm and atelectasis',
      atelectasisSource,
    ),
    AbgSection(
      'Escalation and reporting',
      [
        'State which structures were seen and whether the clinical question was answered.',
        'If the examination is incomplete or a significant finding is uncertain, arrange expert assessment or definitive imaging within the appropriate clinical timeframe.',
      ],
      'ANZCA 2025 · POCUS limitations',
      pocusSource,
    ),
  ]),
  AbgTopic(
      'pocus-fluid',
      'IVC findings & the fluid-responsiveness trap',
      'Cardiac & perfusion',
      'A vessel diameter is not a prescription for a fluid bolus.',
      'IVC collapsibility distensibility passive leg raise VTI congestion', [
    AbgSection(
      'Why one IVC image is not enough',
      [
        'IVC size and respiratory variation are affected by ventilation, right-heart function, intrathoracic pressure, and loading conditions.',
        'A dilated IVC can reflect high right-sided pressure, not simply excess total body volume; a small IVC does not independently establish a need for fluid.',
        'Positive-pressure ventilation limits ordinary spontaneous-breathing assumptions about collapse and right atrial pressure.',
      ],
      'ASE 2025 · Right atrial pressure assessment',
      rightHeartSource,
    ),
    AbgSection(
      'Prefer a response to a reversible intervention',
      [
        'Where appropriate, a passive leg raise with a measured change in flow can test preload responsiveness more directly than a static chamber size.',
        'Serial LVOT VTI requires consistent Doppler alignment, sampling, and rhythm assessment. Changes caused by measurement error should not be treated as physiology.',
        'Responsiveness means output can increase with preload; it does not by itself establish that fluid is needed or tolerated.',
      ],
      'Critical Care · Dynamic assessment',
      echoSource,
    ),
    AbgSection(
      'Evaluate the price of more fluid',
      [
        'Integrate RV and LV function, pulmonary congestion, perfusion, and the clinical cause of hypotension.',
        'Reassess after treatment and stop pursuing a single ultrasound number if the patient’s physiology is worsening.',
        'A discordant scan should widen the assessment, not override the examination and other hemodynamic information.',
      ],
      'Critical Care · Integrated hemodynamics',
      echoSource,
      caution: true,
    ),
  ]),
  AbgTopic(
      'pocus-quality',
      'POCUS quality, scope & documentation',
      'Safety',
      'An answer is only as reliable as the acquisition and the operator’s scope.',
      'credential training report images negative indeterminate FAST vascular',
      [
        AbgSection(
          'Keep the examination question-specific',
          [
            'Use POCUS within demonstrated training and competence. Focused cardiac, lung, gastric, and airway examinations are not interchangeable skills.',
            'Acquire more than one view of a structure when feasible and explicitly assess image quality.',
            'Do not extrapolate competence in one application to another, such as treating a core perioperative scan as a complete vascular or trauma examination.',
          ],
          'ANZCA 2025 · Competency and scope',
          pocusSource,
        ),
        AbgSection(
          'A useful report',
          [
            'Record the indication, operator, examination performed, principal findings, and limitations.',
            'Save representative images and document how results were communicated and whether additional assessment is required.',
            'Distinguish “not seen,” “not adequately assessed,” and “no abnormality identified on this focused examination.”',
          ],
          'ANZCA 2025 · Documentation',
          pocusSource,
        ),
        AbgSection(
          'Resolve important uncertainty',
          [
            'Unexpected significant findings, poor windows, and disagreement with the clinical picture warrant expert review or comprehensive imaging.',
            'A negative focused examination does not exclude every disease in that organ system.',
            'The purpose is to improve clinical decisions, not to create certainty where the examination cannot support it.',
          ],
          'ANZCA 2025 · Clinical governance',
          pocusSource,
          caution: true,
        ),
      ]),
];

const carotidTopics = <AbgTopic>[
  AbgTopic(
    'carotid-grade',
    'Internal carotid artery (ICA) stenosis: read the complete duplex pattern',
    'Interpretation',
    'Criteria from the Intersocietal Accreditation Commission (IAC): velocity, plaque, and ratios.',
    'PSV EDV ICA CCA 180 230 cm/s native stenosis',
    [
      AbgSection(
        'Know the laboratory’s criteria',
        [
          'ICA means internal carotid artery. IAC means Intersocietal Accreditation Commission, the organization publishing these recommendations.',
          'The table summarizes the IAC 2023 modified SRU criteria for native internal carotid arteries, not stents or postoperative arteries.',
          'PSV and EDV are in cm/s. The ICA/CCA ratio compares ICA peak systolic velocity with common carotid artery peak systolic velocity.',
          'Interpret grayscale plaque, color flow, velocity, waveform, and technical quality together. No single PSV value should determine the diagnosis.',
        ],
        'Source: IAC 2023 recommendations · Modified SRU criteria',
        carotidCriteriaSource,
      ),
      AbgSection(
        'Important exception and boundary',
        [
          'PSV 125–180 cm/s with ICA/CCA PSV ratio ≥2 may still be consistent with 50–69% stenosis when significant plaque and other features support it.',
          'Near occlusion may have high, low, or undetectable velocity. Do not downgrade severe disease merely because the velocity is low.',
          'A report using different validated criteria may not match this table exactly; clarify methodology before calling a discrepancy an error.',
        ],
        'Source: IAC 2023 recommendations · Interpretation qualifications',
        carotidCriteriaSource,
        caution: true,
      ),
    ],
    differential: [
      AbgDifferential(
        'Normal / <50%',
        'PSV <180; ratio <2; EDV <40.',
        'No plaque for normal; plaque estimate <50% for mild disease. Consider the stated 125–180 exception.',
        'Source: IAC 2023 recommendations',
        carotidCriteriaSource,
      ),
      AbgDifferential(
        '50–69%',
        'PSV 180–230; ratio 2–4; EDV 40–100.',
        'Plaque estimate >50%; reconcile all findings rather than requiring every parameter in every patient.',
        'Source: IAC 2023 recommendations',
        carotidCriteriaSource,
      ),
      AbgDifferential(
        '>70%, below near occlusion',
        'PSV >230; ratio >4; EDV >100.',
        'Plaque estimate >50%; assess residual lumen and whether near-occlusion physiology is present.',
        'Source: IAC 2023 recommendations',
        carotidCriteriaSource,
      ),
      AbgDifferential(
        'Near occlusion',
        'PSV high, low, or undetectable; ratio and EDV variable.',
        'Visible severe plaque/narrowing; requires anatomic and expert correlation.',
        'Source: IAC 2023 recommendations',
        carotidCriteriaSource,
      ),
      AbgDifferential(
        'Total occlusion',
        'No detectable flow; ratio and EDV not applicable.',
        'Visible plaque with no detectable lumen; distinguish from very low-flow near occlusion.',
        'Source: IAC 2023 recommendations',
        carotidCriteriaSource,
      ),
    ],
  ),
  AbgTopic(
      'carotid-discordant',
      'Discordant velocities, near occlusion & confirmation',
      'Interpretation',
      'Resolve uncertainty before converting a duplex label into an operative decision.',
      'NASCET ECST CTA MRA low flow calcification', [
    AbgSection(
      'Investigate the mismatch',
      [
        'Severe anatomic narrowing with unexpectedly low velocity can represent near occlusion rather than mild disease.',
        'Review the report for technical limitations and the concordance of plaque, residual lumen, color filling, PSV, EDV, and ratios.',
        'Do not equate an incompletely visualized lumen with proven occlusion.',
      ],
      'Source: IAC 2023 recommendations · Combined assessment',
      carotidCriteriaSource,
    ),
    AbgSection(
      'The percentage needs a method',
      [
        'NASCET and ECST use different reference diameters; the percentages are not numerically interchangeable.',
        'NASCET compares the narrowed segment with a normal distal ICA. Distal collapse in near occlusion invalidates a simple ordinary percentage calculation.',
        'Read whether a report describes conventional severe stenosis, near occlusion, or complete occlusion; these are different clinical categories.',
      ],
      'ESVS 2023 · Imaging methodology',
      carotidGuidelineSource,
    ),
    AbgSection(
      'Confirm before intervention',
      [
        'For planned carotid endarterectomy, ESVS recommends corroborating duplex severity with CTA, MRA, or repeat duplex by a second operator.',
        'Before carotid stenting, CTA or MRA also assesses arch and extra-/intracranial anatomy.',
        'Near occlusion with distal collapse requires specialist multidisciplinary assessment; ordinary severe-stenosis treatment rules should not be applied automatically.',
      ],
      'ESVS 2023 · Confirmation and near occlusion',
      carotidGuidelineSource,
      caution: true,
    ),
  ]),
  AbgTopic(
      'carotid-preop',
      'Carotid disease before noncarotid surgery',
      'Perioperative care',
      'Symptoms and recency matter more than a screening label alone.',
      'TIA stroke amaurosis asymptomatic screening antiplatelet statin', [
    AbgSection(
      'Separate symptomatic from asymptomatic disease',
      [
        'Clarify whether there has been a recent ipsilateral retinal or cerebral ischemic event, when it occurred, and whether the carotid lesion explains it.',
        'Recent stroke or TIA with relevant carotid stenosis warrants neurovascular evaluation before elective noncardiac surgery.',
        'New focal symptoms require urgent stroke assessment, not merely a repeat outpatient Doppler.',
      ],
      'ESVS 2023 · Symptomatic disease',
      carotidGuidelineSource,
    ),
    AbgSection(
      'Avoid prophylactic procedures just to “clear” surgery',
      [
        'Routine carotid imaging is not recommended solely because an asymptomatic patient is having noncardiac surgery.',
        'ESVS does not recommend prophylactic CEA or carotid stenting for asymptomatic 50–99% stenosis simply to reduce risk before major noncardiac surgery.',
        'Address overall cardiovascular and cerebrovascular risk rather than assuming carotid narrowing explains all perioperative stroke risk.',
      ],
      'ESVS 2023 · Noncardiac surgery',
      carotidGuidelineSource,
      caution: true,
    ),
    AbgSection(
      'Coordinate the perioperative plan',
      [
        'Continue indicated vascular risk-reduction care. ESVS advises against stopping statin therapy in this setting.',
        'Antithrombotic interruption requires balancing thromboembolic and bleeding risks with the procedural teams; do not make a blanket decision from the duplex percentage.',
        'Elective timing after stroke and the need for carotid intervention require current multidisciplinary guidance and consideration of surgical urgency, not a generic Doppler-based clearance.',
      ],
      'ESVS 2023 · Perioperative planning',
      carotidGuidelineSource,
    ),
  ]),
  AbgTopic(
      'carotid-postprocedure',
      'After CEA or carotid stenting: what the report means',
      'Interpretation',
      'Native-vessel cutoffs do not automatically diagnose restenosis.',
      'restenosis stent patch endarterectomy surveillance', [
    AbgSection(
      'Identify the reconstruction',
      [
        'Confirm which side was treated, the procedure and date, and whether the current study is surveillance or symptom-driven.',
        'Stents and surgical reconstruction change vessel mechanics and measured velocities.',
        'Use validated post-CEA or post-stent criteria rather than directly applying the native ICA table.',
      ],
      'ESVS 2023 · Restenosis assessment',
      carotidGuidelineSource,
    ),
    AbgSection(
      'Read trends with the anatomy',
      [
        'Compare with the initial postoperative study and prior surveillance, including the method used.',
        'A new velocity increase should be reconciled with grayscale and color findings and the clinical context.',
        'A suspected important restenosis may require confirmatory imaging and vascular review before treatment decisions.',
      ],
      'ESVS 2023 · Surveillance',
      carotidGuidelineSource,
    ),
    AbgSection(
      'Symptoms override routine surveillance',
      [
        'New retinal or focal neurologic symptoms require urgent assessment regardless of when the next surveillance scan is scheduled.',
        'Do not assume a post-procedure neurologic change is simply residual stenosis; thrombosis, embolism, hemorrhage, and other mechanisms must be considered.',
      ],
      'ESVS 2023 · Post-intervention events',
      carotidGuidelineSource,
      caution: true,
    ),
  ]),
  AbgTopic(
      'carotid-complications',
      'CEA / stenting: hemodynamics & early danger signals',
      'Perioperative care',
      'Protect perfusion while recognizing hyperperfusion, bleeding, and airway threats.',
      'hypertension hypotension bradycardia hyperperfusion hematoma headache', [
    AbgSection(
      'Hemodynamic surveillance',
      [
        'Post-CEA hypertension is associated with neurologic events, neck hematoma, hyperperfusion syndrome, and intracranial hemorrhage.',
        'Carotid stenting can produce bradycardia and hypotension; persistent instability requires ongoing monitored management.',
        'Use written institutional blood-pressure targets and an individualized plan. Avoid assuming one universal pressure target fits every baseline and procedural phase.',
      ],
      'ESVS 2023 · Hemodynamic complications',
      carotidGuidelineSource,
    ),
    AbgSection(
      'New neurologic symptoms are urgent',
      [
        'Severe headache, seizures, confusion, or focal deficits after carotid intervention require immediate assessment.',
        'Hyperperfusion is one possibility, but ischemia and hemorrhage must also be evaluated; do not label symptoms benign without investigation.',
        'Document a baseline neurologic assessment and communicate the timing of any change clearly.',
      ],
      'ESVS 2023 · Hyperperfusion and stroke',
      carotidGuidelineSource,
      caution: true,
    ),
    AbgSection(
      'The neck is also an airway problem',
      [
        'An expanding neck hematoma, stridor, or tracheal deviation after CEA is an airway emergency requiring immediate surgical and anesthesia response.',
        'Do not defer urgent management while waiting for a routine imaging study to quantify the collection.',
        'Hand off airway concerns, pressure trends, vasoactive requirements, and antithrombotic management explicitly.',
      ],
      'ESVS 2023 · Neck hematoma',
      carotidGuidelineSource,
      caution: true,
    ),
  ]),
];
