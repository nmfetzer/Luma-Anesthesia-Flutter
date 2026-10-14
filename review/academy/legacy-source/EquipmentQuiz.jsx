import { useState } from 'react';
import { useScrollReset } from '@/components/ScrollToTop';
import { ChevronLeft, ChevronRight, CheckCircle2, XCircle, RotateCcw, Trophy, BookOpen } from 'lucide-react';
import { useEntitlement } from '@/hooks/useEntitlement';
import PaywallModal from '@/components/PaywallModal';
import QuizFreePreviewGate from './QuizFreePreviewGate';

const FREE_PREVIEW_LIMIT = 5;

// Answer key from PDF page 16:
// Q1:C Q2:B Q3:C Q4:B Q5:C Q6:B Q7:C Q8:C Q9:C Q10:C
// Q11:B Q12:C Q13:C Q14:C Q15:B Q16:B Q17:C Q18:C Q19:D Q20:C
// Q21:B Q22:C Q23:C Q24:D Q25:C Q26:B Q27:C Q28:B Q29:B Q30:B
// Q31:C Q32:B Q33:B Q34:B Q35:B Q36:B Q37:C Q38:B Q39:D Q40:C
// Q41:B Q42:B Q43:B Q44:D Q45:A Q46:B Q47:B Q48:D Q49:B Q50:B

