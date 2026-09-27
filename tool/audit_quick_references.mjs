import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
const dir='docs/quick-reference-audit';
fs.mkdirSync(dir,{recursive:true});
const raw=execFileSync('pplx',['connector','call','supabase','execute_sql','--input',JSON.stringify({
 project_id:'xuckkusbbcxplpqclbxt',
 query:'select c.*,s.body,s.version from public.quick_reference_catalog c join public.quick_reference_sections s using(id) where c.is_published order by c.reference_id,c.sort_order;'
})],{encoding:'utf8',maxBuffer:5e7});
let value=JSON.parse(raw);
for(let i=0;i<8;i++){
 if(Array.isArray(value))break;
 if(typeof value==='object'){value=value.result??value.content??value;continue;}
 try{value=JSON.parse(value);continue;}catch{}
 const m=value.match(/<untrusted-data-[^>]+>\s*(\[[\s\S]*?\])\s*<\/untrusted-data-/);
 if(m){value=JSON.parse(m[1]);break;}
 throw Error('Cannot decode clinical snapshot');
}
if(!Array.isArray(value)||!value[0]?.body)throw Error('Invalid snapshot');
fs.writeFileSync(`${dir}/live-before.json`,JSON.stringify(value,null,2));
const urls=[...new Set(value.flatMap(r=>[...r.body.matchAll(/\]\((https?:\/\/[^)]+)\)/g)].map(m=>m[1])))];
fs.writeFileSync(`${dir}/source-urls.json`,JSON.stringify(urls,null,2));
fs.writeFileSync(`${dir}/content-review.txt`,value.map(r=>`\n# ${r.reference_title} / ${r.title} [${r.id}]\n${r.body.replace(/\]\(https?:\/\/[^)]+\)/g,']')}`).join('\n'));
console.log(JSON.stringify({sections:value.length,guides:new Set(value.map(r=>r.reference_id)).size,urls:urls.length}));
