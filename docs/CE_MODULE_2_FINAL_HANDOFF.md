# CE HALO Module 2 and provider records

Module 2, GLP-1 Receptor Agonists: Current Guidelines and Anesthesia Implications, uses the provider-reviewed final content. It is part of Course 1, A Medication Review for the Experienced CRNA, AANA Course ID 1047239.

## What is included

- **Content:** Private 21-page learner PDF, 2.0-credit allocation entirely Pharmacology & Therapeutics. The full course remains 20.00 credits, not 20 credits per module.
- **Assessment:** 25 clinical questions, 15 per attempt, 12 correct to pass, three attempts. Approved hints eliminate two wrong options. Selection, hint persistence and grading remain server-controlled.
- **Evaluation:** Five learning-objective ratings, five program ratings, two written responses and acknowledgment. Rating scale is 1 Excellent through 5 Poor.
- **Isolation:** Ketamine and GLP-1 have independent progress, attempts, hints, evaluation and completion. Legacy clients without module_id still address Ketamine.

## Register once

After verified course purchase, learners complete one course-registration form with full name, credentials, optional AANA ID and completion location. Registration belongs to the authenticated user and course, not to individual evaluations. The registration can be edited explicitly from the module screen.

Both modules inherit registration when an evaluation is submitted. The server timestamps and links the evaluation and completion to the user account. Completion records snapshot registration for future certificate implementation. No repeated name, credentials, AANA ID, location or typed signature is requested on evaluations.

The fillable PDF evaluations also omit identity re-entry. They do not save into Supabase automatically: standalone PDF submissions need an account-linked upload workflow, which is not included. The in-app evaluations save directly.

## Provider access and monthly ledger

Sign in with the existing authorized provider account and open **CE HALO → Provider records & exports**. Enter a completion month as YYYY-MM, or leave it blank for all months, then select **Load records**. Filters use America/New_York.

- **Default:** Exclude all provider previews.
- **Browser:** Download the internal ledger CSV.
- **Native app:** Copy CSV to the clipboard; use the browser for a downloadable file.
- **Records:** Account ID, registered identity, AANA ID, location, completion date, module allocation, quiz attempts, hints, evaluation ratings, written responses and acknowledgment.
- **Security:** Provider authorization is checked in Supabase. Learner accounts cannot query the ledger or private tables. Exports contain personal information and must be stored securely.

This is an internal recordkeeping export, not a validated AANA upload template. It does not submit credits or track AANA receipt. Module completion is explicitly not a full-course award. The eventual certificate/full-program completion workflow must produce reportable full-course records; no learner can receive an accidental 20-credit award from these two modules.

## Release boundaries

Two of eleven modules are loaded. Course release and native store products remain disabled. No purchase is charged, bonus access activated, certificate issued, DNS changed, or record submitted to AANA. Creator preview requires no purchase and earns no official credit.

## Verification

- **Flutter:** 119 tests passed; targeted CE analysis reported no issues. Production and design-preview web release builds succeeded.
- **Database:** Live rollback tests passed for both modules, registration inheritance, grading, hints, module isolation, private PDF integrity and provider-only ledger access.
- **Browser:** Desktop and mobile renders checked. Completed Module 2's PDF, hint-assisted 15-question assessment, ten-rating evaluation and linked preview completion; downloaded CSV and verified preview exclusion by default.
- **Documents:** Final learner PDF is 21 pages, provider master 35, quiz/key nine, fillable evaluation two. Both modules' evaluation forms were filled, saved, reopened and checked; deliverables remain blank.
- **Not tested or released:** Native store checkout, receipt verification, iOS/Android distribution, certificates, full-course awards and AANA upload format.

## Local browser command

Use a compatible Flutter/Dart toolchain (the repository currently requires Dart 3.13):

```sh
cd ~/Documents/Luma-Anesthesia-Flutter &&
git switch main &&
git pull --ff-only origin main &&
flutter pub get &&
flutter run -d chrome -t lib/ce_portal_main.dart
```

If the repository lives elsewhere, open Terminal in that folder before running the commands after `cd`. The portal uses the same account and Supabase records as the mobile app; the separate design preview has only memory-based test activity.
