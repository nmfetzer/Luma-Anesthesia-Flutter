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

export default function ABAEquipmentModule() {
  return (
    <div className="space-y-2 pb-4">
      {/* Intro */}
      <div className="p-4 rounded-xl bg-blue-50 border border-blue-100 mb-4">
        <p className="text-sm text-blue-900">This module covers the anesthesia gas delivery system, vaporizers, ventilator modes, monitoring standards, and the most frequently tested equipment hazards. Equipment questions on the BASIC exam reward an understanding of how each component fails — and how the failure is detected.</p>
        <KEY_POINT>ASA standard monitors require continuous evaluation of oxygenation, ventilation, circulation, and temperature for every anesthetic. Capnography (continuous quantitative ETCO₂) is mandatory whenever an ETT, LMA, or supraglottic airway is in place AND for moderate/deep sedation.</KEY_POINT>
      </div>

      {/* 4.1 Anesthesia Machine */}
      <Section title="4.1 · The Anesthesia Machine" defaultOpen>
        <p className="font-semibold text-blue-800">Gas Pathway — From Wall to Patient</p>
        <p className="text-sm">Pipeline (50 psi) or cylinder (E-cylinders, regulated to ~45 psi) → check valves → pressure regulators → flowmeters → vaporizers → common gas outlet → breathing circuit → patient.</p>

        <p className="font-semibold text-blue-800 mt-3">Safety Systems</p>
        <Bullet>DISS (Diameter Index Safety System): non-interchangeable threaded fittings for medical gas pipelines.</Bullet>
        <Bullet>PISS (Pin Index Safety System): pin pattern on E-cylinder yokes prevents wrong-cylinder attachment.</Bullet>
        <Bullet>Fail-safe valve: shuts off N₂O if O₂ pressure falls below ~30 psi. Does NOT prevent hypoxic mixture from a depleted O₂ cylinder with N₂O still flowing.</Bullet>
        <Bullet>Hypoxic guard / proportioning system: mechanically links O₂ and N₂O flowmeters to maintain FiO₂ ≥ 25%. Does NOT prevent hypoxia from third gases (helium, air) or crossed pipelines.</Bullet>
        <Bullet>Oxygen analyzer: the ONLY mandatory monitor that detects hypoxic mixture downstream of the flowmeters and vaporizers. Calibrate to room air (21%) each morning.</Bullet>
        <KEY_POINT>If you suspect a crossed pipeline (O₂ analyzer reads low despite high O₂ flowmeter setting), DISCONNECT FROM PIPELINE and ventilate from the E-cylinder. The O₂ analyzer downstream is the only guard against a wrong-gas pipeline.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">E-Cylinders (Common Gas Volumes & Pressures)</p>
        <Table
          headers={['Gas', 'Cylinder Color (US)', 'Full Pressure (psi)', 'Volume (L)', 'State']}
          rows={[
            ['Oxygen', 'Green', '1900', '660', 'Gas'],
            ['Nitrous oxide', 'Blue', '745', '1590', 'Liquid (drops only as liquid is exhausted)'],
            ['Air', 'Yellow', '1900', '625', 'Gas'],
            ['CO₂', 'Gray', '838', '—', 'Liquid'],
            ['Helium', 'Brown', '1600–2200', '—', 'Gas'],
          ]}
        />
      </Section>

      {/* 4.2 Vaporizers */}
      <Section title="4.2 · Vaporizers">
        <p className="font-semibold text-blue-800">Variable-Bypass (Iso, Sevo)</p>
        <p className="text-sm">Inflowing fresh gas is split: most bypasses the vaporizing chamber, a small fraction passes through and saturates with anesthetic. The dial sets the splitting ratio. Output is concentration-calibrated.</p>
        <Bullet>Affected by altitude (output volume % falls but partial pressure remains constant — clinical effect unchanged).</Bullet>
        <Bullet>Affected by temperature (compensated by temperature-sensitive bimetallic strip).</Bullet>
        <Bullet>Tipping a variable-bypass vaporizer can flood the bypass and deliver a lethal concentration — turn off and purge if tipped.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Desflurane Vaporizer (Tec 6)</p>
        <p className="text-sm">Desflurane boils at 22.8°C (near room temperature) — variable-bypass vaporizer cannot reliably control output. The Tec 6 is electrically heated to 39°C (1500 mmHg) and injects pure desflurane vapor into the fresh gas stream.</p>
        <Bullet>Requires AC electrical power.</Bullet>
        <Bullet>Does NOT auto-compensate for altitude — output concentration is constant, but partial pressure drops at altitude, REDUCING anesthetic effect (must increase dial setting at altitude).</Bullet>
        <KEY_POINT>Filling the wrong vaporizer with the wrong agent → unpredictable, potentially lethal output. Modern keyed filling systems (Quik-Fil for sevoflurane, Saf-T-Fil for desflurane) prevent this.</KEY_POINT>
      </Section>

      {/* 4.3 Breathing Circuits */}
      <Section title="4.3 · Breathing Circuits">
        <p className="font-semibold text-blue-800">Circle System (Standard Adult)</p>
        <p className="text-sm">Includes inspiratory and expiratory unidirectional valves, fresh gas inlet, CO₂ absorber, reservoir bag, APL valve, Y-piece. Allows low-flow anesthesia and recovery of exhaled volatile.</p>
        <Bullet>Unidirectional valve incompetence → rebreathing of CO₂ (rising ETCO₂ despite adequate minute ventilation, abnormal capnograph baseline).</Bullet>
        <Bullet>CO₂ absorbent: soda lime (Ca(OH)₂ + NaOH). Color change (white → violet/purple) indicates exhaustion. Bypass-channeling can give false-negative color change.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">CO₂ Absorbent Hazards</p>
        <Bullet>Compound A (sevoflurane + soda lime, especially desiccated) — nephrotoxic in rats; not shown in humans at fresh gas flows ≥ 2 L/min.</Bullet>
        <Bullet>Carbon monoxide (volatile + desiccated absorbent, especially Baralyme — now discontinued). Worst with desflurane &gt; isoflurane &gt; sevoflurane.</Bullet>
        <Bullet>Fire/exothermic reaction (sevoflurane + completely desiccated Baralyme). Use modern absorbents without strong bases (e.g., Amsorb).</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Mapleson Circuits</p>
        <Bullet>No CO₂ absorber; rely on fresh gas flow to wash out CO₂.</Bullet>
        <Bullet>Mapleson A (Magill): most efficient for spontaneous ventilation — FGF = minute ventilation.</Bullet>
        <Bullet>Mapleson D (Bain): most efficient for controlled ventilation — FGF ≈ 2× minute ventilation for normocapnia.</Bullet>
        <Bullet>Bain circuit hazard: inner fresh-gas tube can kink or disconnect → large dead-space rebreathing problem ('Pethick test' detects this).</Bullet>
      </Section>

      {/* 4.4 Mechanical Ventilation */}
      <Section title="4.4 · Mechanical Ventilation">
        <p className="font-semibold text-blue-800">Modes</p>
        <Bullet>Volume control (VCV): set Vt, RR, I:E. Pressure varies — risk of barotrauma if compliance falls.</Bullet>
        <Bullet>Pressure control (PCV): set peak pressure, RR, I:E. Vt varies with compliance — risk of hypoventilation.</Bullet>
        <Bullet>Pressure support (PSV): spontaneous breaths augmented by set pressure — useful for emergence and weaning.</Bullet>
        <Bullet>Pressure-regulated volume control (PRVC): targets a set Vt with the lowest pressure (decelerating flow).</Bullet>

        <p className="font-semibold text-blue-800 mt-3">PEEP & Recruitment</p>
        <Bullet>PEEP 5 cmH₂O is the default ('physiologic' PEEP) — reduces atelectasis.</Bullet>
        <Bullet>Recruitment maneuvers (40 cmH₂O for 40 sec) re-expand collapsed alveoli. Use cautiously in hypovolemia, severe COPD, bullous disease.</Bullet>
        <Bullet>Higher PEEP improves oxygenation but ↑ intrathoracic pressure → ↓ venous return → ↓ CO.</Bullet>
        <KEY_POINT>Standard intraoperative settings: Vt 6–8 mL/kg IBW, PEEP 5 cmH₂O, plateau pressure &lt;30 cmH₂O, FiO₂ ≥ 0.4, RR to target ETCO₂ 35–40 mmHg. Recruitment every 30 min in long cases.</KEY_POINT>
      </Section>

      {/* 4.5 Monitoring */}
      <Section title="4.5 · Monitoring">
        <p className="font-semibold text-blue-800">Pulse Oximetry</p>
        <Bullet>Two wavelengths (660 nm red, 940 nm infrared). Detects pulsatile (arterial) component.</Bullet>
        <Bullet>Detects only HbO₂ and HbR. Misses HbCO (reads high), methemoglobin (reads ~85%), and dyes (methylene blue → transient false low).</Bullet>
        <Bullet>Inaccurate with motion, nail polish, low perfusion, severe anemia (Hb &lt;5), and dark skin pigmentation.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Capnography</p>
        <p className="text-sm">Normal ETCO₂: 35–40 mmHg. PaCO₂ − ETCO₂ gradient ≈ 2–5 mmHg (widens with dead space).</p>
        <Table
          headers={['Pattern', 'Diagnosis']}
          rows={[
            ['Sudden loss of waveform', 'Disconnection, esophageal intubation, cardiac arrest'],
            ['Gradually falling ETCO₂', 'Hyperventilation, ↓ CO, hypothermia, PE'],
            ['Rising ETCO₂', 'Hypoventilation, ↑ metabolism (MH, sepsis, hyperthermia), CO₂ insufflation'],
            ["'Shark fin' (sloped upstroke)", 'Bronchospasm, COPD — obstructive expiration'],
            ['Curare cleft (notch in plateau)', 'Patient breathing against ventilator (incomplete paralysis)'],
            ['Rebreathing (baseline > 0)', 'Valve failure, exhausted absorbent, inadequate FGF in Mapleson'],
          ]}
        />
        <KEY_POINT>ETCO₂ is the gold-standard confirmation of endotracheal intubation. Six sustained waveforms with appropriate amplitude confirms tracheal placement; brief return that decays = esophageal.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Blood Pressure</p>
        <Bullet>Non-invasive (oscillometric): cuff bladder ≥40% arm circumference. Underestimates true SBP, overestimates DBP. Inaccurate in arrhythmia, severe hypotension, motion.</Bullet>
        <Bullet>Invasive arterial line: transducer leveled at phlebostatic axis (4th ICS, mid-axillary line) for non-cardiac surgery; at external auditory meatus for sitting craniotomy.</Bullet>
        <Bullet>Damping: overdamped (long tubing, kink, clot, air bubble) — narrow pulse pressure, blunted upstroke. Underdamped — exaggerated systolic. Square-wave test: 1–2 oscillations = optimal.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">ECG</p>
        <Bullet>Standard intraoperative: leads II + V5. Lead II — best for arrhythmia detection (P wave). V5 — best for left-sided ischemia (75% sensitivity alone; up to 96% with II + V5).</Bullet>
        <Bullet>ST segment analysis: ≥1 mm depression (horizontal or downsloping) 60–80 ms after J-point indicates ischemia.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Temperature</p>
        <Bullet>Core sites: pulmonary artery, distal esophagus (lower 1/4), nasopharynx, tympanic membrane.</Bullet>
        <Bullet>Hypothermia (&lt;35°C) causes coagulopathy, surgical site infection, ↑ catecholamines, ↑ cardiac events. Mandatory active warming for cases &gt;30 min.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Neuromuscular Monitoring</p>
        <Bullet>Ulnar nerve / adductor pollicis is the standard. Facial nerve recovers faster but does NOT reflect adequacy for extubation.</Bullet>
        <Bullet>TOF ratio (T4/T1) ≥ 0.9 by quantitative monitor required for safe extubation. Clinical signs (head lift, hand grip) are insensitive.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Depth-of-Anesthesia Monitors</p>
        <Bullet>BIS (0–100): 40–60 = general anesthesia. Ketamine and N₂O may falsely elevate BIS. Does not replace clinical judgment.</Bullet>
      </Section>

      {/* 4.6 Hazards */}
      <Section title="4.6 · Equipment Hazards & Quick Diagnosis">
        <Table
          headers={['Finding', 'Most Likely Problem']}
          rows={[
            ['FiO₂ falls despite high O₂ flow', 'Crossed pipeline OR depleted O₂ cylinder OR analyzer failure — disconnect pipeline, ventilate via E-cyl'],
            ['Sudden ↓ ETCO₂ to zero', 'Circuit disconnect, esophageal intubation, cardiac arrest, sampling line clogged'],
            ['Sudden ↓ ETCO₂ but waveform present', '↓ CO (hemorrhage, PE, pneumothorax)'],
            ['Sudden ↑ ETCO₂', 'Hypoventilation, MH, hyperthermia, tourniquet release, laparoscopic CO₂ absorption'],
            ['Rising peak airway pressure, normal plateau', '↑ resistance — bronchospasm, kinked tube, mucus, light anesthesia, biting'],
            ['Rising peak AND plateau pressures', '↓ compliance — pulmonary edema, pneumothorax, mainstem intubation, abdominal insufflation'],
            ['Spike in airway pressure', 'Sudden obstruction — kink, secretions, biting; tension pneumothorax'],
            ['High pressure alarm + low Vt', 'Obstruction or pneumothorax'],
            ['Low pressure alarm', 'Disconnect, leak, deflated cuff'],
            ['O₂ analyzer reads low, normal flowmeters', 'Gas crossover, analyzer needs calibration'],
            ['Capnograph baseline elevated', 'Rebreathing — exhausted absorbent or valve incompetence'],
          ]}
        />

        <p className="font-semibold text-blue-800 mt-3">Machine Checkout (Pre-Use)</p>
        <Bullet>Verify O₂ analyzer calibration.</Bullet>
        <Bullet>Check backup E-cylinder (O₂ ≥ 1000 psi).</Bullet>
        <Bullet>Check pipeline pressures (50 psi).</Bullet>
        <Bullet>Vaporizers filled, dials functional, no leaks.</Bullet>
        <Bullet>Breathing circuit: low-pressure leak test, valve test, scavenging functional.</Bullet>
        <Bullet>Suction available, working, with rigid catheter.</Bullet>
        <Bullet>Emergency equipment: bag-valve-mask, oral/nasal airways, alternate laryngoscopes, drugs (succinylcholine, epinephrine, atropine).</Bullet>
      </Section>

      <p className="text-[10px] text-muted-foreground text-center pt-2">© CE Halo LLC · ABA BASIC Study Package · Module 4 · Edition 2026</p>
    </div>
  );
}