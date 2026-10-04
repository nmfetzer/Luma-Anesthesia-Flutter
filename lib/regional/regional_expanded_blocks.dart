part of 'regional_content.dart';

// Adult clinician references. Atlas volumes are context, not default orders.
// These topics remain subject to owner review before publication.
const supraclavicularExpandedSections = <RegionalSection>[
  RegionalSection(
    'At a glance',
    [
      'Best fit: Dense upper-limb coverage for arm, elbow, forearm, and hand procedures.',
      'Coverage gap: The intercostobrachial territory of the proximal medial arm is outside the brachial plexus; assess tourniquet and incision requirements separately.',
      'Major trade-off: The plexus is close to the subclavian vessels, first rib, and pleura. Ultrasound does not eliminate pneumothorax or phrenic involvement.',
      'Recovery priority: Protect the numb arm and assess new respiratory symptoms rather than assuming they are a harmless block effect.',
    ],
    ['sc'],
  ),
  RegionalSection(
    'Selection & coverage',
    [
      'Match the surgical field: Assess the incision, deep structures, tourniquet, and duration. Do not infer adequate shoulder anesthesia solely from a successful distal arm block.',
      'Pulmonary reserve: Supraclavicular blockade may reduce phrenic involvement relative to conventional interscalene techniques, but it is not reliably phrenic-free. Consider a more distal approach when respiratory consequences would be unacceptable.',
      'Baseline assessment: Record existing weakness, sensory deficit, vascular compromise, and relevant pulmonary symptoms. Establish a rescue anesthetic and analgesic plan before placement.',
      'Safety review: Obtain consent, confirm side, exclude puncture-site infection, review allergy and antithrombotics, and determine whether the patient can cooperate with safe positioning.',
    ],
    ['sc', 'diaphragm-2025', 'nerve', 'asra', 'infection'],
  ),
  RegionalSection(
    'Anatomy & ultrasound orientation',
    [
      'Primary landmarks: Identify the subclavian artery above the first rib and the plexus cluster typically posterior and superficial to the artery.',
      'Rib versus pleura: Distinguish the first-rib acoustic shadow from the pleural line and lung sliding. A visible bright line alone is not proof that the needle is safely over rib.',
      'Map the whole target: Scan cephalad and caudad to understand the trunks/divisions and the relationship of the inferior portion of the plexus to artery and rib.',
      'Vessel survey: Use color Doppler to identify crossing branches, including variable dorsal scapular, transverse cervical, or suprascapular arteries.',
      'Image reference: The linked atlas provides labeled ultrasound and probe-placement images. These open externally and require internet.',
    ],
    ['sc'],
  ),
  RegionalSection(
    'Equipment & positioning',
    [
      'Position: Supine or semi-sitting, with the head gently turned away as tolerated. Shoulder depression may improve access above the clavicle; avoid forcing neck or shoulder movement.',
      'Ultrasound and needle: A high-frequency linear probe and an appropriately selected echogenic block needle are typical. Adjust depth and needle length to the individual rather than using fixed anatomy assumptions.',
      'Monitoring: Establish IV access and appropriate physiologic monitoring, with trained assistance, airway equipment, and LAST rescue capability immediately available.',
      'Sterile setup: Use skin antisepsis, sterile gloves, sterile probe cover and gel, and appropriate mask/field precautions. For a catheter, protect the adjacent probe cable and securement field.',
    ],
    ['sc', 'infection', 'last'],
  ),
  RegionalSection(
    'Technique & injection safeguards',
    [
      'Plan the trajectory: Choose an in-plane path that keeps the actual needle tip, vessels, and pleural boundary visible. The intended fascial target must be clear before injection.',
      'Observe initial spread: After aspiration, use a small observed aliquot to confirm the plane. Continue incrementally only with appropriate spread and no concerning pressure, pain, or nerve expansion.',
      'Incomplete distribution: Reassess tip position and which portion of the plexus remains uncovered. Do not force injection, blindly advance, or treat a fixed “corner pocket” trajectory as safe for every anatomy.',
      'Complementary safeguards: Repeated aspiration, ultrasound, patient feedback, and pressure/stimulation information reduce uncertainty but no single reassuring finding excludes vascular or neural injury.',
      'Completion: Document the agent, concentration, total milligrams, observed spread, and clinical response, then monitor block development before incision.',
    ],
    ['sc', 'nerve'],
  ),
  RegionalSection(
    'Local anesthetics & dose context',
    [
      'Atlas context: NYSORA describes 20–25 mL for a typical adult technique. The cited volume is not a formulation-specific dose, mandatory target, or assurance of diaphragm preservation.',
      'Total exposure: Include skin infiltration, supplements for tourniquet/medial-arm coverage, other blocks, and surgeon infiltration in the cumulative local-anesthetic plan.',
      'Duration trade-off: Choose formulation and any adjuvant by expected need and local policy; prolonged sensory block can also mean prolonged motor impairment and a later pain transition.',
      'Catheter prescription: A continuous regimen must specify drug, concentration, basal/bolus settings, lockout, limits, monitoring, and responsible service. Do not copy a rate without its concentration.',
    ],
    ['sc', 'exparel', 'nerve'],
  ),
  RegionalSection(
    'Block assessment & incomplete coverage',
    [
      'Test the operative territory: Assess sensory change and relevant motor effects in median, ulnar, radial, and musculocutaneous distributions, accounting for the planned incision.',
      'Residual ulnar territory: Reassess inferior plexus spread and onset time before considering targeted supplementation. Avoid reflexively repeating the full block.',
      'Medial upper-arm pain: Consider the intercostobrachial gap or tourniquet-related discomfort rather than assuming all pain represents plexus failure.',
      'Before rescue: Review what has already been given, distinguish an anatomic gap from insufficient onset, and choose supplementation or a different anesthetic plan with continued monitoring.',
    ],
    ['sc', 'nerve'],
  ),
  RegionalSection(
    'Complications & urgent escalation',
    [
      'New dyspnea or chest pain: Evaluate airway, ventilation, oxygenation, hemodynamics, and possible pneumothorax or diaphragmatic impairment. Pneumothorax symptoms can be delayed.',
      'Neck swelling or bleeding: Assess promptly, particularly with progressive symptoms, airway effects, or antithrombotic exposure. Do not dismiss a deep hematoma as routine bruising.',
      'Suspected LAST: Stop local-anesthetic delivery, call for help, and follow the current ASRA LAST aid with airway/ventilatory support and appropriate resuscitation.',
      'Neurologic symptoms: Progressive, complete, or functionally important deficits require prompt evaluation. Consider positioning, surgical injury, compression, and the block rather than assigning a cause without assessment.',
    ],
    ['sc', 'last', 'nerve', 'asra'],
  ),
  RegionalSection(
    'Catheter management & recovery',
    [
      'Selection: Use a catheter only when the expected benefit and available follow-up justify respiratory, infection, migration, and pump-management burdens.',
      'Function: Confirm appropriate spread and response before relying on infusion; review a failing catheter rather than delivering repeated blind rescue boluses.',
      'Handoff: Communicate respiratory risk, sensory/motor findings, complete infusion prescription, and an explicit stop/escalation pathway.',
      'Home care: Protect the insensate limb, arrange a pain-transition plan, and supply written instructions, a reachable clinical contact, and removal arrangements. Progressive dyspnea warrants urgent evaluation.',
    ],
    ['sc', 'infection', 'nerve', 'rebound-2026'],
  ),
  RegionalSection(
    'Evidence & current controversies',
    [
      'Respiratory outcomes: The 2025 systematic review found lower complete hemidiaphragmatic-paralysis risk with several techniques compared with conventional interscalene block, including supraclavicular blockade; certainty differed by comparison.',
      'Study boundary: That review searched through December 2022. Its findings do not establish a zero-risk volume or make every supraclavicular approach interchangeable.',
      'Prolongation strategies: Rebound-pain evidence supports considering the complete perioperative analgesic plan, but heterogeneous studies do not establish one best perineural mixture for every upper-limb operation.',
    ],
    ['diaphragm-2025', 'rebound-2026', 'sc'],
  ),
];