const QUESTIONS = [
  { id: 1, section: 'Section 1 — Medical Gas Supply', q: 'What is the standard pipeline working pressure for oxygen, nitrous oxide, and medical air delivered to the anesthesia machine?', options: ['14–16 psi', '30–35 psi', '50–55 psi', '160–200 psi'], answer: 2, rationale: 'Hospital pipeline systems supply all medical gases (O2, N2O, medical air) at approximately 50–55 psi. This standardized working pressure allows the anesthesia machine to accept pipeline gas without additional high-pressure reduction.' },
  { id: 2, section: 'Section 1 — Medical Gas Supply', q: 'A full E-cylinder of oxygen reads approximately 2,200 psi. After using half its contents, what pressure would you expect?', options: ['745 psi (pressure stays constant until nearly empty)', '~1,100 psi', '~1,650 psi', '2,200 psi (no change until the last 10%)'], answer: 1, rationale: 'Oxygen is stored as a compressed gas — its pressure is directly proportional to the remaining volume. A half-full O2 E-cylinder contains ~330 L and reads approximately 1,100 psi. This is in contrast to nitrous oxide, which is stored as a liquid and maintains constant pressure until all liquid evaporates.' },
  { id: 3, section: 'Section 1 — Medical Gas Supply', q: 'You need to estimate how much nitrous oxide remains in an E-cylinder. The pressure gauge reads 500 psi. What is the most accurate way to determine remaining volume?', options: ['Assume 50% remains since pressure is below 745 psi', 'Calculate using the formula: Volume = Pressure × 0.3 ÷ Flow rate', 'Weigh the cylinder; pressure alone is unreliable for N2O', 'Trust the gauge — 500 psi indicates approximately 1/3 full'], answer: 2, rationale: 'N2O is stored as a liquid in equilibrium with its vapor. The pressure gauge reads vapor pressure (~745 psi) regardless of how much liquid remains. Once all liquid evaporates, pressure drops rapidly. The only accurate method to determine remaining N2O volume is to weigh the cylinder.' },
  { id: 4, section: 'Section 1 — Medical Gas Supply', q: 'Which safety system prevents attaching the wrong gas cylinder to the wrong yoke on the anesthesia machine?', options: ['Diameter Index Safety System (DISS)', 'Pin Index Safety System (PISS)', 'Fail-safe valve', 'Check valve (Bodok seal)'], answer: 1, rationale: 'The Pin Index Safety System (PISS) uses a unique pin-hole configuration on the cylinder valve and yoke for each gas, physically preventing attachment of the wrong cylinder to the wrong yoke. DISS is used for pipeline connections (threaded, non-interchangeable connectors).' },
  { id: 5, section: 'Section 1 — Medical Gas Supply', q: 'The fail-safe system on the anesthesia machine activates when oxygen pressure drops below ~25–30 psi. What does it do?', options: ['Activates an audible alarm only and continues delivering all gases', 'Shuts off all gas flow including oxygen', 'Reduces or shuts off flow of all non-oxygen gases to prevent a hypoxic mixture', 'Switches automatically to the backup E-cylinder oxygen supply'], answer: 2, rationale: 'The fail-safe monitors O2 supply pressure and, when it drops below threshold, reduces or eliminates flow of N2O and air. It does NOT shut off oxygen itself, and it does NOT guarantee adequate O2 concentration — it only responds to supply pressure, not actual O2 concentration delivered to the patient.' },
  { id: 6, section: 'Section 1 — Medical Gas Supply', q: 'During hospital construction, a pipeline crossover error results in nitrogen being delivered through the oxygen pipeline. The fail-safe system will:', options: ['Immediately alarm and shut down all gas flow', 'Fail to prevent delivery of a hypoxic gas mixture — it monitors pressure only', 'Detect the nitrogen and automatically switch to E-cylinder oxygen', 'Activate the oxygen ratio controller to compensate'], answer: 1, rationale: 'The fail-safe system only responds to oxygen PRESSURE, not oxygen CONCENTRATION. If nitrogen is delivered through the O2 pipeline at 50–55 psi, the fail-safe sees adequate pressure and does not activate. This is a critical safety limitation — pipeline crossover errors are rare but catastrophic.' },
  { id: 7, section: 'Section 1 — Medical Gas Supply', q: 'An E-cylinder of oxygen reads 1,500 psi. At a flow rate of 5 L/min, approximately how long will it last?', options: ['30 minutes', '45 minutes', '90 minutes', '120 minutes'], answer: 2, rationale: 'Use the formula: Duration (min) = [Pressure (psi) × 0.3] ÷ Flow rate (L/min). Therefore: (1,500 × 0.3) ÷ 5 = 450 ÷ 5 = 90 minutes. This formula applies only to oxygen (compressed gas); it cannot be used for N2O.' },
  { id: 8, section: 'Section 1 — Medical Gas Supply', q: 'Which color coding correctly identifies medical oxygen pipeline and cylinder supply in the United States?', options: ['Blue', 'Yellow', 'Green', 'Gray'], answer: 2, rationale: 'In the United States, oxygen is color-coded GREEN for both pipeline and cylinder supplies. Nitrous oxide is BLUE, medical air is YELLOW, and carbon dioxide is GRAY. Note: International color coding differs (e.g., oxygen is WHITE in most of Europe).' },
  { id: 9, section: 'Section 2 — The Anesthesia Machine', q: 'On North American anesthesia machines, which flowmeter is always positioned on the RIGHT (downstream, closest to the common gas outlet) and why?', options: ['Nitrous oxide — it must be last to blend with oxygen', 'Air — it is the most commonly used carrier gas', 'Oxygen — so that a manifold leak preferentially contaminates with O2, not a hypoxic gas', 'The position is not standardized and varies by manufacturer'], answer: 2, rationale: 'Oxygen is always on the RIGHT (downstream position) on North American machines. If there is a crack or internal leak in the flowmeter manifold, the downstream gas (O2) will preferentially enter the fresh gas stream rather than the upstream hypoxic gas (N2O or air). This is a critical patient safety design feature.' },
  { id: 10, section: 'Section 2 — The Anesthesia Machine', q: 'The first-stage pressure regulator on the anesthesia machine reduces E-cylinder oxygen pressure from ~2,200 psi to approximately:', options: ['14–16 psi', '25–30 psi', '45 psi', '100 psi'], answer: 2, rationale: 'The first-stage (high-pressure) regulator at the cylinder yoke reduces E-cylinder pressure from ~2,200 psi down to ~45 psi — approximately matching pipeline pressure. This allows seamless switching between pipeline and cylinder supply. The second-stage regulator further reduces pressure to ~14–16 psi for the flowmeters.' },
  { id: 11, section: 'Section 2 — The Anesthesia Machine', q: 'A patient experiences laryngospasm during emergence. You activate the oxygen flush valve. Which statement is TRUE regarding this action?', options: ['It delivers 100% O2 at 2–5 L/min through the vaporizer', 'It delivers 100% O2 at 35–75 L/min, bypassing the vaporizer and flowmeters', 'It activates only if the pipeline O2 pressure is above 55 psi', 'It should not be used during spontaneous ventilation because it delivers room air'], answer: 1, rationale: 'The O2 flush valve delivers 100% oxygen at 35–75 L/min directly from the pipeline, completely bypassing the flowmeters, vaporizer, and second-stage regulator. It should be used cautiously during IPPV (can cause barotrauma) and during spontaneous ventilation (the high flow can prevent exhalation and cause auto-PEEP). It dilutes anesthetic concentration in the circuit.' },
  { id: 12, section: 'Section 2 — The Anesthesia Machine', q: 'Which volatile anesthetic has the HIGHEST SVP (saturated vapor pressure) at room temperature and therefore requires the most precise agent-specific vaporizer control?', options: ['Isoflurane (SVP ~238 mmHg)', 'Sevoflurane (SVP ~157 mmHg)', 'Desflurane (SVP ~669 mmHg)', 'Halothane (SVP ~243 mmHg)'], answer: 2, rationale: 'Desflurane has an SVP of ~669 mmHg — near atmospheric pressure — meaning it would vaporize explosively at room temperature if placed in a standard vaporizer. It requires a specialized, pressurized, heated vaporizer (e.g., Tec 6) that maintains the agent at 39°C. Its boiling point is only 22.8°C, close to room temperature.' },
  { id: 13, section: 'Section 2 — The Anesthesia Machine', q: 'During the anesthesia machine pre-use check, you perform a low-pressure system leak test. What does this test specifically assess?', options: ['The integrity of the high-pressure cylinder connections', 'Pipeline supply pressure adequacy', 'Leaks between the flowmeters, vaporizer, and common gas outlet', 'The function of the fail-safe valve'], answer: 2, rationale: 'The low-pressure leak test assesses the integrity of the low-pressure section — from the flowmeters through the vaporizer to the common gas outlet. This is the most important leak test because a leak here dilutes the fresh gas mixture without triggering any alarm.' },
  { id: 14, section: 'Section 2 — The Anesthesia Machine', q: 'In correct gas flow sequence through the anesthesia machine, where does the vaporizer sit relative to the flowmeters and the common gas outlet?', options: ['Upstream of the flowmeters', 'Between the fail-safe valve and the flowmeters', 'Downstream of the flowmeters, upstream of the common gas outlet', 'Parallel to the flowmeters with a mixing valve'], answer: 2, rationale: 'The correct sequence is: Gas source → Pressure regulators → Fail-safe → Flowmeters → Vaporizer → Common gas outlet → Breathing circuit. The vaporizer sits downstream of the flowmeters and upstream of the fresh gas outlet. This ensures measured carrier gas flow picks up vapor before reaching the patient circuit.' },
  { id: 15, section: 'Section 2 — The Anesthesia Machine', q: 'The minimum oxygen ratio controller (e.g., Link-25) on the anesthesia machine is designed to:', options: ['Alarm when O2 flows exceed 8 L/min', 'Prevent setting a fresh gas mixture with less than 25% oxygen', 'Automatically increase oxygen flow when SpO2 drops below 94%', 'Disable the nitrous oxide flowmeter when E-cylinder O2 pressure is low'], answer: 1, rationale: 'The minimum O2 ratio controller (Link-25 or Ratio-Master) mechanically or electronically links the N2O and O2 flow controls to ensure the delivered mixture contains at least 25% O2. If the clinician attempts to increase N2O beyond this ratio, O2 flow is automatically increased proportionally. This prevents accidental delivery of hypoxic mixtures.' },
  { id: 16, section: 'Section 3 — Breathing Circuits & CO2 Absorption', q: 'Compound A forms when sevoflurane reacts with which CO2 absorbent under conditions of low flow and high temperature?', options: ['Amsorb Plus (calcium hydroxide)', 'Soda lime containing NaOH and KOH', 'Lithium hydroxide', 'Silica gel'], answer: 1, rationale: 'Compound A forms when sevoflurane reacts with strong bases, primarily KOH and NaOH found in traditional soda lime. Production increases with low fresh gas flow rates, high absorbent temperature, and desiccated absorbent. Amsorb Plus (calcium hydroxide only) does not contain NaOH/KOH and produces negligible Compound A.' },
  { id: 17, section: 'Section 3 — Breathing Circuits & CO2 Absorption', q: 'A Mapleson D circuit is being used for a spontaneously breathing adult patient. To prevent rebreathing, the fresh gas flow should be:', options: ["Equal to the patient's tidal volume", "1–2 times the patient's minute ventilation", "2–3 times the patient's minute ventilation", "4–6 times the patient's minute ventilation"], answer: 2, rationale: "The Mapleson D (and its modification, the Bain circuit) requires a fresh gas flow of approximately 2–3× the patient's minute ventilation to prevent CO2 rebreathing during spontaneous breathing. During controlled ventilation, it is more efficient, requiring only 70–100 mL/kg/min. The Mapleson A (Magill) is the most efficient for spontaneous breathing (FGF = 1× MV)." },
  { id: 18, section: 'Section 3 — Breathing Circuits & CO2 Absorption', q: 'The active scavenging system in the OR removes waste anesthetic gases. If the interface reservoir bag is fully collapsed during exhalation, this indicates:', options: ['Normal function — the system is working correctly', 'Excessive positive pressure in the scavenging system — possible obstruction', 'Excessive negative pressure (suction too high) — risk of subatmospheric pressure reaching the patient circuit', 'The absorber is saturated and needs replacement'], answer: 2, rationale: 'In an active scavenging system, the interface bag buffers waste gas flow. A fully collapsed bag indicates the vacuum (suction) is drawing more than the system is supplying — excessive negative pressure can be transmitted back to the breathing circuit, causing unintended PEEP removal or rebreathing. Conversely, a fully distended bag suggests inadequate suction or obstruction.' },
  { id: 19, section: 'Section 4 — Airway Equipment & Laryngoscopes', q: 'A patient with a suspected anterior larynx is being intubated. Which direct laryngoscopy blade and technique is MOST appropriate?', options: ['Macintosh blade — tip in vallecula, indirectly elevates epiglottis', 'Miller blade — tip passes posterior to the epiglottis and directly lifts it', 'McCoy blade — hinged tip activated to flex epiglottis', 'Either B or C — both directly elevate the epiglottis'], answer: 3, rationale: 'Both the Miller (straight blade, tip posterior to epiglottis, direct lift) and McCoy (hinged Macintosh-style blade that flexes to lift epiglottis) directly elevate the epiglottis. These are preferred for anterior larynges, pediatric patients, and when Macintosh fails. The McCoy\'s hinged tip can improve Cormack-Lehane grade by 1–2 grades.' },
  { id: 20, section: 'Section 4 — Airway Equipment & Laryngoscopes', q: 'A Cormack-Lehane Grade III view on direct laryngoscopy reveals:', options: ['Full glottis visible', 'Only the posterior portion of the arytenoids visible', 'Only the epiglottis visible — glottis not seen', 'No laryngeal structures visible — only soft palate'], answer: 2, rationale: 'The Cormack-Lehane grading system: Grade I = full glottis visible; Grade II = only posterior commissure/arytenoids visible; Grade III = only epiglottis visible, glottis not seen; Grade IV = epiglottis not visible, only soft palate. Grades III–IV are associated with difficult intubation and require alternative techniques.' },
  { id: 21, section: 'Section 4 — Airway Equipment & Laryngoscopes', q: 'Which video laryngoscope is specifically designed for use WITHOUT a stylet due to its low angle of curvature, making it most suitable for routine intubations?', options: ['GlideScope (standard blade) — high curvature requires stylet', 'C-MAC (standard blade) — low curvature, direct-style view, stylet optional', 'McGRATH MAC — requires manufacturer stylet', 'Airtraq — optical device, no stylet needed'], answer: 1, rationale: 'The C-MAC with a standard Mac-style blade provides an indirect video view while maintaining the low curvature of a standard Macintosh blade. A stylet is often not required, making it suitable for both routine and difficult airway management. The GlideScope standard blade has a 60° curvature requiring a specifically shaped stylet.' },
  { id: 22, section: 'Section 5 — Flexible Bronchoscopy & AFOI', q: 'During awake fiberoptic intubation (AFOI), topical anesthesia of the airway is performed. Which nerve blocks provide anesthesia to the SUPRAGLOTTIC structures (tongue base, epiglottis, vallecula)?', options: ['Transtracheal injection of lidocaine', 'Superior laryngeal nerve blocks (internal branch)', 'Glossopharyngeal nerve block', 'Recurrent laryngeal nerve block'], answer: 2, rationale: 'The glossopharyngeal nerve (CN IX) provides sensory innervation to the posterior tongue, vallecula, and epiglottis (supraglottic structures). Superior laryngeal nerve (internal branch) blocks anesthetize the larynx down to the vocal cords. Transtracheal injection anesthetizes the subglottic trachea. Recurrent laryngeal nerve supplies sensory innervation below the cords.' },
  { id: 23, section: 'Section 5 — Flexible Bronchoscopy & AFOI', q: "When performing fiberoptic-guided intubation through an LMA in a 'cannot intubate' scenario, the MINIMUM LMA size needed to pass a standard 8.0 mm ETT is approximately:", options: ['Size 3 LMA', 'Size 4 LMA', 'Size 5 LMA', 'Any size LMA can accommodate an 8.0 ETT'], answer: 2, rationale: 'A size 5 LMA Classic (or equivalent) is the minimum size that can accommodate a standard 8.0 mm ETT through the LMA barrel during fiberoptic-guided intubation. Size 3 and 4 LMAs have internal diameters that limit passage to size 6.0 and 6.5 ETTs, respectively.' },
  { id: 24, section: 'Section 6 — Endotracheal Tubes (ETTs)', q: 'You are intubating an 8-year-old child. Using the age-based formula, what is the appropriate UNCUFFED ETT size?', options: ['4.5 mm', '5.0 mm', '5.5 mm', '6.0 mm'], answer: 3, rationale: 'The standard formula for uncuffed ETT size in children is (Age in years ÷ 4) + 4. For an 8-year-old: (8 ÷ 4) + 4 = 2 + 4 = 6.0 mm. Always have the next size up (6.5) and down (5.5) available. For cuffed ETTs, the formula is (Age ÷ 4) + 3.5, giving 5.5 mm for an 8-year-old.' },
  { id: 25, section: 'Section 6 — Endotracheal Tubes (ETTs)', q: 'The recommended ETT cuff pressure range to minimize tracheal mucosal ischemia while maintaining an adequate seal is:', options: ['5–10 cmH2O', '10–15 cmH2O', '20–30 cmH2O', '40–50 cmH2O'], answer: 2, rationale: 'ETT cuff pressure should be maintained between 20–30 cmH2O. Below 20 cmH2O, the cuff may not provide an adequate seal, risking aspiration and air leak. Above 30 cmH2O, lateral tracheal wall pressure may exceed mucosal capillary perfusion pressure (~25–35 mmHg), leading to mucosal ischemia, necrosis, and potential tracheal stenosis.' },
  { id: 26, section: 'Section 6 — Endotracheal Tubes (ETTs)', q: 'A thoracic surgery patient requires one-lung ventilation. A left-sided double-lumen tube (DLT) is placed. Which bronchus will the bronchial lumen intubate?', options: ['Right mainstem bronchus — the larger bronchus', 'Left mainstem bronchus — the bronchial lumen is passed into the left bronchus', 'Either bronchus — DLT selection is based on patient size only', 'The trachea — one lumen sits in the trachea and one in the right main bronchus'], answer: 1, rationale: 'A left-sided DLT has a curved bronchial tip designed to pass into the LEFT mainstem bronchus. The tracheal lumen opens into the trachea above the carina, ventilating the right lung. A right-sided DLT is reserved for specific indications (left-sided pneumonectomy, left bronchial anomaly) because the right upper lobe bronchus origin is close to the carina.' },
  { id: 27, section: 'Section 6 — Endotracheal Tubes (ETTs)', q: 'Which specialized ETT is MOST appropriate for a patient requiring continuous subglottic suctioning to reduce the risk of ventilator-associated pneumonia (VAP)?', options: ['Reinforced (armored) ETT', 'Laser-safe ETT', 'Evac/subglottic suction ETT (e.g., Mallinckrodt Hi-Lo Evac)', 'Microlaryngeal tube (MLT)'], answer: 2, rationale: 'Subglottic suction ETTs (e.g., Hi-Lo Evac, SealGuard Evac) have an additional dorsal lumen that exits just above the cuff, allowing continuous or intermittent aspiration of secretions that pool above the cuff. This significantly reduces VAP risk in mechanically ventilated patients.' },
  { id: 28, section: 'Section 6 — Endotracheal Tubes (ETTs)', q: 'You are preparing for airway laser surgery of the larynx. Standard PVC ETTs are contraindicated. What is the PRIMARY reason?', options: ['PVC tubes are too rigid and obstruct the surgical field', 'PVC is highly flammable and can ignite in the oxygen-enriched environment with laser energy', 'PVC tubes do not provide an adequate cuff seal at high inflation pressures', 'The laser cannot be used near standard cuffs filled with air'], answer: 1, rationale: 'PVC (polyvinyl chloride) ETTs are combustible and can ignite when struck by laser energy in an oxygen- or nitrous oxide-enriched environment, causing an airway fire. Laser-safe ETTs are constructed from stainless steel, silicone-coated metal, or have a foil-wrapped outer layer. The cuff should be filled with saline rather than air.' },
  { id: 29, section: 'Section 7 — Supraglottic Airway Devices (SGAs)', q: 'A 2nd-generation supraglottic airway device differs from a 1st-generation device primarily by:', options: ['Having a smaller cuff volume and lower oropharyngeal leak pressure', 'Incorporating a gastric drainage channel and higher oropharyngeal leak pressures (>25 cmH2O)', 'Being designed exclusively for pediatric patients', 'Requiring rigid insertion technique only'], answer: 1, rationale: '2nd-generation SGAs (e.g., ProSeal LMA, Supreme LMA, i-gel) incorporate a gastric access/drainage channel that allows passage of a gastric tube to decompress the stomach, reducing aspiration risk. They also achieve higher oropharyngeal leak pressures (typically >25–27 cmH2O), making them more suitable for positive-pressure ventilation.' },
  { id: 30, section: 'Section 7 — Supraglottic Airway Devices (SGAs)', q: 'The i-gel supraglottic airway is unique among SGAs because:', options: ['It has the largest cuff volume of any commercially available SGA', 'It uses a non-inflatable, gel-like thermoplastic elastomer cuff that molds to the laryngeal anatomy', 'It can only be used in patients weighing over 70 kg', 'It requires a rigid introducer for insertion in all cases'], answer: 1, rationale: 'The i-gel (Intersurgical) uses a non-inflatable cuff made of a soft, gel-like thermoplastic elastomer (SEBS). Body heat causes the cuff to soften and conform to the perilaryngeal anatomy, creating a seal without inflation. It also incorporates a gastric drainage channel (2nd-generation), epiglottic rest, and bite block.' },
  { id: 31, section: 'Section 7 — Supraglottic Airway Devices (SGAs)', q: 'You plan to use an LMA-Fastrach (intubating LMA) for a patient with a predicted difficult airway. The maximum ETT size that can be passed through the standard Fastrach is:', options: ['6.0 mm cuffed', '7.0 mm cuffed', '8.0 mm cuffed', '9.0 mm cuffed'], answer: 2, rationale: 'The LMA-Fastrach (ILMA) has a rigid curved shaft with a 13 mm internal diameter channel designed to accommodate ETTs up to 8.0 mm (cuffed). It is used with a specific silicone wire-reinforced ETT (LMA Fastrach ETT) that is designed to navigate the curve of the Fastrach.' },
  { id: 32, section: 'Section 8 — Additional Airway Adjuncts', q: 'When inserting a nasopharyngeal airway (NPA), the correct size in adults is estimated by measuring from the:', options: ['Corner of the mouth to the ear tragus', 'Tip of the nose to the ear tragus', 'Chin to the ear lobule', 'Nasal tip to the angle of the mandible'], answer: 1, rationale: 'NPA size is estimated by measuring from the tip of the nose to the tragus of the ear. This approximates the distance from the naris to the nasopharynx. Oral airways (OPAs) are sized from the corner of the mouth to the ear tragus. Using the wrong landmark is a common exam question.' },
  { id: 33, section: 'Section 8 — Additional Airway Adjuncts', q: "A patient presents in extremis after failed oral and nasal intubation attempts. The preferred emergency front-of-neck access (eFONA) technique in most CICO scenarios is:", options: ['Percutaneous needle cricothyrotomy with jet ventilation', 'Surgical scalpel-bougie-tube technique through the cricothyroid membrane', 'Percutaneous Seldinger-technique cricothyrotomy kit', 'Retrograde wire intubation via the cricothyroid membrane'], answer: 1, rationale: 'Current DAS (Difficult Airway Society) and most major guidelines recommend the scalpel-bougie-tube (surgical) technique as the preferred eFONA in CICO emergencies. A horizontal stab incision is made through the cricothyroid membrane, a bougie is inserted, and a size 6.0 cuffed ETT is railroaded over the bougie. It is reliable, fast, and does not require specialized kits.' },
  { id: 34, section: 'Section 8 — Additional Airway Adjuncts', q: 'High-flow nasal oxygen (HFNO/THRIVE) during apneic oxygenation can extend the safe apnea time during intubation. The mechanism by which HFNO maintains oxygenation during apnea is primarily:', options: ['Active ventilation via the Venturi effect in the nasopharynx', 'Apneic oxygenation — O2 diffuses down an oxygen concentration gradient into the alveoli without respiratory effort', 'Generation of positive pressure that splints the alveoli open', 'Absorption of alveolar CO2 by the high oxygen flow'], answer: 1, rationale: 'Apneic oxygenation works because O2 consumption continues (~250 mL/min) during apnea, creating a concentration gradient that draws O2 from the upper airway into the alveoli by mass flow, even without respiratory effort. HFNO delivers 40–70 L/min of warmed, humidified O2 to continuously replenish the nasopharyngeal oxygen reservoir.' },
  { id: 35, section: 'Section 9 — Anesthesia Ventilators & Modes', q: 'In Pressure-Controlled Ventilation (PCV), which parameter is set directly by the clinician?', options: ['Tidal volume', 'Peak inspiratory pressure', 'Respiratory rate and I:E ratio only', 'Minute ventilation'], answer: 1, rationale: 'In PCV, the clinician sets the peak inspiratory pressure (driving pressure), respiratory rate, and I:E ratio. Tidal volume is the dependent variable — it varies based on lung compliance and airway resistance. PCV is useful when limiting peak pressures is a priority (e.g., ARDS, lung-protective ventilation). In contrast, in VCV, tidal volume is set and peak pressure varies.' },
  { id: 36, section: 'Section 9 — Anesthesia Ventilators & Modes', q: 'A patient under general anesthesia has a plateau pressure of 38 cmH2O and a peak airway pressure of 42 cmH2O. What does the elevated plateau pressure (>30 cmH2O) most likely indicate?', options: ['High airway resistance (bronchospasm, kinked ETT)', 'Decreased lung/chest wall compliance (atelectasis, pneumothorax, pulmonary edema)', 'Endotracheal tube cuff leak', 'Excessive fresh gas flow'], answer: 1, rationale: 'Plateau pressure reflects static lung/chest wall compliance — it is measured at end-inspiration with flow stopped. Elevated plateau pressure (>30 cmH2O) indicates decreased compliance: pneumothorax, pulmonary edema, atelectasis, endobronchial intubation, abdominal distension. Elevated PEAK pressure with NORMAL plateau pressure indicates increased airway resistance. This distinction is critical on the NBCRNA exam.' },
  { id: 37, section: 'Section 10 — Anesthesia Monitors & Safety', q: 'According to ASA basic monitoring standards, which monitor is required during EVERY anesthetic (including MAC/monitored anesthesia care)?', options: ['Neuromuscular blockade monitoring', 'Bispectral index (BIS) monitoring', 'End-tidal CO2 (capnography)', 'Invasive arterial blood pressure monitoring'], answer: 2, rationale: 'ASA basic monitoring standards require continuous pulse oximetry (SpO2), continuous capnography (ETCO2) when intubated, ECG, blood pressure at least every 5 minutes, temperature when changes are anticipated, and an inspired O2 analyzer. BIS, NMB monitoring, and arterial lines are advanced monitors — not ASA standard requirements.' },
  { id: 38, section: 'Section 10 — Anesthesia Monitors & Safety', q: 'A Line Isolation Monitor (LIM) in the OR alarms. This indicates:', options: ['A patient has suffered a macroshock electrical injury', 'The first fault condition has occurred — the isolated power system has a pathway to ground', 'An electrical device has shorted and must be removed immediately', 'The OR power supply has failed and the backup generator is activated'], answer: 1, rationale: 'The OR uses an isolated power system (no direct connection to earth ground) to reduce electrocution risk. A LIM alarms when it signals the FIRST fault — a single pathway to ground has been created. The patient is NOT in immediate danger from the first fault alone. The dangerous situation is the SECOND fault — which would complete a circuit through the patient. The faulty device should be identified and removed.' },
  { id: 39, section: 'Section 10 — Anesthesia Monitors & Safety', q: 'The minimum amount of current required to cause ventricular fibrillation when applied DIRECTLY to the myocardium (microshock) is approximately:', options: ['1 mA (milliampere)', '10 mA', '100 mA', '100 mcA (microamperes)'], answer: 3, rationale: 'Microshock (current directly to myocardium via cardiac catheter, pacing wires, or intracardiac catheters) can cause ventricular fibrillation with as little as 100 mcA (microamperes = 0.1 mA). Macroshock (current through intact skin) requires approximately 100 mA to fibrillate. This 1,000-fold difference is why patients with intracardiac catheters require the isolated power system and extra electrical precautions.' },
  { id: 40, section: 'Section 10 — Anesthesia Monitors & Safety', q: 'Processed EEG monitoring (e.g., BIS) in the OR is primarily used to:', options: ['Diagnose intraoperative stroke', 'Guide neuromuscular blockade reversal', 'Assess depth of hypnosis and reduce awareness under general anesthesia', 'Monitor cerebral oxygenation during carotid endarterectomy'], answer: 2, rationale: 'Bispectral Index (BIS) and similar processed EEG monitors provide a dimensionless score (0–100). BIS 40–60 correlates with adequate hypnotic depth for general anesthesia; BIS >60 may indicate light anesthesia and increased awareness risk; BIS <40 indicates deep suppression. Cerebral oximetry (rSO2 via NIRS) monitors cerebral oxygenation in carotid surgery.' },
  { id: 41, section: 'Section 11 — Regional Anesthesia Equipment', q: 'A patient develops a postdural puncture headache (PDPH) 24 hours after spinal anesthesia. Which needle type is associated with the LOWEST incidence of PDPH?', options: ['Quincke (cutting tip) needle, 25G', 'Whitacre (pencil-point) needle, 25G', 'Tuohy needle, 17G', 'Sprotte needle, 22G'], answer: 1, rationale: 'Pencil-point needles (Whitacre, Sprotte) spread dural fibers apart rather than cutting them, allowing the dura to reseal more effectively after withdrawal. They have significantly lower PDPH rates than cutting-tip (Quincke) needles of the same gauge. Smaller gauge also reduces PDPH risk. The Tuohy (used for epidural) has the highest PDPH risk if it inadvertently punctures the dura.' },
  { id: 42, section: 'Section 11 — Regional Anesthesia Equipment', q: 'For ultrasound-guided nerve blocks of deep structures (e.g., sciatic nerve, lumbar plexus), which ultrasound probe is preferred?', options: ['High-frequency linear probe (10–15 MHz) — better resolution for deep structures', 'Low-frequency curvilinear probe (2–5 MHz) — greater penetration depth', 'Phased array probe (1–5 MHz) — designed for cardiac imaging', 'Hockey-stick linear probe (13–6 MHz) — designed specifically for nerve blocks'], answer: 1, rationale: 'Low-frequency curvilinear (convex) probes (2–5 MHz) provide greater tissue penetration (up to 10–15 cm), making them suitable for deep structures like the sciatic nerve, lumbar plexus, and psoas compartment. High-frequency linear probes (6–15 MHz) provide excellent resolution for superficial structures but have limited penetration (3–4 cm).' },
  { id: 43, section: 'Section 11 — Regional Anesthesia Equipment', q: 'During a nerve stimulator-guided peripheral nerve block, what is the optimal endpoint (motor response) indicating correct needle tip placement for local anesthetic injection?', options: ['A strong motor twitch at 1.5–2.0 mA', 'A visible motor twitch at 0.2–0.5 mA with loss of twitch at 0.1 mA', 'No motor response at any current level', 'A tingling paresthesia at 0.3 mA'], answer: 1, rationale: 'The optimal endpoint is eliciting the appropriate motor response (twitch) at a current of 0.2–0.5 mA. If a twitch is obtained at <0.2 mA (especially if injection resistance is high), the needle may be intraneural — the needle should be withdrawn slightly before injecting. Loss of twitch at ≥0.5 mA suggests the needle is too far from the nerve.' },
  { id: 44, section: 'Section 12 — Vascular Access & Infusion', q: 'A patient is hemorrhaging and requires the fastest possible fluid resuscitation. Which catheter size delivers the greatest flow rate?', options: ['18G peripheral IV catheter', '16G peripheral IV catheter', '14G peripheral IV catheter', '8.5 Fr introducer (cordis) sheath'], answer: 3, rationale: "Per Poiseuille's law, flow is proportional to the radius to the 4th power. An 8.5 Fr introducer sheath (cordis) has an internal lumen substantially larger than even a 14G peripheral IV and can deliver fluid at rates exceeding 500 mL/min with pressure. Among peripheral IVs: 14G (>250 mL/min) > 16G (~180 mL/min) > 18G (~90 mL/min)." },
  { id: 45, section: 'Section 12 — Vascular Access & Infusion', q: "An arterial line is placed in the radial artery for continuous blood pressure monitoring. Before placing a radial arterial line, the modified Allen's test is performed to assess:", options: ['Adequate collateral ulnar circulation to the hand', 'Presence of a normal radial pulse waveform', 'Patency of the palmar arches bilaterally', 'Risk of arteriovenous fistula formation'], answer: 0, rationale: "The modified Allen's test assesses whether the ulnar artery can provide adequate collateral perfusion to the hand if the radial artery is occluded by the arterial line or damaged during insertion. Return of color within 5–7 seconds after releasing ulnar pressure indicates adequate ulnar collateral flow. A negative Allen's test (>15 seconds or no return) suggests inadequate collateral circulation." },
  { id: 46, section: 'Section 12 — Vascular Access & Infusion', q: 'A TIVA infusion of propofol is running via a target-controlled infusion (TCI) pump. Which pharmacokinetic model is most commonly used for propofol TCI in adults?', options: ['Marsh model — uses weight-based compartment calculations', 'Schnider model — incorporates weight, height, age, and lean body mass', 'Shafer-Varvel model — designed specifically for pediatric propofol dosing', 'Minto model — developed for remifentanil TCI'], answer: 1, rationale: 'The Schnider model (1998) incorporates patient covariates including total body weight, height, age, and derived lean body mass (LBM) to calculate propofol distribution and clearance. It targets plasma (Cp) or effect-site (Ce) concentration. The Marsh model (1991) uses only body weight. The Minto model is used for remifentanil TCI.' },
  { id: 47, section: 'Clinical Integration — Airway & Machine', q: 'SITUATIONAL: After RSI and ETT placement for a laparoscopic cholecystectomy, you note SpO2 declining and bilateral breath sounds are absent on the LEFT. ETCO2 waveform is present. The MOST likely cause and immediate action is:', options: ['Esophageal intubation — remove ETT and ventilate by mask', 'Right mainstem endobronchial intubation — withdraw the ETT 2–3 cm', 'Left-sided tension pneumothorax — needle decompression 2nd ICS MCL', 'Kinked ETT — replace with a new tube'], answer: 1, rationale: 'ETCO2 confirms tracheal placement (eliminating esophageal intubation). Absent breath sounds on the LEFT with present ETCO2 and declining SpO2 after RSI strongly suggests right mainstem endobronchial intubation — the ETT has advanced too far into the right main bronchus, excluding the left lung. The right mainstem is shorter, straighter, and larger — the most common site of endobronchial intubation. Withdraw the ETT 2–3 cm while auscultating.' },
  { id: 48, section: 'Clinical Integration — Equipment & Safety', q: 'SITUATIONAL: Mid-case, the O2 supply pipeline fails. You switch to E-cylinder oxygen. The E-cylinder reads 900 psi. Your patient is on 3 L/min O2. Approximately how long before the E-cylinder runs out?', options: ['~30 minutes', '~45 minutes', '~60 minutes', '~90 minutes'], answer: 3, rationale: 'Using the E-cylinder duration formula: Duration (min) = [Pressure (psi) × 0.3] ÷ Flow rate (L/min). Duration = (900 × 0.3) ÷ 3 = 270 ÷ 3 = 90 minutes. This gives approximately 90 minutes — enough time to complete most cases or arrange for a new cylinder/pipeline restoration.' },
  { id: 49, section: 'Clinical Integration — Airway Selection', q: 'SITUATIONAL: A 52-year-old male presents for elective rhinoplasty with Mallampati III, limited mouth opening (2 cm), short thyromental distance, and a beard. He has no known difficult airway history. The MOST appropriate plan is:', options: ['Standard RSI with direct laryngoscopy — Mallampati III alone is rarely problematic', 'Awake fiberoptic intubation with topical airway anesthesia and dexmedetomidine sedation', 'Video laryngoscopy with a hyperangulated blade after standard induction, with a surgical airway kit immediately available', 'LMA placement — rhinoplasty does not require intubation'], answer: 1, rationale: 'Multiple predictors of difficult airway are present: Mallampati III, limited mouth opening (2 cm — normal is ≥3.5 cm), short thyromental distance, and beard. The combination of 2–3 independent difficult airway predictors with difficult bag-mask ventilation indicators warrants an awake technique. AFOI with topical anesthesia and light dexmedetomidine sedation is the gold-standard for anticipated difficult airway management.' },
  { id: 50, section: 'Clinical Integration — Monitors & Circuits', q: 'SITUATIONAL: During a 4-hour open abdominal case, the CO2 absorbent granules turn PURPLE/VIOLET. The ETCO2 is rising (55 mmHg) despite unchanged ventilator settings. What is the correct interpretation and action?', options: ['Normal color change — no action needed, replace absorbent at end of case', 'Absorbent is exhausted — replace the CO2 absorbent immediately to prevent hypercapnia and rebreathing', 'Sevoflurane has reacted with the absorbent — stop sevoflurane, switch to TIVA', 'The color change indicates moisture loss — increase fresh gas flow to compensate'], answer: 1, rationale: 'CO2 absorbents contain a pH-sensitive color indicator. Fresh absorbent is white/off-white; when exhausted, the indicator turns VIOLET/PURPLE (soda lime). Rising ETCO2 with unchanged ventilator settings = CO2 rebreathing from exhausted absorbent. Replace immediately. Note: some absorbents can paradoxically return to white when CO2 is no longer being absorbed ("regeneration") — the granules can appear white but be functionally exhausted; always check ETCO2.' },
];

