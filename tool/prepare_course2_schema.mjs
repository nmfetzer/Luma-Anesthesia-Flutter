// Mechanical namespace fork of the tested, gated Course 1 implementation.
// Course 2 has separate state, resources, product mapping, awards and records.
import fs from 'node:fs';
const dir='supabase/migrations/';
const read=name=>fs.readFileSync(dir+name,'utf8');
const first=read('20260927010000_course1_learning.sql').split('create function public.ce_course1(')[0];
const mapping=read('20260927020000_course1_hints_store_mapping.sql').split('insert into public.ce_course1_store_products')[0];
const records=read('20260927121000_course1_provider_records.sql');
const foundation=read('20260927160000_course1_certificates.sql').split('create function public.ce_course1_certificate(')[0];
const dates=read('20260927180000_course1_participation_dates.sql');
const archive=read('20260927190000_course1_certificate_archive.sql');
let sql=[first,mapping,
 "insert into public.ce_course1_catalog(id,metadata,released) values('1047239','{}',false);",
 foundation,dates,records,archive].join('\n');
for(const [a,b] of [
 ['ce_course1','ce_course2'],['ce-course1','ce-course2'],['course_1_module_','course_2_module_'],
 ['1047239','1047241'],['196397','196400'],['Course 1','Course 2'],['course1-v1','course2-v1'],
 ['A Medication Review for the Experienced CRNA','Uncommon but Catastrophic Anesthesia Events'],
 ['17.50','10.50'],['17.5','10.5'],['2.50','1.00'],
 ["'pain_credits',2.5","'pain_credits',1.0"],
 ['<> 11','<> 10'],['<>11','<>10'],['=11','=10'],['all 11','all 10'],['all eleven','all ten'],
 ["'required_modules',11","'required_modules',10"],
 ])sql=sql.split(a).join(b);
// Course 2's MH bank is 31; all other banks are 25. Keep three 15-item forms,
// with at most seven shared items between any pair and every item eligible.
sql=sql.replace('jsonb_array_length(bank)<>25',"jsonb_array_length(bank)<>(m->>'bank_size')::int");
sql=sql.replace(
 `where (i=1 and ord between 1 and 15)\n              or (i=2 and (ord between 1 and 7 or ord between 16 and 23))\n              or (i=3 and (ord between 8 and 14 or ord between 16 and 22 or ord=24));`,
 `where (jsonb_array_length(bank)=25 and (\n              (i=1 and ord between 1 and 15)\n              or (i=2 and (ord between 1 and 7 or ord between 16 and 23))\n              or (i=3 and (ord between 8 and 14 or ord between 16 and 22 or ord=24))))\n              or (jsonb_array_length(bank)=31 and (\n              (i=1 and ord between 1 and 15)\n              or (i=2 and ord between 16 and 30)\n              or (i=3 and (ord between 1 and 7 or ord between 16 and 22 or ord=31))));`);
// Never guess paid-store product IDs. Empty mapping keeps purchases closed.
sql+=`\ninsert into public.ce_course2_reviewers(user_id) select user_id from public.ce_course1_reviewers;\nrevoke all on function public.ce_course2(text,jsonb) from public,anon;\ngrant execute on function public.ce_course2(text,jsonb) to authenticated,anon;\n`;
fs.writeFileSync(dir+'20260927200000_course2_learning_certificates.sql',sql);
console.log('Generated isolated Course 2 schema. Product mapping empty; issuance disabled.');
