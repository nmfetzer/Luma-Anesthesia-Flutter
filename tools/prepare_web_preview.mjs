// Run after: flutter build web --release -t lib/preview_main.dart
// Preview hosting may mount the bundle below a nested URL rather than "/".
import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

const directory = process.argv[2] || 'build/web';
const indexPath = resolve(directory, 'index.html');
const html = readFileSync(indexPath, 'utf8');
if (!/<base href="[^"]*">/.test(html)) {
  throw new Error('Expected Flutter base element not found; preview unchanged.');
}
writeFileSync(indexPath, html.replace(/<base href="[^"]*">/, '<base href="./">'));
// Embedded previews block service workers. Use the bundled renderer as well,
// so startup does not depend on a separate Google-hosted renderer download.
const bootstrapPath = resolve(directory, 'flutter_bootstrap.js');
const bootstrap = readFileSync(bootstrapPath, 'utf8');
const workerSettings = /serviceWorkerSettings:\s*\{[^}]*\}/;
if (!workerSettings.test(bootstrap) && !bootstrap.includes("canvasKitBaseUrl: 'canvaskit/'")) {
  throw new Error('Unexpected Flutter bootstrap; review preview initialization.');
}
writeFileSync(
  bootstrapPath,
  bootstrap.replace(workerSettings, "config: { canvasKitBaseUrl: 'canvaskit/' }"),
);
// Flutter dependencies can retain web-storage code even when Supabase is
// configured with EmptyLocalStorage. Embedded preview sessions must remain
// memory-only. Replace those dependency accessors with a real transient adapter;
// never apply this transformation to the native or production web builds.
const dartPath = resolve(directory, 'main.dart.js');
const dart = readFileSync(dartPath, 'utf8');
const memoryStorage = `(() => {
  const values = new Map();
  window.lumaPreviewMemoryStorage = {
    get length() { return values.size; },
    key(index) { return Array.from(values.keys())[index] ?? null; },
    getItem(key) { return values.get(String(key)) ?? null; },
    setItem(key, value) { values.set(String(key), String(value)); },
    removeItem(key) { values.delete(String(key)); },
    clear() { values.clear(); }
  };
})();\n`;
if (dart.includes('localStorage')) {
  writeFileSync(dartPath,
    memoryStorage + dart.replaceAll('localStorage', 'lumaPreviewMemoryStorage'));
}
console.log('Prepared Flutter preview for nested hosting.');
