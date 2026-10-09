// Scoped source reconciliation. Does not approve clinical content or publish it.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {createHash} from 'node:crypto';
const baseline = 'a257f5e6ab164552c56285052ec8b38a063d763f';
const file = 'assets/data/surgical_cases.json';
const dir = 'docs/surgical-testflight-2026-10-08';
const hash = x => createHash('sha256').update(JSON.stringify(x)).digest('hex');
const original = JSON.parse(execFileSync('git', ['show', `${baseline}:${file}`], {maxBuffer: 30_000_000}));
const current = JSON.parse(fs.readFileSync(file));
const records = structuredClone(original);
const source = (label, url) => ({label, url});
const S = {
  eras: source('ERAS Society gynecologic oncology guideline: 2026 full-text update', 'https://www.gynecologiconcology-online.net/article/S0090-8258(26)01999-2/fulltext'),
  glp: source('ASA multisociety GLP-1 guidance: individualized aspiration-risk assessment', 'https://www.asahq.org/about-asa/newsroom/news-releases/2024/10/new-multi-society-glp-1-guidance'),
  asra: source('ASRA antithrombotic guideline, fifth edition (2025)', 'https://rapm.bmj.com/content/early/2025/01/21/rapm-2024-105766'),
  acog: source('ACOG/SMFM Obstetric Care Consensus: Placenta Accreta Spectrum', 'https://www.acog.org/clinical/clinical-guidance/obstetric-care-consensus/articles/2018/12/placenta-accreta-spectrum'),
  rcog: source('RCOG Green-top 27a (2026): PAS timing discrepancy retained for review', 'https://pmc.ncbi.nlm.nih.gov/articles/PMC13485456/'),
  aries: source('ARIES-HM3 randomized trial: aspirin avoidance with continued VKA', 'https://pubmed.ncbi.nlm.nih.gov/37950897/'),
  ecmo: source('VV-ECMO anticoagulation and assay limitations (2025 review)', 'https://www.frontiersin.org/journals/medicine/articles/10.3389/fmed.2025.1530411/full'),
  esc: source('ESC cardiovascular disease and pregnancy guideline (2025)', 'https://academic.oup.com/eurheartj/article/46/43/4462/8234487?login=false'),
};
const reasons = new Map();
const get = id => {const r = records.find(r => r.id === id); assert(r, id); return r;};
function change(id, why) {
  get(id).sourceChecked = '2026-10-08';
  reasons.set(id, [...new Set([...(reasons.get(id) || []), why])]);
}
function put(id, sid, title, bullets, sources) {
  const r = get(id), s = {id: sid, title, bullets, sources};
  const i = r.sections.findIndex(s => s.id === sid);
  if (i >= 0) r.sections[i] = s;
  else r.sections.splice(r.sections.findIndex(s => s.id === 'evidence'), 0, s);
}
function add(id, sid, bullets, sources) {
  const s = get(id).sections.find(s => s.id === sid); assert(s, `${id}:${sid}`);
  put(id, sid, s.title, [...s.bullets, ...bullets],
    [...new Map([...s.sources, ...sources].map(s => [s.url, s])).values()]);
}
const oncology = [
  'gynecology-anesthesia-framework',
  'gynecologic-oncology-staging-laparotomy',
  'ovarian-cancer-debulking-cytoreductive-surgery',
  'radical-hysterectomy',
  'pelvic-exenteration',
];
for (const id of oncology) {
  change(id, 'Reconcile anesthesia-facing recommendations against the accessible 2026 ERAS full text, with separate GLP-1 and neuraxial safety qualifications.');
  add(id, 'preop', [
    'For elective gynecologic oncology surgery, identify and treat the cause of preoperative anemia, including iron deficiency. The 2026 ERAS update supports preoperative optimization; the route of iron replacement depends on severity and time available rather than a universal regimen.',
    'Apply a procedure- and aspiration-risk-specific fasting plan. The ERAS oncology pathway permits clear fluids until two hours before anesthesia and supports preoperative carbohydrate drinks; this is not clearance for a patient with obstruction, delayed gastric emptying, active vomiting or emergency surgery. Carbohydrate loading in well-controlled type 2 diabetes is a cautious, weak recommendation, not a routine instruction for all diabetes.',
  ], [S.eras, S.glp]);
  add(id, 'fluids', [
    'The 2026 ERAS guideline supports goal-directed fluid therapy for major gynecologic oncology surgery. Use an individualized hemodynamic assessment; it does not establish one universal monitor, fluid volume or vasoactive algorithm.',
  ], [S.eras]);
  add(id, 'pain', [
    'For gynecologic oncology surgery, the 2026 ERAS recommendation is multimodal PONV prophylaxis with more than two antiemetic agents. Choose different classes with attention to contraindications and adverse effects rather than copying a fixed drug combination to every gynecologic procedure.',
    'The updated oncology pathway supports multimodal analgesia, incisional local anesthetic or selected fascial-plane blocks, and intrathecal analgesia when appropriate. It does not make epidural analgesia mandatory; consider surgical extent, hemodynamics, anticoagulation, renal function and local expertise.',
  ], [S.eras, S.asra]);
  put(id, 'vte', 'VTE prevention & postoperative recovery', [
    'Assess cancer, prior VTE, obesity, immobility and bleeding risk. Coordinate mechanical and pharmacologic prophylaxis with surgical hemostasis, renal function, drug interactions and neuraxial placement/removal; surgery timing does not override anticoagulant safety intervals.',
    'For cancer laparotomy, the 2026 ERAS update recommends combined mechanical and pharmacologic prophylaxis and 28-day postoperative prophylaxis with LMWH or an appropriate DOAC. Drug choice requires an individualized bleeding, renal-function, interaction and adherence assessment; this is not a universal drug or dose prescription.',
    'Do not automatically extend that 28-day regimen to minimally invasive surgery or minor benign procedures. The 2026 guideline favors mechanical prophylaxis for MIS and considers pharmacologic prophylaxis for high-risk patients, including a high Caprini score; follow the applicable oncology risk assessment.',
    'The ERAS recommendation to initiate surgical prophylaxis preoperatively within two hours of incision is not permission to give LMWH immediately before neuraxial placement. ASRA recommends at least 12 hours after low-dose LMWH before needle placement; higher-dose regimens and renal impairment need their own assessment.',
    'For twice-daily low-dose postoperative LMWH, ASRA requires the first dose the following day and at least 12 hours after needle/catheter placement, catheter removal before LMWH begins, and at least four hours from removal to LMWH. Use the full guideline for other regimens, traumatic placement and concurrent anticoagulants.',
    'Support mobilization and oral nutrition within 24 hours when clinically appropriate. The ERAS regular-diet recommendation includes bowel resection, but instability, ileus, aspiration risk or specific reconstruction concerns require individualized surgical review, particularly after extensive exenteration.',
  ], [S.eras, S.asra]);
  put(id, 'glp1-guidance', 'GLP-1 therapy: reconcile differing guidance', [
    'The 2026 gynecologic oncology ERAS table recommends holding daily GLP-1 therapy on the procedure day and weekly therapy for one week, with resumption on postoperative day one. This differs from the ASA-endorsed multisociety approach allowing continuation for most low-risk patients.',
    'Do not translate either statement into an automatic patient instruction. Agree on a plan with anesthesia, the prescriber and surgery, considering dose escalation, gastrointestinal symptoms, other causes of delayed emptying, glycemic effects and the current institutional pathway.',
    'For higher-risk patients the multisociety approach includes a liquid-only diet for 24 hours, adjustment of the anesthesia plan, and gastric ultrasound when appropriate expertise is available. Persistent concern may require delay of elective surgery; a medication hold or standard fasting interval does not prove an empty stomach.',
    'Postoperative resumption also requires assessment of oral intake, nausea/vomiting, gastrointestinal function and the prescribing plan rather than an unconditional postoperative-day-one restart.',
  ], [S.eras, S.glp]);
  const e = get(id).sections.find(s => s.id === 'evidence');
  e.bullets = e.bullets.filter(b => !/2026.*not accessible|full recommendations were not accessible/.test(b));
  e.bullets.push('The anesthesia-facing ERAS content was reconciled against the 2026 full text on October 8, 2026. Oncology recommendations are scoped to the relevant operation; the GLP-1 guidance difference and independent clinical review remain explicit. This is not specialist approval or a complete institutional ERAS order set.');
  e.sources = [...new Map([...e.sources, S.eras, S.glp, S.asra].map(s => [s.url, s])).values()];
  get(id).reviewNotice = 'Final clinician review: updated 2026 oncology ERAS content. Confirm the GLP-1 plan and anticoagulant/neuraxial coordination; no automatic medication orders.';
}
put(oncology[0], 'eras-verification', '2026 ERAS source reconciliation', [
  'The publisher full text of the 2026 ERAS gynecologic oncology update was obtained and its anesthesia-facing recommendations reviewed on October 8, 2026. The prior full-text access hold is closed.',
  'Updated topics include preoperative anemia, carbohydrate-loading scope, goal-directed fluids, multimodal analgesia/PONV, cancer-laparotomy versus MIS prophylaxis, and early recovery. Recommendations for oncology surgery must not be generalized to every benign or emergency gynecologic procedure.',
  'The guideline’s GLP-1 hold/restart table differs from ASA-endorsed multisociety risk-based guidance. Both are identified in the GLP-1 section; clinicians must resolve the applicable plan rather than infer universal agreement.',
], [S.eras, S.glp, S.asra]);
const pas = 'placenta-accreta-spectrum-pas-cesarean-hysterectomy';
change(pas, 'Restore a directly verified, explicitly attributed ACOG/SMFM timing recommendation without claiming the RCOG discrepancy is resolved.');
put(pas, 'timing-source-hold', 'Delivery timing: attributed guidance & unresolved RCOG discrepancy', [
  'ACOG/SMFM Obstetric Care Consensus suggests scheduled cesarean delivery or hysterectomy at 34+0–35+6 weeks for a stable patient with PAS, absent extenuating circumstances. This is a source-specific recommendation, not a universal window replacing the PAS team’s plan.',
  'Earlier delivery may be required for persistent bleeding, preeclampsia, labor, membrane rupture, fetal compromise or developing maternal comorbidity. ACOG advises against routinely waiting beyond 36+0 weeks; do not postpone indicated delivery to reach a scheduled gestation.',
  'The accessed 2026 RCOG full text remains internally inconsistent: key recommendations state 36+1–37+0 weeks in the absence of preterm-birth risk factors or antenatal bleeding, while section 10.2 states 35+0–36+6 weeks for that stated subgroup. No authoritative correction was verified on October 8, 2026.',
  'Do not average these windows or silently choose a new RCOG instruction. Confirm timing with the maternal-fetal medicine/PAS service and applicable local guidance. Plan delivery in a specialist setting with experienced multidisciplinary staff and blood-bank support; maternal or fetal instability takes priority.',
], [S.acog, S.rcog]);
get(pas).reviewNotice = 'PAS timing needs clinician review: ACOG/SMFM guidance is explicitly attributed; the RCOG 2026 internal discrepancy remains unresolved. Do not use this reference alone to schedule delivery.';
const specialist = [
  ['lvad-placement-left-ventricular-assist-device', 'LVAD/cardiac anesthesia', S.aries,
    'The ARIES-HM3 evidence concerns HeartMate 3 recipients receiving VKA therapy. It supports aspirin avoidance in the studied context, not stopping VKA, changing another device’s regimen or overriding an independent antiplatelet indication.'],
  ['ecmo-cannulation-decannulation', 'ECMO/perfusion', S.ecmo,
    'The cited anticoagulation review focuses on VV-ECMO and discusses assay interference and heterogeneous evidence. It does not establish one universal anticoagulation target across VV/VA configurations, bleeding states and circuit types.'],
  ['high-risk-obstetric-anesthesia-cardiac-disease-in-pregnancy', 'cardiac-obstetric anesthesia', S.esc,
    'The ESC guideline supports Pregnancy Heart Team care and lesion-specific planning. Its intensive-care recommendation during and after delivery for PAH must not be generalized to every cardiac diagnosis.'],
];
for (const [id, team, src, bullet] of specialist) {
  change(id, 'Recheck the cited evidence scope and make pending independent specialist approval prominent in the reader.');
  const evidence = get(id).sections.find(s => s.id === 'evidence');
  put(id, 'evidence', 'Evidence scope & pending specialist review',
    [...evidence.bullets, bullet, `Independent ${team} clinical signoff has not been recorded. This reference is available for review only; device/lesion-specific management and institutional rescue protocols require specialist assessment.`],
    // Replace inherited generic thoracic/OLV citations with case-relevant sources.
    [...new Map([src, ...get(id).sections.filter(s => ['anticoagulation', 'lesion-specific'].includes(s.id)).flatMap(s => s.sources)].map(s => [s.url, s])).values()]);
  get(id).reviewNotice = `Specialist signoff pending: ${team}. Source checks are complete for the identified evidence issue, but do not establish independent clinical approval or a patient-specific protocol.`;
}
assert.equal(records.length, 350);
for (let i = 0; i < records.length; i++) {
  assert.equal(current[i].id, original[i].id);
  assert([hash(original[i]), hash(records[i])].includes(hash(current[i])), `Concurrent change: ${current[i].id}`);
  assert.equal(records[i].clinicalStatus, 'draft');
}
const changed = records.filter((r, i) => hash(r) !== hash(original[i]));
const ledger = {date: '2026-10-08', baseline, clinicalApproval: false, nativeUpload: false,
  records: changed.map(after => {
    const before = original.find(r => r.id === after.id);
    return {id: after.id, beforeHash: hash(before), afterHash: hash(after), reasons: reasons.get(after.id), before, after};
  })};
