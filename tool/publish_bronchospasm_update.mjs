// Owner-approved, single-section delta. Does not touch other clinical content.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';

const id = 'bronchospasm-intraoperative-treatment';
const old = JSON.parse(fs.readFileSync(
  'docs/quick-reference-audit/live-after.json', 'utf8')).find(r => r.id === id);
const next = JSON.parse(fs.readFileSync(
  'supabase/seeds/all_quick_references.json', 'utf8')).find(r => r.id === id);
assert.ok(old && next);
assert.equal(next.version, '2026-09-27-r2');
for (const key of ['reference_id', 'reference_title', 'title', 'sort_order', 'is_published']) {
  assert.deepEqual(old[key], next[key]);
}
const q = s => `'${s.replaceAll("'", "''")}'`;
const hash = s => createHash('md5').update(s).digest('hex');
const query = `begin;
lock table public.quick_reference_catalog, public.quick_reference_sections in share row exclusive mode;
do $release$ begin
 if not exists (
 select 1 from public.quick_reference_catalog c join public.quick_reference_sections s using(id)
 where c.id=${q(id)} and c.is_published=true
 and md5(s.body)=${q(hash(old.body))} and s.version=${q(old.version)}
 and md5(array_to_string(c.keywords,chr(31)))=${q(hash(old.keywords.join('\x1f')))})
 then raise exception 'Concurrent bronchospasm edit detected; review before publication'; end if;
end $release$;
update public.quick_reference_sections
 set body=${q(next.body)},version=${q(next.version)},updated_at=now() where id=${q(id)};
update public.quick_reference_catalog
 set keywords=array[${next.keywords.map(q).join(',')}] where id=${q(id)};
commit;
select id,version from public.quick_reference_sections where id=${q(id)};`;
if (!process.argv.includes('--apply')) {
  console.log(query);
} else {
  console.log(execFileSync('pplx', ['connector', 'call', 'supabase', 'execute_sql',
    '--input', JSON.stringify({project_id:'xuckkusbbcxplpqclbxt', query})],
    {encoding:'utf8', maxBuffer:5e7}));
}
