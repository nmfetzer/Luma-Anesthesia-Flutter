import fs from 'node:fs';
import {call} from './load_course3_private.mjs';
const modules=JSON.parse(fs.readFileSync('../ce_halo_course3/production_manifest.json'));
for(const m of modules) {
  const questions=JSON.parse(fs.readFileSync(m.payload)).questions;
  const text=JSON.stringify(questions).replaceAll("'","''");
  console.log(call('execute_sql',{query:`begin;
    do $$ begin assert (select released=false from public.ce_course3_catalog); end $$;
    update public.ce_course3_resources set data='${text}'::jsonb
      where id='course3_module${m.n}_questions';
    commit; select ${m.n} as updated_module;`}));
}