const infraclavicularExpandedSections = <RegionalSection>[
  RegionalSection(
    'At a glance',
    [
      'Best fit: Arm, elbow, forearm, and hand procedures below the shoulder.',
      'Coverage gap: Proximal medial-arm skin and tourniquet discomfort may require assessment beyond the brachial plexus.',
      'Major trade-off: A deeper target around the axillary vessels demands reliable needle-tip visualization; a distal location does not eliminate pleural, vascular, or neurologic risk.',
      'Recovery priority: Anticipate arm weakness and reassess catheter benefit, function, and insertion-site condition.',
    ],
    ['ic'],
  ),
  RegionalSection(
    'Selection & coverage',
    [
      'Surgical match: Confirm that the intended operation lies within the expected cord-derived territory. Do not substitute this block alone for a complete shoulder plan.',
      'Catheter advantage: The chest-wall location can provide useful catheter stability when sustained upper-limb analgesia is needed.',
      'Patient factors: Review ability to position the arm, depth/body habitus, chest-wall anatomy, pulmonary reserve, baseline neuropathy, and anticoagulant exposure.',
      'Plan alternatives: If a stable needle view cannot be obtained, reassess approach or choose another block/anesthetic rather than persisting at an unsafe angle.',
    ],
    ['ic', 'nerve', 'asra'],
  ),
  RegionalSection(
    'Anatomy & ultrasound orientation',
    [
      'Primary landmarks: The axillary artery lies deep to pectoralis major and minor. The plexus cords surround it, but their clock-face positions are variable.',
      'Veins: Identify the axillary vein and smaller vessels; release probe pressure when needed because veins may collapse and disappear from view.',
      'Pleura: Scan medially and caudally to identify the chest wall and pleural boundary before selecting the needle trajectory.',
      'Artifacts: Posterior acoustic enhancement is not automatically the posterior cord. Trace anatomy, optimize angle/focus, and use Doppler rather than relying on a single still view.',
      'Spread goal: Assess distribution around the artery in the intended fascial plane, including posterior spread; individual cord visualization is not always possible.',
    ],
    ['ic'],
  ),
  RegionalSection(
    'Equipment & positioning',
    [
      'Position: Usually supine, with the arm positioned to improve access if the patient can tolerate it. Abduction can lift the clavicle and bring the target more superficial; do not force an injured shoulder.',
      'Probe and needle: Select a probe capable of adequate penetration and a needle long enough for the measured trajectory. A steep needle angle can make tip visibility difficult.',
      'Field preparation: Arrange ultrasound, patient, and operator to maintain continuous visualization; prepare a sterile field, probe cover, gel, and appropriate catheter materials if planned.',
      'Readiness: Use IV access, physiologic monitoring, trained assistance, and immediately available airway and LAST rescue equipment.',
    ],
    ['ic', 'infection', 'last'],
  ),
  RegionalSection(
    'Technique & injection safeguards',
    [
      'Approach: The conventional parasagittal approach advances in-plane toward the region posterior to the artery. Other approaches require their own anatomy and training; they are not interchangeable trajectories.',
      'Confirm location: Use a small observed aliquot after aspiration to verify the plane. Continue in increments with repeated assessment of spread, resistance, and patient symptoms.',
      'Distribution: Septa can limit spread. Reposition under direct vision if a territory is not reached rather than forcing fluid across a barrier.',
      'Safety endpoint: Avoid deliberate cord contact or intraneural injection. Poor tip visibility, pain, high resistance, or unexpected spread should stop the injection and prompt reassessment.',
      'Record and reassess: Document total exposure, the observed distribution, and the evolving clinical examination before relying on the block.',
    ],
    ['ic', 'nerve'],
  ),
  RegionalSection(
    'Local anesthetics & dose context',
    [
      'Atlas context: The conventional adult technique is described with approximately 20–30 mL. This is volume context, not a default concentration, safe maximum, or requirement to complete the full volume.',
      'Cumulative dose: Reconcile the main block, medial-arm supplements, skin infiltration, surgeon infiltration, and any catheter boluses/infusion.',
      'Desired duration: Balance analgesia against delayed motor recovery and the needs of the operation. Adjuvant or concentration changes should not be assumed to improve every outcome.',
      'Formulation warning: Do not extrapolate a labeled liposomal-bupivacaine dose from another block to infraclavicular use. Consult the exact product label and institutional policy.',
    ],
    ['ic', 'exparel'],
  ),
  RegionalSection(
    'Block assessment & incomplete coverage',
    [
      'Assess terminal territories: Check the clinically relevant sensory and motor distributions and the incision/tourniquet requirements, not just general arm heaviness.',
      'Patchy distribution: Review onset time and whether spread reached the appropriate cord region. A partial block may reflect an unfilled compartment rather than inadequate total volume.',
      'Medial proximal arm: Consider the intercostobrachial territory when plexus distributions are otherwise blocked.',
      'Rescue strategy: Select targeted supplementation, systemic analgesia, or alternate anesthesia after reviewing cumulative exposure; avoid repeated large-volume reinjection without a diagnosis.',
    ],
    ['ic', 'nerve'],
  ),
  RegionalSection(
    'Complications & urgent escalation',
    [
      'Vascular injury or LAST: Stop injection if intravascular placement is suspected. Escalate systemic neurologic or cardiovascular symptoms using the ASRA LAST pathway.',
      'Respiratory symptoms: Consider pleural injury and other cardiopulmonary causes if dyspnea or chest pain develops; a more distal approach is not a guarantee against pneumothorax.',
      'Deep bleeding: Assess unexplained swelling, pain, or neurologic change promptly, especially with altered hemostasis.',
      'Neurologic deficit: Progressive or significant dysfunction requires evaluation for block, surgical, positioning, and compressive causes.',
    ],
    ['ic', 'last', 'asra', 'nerve'],
  ),
  RegionalSection(
    'Catheter management & recovery',
    [
      'Confirm spread: Before relying on a catheter, verify appropriate distribution and clinical response; secure it and document its external marking.',
      'Troubleshoot before bolusing: Check pump settings, connections, leakage, migration, and the sensory examination when pain increases.',
      'Ongoing review: Reassess motor effects, insertion site, drug delivery, and ongoing need. A stable dressing does not prove correct internal position.',
      'Discharge: Give a limb-protection plan, written pump/removal instructions, a reachable service, and directions for unexpected symptoms or infection.',
    ],
    ['ic', 'infection', 'nerve'],
  ),
  RegionalSection(
    'Evidence & current controversies',
    [
      'Approach selection: The technique atlas summarizes comparative studies and a large registry; these do not establish one approach as best for all operations or patients.',
      'Registry interpretation: Associations between approach, catheter duration, failure, and complications may reflect case mix and practice differences. They should not be turned into a guaranteed safety ranking.',
      'Motor versus analgesic duration: A longer-acting regimen can delay motor recovery without necessarily improving all recovery outcomes. Evaluate patient-relevant benefit and follow-up burden.',
    ],
    ['ic', 'rebound-2026'],
  ),
];

const axillaryExpandedSections = <RegionalSection>[
  RegionalSection(
    'At a glance',
    [
      'Best fit: Elbow, forearm, wrist, and hand surgery when the required terminal nerves are covered.',
      'Coverage gap: The musculocutaneous nerve often lies outside the main perivascular group; the axillary nerve and proximal medial-arm skin are not reliably covered.',
      'Major trade-off: A superficial approach avoids targeting the neck, but multiple vessels and variable nerve positions still create injection and injury risks.',
      'Recovery priority: Confirm the operative distribution and protect the insensate, weak arm.',
    ],
    ['ax'],
  ),
  RegionalSection(
    'Selection & coverage',
    [
      'Operation-specific plan: Match median, ulnar, radial, and musculocutaneous coverage to the incision, bone/joint work, and tourniquet.',
      'Shoulder limitation: The axillary nerve has already branched proximally; do not expect deltoid/shoulder coverage from this approach.',
      'Position tolerance: Assess whether the arm can be abducted comfortably; trauma, contracture, or pain may favor another approach.',
      'Consent and baseline: Discuss incomplete block and rescue options, document neurologic/vascular findings, and review infection, allergies, and hemostasis.',
    ],
    ['ax', 'nerve', 'asra', 'infection'],
  ),
  RegionalSection(
    'Anatomy & ultrasound orientation',
    [
      'Primary landmarks: Identify the axillary artery, surrounding veins, and individual terminal nerves in the proximal medial arm.',
      'Variable relationships: Median, ulnar, and radial nerve positions are not fixed clock-face coordinates. Trace a questionable structure rather than assuming its identity.',
      'Musculocutaneous nerve: Look within or between coracobrachialis and biceps, often separate from the artery. Anatomic variants may place it closer to the median nerve.',
      'Vein visibility: Excess probe pressure can conceal veins. Release pressure and use Doppler before committing to a needle path.',
      'Radial nerve pitfall: Deep acoustic enhancement can mimic neural tissue. Use anatomy and tracking, not brightness alone.',
    ],
    ['ax'],
  ),
  RegionalSection(
    'Equipment & positioning',
    [
      'Position: Support the arm with comfortable abduction, commonly around 90 degrees, without over-abduction or traction on the plexus.',
      'Imaging: A high-frequency linear transducer is generally suitable for the superficial target; orient it across the proximal arm and optimize the full neurovascular view.',
      'Needle planning: Choose an appropriate echogenic needle and paths that minimize crossing nerves and veins while preserving tip visualization.',
      'Setup: Establish monitoring/IV access, sterile probe cover and gel, antisepsis, and immediate availability of airway/resuscitation and LAST supplies.',
    ],
    ['ax', 'infection', 'last'],
  ),
  RegionalSection(
    'Technique & injection safeguards',
    [
      'Map before injecting: Identify the intended nerves and vessels, including the separate musculocutaneous territory.',
      'Observed injections: Whether using a perivascular or selective approach, confirm small-volume spread before continuing and reassess each needle redirection.',
      'No visible spread: Stop injection immediately and reassess tip location, hidden veins, and the imaging plane; absence of visible expansion is not a reason to keep injecting.',
      'Avoid nerve injury: Do not seek intraneural swelling or force injection against resistance. Severe paresthesia or pain on injection warrants stopping and repositioning.',
      'Balance precision and manipulation: More targeted deposits can improve coverage but also add needle movements; perform only the redirections needed for the chosen technique.',
    ],
    ['ax', 'nerve'],
  ),
  RegionalSection(
    'Local anesthetics & dose context',
    [
      'Atlas context: NYSORA describes roughly 15–20 mL for an adult approach, distributed according to the technique and anatomy. This is not a dose order or a requirement to reach that volume.',
      'Separate deposits still add up: Count the musculocutaneous injection, other terminal-nerve deposits, skin infiltration, and surgical supplements in one cumulative exposure plan.',
      'Choose duration deliberately: Match formulation and concentration to anesthesia versus analgesia goals and anticipated motor recovery.',
      'No automatic top-up: An uncovered nerve does not justify a second complete dose. Reassess the gap and remaining drug exposure before supplementation.',
    ],
    ['ax', 'exparel', 'nerve'],
  ),
  RegionalSection(
    'Block assessment & incomplete coverage',
    [
      'Assess each relevant territory: Check median, ulnar, radial, and lateral-forearm/musculocutaneous distribution as appropriate to the procedure.',
      'Lateral forearm gap: Reconsider separate musculocutaneous coverage rather than assuming the perivascular injection reached it.',
      'Posterior or radial gap: Reassess posterior distribution and distinguish a true nerve from an ultrasound artifact.',
      'Tourniquet discomfort: Proximal medial-arm skin may require separate attention; not all tourniquet discomfort is corrected by adding local anesthetic.',
      'Rescue decision: Allow onset, localize the deficit, review total dose, and select targeted supplementation or alternate anesthesia.',
    ],
    ['ax', 'nerve'],
  ),
  RegionalSection(
    'Complications & urgent escalation',
    [
      'Intravascular injection: Multiple compressible veins surround the target. Stop with concerning spread or systemic symptoms and use the LAST response pathway when indicated.',
      'Hematoma: Evaluate progressive swelling or pain and new neurologic changes rather than assuming all bruising is benign.',
      'Neurologic symptoms: Persistent, progressive, or severe dysfunction requires an assessment that includes surgery, positioning, compression, and the block.',
      'Positioning injury: Avoid excessive arm abduction and monitor pressure points during the procedure and recovery.',
    ],
    ['ax', 'last', 'nerve'],
  ),
  RegionalSection(
    'Catheter management & recovery',
    [
      'Selective use: A catheter may be considered for prolonged analgesia, with attention to the mobile axillary site and ability to maintain securement and follow-up.',
      'Function: Confirm distribution through the catheter and reassess leakage, dislodgement, or a changing sensory pattern before repeated boluses.',
      'Recovery: Protect the insensate limb and give a multimodal pain-transition plan before block resolution.',
      'Home support: Provide clear contact, pump, infection-warning, and removal instructions if a catheter is used.',
    ],
    ['ax', 'infection', 'rebound-2026'],
  ),
  RegionalSection(
    'Evidence & current controversies',
    [
      'Comparative success: The atlas summarizes trials and registry data with differing success and complication measures. A superficial approach is not automatically the most successful or risk-free approach.',
      'Technique variation: Selective nerve and perivascular strategies differ in needle manipulation, local-anesthetic distribution, and completeness. Choose a trained, anatomy-guided approach rather than treating them as identical.',
      'Catheter methods: The atlas does not establish that one catheter trajectory is universally more effective; clinical confirmation and follow-up remain essential.',
    ],
    ['ax', 'nerve'],
  ),
];

