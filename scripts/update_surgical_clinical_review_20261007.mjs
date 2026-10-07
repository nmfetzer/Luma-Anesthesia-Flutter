// Evidence-supported draft corrections. No clinical approval or release activation.
// Run from repo root. Before/after records are retained outside the clinical reader.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {createHash} from 'node:crypto';
const baseline = 'f7cbb7e7a97a9aafcba93fbb03d0a1b5dc221bf1';
const file = 'assets/data/surgical_cases.json';
const original = JSON.parse(execFileSync('git', ['show', `${baseline}:${file}`], {maxBuffer: 30_000_000}));
const records = structuredClone(original);
const current = JSON.parse(fs.readFileSync(file));
const ledgerFile = 'docs/surgical-review-2026-10-07/correction-ledger.json';
const priorLedger = fs.existsSync(ledgerFile) ? JSON.parse(fs.readFileSync(ledgerFile)) : null;
const hash = value => createHash('sha256').update(JSON.stringify(value)).digest('hex');
const source = (label, url) => ({label, url});
const S = {
  pdph: source('Multisociety PDPH guideline (2024)', 'https://rapm.bmj.com/content/49/7/471'),
  platelets: source('SOAP obstetric thrombocytopenia consensus (2021)', 'https://www.soap.org/assets/docs/Consensus/SOAP%20Consensus%20Statement%20Thrombocytopenia%202021.pdf'),
  asra: source('ASRA antithrombotic guideline, fifth edition (2025)', 'https://rapm.bmj.com/content/early/2025/01/21/rapm-2024-105766'),
  last: source('ASRA LAST checklist (2020 version)', 'https://asra.com/docs/default-source/guidelines-articles/local-anesthetic-systemic-toxicity-rgb.pdf?sfvrsn=33b348e_2'),
  morphine: source('SOAP neuraxial morphine monitoring consensus (2019 full statement)', 'https://www.soap.org/assets/COE/SOAP%20Consensus%20Statement%20Neuraxial%20Opioids%202019.pdf'),
  nice: source('NICE NG192: Caesarean birth recommendations', 'https://www.nice.org.uk/guidance/ng192/chapter/recommendations'),
  airway: source('OAA/DAS obstetric difficult-airway guideline (2015)', 'https://pmc.ncbi.nlm.nih.gov/articles/PMC4606761/'),
  who: source('WHO/FIGO/ICM consolidated PPH guidelines (2025)', 'https://iris.who.int/server/api/core/bitstreams/88bf11a5-93b6-4d6b-bdaa-856b46c8ed3c/content'),
  pas: source('RCOG: Placenta Praevia and Placenta Accreta Spectrum (2026)', 'https://pmc.ncbi.nlm.nih.gov/articles/PMC13485456/'),
  ecv: source('StatPearls: External Cephalic Version', 'https://www.statpearls.com/point-of-care/21471'),
  ecvAnes: source('BJA Education: neuraxial block and ECV (2020 review)', 'https://pmc.ncbi.nlm.nih.gov/articles/PMC7807965/'),
  esc: source('ESC cardiovascular disease and pregnancy guideline (2025)', 'https://academic.oup.com/eurheartj/article/46/43/4462/8234487?login=false'),
  aries: source('ARIES-HM3 randomized trial (2023)', 'https://pubmed.ncbi.nlm.nih.gov/37950897/'),
  abbott: source('Abbott: HeartMate 3 aspirin-free labeling update (2024)', 'https://abbott.mediaroom.com/2024-08-21-Abbott-Advances-Heart-Failure-Management-with-Aspirin-Free-Regimen-for-Patients-Receiving-the-HeartMate-3-TM-Heart-Pump'),
  ecmo: source('VV-ECMO anticoagulation: monitoring limitations (2025 review)', 'https://www.frontiersin.org/journals/medicine/articles/10.3389/fmed.2025.1530411/full'),
  eras: source('ERAS gynecology guideline index: 2026 update identified, full text not verified', 'https://erassociety.org/specialty/gynaecology/'),
  lipid: source('StatPearls: Lipid Emulsion Therapy', 'https://www.ncbi.nlm.nih.gov/sites/books/NBK549897/'),
  beach: source('APSF: blood pressure in the beach-chair position (2020 safety review)', 'https://www.apsf.org/article/why-worry-about-blood-pressure-during-surgery-in-the-beach-chair-position/'),
  cement: source('AAGBI/BOA/BGS cemented hemiarthroplasty safety guideline (2015)', 'https://pmc.ncbi.nlm.nih.gov/articles/PMC6681143/'),
  compartment: source('Association of Anaesthetists: lower-leg trauma regional analgesia and ACS (2021)', 'https://ra-uk.org/media/xbwbsr5c/regional_analgesia_for_lower_leg_trauma_and_the_risk_of_acute_compartment_syndrome.pdf'),
  irrigation: source('Shoulder arthroscopy fluid extravasation: systematic review (2018)', 'https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5954585/'),
  cardiacAnes: source('Obstetric Anesthesia and Heart Disease: Practical Clinical Considerations (2021)', 'https://pubs.asahq.org/anesthesiology/article/135/1/164/115827/Obstetric-Anesthesia-and-Heart-Disease-Practical'),
};
const reasons = new Map();
const c = id => { const r = records.find(x => x.id === id); assert(r, id); return r; };
function put(id, sectionId, title, bullets, sources, reason) {
  const r = c(id);
  const section = {id: sectionId, title, bullets, sources};
  const n = r.sections.findIndex(s => s.id === sectionId);
  if (n < 0) r.sections.splice(Math.max(0, r.sections.findIndex(s => s.id === 'evidence')), 0, section);
  else r.sections[n] = section;
  r.sourceChecked = '2026-10-07';
  reasons.set(id, [...new Set([...(reasons.get(id) || []), reason])]);
}
function overview(id, bullets, sources) {
  c(id).overview = {id:'overview', title:'Quick clinical overview', bullets, sources};
}
function add(id, sectionId, bullets, sources, reason) {
  const s = c(id).sections.find(s => s.id === sectionId); assert(s, `${id}:${sectionId}`);
  put(id, sectionId, s.title, [...s.bullets, ...bullets], [...new Map([...s.sources, ...sources].map(s => [s.url, s])).values()], reason);
}
const EBP = 'epidural-blood-patch';
overview(EBP, [
  'Evaluate postpartum headache rather than assuming every headache after neuraxial care is PDPH; focal deficits, visual change, seizures or altered consciousness require assessment for other diagnoses.',
  'Consider therapeutic EBP for PDPH that remains disabling despite conservative care, or for significant neurological sequelae after appropriate assessment. Prophylactic EBP is not routine.',
  'Check infection, hemostasis and antithrombotic exposure. Use asepsis, individualized localization and slow incremental injection; stop for significant pain or neurological symptoms.',
  'Assess response and provide written return precautions, contact details and follow-up until resolution. Worsening, changed or neurologically complicated headache after EBP needs urgent reassessment, not automatic repeat patching.'
], [S.pdph, S.platelets, S.asra]);
put(EBP, 'procedure', 'Indication, level & imaging guidance', [
  'Therapeutic EBP places autologous blood in the epidural space for a suspected dural leak. When the puncture level is known, the multisociety guideline favors that level or one interspace below.',
  'Radiological guidance is individualized to anatomy, prior surgery, failed prior attempts and operator expertise; routine fluoroscopy, contrast or prone positioning is not established as mandatory for a standard obstetric interlaminar patch.',
  'An EBP performed within 48 hours may be more likely to require repetition. Discuss this uncertainty without treating 48 hours as a mandatory delay when symptoms warrant earlier treatment.'
], [S.pdph], 'Replace narrative-review technique assumptions with multisociety guidance.');
put(EBP, 'preop', 'Headache differential & contraindications', [
  'Review onset, orthostatic character, neuraxial history, blood pressure, neurological examination, fever and associated symptoms. Consider preeclampsia/PRES, cerebral venous thrombosis, subdural hematoma and infection when the presentation is atypical.',
  'Focal neurological deficits, visual changes, altered consciousness or seizures should prompt neuroimaging for alternative diagnoses. Consider imaging for nonorthostatic headache, a change from orthostatic to nonorthostatic pain, or onset more than five days after suspected puncture.',
  'Routine cranial imaging is not required to establish typical PDPH; normal imaging does not exclude it. Select MRI, CT and venous imaging according to the suspected diagnosis, urgency and availability.',
  'Do not perform EBP in systemic infection. Assess puncture-site infection, coagulation disorder and recent anticoagulant exposure; obtain consent covering failure, repeat patching, back pain and uncommon neurological complications.'
], [S.pdph], 'Add differential, imaging triggers and infection safeguards.');
put(EBP, 'hemostasis', 'Platelets & antithrombotic eligibility', [
  'For obstetric neuraxial procedures, SOAP describes likely low hematoma risk at platelets at least 70 × 10⁹/L (70,000/µL) in gestational thrombocytopenia, ITP or hypertensive disorders of pregnancy when additional risk factors, bleeding history and DIC concerns are absent. This is a qualified risk framework, not an automatic EBP clearance threshold.',
  'Assess platelet trend, etiology, platelet function concerns, bleeding history and concurrent antithrombotics. Unknown etiology, lower counts or suspected coagulopathy require individualized expert assessment rather than substituting an older review author’s preferred threshold.',
  'For suspected HELLP, a platelet count within six hours of the planned neuraxial procedure may be reasonable; do not generalize this interval to every patient with preeclampsia.',
  'Apply the current drug-, dose- and renal-function-specific neuraxial interruption/restart guidance before EBP. Do not independently stop anticoagulation without assessing its indication and thrombosis risk.'
], [S.pdph, S.platelets, S.asra], 'Resolve platelet-source conflict with qualified consensus and antithrombotic guidance.');
put(EBP, 'setup', 'Asepsis, positioning & observation', [
  'Use strict aseptic technique for blood collection and epidural access. Choose a position and localization method that permit safe access, patient tolerance and communication; no single position is mandated by the multisociety guideline.',
  'Agree on observation, rescue capability and postprocedure assessment appropriate to the patient and any sedation. Document baseline neurological symptoms and a plan to reassess headache and neurological function.'
], [S.pdph], 'Remove inappropriate universal prone/fluoroscopy framing.');
put(EBP, 'airway', 'Sedation & communication', [
  'EBP does not itself require general anesthesia, intubation or neuromuscular blockade. If sedation is considered, assess its risks separately and preserve the ability to report pain or neurological symptoms during injection.',
  'The multisociety guideline does not establish a universal sedative regimen. Sedation requires appropriate monitoring and airway-rescue capability; local anesthesia and communication should not be replaced by an unsupported deep-sedation recipe.'
], [S.pdph, S.airway], 'Preserve individualized sedation without implying a mandatory airway technique.');
put(EBP, 'intraop', 'Slow incremental blood injection', [
  'The optimal volume is uncertain; the multisociety guideline notes commonly recommended adult lumbar volumes of 15–20 mL. This is not a mandatory volume to reach.',
  'Inject slowly and incrementally. Stop for significant backache, headache, pressure paresthesia or neurological symptoms; reassess before any decision to continue.',
  'Volumes greater than 30 mL have not shown better success. Do not pursue a volume target despite poor tolerance or use success estimates as a promise to the patient.'
], [S.pdph], 'Add qualified volume guidance and symptom-limited injection.');
put(EBP, 'complications', 'Failed patch, changed headache & neurological red flags', [
  'Persistent or recurrent PDPH may warrant another EBP after reassessment. If the first patch has no effect, the diagnosis is uncertain or the headache changes, evaluate alternative causes and consider specialist input before repetition.',
  'Worsening symptoms despite EBP, new focal neurological findings or a change in headache character warrant urgent neuroimaging and appropriate specialist referral.',
  'New severe back pain, weakness, sensory changes or bladder/bowel dysfunction should not be dismissed as routine postpatch discomfort; urgently assess for neurological complications.',
  'Changed headache, including a recumbency-worsened pattern, requires reassessment rather than an automatic assumption of persistent CSF leak.'
], [S.pdph], 'Replace wait-and-repeat framing with reassessment and escalation.');
put(EBP, 'fluids', 'Hydration rather than a fixed fluid prescription', [
  'Maintain adequate hydration; routine forced fluid loading is not an established treatment for a dural leak. Use intravenous fluid when oral intake is inadequate or another clinical indication exists.',
  'Autologous blood used for EBP is not a transfusion strategy. Fluid and cardiovascular management remain individualized.'
], [S.pdph], 'Remove unhelpful missing-transfusion-protocol language.');
put(EBP, 'analgesia', 'Conservative care & patient counseling', [
  'Use appropriate simple analgesia and consider caffeine within the guideline’s patient-specific limits while evaluating symptoms. Conservative care must not delay evaluation of red flags or appropriate EBP for disabling symptoms.',
  'Explain that repeat treatment may be needed and that aftercare restrictions have limited supporting evidence. Do not describe a fixed activity restriction period as proven to prevent recurrence.'
], [S.pdph], 'Distinguish evidence-supported care from unproven aftercare rules.');
put(EBP, 'emergence', 'Postprocedure assessment & follow-up', [
  'Reassess headache response, back symptoms and neurological status before discharge. Supine observation is commonly used, but evidence is insufficient to mandate one immobilization duration for all patients.',
  'Provide verbal and written warning signs, contact details and a follow-up plan until headache resolves. Communicate the diagnosis and treatment to the obstetric team and relevant outpatient clinicians.',
  'Urgent return is needed for worsening or changed headache, focal neurological symptoms, seizures, altered consciousness or other concerning findings. Recovery from any sedation must also be adequate for discharge.'
], [S.pdph], 'Add follow-up and remove unsupported fixed recovery requirements.');
put(EBP, 'evidence', 'Evidence scope & limitations', [
  'The 2024 multisociety PDPH guideline now supplies the principal diagnostic, EBP and follow-up framework. Many recommendations still have low or moderate certainty; individualized clinical judgment remains necessary.',
  'SOAP platelet guidance and ASRA antithrombotic guidance supplement EBP risk assessment. Neither establishes zero risk or an automatic numerical clearance rule.',
  'The previously identified retracted PDPH review is not used to support the revised content. Source reconciliation is not independent clinical approval.'
], [S.pdph, S.platelets, S.asra], 'Replace obsolete missing-guideline statement and exclude retracted material.');

