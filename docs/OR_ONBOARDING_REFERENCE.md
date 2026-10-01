# The First Days in the OR

The user-supplied PDF is included as an unchanged, bundled reference.

- Home tile: **The First Days in the OR**, following Quick References and before Coming soon.
- Route: `/first-days-in-or`.
- Asset: `assets/references/first_days_in_the_or.pdf`.
- Length: 39 pages; 3,697,552 bytes.
- SHA-256: `354e5f55ab2c80bba5997fc6809b8515590bad927731970df66088b60df5ca9c`.
- The native app reads bundled bytes without authentication or a network download.
- Uses the existing iOS PDFKit viewer and printing renderer on other platforms. No new PDFium dependency.
- Home, Back (when opened from another page), Reload PDF and asset-load retry controls.
- Standalone reference, not a paid CE course, credit award, subscription grant or promo-redemption integration.
- The supplied PDF has not been clinically rewritten or independently re-reviewed during integration.

## Release notes

The PDF's second page contains a FREELUMA3 promotion and advertisements for features that are deferred in the current app. These were flagged to the user and left unchanged. Adding this file does not activate the promotion, change Apple offers, enable future features, or establish Android store availability.

The selected mixed-grid home layout B is shown separately in the layout-review preview. This addition does not itself implement the pending home/welcome redesign or app-wide text-size/appearance controls.

## Verification

- Original and bundled PDF hashes match.
- Targeted tests: 26 passed across onboarding, existing PDF viewer, home navigation/search and launch device layouts.
- Actual Flutter web preview opened and displayed the PDF.
- Native PDFKit pinch/scroll behavior still requires verification on the new signed iPhone/iPad build.
- A new TestFlight archive is required; this source update is not an App Store upload.
