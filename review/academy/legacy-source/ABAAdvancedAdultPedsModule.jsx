import { useState } from 'react';
import { ChevronDown, ChevronUp, ChevronLeft, ChevronRight, CheckCircle2, XCircle, RotateCcw } from 'lucide-react';

const KEY_POINT = ({ children }) => (
  <div className="my-3 p-3 rounded-lg bg-amber-50 border-l-4 border-amber-400 text-sm text-amber-900">
    <span className="font-bold">KEY POINT — </span>{children}
  </div>
);

const Section = ({ title, children, defaultOpen = false }) => {
  const [open, setOpen] = useState(defaultOpen);
  return (
    <div className="rounded-xl border border-border/60 overflow-hidden mb-3">
      <button onClick={() => setOpen(o => !o)} className="w-full flex items-center justify-between px-4 py-3 bg-secondary text-left">
        <span className="font-bold text-sm text-foreground">{title}</span>
        {open ? <ChevronUp className="w-4 h-4 text-muted-foreground shrink-0" /> : <ChevronDown className="w-4 h-4 text-muted-foreground shrink-0" />}
      </button>
      {open && <div className="px-4 py-3 text-sm text-foreground space-y-2 bg-background">{children}</div>}
    </div>
  );
};

const Table = ({ headers, rows }) => (
  <div className="overflow-x-auto my-2">
    <table className="w-full text-xs border-collapse">
      <thead>
        <tr className="bg-primary text-primary-foreground">
          {headers.map((h, i) => <th key={i} className="px-3 py-2 text-left font-semibold">{h}</th>)}
        </tr>
      </thead>
      <tbody>
        {rows.map((row, i) => (
          <tr key={i} className={i % 2 === 0 ? 'bg-background' : 'bg-secondary'}>
            {row.map((cell, j) => <td key={j} className="px-3 py-2 border-b border-border/30 text-foreground">{cell}</td>)}
          </tr>
        ))}
      </tbody>
    </table>
  </div>
);

const Bullet = ({ children }) => <p className="pl-3 border-l-2 border-slate-200 text-sm text-foreground">• {children}</p>;

