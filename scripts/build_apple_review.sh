#!/usr/bin/env bash
# Run on the developer's Mac after the reviewed backend deployment.
# Does not upload, submit, release or enable customer sales.
set -euo pipefail
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "A Mac with Xcode and the app's Apple signing setup is required." >&2
  exit 1
fi
if [[ $# -ne 1 || ! "$1" =~ ^[1-9][0-9]*$ ]]; then
  echo "Usage: bash scripts/build_apple_review.sh NEW_UNUSED_BUILD_NUMBER" >&2
  exit 1
fi
cd "$(dirname "$0")/.."
flutter pub get
flutter build ipa --release \
  --build-name=3.0 \
  --build-number="$1" \
  --dart-define=LUMA_APPLE_REVIEW_ENABLED=true \
  --dart-define=LUMA_BILLING_ENABLED=false \
  --dart-define=LUMA_CE_BILLING_ENABLED=false
