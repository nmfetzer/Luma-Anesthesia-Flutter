import { useState } from 'react';
import { ChevronDown, ChevronUp, X } from 'lucide-react';
import StarButton from '@/components/StarButton';

const MODULES = [
  {
    number: 11,
    title: 'Ketamine & Anesthesia',
    specialty: 'Anesthesia | Pharmacology',
    description: "A comprehensive review of ketamine's pharmacology, clinical uses, special populations, and emerging roles in multimodal analgesia and psychiatric treatment.",
    objectives: [
      'Explain NMDA antagonism and systemic effects of ketamine',
      'Apply clinical uses including induction, analgesia, and sedation',
      'Identify contraindications and safety considerations',
      "Discuss ketamine's role in psychiatric and chronic pain therapy",
      'Implement monitoring and management strategies for safe administration',
    ],
    color: 'bg-sky-50 border-sky-200',
    badge: 'bg-sky-100 text-sky-700',
    number_bg: 'bg-sky-600',
  },
  {
    number: 12,
    title: 'GLP-1 Receptor Agonists & Anesthesia',
    specialty: 'Anesthesia | Perioperative',
    description: 'Evidence-informed overview of GLP-1 receptor agonists (Ozempic, Mounjaro, etc.) and pramlintide in the perioperative setting — gastric emptying, aspiration risk, and 2026 guidance.',
    objectives: [
      'Explain perioperative relevance including delayed gastric emptying and aspiration risk',
      'Summarize current perioperative guidance for daily and weekly GLP-1 formulations',
      'Identify patient-specific high-risk features warranting additional precautions',
      'Apply evidence-informed strategies for pre-, intra-, and postoperative management',
      'Integrate a provider-focused decision framework for elective and urgent procedures',
    ],
    color: 'bg-emerald-50 border-emerald-200',
    badge: 'bg-emerald-100 text-emerald-700',
    number_bg: 'bg-emerald-600',
  },
  {
    number: 13,
    title: 'Benzodiazepines & Anesthesia',
    specialty: 'Anesthesia | Pharmacology',
    description: 'Practical overview of benzodiazepines in perioperative care — pharmacology, dosing, reversal with flumazenil, delirium risk, withdrawal, and special populations including remimazolam.',
    objectives: [
      'Explain GABA-A pharmacology and clinical properties of perioperative benzodiazepines',
      'Differentiate midazolam, diazepam, lorazepam, and remimazolam',
      'Identify appropriate uses for anxiolysis, amnesia, procedural sedation, and ICU care',
      'Recognize populations at risk for oversedation, delirium, and withdrawal',
      'Apply strategies for safe dosing, monitoring, and reversal',
    ],
    color: 'bg-violet-50 border-violet-200',
    badge: 'bg-violet-100 text-violet-700',
    number_bg: 'bg-violet-600',
  },
  {
    number: 14,
    title: 'Neuromuscular Blocking Agents & Sugammadex',
    specialty: 'Anesthesia | Pharmacology',
    description: 'Evidence-based overview of NMBAs, quantitative monitoring, reversal strategies with neostigmine and sugammadex, residual weakness prevention, and anaphylaxis management.',
    objectives: [
      'Classify NMBAs as depolarizing or nondepolarizing; distinguish aminosteroid from benzylisoquinolinium agents',
      'Compare succinylcholine, rocuronium, vecuronium, cisatracurium, and atracurium',
      'Explain quantitative neuromuscular monitoring and residual weakness prevention',
      'Differentiate reversal with neostigmine/glycopyrrolate vs. sugammadex',
      'Apply clinical decision-making for agent selection, monitoring, reversal, and NMBA anaphylaxis',
    ],
    color: 'bg-orange-50 border-orange-200',
    badge: 'bg-orange-100 text-orange-700',
    number_bg: 'bg-orange-600',
  },
  {
    number: 15,
    title: 'Tranexamic Acid (TXA)',
    specialty: 'Anesthesia | Blood Management',
    description: 'Evidence-informed overview of TXA in perioperative blood management — trauma, obstetrics, orthopedics, cardiac surgery, renal dosing, seizure risk, and wrong-route safety.',
    objectives: [
      'Describe TXA mechanism of action, pharmacokinetics, and pharmacodynamics',
      'Identify high-value perioperative uses in trauma, obstetrics, orthopedics, and cardiac surgery',
      'Apply practical dosing strategies including renal dose adjustments',
      'Recognize adverse effects, contraindications, and seizure risk',
      'Integrate TXA into blood management practice with emphasis on neuraxial route safety',
    ],
    color: 'bg-red-50 border-red-200',
    badge: 'bg-red-100 text-red-700',
    number_bg: 'bg-red-600',
  },
  {
    number: 16,
    title: 'IV Contrast Media & Surgical Dyes',
    specialty: 'Anesthesia | Perioperative',
    description: 'Practical overview of iodinated contrast, gadolinium, ICG, fluorescein, and methylene blue in the OR — acute reactions, kidney risk, methylene blue serotonin toxicity, and G6PD interactions.',
    objectives: [
      'Differentiate major contrast agents and operative dyes relevant to perioperative care',
      'Explain OR uses in vascular, biliary, urologic, neurologic, and minimally invasive procedures',
      'Recognize acute hypersensitivity, physiologic reactions, and organ-specific toxicities',
      'Apply current guidance on contrast-associated AKI risk and metformin management',
      'Integrate preparation, monitoring, and emergency response principles',
    ],
    color: 'bg-cyan-50 border-cyan-200',
    badge: 'bg-cyan-100 text-cyan-700',
    number_bg: 'bg-cyan-600',
  },
  {
    number: 17,
    title: 'Cannabis Use & Anesthesia',
    specialty: 'Anesthesia | Perioperative',
    description: 'How cannabis affects perioperative care — THC/CBD pharmacology, airway and hemodynamic implications, intoxication screening, abstinence counseling, cannabis hyperemesis syndrome, and consent capacity.',
    objectives: [
      'Describe current cannabis use trends and their impact on the perioperative population',
      'Explain pharmacology of THC, CBD, and common routes of administration',
      'Identify preoperative, intraoperative, and postoperative implications of acute and chronic use',
      'Apply guidance on screening, postponing elective surgery, and abstinence counseling',
      'Integrate cannabis-specific risk assessment including airway, hemodynamics, and recovery',
    ],
    color: 'bg-green-50 border-green-200',
    badge: 'bg-green-100 text-green-700',
    number_bg: 'bg-green-600',
  },
  {
    number: 18,
    title: 'Illicit Drug Use & Anesthesia',
    specialty: 'Anesthesia | Perioperative',
    description: 'Perioperative implications of illicit drugs — cocaine, methamphetamine, illicit fentanyl, xylazine, nitazenes, MDMA, PCP, GHB, polysubstance exposure, withdrawal syndromes, and modern drug supply risks.',
    objectives: [
      'Describe the evolving illicit drug supply including fentanyl, xylazine, and nitazenes',
      'Differentiate stimulants, illicit opioids, dissociatives, hallucinogens, and sedative adulterants',
      'Recognize preoperative, intraoperative, and postoperative implications of acute and chronic use',
      'Apply practical screening, physiologic stabilization, and pain planning strategies',
      'Integrate risk mitigation strategies for polysubstance exposure and withdrawal syndromes',
    ],
    color: 'bg-slate-50 border-slate-200',
    badge: 'bg-slate-100 text-slate-700',
    number_bg: 'bg-slate-600',
  },
  {
    number: 19,
    title: 'Volatile Anesthetics',
    specialty: 'Anesthesia | Pharmacology',
    description: 'Core pharmacology of inhaled anesthetics — MAC, solubility, uptake; comparison of sevoflurane, desflurane, isoflurane, and nitrous oxide; malignant hyperthermia, PONV, emergence, and environmental impact.',
    objectives: [
      'Explain MAC, blood-gas solubility, uptake, distribution, and elimination',
      'Compare sevoflurane, desflurane, isoflurane, and nitrous oxide',
      'Recognize cardiovascular, respiratory, neurologic, and postoperative implications',
      'Identify high-yield safety concerns including MH, PONV, and closed-space gas expansion',
      'Apply clinical decision-making for volatile selection, titration, and emergence',
    ],
    color: 'bg-indigo-50 border-indigo-200',
    badge: 'bg-indigo-100 text-indigo-700',
    number_bg: 'bg-indigo-600',
  },
  {
    number: 25,
    title: 'Serotonin Syndrome',
    specialty: 'Anesthesia | Patient Safety',
    description: 'A comprehensive review of serotonin syndrome pathophysiology, high-risk drug combinations including opioid-antidepressant interactions, clinical triad recognition, Hunter criteria application, and severity-based management with supportive care and cyproheptadine evidence.',
    objectives: [
      'Define serotonin syndrome and explain its relevance in anesthesia practice',
      'Describe pathophysiology of serotonin excess and major receptor mechanisms',
      'Identify high-risk drug combinations and perioperative triggers including opioid-antidepressant combinations',
      'Recognize the clinical triad: mental status changes, autonomic instability, neuromuscular hyperactivity with emphasis on clonus and hyperreflexia',
      'Apply Hunter Serotonin Toxicity Criteria and differentiate from MH, NMS, anticholinergic toxicity',
      'Outline severity-based management for mild, moderate, and severe serotonin syndrome',
      'Evaluate evidence for cyproheptadine and integrate perioperative prevention strategies',
    ],
    color: 'bg-yellow-50 border-yellow-200',
    badge: 'bg-yellow-100 text-yellow-700',
    number_bg: 'bg-yellow-600',
  },
  {
    number: 26,
    title: 'OR Fire Safety & Prevention',
    specialty: 'Anesthesia | Patient Safety',
    description: 'Evidence-informed review of surgical fire prevention covering the fire triad, high-risk procedures, flammable liquids and prep solutions including ChloraPrep/DuraPrep drying times, oxygen management, time-out fire assessment, emergency response algorithms, RACE and PASS mnemonics, and post-event management per Joint Commission Sentinel Event Alert 68 (2024).',
    objectives: [
      'Describe the surgical fire triad: oxidizer, ignition source, and fuel',
      'Identify patient, procedure, and environmental factors increasing OR fire risk',
      'Recognize flammable liquids and skin prep solutions with key drying-time considerations',
      'Apply evidence-based prevention strategies for oxygen management, ignition sources, draping, and skin prep',
      'Explain the anesthesia provider role in fire risk assessment during time-out, team communication, and emergency response',
      'Outline immediate response to surgical fire (6-step algorithm) and post-event management steps',
    ],
    color: 'bg-orange-50 border-orange-200',
    badge: 'bg-orange-100 text-orange-700',
    number_bg: 'bg-orange-500',
  },
  {
    number: 27,
    title: 'Negative Pressure Pulmonary Edema (NPPE)',
    specialty: 'Anesthesia | Airway',
    description: 'A focused review of NPPE (post-obstructive pulmonary edema) covering pathophysiology via Müller maneuver mechanism, Type I vs Type II patterns, laryngospasm treatment algorithm with succinylcholine dosing, positive pressure support, selective diuresis guidance, pediatric considerations, and prevention during emergence and extubation.',
    objectives: [
      'Define NPPE and distinguish from cardiogenic pulmonary edema and other causes of postoperative hypoxemia',
      'Explain pathophysiologic mechanisms after upper airway obstruction',
      'Identify common perioperative risk factors, triggers, and clinical findings',
      'Describe evidence-based treatment priorities: airway relief, oxygenation, positive-pressure ventilation, and escalation',
      'Apply prevention strategies during emergence and extubation to reduce NPPE risk',
    ],
    color: 'bg-sky-50 border-sky-200',
    badge: 'bg-sky-100 text-sky-700',
    number_bg: 'bg-sky-500',
  },
  {
    number: 28,
    title: 'Amniotic Fluid Embolism (AFE)',
    specialty: 'Anesthesia | Obstetric',
    description: 'Comprehensive obstetric emergency module covering AFE pathophysiology cascade, Phase 1 and Phase 2 clinical presentations, DIC management with fibrinogen replacement priority, differential diagnosis from peripartum collapse mimics, immediate management with pregnancy-modified CPR, advanced management including ECMO indications, AFE Registry participation, and post-event debriefing.',
    objectives: [
      'Define AFE and describe epidemiology, timing, and diagnostic uncertainty',
      'Explain AFE pathophysiology including pulmonary vascular collapse, ventricular dysfunction, inflammatory activation, and hemostatic failure',
      'Differentiate Phase 1 (cardiopulmonary collapse) and Phase 2 (DIC, hemorrhage) presentations',
      'Apply DIC management including massive transfusion activation, fibrinogen replacement, viscoelastic testing, calcium monitoring',
      'Prioritize immediate actions: airway support, pregnancy-modified CPR with manual uterine displacement, hemodynamic support, delivery planning',
      'Differentiate AFE from other peripartum collapse causes including high spinal, LAST, anaphylaxis, PE, eclampsia',
    ],
    color: 'bg-rose-50 border-rose-200',
    badge: 'bg-rose-100 text-rose-700',
    number_bg: 'bg-rose-600',
  },
  {
    number: 111,
    title: 'Perioperative Antihypertensives',
    specialty: 'Anesthesia | Hemodynamics',
    description: 'From core blood-pressure principles to practical agent selection — covering why perioperative hypertension matters, major IV antihypertensives (labetalol, esmolol, clevidipine, nicardipine, nitroglycerin, nitroprusside, phentolamine), dosing patterns, agent selection by clinical scenario, tight BP control in TCAR/aortic/free-flap surgery, chronic medication management, and avoidance of overshoot hypotension.',
    objectives: [
      'Explain major causes and perioperative implications of acute hypertension in the OR, PACU, and procedural settings',
      'Differentiate commonly used IV antihypertensives including beta-blockers, calcium channel blockers, vasodilators, nitrates, and alpha-blockers',
      'Apply practical adult dosing patterns for IV antihypertensives used in anesthesia care',
      'Select the best antihypertensive agent based on heart rate, cardiac function, cause of hypertension, end-organ considerations, and procedural context',
      'Integrate clinical reasoning to correct causes of hypertension while using short-acting, titratable agents appropriately',
    ],
    color: 'bg-blue-50 border-blue-200',
    badge: 'bg-blue-100 text-blue-700',
    number_bg: 'bg-blue-600',
  },
  {
    number: 112,
    title: 'Hemodynamic Agents & Vasopressors',
    specialty: 'Anesthesia | Hemodynamics',
    description: 'A practical review of vasopressors, inotropes, and hemodynamically active agents used in anesthesia — including phenylephrine, norepinephrine, epinephrine, vasopressin, angiotensin II (Giapreza), dopamine, dobutamine, milrinone, methylene blue, and inhaled agents — with mechanism, clinical indications, infusion dosing, and selection framework.',
    objectives: [
      'Classify vasopressors and inotropes by receptor mechanism and primary hemodynamic effect',
      'Differentiate vasoplegic shock, cardiogenic shock, and distributive shock patterns and select appropriate vasoactive therapy',
      'Apply infusion dosing and titration strategies for common perioperative vasopressors and inotropes',
      'Identify unique considerations for angiotensin II, methylene blue, and newer vasoactive agents',
      'Integrate monitoring parameters and clinical endpoints to guide vasoactive drug adjustments',
    ],
    color: 'bg-red-50 border-red-200',
    badge: 'bg-red-100 text-red-700',
    number_bg: 'bg-red-500',
  },
  {
    number: 113,
    title: 'Airway & Pulmonary Pharmacology',
    specialty: 'Anesthesia | Airway',
    description: 'Covers pharmacologic management of perioperative airway and pulmonary conditions — bronchodilators, inhaled agents, epoprostenol (Flolan), inhaled nitric oxide, sotatercept, pulmonary vasodilators, and management of bronchospasm, reactive airway disease, and pulmonary hypertension in the anesthesia setting.',
    objectives: [
      'Identify mechanisms and clinical use of bronchodilators used perioperatively',
      'Explain inhaled prostacyclin therapy (Flolan/epoprostenol) including dosing, concentration calculations, and delivery systems',
      'Describe inhaled nitric oxide and newer pulmonary agents including sotatercept',
      'Apply a stepwise management approach to intraoperative bronchospasm',
      'Integrate pulmonary pharmacology into anesthetic planning for patients with reactive airway disease or pulmonary hypertension',
    ],
    color: 'bg-cyan-50 border-cyan-200',
    badge: 'bg-cyan-100 text-cyan-700',
    number_bg: 'bg-cyan-600',
  },
  {
    number: 114,
    title: 'Antiemetics & PONV Management',
    specialty: 'Anesthesia | Perioperative',
    description: 'Evidence-based review of postoperative nausea and vomiting — Apfel risk stratification, mechanism-based antiemetic pharmacology (5-HT3 antagonists, NK1 antagonists, dopamine antagonists, corticosteroids, amisulpride, scopolamine), multimodal prophylaxis protocols, rescue strategies, and ERAS integration.',
    objectives: [
      'Calculate Apfel Simplified PONV Risk Score and stratify prophylaxis recommendations',
      'Explain mechanisms of action of major antiemetic drug classes including 5-HT3, NK1, dopamine antagonists, and corticosteroids',
      'Differentiate first-line and rescue antiemetic strategies by drug class and timing',
      'Identify amisulpride as a newer IV antiemetic agent and its clinical application',
      'Apply multimodal PONV prophylaxis within an ERAS framework including anesthetic technique modifications',
    ],
    color: 'bg-emerald-50 border-emerald-200',
    badge: 'bg-emerald-100 text-emerald-700',
    number_bg: 'bg-emerald-600',
  },
  {
    number: 115,
    title: 'Perioperative Antibiotics & Anaphylaxis',
    specialty: 'Anesthesia | Patient Safety',
    description: 'Practical guide to surgical antibiotic prophylaxis — cefazolin dosing, beta-lactam allergy assessment, alternative agents, timing and redosing principles — combined with a comprehensive intraoperative anaphylaxis module covering recognition, grading, immediate treatment with IV epinephrine, tryptase sampling, and post-event management.',
    objectives: [
      'Select appropriate surgical antibiotic prophylaxis and dosing based on procedure type and patient weight',
      'Apply beta-lactam allergy risk stratification to guide antibiotic selection',
      'Identify timing, redosing, and duration principles for perioperative antibiotic prophylaxis',
      'Recognize intraoperative anaphylaxis by clinical grade and distinguish from other perioperative emergencies',
      'Initiate immediate IV epinephrine-based anaphylaxis treatment and coordinate post-event tryptase sampling and follow-up',
    ],
    color: 'bg-amber-50 border-amber-200',
    badge: 'bg-amber-100 text-amber-700',
    number_bg: 'bg-amber-600',
  },
  {
    number: 116,
    title: 'Reversal, Rescue & Emergency Medications',
    specialty: 'Anesthesia | Emergency',
    description: 'High-yield review of emergency pharmacology in anesthesia — dantrolene for MH, lipid emulsion (Intralipid) for LAST, sugammadex dosing, anticholinesterases, flumazenil, naloxone, cyanide antidotes (hydroxocobalamin, sodium thiosulfate), calcium, sodium bicarbonate, and other rescue agents with focused indications and dosing.',
    objectives: [
      'Explain dantrolene mechanism and dosing for malignant hyperthermia including reconstitution and repeat dosing',
      'Apply lipid emulsion therapy (Intralipid 20%) for local anesthetic systemic toxicity including bolus and infusion dosing',
      'Differentiate sugammadex dosing by depth of rocuronium/vecuronium blockade (2 mg/kg, 4 mg/kg, 16 mg/kg)',
      'Identify rescue medications for cyanide toxicity, methemoglobinemia, hyperkalemia, and severe metabolic acidosis',
      'Integrate emergency drug knowledge into rapid response protocols for perioperative crises',
    ],
    color: 'bg-rose-50 border-rose-200',
    badge: 'bg-rose-100 text-rose-700',
    number_bg: 'bg-rose-700',
  },
  {
    number: 21,
    badge_label: 'Course 21',
    title: 'Brain Death, Organ Procurement & the Anesthesia Provider',
    specialty: 'Anesthesia | Advanced',
    description: 'Comprehensive module on brain death determination (BD/DNC), physiologic changes in the brain-dead donor, donation after brain death (DBD) vs. donation after circulatory death (DCD), normothermic regional perfusion (NRP), donor management goals, intraoperative role in procurement cases, ethical considerations, and post-procurement debriefing.',
    objectives: [
      'Define brain death and describe the clinical criteria and confirmatory testing requirements',
      'Explain physiologic changes in the brain-dead organ donor and their anesthetic implications',
      'Differentiate DBD and DCD pathways and describe the anesthesia provider role in each',
      'Apply donor management goals including hemodynamic targets, hormonal resuscitation, and lung protective ventilation',
      'Describe normothermic regional perfusion (NRP) and its impact on organ viability',
      'Discuss ethical considerations and emotional support for the care team in procurement cases',
    ],
    color: 'bg-slate-50 border-slate-300',
    badge: 'bg-slate-200 text-slate-700',
    number_bg: 'bg-slate-700',
  },
  {
    number: null,
    title: 'Airway Management & Sedation in Dentistry',
    specialty: 'Dental Anesthesia',
    badge_label: 'Dental Module',
    description: 'Module for dental professionals covering sedation continuum, patient assessment with updated ASA classification and fasting guidelines (ADA 2026), airway assessment using LEMON and Modified Mallampati, pharmacology of dental sedation agents, monitoring requirements by sedation level, airway management techniques (BVM, OPA/NPA), emergency protocols for laryngospasm, bronchospasm, and anaphylaxis, documentation requirements, and discharge criteria using Modified Aldrete Score.',
    objectives: [
      'Differentiate the four levels of sedation/anesthesia',
      'Perform systematic pre-sedation assessment with updated 2026 ADA vital signs (including BMI)',
      'Conduct LEMON airway assessment and Modified Mallampati classification',
      'Explain pharmacodynamics of dental sedation agents and reversal medications',
      'Apply monitoring standards per ADA 2026 for each sedation level',
      'Demonstrate airway management techniques including BVM ventilation',
      'Recognize and initiate management of sedation complications',
      'Maintain legally compliant sedation records and apply appropriate discharge criteria',
    ],
    color: 'bg-teal-50 border-teal-200',
    badge: 'bg-teal-100 text-teal-700',
    number_bg: 'bg-teal-600',
  },
];

