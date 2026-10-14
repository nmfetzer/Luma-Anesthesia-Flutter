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

export default function ABAPhysiologyModule() {
  return (
    <div className="space-y-2 pb-4">
      {/* Intro */}
      <div className="p-4 rounded-xl bg-blue-50 border border-blue-100 mb-4">
        <p className="text-sm text-blue-900">This module covers cardiovascular, pulmonary, renal, hepatic, neurologic, and endocrine physiology with emphasis on principles tested on the ABA BASIC examination. Each section pairs the underlying mechanism with the perioperative consequence the anesthesiologist must recognize.</p>
        <KEY_POINT>On the BASIC exam, physiology questions almost always demand a quantitative or directional answer: 'Which way will PaCO2 move?', 'How does this change SVR?', 'What is the relationship between MAP, CO, and SVR?' Master the equations and the curves; the application follows.</KEY_POINT>
      </div>

      {/* 2.1 Cardiovascular */}
      <Section title="2.1 · Cardiovascular Physiology" defaultOpen>
        <p className="font-semibold text-blue-800">Determinants of Cardiac Output</p>
        <p className="text-sm">CO = HR × SV. Stroke volume depends on three determinants:</p>
        <Bullet>Preload — ventricular end-diastolic volume. Approximated by CVP (RV) and PCWP (LV). Frank–Starling: ↑ preload → ↑ SV up to a plateau.</Bullet>
        <Bullet>Afterload — wall tension during ejection. Approximated by SVR (LV) or PVR (RV). ↑ afterload → ↓ SV.</Bullet>
        <Bullet>Contractility — intrinsic force at a given preload. Reflected by ejection fraction and dP/dt.</Bullet>
        <Bullet>Heart rate: tachycardia reduces diastolic filling time → compromises subendocardial perfusion (coronary flow occurs in diastole on the left).</Bullet>
        <KEY_POINT>Coronary perfusion pressure (CPP) = aortic diastolic pressure − LV end-diastolic pressure. Tachycardia, hypotension, and ↑ LVEDP all reduce CPP — key in ischemic heart disease management.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Pressure-Volume Loop</p>
        <p className="text-sm">4 phases: isovolumetric contraction → ejection → isovolumetric relaxation → filling. Area within loop = stroke work. Slope of ESPVR = contractility (load-independent).</p>
        <Table
          headers={['Change', 'PV Loop Effect']}
          rows={[
            ['↑ Preload', 'Loop widens to the right; SV ↑'],
            ['↑ Afterload', 'Peak pressure ↑; SV ↓; loop narrows'],
            ['↑ Contractility', 'ESPVR slope ↑; SV ↑; ESV ↓'],
            ['Aortic stenosis', 'Tall, narrow loop; ↑ peak pressure'],
            ['Aortic regurgitation', 'Loop shifts right; no isovolumetric phase'],
            ['Mitral regurgitation', 'Loss of isovolumetric contraction; loop opens at left'],
          ]}
        />

        <p className="font-semibold text-blue-800 mt-3">Vascular Resistance</p>
        <Bullet>SVR = 80 × (MAP − CVP) / CO. Normal SVR: 800–1200 dyn·s·cm⁻⁵.</Bullet>
        <Bullet>PVR = 80 × (MPAP − PCWP) / CO. Normal PVR: 50–150 dyn·s·cm⁻⁵.</Bullet>
        <Bullet>Pulmonary circulation is low-pressure, high-compliance; PVR ≈ 1/10 SVR.</Bullet>
        <Bullet>HPV diverts blood from poorly ventilated alveoli to better ventilated regions. Volatile anesthetics inhibit HPV → V/Q mismatch.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Baroreceptor & Chemoreceptor Reflexes</p>
        <Bullet>Baroreceptors: carotid sinus (CN IX) and aortic arch (CN X). Stretch → ↑ firing → vagal output + ↓ sympathetic outflow. Blunted by hypertension, aging, diabetes, general anesthetics.</Bullet>
        <Bullet>Peripheral chemoreceptors (carotid + aortic bodies): respond to PaO₂ &lt; 60 mmHg → ↑ ventilation; blunted by even ≤0.1 MAC volatile agent.</Bullet>
        <Bullet>Central chemoreceptors (medulla): respond to CSF [H⁺] driven by PaCO₂ — primary minute ventilation driver in normal physiology.</Bullet>
      </Section>

      {/* 2.2 Pulmonary */}
      <Section title="2.2 · Pulmonary Physiology">
        <p className="font-semibold text-blue-800">Lung Volumes & Capacities</p>
        <Table
          headers={['Volume / Capacity', 'Definition', 'Normal (70 kg adult)']}
          rows={[
            ['Tidal volume (Vt)', 'Volume per normal breath', '~500 mL (6–8 mL/kg IBW)'],
            ['Inspiratory reserve (IRV)', 'Above Vt to max inspiration', '~3000 mL'],
            ['Expiratory reserve (ERV)', 'Below Vt to max expiration', '~1100 mL'],
            ['Residual volume (RV)', 'After max expiration', '~1200 mL'],
            ['Vital capacity (VC)', 'IRV + Vt + ERV', '~4600 mL'],
            ['FRC', 'ERV + RV (volume at end-expiration)', '~2400 mL'],
            ['Total lung capacity (TLC)', 'Sum of all volumes', '~6000 mL'],
            ['Closing capacity (CC)', 'Volume at which small airways close', 'Increases with age & disease'],
          ]}
        />
        <KEY_POINT>FRC ↓ in pregnancy, obesity, supine position, anesthesia, and laparoscopy. When CC &gt; FRC, small airways close during tidal breathing → shunt and hypoxemia. CC &gt; FRC supine at ≈age 44; upright at ≈age 66.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">V/Q Relationships</p>
        <Bullet>Ideal V/Q = 0.8 (V = 4 L/min, Q = 5 L/min).</Bullet>
        <Bullet>V/Q = 0: pure shunt (no ventilation; e.g., atelectasis). Not corrected by 100% O₂.</Bullet>
        <Bullet>V/Q = ∞: dead space (no perfusion; e.g., PE, low CO). Anatomic dead space ≈2 mL/kg.</Bullet>
        <Bullet>Upright lung: apex = high V/Q (dead-space–like); base = low V/Q (shunt-like). Lateral decubitus under GA: dependent lung over-perfused but under-ventilated → worsened V/Q mismatch.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Oxygen Transport</p>
        <Bullet>CaO₂ = (1.34 × Hb × SaO₂) + (0.003 × PaO₂). Dissolved O₂ trivial at room air but meaningful at hyperbaric pressures.</Bullet>
        <Bullet>P50 = PaO₂ at which Hb is 50% saturated = 26.6 mmHg (normal).</Bullet>
        <Bullet>Right shift (↓ affinity): ↑ temperature, ↑ PaCO₂, ↓ pH, ↑ 2,3-DPG, HbS.</Bullet>
        <Bullet>Left shift (↑ affinity): ↓ temperature, ↓ PaCO₂, ↑ pH, ↓ 2,3-DPG; carboxyhemoglobin, methemoglobin, fetal Hb.</Bullet>
        <KEY_POINT>CO poisoning causes a left shift AND blocks O₂ binding — tissue hypoxia despite normal SpO₂ (pulse oximeter cannot distinguish HbCO from HbO₂). Co-oximetry is required for diagnosis.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">CO₂ Transport</p>
        <Bullet>70% as bicarbonate (carbonic anhydrase in RBCs), 23% bound to Hb (carbamino), 7% dissolved. CO₂ is ~20× more soluble and diffusible than O₂.</Bullet>
        <Bullet>Haldane effect: deoxygenated Hb binds more CO₂ — facilitates CO₂ pickup in tissues.</Bullet>
        <Bullet>Bohr effect: ↑ CO₂ / ↓ pH right-shifts the OHDC, facilitating O₂ release in tissues.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Control of Ventilation</p>
        <Bullet>VE = Vt × RR. CO₂ is the primary driver via central chemoreceptors.</Bullet>
        <Bullet>Ventilatory response to CO₂: ~2 L/min per mmHg rise in PaCO₂ above 40 mmHg in awake adults.</Bullet>
        <Bullet>Blunted by opioids, volatile anesthetics, benzodiazepines.</Bullet>
      </Section>

      {/* 2.3 Renal */}
      <Section title="2.3 · Renal Physiology">
        <p className="font-semibold text-blue-800">Renal Blood Flow & GFR</p>
        <Bullet>Kidneys receive ≈20% of CO (~1100 mL/min) for 0.4% body mass.</Bullet>
        <Bullet>GFR ≈ 125 mL/min (180 L/day), 99% reabsorbed.</Bullet>
        <Bullet>Autoregulation: RBF and GFR constant over MAP 60–160 mmHg. Lost in shock, sepsis, NSAID use, and anesthetic-induced hypotension below 60 mmHg.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Nephron Segments — High Yield</p>
        <Table
          headers={['Segment', 'Reabsorbs / Secretes', 'Key Drug Target']}
          rows={[
            ['Proximal tubule', '65% Na⁺, glucose, amino acids, HCO₃⁻', 'Acetazolamide; SGLT-2 inhibitors'],
            ['Thick ascending limb (Loop of Henle)', '25% Na⁺ via Na-K-2Cl; concentration gradient', 'Loop diuretics (furosemide)'],
            ['Distal convoluted tubule', '5–10% Na⁺ via Na-Cl cotransporter', 'Thiazides'],
            ['Collecting duct (principal cell)', 'Na⁺/water (ADH, aldosterone)', 'K-sparing diuretics; vasopressin'],
            ['Collecting duct (α-intercalated)', 'H⁺ secretion, HCO₃⁻ reabsorption', 'Acid-base regulation'],
          ]}
        />

        <p className="font-semibold text-blue-800 mt-3">Sodium & Water Handling</p>
        <Bullet>RAAS: ↓ renal perfusion → renin → angiotensin I → ACE → AT II → ↑ aldosterone → Na⁺/water retention.</Bullet>
        <Bullet>ADH (vasopressin): osmoreceptor-driven; ↑ aquaporin-2 channels in collecting duct → water reabsorption.</Bullet>
        <Bullet>ANP/BNP: released from atrial/ventricular stretch → natriuresis and vasodilation.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Acid-Base</p>
        <p className="text-sm">Henderson-Hasselbalch: pH = 6.1 + log([HCO₃⁻] / 0.03 × PaCO₂). Anion gap = Na⁺ − (Cl⁻ + HCO₃⁻), normal 8–12.</p>
        <Bullet>1. Check pH (acidemia &lt;7.35, alkalemia &gt;7.45).</Bullet>
        <Bullet>2. Identify primary disturbance (PaCO₂ or HCO₃⁻ moves same direction as pH = respiratory; opposite = metabolic).</Bullet>
        <Bullet>3. Calculate compensation (Winter's formula for metabolic acidosis: expected PaCO₂ = 1.5 × HCO₃⁻ + 8 ± 2).</Bullet>
        <Bullet>4. If metabolic acidosis, calculate anion gap → MUDPILES vs HARDUPS.</Bullet>
        <KEY_POINT>MUDPILES (high AG): Methanol, Uremia, DKA, Propylene glycol, INH/Iron, Lactate, Ethylene glycol, Salicylates. HARDUPS (normal AG): Hyperalimentation, Acetazolamide, Renal tubular acidosis, Diarrhea, Ureteroenterostomy, Pancreatic fistula, Saline.</KEY_POINT>
      </Section>

      {/* 2.4 Hepatic */}
      <Section title="2.4 · Hepatic Physiology">
        <p className="font-semibold text-blue-800">Blood Supply</p>
        <Bullet>Dual supply: hepatic artery (~25% flow, 50% O₂) + portal vein (~75% flow, 50% O₂).</Bullet>
        <Bullet>Hepatic Arterial Buffer Response (HABR): ↓ portal flow → reflex ↑ hepatic arterial flow (adenosine-mediated). Lost under volatile anesthesia → increases susceptibility to hepatic ischemia.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Functions</p>
        <Bullet>Synthesis: albumin, all coagulation factors EXCEPT vWF and factor VIII; cholinesterase.</Bullet>
        <Bullet>Metabolism: drug biotransformation (phase I — CYP450; phase II — conjugation); bilirubin conjugation.</Bullet>
        <Bullet>Storage: glycogen, vitamins A/D/B12, iron.</Bullet>
        <Bullet>Immune: Kupffer cells (resident macrophages).</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Drug Metabolism — Hepatic Clearance</p>
        <p className="text-sm">Hepatic clearance = Q × ER (Q = liver blood flow, ER = extraction ratio).</p>
        <Bullet>High-extraction drugs (ER &gt;0.7): propofol, lidocaine, fentanyl, morphine, ketamine, propranolol. Clearance is flow-limited — sensitive to hepatic blood flow.</Bullet>
        <Bullet>Low-extraction drugs (ER &lt;0.3): diazepam, lorazepam, methadone, rocuronium, warfarin. Clearance is capacity-limited — sensitive to enzyme activity and protein binding.</Bullet>
      </Section>

      {/* 2.5 Neurophysiology */}
      <Section title="2.5 · Neurophysiology">
        <p className="font-semibold text-blue-800">Cerebral Blood Flow (CBF)</p>
        <Bullet>Normal CBF: 50 mL/100 g/min (15% of CO). CMRO₂: 3.5 mL/100 g/min.</Bullet>
        <Bullet>Autoregulation: MAP 50–150 mmHg in normal patients (shifted right in chronic hypertension).</Bullet>
        <Bullet>CBF couples to CMRO₂: every 1°C ↓ temperature → 7% ↓ CMRO₂ and CBF.</Bullet>
        <Bullet>PaCO₂: CBF changes ~1–2 mL/100 g/min per mmHg over range 20–80 mmHg. Hyperventilation to PaCO₂ 30 mmHg acutely lowers ICP; effect attenuates over 6–12 hours.</Bullet>
        <Bullet>PaO₂: CBF rises sharply only when PaO₂ &lt; 50 mmHg.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Intracranial Pressure</p>
        <Bullet>Monro-Kellie doctrine: cranium contains brain (80%), blood (12%), CSF (8%). Increase in one must be compensated by decrease in another.</Bullet>
        <Bullet>CPP = MAP − ICP (or CVP, whichever is higher). Target CPP 60–70 mmHg in TBI.</Bullet>
        <KEY_POINT>ICP-lowering strategies: head-up 30°, mild hyperventilation (PaCO₂ 30–35), mannitol or hypertonic saline, EVD drainage, propofol/barbiturate burst suppression, surgical decompression. Avoid: hypotension, hyperthermia, hypoxia, hypercapnia, hyponatremia, head-down position.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">CSF</p>
        <Bullet>Total volume: 150 mL (50% intracranial). Produced ~500 mL/day by choroid plexus.</Bullet>
        <Bullet>Absorbed by arachnoid villi into the dural venous sinuses.</Bullet>
        <Bullet>Acetazolamide reduces CSF production.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Neuromonitoring</p>
        <Table
          headers={['Modality', 'What It Measures', 'Anesthetic Impact']}
          rows={[
            ['EEG', 'Cortical electrical activity', 'Volatiles ↓ activity (burst suppression at 1.5+ MAC); ketamine paradoxically activates'],
            ['BIS / processed EEG', 'Anesthetic depth (0–100)', 'Target 40–60 for general anesthesia'],
            ['SSEP', 'Sensory cortex via dorsal columns', 'Moderately sensitive — keep volatile ≤0.5 MAC; avoid bolus shifts'],
            ['MEP', 'Motor cortex via descending tracts', 'Very sensitive — typically TIVA; no muscle relaxant'],
            ['EMG', 'Specific peripheral nerves', 'Avoid neuromuscular blockade'],
          ]}
        />
      </Section>

      {/* 2.6 Endocrine */}
      <Section title="2.6 · Endocrine Physiology">
        <p className="font-semibold text-blue-800">Stress Response to Surgery</p>
        <p className="text-sm">Surgery activates the HPA axis: CRH → ACTH → cortisol (peaks 4–6 hours post-incision, returns to normal by day 5). Catecholamines surge within minutes.</p>
        <Bullet>Hyperglycemia: cortisol + catecholamines + GH inhibit insulin and increase gluconeogenesis.</Bullet>
        <Bullet>Hypercoagulability: ↑ fibrinogen, ↑ platelet activation, ↓ fibrinolysis — partly explains postoperative thrombosis risk.</Bullet>
        <Bullet>Sodium/water retention: aldosterone and ADH increase.</Bullet>
        <KEY_POINT>Regional anesthesia and high-dose opioid techniques blunt the stress response; volatile anesthesia alone does not. This is one rationale for combined regional/general anesthesia in major surgery.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Glucose Control</p>
        <Bullet>Tight glycemic control (80–110 mg/dL) increases hypoglycemia and mortality (NICE-SUGAR).</Bullet>
        <Bullet>Current target: 140–180 mg/dL in most ICU and perioperative settings.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Thyroid</p>
        <Bullet>T4 → T3 (active) via 5'-deiodinase. Most circulating T3/T4 is protein-bound (TBG).</Bullet>
        <Bullet>Hyperthyroidism: ↑ HR, ↑ CO, ↑ O₂ consumption, ↓ SVR. Avoid stimulants (ketamine, ephedrine, pancuronium). Thyroid storm = emergency: propranolol, PTU, steroid, cooling.</Bullet>
        <Bullet>Hypothyroidism: ↓ HR, ↓ CO, sensitivity to opioids/anesthetics, hyponatremia, hypoglycemia. Myxedema coma: thyroid + hydrocortisone.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Adrenal</p>
        <Bullet>Cortex: glucocorticoids (cortisol, zona fasciculata), mineralocorticoids (aldosterone, zona glomerulosa), androgens (zona reticularis).</Bullet>
        <Bullet>Medulla: catecholamines (epinephrine, norepinephrine — chromaffin cells).</Bullet>
        <Bullet>Pheochromocytoma: catecholamine excess → paroxysmal HTN, headache, palpitations, sweating. Preop α-blockade (phenoxybenzamine) BEFORE β-blockade (avoid unopposed α stimulation).</Bullet>
      </Section>

      <p className="text-[10px] text-muted-foreground text-center pt-2">© CE Halo LLC · ABA BASIC Study Package · Module 2 · Edition 2026</p>
    </div>
  );
}