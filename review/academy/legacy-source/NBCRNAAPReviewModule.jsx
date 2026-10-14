import { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';

const systems = [
  {
    id: 'cardiovascular',
    number: 1,
    title: 'Cardiovascular System',
    emoji: '🫀',
    color: 'border-red-200 bg-red-50/30',
    headerColor: 'text-red-700',
    sections: [
      {
        title: 'Anatomy Overview',
        content: `**Heart Chambers and Valves**
• The right atrium receives deoxygenated blood via the SVC, IVC, and coronary sinus. The right ventricle (RV) ejects into the pulmonary artery through the pulmonic valve.
• The left atrium receives oxygenated blood from four pulmonary veins. The left ventricle (LV) ejects into the aorta through the aortic valve.
• Four cardiac valves: mitral (bicuspid), tricuspid, aortic, and pulmonic. Aortic and pulmonic are semilunar; mitral and tricuspid are atrioventricular.

**Coronary Arteries**
• Left main coronary → LAD (anterior LV + septum) + LCx (lateral + posterior LV)
• RCA → RV, inferior LV, SA and AV nodes (~60% of patients; right-dominant)
• Coronary perfusion is diastolic — tachycardia is dangerous in CAD

**Conduction System**
SA node → AV node → Bundle of His → Bundle branches → Purkinje fibers
• Parasympathetic (vagus) slows conduction; sympathetic (T1–T4) accelerates

**Pericardium**
• Fibrous pericardium limits acute dilation. Beck's triad of tamponade: hypotension, muffled heart sounds, JVD`
      },
      {
        title: 'Physiology Review',
        content: `**The Cardiac Cycle**
• Systole (~1/3): isovolumetric contraction → rapid ejection → reduced ejection
• Diastole (~2/3): isovolumetric relaxation → rapid filling → atrial contraction (~20–25% of EDV)
• S1: mitral/tricuspid closure | S2: aortic/pulmonic closure | S3: rapid filling (CHF) | S4: stiff ventricle (diastolic dysfunction)

**Cardiac Output: CO = HR × SV**
Stroke Volume is determined by:
1. Preload — EDV/filling pressure (CVP 2–8 mmHg; PAOP 6–12 mmHg); Frank-Starling law
2. Afterload — impedance to ejection (LV → SVR; RV → PVR); SVR = [(MAP–CVP)/CO] × 80 (normal 800–1200 dynes·sec·cm⁻⁵)
3. Contractility — intrinsic force; EF = SV/EDV × 100 (normal ≥55%)

**Coronary Perfusion Pressure (CPP)**
CPP = Aortic DBP – LVEDP (normal ~70–80 mmHg)
• Ischemia risk: ↑ HR (↓ diastolic time), ↓ DBP, ↑ LVEDP

**BP Regulation**
MAP = CO × SVR = DBP + 1/3(SBP–DBP)
• Baroreceptors (carotid/aortic arch) — rapid response
• RAAS (kidneys) — long-term via angiotensin II + aldosterone
• Chemoreceptors — hypoxia/hypercapnia/acidosis`
      },
      {
        title: 'Key Formulas & Normal Values',
        isTable: true,
        rows: [
          ['Cardiac Output (CO)', 'CO = HR × SV', '4–8 L/min'],
          ['Cardiac Index (CI)', 'CI = CO / BSA', '2.5–4.0 L/min/m²'],
          ['Stroke Volume (SV)', 'SV = EDV – ESV', '60–100 mL/beat'],
          ['Ejection Fraction (EF)', 'EF = SV / EDV × 100', '≥55%'],
          ['MAP', 'DBP + 1/3 (SBP–DBP)', '70–105 mmHg'],
          ['SVR', '[(MAP–CVP)/CO] × 80', '800–1200 dynes·sec·cm⁻⁵'],
          ['CPP', 'DBP – LVEDP', '~70–80 mmHg'],
          ['CVP', '—', '2–8 mmHg'],
          ['PAOP (wedge)', '—', '6–12 mmHg'],
          ['CaO₂', '(1.38 × Hgb × SaO₂) + (PaO₂ × 0.0031)', '18–21 mL/dL'],
        ]
      },
      {
        title: 'Anesthesia Implications',
        content: `**Volatile Agents**
| Agent | HR | MAP | SVR | Contractility |
| Isoflurane | ↑ (reflex) | ↓↓ | ↓↓ | ↓ mild |
| Sevoflurane | 0 | ↓↓ | ↓↓ | ↓ mild (best CV profile) |
| Desflurane | ↑↑ at rapid↑ | ↓↓ | ↓↓ | ↓ mild — avoid for induction |
| Halothane | 0 | ↓↓ | 0/↓ | ↓↓↓ — epinephrine sensitization |

**IV Agents**
• Propofol: ↓ MAP via ↓SVR + mild negative inotropy; reduce 30–50% in elderly/cardiac/hypovolemic
• Etomidate: Most hemodynamically stable; preferred for cardiac-compromised patients (single dose → adrenocortical suppression 8–24 hrs)
• Ketamine: ↑ HR, ↑ MAP, ↑ CO via catecholamine release; direct myocardial depressant in catecholamine-depleted patients
• Dexmedetomidine: α₂-agonist → ↓ HR, ↓ MAP; transient initial hypertension

**Pathology-Specific Management**
• CAD: maintain HR 50–70 bpm, DBP ≥60 mmHg; continue β-blockers preop
• Aortic Stenosis ("5 no's"): no tachycardia, no hypotension, no vasodilation, no bradycardia, no ↓ preload; phenylephrine preferred vasopressor
• Aortic Regurgitation: HR 70–90 bpm, reduce SVR; avoid phenylephrine
• Mitral Stenosis: HR 60–80 bpm, maintain sinus rhythm; beware pulmonary HTN
• Mitral Regurgitation: HR 80–100 bpm, reduce SVR; avoid bradycardia
• HOCM: high preload, high SVR, HR 50–70; avoid vasodilation/tachycardia/hypovolemia; treat with phenylephrine + fluids (NOT ephedrine/dobutamine)
• Cardiac Tamponade: maintain HR, SVR, preload; ketamine preferred induction agent`
      },
      {
        title: 'High-Yield Pearls',
        isPearls: true,
        pearls: [
          'Coronary perfusion occurs in diastole. CPP = DBP – LVEDP. Tachycardia reduces CPP by shortening diastolic time AND increasing LVEDP.',
          'Propofol causes hypotension through vasodilation and negative inotropy — reduce induction dose 30–50% in elderly, hypovolemic, or cardiac-compromised patients.',
          'Volatile anesthetic ischemic preconditioning (sevo > des > iso): cardioprotection via mitochondrial K-ATP channels.',
          'Desflurane should NOT be used for inhalational induction — rapid concentration increases cause sympathoadrenal surges.',
          'In HOCM: treat hypotension with phenylephrine and IV fluids, NOT ephedrine or dopamine.',
          'SVV >12–13% predicts fluid responsiveness only in patients with regular cardiac rhythm on controlled mechanical ventilation with Vt >6 mL/kg.',
          "Beck's triad: hypotension, muffled heart sounds, JVD. Electrical alternans on ECG is pathognomonic for tamponade.",
          'EF alone is insufficient to assess diastolic dysfunction — HFpEF (EF >55%) can have severe heart failure.',
        ]
      }
    ]
  },
  {
    id: 'respiratory',
    number: 2,
    title: 'Respiratory System',
    emoji: '🫁',
    color: 'border-sky-200 bg-sky-50/30',
    headerColor: 'text-sky-700',
    sections: [
      {
        title: 'Anatomy Overview',
        content: `**Upper Airway**
• Larynx at C3–C6; cricoid cartilage = only complete tracheal ring + narrowest point of pediatric airway
• Cricothyroid membrane = landmark for surgical airway (CICO)
• RLN (CN X branch) innervates all intrinsic laryngeal muscles except cricothyroid (external superior laryngeal nerve)

**Tracheobronchial Tree**
• Trachea bifurcates at carina (T4/T5); right main bronchus shorter + more vertical (25°) → endobronchial intubation + foreign body aspiration
• Left main bronchus longer + more horizontal (45°) → preferred for left-sided DLT

**Respiratory Muscles**
• Primary: Diaphragm (phrenic nerve C3, C4, C5 — "C3, 4, 5 keeps the diaphragm alive")
• Passive expiration; active expiration = internal intercostals + abdominals

**Alveoli**
• ~300 million alveoli; surface area ~70 m²
• Type I: gas exchange (90% of surface); Type II: surfactant (DPPC) production
• Surfactant: begins 24–28 weeks gestation; mature by ~35 weeks; absent in RDS of newborn`
      },
      {
        title: 'Physiology Review',
        content: `**Lung Volumes**
• FRC = ERV + RV = 2300–2500 mL (30 mL/kg) — most important volume in anesthesia
• FRC decreases: supine (~20%), GA (additional ~20%), obesity/pregnancy/Trendelenburg
• FRC < closing capacity → V/Q mismatch + shunting

**FRC and Safe Apnea Time**
• Healthy adult: ~6–8 min post pre-oxygenation
• Obese: ~2–3 min | Pregnant (term): ~1.5–3 min | Neonate: ~1–2 min

**V/Q Matching**
• Ideal V/Q = 1.0; bases: lower V/Q (~0.6); apices: higher V/Q (~3.0)
• True shunt (V/Q = 0): does NOT respond to supplemental O₂
• West's Zones: Zone 3 (Pa > Pv > PA) = dominant; Zone 1 (PA > Pa > Pv) = increased with PEEP

**Oxyhemoglobin Dissociation Curve**
• P50 = 26.7 mmHg; PaO₂ 60 mmHg ≈ SaO₂ 90% (steep portion threshold)
• Right shift (↓ affinity): ↑ Temp, ↑ PaCO₂ (Bohr effect), ↑ 2,3-DPG, ↑ H⁺
• Left shift (↑ affinity): ↓ Temp, ↓ PaCO₂, HbF, carboxyhemoglobin

**HPV (Hypoxic Pulmonary Vasoconstriction)**
• Inhibited by: volatile agents (all, dose-dependent), vasodilators, high FiO₂
• Preserved by: IV anesthetics (propofol, ketamine, opioids) → TIVA preferred for OLV

**Control of Breathing**
• Central chemoreceptors (medulla): PaCO₂ primary driver; 1 mmHg ↑ PaCO₂ → ~2–3 L/min ↑ VE
• Peripheral chemoreceptors (carotid body): hypoxia (PaO₂ <60 mmHg)`
      },
      {
        title: 'Key Formulas & Normal Values',
        isTable: true,
        rows: [
          ['Alveolar Gas Equation', 'PAO₂ = FiO₂ × (PB – PH₂O) – PaCO₂/RQ', '~100 mmHg (room air)'],
          ['A-a Gradient', 'PAO₂ – PaO₂', '3–16 mmHg (increases with age)'],
          ['VD/VT ratio', '(PaCO₂ – PēCO₂) / PaCO₂', '0.25–0.33'],
          ['FRC', 'ERV + RV', '2300–2500 mL (30 mL/kg)'],
          ['Tidal Volume', '—', '6–8 mL/kg IBW'],
          ['PaO₂', '—', '80–100 mmHg'],
          ['PaCO₂', '—', '35–45 mmHg'],
          ['FEV₁/FVC', '—', '>0.70 (normal)'],
          ['Minute Ventilation', 'TV × RR', '5–8 L/min'],
          ['RQ', 'VCO₂/VO₂', '0.8 (mixed diet)'],
        ]
      },
      {
        title: 'Anesthesia Implications',
        content: `**Effects of GA on Respiration**
• FRC decreases within 15–40 sec of induction → atelectasis in 90%+ of patients
• Pre-oxygenation: 3–5 min of 100% FiO₂ or 4 vital capacity breaths

**Volatile Agents**
• All cause dose-dependent respiratory depression: ↓ TV, ↑ RR (net ↓ alveolar ventilation)
• Hypercapnic response reduced ~50% at 1 MAC; nearly abolished at 1.5 MAC
• Desflurane = airway irritant → bronchospasm, coughing, laryngospasm; AVOID in reactive airway disease and for inhalational induction
• Isoflurane + sevoflurane = bronchodilators (useful in status asthmaticus)

**One-Lung Ventilation (OLV)**
1. ↑ FiO₂ to 1.0
2. CPAP 5–10 cmH₂O to operative (non-ventilated) lung
3. PEEP 5–10 cmH₂O to ventilated lung
4. Alveolar recruitment
5. Switch to TIVA if severe hypoxemia
6. Intermittent two-lung ventilation

**Lung-Protective Ventilation**
• TV 6 mL/kg IBW | Plateau pressure <30 cmH₂O | PEEP per protocol | I:E ≥1:2 (1:3–4 for obstructive)

**COPD:** prolonged expiratory time; risk of auto-PEEP and pneumothorax
**Asthma:** "shark fin" capnograph; treat with sevoflurane/propofol, albuterol, IV epinephrine, magnesium
**OSA:** STOP-BANG ≥3 = high risk; minimize opioids; CPAP perioperatively`
      },
      {
        title: 'High-Yield Pearls',
        isPearls: true,
        pearls: [
          'FRC decreases ~40% under GA (supine + anesthetic effect) → atelectasis and V/Q mismatch. PEEP partially restores FRC.',
          'Right main bronchus intubation: unilateral breath sounds, ↓ SpO₂, ↑ peak airway pressure. Withdraw ETT 2–3 cm.',
          'Desflurane is airway-irritant — coughing, laryngospasm, bronchospasm. Use sevoflurane for inhalational induction.',
          'HPV is inhibited by volatile agents. Propofol-based TIVA preserves HPV — clinically relevant during OLV.',
          'Safe apnea time is dramatically reduced in obese, pregnant, and pediatric patients. Pre-oxygenate aggressively.',
          'PaO₂ <60 mmHg ≈ SpO₂ 90% — steep portion of ODC; small decreases in PaO₂ cause large drops in SaO₂.',
          'Capnography (EtCO₂) is the most reliable monitor to confirm ETT placement. Normal EtCO₂ 35–45 mmHg.',
          'Normal A-a gradient ≈ (Age/4 + 4) mmHg. Elevated indicates V/Q mismatch, shunt, or diffusion impairment.',
          'Pulse oximetry cannot detect hyperoxia, hypercapnia, or CO poisoning. Use co-oximetry in suspected CO poisoning.',
        ]
      }
    ]
  },
  {
    id: 'renal',
    number: 3,
    title: 'Renal System',
    emoji: '🫘',
    color: 'border-teal-200 bg-teal-50/30',
    headerColor: 'text-teal-700',
    sections: [
      {
        title: 'Anatomy & Physiology Review',
        content: `**Nephron Segments**
1. Renal corpuscle (glomerulus + Bowman's capsule) — filtration
2. PCT — 65% Na⁺/H₂O, 100% glucose/amino acids, 85% HCO₃⁻ reabsorption; angiotensin II stimulates
3. Loop of Henle (thick ascending: NKCC2 cotransporter = furosemide target)
4. DCT — NCC cotransporter (thiazide target); Ca²⁺ under PTH
5. Collecting duct — ADH (AQP2) + aldosterone (ENaC)

**GFR**
• Normal 120–125 mL/min; autoregulated MAP 70–160 mmHg
• Myogenic mechanism + tubuloglomerular feedback (macula densa)
• FF = GFR/RPF ≈ 20%; RBF = ~1200 mL/min (20–25% CO)

**RAAS**
• Renin → Angiotensin I → ACE (lung) → Angiotensin II
• Ang II: potent vasoconstriction, aldosterone secretion, ADH release, PCT Na⁺ reabsorption, efferent arteriole constriction (maintains GFR)
• ACEi/ARBs → AKI risk; hold morning of major surgery

**Acid-Base**
• Anion gap = Na⁺ – (Cl⁻ + HCO₃⁻); normal 8–12 mEq/L
• MUDPILES: Methanol, Uremia, DKA, Propylene glycol, Isoniazid/Infection, Lactic acidosis, Ethylene glycol, Salicylates`
      },
      {
        title: 'Key Formulas & Normal Values',
        isTable: true,
        rows: [
          ['GFR', 'Kf × Net filtration pressure', '120–125 mL/min'],
          ['Creatinine clearance', '[(140–age) × kg] / (72 × SCr)', '80–120 mL/min (males)'],
          ['BUN:Cr ratio', 'BUN / SCr', '10–20:1 (>20:1 = prerenal)'],
          ['RBF', '—', '~1200 mL/min (20–25% CO)'],
          ['Urine output', '—', '≥0.5 mL/kg/hr'],
          ['Serum Na⁺', '—', '135–145 mEq/L'],
          ['Serum K⁺', '—', '3.5–5.0 mEq/L'],
          ['Osmolality', '2 × Na⁺ + Glucose/18 + BUN/2.8', '275–295 mOsm/kg'],
          ['FENa', '(Urine Na⁺ × Plasma Cr) / (Plasma Na⁺ × Urine Cr) × 100', '<1% prerenal; >2% ATN'],
        ]
      },
      {
        title: 'Anesthesia Implications',
        content: `**Anesthesia Effects on Renal Function**
• All techniques reduce RBF/GFR by 20–40% (↓ CO/MAP, sympathetic activation, ADH release)
• Sevoflurane + Compound A: maintain FGF >2 L/min, especially in pre-existing renal disease
• NSAIDs: inhibit prostaglandins → afferent vasoconstriction → ↓ GFR; avoid in AKI risk
• Cisatracurium = NMB of choice in renal failure (Hofmann elimination)
• Avoid: pancuronium (renal excretion), morphine (M6G accumulates), meperidine (normeperidine → seizures)
• Prefer: fentanyl, remifentanil, cisatracurium, propofol

**Drug Dosing in Renal Failure**
| Drug | Notes |
| Succinylcholine | Raises K⁺ ~0.5 mEq/L; unsafe if K⁺ ≥5.5 mEq/L or with upregulated extrajunctional receptors |
| Cisatracurium | Drug of choice — Hofmann elimination |
| Morphine | M6G accumulates — respiratory depression risk |
| Meperidine | Normeperidine → seizures — AVOID |
| Remifentanil | Preferred — minimal accumulation |

**Perioperative AKI (KDIGO)**
• Stage 1: SCr ≥1.5× baseline or ↑≥0.3 mg/dL within 48 hrs
• Stage 2: SCr ≥2× baseline
• Stage 3: SCr ≥3× or need for RRT
• Prerenal: BUN:Cr >20:1, UNa <20, FENa <1%, Uosm >500; responds to fluids
• Intrinsic (ATN): BUN:Cr ~10:1, UNa >40, FENa >2%, Uosm ~290 (isosthenuria)`
      },
      {
        title: 'High-Yield Pearls',
        isPearls: true,
        pearls: [
          'GFR autoregulation occurs between MAP 70–160 mmHg. Serum creatinine does not rise until GFR has decreased by ~50%.',
          'Succinylcholine raises K⁺ by ~0.5 mEq/L. Upregulated extrajunctional receptors (burns, crush, denervation) can cause K⁺ rise of 5–10 mEq/L → fatal hyperkalemia.',
          'Cisatracurium is the NMB of choice in renal (and hepatic) failure — Hofmann elimination is organ-independent.',
          '"Renal-dose" dopamine does NOT protect renal function. Maintain MAP and euvolemia instead.',
          'ACEi/ARBs should be held the morning of major surgery to prevent intraoperative vasodilatory hypotension and AKI.',
          'FENa <1% = prerenal; FENa >2% = intrinsic ATN. Note: FENa may be falsely low in contrast nephropathy and myoglobinuria.',
          'Compound A from sevoflurane: maintain FGF >2 L/min, especially in patients with pre-existing renal disease.',
          'Uremic platelet dysfunction: treat with DDAVP (desmopressin 0.3 μg/kg IV) before elective major surgery.',
        ]
      }
    ]
  },
  {
    id: 'neurologic',
    number: 4,
    title: 'Neurologic System: CNS & ANS',
    emoji: '🧠',
    color: 'border-purple-200 bg-purple-50/30',
    headerColor: 'text-purple-700',
    sections: [
      {
        title: 'Anatomy & Physiology Review',
        content: `**CNS Anatomy**
• Spinal cord: foramen magnum → L1–L2 (conus medullaris); dural sac ends at S2 (lumbar puncture below L2)
• CSF: produced by choroid plexus ~500 mL/day; total volume ~150 mL; absorbed by arachnoid granulations
• Normal ICP: 5–15 mmHg (supine adult)
• BBB: disrupted by inflammation, TBI, ischemia; lipid-soluble agents cross readily

**Cerebral Blood Flow (CBF)**
• Normal CBF: 50–55 mL/100 g/min; CMRO₂: 3.0–3.5 mL O₂/100 g/min
• CBF autoregulation: MAP 50–150 mmHg; impaired by >1 MAC volatile agents and TBI
• PaCO₂ most potent regulator: CBF changes 1–2 mL/100g/min per 1 mmHg PaCO₂ change
• Hypercapnia → ↑ CBF → ↑ ICP; hypocapnia → ↓ CBF (hyperventilate to PaCO₂ 30–35 mmHg for acute ICP crisis)

**CPP = MAP – ICP** (target ≥60 mmHg; TBI target 60–70 mmHg)

**Monro-Kellie Doctrine**
Brain + CSF + Blood = Constant; once reserve exhausted, small ↑ volume → exponential ↑ ICP

**ICP Treatment**
• Head elevation 30° → ↑ venous drainage
• Hyperventilation (PaCO₂ 28–35 mmHg) → rapid, transient ↓ ICP
• Mannitol 0.25–1 g/kg → osmotic → ↓ brain water
• Hypertonic saline (3% or 23.4%) → osmotherapy

**ANS**
• Sympathetic (T1–L2): NE at adrenergic receptors (exception: adrenal medulla + sweat glands = ACh)
• Parasympathetic (craniosacral): ACh at muscarinic (postganglionic) + nicotinic (ganglionic)
• SLUDGE = muscarinic excess: Salivation, Lacrimation, Urination, Defecation, GI upset, Emesis
• β₁: heart (HR, contractility, renin) | β₂: bronchodilation, vasodilation, uterine relaxation
• α₁: vasoconstriction, mydriasis | α₂: ↓ NE release (feedback), sedation, analgesia`
      },
      {
        title: 'Key Formulas & Normal Values',
        isTable: true,
        rows: [
          ['CPP', 'MAP – ICP', '60–100 mmHg'],
          ['TBI CPP target', '—', '60–70 mmHg'],
          ['Normal ICP', '—', '5–15 mmHg'],
          ['Normal CBF', '—', '50–55 mL/100 g/min'],
          ['CMRO₂', '—', '3.0–3.5 mL O₂/100 g/min'],
          ['CBF/PaCO₂ change', '1–2 mL/100g/min per 1 mmHg', 'Range: PaCO₂ 20–80 mmHg'],
          ['CMRO₂ per °C', '~7% per 1°C', 'Q₁₀ effect'],
          ['Total CSF volume', '—', '~150 mL'],
          ['CSF production', '—', '~500 mL/day (~0.35 mL/min)'],
        ]
      },
      {
        title: 'Anesthetic Effects on CBF/CMRO₂/ICP',
        isTable: true,
        rows: [
          ['Propofol', '↓↓', '↓↓', '↓', 'Preserved', 'Preserved'],
          ['Etomidate', '↓', '↓', '↓', 'Not established', 'Preserved'],
          ['Ketamine', '↑↑', '↑', '↑', 'Impaired', '—'],
          ['Volatile agents (>1 MAC)', '↑', '↓', '↑', 'Impaired', 'Preserved'],
          ['N₂O', '↑', '↑', '↑', 'Impaired', 'Preserved'],
          ['Dexmedetomidine', '↓', '↓', '↓', 'Preserved', 'Preserved'],
          ['Opioids (low dose)', '0/↓', '0/↓', '0/↓', 'Preserved', 'Preserved'],
        ],
        tableHeaders: ['Agent', 'CBF', 'CMRO₂', 'ICP', 'Autoregulation', 'CO₂ Reactivity']
      },
      {
        title: 'Anesthesia Implications',
        content: `**Neuroanesthesia Principles**
1. Maintain CPP ≥60 mmHg (MAP 70–100 mmHg)
2. Avoid hypercapnia (↑ ICP) and excessive hypocapnia (cerebral ischemia)
3. Avoid hypoxia (PaO₂ <60 → ↑ CBF, ↑ ICP)
4. Maintain serum osmolality 290–320 mOsm
5. Normoglycemia (hyperglycemia worsens ischemia; target 140–180 mg/dL)
6. Temperature management — avoid hyperthermia

**Induction for Craniotomy (elevated ICP)**
• Lidocaine 1.5 mg/kg IV 3 min before laryngoscopy
• Fentanyl 1–2 mcg/kg ± esmolol to blunt hemodynamic response
• Propofol or thiopental for induction (↓ ICP, ↓ CMRO₂)
• Rocuronium or vecuronium (avoid sux if suspected elevated ICP, though mild transient ICP increase)
• Hyperventilate to PaCO₂ 35 mmHg (30–35 if acutely elevated)
• Etomidate: preferred if hemodynamically unstable with elevated ICP

**Autonomic Dysreflexia (SCI ≥ T6)**
• Noxious stimulus below injury → massive sympathetic discharge → BP >300 mmHg systolic + reflex bradycardia
• Treat: remove stimulus (empty bladder), upright position, nitroglycerin/nitroprusside, spinal/GA

**Succinylcholine in SCI:** hyperkalemia risk begins 24–48 hours post-injury and persists for years`
      },
      {
        title: 'High-Yield Pearls',
        isPearls: true,
        pearls: [
          'CPP = MAP – ICP. To maintain CPP >60 mmHg with elevated ICP, MAP must be supported — even modest MAP reduction can precipitate cerebral ischemia.',
          'Ketamine increases CBF, CMRO₂, and ICP — use with caution in TBI/elevated ICP. When combined with propofol or benzo, ICP increase may be attenuated.',
          'Autoregulation of CBF is impaired at >1 MAC of any volatile agent. Use ≤0.5 MAC or TIVA in patients with poor intracranial compliance.',
          'N₂O increases CMRO₂ and ICP — avoided in neuroanesthesia. Also avoid when air emboli are a risk or in patients with pneumocephalus.',
          'Etomidate is ideal when hemodynamic stability with ICP reduction is needed. Single dose causes adrenocortical suppression for 8–24 hrs.',
          'Cushing\'s response: rising ICP → hypertension, bradycardia, irregular respiration — late, ominous sign of brainstem herniation.',
          'α₂-agonists (dexmedetomidine): reduce MAC by up to 50%, anxiolysis without respiratory depression, useful in neurointensive care.',
          'Succinylcholine should be avoided after 48 hours of SCI, severe burns, denervation, or prolonged immobilization — fatal hyperkalemia risk.',
        ]
      }
    ]
  },
  {
    id: 'endocrine',
    number: 5,
    title: 'Endocrine System',
    emoji: '⚗️',
    color: 'border-amber-200 bg-amber-50/30',
    headerColor: 'text-amber-700',
    sections: [
      {
        title: 'Anatomy & Physiology Review',
        content: `**Adrenal Glands**
• Cortex (80%): Zona Glomerulosa (aldosterone), Zona Fasciculata (cortisol), Zona Reticularis (androgens) — "GFR: Salt, Sugar, Sex"
• Medulla (20%): 80% epinephrine, 20% norepinephrine; modified sympathetic ganglion

**Thyroid**
• T3 (3–4× more potent than T4); T4 converted peripherally to T3 (deiodination); most bound to TBG
• TSH: 0.4–4.5 mIU/L (most sensitive) | fT4: 0.8–1.8 ng/dL | fT3: 2.3–4.2 pg/mL
• ↑ BMR, ↑ VO₂, ↑ CO (↑ HR, ↑ contractility), ↑ GI motility

**Cortisol**
• Normal secretion: 20–30 mg/day; surgical stress: up to 100–300 mg/day
• Actions: anti-inflammatory, gluconeogenesis, protein catabolism, permissive on catecholamines
• Dexamethasone: anti-inflammatory potency 25×; minimal mineralocorticoid activity; long duration (36–72 hr)

**Insulin/Glucagon**
• Surgery → catecholamine + cortisol → insulin resistance + ↑ hepatic glucose → hyperglycemia
• Target intraoperative glucose: 140–180 mg/dL
• Glucagon stimulates cardiac β₁ receptors → inotropic/chronotropic (used in β-blocker/CCB overdose)`
      },
      {
        title: 'Key Formulas & Normal Values',
        isTable: true,
        rows: [
          ['Fasting glucose', '—', '70–100 mg/dL'],
          ['HbA1c', '—', '<5.7% normal; ≥6.5% DM'],
          ['TSH', '—', '0.4–4.5 mIU/L'],
          ['Free T4', '—', '0.8–1.8 ng/dL'],
          ['Serum cortisol (AM)', '—', '10–20 μg/dL'],
          ['Daily cortisol', '—', '20–30 mg/day (basal); up to 300 mg/day (stress)'],
          ['Serum calcium (total)', '—', '8.5–10.5 mg/dL'],
          ['Ionized calcium', '—', '1.0–1.3 mmol/L'],
          ['Intraoperative glucose target', '—', '140–180 mg/dL'],
        ]
      },
      {
        title: 'Anesthesia Implications',
        content: `**Perioperative Steroid Coverage**
• HPA suppression: chronic steroids >5 mg/day prednisone ×3 weeks (or >10 mg/day ×2 weeks)
• Minor surgery (<30 min, local): usual daily dose only
• Moderate (1–2 hr, e.g. cholecystectomy): hydrocortisone 50–75 mg IV
• Major (cardiac/vascular/hepatic): hydrocortisone 100–150 mg IV + taper over 2–3 days
• Adrenal crisis: unexplained hypotension unresponsive to vasopressors → hydrocortisone 100 mg IV bolus
• Etomidate: inhibits 11-β-hydroxylase → cortisol synthesis blocked 8–24 hrs; avoid in sepsis

**Thyroid Storm (Burch-Wartofsky Score >45)**
• Fever >40°C, HR >140 bpm, agitation/delirium, high-output HF
1. PTU or Methimazole — block synthesis
2. Iodine (after PTU) — Wolff-Chaikoff effect, blocks release
3. β-Blockers (propranolol/esmolol) — ↓ HR, ↓ T4→T3 conversion
4. Hydrocortisone 100 mg IV q8h — prevents adrenal insufficiency, ↓ T4→T3

**Hypothyroidism:** ↓ MAC, bradycardia, hypothermia, delayed gastric emptying (aspiration risk), macroglossia (difficult airway), prolonged drug effects

**Pheochromocytoma**
• α-blockade FIRST (phenoxybenzamine 10–14 days), THEN β-blockade (NEVER β before α → unopposed α crisis)
• Intraop: tumor manipulation → hypertensive surge (nitroprusside/phentolamine); venous ligation → profound hypotension (fluids + NE)

**Diabetes Perioperatively**
• Hold metformin 24–48 hrs before surgery (lactic acidosis risk)
• Hold SGLT-2 inhibitors ≥3 days (euglycemic DKA risk — near-normal glucose masks ketosis)
• Hold sulfonylureas morning of surgery
• SIADH: correct Na⁺ ≤0.5–1 mEq/L/hr (max 10–12 mEq/24 hrs) to prevent osmotic demyelination`
      },
      {
        title: 'High-Yield Pearls',
        isPearls: true,
        pearls: [
          'Perioperative adrenal crisis: unexplained hemodynamic instability refractory to fluids and vasopressors in patients on chronic steroids. Treatment: hydrocortisone 100 mg IV bolus.',
          'Never start β-blockers before α-blockers in pheochromocytoma — unopposed α-stimulation → catastrophic hypertensive crisis.',
          'Thyroid storm OR precipitants: surgery, infection, trauma. Manage with PTU → iodine → β-blockade → hydrocortisone.',
          'Etomidate inhibits adrenal steroidogenesis with a single dose. Use propofol or ketamine in septic/critically ill patients.',
          'SGLT-2 inhibitors (gliflozins) must be held ≥3 days before surgery — patients can develop severe ketoacidosis with near-normal glucose.',
          'In SIADH: do NOT correct hyponatremia too rapidly — maximum 10–12 mEq/L in 24 hours to prevent central pontine myelinolysis.',
          'Hyperglycemia worsens ischemic neurologic outcomes — target 140–180 mg/dL intraoperatively in cardiac and neurosurgical cases.',
          'Hypothyroid patients: reduced anesthetic doses, careful temperature management, prolonged drug effects, aspiration risk (delayed gastric emptying).',
        ]
      }
    ]
  },
  {
    id: 'hepatic',
    number: 6,
    title: 'Hepatic System',
    emoji: '🟤',
    color: 'border-orange-200 bg-orange-50/30',
    headerColor: 'text-orange-700',
    sections: [
      {
        title: 'Anatomy & Physiology Review',
        content: `**Hepatic Blood Supply (Dual)**
• Portal vein: ~75% flow (~1050 mL/min), ~50–60% O₂ — passive, unregulated
• Hepatic artery: ~25% flow (~350 mL/min), ~40–50% O₂ — autoregulated
• Total hepatic blood flow ~1400 mL/min (25% of CO)
• Hepatic Arterial Buffer Response (HABR): portal ↓ → hepatic artery ↑ (adenosine-mediated); volatile agents + cirrhosis impair HABR

**Hepatic Zones**
• Zone 1 (periportal): most resistant to ischemia; gluconeogenesis, fatty acid oxidation
• Zone 3 (centrilobular): most susceptible to ischemia + toxic injury; site of halothane hepatitis, acetaminophen toxicity; primary drug biotransformation

**Drug Metabolism**
• Phase I (CYP450): oxidation/reduction/hydrolysis — CYP3A4, CYP2D6, CYP2C9
• Phase II (conjugation): glucuronidation (most common), sulfation, glutathione conjugation
• High extraction (ER >0.7): morphine, lidocaine, fentanyl, propranolol → flow-limited clearance
• Low extraction (ER <0.3): warfarin, diazepam, phenytoin → capacity-limited (enzyme + protein binding)

**Protein Synthesis**
• Albumin (t½ 15–20 days): oncotic pressure, drug binding (acidic drugs)
• Clotting factors II, V, VII, IX, X, XI, XII, XIII (except Factor VIII and vWF)
• Vitamin K–dependent: II, VII, IX, X, Protein C/S; Factor VII t½ 4–6 hrs → PT/INR most sensitive early marker
• Pseudocholinesterase: hydrolyzes succinylcholine + ester local anesthetics; ↓ in liver disease, pregnancy (~20%), malnutrition, genetic variants`
      },
      {
        title: 'Key Formulas & Normal Values',
        isTable: true,
        rows: [
          ['Total hepatic blood flow', '—', '~1400 mL/min (25% CO)'],
          ['Albumin t½', '—', '15–20 days'],
          ['PT/INR normal', '—', 'PT 11–15 sec; INR <1.2'],
          ['Factor VII t½', '—', '4–6 hrs (earliest synthetic marker)'],
          ['Serum albumin', '—', '3.5–5.0 g/dL'],
          ['AST/ALT', '—', '<40 U/L'],
          ['Total bilirubin', '—', '0.1–1.2 mg/dL (>3 = clinical jaundice)'],
          ['Child-Pugh A', '5–6 pts', '~10% operative mortality'],
          ['Child-Pugh B', '7–9 pts', '~30% operative mortality'],
          ['Child-Pugh C', '10–15 pts', '70–80% operative mortality'],
          ['MELD Score', '3.78×ln(Bili) + 11.2×ln(INR) + 9.57×ln(Cr) + 6.43', '90-day mortality prediction'],
        ]
      },
      {
        title: 'Anesthesia Implications',
        content: `**Effects of Anesthesia on Hepatic Blood Flow**
• GA reduces hepatic blood flow 20–40% (↓ CO, MAP)
• Isoflurane better preserves hepatic blood flow vs halothane
• Halothane hepatitis Type 2 (immune-mediated): TFA-hapten formation → centrilobular necrosis; 1:10,000–1:30,000 incidence; modern agents far safer

**Drug Dosing in Hepatic Failure**
| Drug | Notes |
| Succinylcholine | ↓ pseudocholinesterase → prolonged (duration may double) |
| Cisatracurium | Preferred NMB — Hofmann elimination, liver-independent |
| Rocuronium | ~70% biliary — markedly prolonged; reversal with sugammadex reliable |
| Remifentanil | Preferred opioid — ester hydrolysis, completely liver-independent |
| Midazolam | ↑ CYP3A4 metabolism → prolonged; use lorazepam (Phase II only) instead |
| Morphine | M6G excreted renally; avoid with concurrent renal failure |

**Cirrhosis Complications**
• Hyperdynamic state: ↑ CO, ↓ SVR (NO-mediated splanchnic vasodilation)
• Hepatopulmonary syndrome (HPS): orthodeoxia (↓ SpO₂ upright, ↑ supine)
• Hepatorenal syndrome (HRS): functional renal failure; UNa <10 mEq/L; treat with NE + albumin
• Coagulopathy: ↓ clotting factors + ↓ platelets + ↓ fibrinogen + ↓ Protein C/S (balanced coagulopathy)
• Hepatic encephalopathy: avoid benzodiazepines + opioids; propofol preferred sedation; remifentanil if opioid needed
• Avoid benzodiazepines in HE — markedly worsens encephalopathy

**Liver Transplant: Three Phases**
• Phase 1 (Dissection): blood loss, coagulopathy — TEG/ROTEM-guided transfusion
• Phase 2 (Anhepatic): ↓ venous return, ↓ CO, drug accumulation, hypocalcemia from citrate
• Phase 3 (Reperfusion): cold/acidotic/hyperkalemic blood → cardiac depression; have calcium, bicarbonate, epinephrine ready`
      },
      {
        title: 'High-Yield Pearls',
        isPearls: true,
        pearls: [
          'Hepatic blood flow ≈1400 mL/min (25% CO): 75% portal vein (passive), 25% hepatic artery (autoregulated). HABR compensates for portal flow reduction. Volatile agents and cirrhosis impair HABR.',
          'Halothane hepatitis (Type 2): oxidative metabolism → TFA-hapten → immune sensitization → centrilobular necrosis. Modern volatile agents (sevo, des, iso) have far lower metabolism rates.',
          'Cisatracurium = NMB of choice in hepatic failure (Hofmann elimination). Rocuronium markedly prolonged; reversal with sugammadex is reliable.',
          'Succinylcholine duration is prolonged in hepatic failure due to ↓ pseudocholinesterase. Duration may double in severe liver disease.',
          'High-extraction drugs (morphine, lidocaine, fentanyl, propranolol): clearance is flow-dependent. ↓ CO → ↓ clearance → accumulation. Portosystemic shunting also reduces first-pass metabolism.',
          'Factor VII has the shortest half-life (~4–6 hrs) of all liver-synthesized clotting factors — PT/INR is the most sensitive early marker of hepatic synthetic failure.',
          'Hypoalbuminemia in liver disease → ↑ free fraction of acidic protein-bound drugs (diazepam, phenytoin, warfarin, propofol) → amplified drug effect. Titrate carefully.',
          'Remifentanil is the safest opioid in severe liver failure — ester hydrolysis by non-specific plasma esterases is completely liver-independent.',
          'Reperfusion syndrome during liver transplant: cold/acidotic/hyperkalemic blood from new liver → cardiac depression. Prepare calcium, bicarbonate, epinephrine immediately.',
        ]
      }
    ]
  }
];

const references = [
  { category: 'Textbooks', items: [
    'Miller RD, et al. Miller\'s Anesthesia, 9th ed. Elsevier, 2020.',
    'Barash PG, et al. Clinical Anesthesia, 8th ed. Lippincott Williams & Wilkins, 2017.',
    'Nagelhout JJ, Elisha S. Nurse Anesthesia, 6th ed. Elsevier, 2018.',
    'Stoelting RK, Hillier SC. Pharmacology & Physiology in Anesthetic Practice, 4th ed. LWW.',
    'Guyton AC, Hall JE. Textbook of Medical Physiology, 14th ed. Elsevier.',
  ]},
  { category: 'Cardiovascular', items: [
    'StatPearls: Physiology, Cardiovascular. https://www.ncbi.nlm.nih.gov/books/NBK493197/',
    'Effects of Anesthetic Agents on Cardiac Function. ThoracicKey. https://thoracickey.com',
    'Anesthetic-mediated cardioprotection. Frontiers in Physiology 2025. https://pmc.ncbi.nlm.nih.gov/articles/PMC12484132/',
  ]},
  { category: 'Respiratory', items: [
    'Hypoxaemia during one-lung ventilation. BJA Education/PMC. https://pmc.ncbi.nlm.nih.gov/articles/PMC10435364/',
    'StatPearls: Pulmonary Function Tests. https://www.ncbi.nlm.nih.gov/books/NBK482339/',
    'StatPearls: Inhalational Anesthetics. https://www.ncbi.nlm.nih.gov/books/NBK554540/',
  ]},
  { category: 'Renal', items: [
    'StatPearls: Physiology, Renal. https://www.ncbi.nlm.nih.gov/books/NBK538339/',
    'Anesthesia for Patients With Pre-existing Renal Failure. PMC. https://pmc.ncbi.nlm.nih.gov/articles/PMC5018084/',
  ]},
  { category: 'Neurologic / ANS', items: [
    'StatPearls: Autonomic Nervous System. https://www.ncbi.nlm.nih.gov/books/NBK595003/',
    'Volatile Anesthetics on ICP, CBF, and Autoregulation: BMJ Open. https://pmc.ncbi.nlm.nih.gov/articles/PMC11425943/',
    'OpenAnesthesia: Autonomic Neurotransmitters. https://www.openanesthesia.org/keywords/autonomic_neurotransmitters/',
  ]},
  { category: 'Endocrine', items: [
    'Perioperative Glucocorticoid Management. PMC. https://pmc.ncbi.nlm.nih.gov/articles/PMC7861897/',
    'Endocrinopathies in Anesthesia. Indian J Endocrinol Metab/PMC. https://pmc.ncbi.nlm.nih.gov/articles/PMC4481651/',
  ]},
  { category: 'Hepatic', items: [
    'StatPearls: Physiology, Liver. https://www.ncbi.nlm.nih.gov/books/NBK535438/',
    'Anesthesia for Patients With Liver Disease. PMC. https://pmc.ncbi.nlm.nih.gov/articles/PMC4080095/',
  ]},
];

function Section({ section }) {
  const [open, setOpen] = useState(false);

  return (
    <div className="rounded-xl border border-border overflow-hidden">
      <button
        onClick={() => setOpen(o => !o)}
        className="w-full flex items-center justify-between px-4 py-3 bg-card text-left hover:bg-secondary/50 transition-colors"
      >
        <span className="text-sm font-semibold text-foreground">{section.title}</span>
        {open ? <ChevronUp className="w-4 h-4 text-muted-foreground shrink-0" /> : <ChevronDown className="w-4 h-4 text-muted-foreground shrink-0" />}
      </button>
      {open && (
        <div className="px-4 py-3 bg-secondary/20 border-t border-border space-y-2">
          {section.isTable && (
            <div className="overflow-x-auto">
              <table className="w-full text-xs border-collapse">
                <thead>
                  <tr className="bg-secondary">
                    {(section.tableHeaders || ['Parameter', 'Formula', 'Normal Value']).map(h => (
                      <th key={h} className="text-left px-2 py-1.5 font-semibold text-foreground border border-border">{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {section.rows.map((row, i) => (
                    <tr key={i} className={i % 2 === 0 ? 'bg-card' : 'bg-secondary/30'}>
                      {row.map((cell, j) => (
                        <td key={j} className="px-2 py-1.5 text-foreground border border-border leading-relaxed">{cell}</td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
          {section.isPearls && (
            <div className="space-y-2">
              {section.pearls.map((pearl, i) => (
                <div key={i} className="flex items-start gap-2">
                  <span className="text-amber-500 shrink-0 mt-0.5">◆</span>
                  <p className="text-sm text-foreground leading-relaxed">{pearl}</p>
                </div>
              ))}
            </div>
          )}
          {section.content && (
            <div className="space-y-1.5">
              {section.content.split('\n').filter(l => l.trim()).map((line, i) => {
                if (line.startsWith('**') && line.endsWith('**')) {
                  return <p key={i} className="text-xs font-bold text-muted-foreground uppercase tracking-wide mt-3 first:mt-0">{line.replace(/\*\*/g, '')}</p>;
                }
                if (line.startsWith('• ')) {
                  const text = line.slice(2);
                  return (
                    <div key={i} className="flex items-start gap-2">
                      <span className="text-primary mt-1 shrink-0 text-xs">•</span>
                      <p className="text-sm text-foreground leading-relaxed" dangerouslySetInnerHTML={{ __html: text.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>') }} />
                    </div>
                  );
                }
                return <p key={i} className="text-sm text-foreground leading-relaxed" dangerouslySetInnerHTML={{ __html: line.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>') }} />;
              })}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function SystemCard({ system }) {
  const [expanded, setExpanded] = useState(false);

  return (
    <div className={`rounded-2xl border ${system.color} overflow-hidden`}>
      <button
        onClick={() => setExpanded(o => !o)}
        className="w-full flex items-center gap-3 p-4 text-left hover:brightness-95 transition-all active:scale-[0.99]"
      >
        <div className="w-10 h-10 rounded-xl bg-card border border-border flex items-center justify-center shrink-0 text-xl">
          {system.emoji}
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            <span className={`text-xs font-bold uppercase tracking-wide ${system.headerColor}`}>System {system.number}</span>
          </div>
          <p className="font-bold text-sm text-foreground">{system.title}</p>
          <p className="text-[10px] text-muted-foreground mt-0.5">{system.sections.length} sections</p>
        </div>
        {expanded ? <ChevronUp className="w-4 h-4 text-muted-foreground shrink-0" /> : <ChevronDown className="w-4 h-4 text-muted-foreground shrink-0" />}
      </button>
      {expanded && (
        <div className="border-t border-border bg-background/60 px-3 py-3 space-y-2">
          {system.sections.map((section, i) => (
            <Section key={i} section={section} />
          ))}
        </div>
      )}
    </div>
  );
}

function ReferencesSection() {
  const [open, setOpen] = useState(false);
  return (
    <div className="rounded-2xl border border-border overflow-hidden mt-4">
      <button
        onClick={() => setOpen(o => !o)}
        className="w-full flex items-center justify-between px-4 py-3 bg-card text-left hover:bg-secondary/50 transition-colors"
      >
        <span className="text-sm font-semibold text-foreground">📚 References & Sources</span>
        {open ? <ChevronUp className="w-4 h-4 text-muted-foreground shrink-0" /> : <ChevronDown className="w-4 h-4 text-muted-foreground shrink-0" />}
      </button>
      {open && (
        <div className="px-4 py-3 border-t border-border bg-secondary/20 space-y-4">
          {references.map((ref, i) => (
            <div key={i}>
              <p className="text-xs font-bold text-muted-foreground uppercase tracking-wide mb-1">{ref.category}</p>
              <div className="space-y-1">
                {ref.items.map((item, j) => (
                  <p key={j} className="text-xs text-foreground/80 leading-relaxed">{item}</p>
                ))}
              </div>
            </div>
          ))}
          <p className="text-[10px] text-muted-foreground italic pt-2 border-t border-border">
            © CE HALO LLC — For educational use in SRNA board preparation. Clinical values and drug recommendations reflect general anesthesia practice guidelines. Always consult the most up-to-date primary references for clinical decision-making.
          </p>
        </div>
      )}
    </div>
  );
}

export default function NBCRNAAPReviewModule() {
  return (
    <div className="space-y-3">
      <div className="p-4 bg-gradient-to-br from-teal-50 to-teal-100/50 border border-teal-200 rounded-2xl">
        <p className="text-sm font-bold text-teal-800 mb-1">A&P Review for the NBCRNA Exam</p>
        <p className="text-xs text-teal-700 leading-relaxed">
          Systems-based review covering anatomy, physiology, key formulas, anesthesia implications, and high-yield pearls for the NCE. Each of the 6 systems follows a consistent 5-part structure.
        </p>
        <p className="text-[10px] text-teal-600 mt-2 font-medium">CE HALO LLC · SRNA Board Preparation</p>
      </div>

      <div className="grid grid-cols-2 gap-2 text-center">
        {systems.map(s => (
          <div key={s.id} className="flex items-center gap-2 px-3 py-2 bg-card border border-border rounded-xl">
            <span className="text-base">{s.emoji}</span>
            <span className="text-xs font-medium text-foreground truncate">{s.title.split(' ')[0]}</span>
          </div>
        ))}
      </div>

      <div className="space-y-2">
        {systems.map(system => (
          <SystemCard key={system.id} system={system} />
        ))}
      </div>

      <ReferencesSection />
    </div>
  );
}