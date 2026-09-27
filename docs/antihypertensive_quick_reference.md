# Antihypertensive Quick Reference

Requested and authorized September 27, 2026. The owner's explicit format is
charts only, with pertinent details rather than narrative drug monographs.

## Scope

- Adult monitored perioperative IV use only.
- Three sections: bolus chart, infusion chart, monitoring/high-risk cautions.
- Eight agents: labetalol, hydralazine, esmolol, metoprolol, nicardipine,
  clevidipine, nitroglycerin and sodium nitroprusside.
- Doses and warnings cite fetched US labels; small perioperative boluses cite
  published anesthesia reviews. Metoprolol hypertension use is explicitly
  distinguished from its US acute-MI label.
- The nitroprusside <10-minute maximum-rate ceiling is attributed to the
  perioperative review, not incorrectly to the ready-to-use product label.
- No pediatric/obstetric or special-syndrome protocol, universal BP target,
  concentration calculator, or automatically generated dosing is introduced.
- Protected bodies remain server-only; test fixtures contain public metadata.
- Two-column chart renderer reserves most width for dose details; no horizontal
  swiping is required. Other guides retain their existing Markdown rendering.

## QA inventory

- Search generic/brand names and multiword phrases, open matching chart.
- Existing GLP1 and CIED searches and access protections remain intact.
- Charts render at 375px and 1280px with readable doses and source links.
- No drug-body access for anonymous or unpaid users.
- Drug chart banner does not show device or GLP-1 instructions.
- Wrong-drug queries and unsupported nicardipine bolus query return no match.
- All three bodies contain tables only; all clinical dose rows cite sources.
- Verify labels, units, infusion ceilings, delayed peak, and contraindications.

## Build and publication

Run `node tool/prepare_antihypertensive_seed.mjs` from the repository root.
Publish `supabase/seeds/antihypertensive_quick_reference.sql` separately using
the authorized Supabase connection. No schema or access-policy change is needed.

## Verification completed

- Full Flutter suite: 214 tests passed; focused final chart suite: 19 passed.
- Targeted Flutter analysis: no issues; release web preview build succeeded.
- Playwright: 375px mobile and 1280px desktop chart screenshots reviewed.
  Medication names, dose text, source links, safety banner and scroll behavior
  fit without horizontal overflow. Widened the medication column after review.
- Real input: Cardene drip opens infusion chart; hydralazine dose opens bolus
  chart; unsupported nicardipine bolus returns no matching section.
- UI rendering used local-only protected-body fixtures, never deployed.
  A separate unmocked anonymous browser confirmed the live catalog is
  searchable while protected content remains access-controlled.
- Supabase: three new sections published, version 2026-09-27.
  RLS checks: 27 public catalog rows, 27 eligible-account bodies, zero bodies
  for anonymous, unpaid or anonymous-authenticated accounts; no client writes.
- No changes to entitlements, schema, other clinical guides or launch scope.
