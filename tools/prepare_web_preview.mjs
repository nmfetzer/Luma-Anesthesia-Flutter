// Run after: flutter build web --release -t lib/preview_main.dart
// Preview hosting may mount the bundle below a nested URL rather than "/".
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
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
// pdfrx keeps fonts in memory during a worker session already. Its optional
// persistent font cache is unavailable inside this preview host. Return the
// library's documented "no database" value; loadAll/put/clear handle it safely.
// This only touches generated preview files, never production/native sources.
const workerPath = resolve(directory, 'assets/packages/pdfrx/assets/pdfium_worker.js');
if (existsSync(workerPath)) {
  const worker = readFileSync(workerPath, 'utf8');
  if (worker.includes('indexedDB')) {
    const start = worker.indexOf('  async open() {', worker.indexOf('class PdfFontPersistentCache {'));
    const end = worker.indexOf('  async loadAll() {', start);
    if (start < 0 || end < start ||
        !worker.slice(start, end).includes('indexedDB.open(this.dbName, 1)')) {
      throw new Error('Unexpected PDF font cache; review preview compatibility.');
    }
    writeFileSync(workerPath, worker.slice(0, start) +
      '  async open() { return null; }\n\n' + worker.slice(end));
  }
}
// RevenueCat's web plugin eagerly loads its bundled checkout library even
// though LumaBilling deliberately disables checkout on web. Do not ship that
// unused storage-dependent SDK in an embedded preview. A no-op asset lets the
// plugin's load event finish, but intentionally provides no checkout API.
// Keep the real bundle untouched in native / production builds.
const purchasesPath = resolve(directory,
  'assets/packages/purchases_flutter/assets/web/purchases_js_hybrid_mappings.js');
if (existsSync(purchasesPath)) {
  const billing = readFileSync(resolve('lib/billing/revenuecat_billing.dart'), 'utf8');
  if (!billing.includes('if (!RevenueCatConfig.enabled || kIsWeb) return;')) {
    throw new Error('Web billing guard changed; review preview checkout isolation.');
  }
  writeFileSync(purchasesPath,
    '// Embedded preview: checkout is disabled by LumaBilling; no web SDK loaded.\n');
}
console.log('Prepared Flutter preview for nested hosting.');