const LABOR = 'labor-epidural-placement';
put(LABOR, 'antithrombotics', 'Antithrombotics: placement, removal & restart', [
  'Document the exact anticoagulant, dose, indication, last administration, renal function, other hemostasis-altering drugs and planned postpartum restart. Catheter removal is also a neuraxial bleeding-risk event.',
  'ASRA fifth-edition minimum preprocedure intervals for LMWH are at least 12 hours after low-dose LMWH and at least 24 hours after high/therapeutic-dose LMWH. Residual effect may persist longer, especially with renal impairment; these intervals are not automatic clearance.',
  'For postoperative twice-daily low-dose LMWH, remove the catheter before starting LMWH; the first dose is the following day and at least 12 hours after placement, and at least four hours after removal.',
  'For postoperative once-daily low-dose LMWH, the first dose is at least 12 hours after placement. If a catheter is maintained, avoid additional hemostasis-altering medications; remove it at least 12 hours after the last LMWH dose and wait at least four hours before the next dose.',
  'For postoperative high-dose LMWH, satisfy both surgical-hemostasis and neuraxial timing requirements: ASRA describes restart at 24 hours after non-high-bleeding-risk surgery or 48–72 hours after high-bleeding-risk surgery, with catheter removal at least four hours before the first dose and that dose at least 24 hours after placement.',
  'This is a limited LMWH reference, not a complete anticoagulant table. Use the linked guideline for UFH, DOACs, antiplatelets, traumatic placement, assays and renal impairment. Urgent maternal/fetal situations require multidisciplinary risk-benefit decisions rather than automatic extrapolation.'
], [S.asra], 'Add current qualified placement/removal/restart guidance.');
put(LABOR, 'last-rescue', 'Suspected LAST: rescue reference', [
  'For seizure, arrhythmia or cardiovascular instability concerning for LAST after local anesthetic exposure, stop administration, call for help and obtain the LAST kit and ASRA checklist. Support airway/oxygenation and consider lipid emulsion early.',
  'Use 20% lipid emulsion, not propofol as a lipid substitute. ASRA’s checklist gives approximately 1.5 mL/kg over 2–3 minutes followed by 0.25 mL/kg/min for patients under 70 kg; for patients over 70 kg it gives approximately 100 mL over 2–3 minutes followed by approximately 250 mL over 15–20 minutes.',
  'If instability persists, the checklist allows repeat bolus and doubling the infusion. Continue lipid for more than 15 minutes after hemodynamic stability; maximum cumulative lipid dose is 12 mL/kg.',
  'LAST resuscitation differs from standard ACLS: benzodiazepines are preferred for seizures; if epinephrine is needed, start with a smaller dose, less than 1 microgram/kg. Avoid additional local anesthetics, beta blockers, calcium-channel blockers and vasopressin.',
  'After stabilization, ASRA describes observation for at least two hours after seizure, four to six hours after cardiovascular instability, and individualized longer care after cardiac arrest. Maternal/fetal status and the overall obstetric course may require additional monitoring.'
], [S.last, S.lipid], 'Add direct crisis reference and qualified rescue summary.');
put(LABOR, 'evidence', 'Evidence scope & limitations', [
  'General labor-analgesia principles are supplemented by ASRA fifth-edition antithrombotic guidance, SOAP obstetric platelet guidance and the ASRA LAST checklist.',
  'The LMWH summary is not a complete anticoagulant decision tool. Drug dose, renal function, catheter timing, hemostasis and urgent-delivery risk must be considered together.',
  'No universal labor-epidural medication mixture, allergy substitute or PONV regimen is implied. The linked rescue checklist is an adjunct to trained emergency response, not independent clinical signoff.'
], [S.asra, S.platelets, S.last], 'Close unsupported claim that timing and LAST references are absent.');

