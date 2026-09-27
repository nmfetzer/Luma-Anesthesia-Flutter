// Server-only clinical content; public metadata is the only test fixture.
// Run from repository root. This generator never writes to the database.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {finalizeRows} from './quick_reference_release.mjs';

const source = fs.readFileSync('supabase/seeds/antihypertensive_quick_reference.md', 'utf8');
const definitions = [
  ['bolus', 'IV bolus chart', ['bolus', 'push', 'labetalol', 'Trandate', 'hydralazine', 'Apresoline', 'esmolol', 'Brevibloc', 'metoprolol', 'Lopressor', 'beta blocker', 'tachycardia', 'dose', 'dosing', 'onset', 'duration', 'delayed peak', 'off label', 'asthma', 'bradycardia', 'heart block', 'CAD']],
  ['infusion', 'IV infusion chart', ['infusion', 'drip', 'nicardipine', 'Cardene', 'clevidipine', 'Cleviprex', 'esmolol', 'Brevibloc', 'labetalol', 'Trandate', 'nitroglycerin', 'NTG', 'nitroprusside', 'SNP', 'Nipride', 'Nitropress', 'Nipride RTU', 'titration', 'dose', 'dosing', 'maximum', 'egg allergy', 'soy allergy', 'aortic stenosis', 'cyanide', 'renal', 'lipid', 'PDE5', 'sildenafil', 'tadalafil', 'vardenafil', 'riociguat', 'nitrate', 'asthma', 'bradycardia', 'heart block']],
  ['safety', 'Monitoring & high-risk cautions', ['monitoring', 'units', 'mg', 'mcg', 'micrograms', 'bolus stacking', 'delayed peak', 'pain', 'anesthetic depth', 'hypercarbia', 'hypoxia', 'bradycardia', 'beta blocker', 'blood pressure target']],
];
const bodies = new Map(source.split(/^## /m).slice(1).map(chunk => {
  const line = chunk.indexOf('\n');
  return [chunk.slice(0, line).trim(), chunk.slice(line + 1).trim()];
}));
const rows = definitions.map(([slug, title, keywords], index) => {
  const body = bodies.get(title);
  assert.ok(body?.startsWith('|'), `${title}: must be chart-only`);
  assert.ok(body.includes('https://'), `${title}: missing source links`);
  assert.ok(body.split('\n').every(line => !line.trim() || line.startsWith('|')), `${title}: non-chart prose`);
  return {
    id: `antihypertensive-${slug}`, reference_id: 'antihypertensive-dosing',
    reference_title: 'Antihypertensive Dosing', title,
    keywords: ['antihypertensive', 'antihypertensives', 'hypertension', 'HTN', 'high blood pressure', 'BP', 'adult', 'IV', 'intravenous', 'perioperative', 'periop', 'postoperative', 'PACU', ...keywords],
    sort_order: index, is_published: true, body, version: '2026-09-27',
  };
});
finalizeRows(rows);
export {rows};
const q = s => `'${s.replaceAll("'", "''")}'`;
let sql = '-- Authorized adult perioperative antihypertensive quick charts.\nbegin;\n';
for (const row of rows) {
  sql += `\ninsert into public.quick_reference_catalog
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
fs.writeFileSync('supabase/seeds/antihypertensive_quick_reference.sql', sql);
fs.writeFileSync('supabase/seeds/antihypertensive_catalog.json', JSON.stringify(rows.map(({body, version, ...metadata}) => metadata), null, 2) + '\n');
console.log(`Prepared ${rows.length} chart-only sections; database unchanged.`);
