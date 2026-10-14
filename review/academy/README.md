# Luma Academy migration and study preview

Updated October 14, 2026. This is a private implementation and content-review tranche, not the completed Academy or a release authorization.

## Implemented

- Homepage and drawer CE labels share `CE Halo-AANA approved MAC Ed credits`. The existing CE destination, purchases, entitlements, course content and certificates are unchanged.
- Legacy Academy source is preserved under `legacy-source`; `manifest.json` records file hashes and the source commit. No legacy source executes during import.
- The structured question import contains 601 questions. Every original remains marked `needs_clinical_review`; importing is not clinical verification.
- Native private preview has a short untimed round, answer feedback, rationales, source buttons, session-only study points, and a missed-question retry. It contains three corrected sample items, not all 601 questions.
- Original sample IDs 51, 54 and 67 from `ABAPracticeExamData` are mapped to the corrected items in `lib/academy/academy_review_questions.dart`. Each remains awaiting clinician approval.
- Academy remains deferred in `lib/main.dart`. No production route, entitlement, backend, store listing, CE credit or purchase flow was activated.

## First source-checked corrections

- **Etomidate:** The old stem claimed preserved adrenocortical function while its answer and rationale described etomidate. The replacement consistently teaches myoclonus and transient steroid suppression, supported by the [DailyMed etomidate label](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=dc43b289-4f32-1c1e-e053-2995a90a3a23).
- **Desflurane:** The old item mixed volatile agents with nitrous oxide and supplied a contradictory numeric comparison and answer. The replacement tests the labeled coefficient of 0.424 at 37°C, with induction cautions rather than a blanket “fastest induction” claim ([DailyMed SUPRANE label](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3fe3d468-d283-4dd0-a1a7-29291a9b2d0b)).
- **Plain lidocaine:** The old key combined a plain-lidocaine question with an epinephrine-containing formulation. The replacement specifies the normal-healthy-adult general limit, including the total-dose ceiling and the need to respect lower technique/patient-specific limits ([DailyMed lidocaine label](https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3b2dd84e-cee8-4e58-d494-395a65a353a0)).

## Remaining Academy work

- Review the other 598 imported questions, all lesson prose and tables, and current board-exam information. Preserve provenance and track corrections, source dates and clinician approval per item.
- Retrieve the actual Base44 flashcard records. The source contains deck definitions and queries, not the flashcard content itself; the flashcard bank has not been imported.
- Convert archived JSX lesson modules into structured native lesson content after checking clinical claims.
- Review the initial visual direction before expanding it. Proposed next features are short daily rounds, spaced review and topic progress; persistent progress, streaks, cloud sync and leaderboards are not implemented.
- Define Academy premium/free access using the existing subscription policy, without granting approved CE for ordinary study activity.
- Complete native device, accessibility, offline, privacy and clinical acceptance before exposing Academy in the normal app.

## Luma AI is separate

The existing assistant remains a disabled preview. This tranche does not connect a provider or change AI billing. Remaining work includes the authenticated server endpoint, explicit third-party-data consent, bounded educational responses with references, server-authoritative credit reservation/settlement, provider and budget approval, failure/refund handling, and safety/device acceptance. Acknowledging a safety notice is not consent to send data to an AI provider.

## Design reference

The owner requested game-style learning inspired by Ollivate, whose public site describes short sessions, guided paths, streaks, XP and spaced review ([Ollivate](https://ollivate.com/home)). This is an original Luma implementation using owner-provided content, not a copy of Ollivate’s question bank, artwork or interface.

## Developer commands

Run the native design preview separately from the released app:

```sh
flutter run -t lib/academy_review_main.dart
```

Run focused checks:

```sh
flutter test test/academy_review_test.dart test/ce_halo_navigation_label_test.dart test/home_navigation_test.dart test/home_search_test.dart test/luma_ai_safety_test.dart
```

Re-create review screenshots:

```sh
flutter test --dart-define=LUMA_CAPTURE_REVIEW=true --update-goldens test/academy_preview_capture_test.dart
```

Re-import the original source, without overwriting corrected native questions:

```sh
npm ci --prefix tools/academy-import
node tools/academy-import/import.mjs /path/to/legacy-luma-repo
```

The snapshot is review-only and is not listed in Flutter assets. Do not use the Academy review entry point for an App Store or production release.
