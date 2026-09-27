# CE HALO Course 1: Modules 5–11 final package

The seven remaining modules have been produced and loaded into the private Course 1 catalog. The full course is **A Medication Review for the Experienced CRNA**, AANA Course ID **1047239**, approved for **20.00 MAC Ed CE credits** for October 1, 2026 through September 30, 2029.

## Contents and allocations

| Module | Topic | Total | Pharmacology & Therapeutics | Pain Management |
|---|---|---:|---:|---:|
| 5 | Tranexamic Acid | 1.5 | 1.5 | 0 |
| 6 | IV Contrast Media and Surgical Fluorescent Dyes | 2.0 | 2.0 | 0 |
| 7 | Cannabis Use and Anesthesia Implications | 2.0 | 1.5 | 0.5 |
| 8 | Illicit Drug Use and Anesthesia Implications | 1.5 | 1.0 | 0.5 |
| 9 | Volatile Anesthetics | 2.0 | 2.0 | 0 |
| 10 | Non-Opioid Pain Management | 2.0 | 1.0 | 1.0 |
| 11 | Perioperative Antihypertensives | 1.0 | 1.0 | 0 |

With Modules 1–4, the catalog totals 20.00 credits: 17.50 Pharmacology & Therapeutics and 2.50 Pain Management. Module credits are part of the program total, not additional awards.

## Download package

Each module contains four PDFs: learner content, complete provider master, quiz/answer key/hints, and a two-page fillable evaluation. Provider-only JSON and CSV imports and a revision record accompany each module. The combined archive organizes everything by module.

The navy-and-gold halo cover, full program approval statement, Course ID, and info@cehalo.com are retained. Reporting class 196397 appears in provider records, not the learner copy.

The original reviewed teaching pages and tables are preserved, with targeted clinical clarifications applied directly and documented in each provider master. This is not a comprehensive new peer review or an assertion that AANA separately approved the revised edition. The provider should determine whether any revised material requires notification or re-review before learner release.

## Assessment and account workflow

- **Assessment:** 25 questions per module; 15 served per attempt; 12 correct to pass; up to three attempts. Every question includes a hint that removes exactly two incorrect choices.
- **Registration:** Full name, credentials, optional AANA ID, and completion location are collected once at course level.
- **Evaluation:** Five objective ratings, five program ratings, two written responses, and attestation. No repeated identity fields.
- **Account records:** In-app quiz attempts, hint use, grading, evaluation, and module completion are linked to the account.
- **Offline evaluation:** A completed downloaded PDF does not automatically synchronize. Use an authenticated, account-linked return process if accepting offline forms.
- **Creator access:** Existing reviewer access remains available without purchase. Creator preview completion awards zero credit and is excluded from default provider exports.
- **Provider export:** The course's “Provider records & exports” view provides the account-linked internal ledger. It is not represented as a certified AANA import format or an automatic AANA submission.

## Verification

All seven learner PDF checksums were verified against private Supabase resources. A rollback-only live test passed for the eleven-module catalog, private assessment responses without answer keys, hints, grading, registration inheritance, evaluations, independent progress, preview exclusion, and provider authorization.

The final merged app passed all 301 Flutter tests, the focused CE analyzer, and the production web build. The final CE preview build and browser checks also passed. Production JavaScript was checked for the new question IDs and answer-key fields; they were absent. Answer-bearing preview fixtures are restricted to the isolated preview entry point.

Desktop testing covered all seven new module selections and the full Module 11 reading, hint, assessment, evaluation, completion, and provider CSV workflow. Mobile testing covered Module 10 reading and quiz hints at 390px. Screenshot previews accompany the final handoff. Hosted-preview deployment did not return a result and was cancelled; no new hosted preview URL is claimed. This does not affect the Supabase upload or GitHub changes.

## Release boundary

The course remains unreleased. This work does not activate CE purchases, promotional Luma access, certificates, CE.cehalo.com, store publication, or AANA reporting. The effective approval window begins October 1, 2026.

## Open on a Mac in Chrome

Run from the existing Luma Anesthesia Flutter project folder:

```bash
git switch main &&
git pull --ff-only origin main &&
flutter pub get &&
flutter run -d chrome -t lib/ce_portal_main.dart
```

Sign in with the creator account for authorized course preview. For a standalone demonstration without live account data, substitute `lib/ce_preview_main.dart`; that entry point is not for production deployment.
