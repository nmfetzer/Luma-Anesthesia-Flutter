# Academy A&P private review integration

The isolated `lib/academy_package_review_main.dart` entry renders private topic bundles supplied by the owner. No paid text, answer keys or PDF assets are committed in this public repository.

## Implemented

- Reusable package parser for the original Cardiovascular schema and the subsequent topic packages.
- Nine-level catalog supplied privately, source-linked lessons, small recall decks and per-deck practice.
- Checkpoint answer explanations hidden until all answers are submitted.
- Existing native PDF viewer integration.
- Version-scoped, device-local owner-review progress.
- An explicitly disabled purchase-access implementation.
- Nonclinical fixture tests and production-route isolation.

## Not implemented or activated

No live IAP, store price, production content route, server-side entitlement, cloud account progress or authoritative mastery unlock is enabled. Review results never grant a purchase entitlement. Draft content requires clinical approval; the proposed 90% rule is not an NCE passing standard.

The private preparation script and all actual learning packages are stored in the owner's private Project Files. Do not commit `assets/academy_review/` or distribute its bundle publicly. Build preparation uses a separate private copy of this repository and leaves production `pubspec.yaml` unchanged.

## Verification commands

```bash
flutter analyze lib/academy/academy_package.dart lib/academy/academy_package_review_screen.dart lib/academy_package_review_main.dart test/academy_package_test.dart
flutter test test/academy_package_test.dart test/academy_review_test.dart
```
