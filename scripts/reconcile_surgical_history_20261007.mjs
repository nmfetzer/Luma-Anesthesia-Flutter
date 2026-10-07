// Manually adjudicated coverage decisions. This is not automated clinical approval.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const dir='docs/surgical-historical-review-2026-10-07';
const audit=JSON.parse(fs.readFileSync(`${dir}/historical-audit-baseline.json`));
const cases=JSON.parse(fs.readFileSync('assets/data/surgical_cases.json'));
const hash=x=>createHash('sha256').update(JSON.stringify(x)).digest('hex');
const status={
 C:'covered-in-current-draft', S:'scope-boundary-retained',
 U:'updated-this-pass', P:'partially-covered-open',
 N:'identifier-or-provenance-not-treatment-number',
 H:'superseded-historical-wording', V:'verified-qualified-number',
};
const d=(code,sections,rationale)=>({status:status[code],sections:sections.split(','),rationale});
const decisions={
 'roux-en-y-gastric-bypass-rygb':{
  notes:[
   d('S','procedure,evidence','Surgical anatomy is distinguished from general bariatric anesthesia guidance; no RYGB-only protocol is claimed.'),
   d('S','evidence,ponv-plan','ERAS recommendations are scoped to bariatric surgery and uncertainty is preserved.'),
   d('C','fluids','Individualized fluid management replaces a fixed restrictive volume.'),
   d('U','analgesia','ASMBS identifies NSAID-related marginal-ulcer risk and qualified PPI prophylaxis. A universally safe NSAID exposure remains unestablished.'),
   d('C','tubes,intraop','Tube passage and leak testing are coordinated with the surgeon, not mandatory for every case.'),
   d('U','emergence','Explicit quantitative adductor-pollicis TOF recovery is conditional on neuromuscular blocker use.'),
   d('S','tubes,intraop','No unsupported anesthesia-specific leak-test recipe has been added.'),
  ],
  gaps:[
   d('S','airway,hemodynamics','Patient-specific airway and perfusion guidance is supplied, not a claim of uniquely validated RYGB targets.'),
   d('P','analgesia,ponv-plan','Risk guidance and scoped multimodal prevention added. Exact RYGB-specific NSAID safety and a superior fixed PONV regimen remain unresolved.'),
  ],
  numbers:[
   d('N','preop','B12 is a vitamin name, not a dosing threshold.'),
   d('N','glp1','GLP-1 identifies a drug pathway, not a dose or withholding interval.'),
   d('V','pulmonary','ERAS supports 6–8 mL/kg predicted body weight. This is not actual-weight dosing or a universal PEEP target.'),
   d('V','emergence','ASA quantitative TOF threshold is at least 0.9 at the adductor pollicis when a blocker was used.'),
  ],
 },
 'sleeve-gastrectomy':{
  notes:[
   d('C','airway,fluids,scalars,emergence','Unsupported fixed volumes, automatic RSI and reversal guarantees are absent. Current first-line videolaryngoscopy guidance is separately sourced to SOBA 2025; this does not restore the old never-direct-laryngoscopy claim.'),
   d('S','preop','No outdated BMI threshold is used to determine individual surgical eligibility.'),
   d('C','fluids','Euvolemia and individualized therapy replace a universal restrictive total.'),
   d('U','emergence','Conditional quantitative TOF recovery is explicit; paralysis is not mandated.'),
   d('S','airway,evidence','A single spinal-anesthetic case report is not used as a routine-practice recommendation.'),
   d('C','hemodynamics,complications,ponv-plan,emergence','Monitoring, VTE, PONV and respiratory support are individualized rather than supplied as a universal regimen.'),
  ],
  gaps:[
   d('P','tubes,intraop,complications','Recognition and surgical escalation are covered; a validated sleeve-specific intraoperative leak-rescue algorithm is not established.'),
   d('U','ponv-plan','Bariatric multimodal prevention and reassessment are added with an explicit statement that no uniquely effective sleeve regimen is established.'),
  ],
  numbers:[
   d('N','glp1','GLP-1 is not a medication dose.'),
   d('H','airway','Historical fixed 100% preoxygenation wording is replaced by current obesity-airway planning; no guarantee of safe apnea is implied.'),
   d('V','emergence','Conditional TOF at least 0.9 is explicit and source-linked.'),
   d('N','fluids','0.9% saline denotes a fluid concentration, not a prescribed volume or fixed resuscitation target.'),
  ],
 },
 'burn-excision-and-split-thickness-skin-grafting':{
  notes:[
   d('U','evidence,blood-guideline','The older narrative source is supplemented by the 2025 ABA guideline; its other descriptions are not retrospectively upgraded to graded evidence.'),
   d('U','timing-evidence,blood,access,drugs','No 72-hour mortality guarantee, unit-per-percent blood-loss calculator, mandatory arterial line or ideal anesthetic is used. Timing uncertainty is explicit.'),
   d('C','blood','Blood loss is assessed for the actual excision and patient; narrative estimates are not a transfusion calculator.'),
   d('U','blood-guideline,blood-conservation-evidence,temperature','Qualified adult transfusion and conditional TXA evidence replace an evidence gap, not a universal hemoglobin/CVP/drug/warming recipe.'),
   d('C','blockade','The current conservative burn succinylcholine warning is retained; an apparently safe 24–48-hour interval is not inferred from older wording.'),
   d('S','fluids,emergence','Resuscitation and extubation remain physiology-based rather than a universal operative regimen.'),
  ],
  gaps:[
   d('P','timing-evidence','2026 comparative evidence is added, but is heterogeneous and not explicitly adult-only. Adult timing certainty remains open.'),
   d('P','blood-conservation-evidence','ABA conditional TXA, a limited-graft negative trial and cell-salvage contamination evidence are supplied. Generalizability and reinfusion safety remain unresolved.'),
   d('U','blood-guideline','The 2025 adult major-burn RBC recommendation and active hemorrhage, acute brain injury and ACS qualifications are now explicit.'),
  ],numbers:[],
 },
 'escharotomy-fasciotomy-for-burns':{
  currentIds:['burn-escharotomy','burn-fasciotomy'],
  notes:[
   d('U','procedure,pain','Escharotomy now explicitly covers local anesthetic for unburnt extensions and selected sedation; this is not automatically the anesthetic plan for deep fasciotomy.'),
   d('U','procedure,airway','Repeat perfusion/respiratory assessment replaces a guaranteed 10–20 cm H2O response.'),
   d('U','procedure,pain','Do not equate eschar with an entirely painless procedure or omit analgesia for viable tissue.'),
   d('C','procedure','Release follows clinical compromise and urgent assessment, not a fixed 24–48-hour clock.'),
   d('C','blood','Hemorrhage readiness is individualized; no bloodless-procedure assurance is used.'),
   d('C','procedure,airway','Absent pulse is not the only indication; airway and deep-compartment problems require independent assessment.'),
  ],
  gaps:[
   d('P','procedure,pain','Practical procedural guidance is supplied; adult comparative evidence for a preferred escharotomy anesthetic remains limited.'),
   d('C','airway,procedure','Respiratory compromise, airway planning and postrelease reassessment are covered without a guaranteed mechanical response.'),
   d('S','pain,emergence','General burn analgesia and individualized recovery are supplied, not an escharotomy-specific fixed analgesic/PONV regimen.'),
  ],
  numbers:[d('H','procedure','The historical first-48-hours statement is not retained as a mandatory or safe waiting period. Clinical urgency governs release.')],
 },
 'abdominoperineal-resection-apr':{
  notes:[
   d('C','perfusion,analgesia','Fixed fluid/CVP, mandatory lines, cell salvage, TXA and epidural-drug recipes are not imposed.'),
   d('S','bleeding,turn','Presacral hemorrhage anticipation and escalation are covered; detailed surgical hemostatic maneuvers are outside this anesthesia reference.'),
   d('P','perineum,analgesia','Perineal pain and wound care are covered. Phantom-rectal-pain incidence and an evidence-based specific preventive regimen remain open; routine gabapentin is not justified.'),
   d('C','optimization,procedure','Cancer treatment and ureteric-device planning are patient-specific, not routine mandates or injury-prevention guarantees.'),
   d('C','perfusion,analgesia','Current ERAS fluid principles and selected open-surgery epidural use are represented.'),
   d('C','recovery','Quantitative neuromuscular recovery is conditional on blockade.'),
  ],
  gaps:[
   d('C','positioning,turn,ventilation,perfusion','Case setup, position changes, airway access and hemodynamics are expanded; these are not an APR-only randomized protocol.'),
   d('S','bleeding,perfusion','Hemorrhage response is addressed without inventing an APR-specific transfusion ratio or threshold.'),
   d('P','perineum,postop','Perineal morbidity and follow-up are present; specialist chronic/phantom pain guidance remains incomplete.'),
  ],
  numbers:[
   d('V','recovery','TOF at least 0.9 is the conditional ASA recovery recommendation.'),
   d('V','recovery','Early feeding and catheter timing are qualified elective colorectal recommendations, not mandatory timing despite complex pelvic surgery or complications.'),
  ],
 },
 'anal-fistula-repair-fistulotomy-lift-seton':{
  notes:[
   d('S','procedure,technique,evidence','Updated surgical and ambulatory-anorectal guidance improves coverage; surgical guidance is not represented as comparative anesthesia evidence.'),
   d('S','recovery','General ASA recovery standards are not described as fistula-specific trial results.'),
   d('C','analgesia,fluids','Major colorectal ERAS and hemorrhoid-specific analgesic regimens are not automatically imported.'),
   d('C','technique,positioning','Individual technique and positioning considerations now supplement limited original anesthesia coverage.'),
  ],
  gaps:[
   d('C','technique,positioning,local,analgesia,fluids,recovery','These practical domains are covered in the current draft, without a fixed drug regimen.'),
   d('S','technique','No universally superior anesthetic technique is claimed for every fistulotomy, LIFT or seton.'),
  ],
  numbers:[
   d('H','recovery','Current wording retains conditional quantitative recovery without repeating the historical numeric threshold here; this does not invalidate the ASA at-least-0.9 standard.'),
   d('N','evidence','2001 is historical source provenance; later cited guidance does not make that review contemporary.'),
  ],
 },
 'bowel-obstruction-surgery-open-laparoscopic':{
  notes:[
   d('S','evidence','Clinical draft status and final clinician review remain; source checking is not signoff.'),
   d('C','airway,assessment','High aspiration risk commonly favors RSI with a cuffed tube, not an assertion that every presentation requires the identical approach.'),
   d('C','airway,decompression,monitoring,resuscitation','Fixed induction, cricoid, NG, line and fluid recipes are replaced by risk-based planning.'),
   d('C','decompression','Elective avoidance of routine NG does not prohibit therapeutic decompression in acute obstruction.'),
   d('C','evidence','Emergency-laparotomy ERAS 2023 provides a more appropriate population than elective guidance alone.'),
  ],
  gaps:[
   d('C','airway,ventilation','Emergency airway and ventilation domains are supplied with shock and aspiration considerations.'),
   d('C','assessment,monitoring,resuscitation','Operative severity, monitoring and access are individualized to physiology and expected losses.'),
   d('C','extubation,postop','Physiology-based extubation, ongoing ventilation and postoperative escalation are covered.'),
  ],numbers:[],
 },
 'colectomy-open-laparoscopic-robotic':{
  notes:[
   d('C','optimization','Current elective ASCRS/SAGES combined mechanical preparation and oral-antibiotic guidance replaces the older blanket no-preparation statement.'),
   d('C','ventilation,positioning','Laparoscopic/robotic access and airway constraints are addressed without treating all colectomies identically.'),
   d('C','perfusion','Fixed CVP/fluid, routine crossmatch, lines, cell salvage and TXA mandates are not reintroduced.'),
   d('S','evidence','An institution-specific pathway is not treated as a universal standard.'),
   d('C','evidence','Current guideline scope is distinguished from the older broad surgical review.'),
   d('S','evidence','Elective guideline applicability is not recast as proof that every contributing trial was adult-only.'),
  ],
  gaps:[
   d('S','ventilation,positioning','Practical airway planning is present; no uniquely proven colectomy anesthetic protocol is claimed.'),
   d('S','perfusion','Bleeding and perfusion planning do not invent a colectomy-specific transfusion threshold.'),
  ],
  numbers:[
   d('N','optimization','2023 is the cited guideline year, not a treatment number.'),
   d('H','perfusion','Historical MAP-below-65 risk wording is replaced by individualized perfusion guidance, not a universal pressure goal.'),
   d('V','recovery','Conditional TOF at least 0.9 remains source-supported.'),
   d('V','recovery','Diet within 24 hours is qualified to suitable elective colorectal recovery, not complications or obstruction.'),
   d('N','evidence','2023 identifies guideline provenance and population.'),
  ],
 },
 'hemorrhoidectomy':{
  notes:[
   d('S','procedure,preparation-antithrombotics','Surgical selection and preparation are not dictated by the old unverified grade/preparation claims. The newer preparation source is explicitly attributed.'),
   d('C','positioning,technique','Prone airway access and technique are individualized; no blanket LMA prohibition or preference is imposed.'),
   d('S','technique','No unsupported saddle-block drug/dose/posture recipe is supplied.'),
   d('C','local','Local anesthetic safety and procedure context replace a guaranteed analgesic duration.'),
   d('C','fluids','Individualized fluid management replaces the historical 500 mL cap.'),
   d('C','bowel,analgesia','Topical and oral metronidazole evidence are distinguished; a speculative mechanism is not treated as established.'),
   d('S','bowel','Sitz baths are not presented as reliably proven postoperative analgesia.'),
   d('S','recovery','General ASA monitoring guidance is not described as hemorrhoid-specific evidence.'),
   d('U','preparation-antithrombotics','Drug indication, bleeding/thrombotic risk and neuraxial planning are separated. Rubber-band-ligation timing uncertainty is not generalized into an excisional-surgery hold table.'),
   d('U','preparation-antithrombotics,fluids','Contemporary scoped preparation guidance is added; old source age does not justify reinstating a fluid cap.'),
  ],
  gaps:[
   d('S','technique,pudendal','Technique and analgesic options are covered without claiming one best anesthetic for all patients.'),
   d('U','preparation-antithrombotics','Antithrombotic coordination and evidence-population limits are explicit; no unsupported fixed stop/restart intervals are added.'),
   d('U','preparation-antithrombotics','Full mechanical preparation is not required by the cited 2025 consensus; enema is optional under the surgical pathway.'),
   d('C','positioning,technique','Airway access and positioning are addressed.'),
   d('C','ponv,recovery','Risk-based PONV and discharge considerations are supplied without a mandatory regimen.'),
  ],
  numbers:[
   d('H','fluids','The historical 500 mL cap is not current patient guidance.'),
   d('H','technique','Six- and 24-hour study pain comparisons are not retained as proof of universal technique superiority.'),
   d('H','recovery','Current conditional quantitative-recovery wording does not repeat the old number here; ASA at-least-0.9 recovery remains applicable when blockade is used.'),
   d('N','evidence','2007 is old source provenance, not a current practice threshold.'),
  ],
 },
 'low-anterior-resection-lar':{
  notes:[
   d('S','evidence','Original Base44 statements remain unverified history, not evidence.'),
   d('C','optimization','Current elective combined preparation guidance is represented.'),
   d('S','ventilation,perfusion','A small hemodynamic trial does not mandate arterial lines or nitroglycerin for every case.'),
   d('C','positioning,pelvic','Positioning and pelvic consequences replace unsupported fixed-distance, leak-rate and stent guarantees; no individual risk calculator is implied.'),
  ],
  gaps:[
   d('C','positioning','Prolonged lithotomy and well-leg compartment risks are covered with clinical escalation.'),
   d('S','postop','Leak recognition and surgical escalation are covered, not a validated individualized risk score or surgical rescue algorithm.'),
   d('P','pelvic,postop','Autonomic/bladder consequences are present; detailed ureteric-injury recognition and management remain a specialist evidence gap.'),
  ],
  numbers:[
   d('V','recovery','TOF at least 0.9 is conditional on neuromuscular blocker use.'),
   d('H','perfusion','Historical MAP-below-65 association is not a universal LAR goal or transfusion trigger.'),
   d('V','recovery','Early IV-fluid discontinuation and diet within 24 hours are qualified to stable, uncomplicated elective recovery.'),
  ],
 },
 'ostomy-creation-reversal-ileostomy-colostomy':{
  notes:[
   d('S','procedure,approach,evidence','Actual operation and urgency govern applicability; elective resection evidence is not universal to all stoma work.'),
   d('C','analgesia','A contradictory practice-survey opioid statement is not used to choose analgesia.'),
   d('S','analgesia','A retrospective single-center regimen does not establish a preferred block.'),
   d('U','aspiration,approach,stoma','Airway selection remains individualized and new depth-based surgical escalation avoids a blanket stoma return-to-OR rule.'),
   d('U','stoma','Surgical depth assessment is added without instructions for blind bedside instrumentation.'),
  ],
  gaps:[
   d('S','procedure,approach','General perioperative coverage is available; no creation- or colostomy-reversal-specific superior anesthetic is established.'),
   d('U','closure','2025 review of anastomotic testing is added, limited to defunctioning ileostomy contexts and very-low-certainty evidence.'),
   d('U','stoma','Superficial versus below-fascia ischemia/necrosis and urgent surgical escalation are distinguished.'),
   d('C','aspiration,approach,hydration,perfusion,recovery','Airway, fluid and recovery domains are expanded around the actual procedure.'),
   d('U','stoma','The repeated stoma-assessment gap is addressed by the same explicit surgical-depth/escalation section; counted as an original note, not a second clinical change.'),
  ],
  numbers:[
   d('H','closure','Hand-sewn/stapled survey percentages are not retained as comparative outcome guidance.'),
   d('V','recovery','Conditional quantitative TOF at least 0.9 is source-supported.'),
   d('H','perfusion','Historical MAP-below-65 association is replaced by individualized perfusion guidance.'),
   d('V','recovery','Early feeding within 24 hours is scoped to suitable elective colorectal recovery.'),
   d('H','evidence','Survey sample and response-rate numbers are not current clinical treatment instructions.'),
  ],
 },
};
const rows=[];
for(const [id,plan] of Object.entries(decisions)){
 const report=audit.reports.find(r=>r.id===id);assert(report,id);
 const targets=(plan.currentIds||[id]).map(id=>{const c=cases.find(c=>c.id===id);assert(c,id);return c;});
 const numeric=audit.issues.filter(x=>x.id===id);
 for(const [kind,original,adjudicated] of [
  ['reviewNote',report.reviewNotes,plan.notes],
  ['evidenceGap',report.evidenceGaps,plan.gaps],
  ['numericalFlag',numeric.map(x=>x.text),plan.numbers],
 ]){
  assert.equal(original.length,adjudicated.length,`${id}:${kind}`);
  original.forEach((text,i)=>{
   const decision=adjudicated[i];assert(decision.status);
   const evidence=targets.flatMap(c=>decision.sections.map(sid=>{
    const s=c.sections.find(s=>s.id===sid);assert(s,`${c.id}:${sid}`);
    return {caseId:c.id,sectionId:sid,title:s.title,sectionHash:hash(s),bullets:s.bullets,sources:s.sources};
   }));
   rows.push({key:`${id}:${kind}:${i}`,historicalId:id,title:report.title,category:report.category,
    kind,index:i,originalText:text,...decision,evidence,
    historicalLocation:kind==='numericalFlag'?numeric[i]:null});
  });
 }
}
assert.equal(rows.length,128);assert.equal(new Set(rows.map(r=>r.key)).size,128);
const selectedIds=Object.keys(decisions);
const totals=key=>Object.fromEntries([...new Set(rows.map(r=>r[key]))].map(k=>[k,rows.filter(r=>r[key]===k).length]));
const artifact={date:'2026-10-07',scope:'Bariatric, Burns, Colorectal historical coverage reconciliation',
 clinicalApproval:false,releaseAuthorized:false,
 baselineHash:hash(audit),counts:{historicalCases:11,items:rows.length,byKind:totals('kind'),byStatus:totals('status'),bySpecialty:totals('category')},
 currentCaseHashes:Object.fromEntries([...new Set(rows.flatMap(r=>r.evidence.map(e=>e.caseId)))].map(id=>[id,hash(cases.find(c=>c.id===id))])),
 otherHistoricalCasesNotAdjudicatedInThisPass:audit.reports.filter(r=>!selectedIds.includes(r.id)).map(r=>({id:r.id,title:r.title,category:r.category})),
 caveats:['Covered means current draft coverage, not clinician approval.','Scope boundary means an unsupported universal rule was deliberately not invented.','Updated notes may still contain scientific uncertainty; status does not imply evidence certainty.','Original numerical flags include identifiers, years and research descriptions, not only treatment thresholds.','Previous PR #8 corrections are separate; other historical cases have not been adjudicated by this pass.'],
 rows};
