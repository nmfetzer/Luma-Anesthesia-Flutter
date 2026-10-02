import {test} from 'node:test';
import assert from 'node:assert/strict';
import {fetchFda, fetchDailyMed, refreshSources, searchName} from './providers.mjs';

const response = (data, status = 200) => new Response(JSON.stringify(data), {status});
const label = {setid: '12345678-1234-1234-1234-123456789abc',
  title: 'HUMAN DRUG INJECTION [MANUFACTURER]', published_date: 'Oct 1, 2026', spl_version: 2};
const fda = {meta: {last_updated: '2026-10-01', results: {total: 99}},
  results: [{generic_name: 'Epinephrine injection', package_ndc: '12345-001-01',
    status: 'Current', availability: 'Available', company_name: 'Example',
    update_date: '10/01/2026', presentation: '1 mg/mL'}]};

test('conservative queries remove UI annotations but retain combination names', () => {
  assert.equal(searchName('Propofol (Diprivan)'), 'Propofol');
  assert.equal(searchName('Lidocaine with Epinephrine (combination)'), 'Lidocaine with Epinephrine');
  assert.equal(searchName('Racemic Epinephrine (Nebulized) — Post-Extubation'), 'Racemic Epinephrine');
  assert.equal(searchName('x:" OR *'), 'x OR');
});
test('FDA separates report status from individual product availability and retains truncation', async () => {
  const data = await fetchFda('Epinephrine', async url => {
    assert.equal(url.hostname, 'api.fda.gov');
    assert.equal(url.searchParams.get('search'), 'generic_name:"Epinephrine"');
    return response(fda);
  });
  assert.equal(data.rows[0].status, 'Current');
  assert.equal(data.rows[0].availability, 'Available');
  assert.equal(data.total, 99);
  assert.match(data.rows[0].url, /package_ndc/);
  assert.equal(data.source_updated, '2026-10-01');
});
test('FDA no-match is distinguished from service, auth and schema errors', async () => {
  assert.equal((await fetchFda('None', async () =>
    response({error: {code: 'NOT_FOUND'}}, 404))).rows.length, 0);
  for (const code of [401, 429, 500]) {
    await assert.rejects(fetchFda('Drug', async () => response({}, code)));
  }
  await assert.rejects(fetchFda('Drug', async () => response({})));
});
test('DailyMed requests human prescription document type and safe direct label URLs', async () => {
  const data = await fetchDailyMed('Propofol', async url => {
    assert.equal(url.searchParams.get('doctype'), '34391-3');
    return response({data: [label], metadata: {total_elements: 21, db_published_date: 'Oct 1'}});
  });
  assert.equal(data.total, 21);
  assert.equal(new URL(data.rows[0].url).hostname, 'dailymed.nlm.nih.gov');
  assert.equal(data.rows[0].version, '2');
});
test('DailyMed rejects malformed schema and malicious set IDs', async () => {
  await assert.rejects(fetchDailyMed('Drug', async () => response({data: [{}]})));
  await assert.rejects(fetchDailyMed('Drug', async () => response({})));
  const empty = await fetchDailyMed('Drug', async () => response({data: [], metadata: {total_elements: 0}}));
  assert.equal(empty.total, 0);
});
test('partial outage retains old data and its original checked date', async () => {
  const old = {state: 'ok', checked_at: '2026-09-01T00:00:00Z', rows: [{title: 'saved'}]};
  const data = await refreshSources('Drug', {fda: old}, async url => {
    if (url.hostname === 'api.fda.gov') return response({}, 429);
    return response({data: [label]});
  });
  assert.equal(data.fda.refresh_failed, true);
  assert.equal(data.fda.checked_at, old.checked_at);
  assert.equal(data.dailymed.state, 'ok');
});
test('both failures are unavailable, not empty successful results', async () => {
  const data = await refreshSources('Drug', {}, async () => {throw new Error('offline');});
  assert.equal(data.fda.state, 'unavailable');
  assert.equal(data.dailymed.state, 'unavailable');
});
