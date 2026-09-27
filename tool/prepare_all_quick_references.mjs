// Run from repository root. Rebuilds seeds and a server-side test fixture only.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import {rows as preop} from './prepare_quick_reference_seed.mjs';
import {rows as cied} from './prepare_cied_quick_reference_seed.mjs';
import {rows as antihypertensive} from './prepare_antihypertensive_seed.mjs';
import {rows as hypotension} from './prepare_hypotension_seed.mjs';
import {rows as beta} from './prepare_beta_blocker_seed.mjs';
import {rows as remaining} from './prepare_remaining_quick_reference_seed.mjs';
const rows = [...preop, ...cied, ...antihypertensive, ...hypotension, ...beta, ...remaining];
assert.equal(rows.length, 59);
assert.equal(new Set(rows.map(r => r.id)).size, 59);
assert.equal(new Set(rows.map(r => r.reference_id)).size, 24);
fs.writeFileSync('supabase/seeds/all_quick_references.json', JSON.stringify(rows, null, 2) + '\n');
console.log('Prepared all 59 sections / 24 guides. Database unchanged.');
