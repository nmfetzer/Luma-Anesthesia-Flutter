import fs from 'node:fs';
const asset = p => fs.readFileSync(p).toString('base64');
// Course 2 uses the same generated templates via a private versioned resource.
// Its loader avoids embedding multi-megabyte assets in each edge deployment.
for(const course of [1]){
const dir=`supabase/functions/ce-course${course}-certificate`;
fs.mkdirSync(dir,{recursive:true});
const target = `${dir}/assets.mjs`;
const data = {
  standardTemplate:asset(`build/certificate-templates/course${course}-standard.pdf`),
  compactTemplate:asset(`build/certificate-templates/course${course}-compact.pdf`),
  fontBase64:asset('assets/fonts/DejaVuSans.ttf'),
  signatureBase64:asset('assets/branding/ce_halo_preview_signature.png'),
};
fs.writeFileSync(target,'// Generated server-only assets from approved Flutter layout. Do not edit.\n'+
  Object.entries(data).map(([key,value])=>`export const ${key}=${JSON.stringify(value)};`).join('\n'));
console.log('Prepared versioned server-only certificate templates and font.');
}
