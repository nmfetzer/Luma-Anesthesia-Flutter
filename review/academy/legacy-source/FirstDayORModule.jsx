import { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';

const Section = ({ number, title, children }) => {
  const [open, setOpen] = useState(false);
  return (
    <div className="rounded-xl border border-border overflow-hidden">
      <button
        onClick={() => setOpen(o => !o)}
        className="w-full flex items-center gap-3 p-4 text-left bg-card hover:bg-accent/30 transition-colors"
      >
        <div className="w-7 h-7 rounded-lg bg-amber-700 flex items-center justify-center shrink-0 text-white font-bold text-sm">{number}</div>
        <span className="font-semibold text-sm text-foreground flex-1">{title}</span>
        {open ? <ChevronUp className="w-4 h-4 text-muted-foreground shrink-0" /> : <ChevronDown className="w-4 h-4 text-muted-foreground shrink-0" />}
      </button>
      {open && <div className="px-4 pb-4 pt-2 bg-background/60 text-sm text-foreground space-y-3">{children}</div>}
    </div>
  );
};

const Sub = ({ title, children }) => (
  <div className="mt-3">
    <p className="text-xs font-bold text-amber-700 uppercase tracking-wide mb-1.5">{title}</p>
    {children}
  </div>
);

const Bullets = ({ items }) => (
  <ul className="space-y-1.5">
    {items.map((item, i) => (
      <li key={i} className="flex items-start gap-2 text-sm">
        <span className="text-amber-600 mt-0.5 shrink-0">◆</span>
        <span>{item}</span>
      </li>
    ))}
  </ul>
);

const Numbered = ({ items }) => (
  <ol className="space-y-1.5">
    {items.map((item, i) => (
      <li key={i} className="flex items-start gap-2 text-sm">
        <span className="text-amber-700 font-bold shrink-0 w-4">{i + 1}.</span>
        <span>{item}</span>
      </li>
    ))}
  </ol>
);

const Table = ({ headers, rows }) => (
  <div className="overflow-x-auto rounded-lg border border-border">
    <table className="w-full text-xs">
      <thead className="bg-amber-900 text-white">
        <tr>{headers.map((h, i) => <th key={i} className="px-3 py-2 text-left font-semibold">{h}</th>)}</tr>
      </thead>
      <tbody className="divide-y divide-border">
        {rows.map((row, i) => (
          <tr key={i} className={i % 2 === 0 ? 'bg-card' : 'bg-amber-50/30 dark:bg-amber-900/10'}>
            {row.map((cell, j) => <td key={j} className="px-3 py-2">{cell}</td>)}
          </tr>
        ))}
      </tbody>
    </table>
  </div>
);

const CalloutBox = ({ children, color = 'amber' }) => {
  const styles = {
    amber: 'bg-amber-50 dark:bg-amber-900/20 border-l-4 border-amber-600',
    red: 'bg-red-50 dark:bg-red-900/20 border-l-4 border-red-600',
    blue: 'bg-blue-50 dark:bg-blue-900/20 border-l-4 border-blue-600',
  };
  return (
    <div className={`p-3 ${styles[color]} rounded-r-lg text-sm text-foreground`}>
      {children}
    </div>
  );
};

const CheckList = ({ items }) => (
  <ul className="space-y-1.5">
    {items.map((item, i) => (
      <li key={i} className="flex items-start gap-2 text-sm">
        <span className="text-muted-foreground shrink-0 mt-0.5">☐</span>
        <span>{item}</span>
      </li>
    ))}
  </ul>
);

const CrisisCard = ({ color, title, children }) => {
  const borderColor = color === 'red' ? 'border-red-500' : color === 'orange' ? 'border-orange-500' : color === 'yellow' ? 'border-yellow-500' : 'border-blue-500';
  const bgColor = color === 'red' ? 'bg-red-50 dark:bg-red-900/20' : color === 'orange' ? 'bg-orange-50 dark:bg-orange-900/20' : color === 'yellow' ? 'bg-yellow-50 dark:bg-yellow-900/20' : 'bg-blue-50 dark:bg-blue-900/20';
  const textColor = color === 'red' ? 'text-red-800 dark:text-red-300' : color === 'orange' ? 'text-orange-800 dark:text-orange-300' : color === 'yellow' ? 'text-yellow-800 dark:text-yellow-300' : 'text-blue-800 dark:text-blue-300';
  return (
    <div className={`p-3.5 rounded-xl border-l-4 ${borderColor} ${bgColor}`}>
      <p className={`text-xs font-bold uppercase tracking-wide mb-2 ${textColor}`}>■ {title}</p>
      <div className="text-sm text-foreground space-y-1.5">{children}</div>
    </div>
  );
};

export default function FirstDayORModule() {
  return (
    <div className="space-y-3">
      {/* Header */}
      <div className="p-4 rounded-2xl bg-gradient-to-br from-amber-900 to-amber-800 text-white shadow-md">
        <p className="text-xs font-semibold text-amber-300 uppercase tracking-widest mb-1">CE Halo LLC · Clinical Onboarding</p>
        <h2 className="font-bold text-lg leading-tight">The First Days in the OR</h2>
        <p className="text-amber-200 text-sm mt-1">For New SRNA Students &amp; Anesthesia Residents</p>
        <div className="mt-3 p-2.5 bg-card/10 rounded-xl text-xs text-amber-100 leading-relaxed">
          Work through Sections 1–3 the night before and morning of your first day. Use Sections 4–6 as your daily room-setup and machine-check reference. Section 7 covers emergency medications. Sections 8–10 are the pages you return to every shift.
        </div>
      </div>

      {/* Section 1 */}
      <Section number="1" title="Before Your First Clinical Day">
        <p className="text-sm text-muted-foreground">Preparation the night before lowers your anxiety more than anything else. Preceptors expect nervousness — what they don't forgive is showing up unprepared.</p>
        <Sub title="The night before">
          <Bullets items={[
            'Look up your cases and patients. Review the surgical schedule, procedure, expected position, and anticipated blood loss.',
            'Build your care plan — induction, maintenance, airway management, lines/monitors, and emergence, including a backup airway plan (DAS Plan A/B/C/D).',
            'Review patient history: allergies, NPO status, airway exam (Mallampati, thyromental distance, mouth opening, neck mobility, dentition), comorbidities, meds, labs, and prior anesthetic records.',
            'Confirm logistics: report time, parking, where to change into scrubs, badge/access, preceptor name, and where to meet.',
            'Sleep and eat — you may not get a break for hours.',
          ]} />
        </Sub>
        <Sub title="What to bring">
          <Bullets items={[
            'Stethoscope, trauma shears, pen light, tape, and a black pen (or two).',
            'A pocket reference of emergency drug doses and your school\'s care-plan template.',
            'Watch with a second hand. Snacks/water for when you finally get a break.',
            'A small notebook to write down where things are kept in this room and this facility.',
          ]} />
        </Sub>
        <Sub title="What to wear / professionalism">
          <Bullets items={[
            'Facility scrubs, a bouffant/surgical cap, clean shoes you can stand in all day, and your ID badge visible.',
            '"On time" in anesthesia means early enough to have the room fully set up and checked before the patient arrives.',
            'Follow the AANA Code of Ethics and your program\'s professional conduct policy at all times.',
          ]} />
        </Sub>
      </Section>

      {/* Section 2 */}
      <Section number="2" title="The Morning Routine">
        <p className="text-sm text-muted-foreground mb-2">A reliable sequence for every morning, before the first patient:</p>
        <Numbered items={[
          'Arrive early — enough time to set up and run a full machine check without rushing.',
          'Get the room ready — turn on the anesthesia machine and monitors so self-tests can run while you set up.',
          'Run the full anesthesia machine checkout (Section 6).',
          'Set up the room using SOAP-ME (Section 4) and the full supply checklist (Section 5).',
          'Draw up and label your drugs (Section 7).',
          'Locate emergency equipment for this room and OR suite (Section 9).',
          'Review the chart, confirm consent, NPO status, allergies, and last-minute changes.',
          'Talk to your preceptor about the plan, and talk to the surgeon about positioning, blood products, and the type of anesthesia planned.',
          'Participate in the surgical Time Out / sign-in per WHO Surgical Safety Checklist principles.',
        ]} />
      </Section>

      {/* Section 3 */}
      <Section number="3" title="The Professional Mindset: How to Show Up">
        <Bullets items={[
          'It is OK to be nervous — preceptors know. What matters is preparation and a willingness to learn.',
          'Ask for help early and often. Every machine and facility is different; asking "where is X kept?" is expected, not a weakness.',
          'Closed-loop communication: repeat back orders and drug doses. Confirm before you give anything.',
          'Never give a drug you didn\'t draw up and label yourself, and never give a drug you can\'t see the label on.',
          'Stay at the head of the bed. Your patient\'s airway and vitals are your responsibility every second.',
          'Own your mistakes immediately. Speak up about near-misses. Patient safety always outranks ego.',
          'Anticipate — think one step ahead: what does the patient, surgeon, or preceptor need next?',
          'Practice deliberate self-care and peer support. SRNA burnout, anxiety, and sleep disruption are documented across the profession; use your program\'s wellness resources.',
        ]} />
      </Section>

      {/* Section 4 */}
      <Section number="4" title="Setting Up a Basic OR (SOAP-ME)">
        <CalloutBox>The classic memory aid for room setup is <strong>S-O-A-P-M-E</strong>. Set up and confirm each category <strong>before every case</strong>.</CalloutBox>
        <div className="mt-3">
          <Table
            headers={['Letter', 'Category', 'What to have ready']}
            rows={[
              ['S', 'Suction', 'Suction on, tubing connected, Yankauer attached, tested and within reach at the head of the bed. Mandatory pre-anesthesia checkout item per ASA/APSF.'],
              ['O', 'Oxygen', 'Pipeline O₂ connected (≥50 psig), backup O₂ cylinder checked (>1,500 psig / at least half full), and a self-inflating manual ventilation device (Ambu bag) at the head of the bed.'],
              ['A', 'Airway', 'Correctly sized ETTs (+one size above and below), laryngoscope handle + blades (check the light), stylet, cuff syringe, oral/nasal airways, tongue depressor, LMAs, tape, backup device. Confirm the GlideScope location. Have a Plan B and C.'],
              ['P', 'Pharmacy', 'Induction agents, paralytics, reversal, emergency drugs, and maintenance/infusions — all drawn up, labeled, and within reach.'],
              ['M', 'Monitors', 'ASA standard monitors: pulse oximeter, ECG, NIBP cuff (correct size), capnography (EtCO₂), temperature probe, agent analysis. Set and confirm alarm limits.'],
              ['E', 'Equipment', 'Machine checked, IV setup and fluids, warming devices, positioning aids, and case-specific equipment (A-line setup, fluid warmer, pressure bags, TOF monitor).'],
            ]}
          />
        </div>
        <div className="mt-3 p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 rounded-xl text-xs text-red-800 dark:text-red-200">
          <strong>Essential "never skip" items on every case:</strong> Manual ventilation device · Full machine checkout · Adequate suction · Emergency airway devices (ETT, LMA) · Emergency drugs · A working IV · ASA standard monitors · Quantitative TOF
        </div>
      </Section>

      {/* Section 5 */}
      <Section number="5" title="Complete Equipment & Supply Checklist">
        <Sub title="Airway equipment">
          <CheckList items={[
            'Correct-size endotracheal tubes (ETT) — plus one size larger and one smaller (typical adult: women 7.0–7.5; men 7.5–8.0)',
            'Laryngoscope — handle with working light + Mac and Miller blades (correct size); a backup handle',
            'Stylet, 10 mL syringe (cuff inflation), tube tie/tape',
            'Oral airways (multiple sizes) and nasal airways',
            'Tongue depressor',
            'LMAs (correct size + backup), bite block',
            'Mask (correct size) and self-inflating manual ventilation bag (Ambu)',
            'Video laryngoscope (GlideScope/C-MAC) charged with clean blade; bougie readily available',
          ]} />
        </Sub>
        <Sub title="Monitoring">
          <CheckList items={[
            'EKG stickers / electrodes',
            'Pulse oximeter probe',
            'NIBP cuff — correct size for the patient',
            'Temperature probe',
            'EtCO₂ / capnography sampling line and gas analyzer',
            'Nerve stimulator (train-of-four) if neuromuscular blockade planned — required to confirm ≥0.9 TOF ratio before extubation per ASA 2023 guidance',
          ]} />
        </Sub>
        <Sub title="IV & Fluids">
          <CheckList items={[
            'IV start kit (angiocaths in several gauges, tourniquet, prep, tape, tegaderm)',
            'IV tubing + extension sets, stopcocks',
            'IV pole',
            'Extra IV fluid (crystalloid bags)',
            'Fluid warmer (set up if significant fluid/blood anticipated)',
            'Pressure bags — if an arterial line is anticipated, or for rapid infusion',
            'A-line setup (transducer, tubing, flush) if invasive monitoring planned',
          ]} />
        </Sub>
        <Sub title="Warming & other essentials">
          <CheckList items={[
            'Forced-air warming blanket ("Bair Hugger") + warming unit',
            'Extra blankets; warmed if available',
            'Suction — Yankauer + tubing, tested and within reach',
            'Gloves (multiple sizes — yours and spares)',
            'Syringes and needles for drawing up/labeling drugs; drug labels',
            'Eye protection/tape for the patient, padding for pressure points',
            'OG/NG tube and esophageal stethoscope/temp probe if indicated',
            'Positioning aids (gel pads, arm boards, foam donut, axillary roll)',
            'Warm saline, lubricant, and case-specific supplies',
          ]} />
        </Sub>
      </Section>

      {/* Section 6 */}
      <Section number="6" title="The Anesthesia Machine Check">
        <CalloutBox>
          <strong>Key principle:</strong> There is no universal checkout that applies to every machine. Always follow the manufacturer-specific checkout for the exact workstation in your room. The 2008 ASA/APSF guidelines (developed with the AANA and ASATT) define <em>what</em> systems must be evaluated; the manufacturer defines <em>how</em>. Also codified in the AANA Standards for Nurse Anesthesia Practice, Standard 6.
        </CalloutBox>

        <Sub title="6A · The 15 Essential Items (ASA/APSF 2008)">
          <Table
            headers={['#', 'Item', 'Frequency']}
            rows={[
              ['1', 'Verify auxiliary O₂ cylinder and self-inflating manual ventilation device are available & functioning', 'Daily'],
              ['2', 'Verify patient suction is adequate to clear the airway', 'Each case'],
              ['3', 'Turn on the delivery system; confirm AC (mains) power is available (not just battery)', 'Daily'],
              ['4', 'Verify availability of required monitors and check alarms', 'Daily'],
              ['5', 'Verify O₂ cylinder pressure on the machine (>1,500 psig); then close the valve', 'Daily'],
              ['6', 'Verify piped gas pressures are ≥50 psig', 'Daily'],
              ['7', 'Verify vaporizers are filled and filler ports tightly closed', 'Daily'],
              ['8', 'Verify no leaks between flowmeters and the common gas outlet', 'Daily / after vaporizer change'],
              ['9', 'Test scavenging system function', 'Daily'],
              ['10', 'Calibrate the O₂ monitor and verify the low-O₂ alarm', 'Daily'],
              ['11', 'Verify CO₂ absorbent is not exhausted', 'Each case'],
              ['12', 'Breathing system pressure & leak testing', 'Each case'],
              ['13', 'Verify gas flows properly through the circuit on inspiration & exhalation', 'Each case'],
              ['14', 'Document completion of the checkout', 'Each case'],
              ['15', 'Confirm ventilator settings; evaluate readiness ("ANESTHESIA TIME OUT")', 'Each case'],
            ]}
          />
        </Sub>

        <div className="p-3 bg-amber-50 dark:bg-amber-900/20 border border-amber-200 rounded-xl text-xs mt-3">
          <strong className="text-amber-800 dark:text-amber-300">Anesthesia Time Out — memorize this:</strong>
          <p className="text-foreground mt-1">Oxygen? · Agent (vaporizer)? · Absorbent? · Pressure (leak test)? · Monitoring? · Alarms?</p>
        </div>

        <Sub title="6B · Classic Checkout Sequence (any machine)">
          <Numbered items={[
            'Verify backup ventilation equipment is available & functioning.',
            'Check the high-pressure system — O₂ cylinder, then central pipeline supplies.',
            'Check the low-pressure system — initial status, then leak-check it.',
            'Turn on the machine master switch.',
            'Test the flowmeters.',
            'Check the scavenging system.',
            'Calibrate the O₂ monitor.',
            'Check the breathing system — initial status, then high-pressure leak check.',
            'Test ventilation systems and unidirectional valves.',
            'Check, calibrate, and set alarm limits on all monitors.',
            'Final status: vaporizers OFF · APL valve open · selector to "Bag" · flowmeters to zero · suction adequate · circuit ready.',
          ]} />
        </Sub>

        <Sub title="6C · Machine-Specific Checkouts">
          <CalloutBox>Modern machines run automated self-tests <strong>plus</strong> a few manual steps you must do yourself. The automated test <strong>does not check everything</strong> — vaporizer filling, agent, suction, and backup equipment are still on you.</CalloutBox>
          <div className="space-y-4 mt-3">
            <div>
              <p className="text-xs font-bold text-amber-700 mb-1">Dräger Fabius GS / GS Premium (15-step)</p>
              <Numbered items={[
                'Verify machine is powered on; run the System Test (left softkey in Standby).',
                'Verify backup ventilation equipment available & functioning.',
                'Confirm O₂ cylinder — open and verify ≥ half full (~1,000 psi).',
                'Confirm pipeline gas pressures.',
                'Verify vaporizers filled, ports closed, and seated.',
                'Set fresh gas flows.',
                'Check the scavenging system.',
                'Flow/expiratory sensor calibration.',
                'O₂ monitor calibration.',
                'Breathing system leak test (automated).',
                'Automatic (mechanical) ventilation check.',
                'Manual ventilation "feel" check.',
                'Confirm CO₂ absorbent, monitors/alarms, and final status (vaporizers off, APL open, ventilator in Standby, flows off).',
              ]} />
            </div>
            <div>
              <p className="text-xs font-bold text-amber-700 mb-1">Dräger Apollo (and Perseus, similar)</p>
              <Numbered items={[
                'Verify backup ventilation equipment.',
                'Verify suction.',
                'Turn machine ON.',
                'Complete the manual checklist as displayed on screen.',
                'Confirm to initiate the automatic self-test.',
                'Prepare machine for final use.',
              ]} />
            </div>
            <div>
              <p className="text-xs font-bold text-amber-700 mb-1">Dräger Narkomed GS</p>
              <Numbered items={[
                'Verify auxiliary O₂ + self-inflating device; patient suction.',
                'Confirm AC power ("AC Power Fail" and "Battery Low" amber lights OFF).',
                'Verify required monitors/alarms.',
                'O₂ cylinder >1,500 psig; pipeline ≥50 psig.',
                'Vaporizers filled and filler ports closed.',
                'Set scavenging to 10–20 L/min.',
                'Calibrate O₂ monitor and low-O₂ alarm.',
                'Confirm CO₂ absorbent (Sodasorb) not exhausted.',
                'Perform leak and ventilator tests.',
              ]} />
            </div>
            <div>
              <p className="text-xs font-bold text-amber-700 mb-1">GE / Datex-Ohmeda Aestiva</p>
              <Numbered items={[
                'Check CO₂ absorbent, sampling line, water trap.',
                'Occlude Y-piece and run the static ventilator leak check.',
                'Check ventilator relief valve, scavenger suction, O₂ flush; patient suction.',
                'Walk around: backup ventilation bag, jet ventilator, emergency LMA.',
                'O₂ pipeline and cylinder pressures — then turn cylinders OFF.',
                'Cut & restore main power to confirm battery backup.',
                'Machine ON: minimum O₂ flow/calibration/alarm → flow sensor calibration → mechanical ventilation, leaks, pressure limiter → O₂/N₂O ratio, flow controls, minimum PEEP → return to manual → vaporizer back-pressure test → set alarms.',
                'Finish with TIME OUT: Oxygen? Agent? Absorbent? Pressure? Monitoring? Alarms?',
              ]} />
            </div>
            <div>
              <p className="text-xs font-bold text-amber-700 mb-1">GE Aisys CS2 / Aespire / Avance (automated)</p>
              <Numbered items={[
                'Confirm gas pipelines connected; cylinders available.',
                'Check that the breathing system is properly connected.',
                'Turn the System Switch to On — the machine runs automated self-tests.',
                'Perform a Full Test from the checkout menu before the first case of the day.',
                'Use the leak test plug to occlude the breathing circuit.',
                'Confirm the AGSS (scavenging) flow indicator ball is in the green zone.',
                'Manually verify vaporizer/agent, CO₂ absorbent, suction, backup ventilation, monitors/alarms.',
              ]} />
            </div>
            <div>
              <p className="text-xs font-bold text-amber-700 mb-1">Mindray A-Series (A7 / A9)</p>
              <Numbered items={[
                'Verify equipment, cables, and accessories are in correct working order.',
                'Turn on and allow automated self-tests.',
                'Run the system/leak and compliance tests.',
                'Calibrate the O₂ and flow sensors as prompted.',
                'Confirm vaporizer, CO₂ absorbent, scavenging, suction, backup ventilation, monitors/alarms per the operator\'s manual.',
              ]} />
            </div>
          </div>
          <div className="mt-3 p-3 bg-amber-50 dark:bg-amber-900/20 border border-amber-200 rounded-xl text-xs">
            <strong>Whatever the brand — the logic is the same:</strong>
            <p className="text-foreground mt-1">Power & backup → gas supplies → vaporizers → low-pressure leak → flows → scavenging → O₂ monitor → breathing-system leak → ventilator & valves → monitors/alarms → final status & document. Automated tests cover internal plumbing; <strong>you still own</strong> suction, backup bag, agent, absorbent, monitors, and drugs.</p>
          </div>
        </Sub>
      </Section>

      {/* Section 7 */}
      <Section number="7" title="Emergency Meds & Drawing Up Drugs">
        <CalloutBox color="red">
          Doses below are <strong>common adult reference ranges for orientation only</strong>. Always confirm doses against your institution's formulary, your preceptor, and the individual patient (weight, age, comorbidities) before administering. Draw up, label every syringe, and <strong>never give an unlabeled drug</strong>.
        </CalloutBox>

        <Sub title="7A · Have drawn up & available for every case">
          <div className="space-y-3">
            <div>
              <p className="text-xs font-semibold text-foreground mb-1">Induction / Hypnotics</p>
              <Bullets items={[
                'Propofol 1.5–2.5 mg/kg IV induction (reduce in elderly/frail; use lean body weight in obesity)',
                'Etomidate 0.2–0.3 mg/kg (hemodynamically unstable; single-dose adrenal suppression is expected)',
                'Ketamine 1–2 mg/kg IV / 4–8 mg/kg IM',
                'Midazolam 0.02–0.04 mg/kg (premed/amnesia)',
              ]} />
            </div>
            <div>
              <p className="text-xs font-semibold text-foreground mb-1">Opioids</p>
              <Bullets items={[
                'Fentanyl — titrate; commonly 1–3 mcg/kg',
                'Hydromorphone / morphine for longer-acting analgesia',
                'Remifentanil 0.05–0.2 mcg/kg/min infusion where appropriate',
              ]} />
            </div>
            <div>
              <p className="text-xs font-semibold text-foreground mb-1">Neuromuscular Blockers</p>
              <Bullets items={[
                'Succinylcholine 1–1.5 mg/kg IV (rapid sequence; also for laryngospasm — pediatric IM dose 4 mg/kg)',
                'Rocuronium 0.6–1.2 mg/kg IV',
                'Vecuronium / cisatracurium per case',
              ]} />
            </div>
            <div>
              <p className="text-xs font-semibold text-foreground mb-1">Reversal</p>
              <Bullets items={[
                'Sugammadex 2 mg/kg (moderate block, TOF ≥2), 4 mg/kg (deep block, PTC 1–2), or 16 mg/kg (immediate reversal of rocuronium/vecuronium)',
                'Neostigmine 0.03–0.07 mg/kg (max 5 mg) with glycopyrrolate 0.01 mg/kg — only use when TOF count ≥2',
                'Confirm quantitative TOF ratio ≥0.9 before extubation — ASA/ESAIC 2023 recommends quantitative monitoring whenever a nondepolarizer is given',
              ]} />
            </div>
          </div>
          <div className="mt-3 p-3 bg-amber-50 dark:bg-amber-900/20 border border-amber-200 rounded-xl text-xs">
            <strong className="text-amber-800 dark:text-amber-300">Sugammadex & hormonal contraception — counsel every patient:</strong>
            <p className="mt-1 text-foreground">Sugammadex can bind progesterone and is considered equivalent to a missed dose of hormonal contraception. Advise patients to use an additional non-hormonal method for <strong>7 days</strong> after sugammadex exposure. (Merck US prescribing information; ASA/ESAIC 2023.)</p>
          </div>
        </Sub>

        <Sub title="7B · Emergency / Resuscitation Drugs (immediately available)">
          <Table
            headers={['Drug', 'Common adult use & reference dose']}
            rows={[
              ['Phenylephrine', 'Pure α-agonist; bolus ~50–100 mcg IV for hypotension (reflex bradycardia); infusion 20–200 mcg/min'],
              ['Ephedrine', 'Mixed agonist; bolus ~5–10 mg IV for hypotension with bradycardia'],
              ['Epinephrine', 'Anaphylaxis 10–100 mcg IV titrated (or 0.3–0.5 mg IM); 1 mg IV in cardiac arrest per ACLS'],
              ['Atropine', '0.5 mg IV for bradycardia (up to ~3 mg total); pediatric 0.02 mg/kg (min 0.1 mg)'],
              ['Glycopyrrolate', '0.2 mg IV antisialagogue / bradycardia; pairs with neostigmine (0.01 mg/kg)'],
              ['Vasopressin', 'Refractory hypotension / arrest per ACLS (40 units IV push in arrest)'],
              ['Calcium chloride / gluconate', 'Hyperkalemia, hypocalcemia, cardiac support; CaCl₂ 1 g IV (central line preferred)'],
              ['Naloxone', 'Opioid reversal — titrate small doses (e.g., 40 mcg IV) to preserve analgesia'],
              ['Flumazenil', 'Benzodiazepine reversal 0.2 mg IV (caution: seizure risk in chronic BZD users)'],
              ['Labetalol / esmolol / hydralazine', 'Acute hypertension / tachycardia'],
              ['Nitroglycerin', 'Ischemia, acute hypertension, controlled hypotension'],
              ['Lidocaine', 'Antiarrhythmic; blunt the intubation response (1–1.5 mg/kg IV)'],
              ['Dantrolene', 'Malignant hyperthermia — know exactly where the MH cart is'],
              ['Lipid emulsion 20%', 'Local anesthetic systemic toxicity (LAST) — see Section 8 for ASRA dosing'],
            ]}
          />
        </Sub>

        <Sub title="7C · Drug-Handling Rules">
          <Bullets items={[
            'Label every syringe immediately with drug name and concentration.',
            'Use ISO 26825 color-coded labels (yellow = induction, red = paralytic, blue = opioid, orange = benzodiazepine, violet = vasopressor).',
            'Draw up vasopressors (phenylephrine, ephedrine) before induction — hypotension is common and you won\'t have time later.',
            'Double-check concentration — many errors come from mixing up mcg vs mg.',
            'Account for and document controlled substances per policy.',
          ]} />
        </Sub>

        <Sub title="7D · Pediatric Quick Notes (weight-based dosing)">
          <CalloutBox>
            <strong>Always use lean/actual weight as appropriate.</strong> Have a Broselow tape or a pediatric dosing calculator in the room for any patient &lt;40 kg.
          </CalloutBox>
          <div className="mt-2">
            <Table
              headers={['Drug / parameter', 'Pediatric reference']}
              rows={[
                ['Propofol induction', '2.5–3.5 mg/kg IV (children often need more per kg than adults)'],
                ['Ketamine', '1–2 mg/kg IV; 4–8 mg/kg IM'],
                ['Rocuronium', '0.6–1.2 mg/kg IV'],
                ['Succinylcholine', '1–2 mg/kg IV; 4 mg/kg IM (laryngospasm rescue)'],
                ['Atropine (bradycardia)', '0.02 mg/kg IV (min 0.1 mg, max 0.5 mg)'],
                ['Epinephrine (arrest)', '0.01 mg/kg IV/IO (1:10,000) every 3–5 min'],
                ['Fentanyl', '1–2 mcg/kg IV titrated'],
                ['ETT size (cuffed)', '(Age/4) + 3.5; depth ≈ ETT size × 3 cm at lip'],
                ['Maintenance fluid (4/2/1)', '4 mL/kg/h first 10 kg + 2 mL/kg/h next 10 kg + 1 mL/kg/h >20 kg'],
              ]}
            />
          </div>
        </Sub>
      </Section>

      {/* Section 8 */}
      <Section number="8" title="Crisis Algorithms (MH · LAST · Airway · Anaphylaxis)">
        <p className="text-sm text-muted-foreground mb-3">These are the events you hope you never see — but you must know cold before you ever induce a patient.</p>
        <div className="space-y-4">
          <CrisisCard color="red" title="MALIGNANT HYPERTHERMIA — recognize & act in seconds">
            <p><strong>Call for help.</strong> Get the MH cart. Assign a dedicated Dantrolene Mixer.</p>
            <p><strong>Stop the trigger:</strong> discontinue all volatile agents and succinylcholine. Change circuit, soda lime, and reservoir bag. Hyperventilate with 100% O₂ at ≥10 L/min.</p>
            <p><strong>Dantrolene 2.5 mg/kg IV bolus</strong> as fast as it can be reconstituted. Repeat every 5–10 min until signs abate. Maintenance 1 mg/kg IV q 4–6 h × 24–72 h.</p>
            <p><strong>Cool the patient</strong> (cold IV saline, surface cooling, gastric/bladder lavage) — stop at 38 °C.</p>
            <p>Treat hyperkalemia, acidosis, arrhythmias. Insert arterial line, Foley, and monitor for compartment syndrome/rhabdomyolysis.</p>
            <p className="text-red-700 dark:text-red-300 font-bold">MHAUS Hotline (24/7): 1-800-644-9737 · Outside US: +1-209-417-3722</p>
          </CrisisCard>

          <CrisisCard color="orange" title="LOCAL ANESTHETIC SYSTEMIC TOXICITY (LAST) — ASRA 2020">
            <p><strong>Stop injecting the local anesthetic.</strong> Call for help. Get lipid emulsion 20%.</p>
            <p><strong>Airway:</strong> 100% O₂, mask ventilate, intubate as needed. Avoid hyperventilation (acidosis worsens cardiotoxicity).</p>
            <p><strong>Seizures:</strong> benzodiazepine first-line (midazolam 2–4 mg IV). Avoid propofol if hemodynamically unstable.</p>
            <p><strong>Lipid emulsion 20% dosing (ASRA 2020):</strong></p>
            <ul className="ml-3 space-y-0.5 text-sm">
              <li>• &lt;70 kg: bolus 1.5 mL/kg over 2–3 min, then infusion 0.25 mL/kg/min</li>
              <li>• ≥70 kg: bolus 100 mL over 2–3 min, then infusion 200–250 mL over 15–20 min</li>
              <li>• Repeat bolus 1–2× and double infusion rate if unstable. <strong>Max cumulative dose 12 mL/kg.</strong></li>
            </ul>
            <p><strong>Cardiac arrest:</strong> modified ACLS — reduce epinephrine to ≤1 mcg/kg; avoid vasopressin, calcium channel blockers, β-blockers, and lidocaine. Consider CPB/ECMO early.</p>
          </CrisisCard>

          <CrisisCard color="yellow" title="ANAPHYLAXIS — epinephrine first, then airway/fluids">
            <p><strong>Stop the trigger</strong> (drug, latex, chlorhexidine, contrast, blood product). Call for help.</p>
            <p><strong>Epinephrine is first-line, always:</strong> 10–100 mcg IV titrated (or 0.3–0.5 mg IM if no IV). Repeat every 1–2 min; start infusion if refractory (0.05–0.2 mcg/kg/min).</p>
            <p><strong>Airway:</strong> 100% O₂, secure the airway early — angioedema progresses quickly.</p>
            <p><strong>Fluids:</strong> crystalloid 10–30 mL/kg rapid bolus; may need &gt;4 L.</p>
            <p><strong>Adjuncts</strong> (only after epinephrine): diphenhydramine 25–50 mg, famotidine 20 mg, hydrocortisone 100–200 mg.</p>
            <p>Draw a tryptase level at 1 h, 4 h, and 24 h after onset. Refer for allergy testing.</p>
          </CrisisCard>

          <CrisisCard color="blue" title="DIFFICULT / FAILED AIRWAY — DAS Plan A → B → C → D">
            <p><strong>Plan A — Mask ventilation & tracheal intubation.</strong> Optimize position; two-hand mask with adjuncts (OPA/NPA); maximum <strong>three</strong> attempts at direct/video laryngoscopy, plus <strong>one</strong> by a more experienced operator. Use a bougie/stylet, external laryngeal manipulation, and switch blade/device between attempts. <strong>Declare failure early.</strong></p>
            <p><strong>Plan B — Supraglottic airway (SGA).</strong> Maximum three attempts with a second-generation SGA (i-gel, LMA Supreme). Ventilate, then decide: wake, intubate through the SGA (fiberoptic-assisted), or proceed to Plan C.</p>
            <p><strong>Plan C — Facemask ventilation and wake up.</strong> Two-person mask ventilation with adjuncts, paralysis if not already given. If ventilation is adequate: wake the patient. If not adequate: declare CICO.</p>
            <p><strong>Plan D — Emergency front-of-neck access (eFONA).</strong> Scalpel–bougie–tube cricothyroidotomy: identify cricothyroid membrane → transverse stab → 90° rotate → insert bougie → railroad size-6 cuffed ETT. <strong>Practice this on a simulator before you need it.</strong></p>
          </CrisisCard>
        </div>
      </Section>

      {/* Section 9 */}
      <Section number="9" title="Know Where the Emergency Equipment Lives">
        <p className="text-sm text-muted-foreground mb-3">On your first day in each new room and OR suite, physically walk the room with your preceptor and locate every item below. Write the locations in your notebook — in an emergency, you must reach them in seconds.</p>
        <CheckList items={[
          'GlideScope / video laryngoscope — confirm it\'s charged and a clean blade is loaded',
          'Difficult Airway Cart — fiberoptic scope, bougie, LMAs (incl. intubating LMA), cricothyroidotomy/surgical airway kit, assorted ETTs and blades',
          'Crash cart / code cart and defibrillator — know how to turn it on and where the pads are',
          'Malignant Hyperthermia (MH) cart — dantrolene (Ryanodex or Dantrium/Revonto), sterile water, cold saline, and the MH protocol/hotline number (1-800-644-9737)',
          'Emergency tracheostomy tray and selection of tracheostomy tubes',
          'Backup manual ventilation device (Ambu bag) and backup O₂ cylinder',
          'Massive transfusion protocol supplies / blood refrigerator and how to activate MTP',
          'Rapid infuser / Level 1 and additional fluid warmers',
          'Extra suction setup and tubing',
          'Emergency drug box / pharmacy Pyxis and the after-hours pharmacy plan',
          'Lipid emulsion 20% (Intralipid) — required near any block cart (ASRA 2020)',
          'Fire extinguisher and OR fire plan; gas shutoff valves',
          'How to call for help — the in-room phone, overhead code/STAT page, and who responds',
        ]} />
        <Sub title="Know the algorithms">
          <Bullets items={[
            'ASA Difficult Airway Algorithm (2022) and DAS 2015/2025 — have a plan for "cannot intubate, cannot oxygenate."',
            'ACLS / PALS — current AHA protocols.',
            'Malignant Hyperthermia protocol — recognition, dantrolene dosing/mixing, MHAUS hotline.',
            'Local Anesthetic Systemic Toxicity (LAST) — where the lipid emulsion is kept and the ASRA 2020 dosing.',
            'Anaphylaxis — epinephrine first, then airway/fluids/secondary agents.',
            'Massive Transfusion Protocol and Emergency Manuals (Stanford / AHA / APSF cognitive aids).',
          ]} />
        </Sub>
      </Section>

      {/* Section 10 */}
      <Section number="10" title="PACU Handoff (SBAR) & Post-Op Considerations">
        <p className="text-sm text-muted-foreground mb-3">A structured handoff to PACU is a Joint Commission and AANA expectation. Standardized handoffs are associated with fewer information gaps and adverse events.</p>
        <Table
          headers={['Element', 'What to say']}
          rows={[
            ['S — Situation', 'Patient name, age, allergies, procedure performed, surgeon, and anesthesia type (GA/MAC/regional).'],
            ['B — Background', 'Relevant PMH/PSH, home meds, ASA class, airway grade, blood loss, urine output, fluids/blood products given.'],
            ['A — Assessment', 'Current vitals and trend; pain score; nausea; block level / motor return; residual neuromuscular block (last TOF); intraoperative issues; post-op labs pending.'],
            ['R — Recommendation', 'Analgesia plan, PONV prophylaxis, glycemic plan, VTE prophylaxis, disposition (floor / step-down / ICU), lines/drains, and "call me for…" criteria.'],
          ]}
        />
        <Sub title="Post-op safety essentials">
          <Bullets items={[
            'Confirm quantitative TOF ≥0.9 before extubation and again on PACU arrival.',
            'Discharge criteria: Aldrete or PADSS score per facility.',
            'PONV multimodal prophylaxis for >1 Apfel risk factor (ondansetron + dexamethasone ± scopolamine ± aprepitant).',
            'Reassess pain, sedation, and respiratory status at defined intervals — opioid-induced respiratory depression is most common in the first hour.',
            'Sugammadex/contraception counseling before discharge.',
            'Document the anesthetic record and any complications per AANA Standard 11.',
          ]} />
        </Sub>
      </Section>

      {/* Section 11 */}
      <Section number="11" title="Quick-Reference Pocket Card">
        <div className="space-y-2">
          {[
            { label: 'Room setup — SOAP-ME', text: 'Suction · Oxygen (+ Ambu bag) · Airway · Pharmacy · Monitors · Equipment' },
            { label: 'Never skip on any case', text: 'Manual vent device · Machine check done · Suction · Emergency airway (ETT + LMA) · Emergency drugs · Working IV · ASA monitors · Quantitative TOF' },
            { label: 'Anesthesia Time Out (each case)', text: 'Oxygen? · Agent? · Absorbent? · Pressure (leak test)? · Monitoring? · Alarms?' },
            { label: 'Machine check logic (any brand)', text: 'Power & backup → gas supplies → vaporizers → low-pressure leak → flows → scavenging → O₂ monitor → breathing-system leak → ventilator & valves → monitors/alarms → final status & document.' },
            { label: 'Pre-draw before induction', text: 'Phenylephrine and ephedrine — hypotension is common.' },
            { label: 'Crisis numbers & doses', text: 'MHAUS: 1-800-644-9737 · Dantrolene 2.5 mg/kg IV · LAST lipid 1.5 mL/kg bolus + 0.25 mL/kg/min infusion (max 12 mL/kg) · Epi anaphylaxis 10–100 mcg IV · Sugammadex 2/4/16 mg/kg.' },
            { label: 'Locate on day one', text: 'GlideScope · Difficult airway cart · Crash cart + defibrillator · MH cart (dantrolene) · Lipid emulsion · Trach tray · How to call for help.' },
            { label: 'Mindset', text: 'Prepared, early, asks questions, double-checks doses, never gives an unlabeled drug, stays at the head of the bed.' },
          ].map((card, i) => (
            <div key={i} className="p-3 rounded-xl bg-amber-900/10 border border-amber-200 dark:border-amber-800">
              <p className="text-xs font-bold text-amber-700 dark:text-amber-400 mb-1">{card.label}</p>
              <p className="text-sm text-foreground">{card.text}</p>
            </div>
          ))}
        </div>
      </Section>

      {/* Section 12 */}
      <Section number="12" title="Recommended Reading & Textbooks">
        <p className="text-sm text-muted-foreground mb-2">Every SRNA and anesthesia resident should have the following on their shelf (physical or digital) by the end of the first semester. Editions current as of 2025–2026.</p>
        <Sub title="Core Textbooks">
          <Bullets items={[
            'Elisha S, Heiner JS, Nagelhout JJ. Nurse Anesthesia, 7th ed. Elsevier, 2023. The definitive CRNA text — start here.',
            'Elisha S, Heiner JS. Current Anesthesia Practice and Certification Review, 2nd ed. Elsevier, 2026. Best NCE prep for CRNA candidates.',
            'Gropper MA, Eriksson LI, Fleisher LA, et al. Miller\'s Anesthesia, 10th ed (2-vol). Elsevier, 2024. The reference standard.',
            'Cullen BF, Stock MC, Ortega R, et al. Barash, Cullen, and Stoelting\'s Clinical Anesthesia, 9th ed. Wolters Kluwer, 2023. Excellent second reference.',
            'Butterworth JF, Mackey DC, Wasnick JD. Morgan & Mikhail\'s Clinical Anesthesiology, 7th ed. McGraw-Hill, 2022. High-yield boards review.',
            'Coté CJ, Lerman J, Anderson BJ. A Practice of Anesthesia for Infants and Children, 7th ed. Elsevier, 2023. Essential for OB/Peds rotations.',
            'Chestnut DH, Wong CA, Tsen LC, et al. Chestnut\'s Obstetric Anesthesia, 7th ed. Elsevier, 2024. The OB anesthesia standard.',
            'Hadzic A. Hadzic\'s Textbook of Regional Anesthesia and Acute Pain Management, 2nd ed. McGraw-Hill, 2017 (with 2023 online updates via NYSORA).',
          ]} />
        </Sub>
        <Sub title="Pocket References & Apps">
          <Bullets items={[
            'Luma Anesthesia (companion app to this module) — drug reference, machine check, crisis hub, OB/Peds, regional, airway, EKG, labs. Free 3-month SRNA subscription — code FREELUMA3.',
            'Jaffe RA, Schmiesing CA, Golianu B. Anesthesiologist\'s Manual of Surgical Procedures, 6th ed. Wolters Kluwer, 2020. Case-by-case anesthetic planning.',
            'Ezekiel MR. Handbook of Anesthesiology (updated annually). Pocket-size formulary.',
            'Stanford Emergency Manual — free download at emergencymanual.stanford.edu.',
            'ASRA Coags App (regional anesthesia + antithrombotics) and ASA Monitor journal.',
          ]} />
        </Sub>
      </Section>

      {/* Disclaimer */}
      <div className="p-3 rounded-xl bg-muted border border-border text-xs text-muted-foreground">
        <strong>Disclaimer:</strong> This module is an educational orientation aid. It does not replace your anesthesia program's curriculum, your facility's policies, manufacturer operator manuals, or your clinical preceptor's direct supervision. All drug doses must be independently verified before administration. Always follow institutional protocol and your professional scope of practice.
        <br /><span className="mt-1 block">Created by CE HALO LLC · <a href="https://www.cehalo.com" target="_blank" rel="noopener noreferrer" className="text-primary underline">www.cehalo.com</a> · CRNA Owned &amp; Colleague Centered</span>
      </div>
    </div>
  );
}