function ModuleModal({ module, onClose }) {
  const badgeLabel = module.badge_label || (module.number ? `M${module.number}` : '★');
  return (
    <div className="fixed inset-0 z-50 flex items-end md:items-center justify-center bg-black/50 backdrop-blur-sm" onClick={onClose}>
      <div
        className={`w-full max-w-[600px] mx-auto max-h-[90vh] overflow-y-auto rounded-t-3xl md:rounded-3xl border-2 ${module.color} bg-card`}
        onClick={e => e.stopPropagation()}
      >
        {/* Handle */}
        <div className="flex justify-center pt-3 pb-1">
          <div className="w-10 h-1 rounded-full bg-border" />
        </div>

        <div className="px-5 pb-8 pt-2">
          {/* Header */}
          <div className="flex items-start gap-3 mb-4">
            <div className={`${module.number_bg} text-white text-xs font-bold px-2.5 py-1 rounded-lg shrink-0 mt-0.5`}>
              {badgeLabel}
            </div>
            <div className="flex-1 min-w-0">
              <p className="font-bold text-base text-foreground leading-[1.35]">{module.title}</p>
              <span className={`inline-block mt-1.5 text-xs font-semibold px-2 py-0.5 rounded-full ${module.badge}`}>
                {module.specialty}
              </span>
            </div>
            <button onClick={onClose} aria-label="Close" className="p-3 min-w-[44px] min-h-[44px] rounded-full hover:bg-secondary transition-colors shrink-0 flex items-center justify-center">
              <X className="w-4 h-4 text-muted-foreground" />
            </button>
          </div>

          {/* Description */}
          <p className="text-sm text-muted-foreground leading-relaxed mb-5">{module.description}</p>

          {/* Learning Objectives */}
          <p className="text-xs font-bold text-muted-foreground uppercase tracking-wide mb-3">Learning Objectives</p>
          <ul className="space-y-2.5">
            {module.objectives.map((obj, i) => (
              <li key={i} className="flex items-start gap-2.5 text-sm text-foreground leading-relaxed">
                <span className={`text-xs font-bold mt-0.5 shrink-0 px-1.5 py-0.5 rounded text-white ${module.number_bg}`}>{i + 1}</span>
                <span>{obj}</span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
}

function FeaturedCard({ emoji, badge, title, specialty, description, cta }) {
  return (
    <div className="rounded-2xl border-2 border-purple-300 bg-gradient-to-br from-purple-50 to-indigo-50 overflow-hidden">
      <div className="p-4">
        <div className="flex items-start gap-3 mb-3">
          <div className="text-2xl shrink-0">{emoji}</div>
          <div className="flex-1 min-w-0">
            <span className="inline-block text-xs font-bold bg-purple-200 text-purple-800 px-2 py-0.5 rounded-full mb-1">{badge}</span>
            <p className="font-bold text-sm text-foreground leading-[1.35]">{title}</p>
            <span className="inline-block mt-1 text-xs font-semibold bg-purple-100 text-purple-700 px-2 py-0.5 rounded-full">{specialty}</span>
          </div>
        </div>
        <p className="text-xs text-muted-foreground leading-relaxed mb-4">{description}</p>
        <button className="w-full py-2.5 rounded-xl text-xs font-bold text-white bg-purple-600 hover:opacity-90 active:scale-[0.98] transition-all">
          {cta}
        </button>
      </div>
    </div>
  );
}

function CEModuleCard({ module }) {
  const [open, setOpen] = useState(false);
  const badgeLabel = module.badge_label || (module.number ? `M${module.number}` : '★');

  return (
    <>
      <div
        className={`rounded-2xl border-2 ${module.color} overflow-hidden cursor-pointer active:scale-[0.98] transition-transform`}
        onClick={() => setOpen(true)}
      >
        <div className="p-4">
          {/* Header */}
          <div className="flex items-start gap-3 mb-2">
            <div className={`${module.number_bg} text-white text-xs font-bold px-2.5 py-1 rounded-lg shrink-0`}>
              {badgeLabel}
            </div>
            <div className="flex-1 min-w-0">
              <p className="font-bold text-sm text-foreground leading-[1.35]">{module.title}</p>
              <span className={`inline-block mt-1 text-xs font-semibold px-2 py-0.5 rounded-full ${module.badge}`}>
                {module.specialty}
              </span>
            </div>
            <StarButton
              item={{ id: `module-${module.number ?? module.title}`, type: 'module', name: module.title, category: module.specialty }}
              onClick={e => e.stopPropagation()}
            />
          </div>

          {/* Description preview */}
          <p className="text-xs text-muted-foreground leading-relaxed line-clamp-2 mb-3">{module.description}</p>

          {/* Tap hint */}
          <div className={`flex items-center gap-1 text-xs font-semibold ${module.number_bg.replace('bg-', 'text-')}`}>
            <ChevronDown className="w-3.5 h-3.5" />
            View {module.objectives?.length || 0} Learning Objectives
          </div>
        </div>
      </div>

      {open && <ModuleModal module={module} onClose={() => setOpen(false)} />}
    </>
  );
}

export default function CEModules() {
  return (
    <div className="space-y-4">
      {/* NBCRNA NCE Board Prep Section Header */}
      <div className="flex items-center gap-2 pt-1">
        <div className="flex-1 h-px bg-gradient-to-r from-purple-200 to-transparent" />
        <span className="text-xs font-bold uppercase tracking-widest text-purple-600 px-2">📚 NBCRNA NCE Board Prep</span>
        <div className="flex-1 h-px bg-gradient-to-l from-purple-200 to-transparent" />
      </div>

      <FeaturedCard
        emoji="📖"
        badge="Full 4-Domain Study Guide | 2026"
        title="NBCRNA NCE Comprehensive Review Course"
        specialty="Board Prep"
        description="A comprehensive 25-page review guide aligned to the 2024-2026 NBCRNA NCE Content Outline covering all four exam domains. Includes high-yield tables, clinical pearls, pharmacology summaries for all 31 drug classes, equipment troubleshooting, surgical & special population considerations, quick-reference lab values, MUDPILES, cardiac dysrhythmia management, and a final board day checklist."
        cta="Start Study Guide"
      />

      <FeaturedCard
        emoji="📝"
        badge="100 Questions | Full Answer Key with Rationales"
        title="NBCRNA NCE Practice Test — Set 2"
        specialty="Board Prep"
        description="Second 100-question board-style practice test aligned to the 2024-2026 NBCRNA NCE Content Outline, proportionally distributed across all four domains. Includes detailed annotated rationales explaining correct AND incorrect answers for all 100 questions."
        cta="Start Practice Test"
      />

      <FeaturedCard
        emoji="📝"
        badge="100 Questions"
        title="NBCRNA NCE Practice Test — Set 1"
        specialty="Board Prep"
        description="100 board-style questions aligned to the NBCRNA NCE Content Outline covering all 4 domains: Basic Sciences (20%), Equipment & Technology (20%), General Principles of Anesthesia (35%), and Anesthesia for Surgical Procedures & Special Populations (25%). Includes detailed annotated answer rationales for every question."
        cta="Start Practice Test"
      />

      <FeaturedCard
        emoji="🔬"
        badge="NBCRNA NCE Board Review | 12 Sections"
        title="Anesthesia Equipment Review"
        specialty="Board Prep | Equipment"
        description="Comprehensive 12-section equipment review covering: Medical Gas Supply Systems, Anesthesia Machine, Breathing Circuits & CO₂ Absorption, Laryngoscopes & Video Laryngoscopy, Flexible Bronchoscopy & AFOI, Endotracheal Tubes, Supraglottic Airways, Airway Adjuncts, Ventilators & Modes, Monitors & Safety Systems, Regional Anesthesia Equipment, and Vascular Access & Infusion Equipment."
        cta="View Module"
      />

      <div className="flex items-center justify-between pt-1">
        <p className="text-xs font-bold text-muted-foreground uppercase tracking-widest">Modules</p>
        <span className="text-xs bg-purple-100 text-purple-700 font-semibold px-2 py-0.5 rounded-full">{MODULES.length} modules</span>
      </div>
      {MODULES.map((mod) => <CEModuleCard key={mod.number ?? mod.title} module={mod} />)}
    </div>
  );
}