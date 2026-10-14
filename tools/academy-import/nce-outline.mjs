// Parse the owner-supplied outline without inventing topics or importing exam items.
// Requires Poppler: node tools/academy-import/nce-outline.mjs /path/to/outline.pdf
import {execFileSync} from 'node:child_process';
import {readFile, writeFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';

const file = process.argv[2];
if (!file) throw Error('Provide the NCE outline PDF');
const text = execFileSync('pdftotext', ['-layout', file, '-'], {encoding: 'utf8'});
const nodes = [];
const stack = [];
const normalizationNotes = [];
const romanParents = new Set(['IV.A.3.a', 'IV.A.3.b', 'IV.A.10.d', 'IV.B.1.a']);
const types = ['domain', 'section', 'topic', 'subtopic', 'detail'];
let started = false;
for (const [pageIndex, page] of text.split('\f').entries()) {
  for (const raw of page.split('\n')) {
    let line = raw.trim();
    if (!line || /^\d+$/.test(line)) continue; // Page numbers, not outline numbers.
    if (/^I\.\s+Basic Sciences/.test(line)) started = true;
    if (!started) continue;
    // The uploaded document omits the period on this single list marker.
    if (/^e Nonobstetric surgery in the parturient$/.test(line)) {
      normalizationNotes.push({page: pageIndex + 1, original: line, normalized: line.replace(/^e /, 'e. ')});
      line = line.replace(/^e /, 'e. ');
    }
    let m;
    let depth;
    let marker;
    let title;
    if ((m = line.match(/^([IVX]+)\.\s+(.+\(\d+%\))$/))) {
      depth = 0; [, marker, title] = m;
    } else if ((m = line.match(/^([A-Z])\.\s+(.+)$/))) {
      depth = 1; [, marker, title] = m;
    } else if ((m = line.match(/^(\d+)\.\s+(.+)$/))) {
      depth = 2; [, marker, title] = m;
    } else if ((m = line.match(/^([a-z]+)\.\s+(.+)$/))) {
      [, marker, title] = m;
      depth = romanParents.has(stack[3]?.id) && /^(i|ii|iii|iv|v|vi)$/.test(marker)
        ? 4 : 3;
      if (depth === 3 && marker.length !== 1) throw Error(`Unexpected marker ${line}`);
    } else {
      assert(nodes.length, `Unmapped text: ${line}`);
      nodes.at(-1).title += ` ${line}`; // Wrapped headings, including page boundaries.
      continue;
    }
    const parent = depth === 0 ? null : stack[depth - 1];
    if (depth > 0) assert(parent, `Missing parent on page ${pageIndex + 1}: ${line}`);
    const node = {
      id: parent ? `${parent.id}.${marker}` : marker,
      parentId: parent?.id ?? null,
      type: types[depth],
      title,
      sourcePage: pageIndex + 1,
      reviewStatus: 'outline_only_content_not_authored',
    };
    nodes.push(node);
    stack.length = depth;
    stack[depth] = node;
  }
}
assert.equal(new Set(nodes.map(n => n.id)).size, nodes.length, 'Duplicate IDs');
assert.deepEqual(nodes.filter(n => n.type === 'domain').map(n => n.id), ['I', 'II', 'III', 'IV']);
assert.equal(nodes.find(n => n.id === 'I.A.1').title, 'Cardiovascular');
assert.equal(nodes.find(n => n.id === 'I.A.9').title, 'Immune');
assert.equal(nodes.find(n => n.id === 'I.B.3.i').title, 'Seizure disorders');
assert.equal(nodes.find(n => n.id === 'IV.A.3.a.vi').title, 'Orthodontic/dental');
assert.equal(nodes.find(n => n.id === 'IV.B.2.e').title, 'Nonobstetric surgery in the parturient');
assert.equal(nodes.at(-1).id, 'IV.B.6.c');
for (const node of nodes) {
  node.childIds = nodes.filter(n => n.parentId === node.id).map(n => n.id);
  node.isLeaf = node.childIds.length === 0;
  node.learningBundle = node.isLeaf ? {
    topicPdf: null,
    flashcardDeck: null,
    practiceQuestions: null,
    masteryCheckpoint: null,
    graphics: [],
    readyToPublish: false,
  } : null;
}
const leaves = nodes.filter(n => n.isLeaf);
const output = {
  schemaVersion: 1,
  source: {
    filename: 'NCE-Content-Outline.pdf',
    sha256: createHash('sha256').update(await readFile(file)).digest('hex'),
    pageCount: text.split('\f').filter(p => p.trim()).length,
    officialUrl: 'https://www.nbcrna.com/docs/default-source/exams-documents/nce-resources-landing-page/nce_content_outline_2025to2026.pdf?sfvrsn=6abde65a_9',
    examApplicability: 'NCE exams administered on or after 2024-01-02',
    importedOn: '2026-10-14',
    normalizationNotes,
  },
  domainWeights: {I: 20, II: 20, III: 35, IV: 25},
  seeDomainWeights: {I: 25, II: 25, III: 25, IV: 25},
  nodeCount: nodes.length,
  leafCount: leaves.length,
  firstLevelId: 'I.A.1',
  nodes,
  proposedLevelOrder: leaves.map(n => n.id),
  status: 'planning_manifest_not_a_completed_course',
};
await writeFile('review/academy/nce-outline-map.json', `${JSON.stringify(output, null, 2)}\n`);
console.log(JSON.stringify({
  nodes: nodes.length,
  leaves: leaves.length,
  domains: nodes.filter(n => n.type === 'domain').map(n => n.title),
  normalizationNotes,
}));
