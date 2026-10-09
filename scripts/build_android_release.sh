#!/usr/bin/env bash
# Builds the Play Store release App Bundle with verified production purchases.
# Does not upload, submit, release, or modify backend sales settings.
# The Google RevenueCat key is the app's PUBLIC SDK key (baked in as a default
# in lib/billing/revenuecat_billing.dart); no secret is passed here.
set -euo pipefail
if [[ $# -ne 1 || ! "$1" =~ ^[1-9][0-9]*$ ]]; then
  echo "Usage: bash scripts/build_android_release.sh NEW_UNUSED_VERSION_CODE" >&2
  exit 1
fi
cd "$(dirname "$0")/.."
flutter pub get
flutter build appbundle --release \
  --build-name=2.3 \
  --build-number="$1" \
  --dart-define=LUMA_BILLING_ENABLED=true \
  --dart-define=LUMA_CE_BILLING_ENABLED=true
bundle="build/app/outputs/bundle/release/app-release.aab"
if [[ ! -f "$bundle" ]]; then
  echo "Expected bundle not found: $bundle" >&2
  exit 1
fi
echo "Built Play Store bundle: $bundle (versionName 3.0.0, versionCode $1)."
echo "Purchase environment is verified server-side; the build flag grants no access."
echo "Upload only this new bundle. This command has not uploaded or released it."
