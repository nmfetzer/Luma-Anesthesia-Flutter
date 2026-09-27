// Owner-authorized, staged Course 2 content. CLI arguments stay below OS limits.
import fs from 'node:fs';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';
const project_id = 'xuckkusbbcxplpqclbxt';
export function call(tool, args) {
  let result;
  for (let attempt=0;attempt<5;attempt++) {
    try {
      result = JSON.parse(execFileSync('pplx', [
        'connector','call','supabase',tool,'--input',
        JSON.stringify({project_id,...args}),
      ],{encoding:'utf8',maxBuffer:1e7,timeout:90000,stdio:['ignore','pipe','pipe']}));
      break;
    } catch (error) {
      if (!String(error.stderr).includes('CONNECTOR_RATE_LIMITED')) {
        throw Error(`Connector ${tool} failed: ${String(error.stderr).slice(0,1000)}`);
      }
      console.log('Rate limit: waiting before retrying the rejected request.');
      Atomics.wait(new Int32Array(new SharedArrayBuffer(4)),0,0,15000*(attempt+1));
    }
  }
  if (!result) throw Error('Connector rate limit persists; safe to rerun this loader.');
  if (result.is_error || result.error) throw Error(JSON.stringify(result));
  while (typeof result.result === 'string' && result.result.trim().startsWith('{')) {
    result = JSON.parse(result.result);
  }
  if (result.error || result.success === false) throw Error(JSON.stringify(result));
  return result;
}
const sql = query => call('execute_sql',{query});
const quote = value => "'"+value.replaceAll("'","''")+"'";
function rows(result) {
  const match = result.result.match(/<untrusted-data-[^>]+>\s*(\[[\s\S]*?\])\s*<\/untrusted-data-/);
  if (!match) throw Error('Unexpected query result');
  return JSON.parse(match[1]);
}
function resource(id, value) {
  const text = JSON.stringify(value);
  const temporary = '__staging_'+id;
  const status=rows(sql(`select id,length(data#>>'{}') as length from public.ce_course2_resources
    where id in (${quote(id)},${quote(temporary)});`));
  if (status.some(row=>row.id===id)) {
    console.log(`Already loaded private ${id}`); return;
  }
  let start=status.find(row=>row.id===temporary)?.length ?? 0;
  if (!start) sql(`insert into public.ce_course2_resources(id,data) values(${quote(temporary)},'""'::jsonb)
       on conflict(id) do nothing;`);
  for (let i=start;i<text.length;i+=90000) {
    const part = text.slice(i,i+90000);
    sql(`do $$ begin
      assert (select length(data#>>'{}')=${i} from public.ce_course2_resources where id=${quote(temporary)});
      update public.ce_course2_resources set data=to_jsonb((data#>>'{}')||${quote(part)})
      where id=${quote(temporary)};
    end $$;`);
    Atomics.wait(new Int32Array(new SharedArrayBuffer(4)),0,0,1600);
  }
  const validation = id.endsWith('_pdf') ? `
    assert (select encode(sha256(decode(data->>'base64','base64')),'hex')=data->>'sha256'
      from public.ce_course2_resources where id=${quote(id)});` : '';
  sql(`begin;
    insert into public.ce_course2_resources(id,data)
      select ${quote(id)},(data#>>'{}')::jsonb from public.ce_course2_resources where id=${quote(temporary)}
      on conflict(id) do update set data=excluded.data;
    do $$ begin
      assert (select released=false from public.ce_course2_catalog where id='1047241');
      ${validation}
    end $$;
    delete from public.ce_course2_resources where id=${quote(temporary)};
    commit;`);
  console.log(`Loaded private ${id} (${text.length} characters)`);
}
if (process.argv.includes('--apply')) {
  const modules = JSON.parse(fs.readFileSync('../ce_halo_course2/production_manifest.json'));
  for (const m of modules) {
    const range=process.argv.find(a=>a.startsWith('--modules='))?.split('=')[1]?.split('-').map(Number);
    if (range && (m.n<range[0] || m.n>(range[1] ?? range[0]))) continue;
    const pdf = fs.readFileSync(m.learner);
    resource(`course2_module${m.n}_pdf`, {
      base64:pdf.toString('base64'),
      sha256:crypto.createHash('sha256').update(pdf).digest('hex'),
      filename:m.learner.split('/').at(-1),mime_type:'application/pdf',
    });
    resource(`course2_module${m.n}_questions`,JSON.parse(fs.readFileSync(m.payload)).questions);
  }
  if (process.argv.includes('--finish')) {
  const assets = {};
  for (const [key,path] of [
    ['standardTemplate','build/certificate-templates/course2-standard.pdf'],
    ['compactTemplate','build/certificate-templates/course2-compact.pdf'],
    ['fontBase64','assets/fonts/DejaVuSans.ttf'],
    ['signatureBase64','assets/branding/ce_halo_preview_signature.png'],
  ]) assets[key] = fs.readFileSync(path).toString('base64');
  resource('certificate_assets_v1',assets);
  sql(fs.readFileSync('supabase/seed/course2_catalog.sql','utf8'));
  console.log('Course 2 catalog activated for provider staging only. No release or purchases enabled.');
  }
}
