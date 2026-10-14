import { useState } from 'react';
import { ChevronDown, ChevronUp, BookOpen } from 'lucide-react';

const SECTIONS = [
  {
    id: 'gas_supply',
    title: 'Section 1: Medical Gas Supply Systems',
    color: 'bg-blue-50 border-blue-200',
    emoji: '🔵',
    topics: [
      {
        heading: 'Pipeline Gas Supply',
        bullets: [
          'Hospital pipeline systems supply medical gases at ~50–55 psi (the primary source during normal operation).',
          'Pipeline gases include oxygen (O2), nitrous oxide (N2O), air, and nitrogen.',
          'The Diameter Index Safety System (DISS) is a standardized, non-interchangeable threaded connector that prevents misconnection of different gas hoses at the anesthesia machine.',
        ],
        table: {
          headers: ['Gas', 'Pipeline Pressure (psi)', 'Color Code (USA)', 'Primary Use'],
          rows: [
            ['Oxygen (O2)', '50–55', 'Green', 'Carrier gas, patient oxygenation'],
            ['Nitrous Oxide (N2O)', '50–55', 'Blue', 'Analgesia, adjunct anesthetic'],
            ['Medical Air', '50–55', 'Yellow', 'Carrier gas, ventilator drive'],
            ['Nitrogen (N2)', '160–200', 'Black', 'Powers pneumatic equipment'],
          ],
        },
      },
      {
        heading: 'E-Cylinder Gas Supply',
        bullets: [
          'E-cylinders are the backup gas supply mounted on the anesthesia machine yoke.',
          'The Pin Index Safety System (PISS) prevents attachment of the wrong cylinder to the wrong yoke — each gas has a unique pin configuration.',
          '⚡ KEY: Oxygen is stored as COMPRESSED GAS — pressure is directly proportional to remaining volume. A half-full O2 E-cylinder reads ~1100 psi.',
          '⚡ KEY: Nitrous oxide is stored as a LIQUID — pressure remains constant at ~745 psi until all liquid is vaporized. You CANNOT estimate remaining N2O by pressure alone; you must WEIGH the cylinder.',
          'Duration formula: O2 Duration (min) = [Pressure (psi) × 0.3] ÷ Flow rate (L/min). Example: 1000 psi at 5 L/min → 60 minutes.',
        ],
        table: {
          headers: ['Gas', 'Full Pressure (psi)', 'Volume (Liters)', 'Color (USA)', 'Storage State'],
          rows: [
            ['Oxygen (O2)', '~2200', '~660 L', 'Green', 'Compressed gas'],
            ['Nitrous Oxide (N2O)', '~745', '~1590 L', 'Blue', 'Liquid + vapor'],
            ['Air', '~1900', '~625 L', 'Yellow', 'Compressed gas'],
            ['CO2', '~838', '~940 L', 'Gray', 'Liquid + vapor'],
          ],
        },
      },
      {
        heading: 'Fail-Safe System & Low-Pressure Alarms',
        bullets: [
          'The fail-safe system (pressure sensor shut-off valve) monitors O2 supply pressure.',
          'If O2 pressure falls below ~25–30 psi, the fail-safe valve automatically shuts off all other gases (N2O, air) to prevent delivery of a hypoxic mixture.',
          '⚠️ The fail-safe does NOT guarantee adequate oxygen supply — it only monitors pressure, not concentration.',
          'Low O2 pressure alarm (audible) activates when O2 pipeline pressure falls below ~30 psi.',
          'Modern machines include a minimum O2 ratio controller (Link-25 / Ratio-Master) that maintains at least 25% O2 in the fresh gas mixture.',
          '⚠️ Critical: The fail-safe does NOT protect against crossed pipelines during hospital construction.',
          'H-cylinders: Large free-standing cylinders. An H-cylinder of O2 contains ~6,900 liters at ~2200 psi.',
        ],
      },
    ],
  },
  {
    id: 'anesthesia_machine',
    title: 'Section 2: The Anesthesia Machine',
    color: 'bg-teal-50 border-teal-200',
    emoji: '⚙️',
    topics: [
      {
        heading: 'Gas Flow Path (High → Low Pressure)',
        table: {
          headers: ['Component', 'Description'],
          rows: [
            ['Gas Source', 'Pipeline (50 psi) or E-Cylinder (2200 psi O2)'],
            ['1st-Stage Regulator', 'Reduces cylinder pressure to ~45 psi'],
            ['Check Valves', 'Prevents backflow between pipeline and cylinder sources'],
            ['Fail-Safe Valve', 'Shuts off N2O/Air if O2 pressure drops below threshold'],
            ['Flow Control Valves', 'Needle valves controlled by flowmeter knobs (O2, N2O, Air)'],
            ['Flowmeters (Rotameters)', 'Calibrated glass tubes measuring gas flow in L/min'],
            ['Min O2 Ratio Controller', 'Ensures minimum 25% O2 in fresh gas mixture'],
            ['Vaporizer', 'Agent-specific; adds volatile anesthetic vapor to gas stream'],
            ['Common Gas Outlet', 'Combined gas mixture exits machine to breathing circuit'],
            ['Patient Airway', 'ETT, LMA, mask — gas delivered to patient'],
          ],
        },
      },
      {
        heading: 'Flowmeters (Rotameters)',
        bullets: [
          'Precision-calibrated, gas-specific glass or acrylic tubes containing a lightweight float (bobbin or ball).',
          'Flow rate is read at the top of the float (ball) or midpoint of the bobbin.',
          'On North American machines, OXYGEN is always on the RIGHT (closest to the common gas outlet) — prevents hypoxic mixtures in case of flowmeter tube cracks.',
          'At low flows, the annular space is primarily determined by tube diameter (viscosity-dependent).',
          'At high flows, float height is primarily determined by gas density.',
          'Flowmeters are gas-specific and non-interchangeable.',
        ],
      },
      {
        heading: 'Pressure Regulators',
        table: {
          headers: ['Regulator', 'Location', 'Input Pressure', 'Output Pressure', 'Function'],
          rows: [
            ['First-Stage (High-Pressure)', 'At cylinder yoke', '~2200 psi (O2 cylinder)', '~45 psi', 'Reduces cylinder pressure to match pipeline'],
            ['Second-Stage', 'Within machine', '~50 psi (pipeline/1st stage)', '~14–16 psi', 'Provides stable, low pressure to flowmeters'],
            ['Oxygen Flush Valve', 'Direct pipeline', '50 psi', '35–75 L/min', 'Bypasses all regulators; delivers 100% O2 directly'],
          ],
        },
      },
      {
        heading: 'Oxygen Flush Valve & Vaporizers',
        bullets: [
          'Oxygen flush valve delivers 100% oxygen at 35–75 L/min directly to the common gas outlet, bypassing the flowmeters AND vaporizer.',
          '⚠️ Cautions: (1) Barotrauma risk if used during inspiration; (2) Dilutes volatile agent — can cause awareness; (3) Valve sticking delivers continuous high O2 flow.',
          'Modern vaporizers are variable-bypass, temperature-compensated, agent-specific (e.g., Datex-Ohmeda Tec 7, Draeger Vapor 2000).',
          '⚡ KEY: Desflurane requires a SPECIAL electrically-heated, pressurized vaporizer (Tec 6) — boiling point 22.8°C is near room temperature; cannot use standard variable-bypass.',
          'Vaporizers are interlocked — only one can be active at a time.',
          'Tipping effect: Tilting a vaporizer can allow liquid anesthetic into the bypass chamber, causing a massive overdose. Transport upright.',
        ],
        table: {
          headers: ['Agent', 'Vaporizer Type', 'Boiling Point', 'SVP at 20°C', 'Notes'],
          rows: [
            ['Sevoflurane', 'Tec 7 / Vapor 2000S', '58.5°C', '157 mmHg', 'Standard variable-bypass; most common in USA'],
            ['Desflurane', 'Tec 6 Plus / D-Vapor', '22.8°C', '664 mmHg', 'Electrically heated & pressurized; NOT standard'],
            ['Isoflurane', 'Tec 5 / Vapor 19.n', '48.5°C', '238 mmHg', 'Standard variable-bypass'],
          ],
        },
      },
      {
        heading: 'Anesthesia Machine Pre-Use Check (10-Step FDA)',
        bullets: [
          '1. Auxiliary O2 supply (self-inflating bag/E-cylinder) available',
          '2. Pipeline pressures adequate (~50 psi all gases)',
          '3. E-cylinder backup pressure adequate (O2 >1000 psi)',
          '4. Low-pressure circuit leak test (negative pressure or positive pressure test)',
          '5. Flowmeter function and O2 ratio controller',
          '6. Vaporizer fill level and no leaks',
          '7. CO2 absorbent color and adequacy',
          '8. Breathing circuit integrity (unidirectional valves, mask seal)',
          '9. Scavenging system connected and functional',
          '10. Monitors and alarms active and properly calibrated',
          '⚡ KEY: Negative pressure (Madison) leak test checks the low-pressure circuit (flowmeters through vaporizer to common gas outlet). Must pass before every case.',
        ],
      },
    ],
  },
  {
    id: 'breathing_circuits',
    title: 'Section 3: Breathing Circuits & CO2 Absorption',
    color: 'bg-green-50 border-green-200',
    emoji: '🔄',
    topics: [
      {
        heading: 'Circle Breathing System',
        bullets: [
          'The most commonly used breathing circuit in the USA.',
          'Allows rebreathing of exhaled gases after CO2 removal, conserving heat, moisture, and volatile agents.',
          'Low-flow anesthesia (total FGF <1 L/min) is possible with the circle system due to CO2 absorption.',
          'Risks at low flows: compound A accumulation (sevoflurane), CO production (desflurane/isoflurane + desiccated absorbent).',
        ],
        table: {
          headers: ['Component', 'Function'],
          rows: [
            ['Fresh Gas Inlet', 'Enters between absorber and inspiratory valve; delivers fresh O2/agent mix'],
            ['Inspiratory Unidirectional Valve', 'Ensures one-way gas flow toward patient (opens on inspiration)'],
            ['Expiratory Unidirectional Valve', 'Ensures one-way gas flow away from patient (opens on expiration)'],
            ['CO2 Absorber Canister', 'Contains soda lime or Amsorb; removes CO2 from exhaled gas'],
            ['APL Valve (Pop-off)', 'Limits maximum circuit pressure; vents excess gas to scavenging'],
            ['Reservoir Bag', 'Allows manual ventilation; buffers gas volume'],
            ['Y-Piece', 'Connects inspiratory and expiratory limbs to patient airway device'],
          ],
        },
      },
      {
        heading: 'CO2 Absorbents',
        bullets: [
          '⚡ KEY: Violet/purple color in soda lime = EXHAUSTED absorbent. Replace immediately. Color may partially revert to white after resting (regeneration) — this does NOT restore function.',
          '⚡ KEY: Desiccated absorbent + desflurane or isoflurane → carbon monoxide (CO) production. More common on Monday mornings when machines have had high O2 flows all weekend. Turn off fresh gas flows when not in use.',
        ],
        table: {
          headers: ['Absorbent', 'Composition', 'Color Change (exhausted)', 'Compound A Risk', 'CO Risk'],
          rows: [
            ['Soda Lime', 'Ca(OH)2 + NaOH/KOH + water', 'White → Pink/Violet', 'Yes (with sevoflurane)', 'Low-Moderate'],
            ['Baralyme', 'Ba(OH)2 + Ca(OH)2', 'White → Violet', 'Yes (higher than soda lime)', 'Higher (largely discontinued)'],
            ['Amsorb Plus', 'Ca(OH)2 + Ca(Cl)2 (no NaOH/KOH)', 'White → Violet', 'Minimal', 'Minimal — safer with all agents'],
          ],
        },
      },
      {
        heading: 'Mapleson Circuits',
        bullets: [
          'Non-rebreathing (or minimal rebreathing) systems used for pediatric anesthesia, transport, and specific clinical situations.',
          '⚡ KEY: Bain circuit check — before use, occlude the inner fresh gas tube while applying a low flow; if the flowmeter bobbin drops, the inner tube is intact (Pethick test).',
        ],
        table: {
          headers: ['Circuit', 'Common Name', 'Best For', 'FGF (Spontaneous)', 'FGF (Controlled)'],
          rows: [
            ['Mapleson A', 'Magill / Lack', 'Spontaneous ventilation', 'Equal to MV', '2–3× MV'],
            ['Mapleson D', 'Bain Circuit (coaxial)', 'Controlled ventilation', '2–3× MV', '70 mL/kg/min'],
            ['Mapleson E', "Ayre's T-piece", 'Pediatric (no bag, <10 kg)', '2–3× MV', '2–3× MV'],
            ['Mapleson F', 'Jackson-Rees (modified T-piece)', 'Pediatric', '2–3× MV', '2–3× MV'],
          ],
        },
      },
      {
        heading: 'Scavenging Systems (AGSS)',
        bullets: [
          'Anesthesia gas scavenging system (AGSS) captures waste anesthetic gases from the APL valve and ventilator relief valve, preventing OR pollution.',
          'Chronic exposure linked to: spontaneous abortion, hepatotoxicity, and neurological effects in healthcare workers.',
          'Components: gas-collecting assembly → transfer tubing → scavenging interface → disposal assembly (active vacuum or passive flow).',
          'Interface contains pressure-relief valves to prevent both positive pressure (barotrauma) and negative pressure (lung collapse).',
          'OSHA limits: trace N2O levels <25 ppm; trace halogenated agents <2 ppm (0.5 ppm when used with N2O).',
        ],
      },
    ],
  },
  {
    id: 'laryngoscopes',
    title: 'Section 4: Airway Equipment — Laryngoscopes',
    color: 'bg-red-50 border-red-200',
    emoji: '🔦',
    topics: [
      {
        heading: 'Direct Laryngoscopy Blades',
        bullets: [
          'Direct laryngoscopy (DL) uses a rigid laryngoscope handle and blade to directly visualize the glottis.',
          'Cormack-Lehane (C-L) grading: Grade I = full glottis; Grade II = posterior commissure only; Grade III = epiglottis only; Grade IV = no laryngeal structures.',
          '⚡ KEY: BURP maneuver (Backward, Upward, Rightward Pressure on the thyroid cartilage) applied by an assistant can improve C-L grade during difficult laryngoscopy.',
        ],
        table: {
          headers: ['Blade', 'Type', 'Size Range', 'Technique', 'Best Used For'],
          rows: [
            ['Macintosh', 'Curved', '0–4 (adult: 3–4)', 'Tip in vallecula (epiglottis indirectly lifted)', 'Most common adult blade; wider flange displaces tongue easily'],
            ['Miller', 'Straight', '0–4 (adult: 2–3)', 'Tip under epiglottis (directly lifts it)', 'Pediatrics, anterior airways, long floppy epiglottis'],
            ['McCoy', 'Curved with articulating tip', '3', 'Tip in vallecula; lever lifts epiglottis', 'Difficult/anterior airways; improves grade by 1–2'],
          ],
        },
      },
      {
        heading: 'Video Laryngoscopy',
        bullets: [
          'Video laryngoscopes (VL) use a camera mounted at the blade tip to project a magnified, indirect view onto a screen.',
          'Improve laryngoscopic view by 1–2 grades vs. DL; invaluable for anticipated and unanticipated difficult airways.',
          '⚡ KEY: An excellent VL view does NOT guarantee easy intubation. The hyperangulated blade requires a matching rigid stylet. Inability to navigate the ETT through the curve despite a great view is a recognized failure mode.',
          'Indications: anticipated difficult airway, obesity, limited cervical spine mobility, limited mouth opening, previous difficult intubation, rescue after failed DL.',
        ],
        table: {
          headers: ['Device', 'Blade Type', 'Channeled?', 'Key Feature'],
          rows: [
            ['GlideScope (Verathon)', 'Hyperangulated (60°)', 'No', 'Most widely studied VL; excellent view; requires stylet'],
            ['McGRATH MAC', 'Standard curved geometry', 'No', 'Familiar Mac blade angle; easier to intubate once view obtained'],
            ['C-MAC (Karl Storz)', 'Mac shape + D-Blade hyperangulated', 'No', 'DL + VL in same blade; D-Blade for difficult airways'],
            ['King Vision', 'Channeled or non-channeled', 'Yes (channeled)', 'Disposable; channel guides ETT'],
            ['Airtraq', 'Optical/camera channeled', 'Yes', 'Disposable; good for limited mouth opening'],
          ],
        },
      },
    ],
  },
  {
    id: 'fiberoptic',
    title: 'Section 5: Flexible Bronchoscopy & Fiberoptic Intubation',
    color: 'bg-purple-50 border-purple-200',
    emoji: '🔭',
    topics: [
      {
        heading: 'Flexible Fiberoptic Bronchoscope (FOB)',
        bullets: [
          'Transmits light and images via thousands of bundled optical fibers (fiberoptic) or via a CCD camera chip at the tip (videobronchoscope).',
          'Intubating bronchoscopes have an outer diameter (OD) of 3.5–6.0 mm. ETT must have an ID at least 1 mm larger than the bronchoscope OD.',
          'Most adult AFOI is performed with a 4.0–5.5 mm OD scope through a ≥6.0 mm ID ETT.',
        ],
        table: {
          headers: ['Component', 'Function'],
          rows: [
            ['Insertion cord (shaft)', 'Flexible shaft containing fiberoptic bundles, working channel, and control wires'],
            ['Bending section (distal tip)', 'Angulates up/down (180°/130° typical) via control lever'],
            ['Working channel (suction/biopsy)', 'Allows suction, O2 delivery, local anesthetic injection, and instrument passage'],
            ['Angulation control lever', 'Up/down deflection of distal tip'],
          ],
        },
      },
      {
        heading: 'Awake Fiberoptic Intubation (AFOI)',
        bullets: [
          '⚡ KEY: AFOI is the GOLD STANDARD technique for managing the anticipated difficult airway.',
          'The patient is kept awake with topical anesthesia and light sedation while the scope is passed nasally or orally into the trachea, then the ETT is railroaded over the scope.',
          'AFOI indications: anticipated difficult airway with full stomach, unstable C-spine, restricted mouth opening, large neck/mediastinal mass, airway pathology, or any situation where loss of airway could be catastrophic.',
          'Topical anesthesia: Lidocaine 4% atomized to oropharynx, larynx, trachea; transtracheal block (2–3 mL lidocaine 4% through cricothyroid membrane).',
          'Superior laryngeal nerve block (bilateral): 2–3 mL lidocaine 2% at superior cornu of thyroid cartilage.',
          'Best sedation: Dexmedetomidine (sedation + mild analgesia without suppressing airway reflexes); midazolam (amnesia/anxiolysis); remifentanil (caution at higher doses).',
          'Nasal AFOI: Decongest with oxymetazoline (Afrin), lubricate nasal passage, choose wider nostril.',
          'Oral AFOI: Use a Berman or Ovassapian intubating airway to guide and protect the scope.',
        ],
      },
    ],
  },
  {
    id: 'ett',
    title: 'Section 6: Endotracheal Tubes (ETTs)',
    color: 'bg-orange-50 border-orange-200',
    emoji: '🩺',
    topics: [
      {
        heading: 'Standard ETT Sizing',
        bullets: [
          'ETTs are sized by internal diameter (ID) in millimeters.',
          '⚡ KEY: Cuff pressure >30 cmH2O risks tracheal mucosal ischemia, necrosis, and post-extubation stenosis. Always check cuff pressure with a manometer — especially during N2O anesthesia (N2O diffuses into the cuff and increases pressure over time).',
          'High-volume, low-pressure (HVLP) cuff: maintain at 20–30 cmH2O.',
        ],
        table: {
          headers: ['Age/Patient', 'ETT ID (mm)', 'Depth at Lips (cm)', 'Notes'],
          rows: [
            ['Premature neonate', '2.5–3.0', '6–8 cm', 'Uncuffed preferred in very small neonates'],
            ['Neonate (term)', '3.0–3.5', '9–10 cm', ''],
            ['6 months', '3.5–4.0', '11–12 cm', ''],
            ['1 year', '4.0', '12 cm', ''],
            ['Pediatric (>1 yr)', 'Age/4 + 4 (uncuffed); Age/4 + 3.5 (cuffed)', 'Age/2 + 12 (oral)', 'Cuffed tubes increasingly used in peds'],
            ['Adult Female', '7.0–7.5', '21–23 cm', ''],
            ['Adult Male', '7.5–9.0', '23–25 cm', ''],
          ],
        },
      },
      {
        heading: 'Specialized ETT Types',
        table: {
          headers: ['ETT Type', 'Key Feature', 'Clinical Use'],
          rows: [
            ['RAE Tube', 'Pre-formed oral or nasal curve; keeps circuit away from surgical field', 'Oral/facial surgery, rhinoplasty, sinus surgery'],
            ['Reinforced (Armored) ETT', 'Stainless steel wire spiral embedded in PVC; kink-resistant', 'Prone positioning, head-and-neck surgery, neurosurgery, Trendelenburg'],
            ['Double-Lumen Tube (DLT)', 'Two parallel lumens (bronchial + tracheal); independent lung ventilation', 'Thoracic surgery, one-lung ventilation (OLV) — requires FOB confirmation'],
            ['Microlaryngoscopy Tube (MLT)', 'Long, narrow ID (4.0–5.0 mm); allows vocal cord visualization', 'Laryngeal/glottic surgery'],
            ['Laser-Safe ETT', 'Metal foil or silicone wrapping; reflects laser energy; saline-filled cuff', 'CO2, Nd:YAG, KTP laser surgery on/near the airway — prevents airway fire'],
            ['Subglottic Suction ETT', 'Additional dorsal suction lumen above cuff', 'ICU ventilated patients; aspirates subglottic secretions, reduces VAP'],
            ['Endobronchial Blocker', 'Separate blocker advanced through ETT into mainstem bronchus', 'OLV when DLT cannot be used; useful in patients already intubated'],
          ],
        },
      },
      {
        heading: 'Double-Lumen Tubes (DLTs)',
        bullets: [
          'Most commonly used device for one-lung ventilation (OLV) in thoracic surgery.',
          'Left-sided DLTs are safer (longer left mainstem bronchus); two lumens: one ending in trachea, one extending into left mainstem bronchus.',
          'Sizing: Women <160 cm → 35Fr | Women >160 cm → 37Fr | Men <170 cm → 39Fr | Men >170 cm → 41Fr.',
          'CT measurement of left mainstem bronchus diameter is the most accurate sizing method.',
          '⚡ KEY: ALWAYS confirm DLT position with FOB after initial placement AND after patient repositioning (lateral decubitus position can cause DLT migration).',
          'Via tracheal lumen: tracheal carina should be visible; blue bronchial cuff just below carina in left mainstem bronchus.',
          'Via bronchial lumen: left upper lobe takeoff and left lower lobe bronchus should be visible.',
        ],
      },
    ],
  },
  {
    id: 'sgas',
    title: 'Section 7: Supraglottic Airway Devices (SGAs)',
    color: 'bg-pink-50 border-pink-200',
    emoji: '💨',
    topics: [
      {
        heading: 'SGA Overview & Generations',
        bullets: [
          'SGAs sit above the glottis, forming a low-pressure seal against the periglottic structures.',
          'Used for: (1) routine airway management when ETT not required; (2) rescue devices in difficult/failed intubation; (3) conduits for fiberoptic intubation.',
          '⚡ KEY — Contraindications to SGA use: full stomach (relative), pharyngeal pathology, restricted mouth opening <2.5 cm, morbid obesity (relative), prolonged prone positioning, airway pressures >20 cmH2O needed.',
        ],
        table: {
          headers: ['Generation', 'Examples', 'Drain Tube?', 'Aspiration Protection', 'Key Feature'],
          rows: [
            ['First-generation', 'LMA Classic, LMA Unique', 'No', 'Limited', 'Simple bowl-shaped cuff; reusable or disposable'],
            ['Second-generation', 'LMA Supreme, LMA ProSeal, i-gel', 'Yes', 'Better — allows gastric decompression', 'Integral drain tube reduces aspiration risk; higher seal pressure'],
            ['Intubating', 'LMA Fastrach (iLMA), AirQ (ILA)', 'No', 'Limited', 'Designed to facilitate ETT passage (blind or FOB-guided)'],
          ],
        },
      },
      {
        heading: 'Common SGAs in Detail',
        bullets: [
          '⚡ KEY: i-gel advantages — No cuff inflation, no cuff pressure concerns, fast insertion, integral drain channel. Consider for difficult cuff management or when speed of insertion is critical.',
        ],
        table: {
          headers: ['Device', 'Type', 'Cuff Material', 'Max Seal (cmH2O)', 'Key Points'],
          rows: [
            ['LMA Classic', '1st gen, reusable', 'PVC inflatable', '~20', 'Gold standard; 8 uses before replacement; sizes 1–6'],
            ['LMA ProSeal', '2nd gen, reusable', 'Dual cuff (dorsal+ventral)', '~30', 'Highest seal of all LMAs; drain tube for gastric suctioning'],
            ['LMA Supreme', '2nd gen, disposable', 'Elliptical PVC, rigid shaft', '~25', 'Pre-curved rigid airway tube, integrated bite block, drain tube'],
            ['i-gel', '2nd gen, disposable', 'Thermoplastic elastomer (non-inflatable)', '~25–30', 'No inflation required; non-inflatable cuff conforms to anatomy; integral drain channel'],
            ['LMA Fastrach (iLMA)', 'Intubating, reusable', 'PVC inflatable', '~20', 'Rigid, handle-equipped; allows blind or FOB-guided ETT insertion; size 3–5'],
          ],
        },
      },
    ],
  },
  {
    id: 'adjuncts',
    title: 'Section 8: Additional Airway Adjuncts & Equipment',
    color: 'bg-yellow-50 border-yellow-200',
    emoji: '🛠️',
    topics: [
      {
        heading: 'Oral & Nasal Airways + Accessories',
        table: {
          headers: ['Device', 'Sizing', 'Mechanism', 'Key Points'],
          rows: [
            ['Oropharyngeal Airway (OPA / Guedel)', 'Center of mouth to earlobe; 60–110 mm (adult: 80–100 mm)', 'Displaces tongue anteriorly; maintains pharyngeal patency', 'Tolerated only in deeply unconscious patients — stimulates gag reflex; causes laryngospasm risk'],
            ['Nasopharyngeal Airway (NPA)', 'ID 6–9 mm; length = nostril to earlobe (~15–20 cm)', 'Maintains nasal patency; bypasses tongue', 'Tolerated in lightly sedated patients; avoid in skull base fracture, coagulopathy, nasal polyps'],
            ['Stylet (malleable intubating)', 'Fits inside ETT; bent to desired angle', 'Gives rigidity and shape to ETT', 'Tip should NOT extend beyond ETT tip; lubricate to allow easy withdrawal'],
            ['Bougie (Eschmann / gum elastic)', '60 cm, 15 Fr; coude (angled) tip', 'Passed blindly under epiglottis; tracheal clicks felt over tracheal rings; ETT railroaded over bougie', 'Essential rescue tool for grade III/IV DL; "hold-up" sign confirms bronchial placement (not esophagus)'],
            ['Magill Forceps', 'Angled metal forceps', 'Directs nasal ETT or foreign body into glottis during laryngoscopy', 'Used during nasotracheal intubation and foreign body removal'],
          ],
        },
      },
      {
        heading: 'Cricothyrotomy Devices (eFONA)',
        bullets: [
          'Cricothyrotomy is the rescue technique for CICO (cannot intubate, cannot oxygenate) emergencies.',
          'Access the airway through the cricothyroid membrane (CTM) — located between thyroid and cricoid cartilages.',
          "⚡ KEY: The 'Scalpel-Bougie' technique is the recommended eFONA method (DAS 2015 guidelines): Stab → dilate (caudal traction on trachea) → insert bougie → railroad 6.0 ETT → inflate cuff → confirm.",
        ],
        table: {
          headers: ['Technique', 'Device', 'Time to O2', 'Notes'],
          rows: [
            ['Needle Cricothyrotomy (jet ventilation)', '14–16G IV catheter + jet ventilator', 'Fast (~30 sec)', 'Oxygenation ONLY — CO2 builds up; buys time <30–45 min; risk of barotrauma with obstruction'],
            ['Melker Percutaneous (Seldinger)', 'Melker kit — guidewire + dilator + cuffed airway catheter (4–6 mm ID)', 'Moderate (~60–90 sec)', 'Provides oxygenation AND ventilation; can connect to standard circuit'],
            ['Surgical Cricothyrotomy', 'Scalpel + tracheal hook + 6.0 ETT or Bougie-assisted', 'Moderate (~60 sec)', 'Most reliable; recommended for failed airway in adults; scalpel-bougie technique'],
          ],
        },
      },
      {
        heading: 'Additional Intubation Accessories',
        bullets: [
          'HFNO / THRIVE: Heated, humidified oxygen at 30–70 L/min via nasal cannula. Creates apneic oxygenation via mass-flow effect and generates low PEEP. Extends safe apnea time up to 65+ minutes.',
          'ETCO2 colorimetric detector: Disposable chemical detector that changes color in CO2; confirms tracheal intubation.',
          'Esophageal detector device (EDD / bulb syringe): Esophagus collapses (no refill) = esophageal; trachea resists collapse (refills) = tracheal.',
          'Tube exchanger (airway exchange catheter): Hollow, flexible catheter; can be left in trachea while ETT is changed over it.',
          'HME (Heat and Moisture Exchanger): Passive humidifier/filter; conserves heat and moisture; placed between circuit Y-piece and ETT.',
        ],
      },
    ],
  },
  {
    id: 'ventilators',
    title: 'Section 9: Anesthesia Ventilators & Ventilation Modes',
    color: 'bg-cyan-50 border-cyan-200',
    emoji: '💨',
    topics: [
      {
        heading: 'Common Ventilation Modes',
        table: {
          headers: ['Mode', 'Abbreviation', 'Controlled Parameter', 'Clinical Use'],
          rows: [
            ['Volume Control Ventilation', 'VCV', 'Tidal volume (fixed); pressure varies', 'Standard mode; predictable tidal volumes; risks barotrauma with high airway resistance'],
            ['Pressure Control Ventilation', 'PCV', 'Peak airway pressure (fixed); volume varies', 'Improved gas distribution; reduced barotrauma risk; tidal volume varies with compliance changes'],
            ['Pressure Support Ventilation', 'PSV', 'Patient-triggered; pressure support boosts patient effort', 'Weaning; spontaneous breathing support; reduces work of breathing'],
            ['SIMV', 'SIMV', 'Mandatory breaths + patient spontaneous breaths', 'Weaning; allows some patient control'],
            ['PEEP', 'PEEP', 'Maintains positive pressure at end-expiration', 'Prevents alveolar collapse; improves oxygenation; standard 5 cmH2O in most cases'],
            ['PRVC / VC+', 'PRVC', 'Dual-control; targets set volume with lowest possible pressure', 'Combines benefits of VCV and PCV; available on newer anesthesia machines'],
          ],
        },
      },
      {
        heading: 'Key Ventilator Settings & Targets',
        table: {
          headers: ['Parameter', 'Typical Setting', 'Notes'],
          rows: [
            ['Tidal Volume (Vt)', '6–8 mL/kg IBW', 'Lung-protective; lower in ARDS (4–6 mL/kg IBW)'],
            ['Respiratory Rate (RR)', '10–14 breaths/min', 'Adjust to maintain ETCO2 35–45 mmHg'],
            ['I:E Ratio', '1:2 (standard)', 'Lengthen expiratory time (1:3–1:4) in obstructive lung disease (COPD, asthma)'],
            ['PEEP', '5 cmH2O (routine)', 'Higher in obese patients (8–10 cmH2O); individualized in ARDS'],
            ['Peak Inspiratory Pressure (PIP)', 'Monitor; ideally <30 cmH2O', 'High PIP = increased airway resistance or decreased compliance'],
            ['Plateau Pressure (Pplat)', 'Keep <28–30 cmH2O', 'Reflects alveolar pressure; driving pressure = Pplat − PEEP; target <15 cmH2O'],
            ['FiO2', 'Start 1.0; titrate to SpO2 >95%', 'Minimize FiO2 to avoid absorption atelectasis and O2 toxicity'],
            ['ETCO2', '35–45 mmHg', 'Adjust RR or Vt; ETCO2 ≈ PaCO2 − 5 mmHg in normal lungs'],
          ],
        },
      },
    ],
  },
  {
    id: 'monitors',
    title: 'Section 10: Anesthesia Monitors & Safety Systems',
    color: 'bg-indigo-50 border-indigo-200',
    emoji: '📊',
    topics: [
      {
        heading: 'ASA Basic Monitoring Standards',
        table: {
          headers: ['Monitor', 'Standard Requirement', 'Key Parameter'],
          rows: [
            ['Pulse Oximetry (SpO2)', 'Continuous throughout anesthetic', 'Peripheral O2 saturation; arterial pulsations'],
            ['Capnography (ETCO2)', 'Continuous when intubated; strongly recommended for all GA/MAC', 'Confirms ETT placement; monitors ventilation; detects MH (rising ETCO2)'],
            ['ECG', 'Continuous throughout anesthetic', 'Heart rate, rhythm, ischemia (ST changes)'],
            ['Blood Pressure (NIBP)', 'At least every 5 minutes', 'Systolic, diastolic, MAP'],
            ['Temperature', 'When clinically significant change expected', 'Core temperature (esophageal, bladder, rectal, nasopharyngeal)'],
            ['Inspired O2 Analyzer', 'Continuous; low O2 alarm must be enabled', 'Confirms minimum FiO2 delivered'],
            ['Ventilator Disconnect Alarm', 'Required during mechanical ventilation', 'Detects circuit disconnection; low pressure/volume alarm'],
          ],
        },
      },
      {
        heading: 'Specialized Anesthesia Monitors',
        table: {
          headers: ['Monitor', 'Measured Parameter', 'Clinical Use'],
          rows: [
            ['Volatile Agent Analyzer', 'Inspired and expired anesthetic agent concentration', 'Confirms agent delivery; guides MAC maintenance'],
            ['Neuromuscular Monitor (TOF)', 'Train-of-four (TOF) ratio; PTC; DBS; single-twitch', 'Quantifies NMB; guides reversal; confirms adequate recovery (TOF ≥0.9)'],
            ['Bispectral Index (BIS)', 'Processed EEG (0–100 scale)', 'Depth of hypnosis; target 40–60 for GA; reduces awareness and oversedation'],
            ['Invasive Arterial Line (A-line)', 'Continuous beat-to-beat BP + arterial blood gas access', 'Hemodynamic instability, cardiac surgery, anticipated large fluid shifts'],
            ['Cerebral Oximetry (NIRS)', 'Regional cerebral O2 saturation (rSO2)', 'Cardiac surgery, carotid endarterectomy, prone spine cases'],
            ['Transesophageal Echo (TEE)', 'Real-time cardiac structure and function imaging', 'Cardiac surgery, hemodynamic instability, valve evaluation, volume assessment'],
            ['Arterial Waveform Analysis (FloTrac, LiDCO)', 'Stroke volume variation (SVV), pulse pressure variation (PPV), CO', 'Goal-directed fluid therapy; predicts fluid responsiveness in mechanically ventilated patients'],
          ],
        },
      },
      {
        heading: 'Electrical Safety in the OR',
        bullets: [
          'Line Isolation Monitor (LIM): The OR uses an isolated power system — neither conductor connected to ground. Prevents single-fault macroshock from flowing through a patient.',
          'LIM alarms when isolation is compromised — identify and remove the faulty device. Procedure need not stop.',
          'Macroshock: Current applied to the skin; requires >100 mA to cause VF; protected by skin resistance.',
          '⚡ KEY — Microshock: Current applied directly to the heart (via pacing wires, intracardiac catheters); as little as 10 µA can cause VF. Patient is 10,000× more sensitive.',
          '⚡ KEY: Any patient with an intracardiac catheter (pacemaker wire, PA catheter) is at risk for microshock. All equipment near such patients must be grounded and in good repair.',
        ],
      },
    ],
  },
  {
    id: 'regional_equip',
    title: 'Section 11: Regional Anesthesia Equipment',
    color: 'bg-violet-50 border-violet-200',
    emoji: '💉',
    topics: [
      {
        heading: 'Spinal & Epidural Needles',
        bullets: [
          '⚡ KEY — PDPH: Positional headache (worse upright, better supine) due to CSF leak through dural hole. Risk factors: larger needle, cutting vs. pencil-point tip, female sex, young age.',
          'PDPH treatment: bed rest, hydration, caffeine, and epidural blood patch (gold standard) — 15–20 mL autologous blood into epidural space.',
        ],
        table: {
          headers: ['Needle', 'Type', 'Gauge', 'Tip Design', 'PDPH Risk', 'Use'],
          rows: [
            ['Quincke', 'Cutting-tip spinal', '22–27G', 'Beveled cutting tip', 'Higher (cuts dural fibers)', 'Traditional spinal; fast CSF flow; good for diagnostic LP'],
            ['Whitacre', 'Pencil-point spinal', '24–27G', 'Pencil-point with side orifice', 'Lower (separates dural fibers)', 'Most common for spinal anesthesia; reduced PDPH'],
            ['Sprotte', 'Pencil-point spinal', '24–27G', 'Larger side orifice than Whitacre', 'Lower', 'Faster injection; reduced PDPH'],
            ['Touhy (Tuohy)', 'Epidural', '17–18G', 'Curved Huber tip (90° curve)', 'N/A (epidural)', 'Standard epidural needle; curved tip directs catheter cephalad'],
            ['Weiss (winged Tuohy)', 'Epidural', '17–18G', 'Wings for grip during LOR', 'N/A', 'Easier grip during loss-of-resistance technique'],
          ],
        },
      },
      {
        heading: 'Ultrasound-Guided Regional Anesthesia',
        bullets: [
          'Ultrasound guidance (USG) enables real-time visualization of nerves, adjacent structures, and needle tip position while observing local anesthetic spread.',
          'Reduces: block failure rates, LA doses required, and complication rates (vascular puncture, pneumothorax).',
          'Nerve stimulator: Delivers controlled electrical current (0.5 mA, 0.1 ms) through an insulated needle tip. Motor response at <0.5 mA confirms needle proximity to nerve.',
          '⚠️ Current <0.2 mA with motor response may indicate intraneural placement — STOP and reposition.',
        ],
        table: {
          headers: ['Probe Type', 'Frequency', 'Depth', 'Best For'],
          rows: [
            ['High-frequency linear (hockey stick)', '10–15 MHz', 'Superficial (<4 cm)', 'Superficial nerve blocks (brachial plexus above clavicle, saphenous, femoral nerve), vascular access'],
            ['Curved/convex (low frequency)', '2–5 MHz', 'Deep (>6 cm)', 'Deep nerve blocks (sciatic, lumbar plexus, paravertebral), abdominal blocks in obese patients'],
            ['Phased array (cardiac probe)', '1–5 MHz', 'Variable', 'TEE, point-of-care cardiac assessment; not typically used for peripheral nerve blocks'],
          ],
        },
      },
    ],
  },
  {
    id: 'vascular',
    title: 'Section 12: Vascular Access & Infusion Equipment',
    color: 'bg-emerald-50 border-emerald-200',
    emoji: '🩹',
    topics: [
      {
        heading: 'IV Catheter Sizes & Flow Rates',
        bullets: [
          "⚡ KEY: Flow rate is inversely proportional to catheter length and directly proportional to the 4th power of the radius (Poiseuille's Law). A short, large-bore catheter (14–16G) provides dramatically higher flow than a long central line for rapid resuscitation.",
        ],
        table: {
          headers: ['Gauge', 'Color', 'Flow Rate (mL/min)', 'Clinical Use'],
          rows: [
            ['14G', 'Orange', '~340 mL/min', 'Massive hemorrhage, rapid resuscitation, level 1 infuser'],
            ['16G', 'Gray', '~210 mL/min', 'Major surgery, blood transfusion, rapid fluid administration'],
            ['18G', 'Green/Pink', '~100 mL/min', 'Standard adult IV; most surgeries; blood products'],
            ['20G', 'Pink/Rose', '~60 mL/min', 'Standard adult IV; most infusions and medications'],
            ['22G', 'Blue', '~35 mL/min', 'Pediatric, elderly, difficult access; drug infusions'],
            ['24G', 'Yellow', '~22 mL/min', 'Neonates, very small pediatric patients, fragile veins'],
          ],
        },
      },
      {
        heading: 'Central Venous Catheters & Arterial Lines',
        bullets: [
          'CVCs are placed in large central veins (IJ, subclavian, femoral) for CVP monitoring, drug delivery (vasopressors, TPN, vesicants).',
          'Complications of CVC: arterial puncture, pneumothorax (highest risk with subclavian), air embolism, catheter malposition, CLABSI, thrombosis, nerve injury.',
          'Arterial lines: radial artery (most common — perform Allen\'s test first), femoral, brachial, or dorsalis pedis.',
          '⚡ KEY — Phlebostatic axis: Reference point for zeroing all hemodynamic pressure transducers. Located at the intersection of the 4th intercostal space and the mid-axillary line — approximates the level of the right atrium.',
        ],
      },
      {
        heading: 'Infusion Devices',
        table: {
          headers: ['Device', 'Purpose', 'Key Feature'],
          rows: [
            ['Syringe pump', 'Drug infusions (vasopressors, TIVA, insulin, heparin)', 'Precise, low-volume delivery; 10–60 mL syringe; programmable rates'],
            ['IV infusion pump (volumetric)', 'IV fluids and blood products', 'Controls flow rate; air-in-line and occlusion alarms'],
            ['PCA pump', 'Postoperative opioid analgesia', 'Patient-triggered bolus doses + optional continuous basal rate; lockout interval'],
            ['Level 1 Fluid Warmer / Hotline', 'Rapid warmed fluid infusion', 'Warms fluid to 38–41°C; high-flow; used for massive transfusion'],
            ['Belmont Rapid Infuser', 'Massive hemorrhage resuscitation', 'Up to 1,000 mL/min at body temperature; pressure-driven; integrates warming'],
            ['TCI (Target-Controlled Infusion) pump', 'TIVA (propofol, remifentanil)', 'Pharmacokinetic model-driven; targets plasma or effect-site concentration'],
          ],
        },
      },
    ],
  },
];