const femoralExpandedSections = <RegionalSection>[
  RegionalSection(
    'At a glance',
    [
      'Best fit: Anterior thigh/knee analgesia, femoral or patellar procedures, and selected hip-fracture pain pathways.',
      'Coverage gap: A femoral block does not provide complete posterior knee, whole-leg, or hip surgical anesthesia.',
      'Major trade-off: Quadriceps weakness is expected; pain relief is not proof of safe ambulation.',
      'Recovery priority: Assess knee-extension strength and use assisted mobilization and limb-protection precautions.',
    ],
    ['fn', 'ipack', 'ac'],
  ),
  RegionalSection(
    'Selection & coverage',
    [
      'Define the goal: Decide whether the block is an analgesic component or part of a broader surgical anesthetic plan.',
      'Hip pain: Femoral analgesia can help selected hip-fracture patients, but does not cover every articular contribution or the surgical incision.',
      'Knee pathway: Compare the need for dense anterior coverage with rehabilitation goals; adductor canal approaches may preserve more motor function but have different coverage and residual weakness risk.',
      'Baseline and contraindications: Document neurologic/vascular status, ability to mobilize, infection risk, drug allergy, and antithrombotic exposure before consent and laterality confirmation.',
    ],
    ['fn', 'ac', 'peng', 'nerve', 'asra'],
  ),
  RegionalSection(
    'Anatomy & ultrasound orientation',
    [
      'Primary landmarks: At the femoral crease identify the artery, vein, iliopsoas, fascia lata, and fascia iliaca.',
      'Nerve location: The femoral nerve is typically lateral to the artery, deep to fascia iliaca and on the iliopsoas surface.',
      'Level selection: If arterial branching makes the anatomy confusing, scan proximally to define the common femoral artery and its relation to the nerve.',
      'Fascial distinction: An injection near the nerve but superficial to the intended fascia can fail. Identify both fascia layers rather than relying on a tactile “pop.”',
      'Vessel variants and distortion: The vein may not be strictly medial; pressure can hide it. Surgical fluid extravasation, including after hip arthroscopy, can displace or deepen landmarks.',
    ],
    ['fn'],
  ),
  RegionalSection(
    'Equipment & positioning',
    [
      'Position: Supine with the groin accessible and the limb supported; optimize comfort in a patient with a painful fracture rather than forcing rotation.',
      'Probe: Use a linear transducer when depth permits, adjusting angle to improve the nerve’s echogenicity and identify the fascia.',
      'Needle path: Plan a controlled in-plane approach that avoids vessels and maintains the tip in view; select needle length from actual depth.',
      'Preparation: Use antisepsis, sterile probe cover/gel, appropriate monitoring and IV access, with trained help and LAST rescue capability.',
    ],
    ['fn', 'infection', 'last'],
  ),
  RegionalSection(
    'Technique & injection safeguards',
    [
      'Target plane: Place local anesthetic adjacent to the nerve deep to fascia iliaca, with observed spread separating the relevant fascial structures.',
      'Incremental confirmation: Aspirate and observe a small initial aliquot before continuing; repeated aspiration does not itself prove extravascular placement.',
      'Spread, not needle contact: Circumferential encirclement is not required. Do not chase a complete ring by repeatedly contacting or passing through the nerve.',
      'High resistance or pain: Stop and reassess for intraneural position, the wrong fascial plane, or a poorly visualized tip.',
      'Stimulation: A quadriceps response can be an adjunct to localization, not a substitute for anatomy, safe pressure, and tip/spread assessment.',
    ],
    ['fn', 'nerve'],
  ),
  RegionalSection(
    'Local anesthetics & dose context',
    [
      'Atlas context: Approximately 10–15 mL is described for an adult single-injection ultrasound-guided technique. Concentration and total milligrams must still be chosen for the patient and purpose.',
      'Combined blocks: Include posterior-knee or sciatic supplements, surgeon infiltration, and any catheter infusion in the cumulative plan.',
      'Motor duration: Consider the consequences of prolonged quadriceps weakness when selecting agent, concentration, adjuvant, and infusion duration.',
      'Continuous prescription: Document concentration, basal/bolus delivery and limits, not only mL/hour, with an explicit reassessment and mobilization plan.',
    ],
    ['fn', 'ac', 'exparel'],
  ),
  RegionalSection(
    'Block assessment & incomplete coverage',
    [
      'Assess effect: Evaluate anterior-thigh/knee analgesia, relevant sensory distribution, and quadriceps function while respecting surgical restrictions.',
      'Persistent posterior knee pain: Consider a coverage gap rather than simple femoral-block failure; assess the posterior modality within the full knee pathway.',
      'Poor anterior effect: Reassess onset and whether injectate reached beneath fascia iliaca. A superficial collection can look substantial without achieving the intended block.',
      'Before supplementation: Review total exposure and whether pain could represent another process rather than repeatedly escalating the block.',
    ],
    ['fn', 'ipack', 'nerve'],
  ),
  RegionalSection(
    'Complications & urgent escalation',
    [
      'Falls: Do not permit unsupported ambulation based on analgesia alone. Reassess strength and coordinate with nursing and physical therapy.',
      'Vascular injury or LAST: Stop with concerning symptoms or spread; evaluate swelling and use the LAST pathway for systemic toxicity.',
      'Unexpected weakness: Compare with baseline, expected block distribution, surgical factors, and progression. Significant or worsening deficits warrant prompt evaluation.',
      'Groin catheter infection: New spreading erythema, tenderness, drainage, or fever requires assessment and early management, not dressing replacement alone.',
    ],
    ['fn', 'ac', 'last', 'nerve', 'infection'],
  ),
  RegionalSection(
    'Catheter management & recovery',
    [
      'Catheter goal: Confirm spread near the nerve beneath fascia iliaca; the mobile groin and shallow target can promote dislodgement.',
      'Daily benefit review: Reassess analgesia versus quadriceps weakness and rehabilitation needs, along with site condition and pump function.',
      'Breakthrough pain: Check migration, connections, delivery, and coverage before repeated catheter boluses.',
      'Discharge planning: Provide assisted-mobilization instructions, limb protection, a medication transition, and contact/removal arrangements if outpatient infusion is selected.',
    ],
    ['fn', 'infection', 'nerve'],
  ),
  RegionalSection(
    'Evidence & current controversies',
    [
      'Hip-fracture evidence: The atlas summarizes supportive analgesic studies, including observational cohorts. Their findings should not be generalized into a guarantee of improved length of stay or mobility for every patient.',
      'Femoral versus adductor canal: The trade-off is not simply “stronger versus safer”; coverage, motor effects, surgical pathway, and rescue needs all matter.',
      'Continuous versus single injection: A longer infusion may support analgesia but also extend motor impairment and catheter-related burden. Select it for an individual benefit rather than by default.',
    ],
    ['fn', 'ac', 'infection'],
  ),
];

const adductorCanalExpandedSections = <RegionalSection>[
  RegionalSection(
    'At a glance',
    [
      'Best fit: Medial leg/foot sensory supplementation and a component of multimodal knee analgesia.',
      'Coverage gap: It is not a complete knee or foot/ankle surgical anesthetic and does not reliably address posterior knee pain.',
      'Major trade-off: “Motor-sparing” is an aim, not a guarantee; proximal spread can weaken quadriceps.',
      'Recovery priority: Assess actual strength before walking and coordinate posterior coverage and surgeon infiltration when needed.',
    ],
    ['ac', 'ipack'],
  ),
  RegionalSection(
    'Selection & coverage',
    [
      'Knee analgesia: Select the approach within the total perioperative pathway, including posterior pain, incision coverage, and planned rehabilitation.',
      'Foot/ankle supplementation: Saphenous coverage can address the medial territory left by a sciatic block.',
      'Name the actual level: A femoral triangle, proximal canal, distal canal, and distal saphenous injection are not anatomically identical despite inconsistent terminology in practice.',
      'Risk review: Document baseline strength and sensation, vascular disease, infection, drug allergy, and anticoagulant exposure; agree on monitoring and rescue analgesia.',
    ],
    ['ac', 'ps', 'asra', 'nerve'],
  ),
  RegionalSection(
    'Anatomy & ultrasound orientation',
    [
      'Canal relationships: Sartorius forms the roof, with vastus medialis lateral and adductor longus/magnus medially/posteriorly. Identify the femoral artery and vein beneath sartorius.',
      'Saphenous nerve: It is a sensory branch of the femoral nerve, often appearing as a small structure near the artery; direct visualization may be difficult.',
      'Trace rather than estimate: Follow the vessels and fascial relationships to understand whether the probe is in the triangle, canal, or approaching the hiatus.',
      'Distal alternative: Below the knee, the nerve runs near the great saphenous vein; this is a different target from a proximal canal technique.',
      'Vascular hazards: Survey the artery, vein, and genicular branches with Doppler; avoid pressure that hides small veins.',
    ],
    ['ac'],
  ),
  RegionalSection(
    'Equipment & positioning',
    [
      'Position: Usually supine with the thigh comfortably abducted/external rotated as tolerated. Protect the operated limb and avoid stressing the joint.',
      'Imaging: A linear probe is typically suitable; increase penetration or adjust probe choice if habitus obscures the vessel/fascial relationships.',
      'Needle setup: Select a trajectory and needle length that permit clear tip visualization without traversing the vessels.',
      'Preparation: Use antisepsis, sterile probe cover and gel, monitoring, IV access, and readily available resuscitation/LAST support.',
    ],
    ['ac', 'infection', 'last'],
  ),
  RegionalSection(
    'Technique & injection safeguards',
    [
      'Target the chosen level: Document where the injection is made rather than recording only “ACB.” Place injectate in the intended subsartorial/perivascular plane.',
      'Observed spread: Confirm with a small aliquot after aspiration; continue incrementally with the needle tip and vessel boundaries visible.',
      'If spread is wrong: Reassess the tip and fascial layer rather than relying on a fixed total volume to overcome poor distribution.',
      'Avoid an intravascular or high-pressure injection: Stop for pain, unexpected resistance, absent visible spread, or uncertain tip location.',
      'Motor implications: More proximal or extensive spread can reach motor branches. A technically completed injection is not proof of preserved quadriceps strength.',
    ],
    ['ac', 'nerve'],
  ),
  RegionalSection(
    'Local anesthetics & dose context',
    [
      'Technique-dependent volume: The atlas describes smaller saphenous injections and larger canal techniques separately. Do not transfer a volume between levels as though their coverage and motor effects were identical.',
      'Combined exposure: Count ACB, iPACK, periarticular infiltration, skin infiltration, and any catheter delivery together.',
      'Liposomal label: The adult labeled EXPAREL adductor-canal regimen is 133 mg admixed with 50 mg bupivacaine HCl. This is formulation- and indication-specific, not a standard for conventional local anesthetics.',
      'Compatibility and follow-up: Follow the complete product label, including additive toxicity and subsequent-local-anesthetic restrictions, when a liposomal formulation is used.',
    ],
    ['ac', 'exparel'],
  ),
  RegionalSection(
    'Block assessment & incomplete coverage',
    [
      'Clinical examination: Assess medial sensory effect, knee pain with the permitted activity, and quadriceps strength rather than relying only on a resting pain score.',
      'Posterior pain: Consider a posterior coverage gap, not an automatic reason to repeat the canal block.',
      'Unexpected quadriceps weakness: Reassess proximal spread and other contributors, including residual neuraxial anesthesia and surgical factors; use assisted mobilization.',
      'Breakthrough pain with a catheter: Check migration, leakage, pump settings, onset, and the location of pain before further boluses.',
    ],
    ['ac', 'ipack', 'nerve'],
  ),
  RegionalSection(
    'Complications & urgent escalation',
    [
      'Fall risk persists: Even when weakness is less than with femoral block, an individual patient may not be safe to stand unsupported.',
      'Vascular puncture and LAST: Reassess swelling or concerning systemic symptoms and use the LAST response pathway when indicated.',
      'New neurologic findings: Progressive or severe deficits require evaluation for neural, compressive, vascular, surgical, and positioning causes.',
      'Severe unexpected pain: Do not assume every pain increase is ordinary block resolution; assess the surgical limb and clinical context.',
    ],
    ['ac', 'nerve', 'last'],
  ),
  RegionalSection(
    'Catheter management & recovery',
    [
      'Select for benefit: Consider continuous analgesia only with a complete rehabilitation and follow-up pathway.',
      'Migration matters: Movement, leakage, or displacement can change distribution; confirm function instead of assuming the catheter remains in its initial position.',
      'Prescription: Specify drug/concentration, infusion or programmed bolus parameters, dose limits, and who can adjust the pump.',
      'Recovery plan: Coordinate assisted ambulation, sensory protection, oral analgesia, site checks, and catheter removal/contact instructions.',
    ],
    ['ac', 'infection', 'rebound-2026'],
  ),
  RegionalSection(
    'Evidence & current controversies',
    [
      'Terminology affects comparisons: Studies labeled “adductor canal” can differ in injection level, volume, and accompanying analgesia; compare the actual protocol.',
      'Single injection versus catheter: The atlas summarizes favorable recent catheter trials, but those results reflect selected patients and multimodal co-interventions, not a mandate for every knee procedure.',
      'Motor outcomes: Reduced average motor impairment does not mean absent weakness in every patient; use measured function to guide mobilization.',
    ],
    ['ac', 'ipack-risk'],
  ),
];

