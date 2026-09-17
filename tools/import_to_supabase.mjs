// -----------------------------------------------------------------------------
// import_to_supabase.mjs
//
// Bulk-imports the full Base44 Medication export into your Supabase
// `medication` table. Handles every field from the expanded schema.
// Uses upsert by `id`, so re-running is safe.
//
// USAGE
//   1. Run the schema migration first:
//        Paste supabase/002_expand_medication_schema.sql into Supabase SQL Editor
//   2. Grab the SERVICE ROLE key from
//        Supabase → Settings → API → Project API keys → service_role (secret)
//      Never commit this key.
//   3. Run:
//        export SUPABASE_URL="https://xuckkusbbcxplpqclbxt.supabase.co"
//        export SUPABASE_SERVICE_KEY="paste_service_role_here"
//        node tools/import_to_supabase.mjs assets/data/medications-full.json
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
    "Set SUPABASE_URL and SUPABASE_SERVICE_KEY environment variables first.",
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

// Coerce a Base44 record into our Supabase column shape.
function mapRow(r) {
  const asString = (v) => (v == null || v === "" ? null : String(v));
  const asArray = (v) => (Array.isArray(v) ? v : v ? [v] : null);
  const asJson = (v) => (v == null ? null : v);
  const asNum = (v) => {
    if (v == null || v === "") return null;
    const n = Number(v);
    return Number.isFinite(n) ? n : null;
  };
  const asBool = (v) => (typeof v === "boolean" ? v : !!v);

  return {
    id: String(r.id ?? r.slug ?? r.name).toLowerCase().replace(/\s+/g, "-"),
    name: r.name,
    brand_name: asString(r.brand_name),
    class_short: asString(r.class_short),
    classification: asString(r.classification),
    category: r.category,
    secondary_categories: asArray(r.secondary_categories),
    high_alert: asBool(r.high_alert),
    dea_schedule: asString(r.dea_schedule) ?? "non_scheduled",
    black_box_warning: asString(r.black_box_warning),
    lasa_warning: asString(r.lasa_warning),
    indications: asString(r.indications),
    mechanism: asString(r.mechanism),
    adult_dose: asString(r.adult_dose),
    peds_dose: asString(r.peds_dose),
    dose_mg_per_kg_min: asNum(r.dose_mg_per_kg_min),
    dose_mg_per_kg_max: asNum(r.dose_mg_per_kg_max),
    dose_unit: asString(r.dose_unit),
    is_infusion: asBool(r.is_infusion),
    concentration_mixing: asString(r.concentration_mixing),
    requires_dilution: asBool(r.requires_dilution),
    target_concentration: asString(r.target_concentration),
    standard_recipe: asString(r.standard_recipe),
    final_volume_ml: asNum(r.final_volume_ml),
    diluent: asString(r.diluent),
    alternative_concentrations: asString(r.alternative_concentrations),
    stability_hours_room_temp: asNum(r.stability_hours_room_temp),
    stability_hours_refrigerated: asNum(r.stability_hours_refrigerated),
    mixing_pearls: asString(r.mixing_pearls),
    notes: asString(r.notes),
    common_concentrations: asString(r.common_concentrations),
    dosage_forms: asString(r.dosage_forms),
    routes: asString(r.routes),
    onset_duration: asString(r.onset_duration),
    onset_minutes: asNum(r.onset_minutes),
    duration_minutes: asNum(r.duration_minutes),
    contraindications: asString(r.contraindications),
    side_effects: asString(r.side_effects),
    serious_effects: asString(r.serious_effects),
    drug_interactions: asString(r.drug_interactions),
    interactions_critical: asArray(r.interactions_critical),
    administration_details: asString(r.administration_details),
    special_populations: asString(r.special_populations),
    pregnancy_lactation: asString(r.pregnancy_lactation),
    warnings_precautions: asString(r.warnings_precautions),
    pharmacokinetics: asString(r.pharmacokinetics),
    antidote_reversal: asString(r.antidote_reversal),
    clinical_pearls: asString(r.clinical_pearls),
    special_considerations: asString(r.special_considerations),
    monitoring_parameters: asArray(r.monitoring_parameters),
    deep_dive_content: asString(r.deep_dive_content),
    sources: asJson(r.sources),
    last_reviewed: asString(r.last_reviewed),
    clinical_reviewer: asString(r.clinical_reviewer),
    review_cycle_months: asNum(r.review_cycle_months),
  };
}

const BATCH = 200;
let inserted = 0;
for (let i = 0; i < rows.length; i += BATCH) {
  const chunk = rows.slice(i, i + BATCH).map(mapRow);

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

console.log(`\nDone. ${inserted} medications imported to Supabase.`);