function TopicBlock({ topic }) {
  return (
    <div className="mb-4">
      <h4 className="text-xs font-bold text-muted-foreground uppercase tracking-wider mb-2">{topic.heading}</h4>
      {topic.bullets && (
        <ul className="space-y-1.5 mb-3">
          {topic.bullets.map((b, i) => (
            <li key={i} className="flex gap-2 text-sm text-foreground">
              <span className="text-primary mt-0.5 shrink-0">•</span>
              <span>{b}</span>
            </li>
          ))}
        </ul>
      )}
      {topic.table && (
        <div className="overflow-x-auto rounded-xl border border-border">
          <table className="w-full text-xs">
            <thead>
              <tr className="bg-muted">
                {topic.table.headers.map((h, i) => (
                  <th key={i} className="text-left px-3 py-2 font-semibold text-foreground border-b border-border">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {topic.table.rows.map((row, ri) => (
                <tr key={ri} className={ri % 2 === 0 ? 'bg-card dark:bg-gray-900' : 'bg-muted/40'}>
                  {row.map((cell, ci) => (
                    <td key={ci} className="px-3 py-2 text-foreground align-top border-b border-border/50 last:border-b-0">{cell}</td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function SectionCard({ section }) {
  const [open, setOpen] = useState(false);
  return (
    <div className={`rounded-2xl border-2 ${section.color} overflow-hidden`}>
      <button
        onClick={() => setOpen(o => !o)}
        className="w-full flex items-center gap-3 p-4 text-left hover:opacity-90 active:scale-[0.99] transition-all"
      >
        <span className="text-2xl shrink-0">{section.emoji}</span>
        <div className="flex-1 min-w-0">
          <p className="font-bold text-sm text-foreground leading-snug">{section.title}</p>
          <p className="text-xs text-muted-foreground mt-0.5">{section.topics.length} topics</p>
        </div>
        {open ? <ChevronUp className="w-4 h-4 text-muted-foreground shrink-0" /> : <ChevronDown className="w-4 h-4 text-muted-foreground shrink-0" />}
      </button>
      {open && (
        <div className="px-4 pb-4 bg-card dark:bg-gray-900 border-t border-border/50 space-y-5 pt-4">
          {section.topics.map((t, i) => <TopicBlock key={i} topic={t} />)}
        </div>
      )}
    </div>
  );
}

export default function EquipmentReviewGuide() {
  return (
    <div className="flex flex-col pb-6">
      {/* Header */}
      <div className="bg-teal-800 text-white px-4 py-5 rounded-2xl mb-4">
        <div className="flex items-center gap-3 mb-2">
          <BookOpen className="w-6 h-6" />
          <span className="text-xs font-bold uppercase tracking-widest opacity-80">CE HALO LLC</span>
        </div>
        <h2 className="font-heading font-bold text-xl leading-tight">Anesthesia Equipment Review Module</h2>
        <p className="text-sm opacity-80 mt-1">NBCRNA NCE Board Review</p>
        <p className="text-xs opacity-60 mt-1">12 Sections · Gas Supply, Airway, Circuits, Monitors, Regional & Vascular Access</p>
      </div>

      <div className="space-y-3">
        {SECTIONS.map(s => <SectionCard key={s.id} section={s} />)}
      </div>

      <div className="mt-4 p-3 bg-amber-50 border border-amber-200 rounded-xl">
        <p className="text-xs text-amber-800 font-medium">⚠️ For educational use only. Not for clinical decision-making. © CE HALO LLC 2025</p>
      </div>
    </div>
  );
}