const ipackExpandedSections = <RegionalSection>[
  RegionalSection(
    'At a glance',
    [
      'Best fit: Posterior knee analgesia as an adjunct within selected knee-surgery pathways.',
      'Coverage gap: iPACK does not replace anterior/medial coverage, periarticular analgesia, or the primary surgical anesthetic.',
      'Major trade-off: The target is close to popliteal vessels and tibial/common peroneal pathways; unintended spread can cause weakness or foot drop.',
      'Recovery priority: Check ankle/foot motor function and quadriceps strength before mobilization.',
    ],
    ['ipack', 'ipack-risk'],
  ),
  RegionalSection(
    'Selection & coverage',
    [
      'Clinical role: Consider iPACK when posterior knee pain is inadequately addressed by the planned anterior/medial modality.',
      'Coordinate with the surgeon: Review periarticular infiltration and the entire analgesic pathway to avoid unnecessary duplicate local-anesthetic exposure.',
      'Analgesia rather than full anesthesia: Sensory articular targeting does not establish reliable complete knee surgical coverage.',
      'Baseline motor examination: Document preexisting peroneal/tibial dysfunction and planned postoperative nerve assessment before placement.',
    ],
    ['ipack', 'ipack-risk', 'nerve'],
  ),
  RegionalSection(
    'Anatomy & ultrasound orientation',
    [
      'Target interval: Identify the distal femur/posterior capsule and popliteal artery; the intended spread lies between the artery and posterior knee structures.',
      'Vessels: Identify the popliteal vein and vascular branches as well as the artery; use Doppler and avoid assuming the displayed artery is the only vessel at risk.',
      'Level matters: Proximal and distal iPACK approaches differ in relationships and distribution. Follow the landmarks of the chosen trained technique, not a fixed skin distance.',
      'Motor nerves: The goal is articular-branch analgesia without bathing the major tibial/common peroneal motor pathways; ultrasound appearance does not guarantee selective spread.',
    ],
    ['ipack', 'ipack-risk'],
  ),
  RegionalSection(
    'Equipment & positioning',
    [
      'Positioning goal: Support the leg so the posterior/distal femoral anatomy and vessels can be visualized without painful or unstable knee manipulation.',
      'Probe selection: Select frequency and depth for habitus and the chosen approach, preserving the artery-to-femur view.',
      'Needle path: Plan a controlled in-plane trajectory that avoids vessels and allows observation of the entire target interval.',
      'Preparation: Confirm side, consent, baseline neurologic status, sterile setup, monitoring/IV access, and LAST rescue readiness.',
    ],
    ['ipack', 'ipack-risk', 'infection', 'last', 'nerve'],
  ),
  RegionalSection(
    'Technique & injection safeguards',
    [
      'Establish a clear plane: Identify artery, bone/capsule, and the intended distribution before advancing the needle.',
      'Incremental injection: Aspirate and confirm small-volume spread under direct vision, continuing only while the tip and vessels remain clearly identified.',
      'Avoid indiscriminate posterior spread: Do not redirect toward a major motor nerve to chase pain relief; excessive or misplaced spread can defeat the motor-sparing goal.',
      'Stop and reassess: Pain, resistance, absent visible spread, or uncertain vessel/needle relationship should stop injection.',
      'Document the approach: Record level, side, agent/concentration, total dose, and any observed motor change for the recovery team.',
    ],
    ['ipack', 'ipack-risk', 'nerve'],
  ),
  RegionalSection(
    'Local anesthetics & dose context',
    [
      'Published context: NYSORA describes 15–20 mL in its technique discussion, while individual trials use different volumes and concentrations. These are not interchangeable default orders.',
      'Account for the bundle: Add the exposure from adductor canal/femoral block, surgeon infiltration, skin infiltration, and any infusion.',
      'Selective-spread goal: More volume is not automatically better; reassess the target rather than escalating blindly when posterior pain persists.',
      'Formulation restrictions: Do not borrow EXPAREL dosing approval from adductor canal or popliteal sciatic use and apply it to iPACK.',
    ],
    ['ipack', 'ipack-risk', 'exparel'],
  ),
  RegionalSection(
    'Block assessment & incomplete coverage',
    [
      'Pain assessment: Compare posterior pain with anterior/medial pain and assess function within surgical restrictions.',
      'Motor examination: Evaluate dorsiflexion, plantarflexion, and quadriceps function, accounting for residual neuraxial or other block effects.',
      'Persistent posterior pain: Consider incorrect distribution, another pain generator, or inadequate overall multimodal analgesia before repeating an injection.',
      'Communicate uncertainty: A low pain score does not confirm selective articular blockade or exclude a developing motor effect.',
    ],
    ['ipack-risk', 'ipack', 'nerve'],
  ),
  RegionalSection(
    'Nonzero motor risk',
    [
      'Foot drop can occur: In the cited 60-patient TKA study, temporary foot drop occurred in 2 of 30 patients receiving iPACK plus ACB. That small-study finding is not a universal incidence estimate.',
      'Do not assume the cause: New foot drop after knee surgery also requires consideration of surgical, positioning, compressive, or vascular factors.',
      'Escalate concerning deficits: Severe, progressive, or unexpected dysfunction warrants prompt evaluation rather than reassurance based on the phrase “motor-sparing.”',
      'Other urgent concerns: Assess suspected vascular injury or expanding hematoma; stop local-anesthetic delivery and activate the LAST pathway for systemic toxicity.',
    ],
    ['ipack-risk', 'nerve', 'last'],
  ),
  RegionalSection(
    'Recovery & follow-up',
    [
      'Mobility: Provide assistance until actual strength and sensation support the planned activity; a motor-sparing intention is not clearance for independent walking.',
      'Analgesic transition: Explain the expected pain transition and prescribed multimodal medications before the block resolves.',
      'Catheter boundary: This reference does not establish a routine continuous-iPACK catheter protocol or a standard infusion rate.',
      'Handoff: Document technique, cumulative dose, motor findings, residual coverage gaps, and the contact pathway for worsening pain or neurologic symptoms.',
    ],
    ['ipack-risk', 'ipack', 'rebound-2026'],
  ),
  RegionalSection(
    'Evidence & current controversies',
    [
      'Procedure specificity: Evidence includes selected TKA and ACL-reconstruction pathways with different comparator blocks and co-analgesia. Do not transfer all outcomes across operations.',
      'Comparator matters: Motor benefit versus a femoral-plus-sciatic strategy does not establish superiority over every periarticular-infiltration pathway.',
      'Unresolved details: Optimal level, volume, concentration, and incremental benefit with modern multimodal analgesia remain protocol-dependent questions.',
    ],
    ['ipack', 'ipack-risk'],
  ),
];

const poplitealExpandedSections = <RegionalSection>[
  RegionalSection(
    'At a glance',
    [
      'Best fit: Foot, ankle, and Achilles procedures requiring tibial and common peroneal distribution coverage.',
      'Coverage gap: The medial leg/foot supplied by the saphenous nerve remains outside sciatic coverage.',
      'Major trade-off: Foot and ankle motor block can impair safe ambulation even when hamstring function is spared.',
      'Recovery priority: Protect the insensate foot, follow weight-bearing restrictions, and plan rebound-pain or catheter follow-up.',
    ],
    ['ps', 'ac'],
  ),
  RegionalSection(
    'Selection & coverage',
    [
      'Match the operation: Include medial incision, ankle, and tourniquet requirements rather than assuming all below-knee pain is sciatic territory.',
      'Consider supplementation: A saphenous approach may be needed for medial ankle/foot coverage; reconcile both injections in the dose plan.',
      'Patient factors: Document baseline peroneal/tibial deficits, neuropathy, vascular compromise, and positioning tolerance.',
      'Safety review: Obtain consent, confirm side, review puncture-site infection, allergy and antithrombotics, and establish rescue analgesia/anesthesia.',
    ],
    ['ps', 'ac', 'nerve', 'asra'],
  ),
  RegionalSection(
    'Anatomy & ultrasound orientation',
    [
      'Identify both divisions: Trace tibial and common peroneal nerves proximally to understand their relationship and variable bifurcation level.',
      'Vascular landmarks: At the popliteal region the artery and vein are deep to the tibial nerve; avoid treating a compressible vein as absent.',
      'Paraneural versus intraneural: The common sheath around the divisions is distinct from the individual nerve epineurium; appropriate spread does not require entering neural tissue.',
      'Scan dynamically: Optimize angle, depth and focus and observe spread around both divisions rather than assuming a single image proves complete distribution.',
      'Image reference: The atlas includes labeled views and approach illustrations, accessible online through the source button.',
    ],
    ['ps', 'nerve'],
  ),
  RegionalSection(
    'Equipment & positioning',
    [
      'Options: Prone, lateral, or supported supine/lateral-approach positioning can be used according to patient needs and operator training.',
      'Stability: Support the knee/ankle so the limb remains comfortable and the imaging plane is stable; avoid pressure on an injured foot.',
      'Probe and needle: A linear probe is often suitable; select needle length and a controlled trajectory from measured anatomy.',
      'Readiness: Use sterile probe cover/gel, skin antisepsis, IV access and monitoring, with airway and LAST support available.',
    ],
    ['ps', 'infection', 'last'],
  ),
  RegionalSection(
    'Technique & injection safeguards',
    [
      'Define the chosen target: Use the relationship of the two sciatic divisions and their sheath to guide the approach, not a fixed distance above the crease.',
      'Initial confirmation: Aspirate and observe a small aliquot before continuing; assess spread around both divisions and along the plane.',
      'Avoid fascicular injection: Do not seek nerve swelling or force separation within a nerve. Pain, resistance, or loss of tip visibility requires stopping.',
      'Incomplete spread: Reassess anatomy and target plane before redirecting; repeated needle passes carry their own risk.',
      'Documentation: Record the technique, agent, concentration, volume and total milligrams, plus baseline and evolving motor/sensory findings.',
    ],
    ['ps', 'nerve'],
  ),
  RegionalSection(
    'Local anesthetics & dose context',
    [
      'Atlas context: A conventional adult technique is described with 15–20 mL, but volume alone does not define a safe dose or the expected duration.',
      'Combined exposure: Include saphenous supplementation, infiltration, surgeon injections, and any continuous infusion.',
      'Liposomal label: EXPAREL has a labeled adult sciatic block indication in the popliteal fossa at 133 mg. Follow that product’s complete compatibility and subsequent-local-anesthetic restrictions.',
      'Motor duration: Longer analgesia can also prolong foot/ankle weakness. Do not choose an extended-duration strategy without a mobility and follow-up plan.',
    ],
    ['ps', 'exparel'],
  ),
  RegionalSection(
    'Block assessment & incomplete coverage',
    [
      'Assess both divisions: Examine the clinically relevant tibial and common peroneal sensory and motor effects, within surgical restrictions.',
      'Medial gap: Preserved medial ankle/foot sensation may be a saphenous gap rather than sciatic failure.',
      'Partial sciatic effect: Consider incomplete distribution to one division or insufficient onset before supplementing.',
      'Rescue: Localize the gap, review total drug exposure, and coordinate with the overall anesthetic plan; do not automatically repeat the full injection.',
    ],
    ['ps', 'ac', 'nerve'],
  ),
  RegionalSection(
    'Complications & urgent escalation',
    [
      'Falls or injury: Numbness and weakness can impair balance and protective sensation; enforce assistance and prescribed weight-bearing restrictions.',
      'Severe breakthrough pain: Assess the surgical limb and clinical context rather than assuming every pain increase is normal block resolution.',
      'Neurologic deficit: Progressive or significant dysfunction needs evaluation for compression, surgical or positioning injury, vascular problems, and block-related causes.',
      'Vascular injury/LAST: Evaluate swelling or systemic symptoms promptly; stop local-anesthetic delivery and use the LAST pathway when indicated.',
    ],
    ['ps', 'nerve', 'last'],
  ),
  RegionalSection(
    'Catheter management & recovery',
    [
      'Confirm function: Verify distribution through the catheter and secure it to reduce traction or displacement with movement.',
      'Prescription: Specify concentration, basal/bolus settings, limits, duration, monitoring, and the service responsible for changes.',
      'Troubleshooting: Check leakage, disconnection, pump function, migration, and the location of pain before delivering rescue boluses.',
      'Discharge: Provide limb protection, analgesic-transition, catheter/removal instructions, and a reliable contact pathway; reassess persistent or worsening deficits.',
    ],
    ['ps', 'infection', 'rebound-2026', 'nerve'],
  ),
  RegionalSection(
    'Evidence & current controversies',
    [
      'Formulation and adjuvant studies: The atlas summarizes trials showing prolonged analgesia with some strategies, but these have specific operations, comparators, and co-interventions.',
      'Outcome selection: Analgesic duration, motor recovery, opioid use, falls risk, and unplanned care are different outcomes; one favorable endpoint does not establish universal superiority.',
      'Catheter versus single injection: Longer delivery must be weighed against follow-up requirements, migration, infection, and extended motor impairment.',
    ],
    ['ps', 'exparel', 'infection', 'rebound-2026'],
  ),
];

