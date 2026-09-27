import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
const dir = 'docs/quick-reference-audit';
function execute(query) {
  const raw = execFileSync('pplx', ['connector', 'call', 'supabase', 'execute_sql',
    '--input', JSON.stringify({project_id: 'xuckkusbbcxplpqclbxt', query})],
    {encoding: 'utf8', maxBuffer: 5e7});
  let result = JSON.parse(raw);
  for (let i=0; i<8; i++) {
    if (Array.isArray(result)) return result;
    if (typeof result === 'object') {
      result = result.result ?? result.content ?? result;
      continue;
    }
    try { result = JSON.parse(result); continue; } catch {}
    const match = result.match(/<untrusted-data-[^>]+>\s*(\[[\s\S]*?\])\s*<\/untrusted-data-/);
    if (match) return JSON.parse(match[1]);
    throw Error('Cannot decode connector response');
  }
  throw Error('Unexpected connector response');
}
const live = execute('select c.*,s.body,s.version from public.quick_reference_catalog c join public.quick_reference_sections s using(id) where c.is_published order by c.reference_id,c.sort_order;');
const expected = JSON.parse(fs.readFileSync('supabase/seeds/all_quick_references.json', 'utf8'));
assert.equal(live.length, 59);
for (const row of expected) {
  const actual = live.find(r => r.id === row.id);
  for (const key of Object.keys(row)) assert.deepEqual(actual?.[key], row[key], `${row.id}: ${key}`);
}
fs.writeFileSync(`${dir}/live-after.json`, JSON.stringify(live, null, 2));
const access = execute(fs.readFileSync('supabase/tests/quick_references_access.sql', 'utf8'));
fs.writeFileSync(`${dir}/access-receipt.json`, JSON.stringify(access, null, 2));
console.log(JSON.stringify({exactSections: live.length, guides: new Set(live.map(r => r.reference_id)).size, access}, null, 2));
