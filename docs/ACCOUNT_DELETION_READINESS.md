# Account deletion: prepared, not live

The user approved a seven-day turnaround and internal notification destination
`info@cehalo.com` on October 2, 2026. The app submits a deletion request, not an
automatic erase command. No live migration was applied in this work.

## Activation blockers

- A notification delivery provider is not configured. The Resend connection
  request was dismissed; do not prompt again unless the user explicitly asks.
- Establish durable email delivery/retry handling and daily queue monitoring
  before activating requests.
- Confirm CE record retention and non-retained data removal, including processor
  data and Sign in with Apple token revocation.
- Arrange completion emails and an external website deletion path.
- Run an end-to-end test with an approved disposable account, not a real learner.

`20261002090000_account_deletion_requests.sql` creates a protected, idempotent
request queue and availability/submission RPCs. It starts disabled and does not
send email, delete accounts or change purchase access. The UI does not accept
requests if the availability check fails. Never enable the setting merely to
make a button appear working, and never claim the queue alone completes deletion.

The request stores the account UUID, contact email, request/due timestamps,
pending/completed status and eventual completion evidence. Only the owning user
can read their request; authenticated clients cannot directly modify it.
Authenticated RPC submission derives identity and email from the session.

## Local verification

Run only against a disposable test PostgreSQL cluster:

```sh
pg_virtualenv psql -v ON_ERROR_STOP=1 \
  -f test/deletion_database_setup.sql \
  -f supabase/migrations/20261002090000_account_deletion_requests.sql \
  -f test/deletion_database_assertions.sql
```

All assertions passed. Flutter deletion tests cover unavailable service, explicit
confirmation, cancellation, request receipt, and failure without false success.

## Policy and CE notes

The core policy acknowledgment is local per-install/version, not a server consent
ledger. The embedded preview intentionally resets local preferences on reload.
The acknowledgment does not grant marketing, tracking or third-party AI consent.

AANA PDIS guidance states all program records must be securely retrievable for
at least 60 months; confirm applicable record scope/start date before fulfillment:
[AANA PDIS guidance](https://www.aana.com/wp-content/uploads/2026/01/Guidelines-for-Completion-of-an-Application-for-Prior-Approval-Provider-Directed-Independent-Study-January-2026.pdf).

Follow the in-app path and processor-token requirements in
[Apple's account deletion guidance](https://developer.apple.com/support/offering-account-deletion-in-your-app/)
and the public web request requirements in
[Google's account deletion guidance](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en).
