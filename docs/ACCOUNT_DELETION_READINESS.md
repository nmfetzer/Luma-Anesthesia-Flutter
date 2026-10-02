# Account deletion: implementation and release status

Updated October 2, 2026. Request intake, email queue, dispatcher, retention guards,
and completion receipts are implemented and locally tested. **Not deployed or
enabled. Actual account erasure remains an explicit operator action through the
Supabase Auth admin interface, not an automatic response to an email or app tap.**

## Approved operating choices

- Turnaround: seven calendar days for verified requests.
- Operator: CE HALO LLC / Nicole Fetzer.
- Internal notification destination: the owner-approved address, stored in the
  protected `luma_account_deletion_settings.notification_email` field, not in
  public source code.
- Public request/support address and Reply-To: `info@cehalo.com`.
- Sender: `CE HALO <info@cehalo.com>`.
- External request path: email instructions at https://cehalo.com/privacy-policy.
- Required AANA PDIS program evidence must remain securely retrievable for at least
  60 months, not 60 days and not just certificates:
  [AANA guidance](https://www.aana.com/wp-content/uploads/2026/01/Guidelines-for-Completion-of-an-Application-for-Prior-Approval-Provider-Directed-Independent-Study-January-2026.pdf).

Resend is connected and the domain was previously verified. An accepted connector
test email is not evidence that the app has a server credential, a running mail
dispatcher, or actual inbox delivery. Never use the previously pasted secret.

## Implemented

- In-app explicit confirmation and authenticated request submission.
- Identity/email derived from the authenticated account, never client parameters.
- Owner-only saved receipt on reopening, with the original seven-day deadline.
- Atomic initial operator and learner receipt messages; duplicates do not enqueue
  more mail or extend the deadline.
- Protected server-only email queue; maximum five messages claimed per run,
  two-minute leases, stable Resend idempotency keys and frozen message payloads.
- Backoff after failures; ambiguous messages older than 23 hours or eight failed
  attempts require operator reconciliation rather than unsafe resending.
- Daily UTC reminders when a request is due within two days or overdue.
- Provider acceptance stored separately from request completion. `accepted` means
  Resend accepted it, NOT that the recipient's mailbox delivered/read it.
- A guarded completion RPC requires an absent auth account and documented
  fulfillment evidence. It queues a separate completion email.
- A pre-erasure operator RPC records processor/token/session fulfillment evidence.
- An auth-deletion trigger requires a prepared request and atomically archives
  non-preview CE learning evidence before active learning profiles are removed.
- Certificate and purchase ledgers keep their original rows/UUIDs, detached from
  the login FK. Existing certificate immutability/reporting paths remain intact;
  replacement write guards reject new associations to nonexistent logins.
- Missing certificate PDF archive metadata or newly added CE tables stops erasure.
- Retained learning records are service-only and have no automatic purge. Their
  review floor is conservatively 60 months after archive creation; this is an
  operational choice, not an assertion that AANA mandates that starting event.
- Intake starts disabled and also requires a recent worker heartbeat. Unresolved
  mail errors prevent heartbeat renewal. Existing receipts remain readable.
- No account erase endpoint, purchase-access bypass, or client-visible secrets.

Provider retry rules follow [Resend's 24-hour idempotency window](https://resend.com/docs/dashboard/emails/idempotency-keys).

## Production blockers and safe activation sequence

1. **Approve and validate retention-safe fulfillment.** Live schema inspection found
   `ce_course1_state`, `ce_course2_state`, and `ce_course3_state` cascade when an auth
   account is removed. Their profile/progress JSON contains participation,
   assessment, and evaluation evidence. Certificate tables instead RESTRICT auth
   deletion and preserve immutable award snapshots plus private PDF paths/checksums.
   `luma_ce_bonus_purchases` also blocks auth deletion through its foreign key.
   Do not delete an auth user, disable these constraints, or delete blocking CE
   records to make deletion succeed. The prepared retention migration replaces
   the four blocking ledger FKs with write guards and adds a protected learning
   archive, without removing existing awards, financial records or PDF files.
   The operator must verify PDF files and hashes, required-record retrieval,
   continuing monthly AANA reporting, and any applicable longer legal holds.
2. **Set server secrets through Supabase's own secrets interface.** Store a
   replacement Resend sending key as `RESEND_API_KEY`. Never put it in
   Flutter, this repository, screenshots, or chat. Supabase supplies
   `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` to the Edge Function.
   Set `notification_email` to the approved owner address through a protected
   server operation. The public app cannot read or change this setting.
3. **Approve exact migrations and deploy disabled.** Apply
   `20261002090000_account_deletion_requests.sql`, then
   `20261002110000_account_deletion_workflow.sql`, then
   `20261002120000_account_deletion_retention.sql`; deploy `account-deletion-notify`
   with gateway `verify_jwt=false` because the dispatcher authenticates a
   short-lived, one-use server token itself. It does not accept user JWTs as worker
   credentials. Tokens are minted only by the protected scheduler function and
   stored as hashes; no long-lived scheduler key needs to be copied.
   Do not run a broad `supabase db push` that applies unrelated prepared migrations.
4. **Approve and schedule the worker.** Review
   `supabase/operations/account_deletion_schedule.sql`, enable its prerequisite
   extensions, and install the cron job.
   [Supabase scheduling guidance](https://supabase.com/docs/guides/functions/schedule-functions)
   supports pg_cron with pg_net. This implementation instead uses a server-only
   one-use token so the cron definition contains no long-lived credential.
   The script does not enable intake or erase data.
5. **Test with an approved disposable account.** Verify signup/session ownership,
   one pending receipt, two initial messages, actual inbox delivery, duplicate
   suppression, outage retry, reminder behavior, and retention-safe fulfillment.
   Include a fixture with CE evidence, not only an empty account. Never use a real
   learner's account for destructive testing.
6. **Verify operator process.** Confirm daily queue review, failed-email
   reconciliation, retained-record retrieval, Sign in with Apple token revocation
   when applicable, processor removal, session invalidation and cache/access
   expiry. A checkbox is evidence recorded by an operator, not automated proof.
7. **Enable only after all gates pass.** Then update the single protected setting
   `enabled=true`. If intake is disabled later, continue processing existing
   requests and notifications; do not abandon them.

No activation, secret installation, email sending, or real-account deletion has
been authorized by merely reviewing this document. Each real destructive
fulfillment must identify the exact account and approved retention scope.

## Daily operator review

Use the Supabase SQL editor or a service-role-only administrative surface. Do not
place this query in a public app or expose it through an anonymous endpoint.

```sql
select id, contact_email, requested_at, due_at, status,
       (status='pending' and due_at < now()) as overdue
from public.luma_account_deletion_requests
order by (status='pending') desc, due_at;

select id, request_id, kind, status, attempts, provider_id, last_error_code
from public.luma_account_deletion_mail
where status <> 'accepted'
order by created_at;
```

Check cron run results and worker errors as well as email. If email itself fails,
an email-only reminder cannot alert you reliably. Investigate `needs_attention`
in Resend using the request/message reference; do not blindly reset its first
attempt time or idempotency key. Verify actual delivery separately because a
sending-only API key may not allow delivery lookup.

Before recording completion:

- Preserve required CE records and confirm they can be retrieved and reported.
- Remove non-retained app/profile/storage data and address processor-held data.
- Revoke linked sign-in credentials where applicable; invalidate sessions and
  prevent new sign-ins during fulfillment. Confirm previously issued tokens
  cannot continue accessing protected data.
- Call `luma_prepare_account_deletion` with the exact request ID and truthful
  evidence. Preparation expires after one hour; recheck the external steps if it
  expires. All of `nonretained_data_removed`, `processors_addressed`,
  `signin_tokens_addressed`, `sessions_revoked`, and `certificate_archives_verified`
  must be true, with an operator and explanatory note.
- Remove the auth account through a supported admin path only after the retention
  procedure is approved and tested.
- Record the responsible operator, evidence note, and a learner-readable summary
  of retained records. Call `luma_complete_account_deletion` only then.
- Confirm the completion email is delivered; account removal and email delivery
  are distinct events. Respect legally permitted exceptions and inform the user
  if a verified request needs additional time.

The completion RPC requires boolean evidence keys `retention_verified`,
`nonretained_data_removed`, `processors_addressed`, `signin_tokens_addressed`,
and `sessions_revoked`, plus `operator` and `note`. The retained-record summary is
included verbatim in the learner's completion email; do not include internal
secrets or patient data. Resubmitting completion does not send a second email.

Follow [Apple's account-deletion requirements](https://developer.apple.com/support/offering-account-deletion-in-your-app/)
and [Google's deletion guidance](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en).
This implementation document is not a claim of store approval or completed deletion.

## Local verification

```sh
flutter test test/policy_deletion_test.dart
node --test supabase/functions/account-deletion-notify/handler_test.mjs
npx --yes deno check supabase/functions/account-deletion-notify/index.ts
pg_virtualenv psql -v ON_ERROR_STOP=1 \
  -f test/deletion_database_setup.sql \
  -f supabase/migrations/20261002090000_account_deletion_requests.sql \
  -f test/deletion_database_assertions.sql \
  -f supabase/migrations/20261002110000_account_deletion_workflow.sql \
  -f test/deletion_workflow_assertions.sql \
  -f test/deletion_retention_setup.sql \
  -f supabase/migrations/20261002120000_account_deletion_retention.sql \
  -f test/deletion_retention_assertions.sql
```

The SQL fixtures are for a disposable local PostgreSQL cluster only. They create
test auth users and erase a test fixture; never run them against production.
