# Hypotension Quick Reference

Owner authorized September 27, 2026 after approving the antihypertensive chart
layout. Preserve that layout: tables only, pertinent details, searchable sections.

## Scope and clinical provenance

- Six agents: phenylephrine, ephedrine, norepinephrine, epinephrine,
  vasopressin and dopamine. No calculators or automatic treatment selection.
- Three charts: IV bolus, IV infusion, selection/safety.
- FDA labels establish labeled doses and safety details. Stanford's cardiac
  anesthesia reference and a July 2026 review support perioperative practice.
- Norepinephrine, epinephrine and vasopressin rescue boluses are explicitly
  off-label. Shock-specific infusion regimens are separately identified.
- Product preparation is not inferred from a drug name. No universal dose
  ceiling or BP target is invented; vasopressin units are explicitly highlighted.
- Clinical rows contain direct source links; bodies stay server-only.
- No change to other clinical modules, account entitlement or launch scope.

## QA inventory

- Generic, brand, shorthand and multiword searches open the relevant chart.
- Unsupported ephedrine infusion / dopamine bolus and misspelled medication
  queries must not invent a match.
- All three charts render at 375px and 1280px with source links and drug banner.
- Visual phone/desktop check: drug names, units, column fit, scrolling.
- Unmocked live catalog search and anonymous protected-content denial.
- RLS: public metadata only for anonymous/unpaid accounts; premium bodies
  accessible only to eligible accounts; no client writes.
- Existing pre-op, CIED and antihypertensive references remain unchanged.

## Generation

Run `node tool/prepare_hypotension_seed.mjs` from the repository root.
Publication uses the authorized Supabase connection and the generated atomic
upsert SQL. No schema migration or access-policy change is needed.

## Verification completed

- Full Flutter suite: 235 tests passed. After the final name-column adjustment,
  all 39 hypotension/antihypertensive tests passed again; targeted analysis clean.
- Release web build and nested-hosting postprocessor completed.
- Phone and desktop browser review covered bolus, infusion and safety tables,
  scrolling and source-link presentation. Longer medication names fit the
  slightly wider hypotension-only name column; antihypertensive layout unchanged.
- Browser searches for Neo push, Levophed drip and phentolamine opened the
  correct chart. Back, Clear search and a new query were exercised successfully.
- Protected-body visual QA used local browser-only fixtures, never bundled or
  deployed. Unmocked live search found the infusion chart; anonymous opening
  correctly displayed the clinical-access notice rather than a dosing body.
- Database readback: all three sections published, version 2026-09-27.
- RLS checks: 30 public catalog rows; 30 bodies for an existing eligible account;
  zero bodies for anonymous, unpaid or anonymous-authenticated users; no client
  writes. Claims were rolled back and no entitlements changed.
