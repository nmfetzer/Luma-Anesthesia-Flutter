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

export default function ABAPharmacologyModule() {
  return (
    <div className="space-y-2 pb-4">
      {/* Intro */}
      <div className="p-4 rounded-xl bg-blue-50 border border-blue-100 mb-4">
        <p className="text-sm text-blue-900">This module reviews the pharmacology essential to safe anesthetic care: pharmacokinetics and dynamics, inhaled and IV anesthetics, opioids, neuromuscular blockade and reversal, local anesthetics, and key adjuncts. Numbers and curves dominate this section of the BASIC exam — commit the MACs, ED95s, half-lives, and toxic doses to memory.</p>
        <KEY_POINT>Concentrations matter more than doses. Pharmacokinetics describes what the body does to the drug; pharmacodynamics describes what the drug does to the body. Volume of distribution drives initial dose; clearance drives the dosing interval.</KEY_POINT>
      </div>

      {/* 3.1 PK/PD */}
      <Section title="3.1 · Pharmacokinetics & Pharmacodynamics" defaultOpen>
        <p className="font-semibold text-blue-800">Core Concepts</p>
        <Bullet>Vd (volume of distribution): dose / plasma concentration. Large Vd = lipophilic, tissue-distributed (e.g., fentanyl, propofol). Small Vd = water-soluble, plasma-confined (e.g., NMBs, heparin).</Bullet>
        <Bullet>Clearance (Cl): volume of plasma cleared per unit time. Cl = Vd × k = 0.693 × Vd / t½.</Bullet>
        <Bullet>Half-life (t½): time for concentration to fall by 50%. 5 half-lives = ~97% elimination.</Bullet>
        <Bullet>Context-sensitive half-time: time for plasma concentration to fall 50% AFTER STOPPING an infusion of a given duration — critical for selecting drugs in long cases.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Context-Sensitive Half-Times (4-hour infusion)</p>
        <Table
          headers={['Drug', 'Half-time (min)']}
          rows={[
            ['Remifentanil', '3–4 (independent of duration)'],
            ['Propofol', '30–40'],
            ['Sufentanil', '30–35'],
            ['Alfentanil', '60'],
            ['Fentanyl', '260+'],
            ['Midazolam', '60–80'],
            ['Thiopental', '150+ (saturates fat)'],
          ]}
        />
        <KEY_POINT>For long cases or when you need a predictable wake-up, choose drugs with low and duration-independent context-sensitive half-times: remifentanil, propofol, sevoflurane/desflurane.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Receptor Pharmacology</p>
        <Bullet>Agonist: binds and activates. Full agonist (fentanyl) vs partial (buprenorphine — ceiling effect).</Bullet>
        <Bullet>Antagonist: binds without activating. Competitive (naloxone, flumazenil) vs non-competitive.</Bullet>
        <Bullet>Inverse agonist: stabilizes inactive state — opposite effect to agonist.</Bullet>
        <Bullet>Tolerance: ↓ effect with repeated exposure. Tachyphylaxis: rapid tolerance (ephedrine).</Bullet>
      </Section>

      {/* 3.2 Inhaled */}
      <Section title="3.2 · Inhaled Anesthetics">
        <p className="font-semibold text-blue-800">MAC Values</p>
        <Table
          headers={['Agent', 'MAC (%)', 'Blood:gas λ', 'Notes']}
          rows={[
            ['Nitrous oxide', '104', '0.47', 'Cannot deliver 1 MAC alone; second gas effect; diffuses into closed spaces'],
            ['Halothane', '0.75', '2.4', 'Largely obsolete — hepatitis, sensitizes myocardium to catecholamines'],
            ['Isoflurane', '1.15', '1.4', 'Coronary steal (historical concern); pungent'],
            ['Sevoflurane', '2.0', '0.65', 'Non-pungent — inhalation induction; Compound A with desiccated CO₂ absorbent'],
            ['Desflurane', '6.0', '0.42', 'Fastest on/off; pungent — no inhalation induction; tachycardia with rapid ↑'],
          ]}
        />
        <KEY_POINT>1 MAC prevents movement in 50% of patients to surgical incision. 1.3 MAC suppresses movement in 95%. MAC-awake (≈0.3 MAC) prevents recall. MAC-BAR (≈1.5 MAC) blocks autonomic response.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">MAC Modifiers</p>
        <Bullet>↑ MAC: hyperthermia, hypernatremia, chronic alcohol use, infants 1–6 months (peak), MAOIs, stimulants (cocaine, amphetamines).</Bullet>
        <Bullet>↓ MAC: hypothermia, hyponatremia, pregnancy (~30%), acute alcohol intoxication, opioids, α2-agonists, age (~6% per decade after 40), severe anemia (Hb &lt;5).</Bullet>
        <Bullet>No effect on MAC: gender, duration of anesthesia, PaCO₂ (15–95), PaO₂ (&gt;40), thyroid disease, hypertension.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Uptake & Distribution — Faster Induction With:</p>
        <Bullet>Low blood:gas solubility (desflurane &gt; sevoflurane &gt; isoflurane &gt; halothane).</Bullet>
        <Bullet>High inspired concentration (overpressure technique).</Bullet>
        <Bullet>High alveolar ventilation.</Bullet>
        <Bullet>Low cardiac output (paradoxically — slower removal from alveoli, faster equilibration).</Bullet>
        <Bullet>Second-gas effect (N₂O speeds uptake of accompanying volatile).</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Systemic Effects of Volatiles</p>
        <Bullet>CV: dose-dependent ↓ MAP (primarily ↓ SVR with iso, sevo, des; ↓ contractility with halothane).</Bullet>
        <Bullet>Respiratory: ↓ Vt, ↑ RR; blunted hypoxic and hypercapnic drive; bronchodilation (useful in asthma).</Bullet>
        <Bullet>CNS: ↑ CBF (uncouples CBF from CMRO₂ above 1 MAC); EEG slowing; potentiate NMB.</Bullet>
        <Bullet>Renal: ↓ RBF, ↓ GFR (transient).</Bullet>
        <Bullet>Hepatic: all volatiles ↓ portal flow; halothane (and rarely others) → immune-mediated hepatitis.</Bullet>
        <Bullet>Uterine: dose-dependent relaxation — useful for breech delivery/retained placenta; harmful for postpartum bleeding.</Bullet>
        <KEY_POINT>Sevoflurane + desiccated CO₂ absorbent → exothermic reaction → fire risk. Sevoflurane + soda lime → Compound A (theoretical nephrotoxicity in rats; not shown in humans at clinical flows &gt;2 L/min).</KEY_POINT>
      </Section>

      {/* 3.3 IV Induction */}
      <Section title="3.3 · Intravenous Induction Agents">
        <Table
          headers={['Drug', 'Induction Dose', 'Mechanism', 'Distinguishing Features']}
          rows={[
            ['Propofol', '1.5–2.5 mg/kg', 'GABA-A potentiation', '↓ BP, ↓ SVR, ↓ CMRO₂, anti-emetic; pain on injection; PRIS in long infusions'],
            ['Etomidate', '0.2–0.3 mg/kg', 'GABA-A', 'Hemodynamic stability; adrenal suppression (≥1 dose); myoclonus; nausea'],
            ['Ketamine', '1–2 mg/kg IV; 4–6 IM', 'NMDA antagonism', '↑ HR, ↑ BP, bronchodilation, dissociative; emergence reactions; ↑ secretions; ↑ ICP (debated)'],
            ['Thiopental', '3–5 mg/kg', 'GABA-A (barbiturate)', '↓ CMRO₂ (cerebral protection); histamine release; ↑ porphyria risk; tissue necrosis if extravasated'],
            ['Methohexital', '1–2 mg/kg', 'GABA-A (barbiturate)', 'ECT (lowers seizure threshold the least)'],
            ['Dexmedetomidine', '0.5–1 µg/kg over 10 min', 'α2 agonist (locus ceruleus)', 'Sedation without respiratory depression; bradycardia, hypotension; arousable'],
            ['Midazolam', '0.1–0.3 mg/kg (induction); 1–2 mg pre-op', 'GABA-A (benzo)', 'Anxiolysis, anterograde amnesia; reversible with flumazenil'],
          ]}
        />
        <KEY_POINT>Propofol Infusion Syndrome (PRIS): metabolic acidosis, rhabdomyolysis, hyperkalemia, cardiac failure, AKI. Risk factors: &gt;4 mg/kg/hr for &gt;48 hrs, especially in critically ill children. Limit infusion in ICU sedation.</KEY_POINT>
      </Section>

      {/* 3.4 Opioids */}
      <Section title="3.4 · Opioids">
        <p className="font-semibold text-blue-800">Receptors</p>
        <Bullet>μ (mu) — analgesia, respiratory depression, euphoria, miosis, constipation, urinary retention.</Bullet>
        <Bullet>κ (kappa) — spinal analgesia, dysphoria, miosis, diuresis.</Bullet>
        <Bullet>δ (delta) — modulation of μ effects.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Common Opioids</p>
        <Table
          headers={['Drug', 'Onset (IV)', 'Duration', 'Notes']}
          rows={[
            ['Morphine', '5–10 min', '3–4 hr', 'Histamine release; active metabolite (M6G) — accumulates in renal failure'],
            ['Hydromorphone', '5 min', '3–4 hr', '5× potency of morphine; no active metabolites — safer in renal failure'],
            ['Fentanyl', '<1 min (peak 3–5)', '30–60 min (bolus)', '100× morphine; lipophilic; no histamine release; chest wall rigidity at high doses'],
            ['Sufentanil', '1–3 min', '30 min', '1000× morphine; lowest context-sensitive half-time of fentanyl family'],
            ['Alfentanil', '1 min', '10–15 min', 'Faster onset than fentanyl (mostly non-ionized at pH 7.4)'],
            ['Remifentanil', '1 min', '3–10 min', 'Metabolized by plasma esterases; ultra-short; no renal/hepatic accumulation; hyperalgesia'],
            ['Meperidine', '5 min', '2–3 hr', 'Anti-shivering; normeperidine (toxic, seizures); avoid with MAOIs (serotonin syndrome)'],
            ['Methadone', '10–20 min', '12–24 hr', 'NMDA antagonism; QT prolongation; long, variable half-life'],
          ]}
        />
        <KEY_POINT>Naloxone: 0.04–0.4 mg IV. Onset 1–2 min, duration 30–60 min (shorter than most opioids). Always anticipate re-narcotization and consider an infusion (5 µg/kg/hr) after reversal of long-acting opioid overdose.</KEY_POINT>
      </Section>

      {/* 3.5 NMB */}
      <Section title="3.5 · Neuromuscular Blockers & Reversal">
        <p className="font-semibold text-blue-800">Depolarizing — Succinylcholine</p>
        <Bullet>Dose: 1–1.5 mg/kg IV (3–4 mg/kg IM). Onset 30–60 sec; duration 5–10 min.</Bullet>
        <Bullet>Metabolized by pseudocholinesterase. Atypical/deficient enzyme → prolonged paralysis (dibucaine number 30–60 heterozygous; &lt;30 homozygous).</Bullet>
        <Bullet>Side effects: hyperkalemia (↑ K⁺ ~0.5 mEq/L; exaggerated in burns/denervation/myopathy &gt;24 hr to ~6 months), bradycardia (second dose in children), masseter spasm, MH trigger, ↑ ICP/IOP/intragastric pressure.</Bullet>
        <KEY_POINT>Avoid succinylcholine in: known/suspected MH, hyperkalemia, burns &gt;24 hr to 6 months, denervation injury (paraplegia, stroke &gt;24 hr), myopathies (DMD, Becker), severe sepsis with immobility, crush injury, prolonged immobilization.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Non-Depolarizing NMBs</p>
        <Table
          headers={['Drug', 'ED95 (mg/kg)', 'Intubation Dose', 'Duration', 'Elimination']}
          rows={[
            ['Rocuronium', '0.3', '0.6 (RSI: 1.2)', '30–60 min', 'Hepatic (biliary) > renal'],
            ['Vecuronium', '0.05', '0.1', '30–60 min', 'Hepatic & renal; active metabolite (3-desacetyl)'],
            ['Cisatracurium', '0.05', '0.15–0.2', '40–60 min', 'Hofmann elimination (organ-independent; preferred in liver/kidney failure)'],
            ['Atracurium', '0.25', '0.5', '30–45 min', 'Hofmann + ester hydrolysis; histamine release'],
            ['Pancuronium', '0.07', '0.1', '60–90 min', 'Renal; vagolytic → tachycardia'],
            ['Mivacurium', '0.08', '0.2', '15–20 min', 'Pseudocholinesterase (like succinylcholine)'],
          ]}
        />

        <p className="font-semibold text-blue-800 mt-3">Reversal Agents</p>
        <Bullet>Neostigmine: AChE inhibitor (↑ ACh at junction). Dose 0.04–0.07 mg/kg. ALWAYS co-administer glycopyrrolate (0.2 mg per 1 mg neostigmine) to block muscarinic effects. Only effective when ≥2 of 4 TOF twitches present.</Bullet>
        <Bullet>Sugammadex: encapsulates rocuronium (and vecuronium). Dose 2 mg/kg (TOF 2+), 4 mg/kg (1–2 PTC), 16 mg/kg (immediate reversal of 1.2 mg/kg roc). Side effects: bradycardia, anaphylaxis. Counsel patients: backup contraception × 7 days.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Neuromuscular Monitoring</p>
        <Bullet>Train-of-four (TOF): 4 stimuli at 2 Hz. Ratio T4/T1 reflects depth of block. Fade = non-depolarizing block.</Bullet>
        <Bullet>Post-tetanic count (PTC): for deep block when no TOF response — count twitches after 5 sec of 50 Hz tetany.</Bullet>
        <Bullet>Quantitative monitoring (acceleromyography, EMG) is the gold standard — TOF ratio ≥ 0.9 required for safe extubation.</Bullet>
      </Section>

      {/* 3.6 Local Anesthetics */}
      <Section title="3.6 · Local Anesthetics">
        <p className="font-semibold text-blue-800">Mechanism & Structure</p>
        <p className="text-sm">LAs bind the inner pore of voltage-gated sodium channels in their open/inactivated state, preventing depolarization. All consist of: lipophilic aromatic ring + intermediate chain (amide or ester) + hydrophilic amine.</p>
        <Bullet>Amides (two 'i's: lidocaine, bupivacaine, ropivacaine, mepivacaine, prilocaine, etidocaine) — hepatic metabolism.</Bullet>
        <Bullet>Esters (one 'i': procaine, chloroprocaine, tetracaine, cocaine, benzocaine) — plasma cholinesterase; PABA metabolite causes allergy.</Bullet>
        <Bullet>Potency ∝ lipid solubility. Onset ∝ pKa (closer to 7.4 = more non-ionized = faster). Duration ∝ protein binding.</Bullet>

        <p className="font-semibold text-blue-800 mt-3">Properties</p>
        <Table
          headers={['Drug', 'pKa', 'Onset', 'Duration', 'Max Dose (mg/kg)']}
          rows={[
            ['Lidocaine', '7.9', 'Fast', '1–2 hr', '4.5 (7 with epi)'],
            ['Mepivacaine', '7.6', 'Fast', '1.5–3 hr', '4.5 (7 with epi)'],
            ['Bupivacaine', '8.1', 'Slow', '3–8 hr', '2.5 (3 with epi)'],
            ['Ropivacaine', '8.1', 'Slow', '3–8 hr', '3'],
            ['Chloroprocaine', '8.7', 'Fast', '30–60 min', '11 (14 with epi)'],
            ['Tetracaine', '8.5', 'Slow', '2–4 hr (spinal)', '1.5'],
          ]}
        />
        <KEY_POINT>Bicarbonate added to LA (1 mEq per 10 mL lidocaine) raises pH → more non-ionized drug → faster onset. Reduces injection pain. Excess bicarbonate causes precipitation.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Local Anesthetic Systemic Toxicity (LAST)</p>
        <p className="text-sm">Progression: tongue numbness/tinnitus/perioral paresthesia → confusion, drowsiness → seizures → CNS depression/coma → CV collapse.</p>
        <Bullet>Bupivacaine has the highest cardiotoxicity — 'fast-in, slow-out' Na-channel binding; LAST often presents as cardiac arrest first.</Bullet>
        <Bullet>Ropivacaine and levobupivacaine — lower CV toxicity than racemic bupivacaine.</Bullet>
        <KEY_POINT>LAST treatment: STOP injection, call for help, 100% O₂, benzodiazepines for seizures (avoid propofol if CV-unstable), epinephrine ≤1 µg/kg. LIPID EMULSION 20%: 1.5 mL/kg IV bolus → 0.25 mL/kg/min infusion; max 12 mL/kg. AVOID vasopressin, CCBs, β-blockers, lidocaine.</KEY_POINT>

        <p className="font-semibold text-blue-800 mt-3">Methemoglobinemia</p>
        <p className="text-sm">Triggered by benzocaine, prilocaine, dapsone, nitrates. Hb iron oxidized Fe²⁺ → Fe³⁺ — cannot carry O₂. SpO₂ reads ~85% regardless of true sat. Treatment: methylene blue 1–2 mg/kg IV (avoid in G6PD deficiency — use ascorbic acid).</p>
      </Section>

      {/* 3.7 Adjuncts */}
      <Section title="3.7 · Selected Adjuncts">
        <p className="font-semibold text-blue-800">Anticholinergics</p>
        <Table
          headers={['Drug', 'CNS Penetration', 'Mydriasis', 'Antisialagogue', 'HR Effect']}
          rows={[
            ['Atropine', 'Yes (central syndrome possible)', '++', '+', '↑↑'],
            ['Glycopyrrolate', 'No (quaternary amine)', '0', '+++', '↑'],
            ['Scopolamine', 'Yes (sedation, amnesia)', '+++', '++', '↑ (mild)'],
          ]}
        />

        <p className="font-semibold text-blue-800 mt-3">Sympathomimetics</p>
        <Table
          headers={['Drug', 'Receptors', 'Use', 'Notes']}
          rows={[
            ['Phenylephrine', 'α1 (pure)', '↑ SVR, ↑ BP', 'Reflex bradycardia; favored in AS, HOCM, pregnancy'],
            ['Ephedrine', 'α + β (indirect via NE release)', '↑ BP, ↑ HR', 'Tachyphylaxis; less placental crossover (now phenylephrine preferred in OB)'],
            ['Epinephrine', 'α1, α2, β1, β2 (dose-dependent)', 'Cardiac arrest, anaphylaxis, low CO', '1–10 µg bolus; 0.01–0.1 µg/kg/min'],
            ['Norepinephrine', 'α1 >> β1', 'Septic shock first-line', '↑ SVR; modest inotropy'],
            ['Dopamine', 'Dopa < β < α (dose-dependent)', 'Low CO + bradycardia', 'Largely replaced by NE'],
            ['Dobutamine', 'β1 > β2 > α', 'Cardiogenic shock; stress testing', '↑ contractility, ↓ SVR'],
            ['Isoproterenol', 'β1 = β2', 'Heart block, bradycardia', '↑ HR, ↓ DBP'],
            ['Vasopressin', 'V1 (vascular), V2 (renal)', 'Vasoplegia, septic shock adjunct', 'Useful with acidosis (catecholamines fail)'],
            ['Milrinone', 'PDE-3 inhibitor', 'Low CO, pulmonary HTN', 'Inotrope + pulmonary vasodilator; ↓ SVR'],
          ]}
        />

        <p className="font-semibold text-blue-800 mt-3">Antihypertensives & Vasodilators</p>
        <Bullet>Nitroglycerin: predominantly venodilator → ↓ preload; coronary dilation.</Bullet>
        <Bullet>Nitroprusside: arterial + venous dilator; cyanide toxicity risk at &gt;2 µg/kg/min for prolonged periods.</Bullet>
        <Bullet>Nicardipine, clevidipine: CCB; smooth BP control without reflex tachycardia.</Bullet>
        <Bullet>Esmolol: ultra-short β1-selective; bolus 0.5 mg/kg, infusion 50–200 µg/kg/min.</Bullet>
        <Bullet>Labetalol: α + β (β:α ≈ 7:1 IV); useful in pregnancy and pheo crisis.</Bullet>
        <Bullet>Hydralazine: direct arterial dilator; slow onset, long duration, reflex tachycardia.</Bullet>
      </Section>

      <p className="text-[10px] text-muted-foreground text-center pt-2">© CE Halo LLC · ABA BASIC Study Package · Module 3 · Edition 2026</p>
    </div>
  );
}