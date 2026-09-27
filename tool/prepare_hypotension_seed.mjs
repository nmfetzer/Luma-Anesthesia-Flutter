// Server-only clinical content; public metadata is the only catalog fixture.
// Generate locally; never writes to the database.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {finalizeRows} from './quick_reference_release.mjs';

const source = fs.readFileSync('supabase/seeds/hypotension_quick_reference.md', 'utf8');
const definitions = [
  ['bolus', 'IV bolus chart', ['bolus', 'push', 'push dose', 'rescue', 'phenylephrine', 'Neo', 'Neo-Synephrine', 'ephedrine', 'Akovaz', 'Corphedra', 'norepinephrine', 'noradrenaline', 'norepi', 'Levophed', 'epinephrine', 'adrenaline', 'epi', 'vasopressin', 'Vasostrict', 'low HR', 'bradycardia', 'tachyphylaxis', 'off label', 'units', 'mcg', 'mg']],
  ['infusion', 'IV infusion chart', ['infusion', 'drip', 'pressor', 'vasopressor', 'titration', 'maximum', 'phenylephrine', 'Neo', 'Neo-Synephrine', 'norepinephrine', 'noradrenaline', 'norepi', 'Levophed', 'epinephrine', 'adrenaline', 'epi', 'vasopressin', 'Vasostrict', 'dopamine', 'Intropin', 'septic shock', 'post cardiotomy', 'vasoplegia', 'ideal body weight', 'IBW', 'lactate', 'MAOI', 'pheochromocytoma', 'units']],
  ['safety', 'Selection & safety chart', ['selection', 'safety', 'monitoring', 'concentration', 'units', 'extravasation', 'phentolamine', 'norepinephrine', 'Levophed', 'dopamine', 'ischemia', 'peripheral IV', 'central access', 'low HR', 'preload', 'cardiac output', 'volume', 'anesthetic depth', 'vasoplegia', 'blood pressure target']],
];
const bodies = new Map(source.split(/^## /m).slice(1).map(chunk => {
  const line = chunk.indexOf('\n');
  return [chunk.slice(0, line).trim(), chunk.slice(line + 1).trim()];
}));
const rows = definitions.map(([slug, title, keywords], index) => {
  const body = bodies.get(title);
  assert.ok(body?.startsWith('|'), `${title}: must be chart-only`);
  assert.ok(body.split('\n').every(line => !line.trim() || line.startsWith('|')), `${title}: non-chart prose`);
  assert.ok(body.includes('https://'), `${title}: missing sources`);
  return {
    id: `hypotension-${slug}`, reference_id: 'hypotension-dosing',
    reference_title: 'Hypotension Dosing', title,
    keywords: ['hypotension', 'low blood pressure', 'low BP', 'adult', 'IV', 'intravenous', 'perioperative', 'periop', 'postoperative', 'PACU', 'dose', 'dosing', ...keywords],
    sort_order: index, is_published: true, body, version: '2026-09-27',
  };
});
finalizeRows(rows);
export {rows};
const q = s => `'${s.replaceAll("'", "''")}'`;
let sql = '-- Authorized adult perioperative hypotension quick charts.\nbegin;\n';
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
fs.writeFileSync('supabase/seeds/hypotension_quick_reference.sql', sql);
fs.writeFileSync('supabase/seeds/hypotension_catalog.json', JSON.stringify(rows.map(({body, version, ...metadata}) => metadata), null, 2) + '\n');
console.log(`Prepared ${rows.length} chart-only sections; database unchanged.`);