const tapExpandedSections = <RegionalSection>[
  RegionalSection(
    'At a glance',
    [
      'Best fit: Somatic abdominal-wall analgesia as part of a procedure-specific multimodal plan.',
      'Coverage gap: TAP does not reliably treat visceral pain or replace the primary surgical anesthetic.',
      'Major trade-off: Coverage depends on approach and spread; bilateral injections can create substantial cumulative local-anesthetic exposure.',
      'Recovery priority: Assess incision pain separately from deeper abdominal pain and maintain a rescue plan.',
    ],
    ['tap'],
  ),
  RegionalSection(
    'Selection & coverage',
    [
      'Incision match: Choose subcostal, lateral, posterior, or another trained approach according to the location of the abdominal-wall incision.',
      'Avoid a universal dermatome claim: A lateral injection should not be assumed to cover an upper abdominal incision or reliably reach every L1 contribution.',
      'Multimodal role: Include the surgical approach, visceral-pain plan, neuraxial analgesia if used, and surgeon infiltration when judging added value.',
      'Patient review: Assess anatomy, prior surgery, infection, allergy and hemostasis, and document the entire unilateral/bilateral drug plan.',
    ],
    ['tap', 'asra', 'infection'],
  ),
  RegionalSection(
    'Anatomy & ultrasound orientation',
    [
      'Lateral wall layers: Identify external oblique, internal oblique, and transversus abdominis, with the intended plane between internal oblique and transversus.',
      'Deep boundary: Clearly identify transversus, transversalis fascia/peritoneal region, and underlying abdominal contents before advancing.',
      'Approach variation: Subcostal and posterior anatomy differs from the lateral wall; follow the appropriate plane for the selected technique.',
      'Structures at risk: Avoid liver, spleen, bowel/peritoneum and vessels; depth and organ position vary with habitus and scan location.',
      'Spread confirmation: Watch opening of the correct fascial plane rather than accepting muscle swelling as an adequate endpoint.',
    ],
    ['tap'],
  ),
  RegionalSection(
    'Equipment & positioning',
    [
      'Position: Support the patient to expose the selected abdominal-wall region; coordinate positioning with surgical restrictions and comfort.',
      'Probe: A linear probe may show the muscle layers well; a lower-frequency probe may be needed for a deeper target.',
      'Needle: Choose an in-plane path that keeps the tip above the peritoneal/visceral boundary and allows the intended fascial target to remain visible.',
      'Preparation: Use sterile technique, appropriate monitoring and IV access, and ready access to airway/resuscitation and LAST treatment.',
    ],
    ['tap', 'infection', 'last'],
  ),
  RegionalSection(
    'Technique & injection safeguards',
    [
      'Verify all layers: Identify the target muscle interface before puncture and reconfirm when advancing the needle.',
      'Observed aliquot: Aspirate and confirm separation in the intended plane with a small amount before continuing incrementally.',
      'Wrong-plane spread: Intramuscular swelling or fluid below the intended deep boundary requires stopping and reassessment, not more volume.',
      'Bilateral planning: Reassess the first-side dose before the second side and include all other local anesthetics administered by the team.',
      'No forceful injection: Pain, high resistance, uncertain tip location, or unexpected spread warrants repositioning or abandoning an unsafe approach.',
    ],
    ['tap', 'nerve', 'last'],
  ),
  RegionalSection(
    'Local anesthetics & dose context',
    [
      'Volume-dependent spread: Fascial-plane coverage often uses larger volumes, but the required volume and achievable field depend on approach and anatomy.',
      'Milligram accounting: Reducing concentration may reduce total dose at a given volume, but neither dilution nor a weight-based cap guarantees freedom from toxicity.',
      'Bilateral total: Count both sides together with infiltration, other blocks, and infusion. Do not treat each side as an independent maximum-dose allowance.',
      'Liposomal boundary: The cited US EXPAREL label does not establish TAP as an approved perineural block indication. Do not transfer an infiltration maximum into a “per side” TAP recipe.',
    ],
    ['tap', 'exparel', 'last'],
  ),
  RegionalSection(
    'Block assessment & incomplete coverage',
    [
      'Separate pain types: Assess abdominal-wall/incisional pain and sensory change; persistent deep visceral pain may lie outside the expected effect.',
      'Check incision location: Inadequate upper or lower coverage may reflect approach mismatch rather than a need for a larger identical injection.',
      'Reassess spread: Review whether local anesthetic actually opened the intended plane and whether both sides were needed or treated.',
      'Rescue thoughtfully: Review the clinical differential and total drug exposure, then use multimodal or alternate analgesia rather than repeated blind plane injections.',
    ],
    ['tap', 'last'],
  ),
  RegionalSection(
    'Complications & urgent escalation',
    [
      'Visceral or vascular injury: New concerning abdominal symptoms, swelling, or bleeding after placement require assessment rather than attribution to routine postoperative pain.',
      'LAST: Large-volume and bilateral exposure warrants vigilance for neurologic or cardiovascular toxicity; stop administration and follow the rescue aid when suspected.',
      'Unexpected weakness: Evaluate unusual lower-limb motor changes and possible spread beyond the intended plane rather than assuming TAP cannot affect mobility.',
      'Persistent or progressive symptoms: Escalate unexplained neurologic or systemic findings and document the procedure and all administered drugs.',
    ],
    ['tap', 'last', 'nerve'],
  ),
  RegionalSection(
    'Catheter management & recovery',
    [
      'Selective catheter use: A fascial-plane catheter needs a defined purpose, complete prescription, securement, and service able to assess its effectiveness.',
      'Function and exposure: Reassess the pain location, spread/function, leakage, and total bilateral infusion dose rather than increasing rate automatically.',
      'Infection review: Examine catheter sites and reassess continuing need; new infection signs require clinical evaluation and early management.',
      'Handoff: Explain expected somatic coverage, the separate visceral-pain plan, oral analgesic transition, and whom to contact for uncontrolled pain or complications.',
    ],
    ['tap', 'infection', 'last'],
  ),
  RegionalSection(
    'Evidence & current controversies',
    [
      'Not one intervention: TAP studies use different approaches, incisions, volumes, and multimodal regimens; results should be interpreted at that level.',
      'Incremental benefit: Added benefit can differ when effective neuraxial analgesia or surgical infiltration is already provided.',
      'TAP versus QL: These target different planes. Proposed broader QL spread is variable and should not be turned into a guarantee of superior visceral analgesia.',
    ],
    ['tap'],
  ),
];

