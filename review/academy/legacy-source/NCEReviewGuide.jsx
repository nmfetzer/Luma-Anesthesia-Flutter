import { useState } from 'react';
import { ChevronDown, ChevronUp, BookOpen } from 'lucide-react';

const DOMAINS = [
  {
    id: 'overview',
    title: 'How to Use This Guide',
    color: 'bg-teal-50 border-teal-200',
    headerColor: 'bg-teal-700',
    emoji: '📋',
    sections: [
      {
        heading: 'Study Strategy',
        bullets: [
          'Step 1 — Benchmark: Take the full 100-question practice test cold to identify your weakest domain before studying.',
          'Step 2 — Study by domain: Spend the most time on General Principles of Anesthesia (35%), the largest domain.',
          'Step 3 — Active recall: After each section, close the guide and write down everything you remember.',
          'Step 4 — Re-test: Re-do practice questions for any domain scoring below 70%.',
          'Step 5 — Final review: In the 48 hours before the exam, review only High-Yield boxes and Clinical Pearls.',
        ],
      },
      {
        heading: 'NCE Key Facts',
        bullets: [
          'Format: Computerized Adaptive Test (CAT) — 100-170 questions, 3-hour time limit.',
          '70-140 scored questions + 30 unscored pretest items.',
          'Question types: Multiple choice, MCR, Short Answer/Calculation, Drag-and-Drop, Hotspot.',
          'Scoring: Scaled score 0-900; passing standard 450 (adjusting July 1, 2026).',
          'Results: Pass/Fail provided immediately at the testing center.',
          'First-time pass rate (2025): 90.5%.',
        ],
      },
      {
        heading: 'Exam Blueprint',
        table: {
          headers: ['Domain', 'Weight', 'Key Focus Areas'],
          rows: [
            ['I. Basic Sciences', '20%', 'A&P, Pathophysiology, Pharmacology, Applied Physics/Chemistry'],
            ['II. Equipment, Instrumentation & Technology', '20%', 'Anesthesia machines, airway equipment, monitoring, vaporizers'],
            ['III. General Principles of Anesthesia', '35%', 'Preop assessment, airway, regional, fluids, PACU, pain, ERAS'],
            ['IV. Anesthesia for Surgical Procedures & Special Populations', '25%', 'Surgical anesthesia, pediatrics, obstetrics, geriatrics, obesity'],
          ],
        },
      },
    ],
  },
  {
    id: 'domain1',
    title: 'Domain I: Basic Sciences (20%)',
    color: 'bg-blue-50 border-blue-200',
    headerColor: 'bg-blue-800',
    emoji: '🔬',
    sections: [
      {
        heading: 'Cardiovascular A&P',
        bullets: [
          'Frank-Starling law: increased preload → increased stroke volume (to a point)',
          'Cardiac output (CO) = Heart rate (HR) × Stroke volume (SV)',
          'SVR = (MAP - CVP) / CO × 80; normal SVR 800-1200 dynes·s·cm⁻⁵',
          'Coronary perfusion pressure (CPP) = Aortic diastolic pressure - LVEDP',
          'Right coronary artery dominance in 85%; supplies SA and AV nodes',
          'Myocardial O₂ demand determinants: HR, contractility, wall tension',
        ],
      },
      {
        heading: 'Respiratory A&P',
        bullets: [
          'FRC = ERV + RV; volume at rest after passive exhalation',
          'HPV diverts blood from atelectatic lung — volatile agents blunt HPV',
          'Oxyhemoglobin dissociation curve: right shift with increased CO₂, temp, H⁺, 2,3-DPG',
          'Closing capacity increases with age, obesity, supine position → V/Q mismatch',
          'Alveolar gas equation: PAO₂ = (FiO₂)(PB - PH₂O) - PaCO₂/0.8',
          'Dead space (Vd/Vt): normal 0.33; increases with PE, emphysema, high PEEP, low CO',
        ],
      },
      {
        heading: 'CNS A&P',
        bullets: [
          'CBF: normal 50 mL/100g/min; autoregulation MAP 60-150 mmHg',
          'CBF directly proportional to PaCO₂ (4% per mmHg)',
          'ICP: normal <15 mmHg; CPP = MAP - ICP; target CPP >60 mmHg in neuro injury',
          'Blood-brain barrier: tight junctions, impermeable to ions; permeable to lipid-soluble drugs',
          'MAC: minimum alveolar concentration to prevent movement in 50% of patients at 1 atm',
        ],
      },
      {
        heading: 'Pathophysiology — High-Yield Conditions',
        table: {
          headers: ['Condition', 'Anesthesia Implications', 'Key Management'],
          rows: [
            ['Aortic Stenosis', 'Fixed CO; avoid tachycardia, hypotension, vasodilation', 'Maintain sinus rhythm, SVR; phenylephrine for hypotension'],
            ['Aortic Regurgitation', 'Benefits from mild tachycardia, reduced afterload', 'Avoid bradycardia; vasodilators help'],
            ['Mitral Stenosis', 'Fixed CO; avoid tachycardia, A-fib with RVR', 'Slow HR, avoid pulmonary HTN triggers'],
            ['HOCM', 'Worsens with decreased preload/afterload, increased HR/contractility', 'Volume, beta-blockade, avoid vasodilators'],
            ['COPD', 'Auto-PEEP risk; blunted hypoxic drive; air trapping', 'Prolonged expiratory time, low RR'],
            ['Malignant Hyperthermia', 'Triggered by volatile agents + succinylcholine', 'STOP trigger, dantrolene 2.5 mg/kg IV; cooling'],
            ['Myasthenia Gravis', 'Sensitivity to NDNMBs; may resist succinylcholine', 'Minimize NDNMBs; sugammadex preferred'],
          ],
        },
      },
      {
        heading: 'Inhalation Anesthetics',
        table: {
          headers: ['Agent', 'Blood:Gas', 'MAC (%)', 'Key Properties'],
          rows: [
            ['Sevoflurane', '0.65', '2.0', 'Sweet smell; inhalation induction; compound A with low-flow; 3-5% hepatic metabolism'],
            ['Desflurane', '0.42', '6.0', 'Fastest onset/offset; pungent — cannot use for induction; requires heated vaporizer'],
            ['Isoflurane', '1.4', '1.15', 'Coronary steal controversy; good muscle relaxation; pungent'],
            ['Nitrous Oxide', '0.47', '104', 'Analgesic, not complete anesthetic; diffusion hypoxia; expands air-filled cavities; avoid in PTX, bowel obstruction'],
          ],
        },
      },
      {
        heading: 'IV Anesthetics',
        bullets: [
          'Propofol: Lipid emulsion; onset 30-45 sec; decreases CBF, ICP, CMRO₂; antiemetic; PRIS with high doses >48h',
          'Etomidate: Cardiostable; adrenal suppression with single dose; myoclonic movements; PONV',
          'Ketamine: Dissociative; bronchodilator; increases HR, BP, ICP; preserves airway reflexes; emergence delirium',
          'Dexmedetomidine: Alpha-2 agonist; sedation/analgesia without respiratory depression; bradycardia, hypotension',
          'Midazolam: Benzodiazepine; anxiolysis, amnesia, anticonvulsant; reversal with flumazenil (re-sedation risk)',
        ],
      },
      {
        heading: 'Opioids',
        table: {
          headers: ['Drug', 'Onset', 'Duration', 'Key Points'],
          rows: [
            ['Fentanyl', '1-2 min', '30-60 min', '100× morphine potency; highly lipid soluble; chest wall rigidity at high doses'],
            ['Sufentanil', '1-2 min', '60-90 min', '1000× morphine potency; most potent clinical opioid; cardiac anesthesia'],
            ['Remifentanil', '1 min', '3-5 min', 'Ester hydrolysis — organ-independent; ideal for TIVA; hyperalgesia risk'],
            ['Morphine', '15-30 min', '4-5 h', 'Histamine release; M6G accumulates in renal failure'],
            ['Methadone', 'Slow', '24-36 h', 'NMDA antagonist; QT prolongation; opioid-tolerant patients'],
          ],
        },
      },
      {
        heading: 'Neuromuscular Blocking Agents',
        table: {
          headers: ['Agent', 'Type', 'Onset/Duration', 'Key Points'],
          rows: [
            ['Succinylcholine', 'Depolarizing', '45-60 sec / 8-12 min', 'Hyperkalemia risk; MH trigger; bradycardia in children; avoid in burns, crush injury, denervation >72h'],
            ['Rocuronium', 'Non-depolarizing', '60-90 sec / 30-60 min', 'Fastest NDNMB; 1.2 mg/kg for RSI; reversed by sugammadex 16 mg/kg'],
            ['Vecuronium', 'Non-depolarizing', '3-5 min / 25-40 min', 'Hepatic elimination; no cardiovascular effects'],
            ['Cisatracurium', 'Non-depolarizing', '3-5 min / 35-45 min', 'Hofmann elimination; no histamine; ideal in hepatic/renal failure'],
          ],
        },
      },
      {
        heading: 'Local Anesthetics',
        bullets: [
          'Mechanism: Sodium channel blockade — autonomic > sensory pain/temp > touch/pressure > motor',
          'Amides (lidocaine, bupivacaine, ropivacaine): Liver metabolism; "amides have 2 i\'s in their name"',
          'Esters (procaine, chloroprocaine, tetracaine): Plasma cholinesterase; PABA metabolite — allergies',
          'LAST: CNS signs (tinnitus, metallic taste, seizures) then CV collapse → Intralipid 20% 1.5 mL/kg bolus',
          'Max doses: Lidocaine 4.5 mg/kg plain / 7 mg/kg with epi; Bupivacaine 2.5 mg/kg; Ropivacaine 3 mg/kg',
          'Bupivacaine most cardiotoxic — avoid for IV regional (Bier block)',
        ],
      },
      {
        heading: 'Applied Physics',
        bullets: [
          'Boyle\'s Law: P₁V₁ = P₂V₂ — pressure/volume inversely proportional (compressed gas cylinders)',
          'Henry\'s Law: Gas solubility proportional to partial pressure — basis for blood:gas partition coefficients',
          'Graham\'s Law: Diffusion rate inversely proportional to √molecular weight — CO₂ diffuses faster than O₂',
          'Laplace\'s Law: T = P × r / 2w — smaller alveoli tend to collapse; countered by surfactant',
          'Poiseuille\'s Law: Flow = (Pr⁴π)/(8ηl) — doubling tube radius increases flow 16×',
          'Fick Principle: CO = O₂ consumption / (CaO₂ - CvO₂); normal SvO₂ 75%',
          'ABL = EBV × (Hi - Hf) / Hi; EBV = 65-70 mL/kg adult',
        ],
      },
    ],
  },
  {
    id: 'domain2',
    title: 'Domain II: Equipment, Instrumentation & Technology (20%)',
    color: 'bg-purple-50 border-purple-200',
    headerColor: 'bg-purple-800',
    emoji: '🔧',
    sections: [
      {
        heading: 'Gas Machine — Pressure Hierarchy',
        bullets: [
          'High-pressure: Cylinder → PISS → cylinder regulator (~2000 psig O₂ → 45 psig)',
          'Intermediate-pressure: Pipeline gas (50 psig) → master switch → O₂ flush (35-75 L/min)',
          'Low-pressure: Flowmeters → vaporizer → common gas outlet → breathing circuit',
          'Failsafe valve: Shuts off N₂O if O₂ pipeline falls below ~25 psig',
          'Proportioning system: Maintains minimum 25% O₂ in delivered gas',
          'O₂ Flush: Bypasses vaporizer/flowmeters — NEVER activate during inspiration (barotrauma)',
        ],
      },
      {
        heading: 'Vaporizers',
        bullets: [
          'Variable-bypass (Tec 6/7): Agent-specific, temperature-compensated; key-fill device',
          'Desflurane requires heated vaporizer (Tec 6): Boiling point 22.8°C',
          'Tipping hazard: Allow 30 min before use if sevoflurane/isoflurane vaporizer tipped',
        ],
      },
      {
        heading: 'Breathing Circuits',
        table: {
          headers: ['Circuit', 'Rebreathing', 'CO₂ Absorber', 'Key Use'],
          rows: [
            ['Circle system', 'Yes', 'Required', 'Standard adult/ped; low fresh gas flow'],
            ['Mapleson A (Magill)', 'Some', 'No', 'Most efficient spontaneous ventilation; FGF = MV'],
            ['Mapleson D (Bain)', 'Some', 'No', 'Most efficient controlled ventilation; FGF 2× MV; coaxial'],
            ['Jackson-Rees', 'None', 'No', 'Pediatric; high FGF required'],
          ],
        },
      },
      {
        heading: 'CO₂ Absorbents',
        bullets: [
          'Soda lime: NaOH + Ca(OH)₂; produces compound A with sevoflurane; CO with desiccated desflurane/isoflurane',
          'Amsorb / Drägersorb: Calcium hydroxide only; does NOT produce compound A or CO',
          'Color change: Purple/violet when exhausted — do not trust color reversal on standing',
        ],
      },
      {
        heading: 'Monitoring Devices',
        table: {
          headers: ['Monitor', 'What It Measures', 'Key Clinical Points'],
          rows: [
            ['Capnography (ETCO₂)', 'Exhaled CO₂ waveform', 'Gold standard ETT placement; ETCO₂ normally 2-5 mmHg below PaCO₂; sudden drop to zero = esophageal intubation/cardiac arrest'],
            ['Pulse Oximetry', 'Functional O₂ saturation', 'Cannot detect hyperoxia or CO poisoning (falsely high ~95%); methemoglobinemia reads ~85%'],
            ['Arterial Line', 'Continuous beat-to-beat BP', 'Overdamped: falsely low systolic; underdamped: falsely high systolic; Allen test before radial'],
            ['BIS Monitor', 'Processed EEG — depth', 'Target 40-60 for GA; 65-85 for sedation; reduces awareness risk'],
            ['TOF (Nerve Stimulator)', 'NMB depth', 'TOF ratio <0.9 = residual block; 4/4 with fade = partial block'],
            ['TEE', 'Cardiac structure/function', 'Most sensitive for VAE; diagnoses wall motion abnormalities, valve pathology, volume status'],
            ['Cerebral Oximetry (NIRS)', 'Regional cerebral O₂', 'Normal 55-80%; drop >20% from baseline = intervention threshold'],
          ],
        },
      },
      {
        heading: 'Equipment Troubleshooting',
        bullets: [
          'High peak pressure + normal plateau: airway obstruction (bronchospasm, ETT kink, secretions)',
          'High peak AND plateau: decreased compliance (pneumothorax, endobronchial intubation, ARDS)',
          'Sudden ETCO₂ drop to zero: esophageal intubation, circuit disconnect, cardiac arrest',
          'Gradual ETCO₂ decline: pulmonary embolism, decreased CO, hyperventilation',
          'O₂ E-tank: full ~2000 psig; duration = remaining psig × 0.3 / FGF rate',
        ],
      },
    ],
  },
  {
    id: 'domain3',
    title: 'Domain III: General Principles of Anesthesia (35%)',
    color: 'bg-green-50 border-green-200',
    headerColor: 'bg-green-800',
    emoji: '🏥',
    sections: [
      {
        heading: 'ASA Physical Status Classification',
        table: {
          headers: ['Class', 'Definition', 'Examples'],
          rows: [
            ['ASA I', 'Normal healthy patient', 'No systemic disease, non-smoker'],
            ['ASA II', 'Mild systemic disease', 'Well-controlled DM, HTN, BMI 30-40, smoker, pregnancy'],
            ['ASA III', 'Severe systemic disease', 'Poorly controlled DM/HTN, COPD, morbid obesity, ESRD, CVA history'],
            ['ASA IV', 'Severe — constant threat to life', 'Recent MI (<3 mo), sepsis, DIC, severe valve disease'],
            ['ASA V', 'Moribund — not expected to survive 24h', 'Ruptured AAA, massive trauma, intracranial bleed'],
          ],
        },
      },
      {
        heading: 'NPO Guidelines (ASA 2023)',
        table: {
          headers: ['Ingested Substance', 'Minimum Fasting Time'],
          rows: [
            ['Clear liquids (water, juice without pulp, black coffee, tea)', '2 hours'],
            ['Breast milk', '4 hours'],
            ['Formula, non-human milk', '6 hours'],
            ['Light meal (toast + clear liquid)', '6 hours'],
            ['Full meal (fried, fatty foods, meat)', '8 hours'],
          ],
        },
      },
      {
        heading: 'Preoperative Medications',
        bullets: [
          'Beta-blockers: Continue perioperatively; initiating new BB day of surgery increases stroke risk',
          'ACE inhibitors/ARBs: Hold morning of surgery — refractory intraoperative hypotension risk',
          'Clopidogrel: Hold 5-7 days before elective surgery with neuraxial',
          'Herbal supplements: Garlic/ginkgo (bleeding), ginseng (hypoglycemia), St. John\'s Wort (drug interactions), kava (sedation)',
        ],
      },
      {
        heading: 'Difficult Airway — LEMON Assessment',
        bullets: [
          'L — Look: Facial trauma, obesity, micrognathia, retrognathia, large incisors',
          'E — Evaluate 3-3-2 rule: Mouth >3 fingers, hyoid-chin >3 fingers, hyoid-thyroid notch >2 fingers',
          'M — Mallampati: Score I-IV; III-IV associated with difficult intubation',
          'O — Obstruction: Stridor, foreign body, abscess, angioedema, tumor',
          'N — Neck mobility: Cervical disease, obesity; reduced extension = difficult laryngoscopy',
        ],
      },
      {
        heading: 'ASA Difficult Airway Algorithm',
        bullets: [
          'Awake intubation: preferred when difficult airway anticipated AND patient cannot tolerate apnea safely',
          'Awake fiberoptic: gold standard; topicalize with nebulized lidocaine + superior laryngeal nerve block',
          'RSI: succinylcholine 1.5-2 mg/kg OR rocuronium 1.2 mg/kg + sugammadex available',
          'CICO: declare emergency → supraglottic device → cricothyrotomy if SGA fails',
          'Extubation of difficult airway: airway exchange catheter; extubate fully awake',
        ],
      },
      {
        heading: 'Neuraxial — Spinal vs. Epidural',
        table: {
          headers: ['Feature', 'Spinal', 'Epidural'],
          rows: [
            ['Space', 'Intrathecal (subarachnoid)', 'Epidural space'],
            ['Onset', '2-5 minutes', '15-20 minutes'],
            ['Dose', 'Small (1.5-3 mL)', 'Large (10-20 mL)'],
            ['Duration', 'Fixed (agent-dependent)', 'Continuous with catheter'],
            ['Max safe level', 'T4 (nipple) for cesarean', 'T4-T6 for abdominal surgery'],
          ],
        },
      },
      {
        heading: 'Neuraxial Complications',
        bullets: [
          'High spinal (above T4): hypotension, bradycardia, loss of intercostal breathing; C3-C5 = phrenic paralysis → intubate',
          'PDPH: positional headache; blood patch (15-20 mL) is definitive treatment; onset 24-48h post dural puncture',
          'Peripheral blocks: TAP (T10-L1), femoral/adductor (knee), popliteal sciatic (foot), paravertebral (thorax/breast)',
        ],
      },
      {
        heading: 'Fluid Management',
        table: {
          headers: ['Fluid', 'Type', 'Na⁺', 'Notes'],
          rows: [
            ['Normal Saline (0.9%)', 'Isotonic crystalloid', '154', 'Hyperchloremic metabolic acidosis with large volumes; use in head trauma, hyperkalemia'],
            ['Lactated Ringer\'s', 'Balanced crystalloid', '130', 'Most physiologic; preferred for most surgical cases'],
            ['Plasmalyte/Normosol', 'Balanced crystalloid', '140', 'Most balanced pH; no calcium; large volume resuscitation'],
            ['Albumin 5%', 'Colloid', '~145', 'Volume expansion; useful in hepatic failure; no mortality benefit over crystalloid'],
            ['PRBCs', 'Blood product', '—', 'Transfuse at Hgb <7 g/dL; 1 unit raises Hgb ~1 g/dL'],
            ['FFP', 'Blood product', '—', 'Coagulopathy + active bleeding (INR >1.5); 10-15 mL/kg'],
            ['Platelets', 'Blood product', '—', '<50,000 for surgery; <100,000 for neurosurgery; <10,000 for prophylaxis'],
          ],
        },
      },
      {
        heading: 'Massive Transfusion Protocol (MTP)',
        bullets: [
          '1:1:1 ratio — PRBC:FFP:Platelets',
          'Add cryoprecipitate for fibrinogen <150 mg/dL (<200 in OB hemorrhage)',
          'TXA 1g IV within 3 hours of traumatic hemorrhage — significantly reduces mortality',
          'Monitor with TEG/ROTEM for goal-directed transfusion',
        ],
      },
      {
        heading: 'Patient Positioning',
        table: {
          headers: ['Position', 'Physiologic Effects', 'Complications'],
          rows: [
            ['Supine', 'Baseline; FRC decreases vs. standing', 'Aortocaval compression in pregnancy (tilt 15° left)'],
            ['Trendelenburg', 'Increased VR, CO, ICP, airway pressure', 'Cerebral edema, brachial plexus stretch, ETT migration caudad'],
            ['Lithotomy', 'Increased VR when legs raised', 'Peroneal nerve palsy (most common), compartment syndrome if >4h'],
            ['Lateral decubitus', 'Dependent lung compression; HPV', 'Axillary roll required (NOT in axilla); down lung atelectasis'],
            ['Prone', 'Improved oxygenation; increased airway pressure', 'ETT dislodgement on turning, corneal abrasion, facial edema'],
            ['Sitting/Beach Chair', 'Best shoulder/posterior fossa access', 'VAE risk highest; paradoxical air embolism if PFO'],
          ],
        },
      },
      {
        heading: 'PACU Complications',
        table: {
          headers: ['Complication', 'Signs/Symptoms', 'Management'],
          rows: [
            ['Laryngospasm', 'High-pitched stridor, paradoxical chest, SpO₂ drop', 'Jaw thrust, 100% O₂, CPAP; succinylcholine 0.1-0.5 mg/kg'],
            ['NPPE', 'Post-extubation pink frothy sputum', 'CPAP/BiPAP, diuresis; occurs after forceful inspiration against closed glottis'],
            ['Residual NMB', 'Weak grip, head lift <5 sec, paradoxical breathing', 'Verify TOF >0.9 before extubation; sugammadex or neostigmine'],
            ['PONV', 'Nausea, vomiting post-op', 'Apfel score; ondansetron, dexamethasone, scopolamine; TIVA reduces PONV'],
            ['Shivering', 'Muscle tremors, increased O₂ consumption 400-500%', 'Meperidine 25 mg IV most effective; warming; clonidine'],
          ],
        },
      },
    ],
  },
  {
    id: 'domain4',
    title: 'Domain IV: Anesthesia for Surgical Procedures & Special Populations (25%)',
    color: 'bg-orange-50 border-orange-200',
    headerColor: 'bg-orange-700',
    emoji: '👨‍⚕️',
    sections: [
      {
        heading: 'Surgical Anesthesia — High-Yield',
        table: {
          headers: ['Procedure', 'Key Anesthetic Considerations'],
          rows: [
            ['Cardiac (CABG, valve)', 'CPB: heparin 300-400 units/kg, ACT >400 sec; cardioplegia; protamine reversal; TEE essential'],
            ['Neurosurgery', 'ICP: head up 15-30°, avoid N₂O, mannitol 0.25-1 g/kg, avoid ketamine; TIVA for neuromonitoring'],
            ['Thoracic (lung resection)', 'OLV: DLT or bronchial blocker; TV 4-6 mL/kg IBW; CPAP nondependent lung for refractory hypoxia'],
            ['Laparoscopic', 'CO₂ pneumoperitoneum: increased PaCO₂, ICP, airway pressure; watch for CO₂ embolism'],
            ['Orthopedic', 'Fat embolism with IM reaming; tourniquet deflation: hypotension/metabolic acidosis; regional preferred'],
            ['Ophthalmologic', 'Oculocardiac reflex (bradycardia with EOM traction) → atropine; avoid succinylcholine in open globe'],
          ],
        },
      },
      {
        heading: 'Venous Air Embolism (VAE)',
        bullets: [
          'Highest risk: sitting/beach chair craniotomy, posterior fossa, hepatic resection, spine surgery',
          'Signs: mill-wheel murmur, decreased ETCO₂, increased ETN₂, hypotension, dysrhythmias',
          'TEE is most sensitive; Doppler most practical',
          'Treatment: flood field, Durant maneuver (left lateral decubitus + Trendelenburg), 100% O₂, D/C N₂O, aspirate through CVP catheter',
        ],
      },
      {
        heading: 'Pediatric Anesthesia',
        bullets: [
          'Airway: obligate nasal breathers <6 mo; narrowest at cricoid (not glottis) until ~8 years; large tongue, omega epiglottis',
          'ETT size (uncuffed): (Age/4) + 4; ETT depth (cm at lip): weight (kg) + 10 or age/2 + 12',
          'Inhalation induction: sevoflurane with 70% N₂O; MAC higher in infants (sevoflurane MAC 3.3% neonates)',
          'Fluid maintenance: 4/2/1 rule (4 mL/kg/h × first 10 kg; 2 × next 10 kg; 1 × each kg >20)',
          'Laryngospasm: 0.87% incidence vs. 0.08% adults — most common peds anesthesia complication',
          'LMA sizing: Size 1 (<5 kg), 2 (10-20 kg), 3 (30-50 kg), 4 (50-70 kg), 5 (70-100 kg)',
        ],
      },
      {
        heading: 'Obstetric Anesthesia',
        table: {
          headers: ['System', 'Change in Pregnancy', 'Clinical Implication'],
          rows: [
            ['Cardiovascular', 'CO +40-50%; HR +15-20 bpm; SVR -20%', 'Aortocaval compression → tilt 15° left'],
            ['Respiratory', 'MV +50%; FRC -20%; O₂ consumption +20%', 'Pre-oxygenate 3-5 min; early desaturation during intubation'],
            ['GI', 'Delayed gastric emptying; decreased LES tone', 'RSI for all GA after 12-18 weeks gestation'],
            ['CNS', 'MAC decreases ~40%; spinal dose -30%', 'Reduced anesthetic requirements (progesterone-mediated)'],
          ],
        },
      },
      {
        heading: 'Obstetric Key Points',
        bullets: [
          'Cesarean spinal: Hyperbaric bupivacaine 10-12 mg + fentanyl 15-25 mcg + preservative-free morphine 0.1-0.2 mg; target T4',
          'Spinal hypotension: Phenylephrine first-line (preserves uteroplacental blood flow better than ephedrine)',
          'HELLP: Hemolysis, Elevated Liver enzymes, Low Platelets; platelet threshold for epidural >75,000-80,000',
          'PPH: Oxytocin first-line (20-40 units/L LR); if refractory: methylergonovine, 15-methyl-PGF2α, misoprostol',
          'Amniotic fluid embolism: Sudden CV collapse + DIC + hypoxia; supportive; highly lethal',
        ],
      },
      {
        heading: 'Geriatric Anesthesia',
        bullets: [
          'Pharmacokinetics: Decreased hepatic/renal function → prolonged drug effect; decreased albumin → more free drug',
          'MAC decreases ~6% per decade after age 40',
          'Closing capacity exceeds FRC at ~age 65 supine → increased V/Q mismatch',
          'POCD risk increases with age, depth, duration, polypharmacy; avoid benzodiazepines',
        ],
      },
      {
        heading: 'Anesthesia for Obesity',
        bullets: [
          'Airway: ramped position (ear to sternal notch); 25° head-up reduces aspiration risk; preoxygenate optimally',
          'Dosing: IBW for volatile MAC; LBW for most IV drugs; TBW for succinylcholine',
          'Screen for OSA: STOP-BANG ≥3 = high risk (Snoring, Tired, Observed apnea, Pressure/HTN, BMI>35, Age>50, Neck>40cm, Male)',
          'Bariatric surgery: RSI required; minimize opioids post-op in OSA patients',
        ],
      },
    ],
  },
  {
    id: 'quickref',
    title: 'Quick Reference — High-Yield Tables',
    color: 'bg-red-50 border-red-200',
    headerColor: 'bg-red-800',
    emoji: '⚡',
    sections: [
      {
        heading: 'Normal Laboratory Values',
        table: {
          headers: ['Lab Value', 'Normal Range', 'Clinical Significance'],
          rows: [
            ['pH', '7.35-7.45', '<7.35 acidosis; >7.45 alkalosis'],
            ['PaCO₂', '35-45 mmHg', 'Respiratory acid-base control'],
            ['PaO₂', '80-100 mmHg', '<60 mmHg = respiratory failure threshold'],
            ['HCO₃⁻', '22-26 mEq/L', 'Metabolic acid-base control'],
            ['SaO₂', '>95%', '<90% requires urgent intervention'],
            ['Na⁺', '135-145 mEq/L', 'Hyponatremia <130: seizure risk'],
            ['K⁺', '3.5-5.0 mEq/L', '<3.0 or >6.0: arrhythmia risk'],
            ['PT/INR', '11-13 sec / 0.9-1.1', '>1.5 INR: FFP before neuraxial'],
            ['Platelets', '150,000-400,000/mm³', '<80,000: avoid neuraxial; <50,000: transfuse before surgery'],
            ['Hgb', '12-17 g/dL', 'Transfuse threshold typically Hgb <7 g/dL'],
          ],
        },
      },
      {
        heading: 'MUDPILES — High Anion Gap Metabolic Acidosis',
        table: {
          headers: ['Letter', 'Cause', 'Key Notes'],
          rows: [
            ['M', 'Methanol, Metformin', 'Visual symptoms with methanol; lactic acidosis with metformin'],
            ['U', 'Uremia', 'Renal failure — accumulation of organic acids'],
            ['D', 'DKA', 'Glucose >250, ketonemia, pH<7.3'],
            ['P', 'Propylene glycol, Paraldehyde', 'Found in some IV medications'],
            ['I', 'Isoniazid, Iron', 'Toxic ingestion'],
            ['L', 'Lactic acidosis', 'Shock, sepsis, ischemia, cyanide, liver failure'],
            ['E', 'Ethylene glycol', 'Antifreeze; calcium oxalate crystals in urine'],
            ['S', 'Salicylates', 'Mixed respiratory alkalosis + metabolic acidosis'],
          ],
        },
      },
      {
        heading: 'Cardiac Dysrhythmias — Perioperative Management',
        bullets: [
          'SVT: Adenosine 6 mg rapid IV push (12 mg ×2 if needed); cardiovert if unstable',
          'A-fib with RVR: Rate control (metoprolol, diltiazem); cardiovert if hemodynamically unstable',
          'VT (pulseless): Defibrillate 200J biphasic; amiodarone 300 mg IV; follow ACLS',
          'VF: Immediate defibrillation; CPR; epinephrine 1 mg q3-5 min',
          'Bradycardia: Atropine 0.5 mg IV (up to 3 mg); pacing if refractory',
          'Torsades: Magnesium sulfate 1-2 g IV; correct QT-prolonging drugs',
        ],
      },
      {
        heading: '5 Hs and 5 Ts — Reversible Causes of Cardiac Arrest',
        bullets: [
          '5 Hs: Hypovolemia, Hypoxia, Hydrogen ion (acidosis), Hypo/Hyperkalemia, Hypothermia',
          '5 Ts: Tension pneumothorax, Tamponade (cardiac), Toxins, Thrombosis (pulmonary), Thrombosis (coronary)',
          'Treat all reversible causes simultaneously during CPR',
          'TEE is invaluable in unexplained intraoperative cardiac arrest',
        ],
      },
      {
        heading: 'Final Board Day Checklist',
        bullets: [
          '4 domains: Basic Sciences 20%, Equipment 20%, General Principles 35%, Surgical/Special 25%',
          'The NCE is adaptive — a hard question is a GOOD sign; stay calm and keep going',
          'For MCR "select ALL that apply": evaluate each option independently; no partial credit',
          'If exam stops at 100 questions — do NOT assume you failed; most passes occur at minimum count',
          'Pass rate (2025): 90.5% first-time — the odds are strongly in your favor',
          'Review AANA practice advisories and standards for ethics/scope of practice questions',
        ],
      },
    ],
  },
];

