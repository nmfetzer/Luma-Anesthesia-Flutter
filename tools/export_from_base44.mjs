// -----------------------------------------------------------------------------
// export_from_base44.mjs
//
// Pulls every Medication record from your Base44 app using the official SDK
// and saves them to assets/data/medications-full.json ready for import.
//
// USAGE
//   cd tools && npm install
//   cd ..
//   node tools/export_from_base44.mjs
//
// Credentials are read from environment variables — never commit them.
//   export BASE44_APP_ID="6a35a143e93e5ed18ad346be"
//   export BASE44_TOKEN="b44u_..."
// -----------------------------------------------------------------------------

import { writeFile, mkdir } from "node:fs/promises";
import { createClient } from "@base44/sdk";

const appId = process.env.BASE44_APP_ID;
const token = process.env.BASE44_TOKEN;

if (!appId || !token) {
  console.error(
    "Set BASE44_APP_ID and BASE44_TOKEN environment variables first.",
  );
  process.exit(1);
}

const base44 = createClient({
  appId,
  headers: {
    Authorization: `Bearer ${token}`,
  },
});

console.log("Connecting to Base44…");

let rows = [];

// The SDK exposes entities as base44.entities.<EntityName> in most versions.
// Try a few common shapes so we're robust to SDK differences.
try {
  const entity = base44.entities?.Medication ?? base44.entity?.("Medication");
  if (!entity) throw new Error("Could not find Medication entity on client");

  // Try list() with pagination — most Base44 SDK builds support this
  let page = 1;
  const pageSize = 200;
  while (true) {
    let batch;
    try {
      batch = await entity.list({ page, limit: pageSize });
    } catch (err) {
      // Some SDK builds use .find() instead
      batch = await entity.find({ page, limit: pageSize });
    }
    const items = Array.isArray(batch) ? batch : batch?.data ?? batch?.items ?? [];
    if (items.length === 0) break;
    rows.push(...items);
    console.log(`  page ${page} · +${items.length} (total ${rows.length})`);
    if (items.length < pageSize) break;
    page += 1;
    if (page > 20) break; // safety valve
  }
} catch (err) {
  console.error("\nBase44 SDK call failed:", err.message);
  console.error("Full error:", err);
  process.exit(1);
}

if (rows.length === 0) {
  console.error("Zero rows returned — the token or app id may be wrong.");
  process.exit(1);
}

await mkdir("assets/data", { recursive: true });
await writeFile(
  "assets/data/medications-full.json",
  JSON.stringify(rows, null, 2),
);

console.log(`\nDone. ${rows.length} medications saved to`);
console.log(`  assets/data/medications-full.json`);
console.log("\nNext step: run the schema migration in Supabase, then:");
console.log("  node tools/import_to_supabase.mjs assets/data/medications-full.json");
