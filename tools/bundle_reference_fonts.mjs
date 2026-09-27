// Reproduce the exact fonts used by the pinned google_fonts dependency.
// Run after flutter pub get. No API credentials are required.
import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';
const root = path.resolve(import.meta.dirname, '..');
const pkg = JSON.parse(await fs.readFile(path.join(root, '.dart_tool/package_config.json')));
const entry = pkg.packages.find(p => p.name === 'google_fonts');
const packageRoot = new URL(entry.rootUri, `file://${root}/.dart_tool/`).pathname;
const dest = path.join(root, 'assets/fonts/offline');
await fs.mkdir(dest, { recursive: true });
const weights = {100:'Thin',200:'ExtraLight',300:'Light',400:'Regular',500:'Medium',600:'SemiBold',700:'Bold',800:'ExtraBold',900:'Black'};
for (const [family, method, part, licenseDir] of [
  ['Fraunces','fraunces','f','fraunces'], ['Inter','inter','i','inter'],
  ['JetBrainsMono','jetBrainsMono','j','jetbrainsmono'],
]) {
  const source = await fs.readFile(`${packageRoot}/lib/src/google_fonts_parts/part_${part}.dart`, 'utf8');
  const section = source.split(`static TextStyle ${method}(`)[1].split('return googleFontsTextStyle')[0];
  const variants = [...section.matchAll(/fontWeight: FontWeight.w(\d+),\s+fontStyle: FontStyle.(normal|italic),\s+\): GoogleFontsFile\(\s+'([a-f0-9]+)',\s+(\d+),/g)];
  if (variants.length < 10) throw new Error(`Font metadata not recognized: ${family}`);
  for (const [, weight, style, hash, size] of variants) {
    let suffix = weights[weight];
    if (style === 'italic') suffix = (weight === '400' ? '' : suffix) + 'Italic';
    const filename = `${family}-${suffix}.ttf`;
    const response = await fetch(`https://fonts.gstatic.com/s/a/${hash}.ttf`);
    if (!response.ok) throw new Error(`${filename}: ${response.status}`);
    const bytes = Buffer.from(await response.arrayBuffer());
    if (bytes.length !== Number(size) || crypto.createHash('sha256').update(bytes).digest('hex') !== hash)
      throw new Error(`Font integrity failure: ${filename}`);
    await fs.writeFile(path.join(dest, filename), bytes);
  }
  const license = await fetch(`https://raw.githubusercontent.com/google/fonts/main/ofl/${licenseDir}/OFL.txt`);
  if (!license.ok) throw new Error(`Missing license: ${family}`);
  await fs.writeFile(path.join(dest, `${family}-OFL.txt`), await license.text());
  console.log(`${family}: ${variants.length} verified font files and license`);
}