const QUESTIONS = [
  { q: 'A 68-year-old man scheduled for elective open AAA repair walks two blocks but stops due to leg fatigue. ECG shows old anteroseptal Q-waves. Per 2014 ACC/AHA guideline, next best step:', options: ['Proceed without further testing', 'Order a dobutamine stress echocardiogram', 'Order coronary angiography', 'Cancel surgery and begin beta-blocker therapy'], answer: 1, rationale: 'Functional capacity is <4 METs (cannot climb stairs or walk briskly). Surgery is high-risk vascular. Stress testing is indicated only if results will change management. Coronary angiography is not first-line. Routine beta-blocker initiation just before surgery increases stroke risk (POISE).' },
  { q: 'A 4-year-old presents for elective adenotonsillectomy with a runny nose, clear secretions, no fever. Lungs are clear. Most appropriate management:', options: ['Cancel and reschedule in 6 weeks', 'Cancel and reschedule in 2 weeks', 'Proceed using LMA when feasible and have anticholinergic available', 'Proceed with awake fiberoptic intubation'], answer: 2, rationale: 'An uncomplicated URI without lower respiratory symptoms is not a reason to cancel. LMA reduces airway irritation versus ETT; humidified gases and atropine availability for laryngospasm/bradycardia are prudent.' },
  { q: 'Which volatile anesthetic is most likely to cause sympathetic stimulation with rapid increases in inspired concentration?', options: ['Sevoflurane', 'Isoflurane', 'Desflurane', 'Halothane'], answer: 2, rationale: "Desflurane's pungency triggers sympathetic surge with rapid increases above 1 MAC — tachycardia and hypertension. Slow titration or pretreatment with opioids mitigates this." },
  { q: 'A 25-year-old woman with MH-susceptibility is scheduled for laparoscopic appendectomy. Which agent must be avoided?', options: ['Propofol', 'Ketamine', 'Succinylcholine', 'Rocuronium'], answer: 2, rationale: 'Succinylcholine and all volatile halogenated agents are MH triggers. Propofol, ketamine, opioids, nitrous oxide, and non-depolarizing relaxants are safe.' },
  { q: 'A patient develops a TOF ratio of 0.4 at the end of a 2-hour case after rocuronium 0.6 mg/kg. Most appropriate reversal:', options: ['Neostigmine 0.07 mg/kg + glycopyrrolate', 'Sugammadex 2 mg/kg', 'Sugammadex 4 mg/kg', 'Sugammadex 16 mg/kg'], answer: 1, rationale: 'Sugammadex 2 mg/kg reverses moderate block (TOF count ≥2). 4 mg/kg is for deep block (post-tetanic count 1–2, no TOF). 16 mg/kg is immediate rescue after 1.2 mg/kg dose.' },
  { q: 'Propofol infusion syndrome is most strongly associated with:', options: ['Bolus dosing >2 mg/kg', 'Infusions >4 mg/kg/h for >48 h', 'Concurrent benzodiazepine use', 'Use in obese adults'], answer: 1, rationale: 'PRIS — metabolic acidosis, rhabdomyolysis, hyperkalemia, cardiac failure — occurs with high-dose prolonged infusions, particularly in critically ill and pediatric patients receiving catecholamines and steroids.' },
  { q: 'The narrowest functional portion of the pediatric airway, based on MRI data, is:', options: ['The cricoid ring', 'The glottic opening', 'The subglottic trachea', 'The vallecula'], answer: 1, rationale: 'Older anatomic studies on cadavers indicated cricoid; in-vivo MRI data show the glottis is the narrowest functional portion. This supports routine use of cuffed ETTs in children.' },
  { q: 'A neonate becomes hypotensive after induction. The most likely cause:', options: ['Decreased preload from volatile anesthesia', 'Bradycardia from inadequate ventilation', 'Hypovolemia from prolonged NPO', 'Pneumothorax'], answer: 1, rationale: 'Neonatal CO is rate-dependent due to a non-compliant ventricle. Bradycardia (most often from hypoxia) is the leading cause of hypotension — ventilate, oxygenate, and consider atropine if persistent.' },
  { q: 'Which finding is the strongest single predictor of difficult mask ventilation?', options: ['Mallampati IV', 'Presence of a beard', 'Thyromental distance <6 cm', 'History of OSA'], answer: 1, rationale: 'MOANS — beard impairs mask seal and is among the strongest predictors. Other predictors include obesity/obstruction, age >55, no teeth, and stiff lungs. Mallampati predicts intubation difficulty, not mask ventilation.' },
  { q: 'Updated ASA NPO guidance (2017, 2023) allows clear liquids until how long before elective surgery?', options: ['8 hours', '6 hours', '4 hours', '2 hours'], answer: 3, rationale: 'Clear liquids 2 hours, breast milk 4 hours, formula/non-human milk 6 hours, light meal 6 hours, fatty meal 8 hours. The 2023 update explicitly permits carbohydrate clear drinks within 2 hours.' },
  { q: 'Which agent is the most appropriate induction for a hemodynamically unstable septic patient requiring emergent intubation?', options: ['Propofol 2 mg/kg', 'Etomidate 0.3 mg/kg', 'Ketamine 1–2 mg/kg', 'Midazolam 0.1 mg/kg'], answer: 2, rationale: 'Ketamine preserves sympathetic tone in sepsis. Etomidate is hemodynamically stable but causes adrenocortical suppression even after a single dose, controversial in septic patients. Propofol causes profound hypotension.' },
  { q: 'MAC of sevoflurane is decreased by all EXCEPT:', options: ['Pregnancy', 'Hypothermia', 'Chronic alcohol use', 'Lithium'], answer: 2, rationale: 'Chronic alcohol use INCREASES MAC due to cross-tolerance. Acute intoxication decreases MAC. Pregnancy, hypothermia, opioids, α2-agonists, and lithium all decrease MAC.' },
  { q: 'Which opioid is contraindicated in renal failure due to seizure risk from its metabolite?', options: ['Morphine', 'Hydromorphone', 'Meperidine', 'Fentanyl'], answer: 2, rationale: "Meperidine's metabolite normeperidine accumulates in renal failure and lowers seizure threshold. Morphine-6-glucuronide also accumulates but causes sedation/respiratory depression rather than seizures." },
  { q: 'Sevoflurane reacts with desiccated CO₂ absorbent (especially barium hydroxide lime) to produce:', options: ['Carbon monoxide', 'Compound A', 'Halothane hepatitis precursor', 'Methanol'], answer: 1, rationale: 'Compound A is a vinyl ether formed when sevoflurane contacts strong bases; nephrotoxic in rats. Maintain fresh gas flows ≥1 L/min and avoid desiccated absorbent. CO is produced by desflurane/isoflurane with desiccated absorbent.' },
  { q: 'The most reliable indicator of correct endotracheal tube placement after intubation is:', options: ['Bilateral breath sounds', 'Chest rise', 'Sustained capnography waveform over several breaths', 'Absence of gastric sounds'], answer: 2, rationale: 'Sustained end-tidal CO₂ is the gold standard. A brief positive ETCO₂ can occur with esophageal intubation if carbonated beverages were ingested, so sustained waveform is essential.' },
  { q: 'A 6-month-old develops stridor and saturation drop after extubation following adenoidectomy. Initial management:', options: ['Reintubation', 'Racemic epinephrine and humidified O₂', 'IV dexamethasone alone', 'Heliox'], answer: 1, rationale: 'Post-extubation stridor most likely reflects subglottic edema. Nebulized racemic epinephrine reduces edema; dexamethasone 0.5 mg/kg helps but onset is delayed. Reintubate only if airway obstruction is severe and refractory.' },
  { q: 'Apnea risk after general anesthesia is highest in:', options: ['Term neonates <44 weeks PCA', 'Former premature infants <60 weeks PCA', 'All children <2 years', 'Toddlers with reactive airway disease'], answer: 1, rationale: 'Former preterm infants are at highest risk until ~60 weeks post-conceptual age. Anemia (Hct <30%) further increases risk. Admit for apnea monitoring after any anesthetic in this group.' },
  { q: 'Best initial management of intraoperative laryngospasm under sevoflurane mask anesthesia:', options: ['Succinylcholine 1 mg/kg IM', 'Jaw thrust and positive pressure with 100% O₂', 'Spray local anesthetic on cords', 'Tracheostomy'], answer: 1, rationale: "Larson's maneuver (jaw thrust, CPAP 100% O₂) is first-line. If unresolved, deepen anesthesia with propofol or give succinylcholine. Atropine prevents reflex bradycardia." },
  { q: 'Maintenance IV fluid rate for a 25-kg child per the 4-2-1 rule:', options: ['45 mL/h', '55 mL/h', '65 mL/h', '85 mL/h'], answer: 2, rationale: 'First 10 kg × 4 = 40 mL/h; next 10 kg × 2 = 20 mL/h; remaining 5 kg × 1 = 5 mL/h. Total = 65 mL/h.' },
  { q: 'A patient awakens during a TIVA case using propofol and remifentanil without volatile agent. Which monitor would most reliably have detected light anesthesia?', options: ['End-tidal volatile concentration', 'Processed EEG (BIS)', 'Train-of-four', 'Pulse oximetry'], answer: 1, rationale: 'Without volatile end-tidal monitoring, processed EEG is the most reliable awareness preventive in TIVA. BIS target 40–60.' },
  { q: 'A 70-kg adult is given succinylcholine 100 mg for RSI. Apnea persists for 4 hours. The most likely cause:', options: ['Phase II block from repeat dosing', 'Pseudocholinesterase deficiency', 'Malignant hyperthermia', 'Residual rocuronium'], answer: 1, rationale: 'Atypical or low-activity pseudocholinesterase prolongs succinylcholine effect. Dibucaine number identifies the variant. Supportive ventilation until block resolves.' },
  { q: 'Most appropriate intraoperative ventilation strategy for a 130-kg patient with BMI 48 undergoing laparoscopic surgery:', options: ['TV 6–8 mL/kg ideal body weight, PEEP 8–10, recruitment maneuvers', 'TV 10 mL/kg actual body weight, no PEEP', 'Pressure support only', 'High-frequency oscillation'], answer: 0, rationale: 'Lung-protective ventilation: 6–8 mL/kg IBW with moderate PEEP and periodic recruitment reduces atelectasis and pulmonary complications in obesity and laparoscopic surgery.' },
  { q: 'Which condition contraindicates use of nitrous oxide?', options: ['Asthma', 'Recent vitrectomy with intraocular SF6 gas', 'Hyperthyroidism', 'Aortic stenosis'], answer: 1, rationale: 'N₂O diffuses into closed gas spaces 30× faster than nitrogen exits, expanding intraocular gas bubbles and causing retinal ischemia. Avoid 3–6 weeks after vitrectomy. Also avoid in pneumothorax, bowel obstruction, middle-ear surgery.' },
  { q: 'Which postoperative complication is most strongly reduced by maintaining intraoperative normothermia?', options: ['Postoperative nausea and vomiting', 'Surgical site infection', 'Atelectasis', 'Postoperative delirium'], answer: 1, rationale: 'Kurz et al. demonstrated a 3-fold increase in SSI with mild hypothermia. Normothermia also reduces blood loss, coagulopathy, cardiac events, and prolonged recovery.' },
  { q: 'First-line treatment of malignant hyperthermia:', options: ['Cooling and bicarbonate alone', 'Dantrolene 2.5 mg/kg IV, repeated as needed', 'Calcium gluconate', 'Magnesium 2 g IV'], answer: 1, rationale: 'Dantrolene 2.5 mg/kg IV (up to 10 mg/kg) is definitive. Stop triggering agents, hyperventilate with 100% O₂, cool, treat hyperkalemia, acidosis, and arrhythmias. Continue dantrolene 1 mg/kg q6h for 24–48 h.' },
  { q: 'Why is etomidate avoided as an infusion in critically ill patients?', options: ['Increased risk of myoclonus', 'Inhibition of 11β-hydroxylase causing adrenal suppression', 'Cumulative cardiovascular depression', 'Renal toxicity'], answer: 1, rationale: 'Etomidate suppresses cortisol synthesis. Even a single dose causes measurable suppression for 6–24 hours; infusions in sepsis have been associated with increased mortality.' },
  { q: 'Risk factors for PONV (Apfel score) include all EXCEPT:', options: ['Female sex', 'History of motion sickness or PONV', 'Smoker', 'Postoperative opioid use'], answer: 2, rationale: 'Smoking is PROTECTIVE against PONV. Apfel risk factors: female, nonsmoker, history of PONV/motion sickness, postoperative opioids. Each adds ~20% risk.' },
  { q: 'Which agent provides the most rapid offset regardless of duration of infusion?', options: ['Fentanyl', 'Sufentanil', 'Alfentanil', 'Remifentanil'], answer: 3, rationale: 'Remifentanil is metabolized by nonspecific plasma esterases with a context-sensitive half-time of ~3–4 minutes regardless of infusion duration — unique among opioids.' },
  { q: 'Best initial test to evaluate a new murmur during preoperative evaluation for hip replacement:', options: ['Coronary angiography', 'Transthoracic echocardiogram', 'Cardiac MRI', 'Stress nuclear scan'], answer: 1, rationale: 'TTE characterizes valve lesion, chamber size, and ventricular function. It may identify previously unsuspected severe valvular disease — particularly aortic stenosis.' },
  { q: 'A 5-year-old emerges combative and inconsolable after tonsillectomy under sevoflurane without evidence of pain. Most effective prevention strategy:', options: ['Use of midazolam premedication', 'Propofol 1 mg/kg at end of case or dexmedetomidine 0.3 mcg/kg', 'Increased opioid dose', 'Diphenhydramine'], answer: 1, rationale: 'Emergence delirium with volatile anesthetics is reduced by propofol bolus at end of case, dexmedetomidine, or low-dose fentanyl. Midazolam can worsen delirium in pediatrics.' },
  { q: 'Most appropriate management of a patient on chronic clopidogrel scheduled for elective hip replacement:', options: ['Continue clopidogrel through surgery', 'Stop clopidogrel 5–7 days preoperatively', 'Stop clopidogrel 24 hours preoperatively', 'Substitute with warfarin'], answer: 1, rationale: 'Clopidogrel is held 5–7 days before elective surgery with significant bleeding risk. Aspirin is typically continued. In patients with recent coronary stents, multidisciplinary discussion of stent thrombosis vs bleeding risk is required.' },
  { q: 'The classic finding on capnography in a patient developing malignant hyperthermia:', options: ['Decreased ETCO₂', 'Increased ETCO₂ unresponsive to increased minute ventilation', 'Loss of waveform', 'Curare cleft'], answer: 1, rationale: 'Rising ETCO₂ despite increased minute ventilation is the earliest and most sensitive sign of MH, reflecting hypermetabolism.' },
  { q: 'Most common cause of intraoperative anaphylaxis:', options: ['Volatile anesthetics', 'Latex', 'Neuromuscular blocking agents', 'Local anesthetics'], answer: 2, rationale: 'Neuromuscular blockers (especially rocuronium and succinylcholine) cause >50% of intraoperative anaphylaxis. Latex and antibiotics are next.' },
  { q: 'Best test to confirm anaphylaxis after intraoperative cardiovascular collapse:', options: ['IgE level', 'Serum tryptase within 30–90 minutes of event', 'Eosinophil count', 'Complement levels'], answer: 1, rationale: 'Serum tryptase peaks 30–90 min after onset; compare to baseline 24 h later. Levels >11.4 ng/mL or >20% above baseline support mast cell activation.' },
  { q: 'A patient with OSA undergoes total knee arthroplasty. Best postoperative analgesic strategy:', options: ['High-dose opioids with continuous pulse oximetry', 'Multimodal analgesia minimizing opioids, regional block, capnography monitoring', 'Avoid all analgesics', 'PCA without basal rate'], answer: 1, rationale: 'Multimodal opioid-sparing analgesia with regional anesthesia (e.g., adductor canal block) is preferred. PCA basal infusions are contraindicated in OSA.' },
  { q: 'Recommended dosing of succinylcholine in a 3-year-old when IV access cannot be obtained quickly:', options: ['1 mg/kg IM', '2 mg/kg IM', '4 mg/kg IM with atropine', '6 mg/kg IM'], answer: 2, rationale: 'IM dose is 4 mg/kg (max 200 mg) with atropine 0.02 mg/kg to prevent bradycardia. Onset is 2–4 minutes IM.' },
  { q: 'Which factor most increases the risk of postoperative delirium in the elderly?', options: ['Use of inhalational vs intravenous anesthesia', 'Benzodiazepine administration', 'Use of nitrous oxide', 'Type of fluid (crystalloid vs colloid)'], answer: 1, rationale: 'Benzodiazepines, anticholinergics, meperidine, deep anesthesia, and undertreated pain all increase delirium risk. Avoid benzodiazepines in vulnerable elderly.' },
  { q: 'Most appropriate intervention to prevent postoperative pulmonary complications in a 65-year-old smoker undergoing thoracotomy:', options: ['Smoking cessation 24 hours preoperatively', 'Smoking cessation ≥4–8 weeks preoperatively, incentive spirometry, regional analgesia', 'Routine N-acetylcysteine', 'Prophylactic antibiotics'], answer: 1, rationale: 'Smoking cessation for ≥4–8 weeks reduces complications; <24 hours may transiently worsen secretions. Bundle includes incentive spirometry, lung-protective ventilation, and epidural/regional analgesia.' },
  { q: 'Hyperkalemic cardiac arrest after succinylcholine is most likely in:', options: ['An adult with chronic renal failure on dialysis', 'A patient with burns 24 hours after injury', 'A patient with denervation injury 1 week after spinal cord injury', 'A patient with hepatic cirrhosis'], answer: 2, rationale: 'Upregulation of extrajunctional acetylcholine receptors after denervation injury, burns >24 h old, or prolonged immobilization causes massive K+ release with succinylcholine. Dialysis patients with normal K+ generally tolerate it.' },
  { q: 'Onset of significant adrenocortical suppression after a single dose of etomidate:', options: ['Immediate, lasts 6–24 hours', 'Begins at 4 hours, lasts <1 hour', 'Begins at 24 hours, lasts 72 hours', 'No suppression with single dose'], answer: 0, rationale: 'Even a single induction dose of etomidate suppresses 11β-hydroxylase, lowering cortisol for 6–24 hours. Clinical relevance is greatest in septic patients.' },
  { q: 'MAC-awake of sevoflurane (where patient will respond to verbal command) is approximately:', options: ['0.1 × MAC', '0.3 × MAC', '0.6 × MAC', '1.0 × MAC'], answer: 1, rationale: 'MAC-awake is roughly 0.3–0.4 × MAC for modern volatile agents. MAC-BAR (blocks autonomic response) is 1.5–2 × MAC.' },
  { q: 'Most appropriate first-line prophylaxis for PONV in a high-risk patient (Apfel score 3):', options: ['Single agent ondansetron', 'Combination of dexamethasone 4 mg + ondansetron 4 mg ± a third agent', 'Metoclopramide', 'Promethazine'], answer: 1, rationale: 'Multimodal prophylaxis with agents from different classes (5-HT3 antagonist, corticosteroid, ± NK1, ± droperidol/scopolamine) provides additive benefit in high-risk patients.' },
  { q: 'Most appropriate technique to confirm depth of anesthesia in a patient receiving TIVA with propofol and remifentanil during major spine surgery:', options: ['Train-of-four', 'Processed EEG (BIS) with target 40–60', 'End-tidal CO₂', 'Heart rate variability'], answer: 1, rationale: 'Without volatile end-tidal monitoring, processed EEG is the most reliable tool to titrate TIVA and reduce risk of intraoperative awareness.' },
  { q: 'A 6-week-old former 28-week premature infant requires inguinal hernia repair. Most appropriate postoperative disposition:', options: ['Discharge home from PACU', '23-hour observation in monitored unit', 'Same-day discharge with home apnea monitor', 'Outpatient with parental observation'], answer: 1, rationale: 'Former premature infants <60 weeks post-conceptual age require admission with apnea monitoring after general anesthesia.' },
  { q: 'Approximate context-sensitive half-time of fentanyl after a 6-hour infusion:', options: ['3–5 minutes', '30 minutes', '250–300 minutes', 'Unchanged from bolus'], answer: 2, rationale: 'Fentanyl accumulates in fat with prolonged infusion; context-sensitive half-time rises markedly with infusion duration. Remifentanil is the exception, remaining ~3–4 min regardless of duration.' },
  { q: 'Tube size and depth for a 4-year-old (cuffed ETT):', options: ['4.0 mm at 12 cm', '4.5 mm at 13.5 cm', '5.0 mm at 15 cm', '5.5 mm at 17 cm'], answer: 1, rationale: 'Cuffed size = (age/4) + 3.5 = 4.5; depth = 3 × tube size = 13.5 cm at the lip.' },
  { q: 'Best maneuver to optimize laryngoscopy view in a morbidly obese patient:', options: ['Standard sniffing position', 'Ramped position with auditory meatus level with sternal notch', 'Trendelenburg', 'Lateral position'], answer: 1, rationale: 'Ramped (HELP — Head Elevated Laryngoscopy Position) aligns the auditory meatus with the sternal notch, improves preoxygenation, and improves laryngoscopy view in obesity.' },
  { q: 'First-line treatment for intraoperative bronchospasm under general anesthesia:', options: ['Increase volatile anesthetic concentration and give inhaled albuterol', 'Bolus epinephrine 1 mg IV', 'Stop ventilation', 'Hyperventilate at high tidal volumes'], answer: 0, rationale: 'Deepen anesthesia with bronchodilating volatile (sevoflurane, isoflurane), administer beta-2 agonist via ETT. If severe and refractory, consider epinephrine 10–100 mcg IV. Rule out other causes (tube malposition, anaphylaxis).' },
  { q: 'ASA monitoring standards REQUIRE which during all anesthetics?', options: ['Processed EEG', 'Continuous oxygenation, ventilation, circulation; temperature when changes anticipated', 'Arterial line', 'Train-of-four'], answer: 1, rationale: 'Standard monitors: oxygenation (FiO₂ analyzer, pulse oximetry), ventilation (capnography, disconnect alarms), circulation (ECG, BP q5min), and temperature when changes are anticipated.' },
  { q: 'A patient develops dark blood in the surgical field, ETCO₂ rising, peak airway pressures rising, and SpO₂ 92% during laparoscopic cholecystectomy. Most likely diagnosis:', options: ['Pneumothorax', 'CO₂ embolism', 'Light anesthesia', 'Endobronchial intubation'], answer: 1, rationale: 'CO₂ embolism during laparoscopy presents with sudden hemodynamic collapse, decreased ETCO₂ (massive) or increased ETCO₂ (slow absorption), hypoxemia, and mill-wheel murmur. Stop insufflation, place in left lateral Trendelenburg, support circulation.' },
];

