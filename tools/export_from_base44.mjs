// -----------------------------------------------------------------------------
// export_from_base44.mjs
//
// Pulls every Medication record from your Base44 app and saves them to
// assets/data/medications-full.json ready for import.
//
// USAGE
//   cd tools && npm install
//   cd ..
//   export BASE44_APP_ID="6a35a143e93e5ed18ad346be"
//   export BASE44_TOKEN="b44u_..."
//   node tools/export_from_base44.mjs
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

console.log("Pulling every Medication record from Base44…");
const rows = await base44.entities.Medication.list();
console.log(`Received ${rows.length} rows.`);

await mkdir("assets/data", { recursive: true });
await writeFile(
  "assets/data/medications-full.json",
  JSON.stringify(rows, null, 2),
);

console.log(`\nDone. ${rows.length} medications saved to`);
console.log(`  assets/data/medications-full.json`);
console.log("\nNext step:");
console.log("  node tools/import_to_supabase.mjs assets/data/medications-full.json");