const quadratusLumborumExpandedSections = <RegionalSection>[
  RegionalSection(
    'At a glance',
    [
      'Best fit: Selected abdominal or related perioperative analgesic pathways, with an approach matched to the procedure.',
      'Coverage gap: Lateral, posterior, and anterior/transmuscular QL are not interchangeable and do not guarantee a fixed somatic or visceral field.',
      'Major trade-off: Deeper approaches are close to psoas, lumbar vessels, kidney, and other retroperitoneal structures.',
      'Recovery priority: Assess lower-limb strength, hemodynamics, pain distribution, and cumulative bilateral local-anesthetic exposure.',
    ],
    ['tap'],
  ),
  RegionalSection(
    'Selection & coverage',
    [
      'Specify the approach: Record lateral, posterior, or anterior/transmuscular QL rather than documenting an unspecified “QL block.”',
      'Match the indication: Consider incision location, visceral analgesic needs, other modalities, and whether the evidence applies to the chosen approach and operation.',
      'Deep-block risk: Review bleeding risk and antithrombotic management appropriate to the depth and consequences of bleeding; ultrasound is not a waiver.',
      'Patient factors: Distorted anatomy, prior surgery, organ position, infection, allergy, and the ability to tolerate positioning can alter feasibility.',
    ],
    ['tap', 'asra', 'infection'],
  ),
  RegionalSection(
    'Anatomy & ultrasound orientation',
    [
      'Core structures: Identify quadratus lumborum, psoas, erector spinae, abdominal-wall muscles, and the relevant bony landmarks.',
      'Anterior/transmuscular target: The plane between QL and psoas differs from lateral and posterior fascial targets.',
      'Shamrock orientation: At a lumbar transverse process, the surrounding muscles can provide an orientation pattern; verify each structure rather than relying on the pattern alone.',
      'Kidney and vessels: The kidney can extend low in the flank, and lumbar vessels may cross the planned path. Scan and use Doppler before needle advancement.',
      'Depth and boundaries: Identify the peritoneal/retroperitoneal relationships and avoid treating any deep fascial separation as the correct endpoint.',
    ],
    ['tap'],
  ),
  RegionalSection(
    'Equipment & positioning',
    [
      'Position: Lateral positioning often improves flank access; support the patient and preserve stable anatomy throughout scanning and injection.',
      'Probe choice: A lower-frequency curved probe may be required for deeper structures; resolution must remain sufficient to identify the tip and nearby organs.',
      'Needle selection: Choose length from the actual depth and trajectory, without using a longer needle as a reason to advance beyond a visible target.',
      'Preparation: Use sterile technique, IV access and monitoring, and immediate resuscitation/LAST support; prepare catheter equipment only when a defined pathway exists.',
    ],
    ['tap', 'infection', 'last'],
  ),
  RegionalSection(
    'Technique & injection safeguards',
    [
      'Plan the specific plane: A trained anterior/transmuscular approach cannot be substituted for a lateral/posterior approach without reassessing anatomy and risk.',
      'Tip visibility: Maintain the tip in view, particularly near psoas, kidney, or vascular structures. Stop advancement if visualization is lost.',
      'Confirm spread: Use a small observed aliquot after aspiration to demonstrate the intended fascial separation before continuing.',
      'Avoid force and unexplained spread: High resistance, muscle swelling, pain, or spread outside the intended plane warrants reassessment.',
      'Document precisely: Record the side, named approach, level, agent/concentration, total dose, and the observed response.',
    ],
    ['tap', 'nerve'],
  ),
  RegionalSection(
    'Local anesthetics & dose context',
    [
      'No universal regimen: Approach, incision, patient factors, and concurrent analgesia affect the choice of concentration and volume.',
      'Bilateral exposure: Sum both sides and all other local anesthetic, including surgeon infiltration and catheter delivery.',
      'Do not chase spread with dose: Larger volumes cannot guarantee the desired cephalad or paravertebral distribution and may increase toxicity or unwanted motor effects.',
      'Product boundaries: Do not apply EXPAREL infiltration or other approved nerve-block doses as an established QL regimen.',
    ],
    ['tap', 'exparel', 'last'],
  ),
  RegionalSection(
    'Block assessment & incomplete coverage',
    [
      'Assess the actual field: Evaluate pain and sensory distribution rather than assuming the block spans a fixed list of dermatomes.',
      'Persistent visceral pain: Treat it as a possible coverage limitation or another clinical problem, not automatic proof that more injectate is needed.',
      'Check motor function: Lumbar plexus spread, particularly with deeper approaches, can impair lower-limb strength.',
      'Rescue: Review approach, plane, onset, cumulative dose, and the overall analgesic plan before supplementation.',
    ],
    ['tap', 'nerve'],
  ),
  RegionalSection(
    'Complications & urgent escalation',
    [
      'Organ or vessel injury: Concerning flank/abdominal pain, bleeding, or systemic changes after a deep injection require evaluation.',
      'Unexpected weakness: Assess lumbar plexus spread and other neurologic causes; use assisted mobilization and escalate progressive or severe deficits.',
      'Hemodynamic change: Evaluate unexpected hypotension or extensive block rather than assuming a fascial-plane technique has no systemic effects.',
      'LAST: Stop local-anesthetic delivery and use the rescue pathway for suspected systemic toxicity, including after bilateral injections.',
    ],
    ['tap', 'nerve', 'last'],
  ),
  RegionalSection(
    'Catheter management & recovery',
    [
      'Defined pathway: Continuous QL use should have a complete prescription, monitoring plan, and responsible clinical service rather than a borrowed epidural or ESP rate.',
      'Ongoing assessment: Review pain territory, lower-limb strength, site condition, leakage, infusion exposure, and continuing benefit.',
      'Removal and bleeding: Coordinate catheter decisions with antithrombotic timing and the consequences of deep bleeding.',
      'Discharge: Provide a mobility and analgesic-transition plan and clear instructions for neurologic, infectious, or systemic symptoms.',
    ],
    ['tap', 'asra', 'infection', 'nerve'],
  ),
  RegionalSection(
    'Evidence & current controversies',
    [
      'Variable mechanisms: Proposed paravertebral or other deep spread does not occur uniformly and does not establish reliable epidural-equivalent analgesia.',
      'Approach-specific evidence: Trials labeled “QL” can examine different targets, surgeries, and co-analgesia; do not pool them conceptually into a single guaranteed effect.',
      'Comparative uncertainty: The atlas describes sparse or mixed evidence for several uses. Broader theoretical coverage alone is not proof of better recovery than TAP, infiltration, or neuraxial analgesia.',
    ],
    ['tap'],
  ),
];

const espExpandedSections = <RegionalSection>[
  RegionalSection(
    'At a glance',
    [
      'Best fit: Selected thoracic, chest-wall, or other procedure-specific multimodal analgesic strategies.',
      'Coverage gap: Cranio-caudal plane spread does not guarantee reliable anterior, visceral, or surgical anesthesia.',
      'Major trade-off: The transverse process must be distinguished from rib and lamina; large-volume/bilateral exposure requires dose discipline.',
      'Recovery priority: Assess the actual pain field and watch for unexpected respiratory, neurologic, or systemic effects.',
    ],
    ['esp', 'thoracic-review'],
  ),
  RegionalSection(
    'Selection & coverage',
    [
      'Choose the level for the operation: A T5 description is not a universal technique for every thoracic, abdominal, or lumbar indication.',
      'Analgesic role: Plan additional modalities for uncovered anterior or visceral pain and do not assume ESP can replace the primary anesthetic.',
      'Compare alternatives: Thoracic epidural, paravertebral, other chest-wall blocks, and infiltration have different evidence, coverage, and risk profiles.',
      'Risk review: Obtain consent, document baseline symptoms, review infection/allergy/hemostasis, and decide whether bilateral treatment is necessary.',
    ],
    ['esp', 'thoracic-review', 'asra', 'infection'],
  ),
  RegionalSection(
    'Anatomy & ultrasound orientation',
    [
      'Target plane: Identify erector spinae over the intended transverse process; local anesthetic is placed deep to the muscle and superficial to the bony process.',
      'Medial versus lateral: Laminae can appear as flatter bony surfaces medially, whereas ribs and an intervening pleural line appear farther laterally. Confirm the intended transverse-process view.',
      'Muscle layers: Trapezius and, at upper thoracic levels, rhomboid may overlie erector spinae; the layers change with level.',
      'Pleural awareness: A visible bony surface is not permission to advance without tip control. Maintain awareness of pleura and depth throughout the approach.',
      'Image reference: The source atlas includes scan orientation and spread images; these require internet and are not simulated ultrasound.',
    ],
    ['esp', 'thoracic-review'],
  ),
  RegionalSection(
    'Equipment & positioning',
    [
      'Positioning goal: Select supported sitting, lateral, or prone access as appropriate to the patient and surgical setting, with stable visualization of the intended level.',
      'Probe choice: Use adequate penetration for habitus while preserving muscle, bone, pleura, and needle-tip detail.',
      'Needle approach: Choose an in-plane trajectory that permits clear control as the tip approaches the transverse process.',
      'Preparation: Establish monitoring/IV access, sterile probe cover/gel and field precautions, with airway/resuscitation and LAST supplies available.',
    ],
    ['esp', 'thoracic-review', 'infection', 'last'],
  ),
  RegionalSection(
    'Technique & injection safeguards',
    [
      'Confirm level and target: Distinguish the transverse process from rib or lamina before advancing.',
      'Observed plane opening: After aspiration, a small initial aliquot should lift erector spinae from the transverse process in the intended plane.',
      'Wrong-plane injection: Muscle swelling or poorly visualized spread warrants stopping and reassessment; do not keep injecting solely to reach a target volume.',
      'No guaranteed dermatome count: Visible longitudinal spread does not establish a fixed eight-dermatome field or consistent ventral-ramus/paravertebral effect.',
      'Bilateral discipline: Reconcile cumulative dose after the first side and communicate all other planned local anesthetics.',
    ],
    ['esp', 'thoracic-review', 'nerve'],
  ),
  RegionalSection(
    'Local anesthetics & dose context',
    [
      'Atlas context: The technique page describes 20–30 mL, without establishing one adult formulation or universally safe regimen.',
      'Concentration and dose: Calculate the total milligrams from concentration and volume for each side, then sum all injections and ongoing infusion.',
      'Do not copy a bare rate: A continuous “mL/hour per side” statement is incomplete without the drug, concentration, bolus rules, limits, and patient-specific plan.',
      'Formulation caution: ESP is not one of the adult perineural block indications established in the cited US EXPAREL label.',
    ],
    ['esp', 'exparel', 'last'],
  ),
  RegionalSection(
    'Block assessment & incomplete coverage',
    [
      'Measure clinical effect: Assess the relevant incision/chest-wall pain, breathing-related pain where applicable, and sensory distribution.',
      'Anterior or visceral pain persists: Consider the known variability of spread rather than assuming the injection must have been technically unsuccessful.',
      'Troubleshoot anatomy: Revisit level, bony landmark, and whether injectate was deep to erector spinae rather than intramuscular.',
      'Rescue plan: Use the procedure-specific multimodal pathway or another appropriate technique after reviewing all prior local anesthetic.',
    ],
    ['esp', 'thoracic-review'],
  ),
  RegionalSection(
    'Complications & urgent escalation',
    [
      'Respiratory symptoms: New dyspnea or chest pain requires clinical assessment for pleural injury and other perioperative causes; do not assume a posterior plane block is risk-free.',
      'LAST: Large-volume or bilateral dosing can produce systemic toxicity; stop delivery and follow the rescue aid when suspected.',
      'Unexpected motor or extensive block: Evaluate possible spread beyond the intended plane and other neurologic causes rather than describing all findings as expected.',
      'Infection or bleeding: Progressive site pain, swelling, drainage, fever, or unexplained deficit warrants prompt evaluation.',
    ],
    ['thoracic-review', 'last', 'nerve', 'infection'],
  ),
  RegionalSection(
    'Catheter management & recovery',
    [
      'Select for a defined benefit: Use continuous ESP only with a complete prescription and service capable of assessing analgesic effect and complications.',
      'Confirm function: Evaluate clinical benefit, catheter position/spread when indicated, leakage, connections, and delivery before escalating the infusion.',
      'Reassess daily: Review cumulative dose, site condition, mobility/respiratory status, and ongoing need; a catheter is not evidence that the target pain field is covered.',
      'Transition and follow-up: Give an oral/systemic analgesic plan and instructions for deterioration or infection, with a clear removal/contact pathway.',
    ],
    ['thoracic-review', 'infection', 'last'],
  ),
  RegionalSection(
    'Evidence & current controversies',
    [
      'Mechanism: Paravertebral/ventral-ramus spread is proposed but variable; the atlas does not establish a universally reliable mechanism or coverage map.',
      'Recent synthesis: The December 2025 thoracic-wall review describes procedure-dependent analgesic benefits with heterogeneous techniques, levels, doses, and co-analgesia.',
      'Clinical boundary: Similar pain scores in selected trials do not establish equivalence to epidural or paravertebral techniques for every operation, and long-term outcome evidence remains limited.',
    ],
    ['esp', 'thoracic-review'],
  ),
];

