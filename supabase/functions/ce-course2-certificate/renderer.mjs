import { PDFDocument } from 'pdf-lib';
import fontkit from '@pdf-lib/fontkit';
import { loadAssets } from './private_assets.mjs';

const decode = value => Uint8Array.from(atob(value), c => c.charCodeAt(0));
const date = value => {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value ?? '')) throw Error('Missing certificate date');
  const [y,m,d] = value.split('-');
  return `${Number(m)}/${Number(d)}/${y}`;
};
export async function renderCertificate(record) {
  const { standardTemplate, compactTemplate, fontBase64, signatureBase64 } = await loadAssets();
  if (record.is_preview !== false || record.credits_awarded !== 20 ||
      record.course_id !== '1047241' || record.template_version !== 'cehalo-course2-v1' ||
      !/^[0-9a-f-]{36}$/.test(record.id ?? '') ||
      record.signature_png_base64 !== signatureBase64 ||
      record.provider_city_state !== 'Buffalo, New York' ||
      record.signer_name !== 'Nicole M. Fetzer, MS, CRNA' ||
      record.signer_title !== 'Owner, CE HALO LLC') throw Error('Unsupported official certificate snapshot');
  const p = record.learner;
  for (const [key, max] of [['full_name',150],['credentials',100],['location',300]]) {
    if (typeof p?.[key] !== 'string' || !p[key].trim() || p[key].length > max) throw Error('Invalid learner fields');
  }
  if ((p.aana_id ?? '').length > 60) throw Error('Invalid AANA ID');
  // Use the compact approved layout for wrapping, including long words.
  const compact = p.full_name.length + p.credentials.length > 55 || p.location.length > 55;
  const doc = await PDFDocument.load(decode(compact ? compactTemplate : standardTemplate));
  doc.registerFontkit(fontkit);
  const font = await doc.embedFont(decode(fontBase64), {subset:true});
  const form = doc.getForm();
  const fields = {
    'Name:': `${p.full_name}, ${p.credentials}`,
    'AANA ID Number:': p.aana_id || 'Not applicable',
    'Participation Dates:': `${date(record.participation_start_on)} to ${date(record.participation_end_on)}`,
    'Completion Date:': date(record.completed_on),
    'Location of Completion:': p.location,
    certificate_id: `Certificate ID: ${record.id}`,
  };
  for (const [key,value] of Object.entries(fields)) {
    const field = form.getTextField(key);
    field.enableMultiline();
    field.setText(value);
    field.setFontSize(compact || key === 'certificate_id' ? 9 : 10);
    field.updateAppearances(font);
  }
  form.flatten();
  doc.setTitle('CE HALO Course 2 Certificate of Completion');
  doc.setAuthor('Perplexity Computer');
  return doc.save();
}
