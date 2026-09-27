// Explicitly invoked rollout for owner-authorized registration fields.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
const project_id = 'xuckkusbbcxplpqclbxt';
function call(name, args) {
  const raw = JSON.parse(execFileSync('pplx', [
    'connector','call','supabase',name,'--input',JSON.stringify({project_id,...args}),
  ], {encoding:'utf8',maxBuffer:5e7}));
  if (raw.error) throw Error(JSON.stringify(raw.error));
  return raw;
}
// SQL wrappers may enclose rows in an untrusted-data block. Only parse JSON data.
function rows(raw) {
  if (typeof raw === 'string') return rows(JSON.parse(raw));
  if (Array.isArray(raw)) return raw;
  if (typeof raw.result === 'string') {
    if (raw.result.trim().startsWith('{')) return rows(JSON.parse(raw.result));
    const match = raw.result.match(/<untrusted-data-[^>]+>\s*(\[[\s\S]*?\])\s*<\/untrusted-data-/);
    if (match) return JSON.parse(match[1]);
    return rows(JSON.parse(raw.result));
  }
  throw Error(`Unexpected connector response: ${JSON.stringify(raw).slice(0,500)}`);
}
if (!process.argv.includes('--apply')) throw Error('Pass --apply for the authorized additive migration.');
const definitions = rows(call('execute_sql', {query: `select proname,prosrc from pg_proc
  where oid in ('public.ce_course1(text,jsonb)'::regprocedure,'public.ce_course1_certificate(text)'::regprocedure)`}));
for (const [name, file] of [
  ['ce_course1','20260927120000_course1_multi_module.sql'],
  ['ce_course1_certificate','20260927160000_course1_certificates.sql'],
]) {
  const text = fs.readFileSync(`supabase/migrations/${file}`,'utf8');
  const body = text.match(/as \$\$([\s\S]*?)\$\$;/i)[1].trim();
  assert.equal(definitions.find(d=>d.proname===name)?.prosrc.trim(),body,
    `${name} changed live. Review before replacing.`);
}
console.log(call('apply_migration', {
  name:'course1_participation_dates',
  query:fs.readFileSync('supabase/migrations/20260927180000_course1_participation_dates.sql','utf8'),
}));
for (const file of ['course1_participation_dates.sql','course1_certificate_safety.sql']) {
  console.log(call('execute_sql',{query:fs.readFileSync(`supabase/tests/${file}`,'utf8')}));
}
