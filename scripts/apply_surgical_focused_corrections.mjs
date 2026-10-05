// Idempotent, narrowly scoped correction of three clinical review drafts.
// Run from the repository root: node scripts/apply_surgical_focused_corrections.mjs
import fs from 'node:fs';
import assert from 'node:assert/strict';

const file = 'assets/data/surgical_cases.json';
const cases = JSON.parse(fs.readFileSync(file, 'utf8'));
const before = JSON.stringify(cases);
const changes = [
  {
    id: 'pacemaker-icd-generator-change',
    section: 'intraop',
    old: 'Anticipate electromagnetic interference from electrosurgery. In a pacemaker-dependent patient, the review advises altering pacing function to a synchronous mode when EMI is likely; the individual device response and appropriateness of magnet use must be verified.',
    replacement: [
      'For a pacing-dependent patient in whom electromagnetic interference (EMI) is anticipated, coordinate an appropriate asynchronous-pacing strategy with electrophysiology. Verify the specific device and magnet response; an ICD magnet generally suspends tachytherapy without changing its pacing mode.',
      'This general CIED safeguard does not replace the additional procedural plan needed during generator exchange and possible interruption of pacing support. Confirm the pacing contingency with the electrophysiology team before exchange.',
    ],
    source: {
      label: '2024 AHA/ACC guideline: perioperative cardiovascular management and CIED precautions',
      url: 'https://www.jacc.org/doi/10.1016/j.jacc.2024.06.013',
    },
  },
  {
    id: 'split-thickness-full-thickness-skin-graft',
    section: 'airway',
    old: 'For patients with burn injury, avoid succinylcholine from 48 hours after injury because extrajunctional acetylcholine-receptor upregulation can cause exaggerated hyperkalemia and cardiac arrest.',
    replacement: [
      'After major burns, extrajunctional acetylcholine-receptor upregulation makes succinylcholine capable of causing severe, potentially fatal hyperkalemia. Use a conservative avoidance boundary after the first 24 hours rather than treating 24–48 hours as an assured safe window.',
      'Published timing differs across reviews. Risk may persist for months or longer and cannot be cleared by the calendar alone; active wounds, impaired mobility and ongoing critical illness require individualized burn/anesthesia-team review before later use.',
      'Even in the first 24 hours, succinylcholine is not automatically appropriate: consider existing hyperkalemia, electrical/crush muscle injury and other contraindications.',
    ],
    source: {
      label: 'StatPearls: Anesthesia for Patients With Burns (2023)',
      url: 'https://ncbi.nlm.nih.gov/sites/books/NBK572117/',
    },
  },
  {
    id: 'implantable-loop-recorder-ilr-placement',
    section: 'procedure',
    old: 'Placement uses a small incision and a subcutaneous pocket on the left chest. The device is activated by passing a magnet over it.',
    replacement: [
      'Placement uses a small incision and a subcutaneous pocket on the left chest. Programming, recording and symptom-marking workflows are device-specific. Confirm the implanted model and follow electrophysiology/manufacturer instructions rather than assuming magnet activation.',
      'For example, LINQ II patient guidance describes automatic data transmission and, when prescribed, symptom marking through its supported app/Patient Assistant workflow. Symptom marking is not a universal magnet-based activation instruction for all implantable loop recorders.',
    ],
    source: {
      label: 'Medtronic: Get started with your LINQ II insertable cardiac monitor',
      url: 'https://www.medtronic.com/content/dam/medtronic-wide/public/western-europe/products/cardiac-vascular/cardiac-rhythm/cardiac-monitoring/ee-get-started-with-your-icm-linq-ii.pdf',
    },
  },
];

for (const change of changes) {
  const record = cases.find(c => c.id === change.id);
  assert(record, change.id);
  const section = record.sections.find(s => s.id === change.section);
  assert(section);
  const index = section.bullets.indexOf(change.old);
  if (index >= 0) section.bullets.splice(index, 1, ...change.replacement);
  else assert(change.replacement.every(b => section.bullets.includes(b)), `Unexpected source text: ${change.id}`);
  if (!section.sources.some(s => s.url === change.source.url)) section.sources.push(change.source);
  record.sourceChecked = '2026-10-05';
}
const oldCases = JSON.parse(before);
const changedIds = cases.filter((c, i) => JSON.stringify(c) !== JSON.stringify(oldCases[i])).map(c => c.id);
assert(changedIds.every(id => changes.some(c => c.id === id)));
assert.equal(cases.length, oldCases.length);
assert.equal(new Set(cases.map(c => c.id)).size, cases.length);
fs.writeFileSync(file, JSON.stringify(cases));

// Match the existing index generator, preserving the manual-case entry verbatim.
const indexFile = 'lib/surgical_prep/surgical_index.dart';
const oldIndex = fs.readFileSync(indexFile, 'utf8');
const manualStart = oldIndex.lastIndexOf('  SurgicalCaseIndex(');
assert(oldIndex.slice(manualStart).includes("'laparoscopic-cholecystectomy'"));
const manualTail = oldIndex.slice(manualStart);
const clean = s => s.normalize('NFKC').toLowerCase().replace(/[^a-z0-9\s]/g, '').replace(/\s+/g, ' ').trim();
const dart = s => JSON.stringify(s).replaceAll('$', '\\$');
let output = "// Generated from the staged clinical catalog; do not edit manually.\npart of 'surgical_catalog.dart';\n\nconst surgicalIndex = <SurgicalCaseIndex>[\n";
for (const c of cases) {
  const text = [...new Set(clean([c.title, c.category, ...c.aliases, ...c.overview.bullets, ...c.sections.flatMap(s => [s.title, ...s.bullets])].join(' ')).split(' '))].join(' ');
  output += `  SurgicalCaseIndex(${dart(c.id)}, ${dart(c.title)}, ${dart(c.category)}, ${dart(c.aliases.join(' '))}, ${dart(text)}),\n`;
}
fs.writeFileSync(indexFile, output + manualTail);
console.log(JSON.stringify({changedIds, records: cases.length, manualCasePreserved: true}));