const CS = ['cesarean-section-elective', 'urgent-emergent-c-section-category-1-2'];
const PAS = 'placenta-accreta-spectrum-pas-cesarean-hysterectomy';
const PPH = 'postpartum-hemorrhage-management';
const PRE = 'preeclampsia-severe-preeclampsia-anesthesia-management';
const CARD = 'high-risk-obstetric-anesthesia-cardiac-disease-in-pregnancy';
for (const id of [...CS, PAS, PPH, PRE, CARD]) {
  put(id, 'ob-airway-rescue', 'Obstetric airway rescue & extubation planning', [
    'Before GA, agree on aspiration risk, anticipated airway difficulty, positioning, preoxygenation, skilled help and a failed-intubation plan. Maintain uterine displacement when applicable and use head-up/ramped positioning when suitable.',
    'Prioritize oxygenation. The OAA/DAS obstetric algorithm supports gentle mask ventilation after induction, limits repeated intubation attempts, and advises reducing or releasing cricoid pressure if it impedes ventilation or intubation.',
    'After failed intubation, declare the problem and use facemask or an appropriate second-generation supraglottic airway for oxygenation. Decide whether to wake or proceed based on airway security, aspiration risk, maternal/fetal urgency and surgical needs.',
    'A cannot-intubate/cannot-oxygenate emergency requires immediate escalation to emergency front-of-neck access under the trained local pathway; repeated unsuccessful instrumentation must not delay rescue.',
    'Plan extubation and reintubation contingencies. Awake responsiveness, satisfactory ventilation/oxygenation and adequate neuromuscular recovery are prerequisites when applicable; airway edema, traumatic intubation, pulmonary edema or ongoing instability may justify continued ventilation and ICU care rather than forced extubation.'
  ], [S.airway], 'Add usable obstetric airway/escalation and recovery framework; retain individualized clinical decisions.');
}
for (const id of CS) {
  put(id, 'opioid-monitoring', 'Neuraxial morphine: dose- and risk-stratified monitoring', [
    'Assess respiratory-depression risk before selecting postoperative monitoring. Consider obesity/OSA, significant cardiopulmonary disease, chronic opioids, additional sedatives/systemic opioids, magnesium and perioperative respiratory events.',
    'For healthy low-risk patients, SOAP’s full statement considers routine institutional cesarean monitoring sufficient after intrathecal morphine at most 0.05 mg (50 micrograms) or epidural morphine at most 1 mg. This does not mean no postoperative observation.',
    'For healthy low-risk patients receiving intrathecal morphine greater than 0.05 through 0.15 mg (50–150 micrograms) or epidural morphine greater than 1 through 3 mg, the full SOAP statement recommends respiratory-rate and sedation assessment every two hours for 12 hours in addition to routine institutional observations.',
    'For higher doses, SOAP directs clinicians to ASA/ASRA monitoring: at least hourly respiratory-rate and sedation assessment for the first 12 hours, then every two hours for the next 12 hours. Higher-risk patients need individualized increased intensity and consideration of oxygenation/ventilation monitoring rather than automatic low-risk scheduling.',
    'These are monitoring dose bands, not prescribing recommendations. They apply to single-dose neuraxial morphine after cesarean, not every neuraxial opioid or continuous epidural infusion. Clinical deterioration requires immediate assessment regardless of the scheduled interval.'
  ], [S.morphine], 'Add full-statement monitoring details with explicit low-risk scope.');
  put(id, 'hemorrhage-readiness', 'Hemorrhage readiness & escalation', [
    'Match vascular access and blood preparation to placental findings, anemia, bleeding risk and the clinical course. Quantify ongoing blood loss and reassess perfusion; a normal early hemoglobin does not exclude major acute bleeding.',
    'When PPH occurs, communicate and treat the cause while mobilizing the obstetric hemorrhage pathway, blood-bank support and appropriate resuscitation. Use the linked consolidated PPH guidance; do not wait for a fixed blood-loss number when the patient is deteriorating.',
    'TXA for treatment of established PPH and routine prophylactic TXA are different decisions. WHO 2025 recommends early IV treatment within three hours of birth but does not recommend routine prophylactic TXA at cesarean birth.'
  ], [S.who, S.nice], 'Add hemorrhage guidance without prescribing one institutional MTP.');
}
const URGENT = CS[1];
put(URGENT, 'urgency', 'Urgency categories & decision-to-birth context', [
  'NICE category 1 means an immediate threat to the life of the woman or fetus; category 2 means maternal or fetal compromise that is not immediately life-threatening.',
  'NICE advises category 1 birth as soon as possible and in most situations within 30 minutes, and category 2 as soon as possible and in most situations within 75 minutes of the decision.',
  'These are qualified UK guideline targets, not permission to wait or a universal rule overriding maternal safety and the clinical situation. Communicate the actual emergency and agree the fastest safe anesthetic plan; category alone does not dictate GA.'
], [S.nice], 'Supply previously missing category definitions and qualify timing.');
put(URGENT, 'airway', 'Technique selection & emergency airway', [
  'Assess urgency, airway/aspiration risk, maternal physiology and any functioning neuraxial catheter. A category label alone does not mandate intubation or rule out neuraxial anesthesia.',
  'When GA is selected, use the obstetric airway rescue and extubation section below and the linked full algorithm. Gentle ventilation and release of obstructing cricoid pressure are compatible with prioritizing oxygenation.'
], [S.nice, S.airway], 'Remove ambiguous failed-intubation instruction retaining cricoid pressure unconditionally.');
add(PRE, 'preop', [
  'If the clinical scenario is consistent with HELLP, SOAP considers it reasonable to verify platelets within six hours of neuraxial placement or catheter removal. Repeat-testing frequency in preeclampsia without that scenario remains individualized; do not apply a six-hour rule indiscriminately.',
  'A reassuring platelet count does not override active bleeding, DIC concerns or other contraindications. Concurrent aspirin with thrombocytopenia and additional coagulation tests have evidence limitations; seek expert assessment rather than treating an isolated assay as clearance.'
], [S.platelets], 'Make HELLP timing explicit while preserving scope.');

