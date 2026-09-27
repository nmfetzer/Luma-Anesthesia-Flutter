// Generate server-only clinical bodies and public searchable metadata; no DB writes.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {finalizeRows} from './quick_reference_release.mjs';

const source = fs.readFileSync('supabase/seeds/beta_blocker_quick_reference.md', 'utf8');
const definitions = [
  ['bolus', 'IV bolus chart', ['bolus', 'push', 'esmolol', 'Brevibloc', 'metoprolol', 'tartrate', 'Lopressor', 'labetalol', 'Trandate', 'Normodyne', 'propranolol', 'Inderal', 'AF', 'AFib', 'RVR', 'rate control', 'hypertension', 'tachycardia']],
  ['infusion', 'IV infusion chart', ['infusion', 'drip', 'esmolol', 'Brevibloc', 'labetalol', 'Trandate', 'Normodyne', 'landiolol', 'Rapiblyk', 'SVT', 'AF', 'AFib', 'RVR', 'flutter', 'rate control', 'titration', 'maximum', 'impaired cardiac function', 'pulmonary hypertension', 'verapamil']],
  ['safety', 'Safety & perioperative use', ['safety', 'contraindications', 'interactions', 'esmolol', 'Brevibloc', 'metoprolol', 'Lopressor', 'labetalol', 'Trandate', 'Normodyne', 'propranolol', 'Inderal', 'landiolol', 'Rapiblyk', 'WPW', 'preexcited', 'pre excited AF', 'accessory pathway', 'AV nodal blockers', 'unstable AF', 'cardioversion', 'asthma', 'bronchospasm', 'verapamil', 'diltiazem', 'digoxin', 'bradycardia', 'heart block', 'pheochromocytoma', 'alpha blockade', 'hypoglycemia', 'glucose', 'fasting', 'chronic', 'continue', 'hold', 'morning of surgery', 'day of surgery', 'initiation', '7 days', 'units', 'concentration', 'hypovolemia', 'compensatory tachycardia']],
];
const bodies = new Map(source.split(/^## /m).slice(1).map(chunk => {
  const line = chunk.indexOf('\n');
  return [chunk.slice(0, line).trim(), chunk.slice(line + 1).trim()];
}));
const rows = definitions.map(([slug, title, keywords], index) => {
  const body = bodies.get(title);
  assert.ok(body?.startsWith('|'), `${title}: missing chart`);
  assert.ok(body.split('\n').every(line => !line.trim() || line.startsWith('|')), `${title}: non-chart prose`);
  for (const line of body.split('\n')) {
    if (line.includes('**') && !line.includes('**Scope**')) assert.ok(line.includes('https://'), `${title}: missing row source`);
  }
  return {
    id: `beta-blocker-${slug}`, reference_id: 'beta-blocker-dosing',
    reference_title: 'Beta-Blocker Dosing', title,
    keywords: ['beta blocker', 'beta blockers', 'beta adrenergic', 'adult', 'IV', 'intravenous', 'perioperative', 'periop', 'postoperative', 'PACU', 'dose', 'dosing', ...keywords],
    sort_order: index, is_published: true, body, version: '2026-09-27',
  };
});
finalizeRows(rows);
export {rows};
const q = s => `'${s.replaceAll("'", "''")}'`;
let sql = '-- Authorized adult beta-blocker quick charts.\nbegin;\n';
for (const row of rows) {
  sql += `
insert into public.quick_reference_catalog
  (id,reference_id,reference_title,title,keywords,sort_order,is_published)
values (${q(row.id)},${q(row.reference_id)},${q(row.reference_title)},${q(row.title)},array[${row.keywords.map(q).join(',')}],${row.sort_order},true)
on conflict (id) do update set reference_id=excluded.reference_id,
  reference_title=excluded.reference_title,title=excluded.title,keywords=excluded.keywords,
  sort_order=excluded.sort_order,is_published=excluded.is_published;
insert into public.quick_reference_sections (id,body,version)
values (${q(row.id)},${q(row.body)},${q(row.version)})
on conflict (id) do update set body=excluded.body,version=excluded.version,updated_at=now();
`;
}
sql += '\ncommit;\n';
fs.writeFileSync('supabase/seeds/beta_blocker_quick_reference.sql', sql);
fs.writeFileSync('supabase/seeds/beta_blocker_catalog.json', JSON.stringify(rows.map(({body, version, ...metadata}) => metadata), null, 2) + '\n');
console.log(`Prepared ${rows.length} charts; database unchanged.`);