const pengExpandedSections = <RegionalSection>[
  RegionalSection(
    'At a glance',
    [
      'Best fit: Selected anterior hip-capsule analgesia pathways, not complete hip surgical anesthesia.',
      'Coverage gap: Skin incision and posterior/deeper surgical contributions can remain uncovered.',
      'Major trade-off: Motor sparing is not a guarantee; femoral spread can cause quadriceps weakness.',
      'Recovery priority: Assess knee-extension strength and use assisted mobilization until actual function is known.',
    ],
    ['peng'],
  ),
  RegionalSection(
    'Selection & coverage',
    [
      'Analgesic objective: Define whether the aim is fracture-related pain, positioning comfort, or postoperative analgesia within a larger anesthetic plan.',
      'Capsule versus incision: Articular branch targeting does not establish cutaneous coverage for the operative approach.',
      'Alternatives: Femoral, fascia iliaca, other hip blocks, infiltration, and neuraxial approaches have different coverage and motor implications.',
      'Baseline assessment: Record neurologic function, mobility, residual neuraxial effects, infection/allergy risk, and antithrombotic exposure.',
    ],
    ['peng', 'fn', 'asra', 'nerve'],
  ),
  RegionalSection(
    'Anatomy & ultrasound orientation',
    [
      'Orientation: Identify the anterior inferior iliac spine, iliopubic/iliopectineal region, iliopsoas tendon and muscle, and adjacent femoral vessels.',
      'Intended target: The plane deep to the iliopsoas tendon near the pelvic bony landmark is used to reach articular branches supplying the anterior hip capsule.',
      'Bursal relationship: The iliopectineal bursa and nearby fascia iliaca compartment matter because unintended spread can reach the femoral nerve proper.',
      'Do not confuse PENG with iliopsoas plane block: The proposed target relative to the tendon and capsule differs, and their sensory coverage and evidence are not identical.',
      'Image interpretation: Trace the tendon and bony landmarks and survey vessels rather than relying on one memorized probe angle.',
    ],
    ['peng'],
  ),
  RegionalSection(
    'Equipment & positioning',
    [
      'Positioning goal: Support the patient supine when feasible, minimizing painful hip movement and preserving access to the anterior pelvic/groin anatomy.',
      'Probe selection: Choose sufficient penetration to resolve tendon, bone, target plane, and vessels in the individual patient.',
      'Needle path: Plan a visible in-plane route away from femoral vessels and other identified structures; do not advance toward a poorly defined deep target.',
      'Preparation: Confirm consent/side and baseline function, establish sterile technique and monitoring/IV access, and keep LAST rescue capability available.',
    ],
    ['peng', 'infection', 'last', 'nerve'],
  ),
  RegionalSection(
    'Technique & injection safeguards',
    [
      'Confirm the target: Define tendon, bony landmark, and intended plane before inserting or advancing the needle.',
      'Observed delivery: Use aspiration and a small observed aliquot to confirm spread before continuing incrementally.',
      'Avoid assuming selective spread: Injection beneath or near the tendon can enter or communicate with other planes; a visually successful injection is not proof that motor nerves are spared.',
      'Stop signals: Pain, resistance, absent visible spread, or uncertainty about vessels or tip location requires reassessment.',
      'Document the details: Record approach, agent/concentration, volume and total milligrams, observed distribution, and motor findings.',
    ],
    ['peng', 'nerve'],
  ),
  RegionalSection(
    'Local anesthetics & dose context',
    [
      'Study-volume boundary: The PENG review reports varying volumes and suggests that volume and target location may affect motor spread. These reports do not establish one optimal regimen.',
      'Do not pursue “more is better”: Larger spread may reach additional articular branches but may also reach the femoral nerve and increase weakness.',
      'Cumulative exposure: Include skin infiltration, other hip blocks, surgeon infiltration, and any proposed catheter delivery.',
      'Formulation boundary: The cited US EXPAREL label does not establish PENG as an approved perineural block indication.',
    ],
    ['peng', 'exparel', 'last'],
  ),
  RegionalSection(
    'Block assessment & incomplete coverage',
    [
      'Assess the goal: Compare pain during the clinically relevant permitted movement or positioning with the preblock state, without forcing the injured hip.',
      'Check knee extension: Evaluate quadriceps strength before standing; distinguish residual spinal effects and other contributors from the peripheral block.',
      'Residual incision pain: Consider cutaneous or posterior coverage gaps rather than automatically repeating PENG.',
      'Rescue: Reassess the pain source, target/spread, onset, and cumulative drug exposure before choosing supplementation or another modality.',
    ],
    ['peng', 'nerve'],
  ),
  RegionalSection(
    'Nonzero motor risk',
    [
      'Quadriceps weakness: Clinical reports and trials document weakness after PENG; the phrase “motor-sparing” is not a guarantee for an individual patient.',
      'Proposed mechanism: Spread through bursal or adjacent fascial pathways may reach femoral motor fibers; anatomy and injectate distribution both matter.',
      'Do not infer universal incidence: Small studies use different doses, timing, and strength assessments, sometimes confounded by residual neuraxial anesthesia.',
      'Escalation: Progressive, severe, or persistent weakness requires clinical evaluation for block-related, surgical, compressive, vascular, and other causes. Suspected LAST requires the rescue pathway.',
    ],
    ['peng', 'nerve', 'last'],
  ),
  RegionalSection(
    'Recovery & catheter considerations',
    [
      'Mobility: Use assistance until strength and surgical restrictions permit safe activity; analgesia does not itself establish safe weight-bearing.',
      'Pain transition: Maintain a multimodal plan for uncovered pain and block resolution, with explicit patient/caregiver instructions.',
      'Catheter boundary: Continuous PENG has limited and heterogeneous evidence; this reference does not provide a routine catheter-placement or infusion prescription.',
      'Follow-up: Record motor/sensory changes, analgesic response, and a contact pathway for unexpected weakness, uncontrolled pain, infection, or systemic symptoms.',
    ],
    ['peng', 'nerve', 'infection', 'rebound-2026'],
  ),
  RegionalSection(
    'Evidence & current controversies',
    [
      'Foundational review | 2022: The linked scoping review examines PENG and iliopsoas-plane anatomy and quadriceps weakness, including cadaver, volunteer, and clinical evidence.',
      'Coverage trade-off: More selective iliopsoas-plane targeting may have different articular coverage; it should not be treated as a proven interchangeable replacement for PENG.',
      'Evidence limits: Variable methods, small studies, residual spinal confounding, and incomplete head-to-head comparisons limit broad claims of superior analgesia or assured motor preservation.',
    ],
    ['peng'],
  ),
];

const epiduralExpandedSections = <RegionalSection>[
  RegionalSection(
    'At a glance',
    [
      'Best fit: Titrated segmental anesthesia or analgesia, with the insertion level and regimen matched to surgery or labor.',
      'Coverage gap: Unilateral, patchy, or sacral-sparing blocks can occur; catheter presence does not prove adequate anesthesia.',
      'Major trade-off: Sympathetic block, catheter migration, neuraxial bleeding/infection, and cumulative local-anesthetic or opioid effects require active surveillance.',
      'Recovery priority: Reassess sensory level, motor function, hemodynamics, respiration, catheter site, and antithrombotic timing through removal.',
    ],
    ['epidural', 'asra', 'infection'],
  ),
  RegionalSection(
    'Selection & coverage',
    [
      'Define the goal: Surgical anesthesia, postoperative analgesia, and labor analgesia require different targets and regimens; do not transfer one protocol unchanged to another setting.',
      'Choose insertion level: Match the expected dermatomal field and catheter spread to incision, deep/visceral pain, and surgical position.',
      'Do not proceed without risk review: Consent, puncture-site infection, coagulation/antithrombotics, circulatory status, relevant intracranial pathology, and the ability to monitor and rescue require assessment.',
      'Baseline documentation: Record neurologic findings and identify spinal disease, prior surgery, or anatomy that may complicate access or interpretation of new symptoms.',
      'Hemodynamic reserve: Significant outflow obstruction, hypovolemia, or other limited reserve requires individualized planning rather than assuming titration eliminates sympathetic-block risk.',
    ],
    ['epidural', 'asra', 'nerve'],
  ),
  RegionalSection(
    'Anatomy & ultrasound orientation',
    [
      'Epidural is not intrathecal: The target lies outside dura; spinal anesthesia deliberately enters the subarachnoid space. Drug doses and catheter safety rules are not interchangeable.',
      'Landmarks are estimates: Surface palpation can misidentify level and midline; consider preprocedural ultrasound in difficult anatomy.',
      'Ultrasound purpose: Identify level, midline, interlaminar window, and estimated depth; an estimated depth is not permission to advance without appropriate tissue/clinical feedback.',
      'Ligamentum flavum variation: Midline gaps and differences by spinal level can affect loss-of-resistance interpretation.',
      'Vascular anatomy: The epidural venous plexus creates a risk of vascular entry; negative aspiration does not guarantee the catheter is extravascular.',
    ],
    ['epidural', 'spinal'],
  ),
  RegionalSection(
    'Equipment & positioning',
    [
      'Position: Sitting or lateral positioning should optimize access while maintaining comfort, monitoring, and hemodynamic safety.',
      'Sterile field: Use hand hygiene, appropriate mask/hat/gloves, skin antisepsis allowed to dry, sterile drapes, and catheter handling consistent with current infection guidance.',
      'Equipment: Prepare the intended Tuohy needle, loss-of-resistance system, catheter/connector, labeled syringes, securement and dressing materials.',
      'Medication segregation: Verify exact drug, concentration, preservative/formulation suitability, and neuraxial route; avoid wrong-route drug or connector errors.',
      'Rescue readiness: Establish IV access and monitoring, with airway equipment, vasopressors/resuscitation support, and LAST treatment immediately available.',
    ],
    ['epidural', 'infection', 'last'],
  ),
  RegionalSection(
    'Technique & catheter confirmation',
    [
      'Training boundary: Midline and paramedian approaches require level-specific supervised expertise; this reference is not a substitute for procedural training.',
      'Loss of resistance: Interpret it within the anatomy and chosen technique; a sensation alone does not establish correct space or exclude dural puncture.',
      'Catheter advancement: Avoid force. Resistance, severe paresthesia, blood, or CSF requires reassessment rather than repeated blind manipulation.',
      'Initial confirmation: Aspirate and use the institution’s test-dose/initial-dose strategy, followed by incremental dosing and close observation.',
      'Test-dose limitations: Physiologic responses can be altered by labor, medications, age, sedation, and clinical context. A negative result is not proof against intravascular or intrathecal location.',
      'Recheck before subsequent boluses: A catheter can migrate after initially functioning; maintain dose fractionation, observation, and readiness to treat unexpected spread.',
    ],
    ['epidural', 'nerve'],
  ),
  RegionalSection(
    'Medications & route safety',
    [
      'Choose by purpose: Surgical anesthesia and postoperative or labor analgesia use different concentrations, volumes, and combinations; follow the relevant institutional protocol.',
      'Incremental dosing: Titrate to the intended bilateral level while observing hemodynamics, motor effects, and symptoms of intravascular or intrathecal delivery.',
      'Local anesthetic plus opioid: Account for both sympathetic/motor effects and opioid-related sedation, pruritus, nausea, urinary retention, and respiratory depression.',
      'Complete prescription: Specify agent/formulation, concentration, basal rate or programmed bolus, patient-controlled settings, limits, monitoring, and who can modify the regimen.',
      'Label restrictions: Do not use liposomal bupivacaine as an epidural substitute; the cited EXPAREL label does not recommend epidural or intrathecal administration.',
    ],
    ['epidural', 'exparel'],
  ),
  RegionalSection(
    'Block assessment & troubleshooting',
    [
      'Assess bilaterally: Record sensory level, motor function, pain at rest and with relevant activity, hemodynamics, and respiratory/sedation status.',
      'Unilateral or patchy effect: Reassess catheter marking, patient position, distribution, dose history, and potential migration. A repeatedly unreliable catheter may require replacement rather than serial rescue doses.',
      'Sacral sparing: Especially with lumbar dosing or labor progression, assess whether the needed sacral territory is reached instead of interpreting all residual pain as anxiety.',
      'Unexpectedly high or atypical block: Consider intrathecal, subdural, or other unintended delivery and stop further dosing while evaluating.',
      'Failed surgical conversion: Do not proceed solely because a catheter previously provided analgesia. Confirm an adequate surgical block and have an alternate anesthetic plan.',
    ],
    ['epidural'],
  ),
  RegionalSection(
    'Complications & urgent escalation',
    [
      'High or total block: Rapid ascending weakness, dyspnea, hypotension/bradycardia, impaired consciousness, or apnea requires immediate assistance and airway/circulatory support.',
      'Suspected intravascular toxicity: Stop dosing and follow the ASRA LAST rescue aid for concerning neurologic or cardiovascular symptoms.',
      'Possible hematoma or abscess: New/progressive weakness, sensory loss, severe back pain, sphincter dysfunction, or fever warrants urgent evaluation and appropriate imaging/consultation; do not wait for a complete symptom triad.',
      'Dural puncture and headache: Arrange assessment and follow-up; an atypical, severe, or neurologically associated headache needs a broader differential, not automatic labeling as routine PDPH.',
      'Opioid-related deterioration: Excess sedation or respiratory compromise requires immediate clinical assessment and treatment according to the drug-specific neuraxial opioid pathway.',
    ],
    ['epidural', 'nerve', 'infection', 'last'],
  ),
  RegionalSection(
    'Ongoing care, removal & recovery',
    [
      'Regular review: Assess analgesic benefit, sensory/motor trend, blood pressure, respiratory/sedation status, site condition, pump function, and continuing indication.',
      'Catheter removal is a procedure: Review the actual antithrombotic drug/dose, renal function, last administration, and planned restart interval using the current guideline.',
      'Do not overlook timing changes: New prophylaxis, therapeutic anticoagulation, renal deterioration, or traumatic placement can change a previously acceptable plan.',
      'Mobility and bladder care: Coordinate safe mobilization, motor recovery, and urinary-retention surveillance with the care team.',
      'Handoff and follow-up: Record removal time, catheter integrity, neurologic status, medication transition, and instructions for delayed neurologic, infectious, or headache symptoms.',
    ],
    ['epidural', 'asra', 'infection', 'nerve'],
  ),
  RegionalSection(
    'Evidence & current controversies',
    [
      'Risk reduction | ASRA fifth edition: Antithrombotic decisions distinguish drug, dose, renal function, placement, removal, and restart; a generic hold-time table is insufficient.',
      'Infection | ASRA 2025 guideline: Sterile technique, catheter duration, risk factors, and early response to infection signs are separate components of prevention.',
      'Epidural versus alternatives: Comparative benefit depends on operation, patient risk, regimen, and recovery pathway. Faster titration or longer delivery does not establish universal superiority to spinal, peripheral, or systemic approaches.',
      'Ultrasound and test dosing: Helpful tools reduce uncertainty but do not remove the need for incremental dosing, repeated assessment, and rescue capability.',
    ],
    ['asra', 'infection', 'epidural'],
  ),
];