const ECV = 'external-cephalic-version-ecv';
put(ECV, 'neuraxial-selection', 'Neuraxial benefit, hypotension & emergency readiness', [
  'Neuraxial analgesia can improve comfort and ECV success, but evidence does not establish one mandatory technique or dose for all patients. Discuss maternal preference, prior unsuccessful attempts, hypotension risk and local readiness.',
  'Monitor and treat maternal hypotension promptly when neuraxial care is used, with uterine displacement and individualized fluid/vasopressor support. Do not import a trial dose or a cesarean regimen as a universal ECV prescription.',
  'Perform ECV where prompt cesarean and anesthesia support are available. Stop manipulation for significant fetal bradycardia, poor maternal tolerance or an attempt that is not achieved easily; persistent fetal concerns require urgent obstetric reassessment.',
  'StatPearls describes fetal monitoring for 30–60 minutes after either successful or unsuccessful ECV; extend assessment for concerning findings and follow the agreed obstetric pathway. Failure alone does not require immediate cesarean delivery.'
], [S.ecv, S.ecvAnes], 'Add evidence-based neuraxial selection and monitoring without inventing fetal thresholds.');

put(PAS, 'airway', 'Anesthetic choice & planned or urgent conversion', [
  'Discuss GA, neuraxial anesthesia and planned sequential neuraxial-to-GA options before surgery. The 2026 RCOG guidance supports individualized selection with consent for possible conversion; PAS alone does not mandate one technique.',
  'Plan how prolonged surgery, major bleeding, hemodynamic deterioration or inadequate anesthesia would trigger reassessment and conversion. Airway access and induction during evolving shock must be considered before the crisis.',
  'Neuraxial-to-GA after delivery can be a planned strategy, not a compulsory step. The obstetric airway rescue section supplies the shared framework; anticipated complexity may require additional specialist planning.'
], [S.pas, S.airway], 'Update PAS technique selection and conversion using 2026 guidance.');
put(PAS, 'vascular-adjuncts', 'Vascular adjuncts & evidence limits', [
  'Do not present prophylactic arterial balloons or other interventional-radiology procedures as routine PAS care. The 2026 RCOG guideline finds insufficient evidence for routine use by an expert surgical team.',
  'If an adjunct is selected, agree on access, thrombosis/ischemia surveillance, anticoagulation and rescue. Evidence varies with PAS severity, intervention and surgical approach; an adjunct cannot replace blood availability and experienced multidisciplinary care.'
], [S.pas], 'Replace vague benefit claims with explicit current evidence boundary.');
put(PAS, 'complications', 'Hemorrhage, injury & postoperative escalation', [
  'For unexpected PAS, avoid unplanned placental disruption, call for experienced support and reassess the surgical, anesthetic and hemorrhage plan. Major bleeding and adjacent-organ injury require coordinated intervention.',
  'Prepare immediate blood-product access and adult critical-care capability. Postoperative level of care depends on bleeding, organ dysfunction, respiratory status and support requirements; not every stable patient automatically requires ongoing ventilation or vasopressors.',
  'Conservative management with retained placenta requires specialist follow-up and emergency access for delayed bleeding or infection. Routine cesarean discharge instructions alone are insufficient.'
], [S.pas], 'Remove blanket postoperative-support assumptions.');
put(PAS, 'emergence', 'Recovery, pain & disposition', [
  'Determine extubation versus continued ventilation from airway safety, gas exchange, hemodynamics, hemostasis, temperature and the support required. Use the obstetric airway section for edema/difficult-reintubation considerations.',
  'Communicate blood loss/transfusion, coagulation trends, surgical concerns, vascular adjuncts and analgesic plan to the receiving team. Plan surveillance for ongoing or concealed bleeding.',
  'Discuss postoperative pain control and psychological support as part of specialist PAS care. Individualize multimodal analgesia to organ function, bleeding and anticoagulation; catheter removal requires a fresh hemostasis/timing assessment.'
], [S.pas, S.airway, S.asra], 'Add recovery and analgesia planning rather than a fixed ICU duration.');

