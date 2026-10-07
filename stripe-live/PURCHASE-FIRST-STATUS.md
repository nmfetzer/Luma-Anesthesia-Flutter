# Purchase-first implementation status

Prepared October 7, 2026. Backend installed with guest purchasing OFF; website not deployed.

## Implemented in source

- Website-only feature flag `LUMA_CE_PURCHASE_FIRST`; mobile entry remains unchanged.
- Selected course or bundle opens a guest purchase page and Stripe-hosted payment.
- Separate private guest ledger saves payment before account creation or activation.
- Signed webhooks and authoritative Stripe session/charge checks; fixed live products and amounts.
- Fresh mailbox authentication required before email-to-account linking.
- Activation includes a disclosed password-security step and other-session sign-out. This is an additional safeguard compared with the earlier passwordless-only simulator.
- Existing ownership and shared lifetime bonus functions reused; overlapping purchases held for support.
- Refunded/disputed purchases cannot activate; existing learner progress is not overwritten.
- Server guest switch defaults OFF. Existing authenticated checkout remains available.

## Verified

- 70 local Node/PostgreSQL tests passed, including guest email binding, duplicate fulfillment, refunds, overlap and service-only permissions.
- 38 Flutter regression tests passed.
- Flutter production web build compiled successfully with purchase-first flag.
- Local browser UI uses intercepted fixture responses only; no Stripe sandbox or real payment was created.
- Desktop purchase page and mobile email-activation screen inspected; no browser page errors.
- Production guest catalog responds with all four products ready and guest `enabled:false`.
- Existing authenticated status endpoint still rejects signed-out callers.

## NOT completed / release blockers

- Additive guest migration applied to `xuckkusbbcxplpqclbxt`, guest switch OFF.
- `ce-stripe-live` version 6 deployed. Prior version 5 source matches repository base exactly and is saved in `deployment-backup/ce-stripe-live-before-guest.json`.
- No website deployment or guest activation switch has been enabled.
- Netlify API `/api/v1/user` returned HTTP 401 with the selected saved deployment credential. This does not establish whether its underlying value is invalid or why authorization failed.
- User's logged-in browser is not reachable from this task.
- Actual email redirect, signed-in activation, SMTP delivery and live end-to-end purchase remain unverified.
- Confirm account-security behavior against the production Auth configuration before enabling. Supabase other-session sign-out revokes refresh sessions; already-issued JWTs may remain valid until expiry.
- Complete release review of the new guest routes and device/browser activation flow before enabling.

## Release order

1. Completed: preserved rollback source, additive disabled migration, function version 6.
2. Confirm email callback routing and account-security requirements against production configuration.
3. Deploy web build to the existing `ce.cehalo.com` Netlify site, retaining a known-good rollback deploy.
4. Verify the new pages and actual email activation while guest checkout is OFF, then enable the guest switch.
5. Owner makes first live purchase. Do not make a charge on her behalf.

The existing direct route shape is retained. Do not call any link a live purchase-first page until deployment is verified.
