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

export default function ABASubspecialtyModule() {
  return (
    <div className="space-y-2 pb-4">
      {/* Intro */}
      <div className="p-4 rounded-xl bg-blue-50 border border-blue-100 mb-4">
        <p className="text-sm text-blue-900">Subspecialty content on the BASIC exam tests how the patient's specific physiology — pregnancy, infancy, cardiac disease, intracranial pathology — alters routine anesthetic decisions. Each subspecialty is presented with the physiologic differences first, the anesthetic implications second.</p>
      </div>

      {/* 6.1 Obstetric */}
      <Section title="6.1 · Obstetric Anesthesia" defaultOpen>
        <p className="font-semibold text-blue-800">Maternal Physiologic Changes</p>
        <Table
          headers={['System', 'Change']}
          rows={[
            ['Cardiovascular', '↑ CO 40% (peaks early 3rd trimester, 80% during labor, 100% immediately postpartum), ↓ SVR, ↑ HR 15–20%'],
            ['Pulmonary', '↑ minute ventilation 50%, ↓ FRC 20%, ↑ O₂ consumption 30%, baseline PaCO₂ 30 mmHg (compensated resp alkalosis)'],
            ['Hematologic', '↑ plasma 50%, ↑ RBC mass 30% → physiologic anemia; hypercoagulable (↑ I, VII, VIII, IX, X, XII, fibrinogen)'],
            ['Renal', '↑ GFR 50%, ↓ BUN, ↓ Cr (normal Cr 0.5 may indicate dysfunction)'],
            ['GI', '↓ gastric emptying after labor onset, ↓ LES tone, ↑ aspiration risk — treat ALL as full stomach after 20 weeks'],
            ['CNS', '↓ MAC ~30%; ↓ LA requirement ~30% (epidural vein compression + hormonal sensitivity)'],
          ]}
        />
        <KEY_POINT>Aortocaval compression by the gravid uterus begins around 20 weeks. Place all term parturients with left uterine displacement (15° tilt OR manual displacement during arrest).</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Labor Analgesia</p>
        <Bullet>First stage pain: visceral, T10–L1 (uterus, cervix). Second stage: somatic, S2–S4 (perineum).</Bullet>
        <Bullet>Epidural: low-dose LA + opioid (e.g., bupivacaine 0.0625–0.125% + fentanyl 2 µg/mL) preserves motor function.</Bullet>
        <Bullet>Combined spinal-epidural (CSE): faster onset (spinal component) + flexibility (epidural).</Bullet>
        <Bullet>Avoid: pudendal block (only stage 2); paracervical block (fetal bradycardia).</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Cesarean Anesthesia</p>
        <Bullet>Preferred: neuraxial (spinal for non-emergent, epidural if already placed, CSE for prolonged cases). GA reserved for hemorrhage, fetal distress with no epidural, coagulopathy, refusal.</Bullet>
        <Bullet>Spinal dose: bupivacaine 12 mg + fentanyl 15 µg + morphine 100–200 µg (intrathecal morphine = 18–24 hr analgesia).</Bullet>
        <Bullet>GA induction: pre-oxygenate, RSI, propofol 2 mg/kg + succinylcholine 1.5 mg/kg, sevoflurane 1 MAC (limit volatile &lt;1 MAC — uterine relaxation).</Bullet>
        <KEY_POINT>Failed intubation in obstetrics: incidence ~1:300 (higher than general population due to edema, breast tissue, full dentition, urgency). Awake fiberoptic if predicted difficulty; LMA / supraglottic device + cricoid pressure are accepted rescue.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Obstetric Emergencies</p>
        <Bullet>Pre-eclampsia: HTN ≥ 140/90 after 20 wk + proteinuria/end-organ damage. Severe: BP ≥ 160/110, headache, visual changes, RUQ pain, ↑ LFTs, ↓ platelets, AKI. Treat: magnesium 4–6 g load + 1–2 g/hr; labetalol/hydralazine.</Bullet>
        <Bullet>Eclampsia: seizure on pre-eclampsia background. Magnesium first-line (not benzodiazepines).</Bullet>
        <Bullet>HELLP: Hemolysis, Elevated LFTs, Low Platelets — neuraxial risk if platelets &lt;70–80 × 10⁹/L.</Bullet>
        <Bullet>Amniotic fluid embolism: sudden hypotension, hypoxia, DIC, often cardiac arrest. Supportive care; mortality very high.</Bullet>
        <Bullet>Uterine atony: leading cause of PPH. Oxytocin (slow IV — hypotension if bolus), methylergonovine (avoid in HTN), carboprost/hemabate (avoid in asthma), misoprostol.</Bullet>
      </Section>

      {/* 6.2 Pediatric */}
      <Section title="6.2 · Pediatric Anesthesia">
        <p className="font-semibold text-blue-800">Anatomic / Physiologic Differences</p>
        <Bullet>Airway: large head & tongue, short neck, anterior/cephalad larynx (C3–4 vs C5–6 adult), long floppy epiglottis, narrowest point at cricoid until ~age 8.</Bullet>
        <Bullet>Respiratory: ↑ O₂ consumption (6–8 vs 3–4 mL/kg/min), ↑ closing capacity relative to FRC → rapid desaturation; horizontal ribs, diaphragmatic breathing.</Bullet>
        <Bullet>Cardiovascular: HR-dependent CO (poor SV reserve); parasympathetic dominance → bradycardia with hypoxia, vagal stimuli. Bradycardia in a child = hypoxia until proven otherwise.</Bullet>
        <Bullet>Thermoregulation: high surface area:mass ratio, thin skin, no shivering — depend on non-shivering thermogenesis (brown fat). Active warming mandatory.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Induction & Maintenance</p>
        <Bullet>Inhalation induction (sevoflurane up to 8% in N₂O/O₂) is standard for children &lt;10 unless IV in place.</Bullet>
        <Bullet>ETT size (uncuffed): age/4 + 4. Cuffed: age/4 + 3.5. Modern practice uses microcuff tubes even in infants.</Bullet>
        <Bullet>ETT depth: age/2 + 12 cm (oral), or 3 × ETT internal diameter.</Bullet>
        <Bullet>Succinylcholine: ONLY for emergent airway in children (FDA boxed warning — undiagnosed Duchenne MD → hyperkalemic arrest). Atropine 20 µg/kg before succinylcholine in infants.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Common Pediatric Issues</p>
        <Table
          headers={['Issue', 'Key Point']}
          rows={[
            ['URI within 2–4 weeks', '↑ airway events; postpone elective surgery if fever, productive cough, wheezing, malaise; LMA preferable to ETT if proceeding'],
            ['Laryngospasm', 'Treat: 100% O₂, CPAP, jaw thrust + Larson\'s maneuver; propofol 0.5 mg/kg; succinylcholine 0.1–1 mg/kg IV or 4 mg/kg IM if refractory'],
            ['Croup (post-extubation)', 'Risk: tight ETT, age < 4, traumatic intubation. Treat: humidified O₂, racemic epinephrine, dexamethasone'],
            ['Emergence delirium', 'Sevoflurane (highest), des; preventable with propofol bolus at end, dexmedetomidine, or fentanyl'],
            ['Apnea in former preterm', 'PCA risk if PCA < 60 weeks; observe at least 12 hr postop; consider caffeine'],
          ]}
        />
      </Section>

      {/* 6.3 Cardiac */}
      <Section title="6.3 · Cardiac Anesthesia (BASIC Level)">
        <p className="font-semibold text-blue-800">Ischemic Heart Disease</p>
        <Bullet>Goals: balance O₂ supply (coronary perfusion pressure, diastolic time, Hb, SaO₂) and demand (HR, contractility, wall tension).</Bullet>
        <Bullet>Avoid: tachycardia (↑ demand AND ↓ supply), HTN crisis (↑ wall tension), severe hypotension (↓ supply), anemia.</Bullet>
        <Bullet>β-blockers and statins continued perioperatively if already on them; do NOT initiate immediately before surgery in low-risk patients (POISE — ↑ stroke risk).</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Valvular Disease</p>
        <Table
          headers={['Lesion', 'Hemodynamic Goal']}
          rows={[
            ['Aortic stenosis', 'Maintain sinus rhythm, slow-normal HR, ↑ preload, ↑ SVR (phenylephrine); AVOID tachycardia, vasodilation, spinal anesthesia'],
            ['Aortic regurgitation', "Slightly ↑ HR, ↓ SVR, full preload — 'fast, full, forward'"],
            ['Mitral stenosis', 'Slow HR (longer diastole for LA emptying), maintain preload, avoid PVR ↑'],
            ['Mitral regurgitation', '↑ HR (slightly), ↓ SVR (forward flow), avoid bradycardia and ↑ SVR'],
            ['HOCM', 'Slow HR, ↑ preload, ↑ SVR — opposite of vasodilator therapy in CHF; avoid inotropes'],
          ]}
        />
        <KEY_POINT>Aortic stenosis severity by valve area: mild &gt;1.5, moderate 1.0–1.5, severe &lt;1.0, critical &lt;0.7 cm². Severe AS is the highest-risk non-cardiac surgery valve lesion; bridging hemodynamics with phenylephrine is essential during induction.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Cardiac Tamponade</p>
        <p className="text-sm">Beck's triad: hypotension, ↑ JVP, muffled heart sounds. Echo confirms. Anesthetic principle: 'fast, full, tight' — maintain HR, preload, SVR; avoid positive pressure ventilation until pericardiocentesis (or have surgeon ready to open).</p>

        <p className="font-semibold text-blue-800 mt-3">Pacemakers & ICDs</p>
        <Bullet>Electromagnetic interference (monopolar Bovie above umbilicus) can inhibit pacing or trigger ICD shock.</Bullet>
        <Bullet>Magnet over a pacemaker → asynchronous pacing (most models). Magnet over an ICD → suspends tachy-therapy but does NOT change pacing mode.</Bullet>
        <Bullet>Confirm with device interrogation preoperatively.</Bullet>
      </Section>

      {/* 6.4 Neuroanesthesia */}
      <Section title="6.4 · Neuroanesthesia">
        <p className="font-semibold text-blue-800">Goals</p>
        <Bullet>Maintain CPP (target 60–70 mmHg in TBI), control ICP (&lt;20–22 mmHg), preserve autoregulation.</Bullet>
        <Bullet>Avoid the 6 H's: hypoxia, hypercapnia, hypotension, hyperthermia, hypoglycemia, hyponatremia.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Effects of Anesthetic Drugs on CBF/ICP</p>
        <Table
          headers={['Drug', 'CBF', 'CMRO₂', 'ICP']}
          rows={[
            ['Volatiles', '↑ (>1 MAC)', '↓', '↑'],
            ['N₂O', '↑', '↑ or ↔', '↑'],
            ['Propofol', '↓', '↓', '↓'],
            ['Thiopental', '↓', '↓ (↓ 50%)', '↓'],
            ['Etomidate', '↓', '↓', '↓'],
            ['Ketamine', '↑ (controversial — may be normal with controlled vent)', '↑', '↑ (traditional; debated)'],
            ['Opioids', '↔ or ↓', '↔ or ↓', '↔'],
          ]}
        />

        <p className="font-semibold text-blue-800 mt-3">Specific Procedures</p>
        <Bullet>Craniotomy: avoid N₂O if pneumocephalus possible; TIVA if MEPs monitored; smooth emergence to prevent hypertensive bleeding.</Bullet>
        <Bullet>Sitting craniotomy: VAE risk up to 40%. Monitor: precordial Doppler, ETCO₂ drop, ETN₂ rise. Treatment: flood field with saline, jugular compression, Trendelenburg + left lateral, aspirate from CVL at SVC/RA junction.</Bullet>
        <Bullet>Awake craniotomy: asleep-awake-asleep technique; propofol + remifentanil + dexmedetomidine; scalp block essential.</Bullet>
        <Bullet>Aneurysm clipping: tight BP control, induced hypotension for clip application, mannitol/hypertonic saline for brain relaxation.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Spinal Cord & SCI</p>
        <Bullet>Spinal shock: flaccid paralysis, areflexia, hypotension, bradycardia — lasts days–weeks.</Bullet>
        <Bullet>Autonomic dysreflexia: lesion above T6; noxious stimulus below → unopposed sympathetic outflow → severe HTN, bradycardia, headache, sweating. Treat: remove stimulus, head-up position, short-acting vasodilator (nitroglycerin, nicardipine).</Bullet>
        <Bullet>Avoid succinylcholine after 24 hr post-SCI through 6 months (extrajunctional ACh receptors → hyperkalemia).</Bullet>
      </Section>

      {/* 6.5 Regional Subspecialty */}
      <Section title="6.5 · Regional Anesthesia (Subspecialty Considerations)">
        <p className="font-semibold text-blue-800">Ultrasound Principles</p>
        <Bullet>Linear high-frequency probe (10–15 MHz): best for superficial structures (brachial plexus, femoral).</Bullet>
        <Bullet>Curvilinear low-frequency probe (2–5 MHz): deeper structures (lumbar plexus, neuraxial).</Bullet>
        <Bullet>Hyperechoic = bright (bone, fascia, needle). Hypoechoic = dark (vessels, nerves).</Bullet>
        <Bullet>Doppler distinguishes artery (pulsatile, non-compressible) from vein (compressible, augments with maneuver).</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Adjuvants</p>
        <Bullet>Epinephrine 1:200,000–1:400,000: prolongs duration, ↓ peak plasma LA, marker for intravascular injection.</Bullet>
        <Bullet>Dexamethasone 4–8 mg perineural (off-label): prolongs block duration 1.5–2×; IV systemic dexamethasone has nearly equivalent effect.</Bullet>
        <Bullet>Bicarbonate: speeds onset of intermediate-pKa LAs (lidocaine, mepivacaine) — clinical benefit modest.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Specific Blocks — Pearls & Pitfalls</p>
        <Table
          headers={['Block', 'Pearl / Pitfall']}
          rows={[
            ['Interscalene', '100% ipsilateral phrenic palsy; avoid in severe pulmonary disease; covers shoulder + lateral arm'],
            ['Supraclavicular', "'Spinal of the arm' — covers entire arm; risk of pneumothorax"],
            ['Axillary', 'Spares musculocutaneous (block in coracobrachialis); useful for forearm/hand below elbow'],
            ['TAP block', 'Analgesia for somatic abdominal pain (T10–L1); does NOT cover visceral pain'],
            ['Erector spinae plane (ESP)', 'Covers thoracic somatic pain; thoracic and abdominal applications'],
            ['Adductor canal', 'Saphenous + obturator branches; preserves quadriceps (vs femoral)'],
            ['Popliteal sciatic', 'Block at 5–8 cm above popliteal crease; covers leg/foot except medial (saphenous)'],
            ['Ankle block', '5 nerves (deep peroneal, superficial peroneal, tibial, sural, saphenous); no epinephrine in foot'],
          ]}
        />
      </Section>

      <p className="text-[10px] text-muted-foreground text-center pt-2">© CE Halo LLC · ABA BASIC Study Package · Module 6 · Edition 2026</p>
    </div>
  );
}