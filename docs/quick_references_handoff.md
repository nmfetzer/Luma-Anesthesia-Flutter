# Searchable Quick References

This addition implements the owner's approved Quick References request in the existing Flutter app and connected Supabase project. It initially added **Pre-Op Clearance Guidelines**, with 12 separately searchable sections. The subsequent approved **AICDs & Pacemakers** guide adds 11 sections and flexible multi-keyword search; see [CIED search upgrade](cied_search_upgrade.md) for the current release and verification notes.

## User-facing behavior

- **Quick Ref shortcut (owner-selected option D):** Lower-right ivory pill with a slender blue lightning bolt, blue “Quick Ref” label, and subtle neutral border. Uses a minimum 48-pixel touch target and the accessibility label “Quick References.” Hidden on welcome, account, subscription, CE access, Quick References, dialogs, and while the keyboard is open.
- **Menu entry:** Quick References is also available in the home drawer.
- **Welcome pages:** The existing third welcome slide introduces Quick References, searchable source-linked guidance, Pre-Op Clearance Guidelines and GLP-1 considerations. No extra slide or unbuilt future guides are advertised.
- **Mobile spacing:** The home footer reserves a clear lower lane for the wider shortcut on smaller screens.
- **Search:** Searches section titles, parent guide titles, and curated aliases. GLP1, GLP-1, GLP 1, semaglutide and tirzepatide find the GLP-1 section directly.
- **Reader:** Opens only the selected section, with bulleted clinical content, inline external source links, scope reminder and content version.
- **Navigation:** Back retains the search query. Home returns to the existing dashboard.
- **Failure states:** Loading, no matches, offline retry and access-required states are explicit.

## Data and access

- **Project:** `xuckkusbbcxplpqclbxt`.
- **Catalog:** `public.quick_reference_catalog` contains published titles, aliases and ordering. Public read access permits search without publishing the clinical bodies.
- **Clinical content:** `public.quick_reference_sections` contains Markdown and version metadata. RLS uses the existing `public.has_clinical_premium_access()` helper.
- **Content version:** `2026-09-27` identifies this owner-approved adaptation; it is not a claim that every recommendation was reconciled against all later specialty updates.
- **Clinical source basis:** The approved [2024 AHA/ACC guideline](https://www.ahajournals.org/doi/10.1161/CIR.0000000000001285), with separately attributed clearance-visit guidance and [multisociety GLP-1 guidance](https://pmc.ncbi.nlm.nih.gov/articles/PMC11666732/) and [2025 SPAQI consensus](https://pmc.ncbi.nlm.nih.gov/articles/PMC12597468/).
- **Deployment state:** The schema and 12 content rows have already been applied to Supabase. Do not rerun the migration against that project. The migration filename matches the database migration history.
- **No access changes:** No subscription, owner entitlement or purchase records were modified. No protected bodies are bundled into Flutter assets.
- **Auth transitions:** The reader clears its body before re-fetching on auth changes and app resume; stale asynchronous responses cannot restore a previous session's content.

## Integration with the other active development session

The starting GitHub commit was `75e02faa6f0cce3591e1d536a9d93206f104999e`. Newer Diagnostics work in the other session was not present in this checkout.

Preserve that session's current local changes before pulling or merging this addition from GitHub main. Do not replace its working directory with this checkout, run a destructive reset, or redeploy an older build over its newer preview.

The only modified existing files are:

- `lib/main.dart`: Two imports, route observer/builder integration, and the `/quick-references` route.
- `lib/home/home_menu_drawer.dart`: Quick References navigation item.
- `lib/home/home_screen.dart`: Responsive footer padding to avoid shortcut overlap.
- `lib/welcome/welcome_slides.dart`: Brief Quick References introduction on the feature slide.

Everything else is additive under `lib/quick_references/`, `test/`, `supabase/`, `tool/` and this document. Merge the existing-file additions into the other session's latest versions, then rebuild that current source tree and update its existing preview using the same artifact identity.

This task does not release an App Store/TestFlight binary or overwrite the other session's hosted preview. Supabase content being present does not update an already-built Flutter binary.

## Verification

- **Flutter tests:** 113 tests passed after the option D and welcome-page update, including nine Quick References tests and eight welcome/footer checks at phone, tablet and desktop sizes.
- **Targeted analysis:** No issues in the new module and its tests. The repository-wide analyzer has pre-existing diagnostics; unrelated code was not reformatted or repaired.
- **Build:** Release web build of `lib/preview_main.dart` succeeded with Flutter 3.47.5.
- **Browser:** Phone at 375 × 812 and desktop at 1280 × 900 checked for the option D shortcut, welcome introduction, live catalog, GLP1 search and direct section opening.
- **Protected content:** Real anonymous browser requests were denied the body as expected. Reader visual checks used a local-only intercepted response containing the approved content, not an authorization bypass in app code.
- **Database RLS:** 12 catalog rows publicly visible; 0 clinical bodies visible anonymously, to an unpaid account or an anonymous authenticated session; 12 visible under an existing eligible account's claims. Client writes denied. Tests used transaction-local claims and rolled back.
- **Other interactions:** Browse, back/query preservation, aliases, clear, empty results, retry, sign-out clearing, enlarged text, dialog hiding, ascending order and pagination beyond 200 entries covered by automated tests.
- **Visual checks:** No horizontal overflow at tested sizes. Shared screenshots show the real Flutter UI; the content-reader screenshot is a local QA fixture.

## Content maintenance

The server-only seed is `supabase/seeds/preop_quick_reference.sql`. It was mechanically derived from the owner-approved Markdown using `tool/prepare_quick_reference_seed.mjs`, preserving source links and removing draft-only editorial labels.

Future guides can use new reference IDs and section rows without hardcoding their clinical content into Flutter. Keep clinical changes behind owner review, update content versions, and add relevant section-level aliases to make search useful.

## Owner review in Chrome

From the owner's existing Mac checkout:

```sh
cd ~/Documents/Luma-Anesthesia-Flutter &&
git pull --ff-only origin main &&
flutter pub get &&
flutter run -d chrome
```

If Git refuses the pull because of local edits or divergent history, stop and reconcile those edits; do not reset the checkout. The command launches the local Flutter app using its configured Supabase backend, not a new App Store release. Sign in with the existing owner account to review protected clinical content. Open Quick Ref and browse either guide, or search GLP1 or bipolar and AICD.
