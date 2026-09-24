# Apple and Google sign-in

## Status

Flutter account UI and Supabase browser-OAuth integration are implemented.
Production public auth settings checked September 24, 2026: Apple disabled,
Google disabled, email enabled. Provider configuration has not been changed.
Buttons check public `/auth/v1/settings` and remain disabled until their provider
is enabled. Email/password remains available. No subscription or entitlement is
granted by these buttons.

## Server-side activation

Use the existing Supabase project `xuckkusbbcxplpqclbxt`. Do not create another
project, migrate users, change RLS, or put provider secrets in Flutter or GitHub.

- Google: configure a Web application OAuth client with the project's callback
  `https://xuckkusbbcxplpqclbxt.supabase.co/auth/v1/callback`, then enter the client
  ID and secret in the Supabase Google provider. Use only the required identity
  scopes. See [Supabase Google setup](https://supabase.com/docs/guides/auth/social-login/auth-google).
- Apple: configure Sign in with Apple for the appropriate Apple App ID and a
  Services ID. Register domain `xuckkusbbcxplpqclbxt.supabase.co` and the same
  HTTPS callback above. Configure the Services ID first in Supabase's Apple
  Client IDs and supply its generated client secret. Keep the signing key private
  and arrange secret rotation before expiry, at most six months for this browser
  OAuth flow. See [Supabase Apple setup](https://supabase.com/docs/guides/auth/social-login/auth-apple).
- Add exact Supabase redirect allowlist entries:
  `com.luma.anesthesia://login-callback/` and
  `http://localhost:7357/?auth_callback=1`.
  Add the exact production web callback once a production web host is chosen.
  Do not add broad production wildcard redirects.

For stable local Chrome testing:

```bash
flutter run -d chrome --web-port=7357
```

The browser callback returns to the app root with `auth_callback=1`. The Supabase
Flutter SDK performs PKCE code exchange; the app opens My Account and observes
auth-state changes. Native apps use the registered custom URL scheme and the
SDK's app_links handler. These are browser OAuth flows, not native Google/Apple
SDK login sheets. App Store/Google Play purchase sheets are separate work.

## Preview and testing limits

The embedded Perplexity preview intentionally disables social OAuth because it
uses in-memory PKCE storage and has no approved stable callback origin. It shows
the actual account layout, but use main.dart locally or on a device to sign in.

Automated tests cover provider availability, provider dispatch, auth-state UI,
no false success on browser launch, retries/errors, preview restrictions, redirect
construction, and enlarged text. They do not validate real Google/Apple
credentials. After configuration, complete end-to-end sign-in and cancellation
on Chrome, iPhone, and Android, including app cold-start return, sign-out/re-entry,
Apple private-relay email, and existing-account behavior. Native platform builds
require their normal signing/bundle configuration and have not been device-tested
in this Linux workspace.

Do not manually merge accounts or copy entitlements when an Apple hidden email
differs from an existing email account. Use a reviewed authenticated account-linking
flow if needed.

The Google logo asset is downloaded from Google's
[official branding assets](https://developers.google.com/identity/branding-guidelines);
do not recolor or replace it with a typed letter.
