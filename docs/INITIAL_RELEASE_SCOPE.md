# Initial release scope

User decision: September 27, 2026. Focus the initial release on Drug Library,
Crisis Hub, Vasopressors / Infusions / Transfusions, CE HALO, and Quick References.
Provider mental health and recovery support remains free without an account.

Update authorized September 27, 2026: restore the completed
Pathophysiology & Anesthesia Considerations library for launch as the sixth
home section. Restore its menu destination, published-condition search,
welcome feature and subscription benefit. Keep existing Supabase access rules
and detail/deep-dive subscription enforcement unchanged. No clinical records,
purchase settings, or other deferred sections are changed by this restoration.

## Implemented presentation and navigation

- Home shows the six selected sections, plus the existing account and
  Quick Ref controls. It no longer greets every user with the owner's name.
- AI, Case Prep, Diagnostics,
  Regional & Procedures, Practice Guidelines, Luma Academy and EKG are deferred.
- Deferred routes and their subpaths return an unavailable screen. Neither
  subscriptions, search results, query strings, nor the private preview open
  their clinical or AI implementations.
- The launch app does not import the deferred screens. Their development source
  and clinical records are preserved for later work, not deleted.
- Home search includes published condition titles, categories and search tags.
  It does not fetch protected condition prose or deep dives.
- Welcome, account and paywall copy no longer advertise deferred features as
  current subscription benefits.
- Production `lib/main.dart` omits future-feature teasers.
- Private `lib/preview_main.dart` passes `showComingSoon: true`, displaying an
  informational Coming soon panel. This flag reveals no deferred functionality.
- Unimplemented Settings and My Certificates menu destinations are removed.
- No Supabase data, entitlement rules, store products or purchase settings changed.

## Store-review distinction

Apple's guideline 2.1 requires final submissions without temporary placeholder
content and calls for on-device testing. Therefore the Coming soon panel is for
the private review build, not the submitted application.
https://developer.apple.com/app-store/review/guidelines/

Build the submitted mobile app from `lib/main.dart`, never `preview_main.dart`
or the separate CE demo entry point. Future features require a later reviewed
release, not an undisclosed runtime toggle.

## Still blocking a paid launch

This scope change is not a claim that the app is ready for submission.

- Subscription checkout and restoration are still disabled in
  `lib/screens/subscription_screen.dart`. Native billing, verified entitlements,
  cancellation/expiration handling, and restoration need end-to-end testing.
- The latest shared CE handoff `CE_MODULE_2_FINAL_HANDOFF.md` records two of
  eleven modules loaded, with full-course release and native products disabled.
  It also records unfinished certificates/full-course awards and reporting
  integration. Do not sell or describe the full course as completed on this basis.
- Verify the final privacy policy, store privacy/data-safety declarations,
  account deletion, reviewer access, and accurate listing/screenshots against
  the actual release build.
- Signed iOS/Android builds, real-device tests and store-console submission
  status have not been established by the web preview or Flutter widget tests.
- No app has been submitted to Apple or Google by this change.

## Collaboration

This work starts from GitHub main `eb138da`, preserving the other session's
GLP-1 CE module and provider completion records. Fetch and merge shared main
before subsequent edits. Do not restore old home layouts or enable deferred
features accidentally when working on CE or billing.

## Verification

### Pathophysiology restoration

- Preserved shared main through `789ec49`, including the latest CE certificate
  work and Quick References owner sign-off.
- All 51 targeted Flutter tests passed after the merge, including published
  condition search, six home tiles, deferred-route guards, protected content,
  subscription prompts, welcome layouts and account information.
- Private release web build completed successfully. Targeted analysis reported
  no errors or warnings, with ten existing informational lint/deprecation notices.
- Browser checks confirmed the live catalog loads 240 entries across 12
  categories, Cardiac navigation works, condition search populates results,
  and both catalog and home-search detail entry points show the guest paywall.
- Mobile and desktop home layouts, mobile catalog/paywall/welcome feature,
  drawer navigation, Home return and no-match search were inspected.
- No clinical data, access rules, native purchase configuration or store
  submission changed as part of this restoration.

### Earlier initial-scope verification

- Incorporated shared main through `0011409`, including the CIED Quick Reference
  and flexible search update, before final builds.
- Full Flutter test suite: 186 tests passed.
- Both production `main.dart` and private `preview_main.dart` release web builds
  completed successfully.
- Browser checks passed on mobile and desktop for both home variants, all four
  welcome pages, and deferred-route guards. No browser page errors were recorded.
- These are web and automated checks, not native billing or store approval.
