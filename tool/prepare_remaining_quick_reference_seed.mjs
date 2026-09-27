// Chart-only, source-linked content remains in Supabase. No automatic DB writes.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {finalizeRows} from './quick_reference_release.mjs';

const source = fs.readFileSync('supabase/seeds/remaining_quick_references.md', 'utf8');
const slug = value => value.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
const aliases = {
  'induction-medications': ['Diprivan', 'Amidate', 'Ketalar', 'Versed', 'RSI'],
  'hemodynamic-support': ['increase preload', 'increase afterload', 'increase inotropy', 'increase heart rate', 'SVR', 'CO'],
  'drip-quick-reference': ['drip', 'infusion', 'Levophed', 'Vasostrict', 'Precedex', 'Primacor', 'Ultiva', 'Diprivan'],
  'normal-hemodynamics': ['Swan Ganz', 'PA catheter', 'wedge', 'PCWP', 'PAOP', 'CO', 'CI', 'SVR', 'PVR', 'SvO2'],
  'svt-afib-cardioversion': ['AFib', 'AF', 'RVR', 'SVT', 'DCCV', 'cardioversion', 'Cardizem', 'Lopressor'],
  'wpw-syndrome': ['WPW', 'Wolff Parkinson White', 'preexcited', 'pre excited', 'accessory pathway', 'AVRT', 'orthodromic', 'antidromic', 'delta wave', 'short PR', 'irregular wide complex'],
  'valve-disorders': ['AS', 'AR', 'AI', 'MS', 'MR', 'valvular', 'insufficiency'],
  'antibiotic-redosing': ['Ancef', 'Kefzol', 'Cleocin', 'Flagyl', 'Unasyn', 'Mefoxin', 'Zinacef', 'Zosyn', 'antibiotics', 'redose', 'redosing'],
  'anticoagulants-reversal': ['blood thinner', 'Coumadin', 'Eliquis', 'Xarelto', 'Pradaxa', 'Lovenox', 'Kcentra', 'Praxbind', 'Andexxa'],
  'massive-transfusion': ['MTP', 'massive transfusion protocol', 'hemorrhage', 'TXA', 'blood products', 'cryo'],
  'opioid-dosing': ['Sublimaze', 'Dilaudid', 'Ultiva', 'Narcan', 'opioids', 'analgesia'],
  'local-anesthetic-maxima': ['local anesthetic maximum dose', 'local anesthetics max dose', 'Marcaine', 'Sensorcaine', 'Naropin', 'Xylocaine', 'LAST', 'lipid rescue', 'intralipid'],
  'ponv': ['postoperative nausea vomiting', 'PONV', 'Zofran', 'Decadron', 'Barhemsys', 'Inapsine', 'Aloxi', 'Emend'],
  'neuromuscular-blockade': ['NMB', 'NMBA', 'succinylcholine', 'sux', 'Anectine', 'Zemuron', 'Norcuron', 'Nimbex', 'Bridion', 'TOF', 'paralytic'],
  'bronchospasm': ['wheezing', 'high airway pressure', 'albuterol', 'salbutamol', 'Ventolin', 'Proventil', 'asthma'],
  'anaphylaxis': ['allergic reaction', 'epinephrine', 'adrenaline', 'tryptase'],
  'preop-glucose': ['high glucose', 'hyperglycemia', 'preop diabetes', 'ASA', 'ADA', 'SAMBA', 'GLP1', 'GLP-1', 'SGLT2', 'insulin', 'DKA', 'HHS'],
  'acls-medications': ['ACLS', 'adult code', 'cardiac arrest', 'VF', 'pVT', 'PEA', 'asystole'],
  'pals-medications': ['PALS', 'pediatric', 'paediatric', 'child', 'children', 'infant', 'pediatric code'],
};
const rows = [];
for (const guide of source.split(/^# /m).slice(1)) {
  const firstNewline = guide.indexOf('\n');
  const [referenceTitle, referenceId] = guide.slice(0, firstNewline).split(' :: ');
  assert.ok(aliases[referenceId], `Unknown guide ${referenceId}`);
  const sections = guide.slice(firstNewline + 1).split(/^## /m).slice(1);
  assert.ok(sections.length, `Empty guide ${referenceId}`);
  sections.forEach((section, index) => {
    const cut = section.indexOf('\n');
    const title = section.slice(0, cut).trim();
    const body = section.slice(cut + 1).trim();
    const lines = body.split('\n').filter(line => line.trim());
    assert.ok(lines.length >= 4, `Empty chart ${title}`);
    assert.ok(lines.every(line => line.startsWith('|') && line.endsWith('|') &&
      line.split('|').length === 4), `Not two-column chart ${title}`);
    for (const line of lines.slice(2)) {
      if (!line.includes('**Scope**')) assert.ok(line.includes('https://'), `Missing source ${line}`);
    }
    // Free content: index actual clinical words, not just a short list of titles.
    // Drop URLs and numeric values; never fuzzy-match or guess a medication.
    const terms = body.replace(/\]\(https:\/\/[^)]+\)/g, ']')
      .toLowerCase().match(/[a-z][a-z0-9-]{2,}/g) ?? [];
    rows.push({
      // Preserve the live WPW section ID when broadening its former AF-only title.
      id: referenceId === 'wpw-syndrome' && index === 0
        ? 'wpw-syndrome-pre-excitation-treatment'
        : `${referenceId}-${slug(title)}`, reference_id: referenceId,
      reference_title: referenceTitle, title,
      keywords: [...new Set([...aliases[referenceId], 'dose', 'dosing', ...terms])],
      sort_order: index, is_published: true, body,
      version: referenceId === 'wpw-syndrome' ? '2026-09-27-r2' : '2026-09-27',
    });
  });
}
assert.equal(new Set(rows.map(r => r.reference_id)).size, 19);
assert.equal(new Set(rows.map(r => r.id)).size, rows.length);
finalizeRows(rows);
export {rows};
const q = s => `'${s.replaceAll("'", "''")}'`;
let sql = '-- Owner authorized completion of free Quick Reference charts.\nbegin;\n';
for (const r of rows) {
  sql += `
insert into public.quick_reference_catalog
 (id,reference_id,reference_title,title,keywords,sort_order,is_published)
values (${q(r.id)},${q(r.reference_id)},${q(r.reference_title)},${q(r.title)},
 array[${r.keywords.map(q).join(',')}],${r.sort_order},true)
on conflict(id) do update set reference_id=excluded.reference_id,
 reference_title=excluded.reference_title,title=excluded.title,keywords=excluded.keywords,
 sort_order=excluded.sort_order,is_published=excluded.is_published;
insert into public.quick_reference_sections(id,body,version)
values (${q(r.id)},${q(r.body)},${q(r.version)})
on conflict(id) do update set body=excluded.body,version=excluded.version,updated_at=now();
`;
}
sql += '\ncommit;\n';
fs.writeFileSync('supabase/seeds/remaining_quick_references.sql', sql);
fs.writeFileSync('supabase/seeds/remaining_catalog.json',
  JSON.stringify(rows.map(({body, version, ...row}) => row), null, 2) + '\n');
console.log(`Prepared ${rows.length} charts across 19 guides; database unchanged.`);
