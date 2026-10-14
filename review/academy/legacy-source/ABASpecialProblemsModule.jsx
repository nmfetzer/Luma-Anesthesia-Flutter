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

export default function ABASpecialProblemsModule() {
  return (
    <div className="space-y-2 pb-4">
      {/* Intro */}
      <div className="p-4 rounded-xl bg-blue-50 border border-blue-100 mb-4">
        <p className="text-sm text-blue-900">This module covers trauma, critical care, pain medicine, geriatrics, obesity, and the rare-but-critical perioperative emergencies (malignant hyperthermia, anaphylaxis, awareness) the ABA expects every graduate to handle reflexively.</p>
        <KEY_POINT>Most special-problem questions are recognition + immediate management. Memorize the protocols: MH dantrolene, anaphylaxis epinephrine, LAST lipid emulsion. The exam rewards the practitioner who acts on diagnosis, not the one who waits for confirmation.</KEY_POINT>
      </div>

      {/* 7.1 MH */}
      <Section title="7.1 · Malignant Hyperthermia" defaultOpen>
        <p className="font-semibold text-blue-800">Pathophysiology</p>
        <p className="text-sm">Autosomal dominant defect in the ryanodine receptor (RYR1, sometimes CACNA1S) → uncontrolled Ca²⁺ release from sarcoplasmic reticulum → sustained muscle contraction → hypermetabolism.</p>
        <Bullet>Triggers: ALL volatile anesthetics, succinylcholine.</Bullet>
        <Bullet>SAFE: propofol, etomidate, ketamine, opioids, benzodiazepines, N₂O, all non-depolarizing NMBs, local anesthetics.</Bullet>
        <Bullet>Associated myopathies: King-Denborough, central core disease, multi-minicore disease. NOT increased risk: Duchenne MD (but trigger-related rhabdomyolysis is a separate concern).</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Presentation</p>
        <Bullet>EARLIEST sign: unexplained ↑ ETCO₂ unresponsive to ↑ minute ventilation.</Bullet>
        <Bullet>Tachycardia (also early, non-specific).</Bullet>
        <Bullet>Masseter spasm after succinylcholine (50% become MH-positive).</Bullet>
        <Bullet>Hyperthermia is a LATE sign (can be 1–2°C/hr rise). Mixed metabolic + respiratory acidosis.</Bullet>
        <Bullet>Hyperkalemia, hyperphosphatemia, ↑ CK (&gt;10,000), myoglobinuria, DIC late.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Treatment (MHAUS Protocol)</p>
        <Bullet>1. STOP trigger; switch to non-trigger circuit (activated charcoal filters; new machine if available).</Bullet>
        <Bullet>2. Hyperventilate with 100% O₂, ≥10 L/min.</Bullet>
        <Bullet>3. Dantrolene 2.5 mg/kg IV bolus, repeat every 5–10 min until stable; up to 10 mg/kg. Ryanodex (250 mg/5 mL) is faster to mix.</Bullet>
        <Bullet>4. Cool: cold IV saline 2 L, gastric/bladder lavage, surface cooling. STOP at 38°C to avoid overshoot hypothermia.</Bullet>
        <Bullet>5. Treat hyperkalemia (calcium, insulin/dextrose, bicarbonate).</Bullet>
        <Bullet>6. Treat arrhythmias (avoid calcium channel blockers with dantrolene — hyperkalemia, CV collapse).</Bullet>
        <Bullet>7. ICU monitoring for ≥24 hr (15% recrudescence).</Bullet>
        <Bullet>8. MHAUS Hotline: 1-800-MH-HYPER (1-800-644-9737).</Bullet>
        <KEY_POINT>Dantrolene works by binding the RYR1 receptor and preventing further Ca²⁺ release. Original-formulation dantrolene reconstitutes with 60 mL sterile water; Ryanodex (250 mg) reconstitutes in 5 mL — significantly faster in a crisis.</KEY_POINT>
      </Section>

      {/* 7.2 Anaphylaxis */}
      <Section title="7.2 · Perioperative Anaphylaxis">
        <p className="font-semibold text-blue-800">Common Culprits</p>
        <Bullet>Neuromuscular blocking agents (rocuronium, succinylcholine, atracurium) — most common in many series.</Bullet>
        <Bullet>Antibiotics (cefazolin, vancomycin — 'red man' is histamine release, NOT true anaphylaxis).</Bullet>
        <Bullet>Latex (declining as latex-free becomes standard). Chlorhexidine. Colloids (gelatins &gt; dextrans &gt; albumin).</Bullet>
        <Bullet>Local anesthetics — true allergy is RARE; usually preservative (methylparaben) or epinephrine effect.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Grades (Ring & Messmer)</p>
        <Bullet>I: cutaneous only (flushing, urticaria).</Bullet>
        <Bullet>II: moderate — hypotension, tachycardia, bronchospasm.</Bullet>
        <Bullet>III: severe — shock, severe bronchospasm, GI symptoms.</Bullet>
        <Bullet>IV: cardiac arrest.</Bullet>

        <KEY_POINT>EPINEPHRINE IS FIRST-LINE. Dose: 10–100 µg IV bolus for Grade II; 100–500 µg or 1 mg IV for Grade III/IV; infusion 0.05–0.5 µg/kg/min for ongoing instability. IM 0.3–0.5 mg if no IV access. NEVER substitute antihistamines or steroids — they are adjuncts only.</KEY_POINT>
        <Bullet>Stop trigger. 100% O₂; secure airway if airway involvement. Fluids — large volumes (massive capillary leak).</Bullet>
        <Bullet>Adjuncts: H1 (diphenhydramine 50 mg) + H2 (famotidine 20 mg), hydrocortisone 100–200 mg.</Bullet>
        <Bullet>β-blocked patients refractory to epinephrine: glucagon 1–2 mg IV.</Bullet>
        <Bullet>Post-event: serum tryptase (peaks 60–120 min, draw at 1, 2, and 24 hr); refer to allergist for skin testing in 4–6 weeks.</Bullet>
      </Section>

      {/* 7.3 Awareness */}
      <Section title="7.3 · Intraoperative Awareness">
        <p className="font-semibold text-blue-800">Incidence & Risk Factors</p>
        <Bullet>0.1–0.2% of general anesthetics (higher with TIVA, cardiac, OB GA, trauma; lower with volatile + processed EEG).</Bullet>
        <Bullet>Risk factors: female, younger, obesity, opioid/alcohol/benzodiazepine tolerance, history of awareness, difficult intubation, light anesthesia (low MAC), TIVA without depth monitoring, NMB use.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Prevention</p>
        <Bullet>Ensure adequate anesthetic delivery: ETAG ≥ 0.7 MAC age-adjusted, or processed EEG (BIS 40–60).</Bullet>
        <Bullet>Check vaporizer dial, fresh gas flow, breathing circuit integrity at start of every case.</Bullet>
        <Bullet>Consider scopolamine, midazolam premedication for high-risk patients.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Postoperative Management</p>
        <Bullet>Visit and validate the patient's experience.</Bullet>
        <Bullet>Document carefully; offer psychological/PTSD support — 30% develop PTSD.</Bullet>
        <Bullet>Report to ASA Anesthesia Awareness Registry.</Bullet>
      </Section>

      {/* 7.4 Electrolytes */}
      <Section title="7.4 · Acid-Base & Electrolyte Emergencies">
        <p className="font-semibold text-blue-800">Hyperkalemia</p>
        <Bullet>ECG: peaked T waves → loss of P → widened QRS → sine wave → asystole.</Bullet>
        <Bullet>Membrane stabilization: calcium gluconate 1–2 g (or CaCl₂ 1 g) IV — onset 1–3 min.</Bullet>
        <Bullet>Intracellular shift: insulin 10 U + dextrose 25 g; β2 agonist (albuterol 10–20 mg neb); bicarbonate (only if acidemic).</Bullet>
        <Bullet>Elimination: loop diuretic, dialysis, K-binders.</Bullet>
        <KEY_POINT>In rhabdomyolysis or trauma with crush, the K⁺ load is ongoing — temporizing measures will fail without dialysis or surgical decompression.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Hyponatremia</p>
        <Bullet>Acute symptomatic (&lt;24 hr) or seizures: 3% saline 100 mL bolus, up to 3 doses; goal raise 4–6 mEq/L.</Bullet>
        <Bullet>Chronic: correct slowly — &lt;8–10 mEq/L per 24 hr — to avoid osmotic demyelination.</Bullet>
        <Bullet>TURP syndrome: dilutional hyponatremia from glycine absorption — confusion, visual disturbance, seizure.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Hypocalcemia</p>
        <Bullet>Causes: massive transfusion (citrate chelation), pancreatitis, post-thyroidectomy.</Bullet>
        <Bullet>Findings: Chvostek's, Trousseau's, prolonged QT, tetany.</Bullet>
        <Bullet>Treat: calcium gluconate 1–2 g IV (peripheral OK) or CaCl₂ via central line (more elemental Ca).</Bullet>
      </Section>

      {/* 7.5 Geriatric */}
      <Section title="7.5 · Geriatric Anesthesia">
        <p className="font-semibold text-blue-800">Physiologic Changes with Aging</p>
        <Bullet>CV: ↓ β-receptor sensitivity, ↑ SVR, diastolic dysfunction, ↑ atrial fibrillation.</Bullet>
        <Bullet>Pulm: ↓ FEV1, ↓ vital capacity, ↑ closing capacity (closing capacity &gt; FRC supine by age 44).</Bullet>
        <Bullet>CNS: ↓ MAC ~6% per decade after 40; ↓ brain mass; ↑ susceptibility to delirium.</Bullet>
        <Bullet>Renal: ↓ GFR (~1 mL/min/yr after 30); creatinine may be normal despite low GFR (↓ muscle mass).</Bullet>
        <Bullet>Body composition: ↓ lean mass, ↑ fat → ↑ Vd lipophilic drugs (longer effect).</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Drug Adjustments</p>
        <Bullet>Reduce induction doses 25–50%. Titrate slowly — circulation time prolonged.</Bullet>
        <Bullet>Avoid: benzodiazepines (delirium), meperidine (normeperidine accumulation), anticholinergics.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Postoperative Cognitive Dysfunction (POCD)</p>
        <Bullet>Incidence: 25% at 1 week, 10% at 3 months in elderly major surgery.</Bullet>
        <Bullet>Prevention: minimize benzodiazepines/anticholinergics, regional anesthesia where feasible, dexmedetomidine, multimodal analgesia.</Bullet>
      </Section>

      {/* 7.6 Obesity & OSA */}
      <Section title="7.6 · Obesity & OSA">
        <p className="font-semibold text-blue-800">Physiologic Effects of Obesity</p>
        <Bullet>Respiratory: ↓ FRC, ↓ ERV, ↑ work of breathing, ↑ atelectasis, ↑ V/Q mismatch.</Bullet>
        <Bullet>CV: ↑ blood volume, ↑ CO, LVH, ↑ rate of CAD, OSA-driven pulmonary HTN and right heart strain.</Bullet>
        <Bullet>GI: ↑ gastric volume, ↑ acidic gastric pH, ↑ hiatal hernia → ↑ aspiration risk.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Anesthetic Implications</p>
        <Bullet>Difficult mask ventilation (MOANS), difficult intubation, difficult IV/arterial access.</Bullet>
        <Bullet>Position: 'ramp' to align external auditory meatus with sternal notch — improves laryngoscopy.</Bullet>
        <Bullet>Pre-oxygenate with head up + CPAP/PEEP for 3 min — extends apnea time. Reverse Trendelenburg during induction.</Bullet>
        <Bullet>Drug dosing: propofol induction by LBW/TBW; maintenance by IBW; succinylcholine by TBW; rocuronium by IBW; sugammadex by TBW; fentanyl/sufentanil by LBW.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">OSA (STOP-BANG ≥ 3)</p>
        <Bullet>Pre-op CPAP if already prescribed; bring device to PACU.</Bullet>
        <Bullet>Minimize sedatives; use multimodal analgesia.</Bullet>
        <Bullet>Postop: continuous SpO₂; supplemental O₂ caution (may mask hypoventilation); admit if severe OSA.</Bullet>
      </Section>

      {/* 7.7 Trauma */}
      <Section title="7.7 · Trauma & Resuscitation">
        <p className="font-semibold text-blue-800">Primary Survey (ATLS)</p>
        <Bullet>A: Airway with C-spine precautions. B: Breathing — bilateral breath sounds, decompression of pneumothorax.</Bullet>
        <Bullet>C: Circulation — control hemorrhage, 2 large-bore IV, type and cross. D: Disability — GCS, pupils. E: Exposure — full undress, prevent hypothermia.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Damage Control Resuscitation</p>
        <Bullet>Permissive hypotension (SBP 80–90) until surgical control — except TBI (maintain CPP).</Bullet>
        <Bullet>Massive transfusion 1:1:1 PRBC : FFP : platelets.</Bullet>
        <Bullet>Tranexamic acid (TXA) 1 g over 10 min + 1 g over 8 hr if within 3 hr of injury (CRASH-2).</Bullet>
        <Bullet>Avoid the lethal triad: hypothermia, acidosis, coagulopathy.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Cervical Spine</p>
        <Bullet>Assume injury until cleared. Manual in-line stabilization (MILS) during intubation.</Bullet>
        <Bullet>Video laryngoscopy preferred — less neck movement. Cricoid pressure may impair view; release if needed.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Burns</p>
        <Bullet>Parkland formula: 4 mL/kg × % TBSA in 24 hr (half in first 8 hr); lactated Ringer's.</Bullet>
        <Bullet>Smoke inhalation: 100% O₂, bronchoscopy, hydroxocobalamin for cyanide.</Bullet>
        <Bullet>Succinylcholine: SAFE in first 24 hr; AVOID 24 hr–6 months (upregulated extrajunctional ACh receptors → hyperkalemic arrest).</Bullet>
      </Section>

      {/* 7.8 Pain */}
      <Section title="7.8 · Acute & Chronic Pain">
        <p className="font-semibold text-blue-800">Pain Classification</p>
        <Bullet>Nociceptive: somatic (well-localized, sharp) vs visceral (poorly localized, crampy/referred).</Bullet>
        <Bullet>Neuropathic: nerve injury — burning, lancinating, allodynia, hyperalgesia.</Bullet>
        <Bullet>Mixed: cancer pain, complex regional pain syndrome.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Multimodal Analgesia</p>
        <Bullet>Acetaminophen: 1 g q6h (max 4 g/day; less in liver disease). NSAIDs: ketorolac 15–30 mg IV q6h (max 5 days).</Bullet>
        <Bullet>Gabapentinoids: gabapentin 300 mg × 1 preop reduces opioid use but ↑ sedation; weigh in elderly.</Bullet>
        <Bullet>Ketamine: subdissociative infusion 0.1–0.5 mg/kg/hr — opioid-sparing, NMDA antagonism.</Bullet>
        <Bullet>Lidocaine infusion: 1–2 mg/kg/hr for abdominal surgery. Dexamethasone 4–8 mg single dose: analgesia + PONV prevention.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">PCA</p>
        <Table
          headers={['Drug', 'Dose', 'Notes']}
          rows={[
            ['Hydromorphone', '0.2 mg q6 min, no basal in opioid-naive', 'Standard first-line'],
            ['Morphine', '1 mg q6 min', 'Avoid in renal failure (M6G accumulation)'],
            ['Fentanyl', '20–40 µg q6 min', 'Short t½; useful when GI dysfunction limits oral access'],
          ]}
        />

        <p className="font-semibold text-blue-800 mt-3">Chronic Opioid Patients</p>
        <Bullet>Continue baseline opioid (or rotate equivalent). Expect ↑ analgesic requirement (1.5–3×).</Bullet>
        <Bullet>Buprenorphine: now generally continued through surgery per recent ASA/ASRA guidance (do NOT discontinue 3+ days as previously recommended).</Bullet>
        <Bullet>Methadone: continue maintenance dose; check QT preop.</Bullet>
      </Section>

      <p className="text-[10px] text-muted-foreground text-center pt-2">© CE Halo LLC · ABA BASIC Study Package · Module 7 · Edition 2026</p>
    </div>
  );
}