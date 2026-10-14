// One-way, read-only legacy source import. Never executes legacy JavaScript.
// npm ci --prefix tools/academy-import
// node tools/academy-import/import.mjs /path/to/legacy/repo
import {parse} from '@babel/parser';
import {readFile, writeFile, mkdir, readdir, copyFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {resolve, basename} from 'node:path';
import {execFileSync} from 'node:child_process';

const root = resolve(process.argv[2] ?? (() => {throw Error('Legacy repo required');})());
const output = resolve('review/academy');
const directory = resolve(root, 'src/components/academy');
await mkdir(`${output}/legacy-source`, {recursive: true});
const reviewStatus = 'needs_clinical_review';
const manifest = {
  schemaVersion: 1,
  sourceCommit: execFileSync('git', ['-C', root, 'rev-parse', 'HEAD'], {encoding: 'utf8'}).trim(),
  reviewStatus,
  shippedInApp: false,
  flashcardRecordsImported: false,
  notes: [
    'Archive is not an approved question bank and is not included in Flutter assets.',
    'Flashcard deck definitions are available; Flashcard records are stored separately in Base44.',
    'JSX modules are preserved verbatim, not yet converted into native lessons.',
  ],
  files: [],
};
const questions = [];
const literals = [];
function literal(n) {
  if (!n) throw Error('Missing literal');
  if (['StringLiteral', 'NumericLiteral', 'BooleanLiteral'].includes(n.type)) return n.value;
  if (n.type === 'NullLiteral') return null;
  if (n.type === 'ArrayExpression') return n.elements.map(literal);
  if (n.type === 'ObjectExpression') return Object.fromEntries(n.properties.map(p => {
    if (p.type !== 'ObjectProperty' || p.computed) throw Error('Non-literal property');
    return [p.key.name ?? p.key.value, literal(p.value)];
  }));
  if (n.type === 'UnaryExpression' && n.operator === '-') return -literal(n.argument);
  if (n.type === 'TemplateLiteral' && n.expressions.length === 0) return n.quasis[0].value.cooked;
  throw Error(`Non-literal: ${n.type}`);
}
const files = (await readdir(directory)).filter(f => /\.(jsx|js)$/.test(f)).sort();
for (const name of [...files, '../pages/LumaAcademy.jsx']) {
  const path = name.startsWith('../pages/')
    ? resolve(root, 'src/pages/LumaAcademy.jsx') : resolve(directory, name);
  const text = await readFile(path, 'utf8');
  const file = basename(path);
  await copyFile(path, `${output}/legacy-source/${file}`);
  const entry = {file, sha256: createHash('sha256').update(text).digest('hex'), literalBlocks: [], questionCount: 0};
  const ast = parse(text, {sourceType: 'module', plugins: ['jsx']});
  for (const statement of ast.program.body) {
    const declaration = statement.type === 'ExportNamedDeclaration' ? statement.declaration : statement;
    if (declaration?.type !== 'VariableDeclaration') continue;
    for (const d of declaration.declarations) {
      if (!['QUESTIONS', 'DOMAINS', 'SECTIONS', 'FLASHCARD_DECKS'].includes(d.id.name)) continue;
      const value = literal(d.init); // Fail, rather than silently skip an unsupported content block.
      entry.literalBlocks.push(d.id.name);
      if (d.id.name !== 'QUESTIONS') {
        literals.push({file, name: d.id.name, reviewStatus, value});
        continue;
      }
      for (const [index, q] of value.entries()) {
        if (!q.q || !Array.isArray(q.options) || !Number.isInteger(q.answer)
            || q.answer < 0 || q.answer >= q.options.length || !q.rationale) {
          throw Error(`Invalid structure in ${file} question ${index + 1}`);
        }
        questions.push({
          id: `${file.replace(/\.(jsx|js)$/, '')}:${q.id ?? index + 1}`,
          sourceFile: file,
          sourceQuestion: q.id ?? index + 1,
          reviewStatus,
          original: q,
        });
        entry.questionCount++;
      }
    }
  }
  manifest.files.push(entry);
}
manifest.questionCount = questions.length;
manifest.fileCount = manifest.files.length;
if (new Set(questions.map(q => q.id)).size !== questions.length) throw Error('Duplicate import IDs');
for (const [name, value] of Object.entries({manifest, questions, literals})) {
  await writeFile(`${output}/${name}.json`, `${JSON.stringify(value, null, 2)}\n`);
}
console.log(JSON.stringify({files: manifest.fileCount, questions: questions.length, status: reviewStatus}));