fs.mkdirSync(dir, {recursive: true});
fs.writeFileSync(`${dir}/correction-ledger.json`, JSON.stringify(ledger, null, 2));
fs.writeFileSync(file, JSON.stringify(records));
const indexFile = 'lib/surgical_prep/surgical_index.dart';
const oldIndex = fs.readFileSync(indexFile, 'utf8');
const tail = oldIndex.slice(oldIndex.lastIndexOf('  SurgicalCaseIndex('));
assert(tail.includes("'laparoscopic-cholecystectomy'"));
const clean = s => s.normalize('NFKC').toLowerCase().replace(/[^a-z0-9\s]/g, '').replace(/\s+/g, ' ').trim();
const dart = s => JSON.stringify(s).replaceAll('$', '\\$');
let output = "// Generated from the staged clinical catalog; do not edit manually.\npart of 'surgical_catalog.dart';\n\nconst surgicalIndex = <SurgicalCaseIndex>[\n";
for (const r of records) {
  const text = [...new Set(clean([r.title, r.category, ...r.aliases, ...r.overview.bullets, ...r.sections.flatMap(s => [s.title, ...s.bullets])].join(' ')).split(' '))].join(' ');
  output += `  SurgicalCaseIndex(${dart(r.id)}, ${dart(r.title)}, ${dart(r.category)}, ${dart(r.aliases.join(' '))}, ${dart(text)}),\n`;
}
fs.writeFileSync(indexFile, output + tail);
console.log(`Updated ${changed.length} records. All 351 references retained; no clinical approval or native upload.`);
