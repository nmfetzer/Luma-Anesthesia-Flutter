// Mechanical conversion of the owner-approved Markdown into server-only content.
// Usage: node tool/prepare_quick_reference_seed.mjs /absolute/path/to/approved.md
// This does not publish content or change the database.
import fs from 'node:fs';
import path from 'node:path';
import {finalizeRows} from './quick_reference_release.mjs';

const source = fs.readFileSync(process.argv[2] ?? 'supabase/seeds/preop_quick_reference.md', 'utf8');
const definitions = [
  ['clearance-visit', 'When a separate medical clearance visit may not be needed',
    'When a separate clearance visit may not be needed',
    ['no clearance', 'no medical clearance', 'low risk', 'cataract', 'healthy', 'local anesthesia', 'age', 'PCP', 'consultation']],
  ['proceed-defer', 'At a glance: proceed, evaluate, or defer',
    'At a glance: proceed, evaluate, or defer',
    ['cancel', 'postpone', 'active cardiac condition', 'ACS', 'heart failure', 'unstable arrhythmia']],
  ['urgency', 'Establish surgical urgency', 'Surgical urgency',
    ['emergency', 'urgent', 'elective', 'time sensitive']],
  ['risk', 'Identify symptoms and estimate risk', 'Symptoms, risk & functional capacity',
    ['METs', 'DASI', 'RCRI', 'MICA', 'NSQIP', 'frailty', 'chest pain', 'dyspnea', 'syncope']],
  ['testing', 'Decide whether testing is indicated', 'ECG, echo, biomarkers & stress testing',
    ['EKG', 'ECG', 'echocardiography', 'troponin', 'BNP', 'NT-proBNP', 'CCTA', 'stress test', 'revascularization']],
  ['pci-stroke', 'Check timing after PCI or stroke', 'Timing after PCI, stents, stroke or TIA',
    ['DES', 'BMS', 'balloon angioplasty', 'stent', 'stroke', 'TIA', 'PCI', 'antiplatelet']],
  ['cardiac-conditions', 'Address valve disease and other high-risk conditions',
    'Valve disease & high-risk cardiac conditions',
    ['aortic stenosis', 'mitral stenosis', 'regurgitation', 'pulmonary hypertension', 'HCM', 'HFrEF', 'heart failure', 'LVAD', 'pacemaker', 'ICD', 'AICD', 'CIED']],
  ['medications', 'Review blood pressure and medications', 'Blood pressure & perioperative medications',
    ['hypertension', 'beta blockers', 'statins', 'ACE inhibitors', 'ARB', 'RAAS', 'SGLT2', 'canagliflozin', 'dapagliflozin', 'empagliflozin', 'ertugliflozin', 'clonidine']],
  ['glp1', 'GLP-1 / dual GIP–GLP-1 medications: aspiration-risk assessment',
    'GLP-1 / GIP–GLP-1: aspiration risk & fasting',
    ['GLP1', 'GLP-1', 'GLP 1', 'GIP', 'semaglutide', 'tirzepatide', 'liraglutide', 'dulaglutide', 'Ozempic', 'Wegovy', 'Rybelsus', 'Mounjaro', 'Zepbound', 'Saxenda', 'Victoza', 'Trulicity', 'SPAQI', 'fasting', 'NPO', 'gastric ultrasound', 'aspiration', 'full stomach']],
  ['antithrombotics', 'Confirm the antithrombotic plan', 'Antiplatelets & anticoagulant planning',
    ['aspirin', 'clopidogrel', 'prasugrel', 'ticagrelor', 'warfarin', 'DOAC', 'DAPT', 'bridging', 'neuraxial', 'anticoagulation']],
  ['other-readiness', 'Other preoperative items covered in this guideline', 'Diabetes, OSA & anemia',
    ['HbA1c', 'A1c', 'metformin', 'glucose', 'sleep apnea', 'iron', 'hemoglobin', 'diabetes', 'OSA', 'anemia']],
  ['documentation', 'Proposed app closing block', 'Document the perioperative plan',
    ['documentation', 'disposition', 'communication', 'consent', 'device plan']],
];
const chunks = source.split(/^## /m).slice(1);
const bodies = new Map(chunks.map(chunk => {
  const at = chunk.indexOf('\n');
  return [chunk.slice(0, at).trim(), chunk.slice(at + 1).trim()];
}));
const rows = definitions.map(([slug, heading, title, keywords], index) => {
  let body = bodies.get(heading);
  if (!body) throw new Error(`Missing approved section: ${heading}`);
  body = body.replace('### Proposed app takeaway', '### Clinical takeaway')
    .replace('Editorial note:', 'Scope note:')
    .replace('Proposed app banner:', 'Safety reminder:')
    .replace('### Urgent/emergency procedures and app safety wording', '### Urgent/emergency procedures')
    .replace('These are proposed documentation prompts, not a validated clearance score. The reference would end with the following concise bullets:',
      'Documentation prompts, not a validated clearance score:');
  return {
    id: `preop-${slug}`, reference_id: 'pre-op-clearance-guidelines',
    reference_title: 'Pre-Op Clearance Guidelines', title, keywords,
    sort_order: index, is_published: true, body, version: '2026-09-27',
  };
});
finalizeRows(rows);
export {rows};
const quote = value => `'${value.replaceAll("'", "''")}'`;
let sql = 'begin;\n\n';
for (const row of rows) {
  sql += `insert into public.quick_reference_catalog
  (id,reference_id,reference_title,title,keywords,sort_order,is_published)
values (${quote(row.id)},${quote(row.reference_id)},${quote(row.reference_title)},
  ${quote(row.title)},array[${row.keywords.map(quote).join(',')}],${row.sort_order},true)
on conflict (id) do update set reference_id=excluded.reference_id,
  reference_title=excluded.reference_title,title=excluded.title,keywords=excluded.keywords,
  sort_order=excluded.sort_order,is_published=excluded.is_published;
insert into public.quick_reference_sections (id,body,version)
values (${quote(row.id)},${quote(row.body)},${quote(row.version)})
on conflict (id) do update set body=excluded.body,version=excluded.version,updated_at=now();\n\n`;
}
sql += 'commit;\n';
fs.mkdirSync('supabase/seeds', {recursive: true});
fs.writeFileSync(path.join('supabase/seeds', 'preop_quick_reference.sql'), sql);
console.log(`Prepared ${rows.length} sections; clinical bodies remain outside Flutter assets.`);