put(PPH, 'intraop', 'Cause-directed treatment & early TXA', [
  'Resuscitation and bleeding control proceed together. Evaluate uterine tone, tissue, trauma and coagulation while mobilizing senior obstetric/anesthesia support and the hemorrhage pathway.',
  'WHO 2025 recommends IV oxytocin as first-line uterotonic treatment, with further uterotonics selected for response, contraindications and availability. Avoid rapid unopposed IV oxytocin administration; use the appropriate institutional obstetric regimen.',
  'For established PPH after vaginal or cesarean birth, give TXA as early as possible within three hours of birth: WHO describes 1 g IV over 10 minutes, with a second 1 g IV if bleeding continues after 30 minutes or restarts within 24 hours of completing the first dose.',
  'The three-hour window is measured from birth, not recognition of bleeding. WHO does not support starting TXA after that window for PPH; assess contraindications, including a known thromboembolic event during pregnancy. TXA is an antifibrinolytic, not a uterotonic, and this recommendation is IV only.',
  'WHO’s first-response bundle combines uterine massage, oxytocic medication, TXA, IV fluid, genital-tract examination and escalation. Its formal bundle recommendation is for vaginal birth; individual treatment interventions also apply to cesarean PPH. Do not mislabel bundle trial evidence as cesarean-specific.'
], [S.who], 'Replace underspecified treatment and clarify TXA dose, timing and evidence scope.');
put(PPH, 'fluids', 'Resuscitation & hemostatic therapy', [
  'Activate the local MTP when indicated and reassess clinical perfusion, ongoing loss and laboratory/viscoelastic results. Do not wait for a low hemoglobin in rapid bleeding; early values may be falsely reassuring.',
  'WHO favors isotonic crystalloids over colloids for initial IV resuscitation, while avoiding overload, especially in cardiac disease or preeclampsia. Fluids do not replace definitive bleeding control or needed blood components.',
  'Do not impose one fixed RBC:plasma ratio on every PPH. Use the institution’s validated emergency-release and transfusion pathway, then targeted therapy as results become available.',
  'Assess fibrinogen early. WHO describes replacement when below 2 g/L with a therapeutic goal at least 2 g/L; product choice, dosing and reassessment depend on available concentrate/cryoprecipitate and the local protocol.',
  'Follow calcium, potassium, temperature and acid-base status during major transfusion. Address metabolic complications and surgical hemostasis together rather than treating every persistent bleed as a product-ratio problem.'
], [S.who, ...c(PPH).sections.find(s => s.id === 'fluids').sources], 'Remove unqualified 1:1 framing and add current fibrinogen/clinical assessment.');
put(PPH, 'emergence', 'Posthemorrhage reassessment & recovery level', [
  'After bleeding control, reassess perfusion, ongoing loss, coagulation, temperature, electrolytes, respiratory function and support requirements. Document blood products, TXA and uterotonics received.',
  'Use monitored recovery or critical care appropriate to the course; ongoing shock, major organ dysfunction, respiratory failure or vasoactive/ventilatory support warrants higher-acuity care.',
  'Choose extubation versus continued ventilation according to readiness and reintubation risk, not merely completion of surgery. Individualize analgesia and antiemetics to hemostasis, organ function and the procedure; routine elective ERAC is not automatically applicable.'
], [S.who, S.airway], 'Replace empty recovery-scope language with assessed disposition.');

