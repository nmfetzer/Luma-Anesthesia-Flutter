// LOCAL ONLY. Builds a disposable PostgreSQL database; never connects to Supabase.
// Requires local postgres, sudo and the anon/authenticated/service_role roles.
import fs from 'node:fs';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url));
const read=p=>fs.readFileSync(root+p,'utf8');
const db=`luma_review_test_${process.pid}`;
function run(command,args,input) {
  const p=spawnSync('sudo',['-u','postgres',command,...args],{input,encoding:'utf8',maxBuffer:8*1024*1024});
  if(p.status!==0) throw new Error(p.stderr+'\n'+p.stdout);
  return p.stdout;
}
const sql=input=>run('psql',['-X','-v','ON_ERROR_STOP=1','-d',db],input);
function definition(text,name) {
  const match=text.match(new RegExp(`create (?:or replace )?function public\\.${name}\\(`,'i'));
  if(!match) throw new Error(`Missing function ${name}`);
  const start=match.index, open=text.indexOf('$$',start), end=text.indexOf('$$;',open+2);
  if(open<0||end<0) throw new Error(`Missing function body ${name}`);
  return text.slice(start,end+3);
}
run('createdb',[db]);
try {
  sql(`
    CREATE SCHEMA auth;
    CREATE TABLE auth.users(id uuid PRIMARY KEY,is_anonymous boolean NOT NULL DEFAULT false,
      email_confirmed_at timestamptz,banned_until timestamptz);
    CREATE FUNCTION auth.jwt() RETURNS jsonb LANGUAGE sql STABLE AS
      $$ SELECT current_setting('request.jwt.claims',true)::jsonb $$;
    CREATE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS $$ SELECT (auth.jwt()->>'sub')::uuid $$;
    GRANT USAGE ON SCHEMA auth TO authenticated;
    CREATE TABLE public.luma_content_entitlements(user_id uuid,entitlement text,valid_until timestamptz,revoked_at timestamptz);
    CREATE TABLE public.ce_course1_catalog(id text PRIMARY KEY,metadata jsonb,released boolean NOT NULL DEFAULT false);
    INSERT INTO public.ce_course1_catalog VALUES('1047239','{}',false);
    CREATE TABLE public.ce_course1_store_products(store text,product_id text,PRIMARY KEY(store,product_id));
  `);
  const initial=read('supabase/migrations/20260925030000_ce_bonus_access.sql');
  sql(initial.slice(0,initial.indexOf('-- Only a trusted server')));
  sql(definition(initial,'record_verified_ce_bonus')+'\n'+definition(initial,'revoke_verified_ce_bonus'));
  sql('BEGIN;\n'+read('supabase/migrations/20260927154627_ce_bonus_three_month_cap.sql')+'\nCOMMIT;');
  sql(read('supabase/migrations/20260927163821_revenuecat_ce_webhook.sql'));
  sql(read('supabase/tests/apple_review_fixtures.sql'));
  sql(read('supabase/migrations/20260927193822_apple_purchase_wiring.sql'));
  const courseFiles=[
    '20260927180000_course1_participation_dates.sql',
    '20260927200000_course2_learning_certificates.sql',
    '20260927220000_course3_learning_certificates.sql',
  ];
  for(let n=1;n<=3;n++){
    const source=read('supabase/migrations/'+courseFiles[n-1]);
    for(const suffix of ['_participation_error','','_certificate']) {
      sql(definition(source,`ce_course${n}${suffix}`));
    }
  }
  sql(read('supabase/migrations/20260927230000_apple_sandbox_review.sql'));
  console.log(sql(read('supabase/tests/apple_review.sql')));
  sql(read('supabase/migrations/20260929020000_open_sandbox_testing.sql'));
  console.log(sql(read('supabase/tests/open_sandbox_testing.sql')));
  for(const test of ['ce_bonus_three_month_cap.sql','revenuecat_ce_webhook.sql','apple_purchase_wiring.sql']) {
    sql(read('supabase/tests/'+test));
    console.log(`PASS: production regression ${test}`);
  }
  sql(read('supabase/migrations/20261002143504_public_purchase_account_routing.sql'));
  console.log(sql(read('supabase/tests/open_sandbox_testing.sql')));
  console.log(sql(read('supabase/tests/public_purchase_account_routing.sql')));
  let blocked=false;
  try {
    sql(read('supabase/operations/activate_apple_public_launch.sql'));
  } catch(error) {
    if (!String(error).includes('Incomplete course 1')) throw error;
    blocked=true;
  }
  if (!blocked) throw new Error('Incomplete launch was not blocked');
  sql(`DO $$ BEGIN
    IF (SELECT customer_subscriptions_enabled FROM public.luma_billing_controls)
      OR EXISTS(SELECT 1 FROM public.luma_ce_bonus_products WHERE enabled)
    THEN RAISE EXCEPTION 'Failed activation changed sales flags'; END IF;
  END $$;`);
  sql(read('supabase/tests/public_launch_fixtures.sql'));
  sql(read('supabase/operations/activate_apple_public_launch.sql'));
  sql(`DO $$ BEGIN
    IF NOT (SELECT customer_subscriptions_enabled AND sandbox_self_enrollment_enabled
      FROM public.luma_billing_controls)
      OR (SELECT count(*) FROM public.luma_ce_bonus_products WHERE enabled)<>4
      OR NOT (SELECT released FROM public.ce_course1_catalog)
      OR NOT (SELECT released FROM public.ce_course2_catalog)
      OR NOT (SELECT released FROM public.ce_course3_catalog)
      OR NOT (SELECT enabled FROM public.ce_course1_certificate_settings)
      OR NOT (SELECT enabled FROM public.ce_course2_certificate_settings)
      OR NOT (SELECT enabled FROM public.ce_course3_certificate_settings)
    THEN RAISE EXCEPTION 'Public activation failed or disabled sandbox'; END IF;
  END $$;`);
  console.log(sql(read('supabase/tests/public_purchase_account_routing.sql')));
  console.log('PASS: blocked incomplete activation; complete activation preserves sandbox isolation.');
  console.log('Apple review database integration checks passed in a disposable local database.');
} finally {
  run('dropdb',[db]);
}
