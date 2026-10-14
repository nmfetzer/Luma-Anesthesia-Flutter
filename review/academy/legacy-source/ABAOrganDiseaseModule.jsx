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

export default function ABAOrganDiseaseModule() {
  return (
    <div className="space-y-2 pb-4">
      {/* Intro */}
      <div className="p-4 rounded-xl bg-blue-50 border border-blue-100 mb-4">
        <p className="text-sm text-blue-900">This final module surveys the patient-specific diseases the BASIC exam most frequently builds questions around. Each section presents the disease, what it does to physiology, and the anesthetic adjustments that follow.</p>
      </div>

      {/* 8.1 Pulmonary */}
      <Section title="8.1 · Pulmonary Disease" defaultOpen>
        <p className="font-semibold text-blue-800">COPD</p>
        <Bullet>Obstructive pattern: FEV1/FVC &lt; 0.70; FEV1 stages severity (mild ≥80%, moderate 50–80%, severe 30–50%, very severe &lt;30%).</Bullet>
        <Bullet>Optimize preop: smoking cessation (≥8 weeks best; even 24 hr ↓ CO), bronchodilators, treat infection.</Bullet>
        <Bullet>Anesthetic: regional preferred; if GA — avoid histamine releasers, prefer volatile (bronchodilation), use slow inspiratory flow + long expiratory time + low PEEP to avoid auto-PEEP.</Bullet>
        <Bullet>Auto-PEEP / dynamic hyperinflation: ↓ venous return, hypotension. Treat: disconnect circuit, allow full exhalation.</Bullet>
        <KEY_POINT>Even 24 hours of smoking abstinence reduces carboxyhemoglobin and improves oxygen-carrying capacity. Sputum production transiently increases at 4–8 weeks; optimal cessation is ≥8 weeks before surgery.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Asthma</p>
        <Bullet>Optimize: peak flow at baseline, continue inhalers (give MDI in pre-op), steroids if not at baseline.</Bullet>
        <Bullet>Intraoperative bronchospasm: ↑ inspiratory pressure, wheezing, ↑ ETCO₂ with sharkfin capnograph. Treat: deepen anesthesia (volatile), albuterol via ETT (8–10 puffs), epinephrine (1–10 µg IV) if severe, IV corticosteroid; rule out mechanical causes.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Restrictive Lung Disease</p>
        <Bullet>↓ TLC, FRC, VC; FEV1/FVC normal/↑. Goals: low Vt (6 mL/kg IBW), higher RR, accept permissive hypercapnia; avoid high inspiratory pressures.</Bullet>
      </Section>

      {/* 8.2 Cardiovascular */}
      <Section title="8.2 · Cardiovascular Disease">
        <p className="font-semibold text-blue-800">Hypertension</p>
        <Bullet>Continue antihypertensives day of surgery EXCEPT ACE inhibitors / ARBs (refractory hypotension).</Bullet>
        <Bullet>Elective surgery generally OK if SBP &lt; 180 / DBP &lt; 110.</Bullet>
        <Bullet>Etomidate or careful propofol induction; avoid sympathetic surges (esmolol or lidocaine at intubation).</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Coronary Artery Disease</p>
        <Bullet>Active ischemia, unstable angina, recent MI (&lt;60 days drug-eluting, &lt;30 days bare-metal stent), severe arrhythmia, decompensated HF = postpone elective surgery.</Bullet>
        <Bullet>DAPT after PCI: bare-metal stent — minimum 1 month; drug-eluting stent — 3–6 months (newer-generation).</Bullet>
        <Bullet>Maintain CPP; avoid tachycardia and hypotension; consider invasive BP, 5-lead ECG.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Heart Failure</p>
        <Bullet>HFrEF (EF &lt;40%): continue β-blocker; hold ACE/ARB day of surgery. Avoid myocardial depression; consider invasive monitoring.</Bullet>
        <Bullet>HFpEF: EF preserved; diastolic dysfunction. Sensitive to volume — avoid both hypovolemia and overload.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Pulmonary Hypertension</p>
        <Bullet>Goals: maintain RV function — avoid hypoxia, hypercapnia, acidosis, hypothermia, high airway pressures (all ↑ PVR).</Bullet>
        <Bullet>Maintain SVR &gt; PVR (phenylephrine, vasopressin). Avoid: N₂O (↑ PVR), high PEEP.</Bullet>
        <Bullet>Selective pulmonary vasodilators: inhaled NO, prostaglandins (epoprostenol, iloprost), milrinone.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Arrhythmias</p>
        <Bullet>AF: rate control (β-blocker, diltiazem) intraop; new-onset AF perioperatively common — usually self-limited.</Bullet>
        <Bullet>Long QT: avoid QT-prolonging drugs (haloperidol, droperidol, methadone, certain inhalational agents).</Bullet>
        <Bullet>WPW: avoid AV nodal blockers (adenosine, diltiazem, β-blocker, digoxin) if wide-complex AF — paradoxical accelerated conduction.</Bullet>
      </Section>

      {/* 8.3 Neurologic */}
      <Section title="8.3 · Neurologic Disease">
        <p className="font-semibold text-blue-800">Seizure Disorders</p>
        <Bullet>Continue antiepileptics. Anticonvulsant induction: propofol, thiopental.</Bullet>
        <Bullet>Phenytoin/carbamazepine induce CYP → ↑ NMB resistance (need higher rocuronium/vecuronium doses).</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Parkinson Disease</p>
        <Bullet>Continue levodopa up to and including morning of surgery (rebound rigidity, dysphagia, hypoventilation if missed).</Bullet>
        <Bullet>Avoid: metoclopramide, droperidol, butyrophenones, phenothiazines (D2 antagonists worsen symptoms).</Bullet>
        <Bullet>Safe antiemetics: ondansetron, dexamethasone.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Myasthenia Gravis</p>
        <Bullet>Autoimmune anti-AChR antibodies → weakness, fatigability.</Bullet>
        <Bullet>RESISTANT to succinylcholine (need ↑ dose); SENSITIVE to non-depolarizers (use ~10% normal dose, titrate to TOF).</Bullet>
        <Bullet>Consider postoperative ventilation if: disease duration &gt;6 yr, pyridostigmine &gt;750 mg/day, VC &lt;2.9 L.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Multiple Sclerosis</p>
        <Bullet>Avoid spinal anesthesia (relative — risk of relapse); epidural acceptable.</Bullet>
        <Bullet>Maintain normothermia (hyperthermia worsens demyelinated conduction — Uhthoff phenomenon).</Bullet>
        <Bullet>Succinylcholine: avoid in chronic paralysis from disuse (extrajunctional receptor upregulation → hyperkalemia).</Bullet>
      </Section>

      {/* 8.4 Endocrine */}
      <Section title="8.4 · Endocrine Disease">
        <p className="font-semibold text-blue-800">Diabetes Mellitus</p>
        <Bullet>Hold oral hypoglycemics morning of surgery. Hold SGLT-2 inhibitors 3–4 days (DKA risk, sometimes euglycemic).</Bullet>
        <Bullet>Long-acting insulin (glargine): 50–80% of usual dose. Intermediate (NPH): 50% of morning dose. Short/rapid: hold.</Bullet>
        <Bullet>Target intraoperative glucose 140–180 mg/dL. Autonomic neuropathy → silent ischemia, gastroparesis, labile BP.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Thyroid Disease</p>
        <Bullet>Hyperthyroidism: optimize before elective surgery (β-blocker, PTU/methimazole). Thyroid storm — propranolol, PTU, iodide, steroid, cooling.</Bullet>
        <Bullet>Hypothyroidism: minor cases proceed; severe (myxedema) — postpone, treat with IV levothyroxine + hydrocortisone.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Adrenal Insufficiency / Steroid Replacement</p>
        <Bullet>Chronic steroids (prednisone ≥5 mg/day for &gt;3 weeks within last year) may have HPA suppression.</Bullet>
        <Bullet>Stress dose: minor — usual morning dose; moderate — 25 mg hydrocortisone at induction; major — 100 mg at induction + 50 mg q8h × 24 hr.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Pheochromocytoma</p>
        <Bullet>Preoperative α-blockade (phenoxybenzamine or doxazosin) for 10–14 days, THEN β-blockade if tachycardia (NEVER β-block before α-block — unopposed α leads to crisis).</Bullet>
        <Bullet>Intraop: arterial line, central access; treat HTN crisis with phentolamine, nicardipine, nitroprusside, magnesium; hypotension after tumor ligation with NE and phenylephrine.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Carcinoid Syndrome</p>
        <Bullet>Serotonin, histamine, kinins → flushing, diarrhea, bronchospasm, right-heart valve disease.</Bullet>
        <Bullet>Preop octreotide 100–500 µg subcut TID for 1–2 weeks; intraop infusion. Carcinoid crisis: octreotide bolus 100–500 µg IV.</Bullet>
        <Bullet>Avoid: histamine releasers (morphine, atracurium), sympathomimetics (may trigger crisis).</Bullet>
      </Section>

      {/* 8.5 Renal & Hepatic */}
      <Section title="8.5 · Renal & Hepatic Disease">
        <p className="font-semibold text-blue-800">Chronic Kidney Disease / ESRD</p>
        <Bullet>Ideally dialyzed within 24 hr preop; check K⁺. Avoid: NSAIDs, nephrotoxic contrasts, succinylcholine if K⁺ &gt; 5.5.</Bullet>
        <Bullet>Prefer: hydromorphone, fentanyl, cisatracurium (Hofmann). Avoid morphine (M6G), meperidine (normeperidine), gabapentin, atenolol.</Bullet>
        <Bullet>AV fistula: avoid BP cuff and IV on that arm; pad carefully.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Acute Kidney Injury Prevention</p>
        <Bullet>Maintain MAP &gt; 65 (higher in chronic HTN); avoid hypovolemia; consider goal-directed fluid therapy.</Bullet>
        <Bullet>Avoid nephrotoxic combinations (NSAIDs + ACE/ARB + contrast or aminoglycoside). Avoid HES (hetastarch) in critically ill.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Liver Disease</p>
        <Bullet>MELD / Child-Pugh stratify mortality; even minor cirrhosis significantly increases perioperative risk.</Bullet>
        <Bullet>INR is a POOR predictor of bleeding in cirrhosis — use PT/INR + platelets + fibrinogen + ROTEM/TEG.</Bullet>
        <Bullet>Prefer cisatracurium (Hofmann) and remifentanil (esterase). Maintain hepatic blood flow: avoid hypotension, hypoxia, hypercapnia.</Bullet>
        <Bullet>Hepatopulmonary syndrome: hypoxia improves supine, worsens upright.</Bullet>
      </Section>

      {/* 8.6 Hematologic */}
      <Section title="8.6 · Hematologic Disease">
        <p className="font-semibold text-blue-800">Anemia</p>
        <Bullet>Transfusion threshold: 7 g/dL in stable, 8 in CV disease, higher if symptomatic.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Sickle Cell</p>
        <Bullet>Maintain oxygenation, normothermia, hydration, avoid acidosis — all to prevent sickling.</Bullet>
        <Bullet>Exchange transfusion to reduce HbS to &lt;30% for major surgery (debated).</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Coagulation Disorders</p>
        <Bullet>Hemophilia A (factor VIII), B (factor IX): target 80–100% activity for major surgery, 50% for minor.</Bullet>
        <Bullet>Von Willebrand type 1: DDAVP (releases stored vWF); types 2/3: vWF/factor VIII concentrate.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Anticoagulation Reversal</p>
        <Table
          headers={['Drug', 'Reversal Agent']}
          rows={[
            ['Warfarin', 'Vitamin K (slow), FFP, 4-factor PCC (Kcentra) — fastest for emergency'],
            ['Heparin (UFH)', 'Protamine 1 mg per 100 U heparin in last 2–3 hr'],
            ['LMWH', 'Protamine partially effective (60–75%)'],
            ['Dabigatran', 'Idarucizumab (Praxbind) 5 g IV'],
            ['Apixaban / Rivaroxaban', 'Andexanet alfa (Andexxa); 4-factor PCC as alternative'],
            ['Antiplatelet (aspirin, clopidogrel)', 'Platelet transfusion; DDAVP (limited benefit)'],
          ]}
        />
      </Section>

      {/* 8.7 Sepsis */}
      <Section title="8.7 · Infectious Disease & Sepsis">
        <p className="font-semibold text-blue-800">Sepsis Bundle (Hour-1)</p>
        <Bullet>Measure lactate; remeasure if &gt; 2. Blood cultures before antibiotics.</Bullet>
        <Bullet>Broad-spectrum antibiotics. Crystalloid 30 mL/kg for hypotension or lactate ≥ 4.</Bullet>
        <Bullet>Vasopressors (norepinephrine first-line) to MAP ≥ 65.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Anesthetic Considerations in Septic Patients</p>
        <Bullet>Vasoplegia: high-dose vasopressors; consider vasopressin, hydrocortisone for refractory shock.</Bullet>
        <Bullet>Etomidate: single dose acceptable; concern for adrenal suppression.</Bullet>
        <Bullet>Lung-protective ventilation. Glucose control 140–180. Avoid colloids (especially HES).</Bullet>
      </Section>

      {/* 8.8 Surgical Considerations */}
      <Section title="8.8 · Special Surgical Considerations">
        <p className="font-semibold text-blue-800">Laparoscopy</p>
        <Bullet>Pneumoperitoneum 12–15 mmHg → ↑ SVR, ↓ venous return, ↑ PaCO₂.</Bullet>
        <Bullet>CO₂ embolism (rare, catastrophic): sudden ↓ ETCO₂, hypotension, mill-wheel murmur; release pneumoperitoneum, left lateral + head-down, aspirate from CVL.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Robotic Surgery</p>
        <Bullet>Once docked, patient cannot be moved without un-docking — plan position carefully.</Bullet>
        <Bullet>Steep Trendelenburg for hours → facial/oropharyngeal edema, ↑ ICP, ↓ FRC, optic neuropathy risk.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Lateral & Prone Positioning</p>
        <Bullet>Prone: protect eyes (no pressure — POVL risk), free abdomen, neutral neck, tuck arms or &lt;90° abduction.</Bullet>
        <Bullet>Lateral: axillary roll just caudal to dependent axilla (NOT in axilla — brachial plexus injury); ear flat, nondependent arm padded.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Bariatric Surgery</p>
        <Bullet>Ramp position, awake fiberoptic if airway concerns, preoxygenate with CPAP. DVT prophylaxis aggressive (mechanical + chemical).</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Outpatient / Ambulatory</p>
        <Bullet>Patient selection: ASA I–III stable, escort home, safe environment.</Bullet>
        <Bullet>Discharge criteria: ambulating, voided, tolerating PO, pain controlled, no nausea, escort present.</Bullet>
      </Section>

      <p className="text-[10px] text-muted-foreground text-center pt-2">© CE Halo LLC · ABA BASIC Study Package · Module 8 · Edition 2026</p>
    </div>
  );
}