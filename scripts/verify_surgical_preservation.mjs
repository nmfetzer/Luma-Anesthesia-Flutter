// Run from any directory: node scripts/verify_surgical_preservation.mjs
// Technical no-loss check, not clinical validation.
import fs from 'node:fs';
import {fileURLToPath} from 'node:url';
import path from 'node:path';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const fixture=JSON.parse(fs.readFileSync(path.join(root,'test/fixtures/surgical_preservation.json')));
const cases=JSON.parse(fs.readFileSync(path.join(root,'assets/data/surgical_cases.json')));
const index=fs.readFileSync(path.join(root,'lib/surgical_prep/surgical_index.dart'),'utf8');
const screen=fs.readFileSync(path.join(root,'lib/surgical_prep/surgical_library_screen.dart'),'utf8');
const hash=x=>createHash('sha256').update(JSON.stringify(x)).digest('hex');
const ids=new Set(cases.map(c=>c.id));assert.equal(ids.size,cases.length);
let sections=0,ob=0;
for(const before of fixture.records){
 const c=cases.find(c=>c.id===before.id);assert(c,`Missing ${before.id}`);
 const hashes=new Set(c.sections.map(hash));
 for(const h of before.sectionHashes){assert(hashes.has(h),`Previous section missing/changed: ${before.id}`);sections++;}
 const originalOverview={...c.sections.find(s=>s.id==='retained-overview'),id:'overview',title:'Quick clinical overview'};
 assert(hash(c.overview)===before.overviewHash||hash(originalOverview)===before.overviewHash,`Previous overview missing/changed: ${before.id}`);
 if(before.ob){assert.equal(hash(c),before.recordHash,`OB changed: ${before.id}`);ob++;}
}
for(const id of fixture.originalIds){
 if(id==='laparoscopic-cholecystectomy'){assert(index.includes(id));assert(fs.existsSync(path.join(root,'lib/surgical_prep/drafts/laparoscopic_cholecystectomy.dart')));continue;}
 if(ids.has(id))continue;
 assert(fixture.redirects[id],`Original route missing: ${id}`);assert(screen.includes(`caseId == '${id}'`));
 for(const replacement of fixture.redirects[id])assert(ids.has(replacement),replacement);
}
assert.equal(ob,9);
console.log(`PASS: ${fixture.originalIds.length} original entries accounted for; ${fixture.records.length} prior records and ${sections} detail sections retained; ${ob} OB records unchanged.`);
