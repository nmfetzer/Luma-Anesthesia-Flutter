# CE HALO course-library integration

The approved navy, gold, and cream course-library layout replaces the old
single-course landing screen in the production CE portal and the app’s CE entry.
This is a Flutter navigation/UI change, not a course release or billing change.

## Learner navigation

- Courses: all three programs with account-derived module progress.
- Course overview: numbered modules and a single next-module action.
- Module view: content, existing 15-question assessment with two-answer hints,
  and account-linked evaluation.
- My certificates: per-course access to existing server-validated requirements,
  creator previews, and immutable official certificate downloads when eligible.
- Registration remains once per course; participation dates and location remain
  in the existing registration form, not each evaluation.

## Provider and security boundaries

- Provider dashboard is separate from the course learning screens.
- Each course’s records button requires that course’s server-returned provider flag.
- Records RPC authorization, export rules, and certificate issuance are unchanged.
- Monthly exports remain internal ledgers, not AANA-formatted upload files.
- No direct AANA submission, new purchase path, entitlement grant, new award,
  course-release toggle, or certificate-enablement change is included.
- The concurrent Apple checkout integration is preserved: locked courses link
  to CE purchase options; purchase and restore controls for existing learners
  sit under the collapsed purchase-details section. Store launch gates are unchanged.
- Library access failures are visible and retryable, not shown as successful loads.
- Account changes clear displayed progress and provider navigation. Responses from
  stale library requests are ignored.
- Protected question banks and demo credentials are not imported by production
  `main.dart` or `ce_portal_main.dart`.

## Isolated review build

`lib/ce_library_preview_main.dart` uses in-memory demo repositories for all three
courses. Jordan Example is a synthetic registration. Progress does not persist
and cannot create payments, official completion records, or reportable credits.
The preview banner remains visible.

## QA inventory

- Responsive library, course list, focused module view, certificates, and provider
  dashboard at phone/tablet/desktop widths.
- Course selection, next module, back to course, back to library, and navigation tabs.
- PDF reader to review acknowledgement to quiz and two-choice hint.
- Provider records filters and zero-record empty state.
- Creator certificate requirements and absence of official issuance control.
- Locked learner access, provider sign-out, failed access refresh and retry.
- Existing course banks, module isolation, quiz hints, registration, certificate,
  and CSV safety regression tests.

## Local Chrome command

Run from the existing Flutter project directory:

```bash
git switch main && git pull --ff-only origin main && flutter pub get && flutter run -d chrome -t lib/ce_portal_main.dart
```

The production portal opens the course library. Sign into the existing creator
account to see creator course access and the provider dashboard.
