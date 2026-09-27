# Beta-Blocker Quick Reference

Authorized September 27, 2026. Adult monitored IV chart-only content, preserving
the approved Quick References renderer, search and protected server-only bodies.

## Scope

- Bolus: esmolol, metoprolol tartrate, labetalol, propranolol.
- Infusions: esmolol, labetalol, landiolol.
- Safety: pre-excited AF/WPW, unstable AF, contraindications/interactions,
  chronic continuation/new initiation, glucose/pheochromocytoma and units.
- No outpatient oral titration, pediatric, obstetric, thyroid storm or overdose
  protocols; no new calculator, schema, entitlement or access-policy changes.
- FDA/manufacturer labels and AHA/ACC guidelines linked in clinical rows.
- Metoprolol AF dosing uses the AF guideline's 2-minute administration rather
  than the different hypertension regimen in the existing antihypertensive guide.
- Propranolol uses the AF guideline regimen, not a blended label/AF regimen.
  The older label's WPW wording is explicitly not applied to pre-excited AF.
- Esmolol uses label-specific ceilings (HR 200; hypertension 300 mcg/kg/min),
  rather than generalizing the AF guideline table's upper range to every use.
- Landiolol uses US adult label infusion dosing; no overseas bolus regimen.

## QA inventory

- All three charts render at 375 and 1280px; medication labels and units readable.
- Generic/brand and multiword searches, contraindication searches, clear/back.
- Unsupported metoprolol infusion and landiolol bolus produce no beta-guide match.
- Clinical source links, distinct dose units, off-label indication and WPW warning.
- Unmocked live catalog search with anonymous clinical-content denial.
- RLS remains public metadata, eligible-only bodies, no client writes.
- Tests, targeted analysis, release build and private preview refresh.

## Generation

`node tool/prepare_beta_blocker_seed.mjs` generates the atomic idempotent SQL
and metadata-only test catalog. Run the SQL through the authorized Supabase
connection after validation; no schema migration is required.

## Verification

- Full Flutter suite: 258 tests passed, including 23 beta-blocker tests.
- Targeted analysis clean; release web build and preview postprocessor passed.
- Browser QA: all three tables at 375px and 1280px; scrolling, Back, Clear
  search and a new query; no page errors or horizontal overflow observed.
- Lopressor bolus, Rapiblyk infusion and beta blocker WPW opened the expected
  tables. Unsupported metoprolol infusion returned no beta-guide match.
- Table visual QA used local-only browser fixtures for the protected bodies.
  Fixtures were not included in the release bundle. Separate unmocked live
  catalog search found Rapiblyk infusion and denied anonymous body access.
- Supabase readback: three published sections, version 2026-09-27.
- RLS verification: 33 public metadata rows and 33 bodies for an existing
  eligible account; zero bodies for anonymous, unpaid and anonymous-auth users;
  no client writes. QA claims rolled back, no entitlement changes.
