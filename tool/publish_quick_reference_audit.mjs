// Exact-delta publication with a before-snapshot concurrency guard.
// Generate/review: node tool/publish_quick_reference_audit.mjs
// Apply reviewed delta: node tool/publish_quick_reference_audit.mjs --apply
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {createHash} from 'node:crypto';
const dir = 'docs/quick-reference-audit';
const before = JSON.parse(fs.readFileSync(`${dir}/live-before.json`, 'utf8'));
const after = JSON.parse(fs.readFileSync('supabase/seeds/all_quick_references.json', 'utf8'));
const q = s => `'${s.replaceAll("'", "''")}'`;
const metaKeys = ['reference_id', 'reference_title', 'title', 'keywords', 'sort_order', 'is_published'];
const metadata = row => Object.fromEntries(metaKeys.map(key => [key, row[key]]));
const bodyChanges = [], metadataChanges = [];
assert.equal(before.length, after.length);
let sql = 'begin;\nlock table public.quick_reference_catalog, public.quick_reference_sections in share row exclusive mode;\n';
for (const next of after) {
  const old = before.find(row => row.id === next.id);
  assert.ok(old, `New/unreviewed ID ${next.id}`);
  const bodyChanged = old.body !== next.body || old.version !== next.version;
  const metaChanged = JSON.stringify(metadata(old)) !== JSON.stringify(metadata(next));
  if (!bodyChanged && !metaChanged) continue;
  // Check all fields that this publication owns before updating either table.
  sql += `do $audit$ begin
 if not exists (select 1 from public.quick_reference_catalog c join public.quick_reference_sections s using(id)
 where c.id=${q(old.id)} and md5(s.body)=${q(createHash('md5').update(old.body).digest('hex'))} and s.version=${q(old.version)}
 and c.is_published=true
 and md5(array_to_string(c.keywords,chr(31)))=${q(createHash('md5').update(old.keywords.join('\x1f')).digest('hex'))})
 then raise exception 'Concurrent edit detected: ${old.id}'; end if;
 end $audit$;\n`;
  if (bodyChanged) {
    assert.notEqual(old.body, next.body, `Version-only change ${next.id}`);
    bodyChanges.push(next.id);
    sql += `update public.quick_reference_sections set body=${q(next.body)}, version=${q(next.version)}, updated_at=now() where id=${q(next.id)};\n`;
  }
  if (metaChanged) {
    // This audit should only expand keywords, not change IDs/titles/publication.
    assert.deepEqual({...metadata(old), keywords: []}, {...metadata(next), keywords: []});
    metadataChanges.push(next.id);
    assert.ok(next.keywords.every(word => !word.includes('|')));
    sql += `update public.quick_reference_catalog set keywords=string_to_array(${q(next.keywords.join('|'))},'|') where id=${q(next.id)};\n`;
  }
}
sql += 'commit;\n';
fs.writeFileSync(`${dir}/reviewed-delta.sql`, sql);
fs.writeFileSync(`${dir}/change-manifest.json`, JSON.stringify({bodyChanges, metadataChanges}, null, 2));
console.log(JSON.stringify({bodyChanges: bodyChanges.length, metadataChanges: metadataChanges.length}));
if (process.argv.includes('--apply')) {
  assert.ok(Buffer.byteLength(JSON.stringify({project_id: 'xuckkusbbcxplpqclbxt', query: sql})) < 130000,
    'Publication request exceeds safe CLI argument size; do not partially apply.');
  const result = execFileSync('pplx', ['connector', 'call', 'supabase', 'execute_sql',
    '--input', JSON.stringify({project_id: 'xuckkusbbcxplpqclbxt', query: sql})],
    {encoding: 'utf8', maxBuffer: 5e7});
  console.log(result);
}
