import { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';

const KEY_POINT = ({ children }) => (
  <div className="my-3 p-3 rounded-lg bg-amber-50 border-l-4 border-amber-400 text-sm text-amber-900">
    <span className="font-bold">KEY POINT — </span>{children}
  </div>
);

const Section = ({ title, children, defaultOpen = false }) => {
  const [open, setOpen] = useState(defaultOpen);
  return (
    <div className="rounded-xl border border-border/60 overflow-hidden mb-3">
      <button
        onClick={() => setOpen(o => !o)}
        className="w-full flex items-center justify-between px-4 py-3 bg-secondary text-left"
      >
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
            {row.map((cell, j) => <td key={j} className="px-3 py-2 border-b border-border/30">{cell}</td>)}
          </tr>
        ))}
      </tbody>
    </table>
  </div>
);

const Bullet = ({ children }) => <p className="pl-3 border-l-2 border-slate-200 text-sm text-foreground">• {children}</p>;

export default function ABAClinicalproceduresModule() {
  return (
    <div className="space-y-2 pb-4">
      {/* Intro */}
      <div className="p-4 rounded-xl bg-blue-50 border border-blue-100 mb-4">
        <p className="text-sm text-blue-900">This module covers preoperative assessment, airway management, vascular access, regional anesthesia procedures, fluid and transfusion management, and PACU care. The BASIC exam routinely combines knowledge of a technique with anticipation of its complications.</p>
      </div>

      {/* 5.1 Preoperative Assessment */}
      <Section title="5.1 · Preoperative Assessment" defaultOpen>
        <p className="font-semibold text-blue-800">ASA Physical Status</p>
        <Table
          headers={['Class', 'Definition', 'Example']}
          rows={[
            ['I', 'Healthy', 'Otherwise well non-smoker'],
            ['II', 'Mild systemic disease', 'Controlled HTN/DM, mild obesity, pregnancy, smoker'],
            ['III', 'Severe systemic disease, not incapacitating', 'Poorly controlled DM/HTN, COPD, BMI ≥ 40, ESRD on dialysis, MI/CVA > 3 mo'],
            ['IV', 'Severe systemic disease, constant threat to life', 'Recent (<3 mo) MI/CVA, ongoing ischemia, severe valve dysfunction, EF < 30%'],
            ['V', 'Moribund, not expected to survive without operation', 'Ruptured AAA, massive trauma, ICH with mass effect'],
            ['VI', 'Brain-dead organ donor', ''],
            ['E', 'Emergency suffix added to any class', ''],
          ]}
        />

        <p className="font-semibold text-blue-800 mt-3">NPO Guidelines (ASA 2017)</p>
        <Table
          headers={['Intake', 'Minimum Fasting Time']}
          rows={[
            ['Clear liquids (water, black coffee, pulp-free juice)', '2 hours'],
            ['Breast milk', '4 hours'],
            ['Infant formula', '6 hours'],
            ['Light meal (toast + clear liquid)', '6 hours'],
            ['Full / fatty meal, fried food, meat', '8 hours'],
          ]}
        />

        <p className="font-semibold text-blue-800 mt-3">Cardiac Risk Stratification (ACC/AHA 2014)</p>
        <Bullet>Emergency surgery → proceed.</Bullet>
        <Bullet>Active cardiac condition (unstable angina, decompensated HF, severe valve, significant arrhythmia) → evaluate/treat first.</Bullet>
        <Bullet>Low-risk surgery (&lt;1% MACE) → proceed.</Bullet>
        <Bullet>≥4 METs functional capacity (climb stairs without symptoms) → proceed.</Bullet>
        <Bullet>&lt;4 METs or unknown + elevated risk → consider stress testing if it will change management.</Bullet>
        <KEY_POINT>Routine preoperative tests in healthy patients have no proven benefit. Order tests only to evaluate specific findings on history/exam OR when results would change management.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Medication Management</p>
        <Bullet>Continue: β-blockers, statins (begin perioperatively if indicated), antihypertensives EXCEPT ACE/ARB on morning of surgery (hold to avoid refractory hypotension).</Bullet>
        <Bullet>Hold: oral hypoglycemics (DOS), SGLT-2 inhibitors (3–4 days — DKA risk), warfarin (5 days), most NSAIDs.</Bullet>
        <Bullet>Bridge: high-risk anticoagulation (mechanical mitral valve, recent VTE, CHADS₂ ≥ 5).</Bullet>
        <Bullet>DOACs: hold 24–48 hr (normal renal function); longer if CrCl reduced or high-risk surgery.</Bullet>
      </Section>

      {/* 5.2 Airway */}
      <Section title="5.2 · Airway Management">
        <p className="font-semibold text-blue-800">Difficult Airway Predictors</p>
        <Bullet>History: prior difficult intubation, OSA, head/neck radiation, oral/cervical surgery, RA (atlantoaxial), Down syndrome.</Bullet>
        <Bullet>Examination: Mallampati III/IV, thyromental distance &lt;6 cm, mouth opening &lt;3 cm, neck circumference &gt;40 cm, limited cervical extension (&lt;35°), prominent incisors, receding chin.</Bullet>
        <Bullet>Mnemonics: LEMON (Look, Evaluate 3-3-2, Mallampati, Obstruction, Neck mobility); MOANS (Mask, Obesity, Aged, No teeth, Stiff lungs); RODS (Restricted opening, Obstruction, Distorted, Stiff).</Bullet>

        <p className="font-semibold text-blue-800 mt-3">ASA Difficult Airway Algorithm — Core Decision Points</p>
        <Bullet>Awake intubation if: severe difficulty predicted, aspiration risk + difficult mask, anticipated difficulty oxygenating.</Bullet>
        <Bullet>Asleep approach if difficulty unlikely; have a backup plan (LMA, video laryngoscopy, fiberoptic).</Bullet>
        <Bullet>CICO (cannot intubate, cannot oxygenate): wake the patient if feasible; otherwise emergency surgical airway (cricothyrotomy).</Bullet>
        <KEY_POINT>Limit direct laryngoscopy attempts: a third attempt with the same laryngoscope is generally not justified. Each failed attempt worsens edema and risk. After two failed attempts call for help, switch device (video laryngoscope), or move to rescue (LMA).</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Rapid Sequence Induction (RSI)</p>
        <Bullet>Indications: full stomach, GERD/hiatal hernia, pregnancy ≥ 20 weeks, bowel obstruction, trauma, recent meal.</Bullet>
        <Bullet>Classic technique: pre-oxygenation (3 min tidal volume OR 8 vital-capacity breaths), induction agent + succinylcholine 1.5 mg/kg (or rocuronium 1.2 mg/kg), cricoid pressure (Sellick — now optional/debated), no mask ventilation, intubate.</Bullet>
        <Bullet>Modified RSI: gentle ventilation with low pressures (&lt;15 cmH₂O) before intubation in patients who cannot tolerate apnea.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Extubation Criteria</p>
        <Bullet>Awake, follows commands.</Bullet>
        <Bullet>Adequate spontaneous ventilation: Vt ≥ 5 mL/kg, RR 10–30, NIF more negative than −20 cmH₂O.</Bullet>
        <Bullet>Quantitative TOF ratio ≥ 0.9.</Bullet>
        <Bullet>Hemodynamically stable, normothermic, normoxemic, normocapnic.</Bullet>
        <Bullet>Adequate airway reflexes; no significant edema (cuff leak test if concerned).</Bullet>
      </Section>

      {/* 5.3 Vascular Access */}
      <Section title="5.3 · Vascular Access">
        <p className="font-semibold text-blue-800">Peripheral IV Considerations</p>
        <p className="text-sm">Flow ∝ r⁴ / length (Poiseuille). Short, large-bore catheter is faster than central line for fluid resuscitation. 14-G ~300 mL/min; 16-G ~200 mL/min; 18-G ~100 mL/min.</p>

        <p className="font-semibold text-blue-800 mt-3">Central Venous Access</p>
        <Table
          headers={['Site', 'Advantage', 'Disadvantage']}
          rows={[
            ['Internal jugular (right)', 'Direct path to SVC, ultrasound easy, compressible', 'Carotid puncture, pneumothorax (lower than subclavian)'],
            ['Subclavian', 'Comfort, infection rate lowest', 'Pneumothorax (highest), non-compressible, ultrasound harder'],
            ['Femoral', 'Easy, no chest complications, useful in arrest', 'Higher infection/DVT, less reliable CVP, no ultrasound for CVP/PA'],
            ['PICC', 'Long-term, outpatient-compatible', 'Higher thrombosis; not for rapid resuscitation'],
          ]}
        />
        <KEY_POINT>Ultrasound guidance is the standard of care for internal jugular access; reduces mechanical complications. Confirm wire position in the vein (long axis or contralateral view) before dilator advancement.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Arterial Lines</p>
        <Bullet>Radial: most common; Allen test has poor predictive value; ulnar pulse and palmar arch perfusion check are sufficient.</Bullet>
        <Bullet>Femoral: more accurate central pressure approximation; useful in shock when radial is unreliable.</Bullet>
        <Bullet>Brachial: end-artery — limb-threatening if thrombosed; avoid in most cases.</Bullet>
        <Bullet>Dorsalis pedis / posterior tibial: useful in pediatrics; SBP overestimates more peripherally (distal amplification).</Bullet>
      </Section>

      {/* 5.4 Regional Anesthesia */}
      <Section title="5.4 · Regional Anesthesia">
        <p className="font-semibold text-blue-800">Spinal Anesthesia</p>
        <Bullet>Single-shot intrathecal injection of LA into the CSF below L1 (adult).</Bullet>
        <Bullet>Baricity: hyperbaric (mixed with dextrose) settles to the lowest point; isobaric (plain) stays at injection level; hypobaric (mixed with water) floats up.</Bullet>
        <Bullet>Determinants of spread: baricity, position, dose (volume × concentration). Patient height/weight, needle direction, and barbotage are minor factors.</Bullet>
        <Bullet>Common dosing: bupivacaine 0.5% — 12 mg for cesarean, 15 mg for TURP/lower abdominal. Hyperbaric lidocaine 5% largely abandoned due to TNS.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Epidural Anesthesia</p>
        <Bullet>Continuous catheter-based technique allowing titration and prolonged analgesia.</Bullet>
        <Bullet>Loss-of-resistance with saline or air to identify the epidural space. Air carries small risk of venous air embolism and incomplete block.</Bullet>
        <Bullet>Test dose (3 mL 1.5% lidocaine with 1:200,000 epinephrine): detects intravascular (HR rise) or subarachnoid (rapid spinal) placement.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Complications of Neuraxial Anesthesia</p>
        <Table
          headers={['Complication', 'Cause / Management']}
          rows={[
            ['Hypotension', 'Sympathectomy below block level; treat with fluids, ephedrine/phenylephrine, left uterine displacement in OB'],
            ['High/total spinal', 'Cephalad spread → respiratory failure, hypotension, bradycardia; support airway, BP, atropine'],
            ['PDPH', 'Positional headache 24–72 hr after dural puncture; treat conservative → caffeine → epidural blood patch (15–20 mL)'],
            ['Epidural hematoma', 'Anticoagulation, coagulopathy, traumatic placement → persistent back pain, motor block; MRI urgent, decompression within 8 hr'],
            ['Epidural abscess', 'Late (days–weeks); fever, back pain, neurologic deficit; MRI, antibiotics ± drainage'],
            ['Cauda equina syndrome', 'Saddle anesthesia, urinary retention, weakness — historically with continuous spinal microcatheters + lidocaine'],
            ['TNS', 'Buttock/leg pain after spinal lidocaine, self-limited (1–2 days); not progressive'],
          ]}
        />

        <p className="font-semibold text-blue-800 mt-3">Contraindications</p>
        <Bullet>Absolute: patient refusal, infection at site, severe coagulopathy / therapeutic anticoagulation, ↑ ICP with mass effect, true allergy to LA.</Bullet>
        <Bullet>Relative: pre-existing neurologic disease, severe stenotic valvular lesions (AS), spinal deformity, sepsis.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">ASRA Neuraxial Anticoagulation Guidelines</p>
        <Table
          headers={['Drug', 'Hold Before Neuraxial', 'Restart After Catheter Removal']}
          rows={[
            ['Aspirin / NSAIDs', 'No interval', 'No restriction'],
            ['SC UFH prophylactic (≤15,000 U/day)', '4–6 hr or normal aPTT', '1 hr after catheter removal'],
            ['LMWH prophylactic', '12 hr', '12 hr (or 4 hr after catheter removal)'],
            ['LMWH therapeutic', '24 hr', '24 hr'],
            ['Warfarin', 'INR ≤ 1.4 (≈5 days)', 'Once catheter removed'],
            ['Clopidogrel', '5–7 days', 'Immediately'],
            ['Rivaroxaban / apixaban', '72 hr', '6 hr after catheter removal'],
          ]}
        />
      </Section>

      {/* 5.5 Fluid & Transfusion */}
      <Section title="5.5 · Fluid & Transfusion Management">
        <p className="font-semibold text-blue-800">Crystalloids</p>
        <Bullet>0.9% saline: 154 mEq Na/Cl. Large volumes → hyperchloremic metabolic acidosis. Use when alkalemic or hyponatremic patients need volume.</Bullet>
        <Bullet>Lactated Ringer's / Plasma-Lyte: balanced electrolytes; preferred for general resuscitation.</Bullet>
        <Bullet>Dextrose-containing solutions are NOT volume replacement; use in pediatrics and for glycemic support only.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Maintenance Fluid (4-2-1 Rule)</p>
        <p className="text-sm">4 mL/kg/hr for first 10 kg + 2 mL/kg/hr for next 10 kg + 1 mL/kg/hr for each kg above 20 kg.</p>

        <p className="font-semibold text-blue-800 mt-3">Transfusion Thresholds</p>
        <Bullet>RBC: transfuse below Hb 7 g/dL (or 8 in CV disease). Symptomatic patients regardless.</Bullet>
        <Bullet>Platelets: &lt;10 × 10⁹/L (prophylactic); &lt;20 if febrile/bleeding risk; &lt;50 for invasive procedures; &lt;100 for neurosurgery or ophthalmologic.</Bullet>
        <Bullet>FFP: INR &gt; 1.5–2.0 with bleeding or invasive procedure planned; 10–15 mL/kg.</Bullet>
        <Bullet>Cryoprecipitate: fibrinogen &lt;100–150 mg/dL with bleeding; 1 unit per 10 kg (raises fibrinogen ~50 mg/dL).</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Massive Transfusion</p>
        <Bullet>Definition: &gt;10 units PRBC in 24 hr, or &gt;4 units in 1 hr.</Bullet>
        <Bullet>Ratio: 1:1:1 PRBC : FFP : platelets (approximates whole blood).</Bullet>
        <Bullet>Monitor for: hypocalcemia (citrate), hyperkalemia (stored RBC lysis), hypothermia, acidosis, dilutional coagulopathy, TRALI, TACO.</Bullet>
        <KEY_POINT>TRALI (acute lung injury within 6 hr of transfusion): leading cause of transfusion-related mortality. TACO (volume overload): differentiate by hemodynamics (TRALI hypotensive, TACO hypertensive). FFP and platelets carry highest TRALI risk; PRBC lowest.</KEY_POINT>
      </Section>

      {/* 5.6 PACU */}
      <Section title="5.6 · PACU & Postoperative Care">
        <p className="font-semibold text-blue-800">Aldrete / Modified Aldrete Score</p>
        <p className="text-sm">0–2 points each for: activity, respiration, circulation, consciousness, O₂ saturation. Score ≥ 9 typically required for discharge from Phase I PACU.</p>

        <p className="font-semibold text-blue-800 mt-3">PONV</p>
        <Bullet>Risk factors (Apfel): female sex, non-smoker, history of PONV/motion sickness, postop opioids. Each adds ~20% risk (baseline ~10%).</Bullet>
        <Bullet>Multimodal prophylaxis for ≥2 risk factors: ondansetron 4 mg + dexamethasone 4–8 mg at induction; consider scopolamine patch, droperidol 0.625 mg, aprepitant for high-risk.</Bullet>
        <Bullet>Treatment: use a drug from a different class than prophylaxis.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Postoperative Hypoxemia</p>
        <Bullet>Most common cause: atelectasis. Treat with incentive spirometry, CPAP, head-up position.</Bullet>
        <Bullet>Differential: residual NMB, pulmonary edema (cardiogenic, negative-pressure, TRALI), aspiration, pneumothorax, opioid-induced hypoventilation.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Postoperative Pain</p>
        <Bullet>Multimodal analgesia: acetaminophen + NSAID + opioid + regional/local.</Bullet>
        <Bullet>PCA basal infusion in opioid-naive patients ↑ risk of respiratory depression without improving analgesia — avoid.</Bullet>
        <Bullet>Gabapentinoids potentiate opioid respiratory depression; ketamine subdissociative infusion (0.1–0.5 mg/kg/hr) is opioid-sparing.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Postoperative Delirium</p>
        <Bullet>Risk factors: age &gt;65, cognitive impairment, sensory deficits, polypharmacy (especially benzodiazepines, anticholinergics, meperidine), poor pain control.</Bullet>
        <Bullet>Prevention: orient patient, restore sensory aids, treat pain (avoid meperidine), maintain sleep/wake cycle, mobilize early, avoid benzodiazepines if possible.</Bullet>
      </Section>

      <p className="text-[10px] text-muted-foreground text-center pt-2">© CE Halo LLC · ABA BASIC Study Package · Module 5 · Edition 2026</p>
    </div>
  );
}