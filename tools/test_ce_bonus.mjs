// Install @electric-sql/pglite separately; no real customer database is used.
// PGLITE_MODULE=/absolute/path/to/pglite/dist/index.js node tools/test_ce_bonus.mjs
import {readFile} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
const {PGlite} = await import(process.env.PGLITE_MODULE || '@electric-sql/pglite');
const db = new PGlite();
const root = new URL('../', import.meta.url);
await db.exec(`
  CREATE ROLE anon; CREATE ROLE authenticated; CREATE ROLE service_role BYPASSRLS;
  CREATE SCHEMA auth;
  CREATE TABLE auth.users(id uuid PRIMARY KEY, is_anonymous boolean DEFAULT false,
    raw_user_meta_data jsonb);
  CREATE FUNCTION auth.jwt() RETURNS jsonb LANGUAGE sql STABLE AS
    $$ SELECT COALESCE(NULLIF(current_setting('request.jwt.claims', true), ''), '{}')::jsonb $$;
  CREATE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS
    $$ SELECT (auth.jwt()->>'sub')::uuid $$;
  GRANT USAGE ON SCHEMA auth, public TO anon, authenticated, service_role;
  CREATE TABLE public.medication(id text PRIMARY KEY, adult_dose text, sources text,
    deep_dive_content text);
  INSERT INTO public.medication VALUES ('fixture-drug','fixture dose','fixture source','fixture deep dive');
  GRANT SELECT ON public.medication TO anon, authenticated;
`);
for (const name of [
  '20260923010000_special_considerations.sql',
  '20260925010000_special_considerations_paid_access.sql',
  '20260925020000_medication_deep_dive_access.sql',
  '20260925030000_ce_bonus_access.sql',
]) {
  await db.exec(await readFile(new URL(`supabase/migrations/${name}`, root), 'utf8'));
}
for (const name of ['ce_bonus_access.sql', 'medication_deep_dive_access.sql']) {
  const result = await db.exec(await readFile(new URL(`supabase/tests/${name}`, root), 'utf8'));
  console.log(fileURLToPath(new URL(`supabase/tests/${name}`, root)), result.at(-1).rows);
}
await db.close();
