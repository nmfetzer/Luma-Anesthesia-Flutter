// -----------------------------------------------------------------------------
// import_to_supabase.mjs
//
// Bulk-imports a JSON array of medications into your Supabase `medication`
// table. Uses upsert by `id`, so it's safe to re-run when data changes.
//
// USAGE
//   1. Export your Base44 Medication entity to a JSON array file. The file
//      should be a top-level array of objects using the same field names as
//      lib/models/medication.dart (id, name, brand_name, class_short,
//      category, high_alert, dea_schedule, adult_dose, peds_dose,
//      onset_duration, black_box_warning).
//   2. Grab the SERVICE ROLE key from
//        Supabase → Settings → API → Project API keys → service_role (secret)
//      This key bypasses Row Level Security. NEVER commit it.
//   3. Run:
//        export SUPABASE_URL="https://xuckkusbbcxplpqclbxt.supabase.co"
//        export SUPABASE_SERVICE_KEY="paste_service_role_here"
//        node tools/import_to_supabase.mjs assets/data/medications.json
// -----------------------------------------------------------------------------

import { readFile } from "node:fs/promises";
import { createClient } from "@supabase/supabase-js";

const [, , inputPath] = process.argv;
if (!inputPath) {
  console.error("Usage: node tools/import_to_supabase.mjs <path-to-json>");
  process.exit(1);
}

const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_SERVICE_KEY;
if (!url || !key) {
  console.error(
    "Set SUPABASE_URL and SUPABASE_SERVICE_KEY environment variables first."
  );
  process.exit(1);
}

const raw = await readFile(inputPath, "utf8");
const rows = JSON.parse(raw);
if (!Array.isArray(rows)) {
  console.error("Expected a top-level JSON array.");
  process.exit(1);
}

const supabase = createClient(url, key, {
  auth: { persistSession: false },
});

const BATCH = 500;
let inserted = 0;
for (let i = 0; i < rows.length; i += BATCH) {
  const chunk = rows.slice(i, i + BATCH).map((r) => ({
    id: String(r.id ?? r.slug ?? r.name).toLowerCase().replace(/\s+/g, "-"),
    name: r.name,
    brand_name: r.brand_name ?? null,
    class_short: r.class_short ?? null,
    category: r.category,
    high_alert: !!r.high_alert,
    dea_schedule: r.dea_schedule ?? "non_scheduled",
    adult_dose: r.adult_dose ?? null,
    peds_dose: r.peds_dose ?? null,
    onset_duration: r.onset_duration ?? null,
    black_box_warning: r.black_box_warning ?? null,
  }));

  const { error } = await supabase
    .from("medication")
    .upsert(chunk, { onConflict: "id" });
  if (error) {
    console.error(`Batch ${i}-${i + chunk.length} failed:`, error.message);
    process.exit(1);
  }
  inserted += chunk.length;
  console.log(`Upserted ${inserted} / ${rows.length}`);
}

console.log(`Done. ${inserted} medications imported.`);