put(CARD, 'lesion-specific', 'Lesion-specific delivery & anesthesia distinctions', [
  'Use a documented Pregnancy Heart Team plan for significant disease, including lesion severity, ventricular/RV function, anticoagulation, delivery approach, rescue capability and postpartum surveillance. The 2025 ESC guideline uses the updated mWHO 2.0 framework.',
  'Mitral stenosis: avoid treating this as a generic low-SVR lesion; tachycardia and congestion are important concerns. ESC prefers vaginal delivery in many patients but identifies severe stenosis or refractory heart failure as reasons to favor cesarean. Monitor closely after delivery for decompensation.',
  'Severe symptomatic aortic stenosis: preserve perfusion and avoid abrupt hemodynamic changes; cesarean may be considered. Do not extrapolate this approach to an uncomplicated regurgitant lesion.',
  'HCM with severe LVOTO: abrupt peripheral vasodilation is poorly tolerated. Use neuraxial techniques cautiously with a deliberate hemodynamic plan; severe LVOTO may favor cesarean, whereas lower-risk disease often permits vaginal delivery.',
  'Pulmonary arterial hypertension/Eisenmenger: involve a PH expert, protect RV function and avoid sudden systemic vasodilation. ESC usually favors regional over GA and calls for intensive-care monitoring during and after delivery in PAH; this is not an ICU rule for all cardiac diagnoses.',
  'Eisenmenger physiology also requires meticulous avoidance of air embolism; ESC recommends IV line filters. Balance bleeding and thrombosis risks individually.',
  'Cardiomyopathy/arrhythmic disease: plan hemodynamic and rhythm surveillance, analgesia and volume management around the actual ventricular function and arrhythmia burden, including the postpartum period.',
  'Mechanical valves: coordinate a written anticoagulation interruption/bridging and restart plan with cardiology, obstetrics and anesthesia. Do not independently stop VKA or apply a routine LMWH rule without considering valve-thrombosis risk; neuraxial eligibility must meet the applicable anticoagulant guidance.'
], [S.esc, S.asra, ...c(CARD).sections.find(s => s.id === 'intraop').sources], 'Add contemporary lesion-specific review rather than one generic cardiac plan.');
put(CARD, 'emergence', 'Lesion-specific postpartum surveillance', [
  'Specify the monitoring location, rhythm surveillance, fluid balance, heart-failure warning signs and anticoagulation restart plan before delivery; update for actual obstetric and cardiac events.',
  'Do not apply a fixed ICU duration to all cardiac conditions. Pulmonary arterial hypertension is an important exception to casual low-acuity recovery: ESC recommends intensive-care monitoring during and after delivery because postpartum risk is particularly high.',
  'Other congenital, valvular or myocardial disease requires surveillance proportionate to severity, arrhythmias, ventricular function and the delivery course. Anticipate postpartum congestion and coordinate breastfeeding and medication planning with the specialist team.'
], [S.esc], 'Clarify PAH high-acuity recommendation without a blanket rule for all lesions.');
put(CARD, 'evidence', 'Evidence scope & specialist review', [
  'The 2025 ESC pregnancy guideline supplements the existing anesthesia reviews. Lesion-specific physiological reasoning remains important, and the strength of evidence varies by recommendation.',
  'This reference is not a patient-specific delivery plan or a universal anesthetic/vasopressor recipe. Significant disease requires Pregnancy Heart Team and obstetric-anesthesia assessment.',
  'The source update does not constitute independent cardiac-obstetric signoff. Device/valve type, severity, current physiology and maternal-fetal circumstances remain essential.'
], [S.esc, S.asra], 'Replace obsolete absence of a contemporary cardiac-pregnancy guideline.');

add('lvad-placement-left-ventricular-assist-device', 'anticoagulation', [
  'Separate CPB anticoagulation from the long-term pump antithrombotic regimen. In ARIES-HM3, aspirin avoidance with continued VKA therapy was noninferior for hemocompatibility outcomes and reduced nonsurgical bleeding in HeartMate 3 recipients.',
  'Abbott reports a 2024 HeartMate 3-specific labeling change allowing aspirin-free routine management. This is not permission to stop VKA, extrapolate to another LVAD model or discontinue aspirin for an independent indication without the treating team’s assessment.'
], [S.aries, S.abbott], 'Add HeartMate 3-specific aspirin/VKA distinction; specialist signoff retained.');
add('ecmo-cannulation-decannulation', 'anticoagulation', [
  'Do not equate ACT, aPTT and anti-Xa or escalate heparin from one discordant result alone. A 2025 VV-ECMO review describes inflammation/factor effects on aPTT and hemolysis, bilirubin or lipemia interference with chromogenic assays; review assay method and clinical context with the ECMO team/laboratory.',
  'Interpret anticoagulation alongside bleeding, platelets/fibrinogen, circuit thrombus, circuit performance and patient perfusion. No single assay predicts every bleeding or thrombotic complication; direct-thrombin-inhibitor monitoring has additional assay limitations.',
  'The review is VV-focused and is not a universal VA-ECMO target table. Anticoagulation interruption and resumption during bleeding or decannulation remain ECMO-service decisions with explicit circuit/patient thrombosis surveillance.'
], [S.ecmo], 'Add monitoring/assay safeguards without a universal ACT or anti-Xa target.');

// Correct stale evidence-absence statements only in the specifically supplemented drafts.
for (const id of [...CS, ECV, PAS, PPH, PRE]) {
  const refs = id === ECV ? [S.ecv, S.ecvAnes]
    : id === PAS ? [S.pas, S.airway, S.asra]
    : id === PPH ? [S.who, S.airway]
    : id === PRE ? [S.platelets, S.airway]
    : [S.nice, S.airway, S.who, S.morphine];
  put(id, 'evidence', 'Evidence scope & clinical-review status', [
    'The October 7 source update supplies the focused guidance linked in the revised sections. Recommendations retain their stated population, procedure and evidence scope; UK, US and international guidance is identified rather than silently treated as one local protocol.',
    'Patient-specific technique, drug selection, hemostatic treatment and disposition remain individualized. Absence of a universal regimen is not permission to invent one or a claim that essential emergency preparation is optional.',
    'This remains a clinical-review draft. Evidence reconciliation, software testing and source integration do not establish independent clinician approval or authorize release.'
  ], refs, 'Replace stale blanket missing-source notes after targeted supplementation.');
}

// Keep the explicit blocked guideline task visible without claiming new recommendations.
const gyne = records.filter(r => r.category === 'Gynecology' &&
  JSON.stringify(r).includes('2026') && JSON.stringify(r).toLowerCase().includes('eras'));
