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
// Later evidence corrections may intentionally replace unsafe/outdated clinical text.
// Verify exact recorded postimages, then validate inherited retention against archived
// preimages. Do not put superseded clinical instructions back in the reader merely
// to satisfy the historical preservation fixture.
// Reverse chronological order preserves sequential correction history.
const ledgerPaths=[
 'docs/surgical-historical-review-2026-10-07/correction-ledger.json',
 'docs/surgical-review-2026-10-07/correction-ledger.json',
].map(p=>path.join(root,p));
const verificationCases=structuredClone(cases);
let corrected=0;
for(const ledgerPath of ledgerPaths.filter(p=>fs.existsSync(p))){
 const ledger=JSON.parse(fs.readFileSync(ledgerPath));
 const seen=new Set();
 for(const row of ledger.records){
  assert(!seen.has(row.id),`Duplicate correction: ${row.id}`);seen.add(row.id);
  assert.equal(hash(row.before),row.beforeHash,`Invalid preimage: ${row.id}`);
  assert.equal(hash(row.after),row.afterHash,`Invalid postimage: ${row.id}`);
  assert.equal(row.before.id,row.id);assert.equal(row.after.id,row.id);
  const position=verificationCases.findIndex(c=>c.id===row.id);assert(position>=0);
  assert.equal(hash(verificationCases[position]),row.afterHash,`Unrecorded correction change: ${row.id}`);
  verificationCases[position]=row.before;corrected++;
 }
}
const ids=new Set(cases.map(c=>c.id));assert.equal(ids.size,cases.length);
let sections=0,ob=0;
for(const before of fixture.records){
 const c=verificationCases.find(c=>c.id===before.id);assert(c,`Missing ${before.id}`);
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
console.log(`PASS: ${fixture.originalIds.length} original entries accounted for; ${fixture.records.length} prior records and ${sections} detail sections retained in current content or exact correction preimages; ${ob} OB baseline records verified; ${corrected} exact evidence-update postimages verified. This is not clinical signoff.`);
