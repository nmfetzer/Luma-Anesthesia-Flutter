// Owner review copy from verified live content; never creates new clinical text.
import fs from 'node:fs';
import assert from 'node:assert/strict';
const dir = 'docs/quick-reference-audit';
const rows = JSON.parse(fs.readFileSync(`${dir}/live-after.json`, 'utf8'));
const evidence = [
  ...fs.readFileSync(`${dir}/source-evidence.jsonl`, 'utf8').trim().split('\n').map(JSON.parse),
  ...fs.readFileSync(`${dir}/additional-evidence.jsonl`, 'utf8').trim().split('\n').map(JSON.parse),
  ...JSON.parse(fs.readFileSync(`${dir}/additional-label-extracts.json`, 'utf8')).results,
];
const urls = [...new Set(rows.flatMap(r => [...r.body.matchAll(/\]\((https?:\/\/[^)]+)\)/g)].map(m => m[1])))];
for (const url of urls) {
  assert.ok(evidence.some(e => e.url === url && !e.error && e.content?.length > 250), url);
}
const header = '# Luma Anesthesia Quick References: Clinical Sign-off Copy\n\n' +
  'Review date: September 27, 2026. This is the complete text read back from the live database after the audit corrections: 24 guides and 59 sections. It is a review copy, not a new clinical protocol or evidence of owner approval.\n\n' +
  'All guides are free. Adult scope applies except the explicitly pediatric PALS guide; individualize treatment and follow institutional policy. The separate audit report describes corrections, local-policy choices and limitations.\n\n';
let review = header;
for (const id of [...new Set(rows.map(r => r.reference_id))]) {
  const guide = rows.filter(r => r.reference_id === id);
  review += `## ${guide[0].reference_title}\n\n`;
  for (const row of guide) {
    // Nest original content headings below guide / section headings.
    const body = row.body.replace(/^(#{1,5}) /gm, '$1# ');
    review += `### ${row.title}\n\nContent version: ${row.version}. Section ID: \`${row.id}\`.\n\n${body}\n\n`;
  }
}
fs.writeFileSync(`${dir}/Luma-Quick-References-Clinical-Sign-off-Copy.md`, review.trimEnd() + '\n');
let register = '# Quick Reference Source Retrieval Register\n\n' +
  `Review date: September 27, 2026. All ${urls.length} unique URLs in the verified published content returned substantive source text during this audit. This records retrieval and review provenance, not independent clinical certification or a guarantee of future URL availability.\n\n` +
  '| Source | Retrieval |\n|---|---|\n';
for (const url of urls) {
  const row = evidence.find(e => e.url === url);
  const name = (row.title || new URL(url).hostname).replaceAll('|', '/').replaceAll('\n', ' ');
  register += `| [${name}](${url}) | Retrieved; ${row.content.length.toLocaleString()} characters of full text or targeted extract |\n`;
}
fs.writeFileSync(`${dir}/source-register.md`, register);
console.log(JSON.stringify({sections: rows.length, uniqueUrls: urls.length, reviewBytes: Buffer.byteLength(review)}));
