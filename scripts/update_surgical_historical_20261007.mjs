// Evidence-supported draft supplementation, not clinical signoff or release.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {createHash} from 'node:crypto';
const baseline='f18d577c4acfc9014b16c313ba42d78603066ebe';
const file='assets/data/surgical_cases.json';
const dir='docs/surgical-historical-review-2026-10-07';
const hash=x=>createHash('sha256').update(JSON.stringify(x)).digest('hex');
const original=JSON.parse(execFileSync('git',['show',`${baseline}:${file}`],{maxBuffer:30_000_000}));
const current=JSON.parse(fs.readFileSync(file));
const records=structuredClone(original);
const src=(label,url)=>({label,url});
const S={
  asmbs:src('ASMBS marginal-ulcer risk and prophylaxis review (2024)','https://asmbs.org/wp-content/uploads/2024/11/American-Society-for-Metabolic-and-Bariatric-Surgery-literature-review-on-risk-factors-screening-recommendations-and-prophylaxis-for-marginal-ulcers-after-metabolic-and-bariatric-surgery.pdf'),
  eras:src('ERAS bariatric recommendations: 2021 update','https://link.springer.com/article/10.1007/s00268-021-06394-9'),
  nmb:src('APSF summary of ASA neuromuscular blockade guidelines (2023)','https://www.apsf.org/article/new-practice-guidelines-for-neuromuscular-blockade/'),
  aba:src('ABA blood-product transfusion guideline (2025 full text)','https://doi.org/10.1093/jbcr/iraf021'),
  tranburn:src('Tranburn randomized trial (2025)','https://pmc.ncbi.nlm.nih.gov/articles/PMC12755343/'),
  cell:src('Cell salvage in contaminated fields: scoping review (2026)','https://pmc.ncbi.nlm.nih.gov/articles/PMC12768276/'),
  timing:src('Burn excision timing: systematic review (2026; not adult-only)','https://pmc.ncbi.nlm.nih.gov/articles/PMC13309668/'),
  eschar:src('StatPearls: Escharotomy','https://www.ncbi.nlm.nih.gov/sites/books/NBK482120/'),
  stoma:src('Stoma Complications: surgical review','https://pmc.ncbi.nlm.nih.gov/articles/PMC11466528/'),
  closure:src('Anastomotic evaluation before ileostomy closure: 2025 systematic review','https://pmc.ncbi.nlm.nih.gov/articles/PMC12159718/'),
  hemorrhoid:src('Taiwan Society of Colon and Rectal Surgeons: hemorrhoid consensus (2025)','https://pmc.ncbi.nlm.nih.gov/articles/PMC12572025/'),
  ascrs:src('ASCRS hemorrhoid guideline (2024)','https://www.ascrsu.com/ascrs/view/ASCRS-Evidence-Based-Guidelines-and-Expert-Consensus/3982022/8/Management_of_Hemorrhoids__2024_'),
  asra:src('ASRA antithrombotic guideline, fifth edition (2025)','https://rapm.bmj.com/content/early/2025/01/21/rapm-2024-105766'),
};
const reasons=new Map();
const get=id=>{const r=records.find(r=>r.id===id);assert(r,id);return r;};
function put(id,sid,title,bullets,sources,why){
  const r=get(id),s={id:sid,title,bullets,sources},i=r.sections.findIndex(s=>s.id===sid);
  if(i>=0)r.sections[i]=s;else r.sections.splice(r.sections.findIndex(s=>s.id==='evidence'),0,s);
  r.sourceChecked='2026-10-07';
  reasons.set(id,[...new Set([...(reasons.get(id)||[]),why])]);
}
function add(id,sid,bullets,sources,why){
  const s=get(id).sections.find(s=>s.id===sid);assert(s,`${id}:${sid}`);
  put(id,sid,s.title,[...s.bullets,...bullets],[...new Map([...s.sources,...sources].map(s=>[s.url,s])).values()],why);
}
for(const r of records.filter(r=>r.category==='Bariatric')){
  add(r.id,'emergence',[
    'When a neuromuscular blocker has been given, confirm quantitative recovery at the adductor pollicis with a train-of-four ratio of at least 0.9 before extubation. This does not mandate blockade in every case, and clinical strength or elapsed time alone does not prove recovery.'
  ],[S.nmb],'Restore the explicit, conditional TOF recovery detail identified in the historical audit.');
  put(r.id,'ponv-plan','PONV: prevention, rescue & surgical reassessment',[
    'Bariatric ERAS supports multimodal PONV prevention, reduction of perioperative opioid exposure and consideration of propofol-based TIVA when appropriate. This is bariatric guidance, not proof of one uniquely effective sleeve- or bypass-specific drug combination.',
    'The guideline describes combining agents from three different antiemetic classes. Select the actual agents and timing for contraindications, interactions and patient risk; avoid duplicate dosing and account for sedation, QT risk and glycemic effects where relevant.',
    'Document a rescue plan and reassess persistent vomiting, poor intake or vomiting accompanied by pain, tachycardia or systemic deterioration. Do not repeatedly treat nausea without considering a surgical complication.'
  ],[S.eras,...r.sections.find(s=>s.id==='complications').sources],'Supplement historical PONV gap with scoped bariatric guidance, not a fixed regimen.');
}
add('roux-en-y-gastric-bypass-rygb','analgesia',[
  'The ASMBS review identifies NSAID exposure as a marginal-ulcer risk factor after RYGB. A generic opioid-sparing NSAID pathway should therefore not be imported without an explicit bariatric-team assessment of alternatives and gastrointestinal, renal and bleeding risks.',
  'ASMBS recommends postoperative PPI prophylaxis for at least three months after RYGB, with possible longer treatment for identified risks. Confirm the patient’s actual prescription and adherence; the review does not establish a universally safe NSAID dose or duration, and PPI therapy is not proof that NSAID exposure is risk-free.'
],[S.asmbs],'Reconcile the historical RYGB NSAID question with ASMBS risk and prophylaxis guidance.');
for(const id of ['burn-wound-debridement-excision','burn-excision-and-split-thickness-skin-grafting']){
  put(id,'blood-guideline','Adult major burns: transfusion evidence & exceptions',[
    'The 2025 ABA blood-product guideline addresses hospitalized adults with acute burns; its restrictive RBC recommendation specifically concerns burns of at least 20% TBSA. The studied restrictive approach gives RBCs for a pretransfusion hemoglobin below 7 g/dL to maintain hemoglobin at least 7 g/dL, rather than maintaining at least 10 g/dL.',
    'These thresholds do not apply to significant bleeding or hemodynamic instability in or outside the operating room. Active hemorrhage requires clinical resuscitation; do not wait for a laboratory threshold or delay source control.',
    'The guideline excludes coexisting acute brain injury from that restrictive recommendation and notes that a less restrictive approach may be appropriate in acute coronary syndrome. Assess the actual physiology and comorbidity rather than using burn size alone.',
    'ABA recommends TEG or ROTEM to guide perioperative blood-product therapy during major burn debridement. Follow the local assay and hemorrhage pathway; no universal numerical viscoelastic trigger or fixed plasma/platelet recipe is supplied here.',
    'ABA could not recommend for or against a fixed 1:1:1 RBC:plasma:platelet strategy for the studied burn-excision outcomes. This uncertainty is not an instruction to withhold the institution’s massive-hemorrhage response during uncontrolled bleeding.'
  ],[S.aba],'Supply current adult burn transfusion guidance with hemorrhage, brain-injury and ACS exceptions.');
  put(id,'blood-conservation-evidence','TXA, cell salvage & limits of generalization',[
    'ABA gives a weak conditional recommendation to consider perioperative IV TXA for burn wound debridement, ideally informed by viscoelastic testing and the lysis phenotype. It is not a mandate for every graft or a universal dose instruction; thrombosis-related safety and applicability to early excision remain uncertain.',
    'The separate Tranburn randomized trial found no additional blood-loss or transfusion benefit from TXA alongside topical epinephrine in its limited burn-graft surgery population. It did not exclude a possible effect in more extensive excisions; the result does not prove that TXA always works or never works in burn surgery.',
    'Routine cell salvage is not established by these sources. A 2026 scoping review found bacterial contamination in all samples in two small burn-excision series, both rated poor quality; it could not establish burn-specific reinfusion safety. Any use requires a case-specific transfusion/surgical plan, not an assumption that washing or filtration guarantees a safe product.'
  ],[S.aba,S.tranburn,S.cell],'Resolve the existence-of-evidence gap while retaining TXA and cell-salvage uncertainty.');
  put(id,'timing-evidence','Excision timing: physiology before a clock rule',[
    'Coordinate excision timing with resuscitation, hemodynamic stability, depth/extent, donor sites, infection concerns and available blood, anesthesia and warming support. Do not state that excision within a fixed 72-hour window guarantees lower mortality.',
    'A 2026 systematic review associated early excision with shorter hospitalization but did not demonstrate a consistent mortality benefit; timing definitions and studies were heterogeneous, and its population was not explicitly adult-only. This is not proof of equivalence or a replacement for adult burn-service judgment.'
  ],[S.timing],'Update timing evidence without inventing adult-only certainty or an obligatory window.');
  add(id,'evidence',[
    'The historical blood-management gap is now supplemented by the 2025 ABA transfusion guideline and later comparative/scoping evidence. The 2024 initial burn-shock fluid guideline and the 2025 blood-product guideline address different questions; neither supplies a one-size-fits-all operative resuscitation recipe.'
  ],[S.aba,S.tranburn,S.cell,S.timing],'Update evidence scope after supplementation.');
}
add('burn-escharotomy','procedure',[
  'Local anesthetic is needed for unburnt skin into which the release extends. Sedation may be used, and GA is not invariably required, but pain, associated injury, respiratory compromise and the ability to rescue the airway determine the actual plan; do not equate eschar with an entirely painless procedure.',
  'Reassess distal perfusion or respiratory mechanics during and after release. Persistent compromise needs urgent surgical reassessment for incomplete release, a deep-compartment problem or another cause; neither a promised airway-pressure drop nor absent pulse is an adequate single decision rule.'
],[S.eschar],'Add local-analgesia and postrelease reassessment details to the split escharotomy route.');
add('ostomy-creation-reversal-ileostomy-colostomy','closure',[
  'Before reversal of a defunctioning ileostomy, confirm that the surgical team has assessed the downstream anastomosis and addressed any prior leak, sinus or stricture. The operation name or passage of time alone does not establish integrity.',
  'A 2025 systematic review supports considering endoscopy and digital rectal examination, with water-soluble contrast studies useful when a leak is suspected or in selected higher-risk contexts. Evidence was very low certainty and no randomized trials were identified; no single mandatory test or “negative test guarantees healing” rule is justified.',
  'That evidence concerns adults with distal colonic/pelvic anastomoses and defunctioning ileostomies. Do not apply its test-performance estimates to every colostomy reversal or other reconstruction.'
],[S.closure],'Add anastomotic-assessment evidence with explicit ileostomy population and uncertainty.');
add('ostomy-creation-reversal-ileostomy-colostomy','stoma',[
  'Communicate evolving edema, dusky mucosa or blue/black change promptly and request surgical assessment of depth, not just surface color. The surgical review distinguishes limited superficial ischemia from necrosis extending below the fascia, which warrants operative exploration.',
  'Endoscopic or other direct assessment of the stoma’s depth is a surgical-team procedure. Do not use this brief anesthesia reference as instructions for blind instrumentation, and do not delay escalation because some superficial changes can be observed.'
],[S.stoma],'Make stoma-viability escalation useful without importing a bedside instrumentation recipe.');
put('hemorrhoidectomy','preparation-antithrombotics','Preparation & antithrombotic coordination',[
  'Do not import the mechanical bowel preparation plus oral-antibiotic recommendation for elective colorectal resection into isolated hemorrhoidectomy. The 2025 Taiwan colorectal-society consensus states that full mechanical preparation is unnecessary for hemorrhoid surgery; a cleansing enema may be considered under the surgical pathway.',
  'Review antiplatelet and anticoagulant indication, exact drug/dose, renal function, procedure extent, hemostasis and any neuraxial/deep-block plan. Agree interruption and resumption with the prescribing/procedural teams rather than applying an automatic stop rule.',
  'The 2024 ASCRS guideline’s detailed antithrombotic discussion concerns rubber-band ligation and acknowledges uncertain hold/restart timing. It must not be repackaged as an excisional-hemorrhoidectomy drug-timing table.',
  'Use current ASRA guidance for neuraxial or deep-block eligibility, separately from the surgeon’s procedural bleeding assessment. The Taiwan consensus also calls for weighing the indication and risk of discontinuation; it does not supply one safe interval for all drugs.'
],[S.hemorrhoid,S.ascrs,S.asra],'Resolve preparation scope and add current antithrombotic references without false procedural precision.');
const changed=records.filter((r,i)=>hash(r)!==hash(original[i]));
assert.equal(changed.length,10);
for(const r of records){
  const now=current.find(x=>x.id===r.id),before=original.find(x=>x.id===r.id);
  assert(now&&before);
  assert(hash(now)===hash(before)||hash(now)===hash(r),`Concurrent edit: ${r.id}`);
  assert.equal(r.clinicalStatus,before.clinicalStatus);
}
assert.equal(records.length,350);
fs.mkdirSync(dir,{recursive:true});
const ledger={baseline,date:'2026-10-07',status:'source-updated; no clinician signoff',records:changed.map(after=>{
  const before=original.find(x=>x.id===after.id);
  return {id:after.id,beforeHash:hash(before),afterHash:hash(after),reasons:reasons.get(after.id),before,after};
})};
fs.writeFileSync(`${dir}/correction-ledger.json`,JSON.stringify(ledger,null,2));
fs.writeFileSync(file,JSON.stringify(records));
// Keep the existing manual lap-chole entry exactly; regenerate search text only.
const indexFile='lib/surgical_prep/surgical_index.dart',old=fs.readFileSync(indexFile,'utf8');
const tail=old.slice(old.lastIndexOf('  SurgicalCaseIndex('));assert(tail.includes("'laparoscopic-cholecystectomy'"));
const words=s=>s.normalize('NFKC').toLowerCase().replace(/[^a-z0-9\s]/g,'').replace(/\s+/g,' ').trim();
const dart=s=>JSON.stringify(s).replaceAll('$','\\$');
let index="// Generated from the staged clinical catalog; do not edit manually.\npart of 'surgical_catalog.dart';\n\nconst surgicalIndex = <SurgicalCaseIndex>[\n";
for(const r of records){
  const text=[...new Set(words([r.title,r.category,...r.aliases,...r.overview.bullets,...r.sections.flatMap(s=>[s.title,...s.bullets])].join(' ')).split(' '))].join(' ');
  index+=`  SurgicalCaseIndex(${dart(r.id)}, ${dart(r.title)}, ${dart(r.category)}, ${dart(r.aliases.join(' '))}, ${dart(text)}),\n`;
}
fs.writeFileSync(indexFile,index+tail);
let md='# Surgical Case Prep: Historical Review Corrections\n\nOctober 7, 2026. Evidence-supported drafts, not clinician approval. Exact preimages are archived separately rather than displayed as current clinical guidance.\n\n';
for(const row of ledger.records){
  md+=`## ${row.after.title}\n\n${row.reasons.map(x=>`- ${x}`).join('\n')}\n\n`;
  const before=new Map(row.before.sections.map(s=>[s.id,hash(s)]));
  for(const s of row.after.sections.filter(s=>before.get(s.id)!==hash(s))){
    const cites=s.sources.map(s=>`[${s.label}](${s.url})`).join('; ');
    md+=`### ${s.title}\n\n${s.bullets.map(b=>`- ${b} (${cites})`).join('\n\n')}\n\n`;
  }
}
fs.writeFileSync(`${dir}/UPDATED-DRAFTS.md`,md.trimEnd()+'\n');
console.log(JSON.stringify({changed:changed.map(x=>x.id),count:changed.length,library:351}));
