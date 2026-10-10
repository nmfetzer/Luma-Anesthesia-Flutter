import '../surgical_case.dart';

// Clinical review draft. Not imported by release main.dart or its routes.
final _laparoscopy = SurgicalSource(
  label: 'OpenAnesthesia · Laparoscopic physiology and anesthesia (2024)',
  url: 'https://www.openanesthesia.org/keywords/anesthesia-for-laparoscopic-and-robotic-surgery/',
);
final _prospect = SurgicalSource(
  label: 'PROSPECT · Cholecystectomy pain recommendations (2024)',
  url: 'https://esraeurope.org/wp-content/uploads/2024/08/Summary-recommendations_Laparoscopic-cholecystectomy_EN.pdf',
);
final _surgery = SurgicalSource(
  label: 'StatPearls · Laparoscopic cholecystectomy (updated 2025)',
  url: 'https://www.statpearls.uk/point-of-care/24022',
);
final _nmb = SurgicalSource(
  label: 'APSF · ASA neuromuscular monitoring guidance (2023)',
  url: 'https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/',
);
final _physiology = SurgicalSource(
  label: 'BJA Education · Laparoscopic anesthesia review (2011)',
  url: 'https://academic.oup.com/bjaed/article/11/5/177/282908?login=false',
);

final laparoscopicCholecystectomyDraft = SurgicalCaseReference(
  id: 'laparoscopic-cholecystectomy',
  title: 'Laparoscopic cholecystectomy',
  category: 'General & abdominal · Adult',
  aliases: ['lap chole', 'gallbladder removal', 'LC'],
  overview: SurgicalSection(
    id: 'overview',
    title: 'Quick clinical overview',
    bullets: [
      'Usual approach: general anesthesia with a cuffed tracheal tube and controlled ventilation.',
      'Plan for pneumoperitoneum plus head-up positioning: reduced venous return, higher airway pressures and absorbed CO₂.',
      'Watch the timing: sudden bradycardia during insufflation, or unexplained hypotension or hypoxemia, needs prompt assessment.',
      'Prioritize multimodal analgesia, PONV prevention and a recovery plan that changes if the operation becomes more complex.',
    ],
    sources: [_laparoscopy, _prospect],
  ),
  sections: [
    SurgicalSection(
      id: 'procedure',
      title: 'Procedure & approach',
      bullets: [
        'Gallbladder removal through abdominal ports is used for symptomatic gallstone disease and selected inflammatory or functional gallbladder disorders. Elective biliary colic and an acutely ill patient with cholecystitis are not equivalent anesthetic situations.',
        'CO₂ insufflation creates the operative space. Dissection around the cystic duct and artery, separation from the liver bed, and extraction are important stages for communication about bleeding, traction and surgical progress.',
        'The patient starts supine and is generally moved to reverse Trendelenburg with a slight left tilt to expose the right upper quadrant.',
        'Difficult anatomy, inflammation or bleeding may require a different operative strategy or conversion to open surgery. Conversion can be a safety decision, not a failure; reconsider analgesia, access, blood preparation and postoperative care if the plan changes.',
      ],
      sources: [_surgery, _physiology],
    ),
    SurgicalSection(
      id: 'preop',
      title: 'Preoperative assessment & risk modifiers',
      bullets: [
        'Clarify the indication, urgency and current illness. Review pain and vomiting, oral intake, volume status, evidence of infection, jaundice or biliary obstruction, and whether pancreatitis is suspected.',
        'Use the clinical picture and existing workup to guide testing rather than ordering a fixed panel for every case. Relevant findings may include leukocytosis, bilirubin and liver-enzyme abnormalities; amylase or lipase is relevant when pancreatitis is suspected.',
        'Assess the patient’s ability to tolerate increased intra-abdominal pressure, CO₂ absorption and head-up positioning. Cardiovascular or respiratory disease, renal dysfunction and hypovolemia may change monitoring and the acceptable physiologic response.',
        'Review aspiration risk and airway difficulty together. Do not infer an empty stomach simply from the procedure name or presume that every elective laparoscopic case needs the same induction sequence.',
        'Discuss anticipated operative difficulty and possible open conversion. A short outpatient plan should not determine the anesthetic when the patient or surgical disease suggests a more complicated course.',
      ],
      sources: [_surgery, _laparoscopy, _physiology],
    ),
    SurgicalSection(
      id: 'setup',
      title: 'Room setup, positioning & monitoring',
      bullets: [
        'Use standard anesthetic monitoring, including continuous assessment of oxygenation and ventilation. If neuromuscular blocking drugs are used, arrange quantitative monitoring where it will remain accessible.',
        'Secure the patient against sliding during head-up and lateral tilt, protect pressure points, and confirm that lines and the airway remain accessible after positioning and draping.',
        'Choose IV access and blood availability according to patient condition and expected surgical difficulty. Avoid presenting an arterial line, central line or fixed crossmatch quantity as mandatory for every uncomplicated case.',
        'Consider an arterial line when cardiovascular instability or the need for repeated arterial measurements justifies it. Plan ahead rather than waiting until access is limited by the surgical setup.',
        'Coordinate gastric decompression if needed for exposure; this is not a promise that an orogastric or nasogastric tube will be required or retained in every patient.',
      ],
      sources: [_laparoscopy, _physiology, _nmb],
    ),
    SurgicalSection(
      id: 'airway',
      title: 'Airway & ventilation',
      bullets: [
        'A cuffed tracheal tube is the usual approach because pneumoperitoneum often requires controlled ventilation and higher airway pressures. Airway selection still depends on aspiration risk, respiratory mechanics and the operative plan.',
        'Use a lung-protective strategy. The OpenAnesthesia review describes tidal volumes of 6–8 mL/kg ideal body weight; adjust PEEP, respiratory rate and pressure limits to compliance, oxygenation and hemodynamic tolerance rather than using a fixed recipe.',
        'Expect cephalad diaphragmatic displacement, reduced compliance and increased airway pressure after insufflation. Follow capnography and compensate for absorbed CO₂ with appropriate minute ventilation while avoiding injurious pressures.',
        'Interpret peak and plateau pressures in context. With an abrupt ventilation change, reassess the circuit, tube patency and depth, breath sounds and patient position rather than assuming all pressure increases are from pneumoperitoneum.',
        'Individualize CO₂ goals to comorbidity. Permissive hypercapnia is not an automatic choice when increased cerebral blood flow or pulmonary vascular load could be poorly tolerated.',
      ],
      sources: [_laparoscopy, _physiology],
    ),
    SurgicalSection(
      id: 'hemodynamics',
      title: 'Pneumoperitoneum & hemodynamics',
      bullets: [
        'Increased abdominal pressure can compress venous capacitance vessels and increase afterload. Reverse Trendelenburg adds dependent venous pooling; cardiac output may fall even when arterial pressure is preserved or elevated.',
        'Hypercarbia and neurohumoral responses can produce hypertension and tachycardia. Treat the mechanism: assess anesthetic depth, ventilation, surgical stimulation and insufflation pressure rather than reflexively giving the same drug.',
        'Peritoneal stretch at insufflation can provoke a marked vagal response. Alert the surgeon to clinically important bradycardia and consider pausing insufflation or releasing pneumoperitoneum while assessing perfusion and treating under the appropriate resuscitation protocol.',
        'For hypotension, consider reduced venous return, anesthetic effect, bleeding and less common mechanical complications. Timing relative to induction, positioning, port placement and insufflation helps organize the differential but does not establish the diagnosis.',
        'Discuss the lowest insufflation pressure compatible with safe exposure. PROSPECT advises pressures below 12 mmHg as a pain-reduction measure; this is not an inflexible operating limit or a guarantee of physiologic tolerance.',
      ],
      sources: [_laparoscopy, _physiology, _prospect],
    ),
    SurgicalSection(
      id: 'fluids',
      title: 'Fluids, bleeding & changing surgical conditions',
      bullets: [
        'Individualize fluid replacement to volume status, losses and perfusion. Avoid a fixed fluid volume simply because the operation is a laparoscopic cholecystectomy.',
        'Pressure-based filling measurements can be misleading during pneumoperitoneum. Reduced urine output may reflect pressure-related renal effects; do not use that finding alone as proof of fluid responsiveness.',
        'Use fluid and vasoactive support according to the suspected mechanism and clinical response. Significant instability also warrants discussion of abdominal pressure and surgical events, not only escalation of medication.',
        'Bleeding may arise from the liver bed, cystic artery or access injury. A limited laparoscopic view and pressure-related tamponade can obscure blood loss; unexplained deterioration requires active reassessment with the surgical team.',
        'Reassess hemodynamics during desufflation and before closure. If the case converts to open surgery, update expected pain, blood loss, duration and postoperative disposition rather than continuing the original outpatient assumptions.',
      ],
      sources: [_physiology, _surgery, _laparoscopy],
    ),
    SurgicalSection(
      id: 'analgesia',
      title: 'Multimodal analgesia & regional options',
      bullets: [
        'Pain may be somatic at port sites, visceral from dissection and peritoneal stretch, or referred to the shoulder. Treat the pain pattern and reassess unexpectedly severe or persistent pain rather than simply escalating opioids.',
        'The 2024 PROSPECT recommendations support acetaminophen plus an NSAID or COX-2 inhibitor when appropriate, with IV dexamethasone and rescue opioids if other measures are insufficient. Apply prescribing contraindications and patient-specific risks.',
        'Port-site infiltration with a long-acting local anesthetic is a supported option. Coordinate the total local-anesthetic dose across every injection, block and surgical instillation.',
        'Procedure-specific PROSPECT guidance also supports intraperitoneal local anesthetic, but advises against combining it with port-site infiltration because of cumulative exposure and systemic toxicity concerns. General laparoscopic reviews are less supportive of routine intraperitoneal use; this is an area for a deliberate, protocol-based choice.',
        'TAP or erector spinae plane blocks are second-line options in PROSPECT, not obligatory additions for every patient. Consider expected pain, chronic opioid use, redo surgery, expertise and the availability of simpler techniques.',
        'Routine gabapentinoids, IV lidocaine, ketamine infusions or dexmedetomidine are not default components of the PROSPECT regimen. A potential benefit in a selected patient does not establish routine benefit for uncomplicated day-case cholecystectomy.',
      ],
      sources: [_prospect, _laparoscopy],
    ),
    SurgicalSection(
      id: 'ponv',
      title: 'PONV prevention & recovery comfort',
      bullets: [
        'Plan PONV prophylaxis rather than waiting for symptoms. Laparoscopy is a relevant risk factor, and opioid exposure can add to the postoperative burden.',
        'Use an individualized antiemetic strategy and opioid-sparing analgesia. PROSPECT includes IV dexamethasone as part of the procedure-specific regimen; choose additional measures according to patient risk, contraindications and local protocols.',
        'Consider avoidable emetogenic exposures. The OpenAnesthesia review favors avoiding nitrous oxide because of PONV and bowel-distention concerns.',
        'Residual intraperitoneal gas can contribute to shoulder-tip discomfort. Surgical evacuation of remaining gas is supported, but not all shoulder or upper-abdominal pain should be attributed to retained CO₂.',
      ],
      sources: [_laparoscopy, _prospect, _physiology],
    ),
    SurgicalSection(
      id: 'emergence',
      title: 'Emergence & neuromuscular recovery',
      bullets: [
        'Reassess ventilation, oxygenation, hemodynamics, temperature and analgesia as insufflation ends. Removal of pneumoperitoneum changes respiratory mechanics and does not by itself establish readiness for extubation.',
        'When neuromuscular blocking drugs have been used, confirm a quantitative train-of-four ratio of at least 0.9 at the adductor pollicis before extubation, consistent with ASA guidance.',
        'Choose antagonism according to the drug and measured depth of block. Clinical signs such as a head lift, elapsed time since the last dose, or an apparently adequate tidal volume do not reliably exclude residual paralysis.',
        'Neuromuscular recovery is one part of the extubation decision, not the entire decision. Consider airway protection, spontaneous ventilation and the need for continued support in the context of the patient and intraoperative course.',
      ],
      sources: [_nmb, _laparoscopy],
    ),
    SurgicalSection(
      id: 'recovery',
      title: 'PACU concerns & postoperative deterioration',
      bullets: [
        'Handoff should include airway or ventilation difficulties, significant hemodynamic events, neuromuscular recovery, analgesics and antiemetics already given, local-anesthetic exposure and any surgical concern.',
        'Reassess respiratory obstruction, hypoventilation, hypoxemia and excessive sedation rather than assuming they are routine recovery findings. Residual neuromuscular block is one important possible contributor.',
        'Unexpectedly severe or persistent pain, unexplained instability or respiratory deterioration requires reassessment for a complication rather than automatic attribution to normal laparoscopic recovery.',
        'Bile leak can present after surgery with pain, fever and hyperbilirubinemia. Bleeding, bile duct injury or injury to surrounding structures may not be obvious at the end of the operation.',
        'Determine discharge or admission through the actual clinical course and local criteria. Do not guarantee same-day discharge for a patient with ongoing symptoms, physiologic abnormalities or a complicated operation.',
      ],
      sources: [_surgery, _physiology, _nmb],
    ),
    SurgicalSection(
      id: 'evidence',
      title: 'Evidence scope & reference notes',
      bullets: [
        'This is an adult clinical reference, not a patient-specific anesthetic order set. Source pages were checked October 4, 2026.',
        'PROSPECT provides procedure-specific analgesia recommendations published in 2024, based on evidence searched through December 2022. Its recommendations should not be described as incorporating every later trial.',
        'OpenAnesthesia supplies general laparoscopic physiology and anesthesia context. APSF summarizes the 2023 ASA neuromuscular guideline; StatPearls supplies procedural anatomy and complications.',
        'The 2011 BJA review is used for established physiologic and perioperative context, not as the authority for current drug regimens or all modern practice recommendations.',
        'No fixed duration, blood-loss estimate, fluid total or universal induction-drug recipe is assigned. These vary with the patient, pathology, technique and intraoperative events.',
      ],
      sources: [_prospect, _laparoscopy, _nmb, _surgery, _physiology],
    ),
  ],
);
