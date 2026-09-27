// Convert the owner-approved guide into server-only sections. No DB writes.
// Usage: node tool/prepare_cied_quick_reference_seed.mjs /path/to/approved.md
import fs from 'node:fs';
import assert from 'node:assert/strict';

const source = fs.readFileSync(process.argv[2], 'utf8');
const definitions = [
  ['critical', 'Critical distinctions', ['magnet', 'asynchronous', 'pacing dependent', 'Micra', 'reactivation']],
  ['decision', 'Quick decision table', ['magnet', 'reprogramming', 'pacing dependent', 'EMI', 'above umbilicus', 'below umbilicus', 'no EMI']],
  ['identify', 'Identify the device', ['identification', 'implant card', 'chest x ray', 'radiography', 'leadless', 'S-ICD', 'EV-ICD']],
  ['preop', 'Pre-op assessment and device-team plan', ['preop', 'interrogation', 'remote report', 'battery', 'pacing dependence', 'syncope', 'device plan']],
  ['pacemaker-magnet', 'Pacemaker magnet protocol', ['magnet', 'asynchronous', 'AOO', 'VOO', 'DOO', 'magnet rate', 'Medtronic', 'Abbott', 'Boston Scientific', 'Biotronik', 'Edora', 'MicroPort', 'Sorin', 'St Jude', 'ERI', 'RRT']],
  ['icd-magnet', 'ICD/AICD and CRT-D magnet protocol', ['magnet', 'inhibit therapy', 'ATP', 'shocks', 'tachyarrhythmia', 'prone', 'lateral', 'external pads', 'Boston Scientific']],
  ['exceptions', 'Magnet exceptions that change the plan', ['magnet', 'magnet not working', 'magnet response off', 'leadless', 'Micra', 'AVEIR', 'Biotronik', 'Medtronic', 'Abbott', 'Boston Scientific', 'St Jude', 'MicroPort', 'Sorin', 'S-ICD', 'MRI SureScan', 'telemetry', '10 beats', '8 hours', 'interrogation delay']],
  ['electrocautery', 'Electrocautery and EMI precautions', ['bipolar', 'monopolar', 'cautery', 'electrocautery', 'electrosurgery', 'Bovie', 'ultrasonic', 'EMI', 'electromagnetic interference', 'return electrode', 'return pad', 'grounding pad', 'dispersive pad', 'below umbilicus', 'abdominal generator', 'whole body electrode', 'RF ablation', 'argon plasma']],
  ['intraop', 'Intraoperative monitoring and troubleshooting', ['monitoring', 'ECG', 'pulse', 'capture', 'pacing inhibition', 'bradycardia', 'external pacing', 'inappropriate shock', 'repeated shocks', 'VT', 'VF', 'cardiac arrest', 'defibrillation', 'cardioversion', 'pad position']],
  ['external-defibrillation', 'External Defibrillation & Cardioversion', ['external shock', 'shocks', 'shock pacemaker', 'defibrillate AICD', 'defibrillation', 'cardioversion ICD', 'synchronized', 'unsynchronized', 'pad placement', 'pad position', 'pads over pacemaker', 'anterior posterior', 'anteroposterior', 'anterior lateral', 'anterolateral', '8 cm', 'energy', 'joules', 'VF', 'pulseless VT', 'unstable tachycardia', 'cardiac arrest', 'magnet removal', 'disabled therapy', 'post shock', 'interrogation', 'S-ICD']],
  ['postop', 'Post-op restoration and handoff', ['postop', 'PACU', 'reactivation', 'restore settings', 'interrogation', 'handoff', 'discharge', 'follow up']],
  ['urgent', 'Urgent case with incomplete device information', ['emergency', 'urgent', 'unknown device', 'missing records', 'interrogation', 'external pacing', 'defibrillation']],
];
const chunks = source.split(/^## /m).slice(1);
const bodies = new Map(chunks.map(chunk => {
  const at = chunk.indexOf('\n');
  return [chunk.slice(0, at).trim(), chunk.slice(at + 1).trim()];
}));
const externalTitle = 'External Defibrillation & Cardioversion';
bodies.set(externalTitle, fs.readFileSync(
  new URL('../supabase/seeds/cied_external_defibrillation.md', import.meta.url),
  'utf8',
).replace(/^# .*\n+/, '').trim());
for (const title of ['ICD/AICD and CRT-D magnet protocol', 'Intraoperative monitoring and troubleshooting']) {
  bodies.set(title, `${bodies.get(title)}\n\nRelated section: **${externalTitle}** in this guide covers emergency shocks, pad placement, and post-shock device checks.`);
}
const deviceAliases = ['AICD', 'ICD', 'implantable defibrillator', 'pacemaker', 'PPM', 'CIED', 'CRT', 'CRT-P', 'CRT-D', 'biventricular', 'BiV'];
const scope = 'Adult perioperative clinical reference. Individualize with the anesthesia/CIED team, exact-model instructions, and institutional policy; not a patient-specific device prescription.';
const rows = definitions.map(([slug, title, keywords], index) => {
  const approvedBody = bodies.get(title);
  assert.ok(approvedBody, `Missing approved section: ${title}`);
  assert.ok(approvedBody.includes('https://'), `Missing sources: ${title}`);
  return {
    id: `cied-${slug}`, reference_id: 'aicds-pacemakers',
    reference_title: 'AICDs & Pacemakers', title,
    keywords: [...deviceAliases, ...keywords], sort_order: index,
    is_published: true, body: `${scope}\n\n${approvedBody}`,
    version: '2026-09-27',
  };
});
const quote = value => `'${value.replaceAll("'", "''")}'`;
let sql = '-- Owner-approved AICDs & Pacemakers; atomic, idempotent content publication.\nbegin;\n\n';
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
fs.writeFileSync('supabase/seeds/cied_quick_reference.sql', sql);
// Public metadata only, used by regression tests. No protected bodies in assets.
fs.writeFileSync('supabase/seeds/cied_catalog.json',
  JSON.stringify(rows.map(({body, version, ...metadata}) => metadata), null, 2) + '\n');
console.log(`Prepared ${rows.length} sourced sections. No database changes made.`);