function SectionBlock({ section }) {
  return (
    <div className="mb-4">
      <h4 className="text-xs font-bold text-muted-foreground uppercase tracking-wider mb-2">{section.heading}</h4>
      {section.bullets && (
        <ul className="space-y-1.5">
          {section.bullets.map((b, i) => (
            <li key={i} className="flex gap-2 text-sm text-foreground">
              <span className="text-primary mt-0.5 shrink-0">•</span>
              <span>{b}</span>
            </li>
          ))}
        </ul>
      )}
      {section.table && (
        <div className="overflow-x-auto rounded-xl border border-border">
          <table className="w-full text-xs">
            <thead>
              <tr className="bg-muted">
                {section.table.headers.map((h, i) => (
                  <th key={i} className="text-left px-3 py-2 font-semibold text-foreground border-b border-border">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {section.table.rows.map((row, ri) => (
                <tr key={ri} className={ri % 2 === 0 ? 'bg-card dark:bg-gray-900' : 'bg-muted/40'}>
                  {row.map((cell, ci) => (
                    <td key={ci} className="px-3 py-2 text-foreground align-top border-b border-border/50 last:border-b-0">{cell}</td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function DomainCard({ domain }) {
  const [open, setOpen] = useState(false);
  return (
    <div className={`rounded-2xl border-2 ${domain.color} overflow-hidden`}>
      <button
        onClick={() => setOpen(o => !o)}
        className="w-full flex items-center gap-3 p-4 text-left hover:opacity-90 active:scale-[0.99] transition-all"
      >
        <span className="text-2xl shrink-0">{domain.emoji}</span>
        <div className="flex-1 min-w-0">
          <p className="font-bold text-sm text-foreground leading-snug">{domain.title}</p>
          <p className="text-xs text-muted-foreground mt-0.5">{domain.sections.length} topics</p>
        </div>
        {open ? <ChevronUp className="w-4 h-4 text-muted-foreground shrink-0" /> : <ChevronDown className="w-4 h-4 text-muted-foreground shrink-0" />}
      </button>
      {open && (
        <div className="px-4 pb-4 bg-card dark:bg-gray-900 border-t border-border/50 space-y-5 pt-4">
          {domain.sections.map((s, i) => <SectionBlock key={i} section={s} />)}
        </div>
      )}
    </div>
  );
}

export default function NCEReviewGuide() {
  return (
    <div className="flex flex-col pb-6">
      {/* Header */}
      <div className="bg-teal-700 text-white px-4 py-5 rounded-2xl mb-4">
        <div className="flex items-center gap-3 mb-2">
          <BookOpen className="w-6 h-6" />
          <span className="text-xs font-bold uppercase tracking-widest opacity-80">CE HALO LLC</span>
        </div>
        <h2 className="font-heading font-bold text-xl leading-tight">NBCRNA NCE Comprehensive Review Course</h2>
        <p className="text-sm opacity-80 mt-1">Aligned to the 2024-2026 NBCRNA NCE Content Outline</p>
        <p className="text-xs opacity-60 mt-1">All Four Domains · High-Yield Tables · Clinical Pearls</p>
      </div>

      <div className="space-y-3">
        {DOMAINS.map(domain => <DomainCard key={domain.id} domain={domain} />)}
      </div>

      <div className="mt-4 p-3 bg-amber-50 border border-amber-200 rounded-xl">
        <p className="text-xs text-amber-800 font-medium">⚠️ For educational use only. Not for clinical decision-making. © CE HALO LLC 2026</p>
      </div>
    </div>
  );
}