import fs from 'node:fs';
import {call} from './load_course3_private.mjs';
const sql=query=>call('execute_sql',{query});
console.log(sql(`begin;
update public.ce_course3_certificate_settings c set
  signer_name=s.signer_name,signer_title=s.signer_title,
  provider_city_state=s.provider_city_state,
  signature_png_base64=s.signature_png_base64,approved_at=s.approved_at
from public.ce_course2_certificate_settings s where c.course_id='1047243';
do $$ begin
assert (select enabled=false and approved_at is not null from public.ce_course3_certificate_settings);
assert (select released=false from public.ce_course3_catalog);
end $$; commit;`));
console.log(sql(fs.readFileSync('supabase/tests/course3_learning.sql','utf8')));
const archive=fs.readFileSync('supabase/tests/course1_archive_safety.sql','utf8')
  .replaceAll('course1','course3').replaceAll('1047239','1047243');
console.log(sql(archive));
console.log(sql(`select
 (select count(*) from public.ce_course3_resources) as private_resources,
 (select count(*) from public.ce_course3_certificates) as official_awards,
 (select released from public.ce_course3_catalog) as released,
 (select enabled from public.ce_course3_certificate_settings) as issuance_enabled;`));