for (const r of gyne) {
  // Only add the precise hold to the framework, which anchors the specialty evidence boundary.
  if (r.id !== 'gynecology-anesthesia-framework') continue;
  put(r.id, 'eras-verification', 'Gynecologic oncology ERAS: verification still pending', [
    'A 2026 ERAS gynecologic oncology update is listed by the ERAS Society. On October 7, its publisher full text could not be verified because automated access was blocked and the browser presented a robot challenge.',
    'The existing ERAS recommendations remain attributed to the accessible 2023/earlier sources. Do not describe this specialty as reconciled with the 2026 update until the full recommendations are obtained, compared and reviewed.',
    'This evidence hold concerns the affected oncology recommendations and does not justify inventing changes from an abstract or secondary summary.'
  ], [S.eras], 'Retain explicit 2026 full-text verification hold after unsuccessful retrieval.');
}
const shoulders = ['shoulder-arthroscopy', 'shoulder-arthroplasty-total-or-reverse', 'rotator-cuff-repair-arthroscopic'];
for (const id of shoulders) {
  put(id, 'brain-level-pressure', 'Beach-chair position: pressure at the brain', [
    'When the head is above the arm cuff, arm pressure overestimates pressure at the brain. Account for the vertical hydrostatic gradient; with an arterial line, use an explicitly documented brain-level reference such as the external auditory meatus rather than silently treating heart-level MAP as brain-level MAP.',
    'Avoid deliberate hypotension for surgical visualization in the beach-chair position. The APSF safety review favors pressure close to the patient’s awake baseline, with prompt correction of hypotension and attention to oxygenation, ventilation and head position.',
    'This safety review does not establish a single validated brain-MAP threshold for every patient. Do not transplant a study-specific number or a routine supine MAP target into this setting without considering the measurement level, baseline pressure and cerebrovascular risk.'
  ], [S.beach], 'Add brain-level pressure interpretation without a universal target.');
}
for (const id of ['shoulder-arthroscopy', 'rotator-cuff-repair-arthroscopic']) {
  put(id, 'irrigation-airway', 'Irrigation extravasation & extubation reassessment', [
    'Watch for neck, face or chest swelling and changes in airway pressure or compliance during shoulder arthroscopy. Draping should permit appropriate observation of the neck and nearby chest when feasible.',
    'Examine for extravasation and airway compromise before extubation. If significant edema is present, consider continued intubation and monitored postoperative care until the airway can be managed safely; do not assume completion of surgery means the airway is ready.',
    'If the airway is not already secured, progressive neck swelling can make later intubation difficult. Escalate early when swelling or respiratory compromise develops.',
    'The systematic review is dominated by case reports and small series. Its reported resolution times, pump settings and interventions are not validated universal thresholds, and it cannot establish a routine complication rate.'
  ], [S.irrigation], 'Add explicit pre-extubation evaluation and qualified postoperative airway plan.');
}
for (const id of ['hip-fracture-repair-orif-hemiarthroplasty', 'total-hip-arthroplasty-tha']) {
  put(id, 'cement-safety', 'Cementation: team preparation & vigilance', [
    'Before femoral-canal instrumentation and cement insertion, identify heightened cardiopulmonary risk, agree team roles and ensure the surgeon’s warning is heard and acknowledged. Have vasoactive support immediately available and correct hypovolemia without indiscriminate fluid loading.',
    'The 2015 joint safety guideline for cemented hemiarthroplasty calls for close blood-pressure monitoring during and shortly after cementation, with invasive monitoring in higher-risk patients. A sudden fall in pressure or end-tidal CO₂ under GA may signal right-heart failure or a major fall in cardiac output.',
    'That guideline advises systolic pressure within 20% of the pre-induction value in its setting. This is source-specific guidance, not a universal target for all arthroplasty patients or a substitute for assessing perfusion and the patient’s baseline.',
    'New hypoxemia, hypotension or cardiovascular collapse around instrumentation, cementation or prosthesis insertion requires immediate communication, resuscitation and evaluation for BCIS and other causes. The prevention guideline is not a complete stand-alone cardiac-arrest algorithm.',
    'The guideline’s direct focus is cemented hemiarthroplasty for hip fracture. Applying its team-preparation principles to other cemented arthroplasty requires procedural and patient context; it does not choose the implant or mandate uncemented surgery.'
  ], [S.cement], 'Supplement BCIS recognition with primary safety guidance and scope.');
}
put('long-bone-orif-tibia-femur-humerus', 'compartment-surveillance', 'Lower-leg trauma: analgesia & compartment surveillance', [
  'For tibial/lower-leg injury, identify acute compartment syndrome risk and agree a multidisciplinary surveillance and escalation plan. Observations should occur at defined intervals by trained staff, with equipment and a pathway for compartment-pressure measurement when indicated.',
  'Offer effective analgesia; regional analgesia is not universally prohibited. The 2021 guideline advises avoiding dense regional blocks whose duration substantially exceeds surgery and describes lower-concentration peripheral blocks without adjuncts as an option only with appropriate, effective surveillance.',
  'Increasing pain or pain on passive stretch can be concerning, but severe pain is not always present. Do not wait for pulselessness or paralysis, which are late signs, or use apparent comfort under a block to exclude compartment syndrome.',
  'When the examination is unreliable or the diagnosis remains uncertain, obtain urgent surgical assessment and use compartment-pressure measurement as appropriate. No single sign or test guarantees exclusion.',
  'The guideline is specifically about lower-leg trauma and rests largely on limited observational evidence and consensus. It does not validate a universal block regimen for humeral or femoral fractures; local surveillance capability and the actual injury matter.'
], [S.compartment], 'Add lower-leg-specific regional and compartment-syndrome safeguards.');
for (const id of ['hip-fracture-repair-orif-hemiarthroplasty', 'total-hip-arthroplasty-tha', 'total-knee-arthroplasty-tka']) {
  put(id, 'antithrombotic-coordination', 'Neuraxial/deep-block & thromboprophylaxis coordination', [
    'Before neuraxial or deep plexus/peripheral procedures, identify the exact anticoagulant or antiplatelet drug, dose, last administration, renal function and additional bleeding risks. Use current ASRA drug-specific guidance rather than a single interval for every agent.',
    'Coordinate catheter removal and the first postoperative anticoagulant dose before handoff. Surgical hemostasis, dose intensity and neuraxial timing all matter; catheter removal is itself a bleeding-risk event.',
    'Do not stop clinically indicated antithrombotic treatment independently or delay urgent surgery solely to obtain a preferred anesthetic technique. Discuss feasible anesthetic alternatives and the bleeding/thrombosis tradeoff with the treating team.'
  ], [S.asra], 'Add current antithrombotic placement/removal/restart reference without a universal table.');
}
const orthoIds = [...new Set([...shoulders, 'hip-fracture-repair-orif-hemiarthroplasty', 'total-hip-arthroplasty-tha', 'long-bone-orif-tibia-femur-humerus', 'total-knee-arthroplasty-tka'])];
for (const id of orthoIds) {
  const r = c(id);
  const prior = r.sections.find(s => s.id === 'evidence');
  const supplements = r.sections.filter(s => ['brain-level-pressure','irrigation-airway','cement-safety','compartment-surveillance','antithrombotic-coordination'].includes(s.id));
  put(id, 'evidence', 'Evidence scope & focused safety supplementation', [
    'The October 7 update supplements this draft with the focused safety references linked in the new sections. These address selected historical review gaps, not every aspect of perioperative care.',
    'Existing procedure reviews remain limited by their study populations, study designs and variable evidence quality. A preference reported in a review is not a mandate for one airway device, anesthetic technique, block or recovery pathway.',
    'Keep source-specific populations distinct: lower-leg compartment guidance is not a universal all-fracture protocol; cemented hemiarthroplasty guidance is not a universal implant-selection rule; a beach-chair safety review does not establish one blood-pressure target for every patient.',
    'Patient-specific decisions, the remaining historical review questions and independent clinical signoff remain open. No universal drug, fluid, transfusion or disposition recipe has been inferred from missing procedure-specific evidence.'
  ], [...new Map([...prior.sources, ...supplements.flatMap(s => s.sources)].map(s => [s.url,s])).values()], 'Reconcile evidence notes with focused supplementation; do not claim full case approval.');
}
put(CARD, 'uterotonic-cautions', 'Uterotonics: cardiac lesion & hemorrhage context', [
  'Agree the hemorrhage and uterotonic plan before delivery. The 2025 ESC guideline generally favors oxytocin first-line, including higher-risk cardiac disease, but the agent, administration rate and hemodynamic response still require lesion-specific assessment.',
  'The cardiac-anesthesia review advises titrating oxytocin by infusion pump because a rapid bolus can reduce SVR. Avoid replacing this with a generic scheduled-cesarean regimen when abrupt vasodilation is poorly tolerated.',
  'Carboprost can increase pulmonary vascular resistance and provoke bronchospasm; the anesthesia review describes relative contraindications in pulmonary hypertension, right-heart compromise and preexisting asthma. A broad second-line listing in a guideline is not blanket clearance for these patients.',
  'Methylergonovine can raise SVR and blood pressure and cause coronary vasospasm; the anesthesia review describes relative contraindications in hypertension, preeclampsia, aneurysms and coronary disease. Coordinate alternatives and hemorrhage escalation rather than treating it as interchangeable with oxytocin.',
  'Misoprostol is among ESC’s second-line options in high-risk cardiac disease, but no uterotonic is a substitute for prompt recognition and control of hemorrhage. Specialist review should reconcile the regimen with the specific lesion and local obstetric pathway.'
], [S.esc, S.cardiacAnes], 'Add lesion-specific uterotonic cautions and reconcile broad versus specialist source scope.');
const pasProcedure = c(PAS).sections.find(s => s.id === 'procedure');
put(PAS, 'procedure', pasProcedure.title, [
  pasProcedure.bullets[0],
  'Plan delivery timing with the PAS multidisciplinary team using maternal symptoms, bleeding, placental findings, preterm-birth risk and applicable current guidance. The earlier cited 34+0–35+6-week window is not a universal rule for every stable patient; do not delay indicated urgent delivery to reach a planned gestation.',
  pasProcedure.bullets[2],
], [...pasProcedure.sources, S.pas], 'Remove generalized delivery-window wording while preserving the need for individualized PAS planning.');
put(PAS, 'timing-source-hold', 'Planned-delivery timing: source discrepancy', [
  'The accessed 2026 RCOG full text is internally inconsistent for high-probability PAS without preterm-birth risk factors or antenatal bleeding: its key recommendations state 36+1–37+0 weeks, while section 10.2 states 35+0–36+6 weeks.',
  'The same section discusses an ACOG 34+0–35+6-week approach when significant blood loss and cesarean hysterectomy are anticipated. These statements must not be merged into one supposedly universal recommendation.',
  'Confirm the authoritative recommendation and any correction with the obstetric/PAS service before approving a new timing instruction. This discrepancy is an explicit review hold on timing, not evidence to postpone care in a patient with bleeding, labor or another urgent indication.'
], [S.pas], 'Record verified RCOG summary/table timing discrepancy as unresolved rather than choosing a range.');
const changed = records.filter((r,i) => hash(r) !== hash(original[i]));
assert.equal(changed.length, 19);
for (const r of changed) {
  const before = original.find(x => x.id === r.id);
  const now = current.find(x => x.id === r.id);
  const prior = priorLedger?.records.find(x => x.id === r.id);
  if (prior) {
    assert.equal(hash(prior.before), hash(before), `Invalid prior baseline: ${r.id}`);
    assert.equal(hash(prior.after), prior.afterHash, `Invalid prior ledger: ${r.id}`);
  }
  assert(hash(now) === hash(before) || hash(now) === hash(r) || (prior && hash(now) === prior.afterHash), `Concurrent edit: ${r.id}`);
  assert.equal(r.clinicalStatus, 'draft');
}
for (const r of current) {
  if (!reasons.has(r.id)) assert.equal(hash(r), hash(original.find(x => x.id === r.id)), `Untargeted concurrent edit: ${r.id}`);
}
assert.equal(records.length, 350);
assert.equal(new Set(records.map(r => r.id)).size, 350);
const ledger = {baseline, date:'2026-10-07', status:'evidence-updated; clinician signoff pending',
  records: changed.map(after => {
    const before = original.find(x => x.id === after.id);
    return {id:after.id, beforeHash:hash(before), afterHash:hash(after), reasons:reasons.get(after.id), before, after};
  })};
