// LOCAL ONLY. Builds a disposable PostgreSQL database; never connects to Supabase.
// Requires local postgres and sudo. Run: node scripts/test_guest_subscriptions_db.mjs
import fs from 'node:fs';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
const root = fileURLToPath(new URL('../', import.meta.url));
const read = (p) => fs.readFileSync(root + p, 'utf8');
const db = `luma_guest_test_${process.pid}`;
function run(command, args, input) {
  const p = spawnSync('sudo', ['-u', 'postgres', command, ...args], { input, encoding: 'utf8', maxBuffer: 8 * 1024 * 1024 });
  if (p.status !== 0) throw new Error(p.stderr + '\n' + p.stdout);
  return p.stdout + p.stderr;
}
const sql = (input) => run('psql', ['-X', '-q', '-v', 'ON_ERROR_STOP=1', '-d', db], input);
run('createdb', [db]);
try {
  sql(`DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='anon') THEN CREATE ROLE anon NOLOGIN; END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='authenticated') THEN CREATE ROLE authenticated NOLOGIN; END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='service_role') THEN CREATE ROLE service_role NOLOGIN; END IF;
  END $$;`);
  sql(read('supabase/tests/guest_subscription_purchases.sql'));
  // Production grants (as observed on 2026-10-10) before the replacement.
  sql(`REVOKE ALL ON FUNCTION public.luma_billing_policy() FROM PUBLIC, anon;
       GRANT EXECUTE ON FUNCTION public.luma_billing_policy() TO authenticated;
       REVOKE ALL ON FUNCTION public.has_clinical_premium_access() FROM PUBLIC, anon;
       GRANT EXECUTE ON FUNCTION public.has_clinical_premium_access() TO authenticated;`);
  sql('BEGIN;\n' + read('supabase/migrations/20261010120000_guest_subscription_purchases.sql') + '\nCOMMIT;');
  process.stdout.write(sql(read('supabase/tests/guest_subscription_assertions.sql')));
} finally {
  run('dropdb', [db]);
}
