# CE HALO Module 4: Neuromuscular Blocking Agents and Sugammadex

Final production package and additive course integration, September 27, 2026. The original submission is preserved separately; clinical clarifications are recorded in the complete provider master.

## Content and access

- **Module:** `course_1_module_4`, resource prefix `nmba_sugammadex`.
- **Course:** A Medication Review for the Experienced CRNA, AANA Course ID 1047239. Approval October 1, 2026–September 30, 2029.
- **Allocation:** 2.0 MAC Ed CE credits, all Pharmacology & Therapeutics, within the full 20.00-credit program.
- **Assessment:** 25 clinical items, 15 per attempt, 12 correct to pass, up to three attempts. Every hint removes exactly two wrong choices.
- **Registration:** Shared course-level full name, credentials, optional AANA ID, and completion location. Evaluation has ten ratings, two narratives, and acknowledgment, without duplicate identity fields.
- **Provider records:** Existing account-linked module records and export remain in place. Preview completion awards zero credit and is excluded by default.

## Documents

The user-facing package includes a 27-page learner PDF, nine-page provider quiz/answer key/hints PDF, two-page fillable evaluation, complete provider master, and provider-only JSON/CSV imports. Only the learner PDF and private question bank are seeded into the app; keys and hints are not embedded in production client code.

The approved navy-and-gold halo cover, exact full-program approval statements, support email, and module credit distinction are retained. Reporting class 196397 is provider-only.

## Targeted clinical revisions

- **Monitoring:** Corrected ASA publication year and raw/normalized acceleromyography interpretation; distinguished TOF count from ratio ([ASA guideline](https://csa-online.org/wp-content/uploads/2023/02/NMB23.pdf)).
- **Reversal:** Precise 2/4/16-mg/kg thresholds, current BRIDION pediatric scope, severe renal limitation, actual-weight dosing, and airway-rescue cautions ([BRIDION label](https://www.merck.com/product/usa/pi_circulars/b/bridion/bridion_pi.pdf)).
- **Population-specific care:** Avoided blanket ideal-weight and neuromuscular-disease dosing rules; corrected the myasthenia discussion ([myasthenia review](https://pmc.ncbi.nlm.nih.gov/articles/PMC8520038/)).
- **Evidence:** Corrected authorship and effect estimates; omitted exact statistics whose cited primary reports could not be verified. The master identifies omissions explicitly.
- **Questions:** Corrected the original depolarization/clearance conflation; used clinical decision-making rather than accreditation-rule recall.

## QA inventory

- **Document consistency:** Cover, approval code, allocation, footer email, all-page bounds, clickable citations, source-linked question keys, and all 25 hints.
- **Evaluation:** Save/reopen all 13 logical form fields; no repeated identity inputs; two pages.
- **Client:** Module 4 appears alongside Modules 1–3; mobile and desktop registration, PDF opening, reading confirmation, hint, assessment, evaluation, and completion.
- **Backend:** Private PDF checksum, 15 server-issued questions without answer keys, persistent hints, cross-module submission denial, registration inheritance, ten-rating enforcement, idempotent zero-credit preview completion, and unchanged Modules 1–3 state.
- **Records:** Default excludes preview; provider-only preview ledger and CSV include the linked Module 4 record. Nonprovider access denied.
- **Build boundary:** Production portal compiles without preview bank data or answer-key strings. Preview fixtures are only in the preview entry point.

## Scope boundaries

No course release, IAP activation, app-access promotion, certificate generation, CE subdomain, App Store upload, or AANA submission is enabled by this addition. The provider must determine any AANA notification or re-review requirement before learner release; no separate AANA approval of the revised edition is asserted.

## Run on a Mac

From the existing Flutter project folder:

```bash
git switch main &&
git pull --ff-only origin main &&
flutter pub get &&
flutter run -d chrome -t lib/ce_portal_main.dart
```

Sign in with the creator account to use authorized preview access. Use `lib/ce_preview_main.dart` only for the isolated demonstration, never the production deployment.
