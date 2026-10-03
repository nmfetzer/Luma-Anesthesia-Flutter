// Import public reference metadata only. Never commit the raw Base44 exports.
// Usage: node tools/import_practice_guidelines.mjs /path/to/private/exports
import fs from 'node:fs';
import path from 'node:path';
const root = process.argv[2];
if (!root) throw new Error('Provide the directory containing asa/aana/caa.json');
const hosts = new Set([
  'www.asahq.org', 'pubs.asahq.org', 'doi.org', 'www.aana.com',
  'www.anesthetist.org', 'nccaa.org', 'www.arc-aa.org',
]);
function safeUrl(value) {
  const url = new URL(value);
  if (url.protocol !== 'https:' || !hosts.has(url.hostname) ||
      url.username || url.password || url.port) throw new Error(`Unsafe URL: ${value}`);
  return value;
}
const rows = ['ASA', 'AANA', 'CAA'].flatMap(organization =>
  JSON.parse(fs.readFileSync(path.join(root, `${organization.toLowerCase()}.json`), 'utf8'))
    .map(row => ({
      id: `${organization.toLowerCase()}-${row.id}`,
      organization,
      publisher: row.source || organization,
      title: row.title.trim(),
      category: row.category.trim(),
      url: safeUrl(row.url),
      hub_url: safeUrl(row.hub_url || 'https://www.asahq.org/standards-and-practice-parameters'),
      link_kind: row.link_type === 'search' ? 'search'
        : new URL(row.url).pathname.toLowerCase().endsWith('.pdf') ? 'pdf' : 'page',
      keywords: row.keywords || '',
    })));
if (rows.length !== 229 || new Set(rows.map(r => r.id)).size !== 229) {
  throw new Error('Unexpected catalog size or duplicate identifiers');
}
fs.writeFileSync('assets/data/practice_guidelines.json', JSON.stringify(rows, null, 2) + '\n');
const quote = value => `'${value.replaceAll("'", "''")}'`;
const columns = Object.keys(rows[0]);
const migration = `-- Public publisher-link directory. No clinical text or personal data.
-- Additive import; does not modify entitlements, users, or existing references.
begin;
create table if not exists public.practice_guidelines (
  id text primary key,
  organization text not null check (organization in ('ASA','AANA','CAA')),
  publisher text not null,
  title text not null,
  category text not null,
  url text not null check (url like 'https://%'),
  hub_url text not null check (hub_url like 'https://%'),
  link_kind text not null check (link_kind in ('page','pdf','search')),
  keywords text not null default ''
);
alter table public.practice_guidelines enable row level security;
revoke all on public.practice_guidelines from anon, authenticated;
grant select on public.practice_guidelines to anon, authenticated;
grant all on public.practice_guidelines to service_role;
drop policy if exists practice_guidelines_public_read on public.practice_guidelines;
create policy practice_guidelines_public_read on public.practice_guidelines
  for select to anon, authenticated using (true);
insert into public.practice_guidelines (${columns.join(', ')}) values
${rows.map(row => '(' + columns.map(key => quote(row[key])).join(', ') + ')').join(',\n')}
on conflict (id) do update set
${columns.filter(key => key !== 'id').map(key => `  ${key} = excluded.${key}`).join(',\n')};
commit;
`;
fs.writeFileSync('supabase/migrations/20261003180000_practice_guidelines.sql', migration);
console.log(JSON.stringify({
  imported: rows.length,
  organizations: Object.fromEntries(['ASA', 'AANA', 'CAA'].map(org =>
    [org, rows.filter(row => row.organization === org).length])),
  searchLinks: rows.filter(row => row.link_kind === 'search').length,
}));
