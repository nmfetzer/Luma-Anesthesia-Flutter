#!/usr/bin/env bash
# Same binary supports verified sandbox review and verified production purchases.
# Does not upload, submit, release, or modify backend sales settings.
set -euo pipefail
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "A Mac with Xcode and the app's Apple signing setup is required." >&2
  exit 1
fi
if [[ $# -ne 1 || ! "$1" =~ ^[1-9][0-9]*$ ]]; then
  echo "Usage: bash scripts/build_apple_release.sh NEW_UNUSED_BUILD_NUMBER" >&2
  exit 1
fi
cd "$(dirname "$0")/.."
flutter pub get
flutter build ipa --release \
  --build-name=3.0.0 \
  --build-number="$1" \
  --dart-define=LUMA_APPLE_REVIEW_ENABLED=true \
  --dart-define=LUMA_BILLING_ENABLED=true \
  --dart-define=LUMA_CE_BILLING_ENABLED=true
app_plist="build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/Info.plist"
actual_version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app_plist")
actual_build=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$app_plist")
if [[ "$actual_version" != "3.0.0" || "$actual_build" != "$1" ]]; then
  echo "Archive version mismatch: found $actual_version ($actual_build)." >&2
  exit 1
fi
legacy_pdfium=$(find build/ios/archive/Runner.xcarchive/Products \
  -iname '*pdfium*' -print -quit)
if [[ -n "$legacy_pdfium" ]]; then
  echo "Unexpected legacy PDFium found. Do not upload: $legacy_pdfium" >&2
  exit 1
fi
echo "Verified archive: Luma Anesthesia $actual_version ($actual_build); no PDFium."
echo "Purchase environment is verified server-side; build flags grant no access."
echo "Upload only this new archive. This command has not uploaded or released it."