function QuizMode({ onBack }) {
  const [currentIdx, setCurrentIdx] = useState(0);
  const [selected, setSelected] = useState(null);
  const [showAnswer, setShowAnswer] = useState(false);
  const [answers, setAnswers] = useState({});
  const [mode, setMode] = useState('test'); // 'test' | 'results'
  const [reviewIdx, setReviewIdx] = useState(0);
  const [showRationale, setShowRationale] = useState(false);

  const q = QUESTIONS[currentIdx];
  const totalCorrect = Object.values(answers).filter(a => a.correct).length;
  const totalAnswered = Object.keys(answers).length;

  function handleSelect(idx) {
    if (showAnswer) return;
    setSelected(idx);
    setShowAnswer(true);
    setAnswers(prev => ({ ...prev, [currentIdx]: { chosen: idx, correct: idx === q.answer } }));
  }

  function handleNext() {
    setSelected(null);
    setShowAnswer(false);
    if (currentIdx < QUESTIONS.length - 1) setCurrentIdx(currentIdx + 1);
    else setMode('results');
  }

  function handleReset() {
    setCurrentIdx(0); setSelected(null); setShowAnswer(false);
    setAnswers({}); setMode('test'); setReviewIdx(0);
  }

  function getStyle(idx) {
    if (!showAnswer) return selected === idx ? 'bg-primary/10 border-primary ring-1 ring-primary' : 'bg-card border-border hover:bg-secondary/50';
    if (idx === q.answer) return 'bg-emerald-50 border-emerald-300 ring-1 ring-emerald-400';
    if (idx === selected && idx !== q.answer) return 'bg-red-50 border-red-300 ring-1 ring-red-400';
    return 'bg-card border-border opacity-50';
  }

  if (mode === 'results') {
    const pct = Math.round((totalCorrect / QUESTIONS.length) * 100);
    return (
      <div className="flex flex-col gap-4">
        <div className="bg-teal-700 text-white rounded-2xl p-5 text-center">
          <p className="text-4xl font-bold">{pct}%</p>
          <p className="text-sm opacity-80 mt-1">{totalCorrect}/{QUESTIONS.length} correct</p>
        </div>
        <div className="flex gap-2">
          <button onClick={() => { setMode('review'); setReviewIdx(0); setShowRationale(false); }}
            className="flex-1 py-3 bg-teal-50 border border-teal-200 rounded-xl text-sm font-semibold text-teal-700 active:scale-95 transition-all">📖 Review</button>
          <button onClick={handleReset}
            className="flex-1 py-3 bg-primary text-white rounded-xl text-sm font-semibold active:scale-95 transition-all flex items-center justify-center gap-1">
            <RotateCcw className="w-4 h-4" /> Restart
          </button>
        </div>
      </div>
    );
  }

  if (mode === 'review') {
    const rq = QUESTIONS[reviewIdx];
    const ua = answers[reviewIdx];
    return (
      <div className="flex flex-col gap-3">
        <div className="flex items-center justify-between">
          <button onClick={() => setMode('results')} className="flex items-center gap-1 text-primary text-sm font-medium"><ChevronLeft className="w-4 h-4" /> Results</button>
          <span className="text-xs text-muted-foreground">Q{reviewIdx + 1} of {QUESTIONS.length}</span>
        </div>
        <div className="rounded-xl p-3 border bg-teal-50 border-teal-200">
          <p className="text-sm font-semibold text-foreground leading-relaxed">{rq.q}</p>
        </div>
        <div className="flex flex-col gap-2">
          {rq.options.map((opt, idx) => {
            let style = 'bg-card border-border';
            let icon = null;
            if (idx === rq.answer) { style = 'bg-emerald-50 border-emerald-300'; icon = <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" />; }
            else if (ua?.chosen === idx && idx !== rq.answer) { style = 'bg-red-50 border-red-300'; icon = <XCircle className="w-4 h-4 text-red-500 shrink-0" />; }
            return (
              <div key={idx} className={`flex items-start gap-2 p-3 rounded-xl border ${style}`}>
                <span className="text-xs font-bold text-muted-foreground shrink-0 mt-0.5">{String.fromCharCode(65 + idx)}.</span>
                <p className="text-xs text-foreground flex-1">{opt}</p>
                {icon}
              </div>
            );
          })}
        </div>
        <button onClick={() => setShowRationale(r => !r)} className="flex items-center justify-between w-full p-3 bg-teal-50 border border-teal-200 rounded-xl text-sm font-semibold text-teal-700 active:scale-95 transition-all">
          <span>📖 Rationale</span>
          {showRationale ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
        </button>
        {showRationale && <div className="p-3 bg-teal-50/50 border border-teal-200 rounded-xl"><p className="text-xs text-foreground leading-relaxed">{rq.rationale}</p></div>}
        <div className="flex gap-2">
          <button onClick={() => { setReviewIdx(r => Math.max(0, r - 1)); setShowRationale(false); }} disabled={reviewIdx === 0}
            className="px-4 py-3 bg-secondary border border-border rounded-xl text-sm font-semibold text-muted-foreground disabled:opacity-40 active:scale-95 transition-all">
            <ChevronLeft className="w-4 h-4" />
          </button>
          <button onClick={() => { setReviewIdx(r => Math.min(QUESTIONS.length - 1, r + 1)); setShowRationale(false); }} disabled={reviewIdx === QUESTIONS.length - 1}
            className="flex-1 py-3 bg-primary text-white rounded-xl text-sm font-semibold disabled:opacity-40 active:scale-95 transition-all flex items-center justify-center gap-1">
            Next <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-center justify-between text-xs text-muted-foreground">
        <span>Q{currentIdx + 1} of {QUESTIONS.length}</span>
        <span>{totalAnswered > 0 ? `${totalCorrect}/${totalAnswered} correct` : ''}</span>
      </div>
      <div className="w-full h-1.5 bg-secondary rounded-full overflow-hidden mb-1">
        <div className="h-full bg-teal-600 rounded-full transition-all duration-300" style={{ width: `${((currentIdx + 1) / QUESTIONS.length) * 100}%` }} />
      </div>
      <div className="rounded-xl p-3 border bg-teal-50 border-teal-200">
        <p className="text-sm font-semibold text-foreground leading-relaxed">{q.q}</p>
      </div>
      <div className="flex flex-col gap-2">
        {q.options.map((opt, idx) => (
          <button key={idx} onClick={() => handleSelect(idx)} className={`flex items-start gap-2 p-3 rounded-xl border text-left transition-all active:scale-[0.98] ${getStyle(idx)}`}>
            <span className="text-xs font-bold text-muted-foreground shrink-0 mt-0.5 min-w-[16px]">{String.fromCharCode(65 + idx)}.</span>
            <p className="text-xs text-foreground leading-relaxed">{opt}</p>
            {showAnswer && idx === q.answer && <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0 ml-auto" />}
            {showAnswer && idx === selected && idx !== q.answer && <XCircle className="w-4 h-4 text-red-500 shrink-0 ml-auto" />}
          </button>
        ))}
      </div>
      {showAnswer && (
        <div className="p-3 bg-teal-50 border border-teal-200 rounded-xl">
          <p className="text-xs font-semibold text-teal-700 mb-1">{selected === q.answer ? '✅ Correct!' : '❌ Incorrect'} — Rationale</p>
          <p className="text-xs text-foreground leading-relaxed">{q.rationale}</p>
        </div>
      )}
      <div className="flex gap-2">
        <button onClick={() => { const pq = QUESTIONS[Math.max(0, currentIdx - 1)]; const pa = answers[Math.max(0, currentIdx - 1)]; setCurrentIdx(i => Math.max(0, i - 1)); setSelected(pa?.chosen ?? null); setShowAnswer(pa !== undefined); }}
          disabled={currentIdx === 0} className="px-4 py-3 bg-secondary border border-border rounded-xl text-sm font-semibold text-muted-foreground disabled:opacity-40 active:scale-95 transition-all">
          <ChevronLeft className="w-4 h-4" />
        </button>
        <button onClick={handleNext} disabled={!showAnswer}
          className="flex-1 py-3 bg-primary text-white rounded-xl text-sm font-semibold disabled:opacity-40 active:scale-95 transition-all flex items-center justify-center gap-1">
          {currentIdx === QUESTIONS.length - 1 ? 'View Results' : 'Next Question'} <ChevronRight className="w-4 h-4" />
        </button>
      </div>
    </div>
  );
}

export default function ABAAdvancedAdultPedsModule() {
  const [quizMode, setQuizMode] = useState(false);

  if (quizMode) {
    return (
      <div className="flex flex-col pb-4">
        <div className="flex items-center gap-2 mb-4">
          <button onClick={() => setQuizMode(false)} className="flex items-center gap-1 text-primary text-sm font-medium">
            <ChevronLeft className="w-4 h-4" /> Study Guide
          </button>
          <span className="text-xs text-muted-foreground">/ 50-Question Practice Quiz</span>
        </div>
        <QuizMode onBack={() => setQuizMode(false)} />
        <p className="text-[10px] text-muted-foreground text-center pt-4">For educational use only. Not for clinical decision-making.</p>
      </div>
    );
  }

  return (
    <div className="space-y-2 pb-4">
      <div className="p-4 rounded-xl bg-teal-50 border border-teal-100 mb-4">
        <p className="text-sm text-teal-900">ABA ADVANCED Board Review Series — Document 1 of 7. Covers pharmacology, airway, monitoring, subspecialty considerations, and pediatric physiology for the ADVANCED (Staged) Examination.</p>
        <button onClick={() => setQuizMode(true)} className="mt-3 w-full py-2.5 bg-teal-700 text-white rounded-xl text-sm font-semibold active:scale-[0.99] transition-all">
          📝 Take 50-Question Practice Quiz
        </button>
      </div>

      <Section title="1. Preoperative Evaluation and Risk Stratification" defaultOpen>
        <p className="text-sm">The ASA Physical Status classification is a 6-tier assessment: ASA I — healthy; ASA II — mild systemic disease; ASA III — severe systemic disease, not incapacitating; ASA IV — severe disease, constant threat to life; ASA V — moribund; ASA VI — brain-dead organ donor. The 'E' modifier denotes emergency.</p>
        <p className="font-semibold text-teal-800 mt-3">Cardiac Risk Assessment (2014 ACC/AHA)</p>
        <Bullet>Emergency surgery → proceed with risk reduction.</Bullet>
        <Bullet>Active cardiac conditions (unstable coronary syndrome, decompensated HF, significant arrhythmia, severe valvular disease) → evaluate before elective surgery.</Bullet>
        <Bullet>Low-risk surgery (&lt;1% MACE) → proceed.</Bullet>
        <Bullet>Intermediate/high-risk: ≥4 METs without symptoms → proceed; &lt;4 METs or unknown → consider stress testing only if results will change management.</Bullet>
        <p className="font-semibold text-teal-800 mt-3">Pulmonary Risk</p>
        <Bullet>Strongest predictors: age &gt;60, COPD, smoking within 8 weeks, OSA, ASA ≥ III, functional dependence, prolonged surgery.</Bullet>
        <Bullet>STOP-BANG ≥ 3 identifies OSA patients. Smoking cessation ≥ 4–8 weeks reduces postoperative pulmonary complications.</Bullet>
        <p className="font-semibold text-teal-800 mt-3">NPO Guidelines (ASA 2017, updated 2023)</p>
        <Table
          headers={['Item', 'Fast Time']}
          rows={[
            ['Clear liquids', '2 hours'],
            ['Breast milk', '4 hours'],
            ['Infant formula / non-human milk', '6 hours'],
            ['Light meal', '6 hours'],
            ['Fried/fatty foods or meat', '8 hours'],
          ]}
        />
        <KEY_POINT>Carbohydrate-containing clear drinks within 2 hours are now explicitly permitted and may improve patient comfort (ASA 2023 update).</KEY_POINT>
      </Section>

      <Section title="2. Airway Management">
        <p className="font-semibold text-teal-800">Predictors</p>
        <Bullet>Difficult mask ventilation — MOANS: Mask seal (beard, facial trauma), Obesity/Obstruction, Age &gt;55, No teeth, Stiff lungs.</Bullet>
        <Bullet>Difficult intubation — LEMON, Mallampati III–IV, thyromental distance &lt;6 cm, mouth opening &lt;3 cm, limited cervical extension.</Bullet>
        <p className="font-semibold text-teal-800 mt-3">ASA Difficult Airway Algorithm (2022)</p>
        <Bullet>Awake intubation indicated when difficult ventilation, intubation, cooperation, or aspiration risk is anticipated.</Bullet>
        <Bullet>Limit intubation attempts to 3 by experienced operator + 1 additional; transition to supraglottic device or surgical airway if attempts fail.</Bullet>
        <Bullet>Apneic oxygenation (high-flow nasal cannula 15 L/min or 70 L/min humidified) prolongs safe apnea time.</Bullet>
        <Bullet>Cricothyrotomy when "cannot intubate, cannot oxygenate" is declared.</Bullet>
        <p className="font-semibold text-teal-800 mt-3">RSI Indications</p>
        <p className="text-sm">Full stomach, GERD, bowel obstruction, trauma, pregnancy ≥20 weeks. Classic technique: preoxygenation to ET-O₂ ≥90%, propofol or etomidate + succinylcholine 1.0–1.5 mg/kg or rocuronium 1.0–1.2 mg/kg, with cricoid pressure (controversial). No mask ventilation before intubation unless SpO₂ declines.</p>
      </Section>

      <Section title="3. Pharmacology of Induction and Maintenance Agents">
        <p className="font-semibold text-teal-800">Propofol</p>
        <Bullet>GABA-A agonist. Induction 1.5–2.5 mg/kg; infusion 50–150 mcg/kg/min.</Bullet>
        <Bullet>Causes dose-dependent vasodilation, myocardial depression, apnea, ↓SVR.</Bullet>
        <Bullet>PRIS (metabolic acidosis, rhabdomyolysis, hyperkalemia, cardiac failure) with infusions &gt;4 mg/kg/h for &gt;48 hours, especially critically ill or pediatric patients.</Bullet>
        <p className="font-semibold text-teal-800 mt-3">Etomidate</p>
        <Bullet>Imidazole; induction 0.2–0.3 mg/kg. Minimal cardiovascular effects, useful in hemodynamic compromise.</Bullet>
        <Bullet>Inhibits 11β-hydroxylase → adrenocortical suppression even after a single dose (6–24 hours). Avoid infusions; use cautiously in sepsis.</Bullet>
        <p className="font-semibold text-teal-800 mt-3">Ketamine</p>
        <Bullet>NMDA antagonist. Induction 1–2 mg/kg IV or 4–8 mg/kg IM. Preserves respiratory drive; increases sympathetic tone (HR, BP, CO).</Bullet>
        <Bullet>Direct myocardial depressant in catecholamine-depleted patients. Increases secretions, bronchodilates, may raise ICP.</Bullet>
        <p className="font-semibold text-teal-800 mt-3">Volatile Anesthetics</p>
        <Bullet>MAC decreases ~6%/decade after 40; increased by hyperthermia, chronic alcohol; decreased by hypothermia, hypotension, pregnancy, opioids, α2 agonists, lithium.</Bullet>
        <Bullet>Sevoflurane — blood:gas 0.65, bronchodilator, suitable for inhalational induction; forms Compound A with desiccated CO₂ absorbent.</Bullet>
        <Bullet>Desflurane — blood:gas 0.42 (fastest); pungent → tachycardia/HTN with rapid increases &gt;1 MAC; contraindicated for inhalational induction.</Bullet>
        <Bullet>Nitrous oxide — diffuses into air-filled spaces (avoid with bowel obstruction, pneumothorax, intraocular gas, middle-ear surgery, recent intracranial gas).</Bullet>
        <p className="font-semibold text-teal-800 mt-3">Opioids</p>
        <Bullet>Remifentanil: context-sensitive half-time 3–4 min regardless of duration (plasma esterase metabolism). Unique among opioids.</Bullet>
        <Bullet>Morphine-6-glucuronide accumulates in renal failure → prolonged sedation/respiratory depression.</Bullet>
        <Bullet>Meperidine: normeperidine metabolite accumulates in renal failure → seizures. Avoid in elderly and renal impairment.</Bullet>
      </Section>

      <Section title="4. Neuromuscular Blockade and Reversal">
        <Table
          headers={['Agent', 'Dose', 'Key Points']}
          rows={[
            ['Succinylcholine', '1–1.5 mg/kg IV; 4 mg/kg IM', 'Depolarizing; onset 30–60 s. Avoid in burns >24 h, denervation, severe sepsis, prolonged immobilization, muscular dystrophy (K+ release), MH susceptibility'],
            ['Rocuronium', '0.6–1.2 mg/kg', 'Aminosteroid; reverse with sugammadex 2 mg/kg (moderate) or 16 mg/kg (immediate rescue)'],
            ['Cisatracurium', '0.15–0.2 mg/kg', 'Hofmann elimination — useful in renal/hepatic failure; minimal histamine release'],
          ]}
        />
        <Bullet>Neostigmine 0.05 mg/kg + glycopyrrolate 0.01 mg/kg reverses moderate block (TOF ≥ 2). Sugammadex preferred for deep block.</Bullet>
        <KEY_POINT>Quantitative TOF monitoring should confirm TOF ratio ≥ 0.9 before extubation to reduce residual paralysis risk.</KEY_POINT>
      </Section>

      <Section title="5. Monitoring and Intraoperative Management">
        <p className="text-sm">ASA standard monitors: oxygenation (FiO₂ analyzer, pulse oximetry), ventilation (capnography, disconnect alarms), circulation (ECG, BP every 5 min), temperature (when changes anticipated).</p>
        <KEY_POINT>Capnography is the single most reliable indicator of correct ETT placement and adequacy of ventilation.</KEY_POINT>
        <p className="font-semibold text-teal-800 mt-3">Processed EEG (BIS, SedLine)</p>
        <Bullet>Target 40–60 during general anesthesia. Most reliable for awareness prevention in TIVA without volatile end-tidal monitoring.</Bullet>
        <Bullet>ENGAGES trial: processed EEG did not reduce postoperative delirium overall.</Bullet>
        <Bullet>Volatile end-tidal concentration remains the gold standard for awareness prevention when available.</Bullet>
      </Section>

      <Section title="6. Pediatric Physiology and Pharmacology">
        <Bullet>Neonatal CO is rate-dependent (non-compliant ventricle) — bradycardia is the most common cause of hypotension and is usually hypoxia-driven.</Bullet>
        <Bullet>FRC is small; O₂ consumption is high (6–8 mL/kg/min vs 3–4 in adults) → rapid desaturation.</Bullet>
        <Bullet>Hepatic enzymes mature by 6 months; renal GFR reaches adult values by 1 year.</Bullet>
        <Bullet>MAC is highest at 1–6 months of age, then declines with age.</Bullet>
        <Bullet>Total body water 75% at birth, dropping to 60% by 1 year.</Bullet>
        <Bullet>Maintenance fluids (4-2-1 rule): 4 mL/kg/h first 10 kg, 2 mL/kg/h next 10 kg, 1 mL/kg/h thereafter.</Bullet>
      </Section>

      <Section title="7. Pediatric Airway and Equipment">
        <Bullet>Large occiput causes neck flexion supine; shoulder roll improves airway alignment in infants.</Bullet>
        <Bullet>Larynx is more cephalad (C3–C4 in infants vs C5–C6 in adults); epiglottis is omega-shaped and floppy.</Bullet>
        <Bullet>MRI data show the glottis is functionally narrowest (not cricoid). Cuffed ETTs are now standard in children.</Bullet>
        <Table
          headers={['Formula', 'Value']}
          rows={[
            ['Cuffed ETT size', '(age/4) + 3.5'],
            ['Uncuffed ETT size', '(age/4) + 4'],
            ['Tube depth (cm at lip)', '3 × tube size OR (age/2) + 12'],
          ]}
        />
      </Section>

      <Section title="8. Common Pediatric Scenarios">
        <p className="font-semibold text-teal-800">Upper Respiratory Infection (URI)</p>
        <Bullet>Children with active URI have 2–7× increased airway events. Delay elective surgery 2–4 weeks for symptomatic lower respiratory tract involvement.</Bullet>
        <Bullet>Risk factors: age &lt;1 year, prematurity, reactive airway disease, copious secretions, parental smoking, need for ETT.</Bullet>
        <p className="font-semibold text-teal-800 mt-3">Laryngospasm</p>
        <Bullet>Treat: jaw thrust, CPAP with 100% O₂, deepen anesthesia (propofol 0.5–1 mg/kg). If persistent: succinylcholine 0.1–0.5 mg/kg IV or 4 mg/kg IM + atropine.</Bullet>
        <Bullet>Negative pressure pulmonary edema can follow laryngospasm.</Bullet>
        <p className="font-semibold text-teal-800 mt-3">Emergence Delirium</p>
        <Bullet>More common with sevoflurane and desflurane than propofol-based maintenance.</Bullet>
        <Bullet>Prophylaxis: propofol 1 mg/kg at end of case, dexmedetomidine 0.3–0.5 mcg/kg, or fentanyl 1 mcg/kg. Distinct from pain — assess and treat both.</Bullet>
        <Bullet>Midazolam can worsen delirium in pediatric patients.</Bullet>
      </Section>

      <Section title="9. Geriatric Anesthesia">
        <Bullet>↓ Lean body mass, ↑ fat → prolonged elimination of lipophilic drugs.</Bullet>
        <Bullet>↓ Volume of distribution for water-soluble drugs → higher peak plasma concentrations.</Bullet>
        <Bullet>↓ Hepatic and renal clearance; reduce induction doses by 25–50%.</Bullet>
        <Bullet>↑ Sensitivity to benzodiazepines, opioids, volatile agents (MAC ↓ ~6%/decade after age 40).</Bullet>
        <Bullet>Postoperative delirium: associated with benzodiazepines, anticholinergics, meperidine, prolonged deep anesthesia, uncontrolled pain. Multicomponent prevention bundles reduce incidence by ~30%.</Bullet>
      </Section>

      <p className="text-[10px] text-muted-foreground text-center pt-2">ABA ADVANCED Board Review Series · Document 1 of 7 · For educational use only.</p>
    </div>
  );
}