const spinalExpandedSections = <RegionalSection>[
  RegionalSection(
    'At a glance',
    [
      'Best fit: Selected lower abdominal, pelvic/perineal, obstetric, and lower-limb operations with a level and duration matched to surgery.',
      'Coverage gap: A technically successful puncture does not guarantee adequate bilateral height, density, or duration.',
      'Major trade-off: Rapid sympathetic and motor blockade can cause hypotension, bradycardia, or excessive cephalad spread.',
      'Recovery priority: Monitor hemodynamics and block regression, protect insensate limbs, and assess bladder function and delayed neurologic/headache symptoms.',
    ],
    ['spinal'],
  ),
  RegionalSection(
    'Selection & coverage',
    [
      'Define the required block: Determine the incision, traction/visceral requirements, position, and likely duration rather than relying on a single generic dermatomal target.',
      'Risk review: Consent, puncture-site infection, coagulation/antithrombotics, volume status, relevant intracranial pathology, and capacity for rescue must be assessed.',
      'Limited reserve: Severe hemodynamic vulnerability or fixed outflow obstruction requires individualized risk–benefit planning; spinal is not automatically prohibited or safe based on a diagnostic label alone.',
      'Baseline neurologic findings: Document preexisting deficits and spinal disease or prior surgery that may affect access, spread, or later assessment.',
      'Backup plan: Anticipate inadequate duration, failed or partial block, and conversion to another anesthetic technique.',
    ],
    ['spinal', 'asra', 'nerve'],
  ),
  RegionalSection(
    'Anatomy & ultrasound orientation',
    [
      'Target: Local anesthetic is delivered into the subarachnoid space containing CSF, not the epidural space.',
      'Conus variation: The adult conus level varies. Conventional lumbar placement is commonly at L3–L4 or L4–L5; do not assume surface landmarks identify a safe level perfectly.',
      'Midline structures: Recognize the ligamentous path and the difference between midline and paramedian access; altered anatomy may change the expected tactile sequence.',
      'Ultrasound assistance: Identify sacrum, lumbar levels, midline, interlaminar spaces, and estimated depth when needed; avoid mislabeling the lumbosacral junction.',
      'Depth estimate is not confirmation: CSF return and the complete clinical context remain essential; a “pop” or expected depth alone does not prove intrathecal position.',
    ],
    ['spinal'],
  ),
  RegionalSection(
    'Equipment & positioning',
    [
      'Position: Sitting or lateral positioning should optimize access without sacrificing comfort, airway observation, or circulatory stability.',
      'Sterile preparation: Use appropriate mask, sterile gloves/drapes, skin antisepsis allowed to dry, and careful handling of needle and medication.',
      'Needle system: Select the intended spinal needle and introducer, with equipment for difficult access available rather than repeatedly forcing an unsuitable approach.',
      'Drug verification: Independently verify agent, concentration, baricity, dose, preservative/formulation suitability, and intended intrathecal route.',
      'Readiness: Establish IV access, ECG, blood-pressure and oxygenation monitoring, with immediate airway, circulatory, and resuscitation support.',
    ],
    ['spinal', 'infection'],
  ),
  RegionalSection(
    'Technique & spread safeguards',
    [
      'Confirm access: Use the chosen trained approach and confirm CSF before dosing. Reassess absent or equivocal return rather than assuming the tip is in the correct space.',
      'Avoid neural injury: Severe paresthesia or pain with advancement/injection warrants stopping and reassessment; do not deliberately seek nerve contact.',
      'Control the administered dose: Verify the full syringe contents and route, and account for any uncertainty about how much actually reached CSF.',
      'Position and baricity: Patient position and solution density can influence distribution; coordinate positioning with the intended block and operation.',
      'Monitor development: Assess bilateral sensory and motor effect and hemodynamics as the block evolves, before proceeding with surgery.',
    ],
    ['spinal', 'nerve'],
  ),
  RegionalSection(
    'Medications & dose context',
    [
      'No universal recipe: Agent, dose, baricity, adjuvants, patient factors, and procedural needs determine the plan; a fixed number of mL is not a complete prescription.',
      'Baricity distinction: Hyperbaric, isobaric, and hypobaric preparations differ in position-dependent behavior. Verify the actual preparation rather than inferring from the drug name.',
      'Adjuvants: Check the exact formulation, route suitability, evidence and institutional policy. Neuraxial opioids require drug-appropriate postoperative respiratory/sedation monitoring.',
      'Wrong-route prevention: Epidural doses and solutions must not be treated as spinal equivalents. EXPAREL is not recommended for intrathecal administration in the cited label.',
      'Duration planning: An operation may outlast the block despite adequate initial height; establish a rescue/conversion strategy before that occurs.',
    ],
    ['spinal', 'epidural', 'exparel'],
  ),
  RegionalSection(
    'Block assessment & failed spinal',
    [
      'Test before incision: Confirm bilateral level, density, and motor effects appropriate to the actual operation; comfort at rest does not prove surgical anesthesia.',
      'Allow appropriate onset: Distinguish slow development from a truly absent block while maintaining observation and a time-appropriate alternate plan.',
      'Partial or uncertain injection: Review CSF confirmation, delivered amount, drug, position, and distribution. Do not automatically repeat a full spinal dose.',
      'Repeat-block risk: Additional intrathecal dosing after an uncertain or partial effect can produce excessive spread or toxicity. A senior reassessment and individualized alternative may be safer.',
      'Late breakthrough pain: Consider inadequate duration or coverage and respond with an appropriate anesthetic plan rather than asking the patient to tolerate surgical pain.',
    ],
    ['spinal'],
  ),
  RegionalSection(
    'Complications & urgent escalation',
    [
      'Hypotension or bradycardia: Assess and treat promptly; nausea or sudden deterioration can accompany reduced perfusion. Do not wait for loss of consciousness.',
      'High/total spinal: Ascending weakness, difficulty breathing, profound hypotension, bradycardia, impaired consciousness, or apnea requires immediate help and airway/circulatory support.',
      'New neurologic deficit: Progressive or severe weakness/sensory loss, sphincter dysfunction, or severe back pain requires urgent assessment for compression and other causes.',
      'Infection: Fever or concerning back/neurologic symptoms requires evaluation; absence of a complete abscess/meningitis symptom pattern is not reassuring.',
      'Headache: Evaluate post-dural-puncture symptoms and provide follow-up; atypical headache or associated neurologic findings needs a broader differential.',
    ],
    ['spinal', 'nerve', 'infection'],
  ),
  RegionalSection(
    'Recovery & catheter distinction',
    [
      'Regression: Monitor sensory/motor recovery and hemodynamic stability before mobilization; protect numb limbs and use assistance.',
      'Bladder and symptoms: Assess urinary retention and provide clear instructions for headache, progressive weakness, severe back pain, fever, or new bowel/bladder dysfunction.',
      'Single injection is the scope: This reference primarily addresses conventional single-shot lumbar spinal anesthesia.',
      'Continuous spinal is separate: An intrathecal catheter is not an epidural catheter; it requires dedicated labeling, dosing, monitoring, and trained institutional protocols.',
      'Discharge/handoff: Document the drug and dose, level, recovery status, complications, and follow-up contact rather than ending surveillance when surgery finishes.',
    ],
    ['spinal', 'nerve', 'infection'],
  ),
  RegionalSection(
    'Evidence & current controversies',
    [
      'Predicting height: CSF volume, anatomy, position, and drug properties contribute to variable spread; no simple recipe guarantees a precise level.',
      'Repeat spinal decisions: Failed versus partial blocks are different problems. Published approaches do not justify automatic full-dose repetition when prior intrathecal delivery is uncertain.',
      'Current safety guidance: Use the ASRA fifth-edition antithrombotic guideline and 2025 infection-control recommendations alongside procedure-specific protocols.',
      'Comparative claims: Spinal, epidural, and general anesthesia have different strengths and risks; selection should be patient- and operation-specific rather than based on a universal superiority claim.',
    ],
    ['spinal', 'asra', 'infection'],
  ),
];