fs.writeFileSync(`${dir}/historical-reconciliation.json`,JSON.stringify(artifact,null,2));
let md='# Surgical Case Prep: Historical Review Reconciliation\n\nOctober 7, 2026. Bariatric, Burns and Colorectal only. This is a note-by-note coverage and source-correction record, not clinical approval or release authorization.\n\n';
md+='## Scope and results\n\n';
md+='Eleven historical cases contain 128 items: 65 review notes, 33 evidence gaps and 30 numerical flags. The old combined burn procedure now maps to separate escharotomy and fasciotomy entries. Ten current records received changes; this differs from the historical-case denominator because shared bariatric and burn guidance also applies to newer records.\n\n';
for(const [s,n] of Object.entries(artifact.counts.byStatus))md+=`- **${s}**: ${n} items.\n`;
md+='\n'+artifact.caveats.map(c=>`- ${c}`).join('\n')+'\n\n';
md+='## Questions still explicitly open\n\n';
for(const r of rows.filter(r=>r.status==='partially-covered-open'))md+=`- **${r.title} (${r.kind} ${r.index+1})**: ${r.rationale}\n`;
md+='\nExisting separate holds remain: PAS guideline timing discrepancy, gynecologic-oncology 2026 full-text reconciliation, and specialist LVAD/ECMO/cardiac-pregnancy review. Native layout/PDF/offline acceptance and release authorization are separate. Other specialties’ historical notes remain outside this pass.\n\n';
for(const id of selectedIds){
 const group=rows.filter(r=>r.historicalId===id);
 md+=`## ${group[0].category}: ${group[0].title}\n\n`;
 for(const r of group){
  const refs=[...new Map(r.evidence.flatMap(e=>e.sources).map(s=>[s.url,s])).values()];
  md+=`### ${r.kind} ${r.index+1}: ${r.status}\n\n`;
  md+=`Historical note (archived, not current instructions):\n\n> ${r.originalText}\n\n`;
  md+=`${r.rationale} (${refs.map(s=>`[${s.label}](${s.url})`).join('; ')})\n\n`;
  md+=`Current coverage: ${r.evidence.map(e=>`\`${e.caseId} / ${e.sectionId}\``).join(', ')}. Exact current bullets and section hashes are preserved in the JSON companion.\n\n`;
 }
}
fs.writeFileSync(`${dir}/HISTORICAL-RECONCILIATION.md`,md.trimEnd()+'\n');
console.log(JSON.stringify(artifact.counts,null,2));