function ScoreBar({ score, total }) {
  const pct = total > 0 ? Math.round((score / total) * 100) : 0;
  const color = pct >= 90 ? 'bg-emerald-500' : pct >= 80 ? 'bg-teal-500' : pct >= 70 ? 'bg-amber-500' : 'bg-red-500';
  return (
    <div>
      <div className="flex items-center justify-between mb-1">
        <span className="text-sm font-semibold text-foreground">{score}/{total} correct ({pct}%)</span>
        <span className="text-xs text-muted-foreground">{pct >= 90 ? 'Excellent ≥90%' : pct >= 80 ? 'Proficient 80–89%' : pct >= 70 ? 'Developing 70–79%' : 'Review needed'}</span>
      </div>
      <div className="w-full h-2.5 bg-secondary rounded-full overflow-hidden">
        <div className={`h-full rounded-full transition-all duration-700 ${color}`} style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}

export default function EquipmentQuiz() {
  const { isEntitled } = useEntitlement();
  const [paywallOpen, setPaywallOpen] = useState(false);
  const [showGate, setShowGate] = useState(false);
  const [currentQ, setCurrentQ] = useState(0);
  const [selected, setSelected] = useState(null);
  const [showAnswer, setShowAnswer] = useState(false);
  const [answers, setAnswers] = useState({});
  const [mode, setMode] = useState('test');
  const [reviewQ, setReviewQ] = useState(0);
  const [showRationale, setShowRationale] = useState(false);

  const availableQuestions = isEntitled ? QUESTIONS : QUESTIONS.slice(0, FREE_PREVIEW_LIMIT);

  // Scroll to top whenever the question or mode changes so the question is visible
  useScrollReset([currentQ, reviewQ, mode]);

  const q = availableQuestions[currentQ];
  const totalAnswered = Object.keys(answers).length;
  const totalCorrect = Object.values(answers).filter(a => a.correct).length;

  function handleSelect(idx) {
    if (showAnswer) return;
    setSelected(idx);
    setShowAnswer(true);
    setAnswers(prev => ({ ...prev, [q.id]: { chosen: idx, correct: idx === q.answer } }));
  }

  function handleNext() {
    setSelected(null);
    setShowAnswer(false);
    if (currentQ < availableQuestions.length - 1) {
      setCurrentQ(currentQ + 1);
    } else if (isEntitled) {
      setMode('results');
    } else {
      setShowGate(true);
    }
  }

  function handleReset() {
    setCurrentQ(0);
    setSelected(null);
    setShowAnswer(false);
    setAnswers({});
    setMode('test');
    setReviewQ(0);
    setShowRationale(false);
    setShowGate(false);
  }

  function getOptionStyle(idx) {
    if (!showAnswer) {
      return selected === idx ? 'bg-primary/10 border-primary ring-1 ring-primary' : 'bg-card border-border hover:bg-secondary/50';
    }
    if (idx === q.answer) return 'bg-emerald-50 border-emerald-300 ring-1 ring-emerald-400';
    if (idx === selected && idx !== q.answer) return 'bg-red-50 border-red-300 ring-1 ring-red-400';
    return 'bg-card border-border opacity-50';
  }

  // RESULTS MODE
  if (mode === 'results') {
    const pct = Math.round((totalCorrect / QUESTIONS.length) * 100);
    return (
      <div className="flex flex-col gap-4">
        <div className="bg-teal-800 text-white rounded-2xl p-5 text-center">
          <Trophy className="w-10 h-10 mx-auto mb-2 opacity-90" />
          <h2 className="font-bold text-xl">Quiz Complete!</h2>
          <p className="text-4xl font-bold mt-1">{pct}%</p>
          <p className="text-sm opacity-80 mt-1">{totalCorrect} / {QUESTIONS.length} correct</p>
        </div>
        <div className="bg-amber-50 border border-amber-200 rounded-xl p-3">
          <p className="text-xs text-amber-800 font-medium">45–50 = Excellent (≥90%) · 40–44 = Proficient (80–89%) · 35–39 = Developing (70–79%) · &lt;35 = Review equipment module sections</p>
        </div>
        <div className="flex gap-2">
          <button onClick={() => { setMode('review'); setReviewQ(0); setShowRationale(false); }}
            className="flex-1 py-3 bg-teal-50 border border-teal-200 rounded-xl text-sm font-semibold text-teal-700 active:scale-95 transition-all">
            📖 Review Answers
          </button>
          <button onClick={handleReset}
            className="flex-1 py-3 bg-primary text-white rounded-xl text-sm font-semibold active:scale-95 transition-all flex items-center justify-center gap-1">
            <RotateCcw className="w-4 h-4" /> Restart
          </button>
        </div>
        <p className="text-xs text-muted-foreground text-center">© CE HALO LLC — For educational use only.</p>
      </div>
    );
  }

  // REVIEW MODE
  if (mode === 'review') {
    const rq = QUESTIONS[reviewQ];
    const userAnswer = answers[rq.id];
    return (
      <div className="flex flex-col gap-3">
        <div className="flex items-center justify-between">
          <button onClick={() => setMode('results')} className="flex items-center gap-1 text-primary text-sm font-medium">
            <ChevronLeft className="w-4 h-4" /> Results
          </button>
          <span className="text-xs text-muted-foreground">Q{reviewQ + 1} of {QUESTIONS.length}</span>
        </div>
        <div className="rounded-xl p-3 border bg-teal-50 border-teal-200">
          <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-teal-100 text-teal-700">{rq.section}</span>
          <p className="text-sm font-semibold text-foreground mt-2 leading-relaxed">{rq.q}</p>
        </div>
        <div className="flex flex-col gap-2">
          {rq.options.map((opt, idx) => {
            let style = 'bg-card border-border';
            let icon = null;
            if (idx === rq.answer) { style = 'bg-emerald-50 border-emerald-300'; icon = <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0" />; }
            else if (userAnswer?.chosen === idx && idx !== rq.answer) { style = 'bg-red-50 border-red-300'; icon = <XCircle className="w-4 h-4 text-red-500 shrink-0" />; }
            return (
              <div key={idx} className={`flex items-start gap-2 p-3 rounded-xl border ${style}`}>
                <span className="text-xs font-bold text-muted-foreground shrink-0 mt-0.5">{String.fromCharCode(65 + idx)}.</span>
                <p className="text-xs text-foreground flex-1">{opt}</p>
                {icon}
              </div>
            );
          })}
        </div>
        <button onClick={() => setShowRationale(r => !r)}
          className="flex items-center justify-between w-full p-3 bg-teal-50 border border-teal-200 rounded-xl text-sm font-semibold text-teal-700 active:scale-95 transition-all">
          <span>📖 Rationale</span>
          {showRationale ? <ChevronLeft className="w-4 h-4 rotate-90" /> : <ChevronRight className="w-4 h-4 rotate-90" />}
        </button>
        {showRationale && (
          <div className="p-3 bg-teal-50/50 border border-teal-200 rounded-xl">
            <p className="text-xs text-foreground leading-relaxed">{rq.rationale}</p>
          </div>
        )}
        <div className="flex gap-2">
          <button onClick={() => { setReviewQ(r => Math.max(0, r - 1)); setShowRationale(false); }}
            disabled={reviewQ === 0}
            className="flex-1 py-3 bg-secondary border border-border rounded-xl text-sm font-semibold text-muted-foreground disabled:opacity-40 active:scale-95 transition-all flex items-center justify-center gap-1">
            <ChevronLeft className="w-4 h-4" /> Prev
          </button>
          <button onClick={() => { setReviewQ(r => Math.min(QUESTIONS.length - 1, r + 1)); setShowRationale(false); }}
            disabled={reviewQ === QUESTIONS.length - 1}
            className="flex-1 py-3 bg-primary text-white rounded-xl text-sm font-semibold disabled:opacity-40 active:scale-95 transition-all flex items-center justify-center gap-1">
            Next <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      </div>
    );
  }

  // FREE PREVIEW GATE
  if (showGate) {
    return (
      <>
        <QuizFreePreviewGate
          answeredCount={FREE_PREVIEW_LIMIT}
          totalQuestions={QUESTIONS.length}
          onSubscribe={() => setPaywallOpen(true)}
          onBack={handleReset}
        />
        <PaywallModal open={paywallOpen} onClose={() => setPaywallOpen(false)} />
      </>
    );
  }

  // TEST MODE
  return (
    <div className="flex flex-col gap-3">
      <div className="bg-teal-800 text-white px-4 py-4 rounded-2xl">
        <div className="flex items-center justify-between mb-2">
          <div className="flex items-center gap-2">
            <BookOpen className="w-5 h-5" />
            <span className="text-xs font-bold uppercase tracking-widest opacity-80">CE HALO LLC</span>
          </div>
          <button onClick={handleReset}
            className="flex items-center gap-1 px-2.5 py-1.5 bg-card/20 hover:bg-card/30 rounded-lg text-xs font-semibold transition-all active:scale-95">
            <RotateCcw className="w-3.5 h-3.5" /> Reset
          </button>
        </div>
        <h2 className="font-bold text-base">Anesthesia Equipment Rapid-Fire Quiz</h2>
        <p className="text-xs opacity-70">50 Questions · All 12 Equipment Sections · NBCRNA NCE Board Prep</p>
      </div>

      <div className="bg-card rounded-2xl border border-border p-3">
        <div className="flex items-center justify-between mb-2">
          <span className="text-xs font-semibold text-foreground">Question {currentQ + 1} of {availableQuestions.length}</span>
          <span className="text-xs text-muted-foreground">{totalAnswered} answered · {totalCorrect} correct</span>
        </div>
        <ScoreBar score={totalCorrect} total={totalAnswered} />
      </div>

      <div className="rounded-xl p-3 border bg-teal-50 border-teal-200">
        <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-teal-100 text-teal-700">{q.section}</span>
        <p className="text-sm font-semibold text-foreground mt-2 leading-relaxed">{q.q}</p>
      </div>

      <div className="flex flex-col gap-2">
        {q.options.map((opt, idx) => (
          <button key={idx} onClick={() => handleSelect(idx)}
            className={`flex items-start gap-2 p-3 rounded-xl border text-left transition-all active:scale-[0.98] ${getOptionStyle(idx)}`}>
            <span className="text-xs font-bold text-muted-foreground shrink-0 mt-0.5 min-w-[16px]">{String.fromCharCode(65 + idx)}.</span>
            <p className="text-xs text-foreground leading-relaxed">{opt}</p>
            {showAnswer && idx === q.answer && <CheckCircle2 className="w-4 h-4 text-emerald-500 shrink-0 ml-auto" />}
            {showAnswer && idx === selected && idx !== q.answer && <XCircle className="w-4 h-4 text-red-500 shrink-0 ml-auto" />}
          </button>
        ))}
      </div>

      {showAnswer && (
        <div className="p-3 bg-teal-50 border border-teal-200 rounded-xl">
          <p className="text-xs font-semibold text-teal-700 mb-1">
            {selected === q.answer ? '✅ Correct!' : '❌ Incorrect'} — Rationale
          </p>
          <p className="text-xs text-foreground leading-relaxed">{q.rationale}</p>
        </div>
      )}

      <div className="flex gap-2">
        <button onClick={() => {
          const prevIdx = Math.max(0, currentQ - 1);
          const prevQ = availableQuestions[prevIdx];
          const prevAnswer = answers[prevQ.id];
          setCurrentQ(prevIdx);
          setSelected(prevAnswer?.chosen ?? null);
          setShowAnswer(prevAnswer !== undefined);
        }}
          disabled={currentQ === 0}
          className="px-4 py-3 bg-secondary border border-border rounded-xl text-sm font-semibold text-muted-foreground disabled:opacity-40 active:scale-95 transition-all">
          <ChevronLeft className="w-4 h-4" />
        </button>
        <button onClick={handleNext}
          disabled={!showAnswer}
          className="flex-1 py-3 bg-primary text-white rounded-xl text-sm font-semibold disabled:opacity-40 active:scale-95 transition-all flex items-center justify-center gap-1">
          {currentQ === QUESTIONS.length - 1 ? 'View Results' : 'Next Question'} <ChevronRight className="w-4 h-4" />
        </button>
      </div>

      <p className="text-xs text-muted-foreground text-center">© CE HALO LLC — For educational use only. Not for clinical decision-making.</p>
    </div>
  );
}