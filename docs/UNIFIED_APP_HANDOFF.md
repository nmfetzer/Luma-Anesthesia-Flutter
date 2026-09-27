# Unified app integration

Integrated September 27, 2026. This combines the Diagnostics/provider-support
work ending at `fdd419b` with GitHub main at `02eae06`, containing Quick References
and Course 1 CE. Neither branch was reset or replaced.

## Navigation preserved

- Diagnostics uses `showDiagnosticsDraft`, false by default and true only in
  `lib/preview_main.dart`. The reviewed ACT comparison chart remains at the top
  of the expanded ACT reference.
- `/provider-support` stays directly accessible without an account or payment.
- `/quick-references` preserves the optional search argument and the ivory
  Quick Ref shortcut.
- `/ce-halo` and `/ce-halo/courses` open the real Supabase-backed CE screen.
- `lib/ce_portal_main.dart` retains the CE-only entry via `cePortal: true`.
- EKG was not restored to the Diagnostics navigation.

## Release boundaries

- No Supabase migrations, seeds, grants, or content updates were executed during
  this integration. Do not rerun the already-applied CE or Quick References
  migrations simply because this checkout now contains their files.
- The unified preview is a Flutter review build, not an App Store release.
- Clinical draft restrictions, paid access, CE ownership and disabled purchase
  controls are preserved. No AI generation or billing was enabled.
- Production entry points do not import CE demo data or the demo repository.
  The course seed and answer bank are not web assets.

## Verification

- All 163 existing Flutter tests passed after merging the app code.
- Two additional integration tests passed, covering production defaults and the
  combined Diagnostics, support, Quick References and CE route factory.
- Both `lib/main.dart` and `lib/preview_main.dart` built successfully for release
  web using Flutter 3.47.5 / Dart 3.13.4.
- Targeted analysis reported no errors or warnings; 27 existing informational
  lint/deprecation notices remain.
- Browser checks confirmed the ACT chart on mobile and desktop, including its
  direct source button; no browser runtime errors were observed.
- Mobile browser checks confirmed the home shortcut, the live 12-section
  Quick References catalog, the staged CE catalog with disabled checkout, and
  free provider support without sign-in.

## Working across sessions

Before editing the app, inspect the active checkout and fetch GitHub main.
Preserve local uncommitted work; merge newer shared changes instead of replacing
the checkout with an older preview or source archive. Use normal non-force
pushes after testing.

Project file submissions preserve supporting documents but do not automatically
merge application code. A deployed preview is a build snapshot, not a live view
of other sessions' unpushed edits. Rebuild the preview after integrating changes.

See `CE_COURSE_1_HANDOFF.md` and `quick_references_handoff.md` for their respective
backend and implementation details.
