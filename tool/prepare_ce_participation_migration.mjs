// Mechanical derivation preserves the existing learning/award API behavior.
import fs from 'node:fs';
import assert from 'node:assert/strict';
const change = (text, before, after) => {
  assert.equal(text.split(before).length, 2, `Expected one anchor: ${before}`);
  return text.replace(before, after);
};
const helper = `-- Registration participation dates are distinct from verified completion.
-- No release flag, purchase, signature approval or issued award is changed.
create or replace function public.ce_course1_participation_error(
  p_start text, p_end text, p_preview boolean default false
) returns text language plpgsql stable set search_path = '' as $$
declare first_day date; last_day date;
begin
  if coalesce(p_start,'')='' and coalesce(p_end,'')='' then return null; end if;
  if coalesce(p_start,'') !~ '^\\d{4}-\\d{2}-\\d{2}$'
    or coalesce(p_end,'') !~ '^\\d{4}-\\d{2}-\\d{2}$' then
    return 'Enter both participation dates as YYYY-MM-DD.';
  end if;
  begin
    first_day := p_start::date; last_day := p_end::date;
  exception when others then return 'Enter valid calendar dates.'; end;
  if first_day < date '2026-10-01' or last_day > date '2029-09-30' then
    return 'Participation dates must fall between 2026-10-01 and 2029-09-30.';
  end if;
  if first_day > last_day then return 'End date cannot be before start date.'; end if;
  if not p_preview and last_day > (now() at time zone 'America/New_York')::date then
    return 'Enter actual participation dates, not future dates.';
  end if;
  return null;
end;
$$;
revoke all on function public.ce_course1_participation_error(text,text,boolean) from public,anon,authenticated;
`;
// Avoid JavaScript string escape handling in SQL regex.
const safeHelper = helper.replaceAll("^d{4}-d{2}-d{2}$", "^[0-9]{4}-[0-9]{2}-[0-9]{2}$");
let learning = fs.readFileSync('supabase/migrations/20260927120000_course1_multi_module.sql','utf8');
learning = learning.slice(learning.indexOf('create or replace function'));
learning = change(learning, 'resource_prefix text; expected_ratings int;',
  'resource_prefix text; expected_ratings int;\n  participation_start text; participation_end text; date_error text;');
learning = change(learning, "  if p_action='profile' then", `  if p_action='profile' then
    participation_start := btrim(coalesce(p_payload->>'participation_start_on',s.profile->>'participation_start_on',''));
    participation_end := btrim(coalesce(p_payload->>'participation_end_on',s.profile->>'participation_end_on',''));
    date_error := public.ce_course1_participation_error(participation_start,participation_end,reviewer);
    if date_error is not null then raise exception '%',date_error; end if;`);
learning = change(learning,
  "'aana_id',btrim(coalesce(p_payload->>'aana_id','')),'location',btrim(p_payload->>'location'))",
  "'aana_id',btrim(coalesce(p_payload->>'aana_id','')),'location',btrim(p_payload->>'location'),\n      'participation_start_on',participation_start,'participation_end_on',participation_end)");
let certificate = fs.readFileSync('supabase/migrations/20260927160000_course1_certificates.sql','utf8');
certificate = certificate.slice(certificate.indexOf('create function public.ce_course1_certificate'));
certificate = change(certificate, 'create function public.ce_course1_certificate', 'create or replace function public.ce_course1_certificate');
certificate = change(certificate, '        learner := p->\'completion\'->\'learner\';',
  '        -- Keep completion timestamp; registration fields remain editable until issuance.');
certificate = change(certificate, "    else null end;", `    when coalesce(s.profile->>'participation_start_on','')=''
      or coalesce(s.profile->>'participation_end_on','')=''
      then 'Add your participation dates using Edit course registration.'
    when public.ce_course1_participation_error(s.profile->>'participation_start_on',s.profile->>'participation_end_on',false) is not null
      then public.ce_course1_participation_error(s.profile->>'participation_start_on',s.profile->>'participation_end_on',false)
    when (s.profile->>'participation_start_on')::date > (first_at at time zone 'America/New_York')::date
      or (s.profile->>'participation_end_on')::date < (last_at at time zone 'America/New_York')::date
      then 'Participation dates must include your recorded course activity and completion.'
    else null end;`);
certificate = change(certificate, "    'completed_at',case when p_action='preview' then null else last_at end,",
  `    'completed_at',case when p_action='preview' then null else last_at end,
    'participation_start_on',s.profile->>'participation_start_on',
    'participation_end_on',s.profile->>'participation_end_on',
    'participation_dates_source','registration',`);
fs.writeFileSync('supabase/migrations/20260927180000_course1_participation_dates.sql',
  safeHelper + '\n' + learning + '\n' + certificate);
console.log('Prepared additive participation-date migration.');
