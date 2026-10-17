# Academy shared-account integration

## Release boundary

Academy uses the existing Luma Supabase account. Its private access, content, marks and attempts are separate from CE ownership and clinical subscriptions. The owner authorized the production backend on October 16, 2026. Sales and mastery-based locking are deliberately disabled.

The website entry point remains `lib/ce_portal_main.dart`. Additive routes `/academy` and `/luma-academy` open the connected client. The existing CE portal navigation gains “My CE courses” and “Luma Academy”; CE purchase-first flags and APIs are unchanged.

```sh
flutter build web --release --no-wasm-dry-run \
  -t lib/ce_portal_main.dart \
  --dart-define=LUMA_CE_PURCHASE_FIRST=true \
  --dart-define=LUMA_CE_STRIPE_LIVE_ENABLED=true
```

Use the built `build/web` folder for Netlify. Do not deploy `tool/academy_qa_main.dart` or the local QA server. No approved paid JSON or PDF is included in the static output or public repository.

## Account and progress model

- Content is fetched only after a server-side Academy access check.
- Every RPC derives the account from `auth.uid()`, not a supplied user ID.
- Lessons and recalled cards are append-only unique marks scoped by account, level and content version.
- A card advances as saved only after the server confirms the mark. Network failure leaves a retry.
- A new account destroys the nested Academy navigation stack and cached screens. In-flight responses are rejected if the account changes.
- Returning to the learning path, refreshing, reopening, or resuming reloads saved progress. This is shared persistence, not a live push feed.
- Practice and checkpoint grades are computed by the server. Attempt IDs make retries idempotent and reject changed answers under a reused token.
- Checkpoint keys and explanations are omitted until the entire form is submitted. Ordinary learners cannot request the checkpoint-answer PDF; owner-review access can inspect companion PDFs.
- No local review records are silently migrated into account progress.
- The backend does not grant access from a CE purchase, client flag or client score.

## Native handoff

This native branch includes the route, home tile and drawer link behind `--dart-define=LUMA_ACADEMY_CONNECTED_ENABLED=true`. Default builds retain the existing deferred Academy state. Use the flag for the next owner/TestFlight review build; this does not activate purchases or grant access.

The same `academy_repository.dart` and `academy_screen.dart` work in Flutter native clients. Register `AcademyScreen` before deferred-route handling, with the existing initialized Supabase client. An app binary containing this route and navigation must be built and reviewed before claiming native-device synchronization. This website build does not update installed iOS/Android apps.

The existing local owner-review harness is unchanged and is not a cloud-progress client.

## Security and QA

The migration creates only `academy_private` tables and six narrowly scoped public RPCs. All private tables have RLS enabled, no public/client table grants, and account deletion cascades to Academy access, marks and attempts. Security-definer functions have empty search paths and explicit execution grants.

Run Flutter checks:

```sh
flutter test test/academy_account_test.dart test/ce_portal_frame_test.dart \
  test/ce_web_checkout_test.dart test/ce_billing_test.dart test/ce_store_catalog_test.dart
flutter analyze lib/academy lib/ce/web/ce_portal_frame.dart test/academy_account_test.dart
```

`supabase/tests/academy_security.sql` is an isolated local SQL test with synthetic users. Do not run its bootstrap against production. Production verification uses a rollback-only transaction with the owner's approved review access, leaving no test marks or attempts.

The local browser harness exercises the production widgets and RPC contract against an isolated PostgreSQL database with private content loaded separately. It does not prove real OAuth login, live checkout, or TestFlight acceptance.

## Remaining release steps

- Restore the authorized Netlify deployment credential and approve/publish the website update.
- Verify the owner’s real browser sign-in and account progress.
- Include the connected client in the next native build and verify the same account on a physical device.
- Define Academy price, access duration, store products, purchase/restore/refund ingestion and mastery policy before opening sales.
- Keep Academy clearly distinct from AANA-approved CE credit.
