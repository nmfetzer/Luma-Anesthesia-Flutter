# FDA and DailyMed reference updates

## Scope and release status

Prepared October 2, 2026. This integration adds a lazy, expandable panel to both Drug Library and Vasopressors medication-detail screens. It supplements reviewed medication content; no dosing, mixing, warning, clinical narrative, subscription rule, account, or CE record is modified.

Production activation requires approval of the new migration and Edge Function. A new native build is required for TestFlight users to see the UI. ASHP content is not imported.

## Data flow

- Flutter sends only `medication_id` to the Supabase `drug-reference-updates` function.
- The function validates the caller's project API key through a read of the public medication identity. It does not forward user authorization tokens to the external services.
- The function derives a conservative search term from the stored medication name, removing parenthetical UI annotations. It does not silently invent ingredient, salt, strength or manufacturer matches.
- FDA and DailyMed receive only that medication search term. The function does not send names, email addresses, AANA numbers, CE records or patient information to those providers.
- Two service-only cache tables store public reference metadata and an aggregate refresh budget, not a per-user browsing history.
- Each successful lookup is cached for 12 hours and refreshed on demand when the panel is opened. No scheduled full-library sync is claimed. Failed provider refreshes retry after 15 minutes. An atomic one-minute lease prevents duplicate requests and permits at most 20 medication refreshes per minute across function instances.
- Previously opened results are saved on the device. The full FDA database, all DailyMed labels and linked PDFs are not downloaded for offline use.

## Safety and matching

- Results are explicitly **possible matches**, not verified exact-product matches. Users must verify drug, formulation, strength and manufacturer; FDA results additionally expose package NDC when provided.
- Current FDA shortage-report status and individual product availability are displayed separately. A product may show “Available” within a “Current” report.
- No hit means “No matching shortage report found,” never “No shortage” or guaranteed local availability.
- Labels are restricted to human prescription documents using DailyMed `doctype=34391-3`. OTC-only products may require the direct DailyMed search link. Veterinary labels are not intentionally queried.
- Up to 100 FDA records are fetched, with simpler name matches ranked first and 20 displayed. DailyMed returns the first 20 matching human prescription labels. Three results are initially visible; remaining fetched results expand under “More results.” Larger source result counts trigger an explicit non-exhaustive-list notice.
- No automated substitutions, prescribing recommendations, FDA-approval claims or clinical content overwrites are performed.
- Individual source timestamps and successful check timestamps are distinct. A failed refresh retains the previous successful check date.
- Cached-only, failed-refresh or older-than-24-hour data is clearly marked as not currently verified. Official links remain available; opening remote labels requires a connection.
- API errors, malformed data, blocked storage and provider rate limits cannot become successful empty “no shortage” results.

## APIs and source documentation

- [FDA Drug Shortages API](https://open.fda.gov/apis/drug/drugshortages/how-to-use-the-endpoint/): `https://api.fda.gov/drug/shortages.json`.
- [FDA terms](https://open.fda.gov/terms/): attribution and availability limitations. The openFDA response's warning not to rely on openFDA for medical-care decisions is retained in the UI.
- [FDA source database](https://dps.fda.gov/drugshortages): human-readable shortage browsing. Individual package-record links open the FDA JSON record because the API does not provide a stable product-specific website URL.
- [DailyMed web services](https://dailymed.nlm.nih.gov/dailymed/app-support-web-services.cfm) and [SPL search parameters](https://dailymed.nlm.nih.gov/dailymed/webservices-help/v2/spls_api.cfm).
- [DailyMed human prescription document code example](https://dailymed.nlm.nih.gov/dailymed/webservices-help/v2/spls_setid_api.cfm).

## Deployment

1. Apply only `supabase/migrations/20261002100000_drug_reference_updates.sql` after approval. Do not deploy other pending migrations, particularly the unrelated account-deletion draft.
2. Deploy `supabase/functions/drug-reference-updates/index.ts` and its `providers.mjs` dependency. Set gateway `verify_jwt=false` because the function performs custom project API-key validation and the app uses modern publishable keys, including signed-out users. This does not grant clients cache-table access.
3. Built-in `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are server-side environment values. An optional `OPENFDA_API_KEY` may be added as an Edge Function secret for higher usage limits; never embed it in Flutter. No DailyMed key is required by this implementation.
4. Smoke-test signed-out and signed-in lookup, repeated cached lookup, invalid project key, invalid medication ID, offline saved results, direct source links and independent provider failure.
5. Release the Flutter update in a new signed build. Keep ASHP outside scope until its license is obtained.

Rollback: remove/hide the Flutter panel and undeploy the new function. Existing clinical content is unaffected; cache tables can remain inaccessible to clients. Do not drop tables without approval.

## QA inventory

- Provider unit tests: correct endpoints, name sanitization, separate report/availability states, human-label filter, malformed schema, unsafe SET IDs, no-hit vs failure, independent provider failure and retention of original timestamps.
- Disposable database test: client privilege restrictions, valid/invalid ID lease, duplicate lease exclusion, expiration, global rate budget and reset.
- Flutter tests: lazy expansion, refresh/retry, source links, empty results, offline fallback, large text at 320 px, blocked storage and malformed device cache.
- Browser QA: real API responses intercepted into the pending function route for visual testing only; no mocked clinical result is bundled or published as live data.
- Native TestFlight purchase/auth and unrelated deletion workflows are not retested or certified by this feature's tests.

## Verification completed before production approval

- 23 Flutter tests passed, covering the new feature plus existing source links and medication loading recovery.
- Seven provider tests passed; the real FDA and DailyMed APIs were also exercised for propofol and epinephrine.
- Disposable PostgreSQL migration and privilege/lease/budget assertions passed.
- Deno type-check of the Edge Function passed. Focused Flutter analysis found no issues in the new gateway, panel and test files.
- Release web build succeeded.
- Browser checks passed at 375 px and 1280 px, including live-provider response rendering via a test-only route interception, 20-result expansion/three-result collapse, failed-refresh saved warnings, and no page errors. Large text at 320 px was checked in Flutter widget tests.
- Browser testing exposed and fixed a circular in-flight Future cleanup; a real-gateway regression test now verifies deduplication, completion, persistence and subsequent refresh.
- Production migration, production function deployment, GitHub push and native build upload remain pending authorization/activation.
