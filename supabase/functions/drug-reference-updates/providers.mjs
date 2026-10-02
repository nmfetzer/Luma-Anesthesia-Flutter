// Public reference metadata only. Never rewrite reviewed clinical content.
export const FDA_DATABASE = 'https://dps.fda.gov/drugshortages';
export const DAILYMED_HOME = 'https://dailymed.nlm.nih.gov/dailymed/';

export function searchName(name) {
  return String(name).split(/\s[—–]\s/)[0].replace(/\([^)]*\)/g, '')
    .replace(/[^a-zA-Z0-9 /+-]/g, ' ').replace(/\s+/g, ' ').trim().slice(0, 120);
}

export function sourceLinks(name) {
  const query = searchName(name);
  return {
    fda: FDA_DATABASE,
    dailymed: `${DAILYMED_HOME}search.cfm?query=${encodeURIComponent(query)}`,
  };
}

const text = value => typeof value === 'string' ? value.slice(0, 3000) : '';
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

async function jsonResponse(url, fetcher, fda = false) {
  const response = await fetcher(url, {signal: AbortSignal.timeout(10000)});
  const body = await response.json();
  if (fda && response.status === 404 && body?.error?.code === 'NOT_FOUND') {
    return {results: [], meta: {results: {total: 0}}};
  }
  if (!response.ok) throw new Error('Provider unavailable');
  return body;
}

export async function fetchFda(query, fetcher = fetch, apiKey = '') {
  const url = new URL('https://api.fda.gov/drug/shortages.json');
  url.searchParams.set('search', `generic_name:"${query}"`);
  url.searchParams.set('limit', '100');
  url.searchParams.set('sort', 'update_date:desc');
  if (apiKey) url.searchParams.set('api_key', apiKey);
  const body = await jsonResponse(url, fetcher, true);
  if (!Array.isArray(body.results)) throw new Error('Invalid FDA response');
  const score = row => {
    const name = text(row.generic_name).toLowerCase();
    return name.startsWith(query.toLowerCase()) &&
      !/[,]| and | with /.test(name) ? 1 : 0;
  };
  // Rank simpler named products first, but still label every result as a
  // possible match; ingredient/strength/manufacturer are not auto-verified.
  const rows = [...body.results].sort((a, b) => score(b) - score(a)).slice(0, 20).map(row => {
    // Package-level query avoids claiming that every formulation is affected.
    const record = new URL('https://api.fda.gov/drug/shortages.json');
    record.searchParams.set('search', row.package_ndc
      ? `package_ndc:"${text(row.package_ndc).replace(/[^0-9-]/g, '')}"`
      : `generic_name:"${query}"`);
    record.searchParams.set('limit', '100');
    return {
      title: text(row.generic_name),
      presentation: text(row.presentation),
      company: text(row.company_name),
      ndc: text(row.package_ndc),
      status: text(row.status),
      availability: text(row.availability),
      updated: text(row.update_date),
      reason: text(row.shortage_reason),
      notes: text(row.related_info),
      url: record.toString(),
    };
  });
  return {
    state: 'ok', checked_at: new Date().toISOString(),
    source_updated: text(body.meta?.last_updated),
    total: Number(body.meta?.results?.total ?? rows.length),
    rows,
  };
}

export async function fetchDailyMed(query, fetcher = fetch) {
  const url = new URL(`${DAILYMED_HOME}services/v2/spls.json`);
  url.searchParams.set('drug_name', query);
  // LOINC human prescription drug label. Never mix veterinary product labels
  // into an anesthesia prescribing-information panel.
  url.searchParams.set('doctype', '34391-3');
  url.searchParams.set('pagesize', '20');
  const body = await jsonResponse(url, fetcher);
  if (!Array.isArray(body.data)) throw new Error('Invalid DailyMed response');
  const rows = body.data.filter(row => uuid.test(row.setid ?? '')).map(row => ({
    title: text(row.title), updated: text(row.published_date),
    setid: row.setid, version: String(row.spl_version ?? ''),
    url: `${DAILYMED_HOME}drugInfo.cfm?setid=${row.setid}`,
  }));
  // A schema/identifier problem is not evidence that no label exists.
  if (body.data.length && !rows.length) throw new Error('Invalid label identifiers');
  return {
    state: 'ok', checked_at: new Date().toISOString(),
    source_updated: text(body.metadata?.db_published_date),
    total: Number(body.metadata?.total_elements ?? rows.length),
    rows,
  };
}

export function retainOnFailure(previous) {
  return previous?.state === 'ok' && Array.isArray(previous.rows)
    ? {...previous, refresh_failed: true}
    : {state: 'unavailable', rows: [], refresh_failed: true};
}

export async function refreshSources(name, previous = {}, fetcher = fetch, apiKey = '') {
  const query = searchName(name);
  if (query.length < 2) throw new Error('Unsupported medication name');
  const settled = await Promise.allSettled([
    fetchFda(query, fetcher, apiKey), fetchDailyMed(query, fetcher),
  ]);
  const pick = (i, key) => settled[i].status === 'fulfilled'
    ? settled[i].value : retainOnFailure(previous[key]);
  return {
    schema: 1, query, links: sourceLinks(name),
    fda: pick(0, 'fda'), dailymed: pick(1, 'dailymed'),
  };
}
