# Practice Guidelines: Base44 import

Prepared October 3, 2026 for the next Flutter build.

## Scope

- One home tile and drawer entry: **Practice Guidelines**.
- ASA, AANA, and CAA filters with document categories and as-you-type search.
- 229 Base44 references imported: 126 ASA, 81 AANA, 22 CAA.
- CAA is a professional-resource group, not a publisher. Publisher labels remain AAAA, NCCAA, ARC-AA or ASA.
- Free reference-directory access, matching the source screens. No purchase, CE, account or entitlement changes.
- Home navigation on the list and detail screens. No item counts on the home tile.
- The catalog is bundled for native offline browsing. External publisher documents still require internet and are not included as offline files.

## Provenance and limitations

Base44 stored titles, categories and source links, not full guideline text. All source summaries were blank. No clinical summaries, recommendations or clinical approval are fabricated by this import.

41 AANA entries are publisher searches. They are explicitly labeled **Search AANA**, not represented as direct-document links. PDF and web-page references have separate labels; publisher directories are offered as a fallback.

The ASA directory lists standards, practice guidelines, advisories, statements and related resources ([ASA directory](https://www.asahq.org/standards-and-practice-parameters)). The AANA manual also includes professional standards, position statements and other document types ([AANA Professional Practice Manual](https://www.aana.com/practice/professional-practice-manual/)). AAAA maintains its own position-statement directory ([AAAA Position Statements](https://www.anesthetist.org/position-statements)).

All catalog URL formats and hosts are validated against the imported official-publisher/DOI allowlist. The three publisher hubs above were fetched and the ASA Preanesthesia Care external-link flow was browser-tested. This is **not** an assertion that every one of the 229 linked documents was individually re-reviewed, remains current, or is freely accessible. The interface advises checking current revisions, publisher access requirements, applicable law and institutional policy.

Raw exports, Base44 author emails and other private metadata are not committed or included in the public catalog.

## Backend

Migration: `supabase/migrations/20261003180000_practice_guidelines.sql`.

- Adds only `public.practice_guidelines`, with 229 public reference records.
- Enables RLS and grants anonymous/authenticated users SELECT only.
- No end-user insert, update or delete permission.
- Service role retains administrative access.
- Idempotent seed updates only the imported reference IDs.
- Does not modify clinical medication content, accounts, purchases, or CE tables.

The Flutter screen renders the bundled directory before making any network request. A valid, complete remote catalog can update the directory in the background. A missing table, network failure, malformed data, or partial import leaves the bundled catalog intact.

Production migration and GitHub publication require approval. The separate CE website branch is not changed by this work.

## Verification

- 45 targeted tests passed across Practice Guidelines, home search, home/welcome layout and Home navigation.
- New-feature static analysis: no issues.
- Release web preview build succeeded.
- Tests cover import totals, sanitized fields, URL allowlist, publisher filtering, multi-word search, clear/empty states, category selection, source launch success/failure, publisher fallback, native-bundle offline behavior and rejected partial server imports.
- Layout tests cover 320, 375 and 820 pixel widths at normal and double text scale; existing home/welcome tests also cover landscape.
- Browser QA covers the new list, detail, filter/search, source launch and Home return.

This is Flutter/web verification, not an iOS archive, a TestFlight upload, or App Store approval. Native device verification remains part of the next-build acceptance.