fs.mkdirSync('docs/surgical-review-2026-10-07', {recursive:true});
fs.writeFileSync('docs/surgical-review-2026-10-07/correction-ledger.json', JSON.stringify(ledger, null, 2));
fs.writeFileSync(file, JSON.stringify(records));
const indexFile = 'lib/surgical_prep/surgical_index.dart';
const oldIndex = fs.readFileSync(indexFile, 'utf8');
const manualTail = oldIndex.slice(oldIndex.lastIndexOf('  SurgicalCaseIndex('));
assert(manualTail.includes("'laparoscopic-cholecystectomy'"));
const clean = s => s.normalize('NFKC').toLowerCase().replace(/[^a-z0-9\s]/g, '').replace(/\s+/g, ' ').trim();
const dart = s => JSON.stringify(s).replaceAll('$', '\\$');
let output = "// Generated from the staged clinical catalog; do not edit manually.\npart of 'surgical_catalog.dart';\n\nconst surgicalIndex = <SurgicalCaseIndex>[\n";
for (const r of records) {
  const text = [...new Set(clean([r.title,r.category,...r.aliases,...r.overview.bullets,...r.sections.flatMap(s=>[s.title,...s.bullets])].join(' ')).split(' '))].join(' ');
  output += `  SurgicalCaseIndex(${dart(r.id)}, ${dart(r.title)}, ${dart(r.category)}, ${dart(r.aliases.join(' '))}, ${dart(text)}),\n`;
}
fs.writeFileSync(indexFile, output + manualTail);
let review = '# Surgical Case Prep: Clinical Corrections and Updated Drafts\n\nOctober 7, 2026. Evidence-supported draft changes; clinician signoff and release authorization remain pending. Previous wording is retained in the machine-readable correction ledger, not repeated as clinical instructions.\n\n';
for (const row of ledger.records) {
  review += `## ${row.after.title}\n\n${row.reasons.map(x=>`- ${x}`).join('\n')}\n\n`;
  const old = new Map([row.before.overview,...row.before.sections].map(s=>[s.id,hash(s)]));
  for (const section of [row.after.overview,...row.after.sections]) {
    if (old.get(section.id) === hash(section)) continue;
    const citations = section.sources.map(s=>`[${s.label}](${s.url})`).join('; ');
    review += `### ${section.title}\n\n${section.bullets.map(b=>`- ${b} (${citations})`).join('\n\n')}\n\n`;
  }
}
fs.writeFileSync('docs/surgical-review-2026-10-07/UPDATED-DRAFTS.md', review);
console.log(JSON.stringify({changed:changed.map(r=>r.id), count:changed.length, total:records.length+1, releaseEnabled:false},null,2));
