#!/usr/bin/env bash
# Internal clinician review only. No upload, submission, or backend mutation.
set -euo pipefail
if [[ $# -ne 2 || ! "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ || ! "$2" =~ ^[1-9][0-9]*$ ]]; then
  echo "Usage: bash scripts/build_surgical_testflight_review.sh VERSION UNUSED_BUILD_NUMBER" >&2
  exit 1
fi
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "A Mac with Xcode and Apple signing is required. No archive was built." >&2
  exit 1
fi
cd "$(dirname "$0")/.."
node scripts/verify_surgical_preservation.mjs
flutter pub get
flutter test --dart-define=LUMA_SURGICAL_REVIEW=true test/surgical_testflight_review_test.dart
flutter build ipa --release \
  --build-name="$1" --build-number="$2" \
  --dart-define=LUMA_SURGICAL_REVIEW=true \
  --dart-define=LUMA_APPLE_REVIEW_ENABLED=true \
  --dart-define=LUMA_BILLING_ENABLED=true \
  --dart-define=LUMA_CE_BILLING_ENABLED=true
plist="build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/Info.plist"
actual_version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$plist")
actual_build=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$plist")
[[ "$actual_version" == "$1" && "$actual_build" == "$2" ]] || {
  echo "Archive version mismatch. Do not upload." >&2; exit 1;
}
if [[ -n "$(find build/ios/archive/Runner.xcarchive/Products -iname '*pdfium*' -print -quit)" ]]; then
  echo "Unexpected PDFium in archive. Do not upload." >&2; exit 1
fi
printf 'INTERNAL CLINICAL REVIEW ONLY\nVersion: %s (%s)\nCommit: %s\nLUMA_SURGICAL_REVIEW=true\nNo upload performed. Do not select for public App Store release.\n' \
  "$1" "$2" "$(git rev-parse HEAD)" > build/ios/SURGICAL_REVIEW_ARCHIVE.txt
echo "Created internal review archive $1 ($2). Upload with Xcode for internal TestFlight only."
echo "Do not submit this review archive to the public App Store."
