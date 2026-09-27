# AICDs & Pacemakers and flexible Quick References search

Owner-authorized September 27, 2026. This update builds on shared main `eb138da`,
preserving the integrated Diagnostics, CE, provider-support, and Quick References
work. It does not change clinical access, purchases, or existing pre-op content.

## Content

- Eleven separately searchable sections from the approved combined guide.
- Approved clinical paragraphs, tables, qualifications, and inline source URLs
  are retained; only draft/editorial publication notes are excluded.
- Every section carries the adult perioperative scope reminder.
- Content is stored in `quick_reference_sections`, not bundled Flutter assets.
- Public titles and section-specific aliases live in `quick_reference_catalog`.
- The reader now selects its safety banner by guide rather than showing the
  pre-op/GLP-1 disclaimer for every clinical reference.
- Server-only seed: `supabase/seeds/cied_quick_reference.sql`.
- Generator: `tool/prepare_cied_quick_reference_seed.mjs`, taking the approved
  Markdown as input. Publication is a separate authorized SQL operation.

## Search contract

Searches section titles, parent-guide titles, and curated section aliases.
Multiple meaningful terms must match the same section, in any order.
Punctuation, capitalization, and ordinary filler words are ignored.
Device and cautery synonyms are curated explicitly; spelling correction is
limited to the listed cautery misspellings. No drug-name or dose fuzzy matching,
semantic AI generation, or full clinical-body exposure is introduced.
Negation such as `no` and `not` is retained, not interpreted as a treatment rule.

Examples resolving directly to Electrocautery and EMI precautions:

- `bipolar and AICD`
- `AICD and bipolar`
- `Bovie ICD`
- `cautery with defibrillator`
- `grounding pad AICD`
- `bipolar electrocuatery with an AICD`
- `Can I use bipolar electrosurgery with an implantable defibrillator?`

`magnet not working` resolves to Magnet exceptions that change the plan.
`Micra and magnet` may return several relevant sections, not a fabricated answer.
Unknown terms and unrelated combinations show the existing no-results state.
New topics still need curated section metadata; this is not unrestricted AI search.

## QA inventory

- Metadata fixture matches the published 11-section seed; unique stable IDs.
- Search phrases, reverse order, synonyms, punctuation, filler words, typo list.
- GLP1 / GLP-1 / GLP 1 and existing pre-op aliases remain supported.
- Unknown terms, filler-only queries, and unrelated drug combinations fail closed.
- Direct result opens the correct section; back preserves query; clear resets.
- Anonymous and unpaid users cannot read clinical bodies; eligible users can.
- Mobile 375 × 812 and desktop 1280 × 900: catalog, search result, reader.
- Reader includes citations, appropriate scope banner, and source links.
- Tables and full cautery body checked for readable mobile layout.
- Full Flutter tests, targeted analysis, and release web build.

## Release verification

- The 11 CIED sections were published atomically to Supabase project
  `xuckkusbbcxplpqclbxt`; the existing 12 pre-op rows were not changed.
- All 11 CIED bodies contain source URLs and exclude draft publication notes.
- Database access checks: 23 public catalog rows, 23 eligible-user bodies,
  zero anonymous/unpaid/anonymous-authenticated bodies, no client write grants.
- All 183 Flutter tests passed after integrating the latest CE update.
- Targeted Quick References analysis found no issues.
- Flutter release web build from `lib/preview_main.dart` succeeded.
- Browser reader checks use a local-only response fixture for protected bodies;
  real anonymous body denial is checked separately. No access bypass is shipped.

## Launch locally

```sh
cd ~/Documents/Luma-Anesthesia-Flutter &&
git pull --ff-only origin main &&
flutter pub get &&
flutter run -d chrome
```

Do not reset or discard local changes if the pull cannot fast-forward.
Sign in with an eligible account and open Quick Ref. Search `bipolar and AICD`.
Supabase content publication does not update an already-built Flutter binary;
the search upgrade requires this updated build. This is not an App Store release.
