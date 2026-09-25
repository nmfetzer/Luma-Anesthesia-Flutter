// Run after regenerating public medication JSON. Deep Dives stay server-side.
import { readFileSync, writeFileSync } from 'node:fs';
const path = process.argv[2] || 'assets/data/medications.json';
const rows = JSON.parse(readFileSync(path, 'utf8'));
for (const row of rows) delete row.deep_dive_content;
writeFileSync(path, JSON.stringify(rows, null, 2) + '\n');
console.log(`Removed Deep Dive fields from ${rows.length} public medication records.`);
