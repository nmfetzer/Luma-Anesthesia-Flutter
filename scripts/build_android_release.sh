#!/usr/bin/env bash
# Builds the Play Store release App Bundle with verified production purchases.
# Does not upload, submit, release, or modify backend sales settings.
# The Google RevenueCat key is the app's PUBLIC SDK key (baked in as a default
# in lib/billing/revenuecat_billing.dart); no secret is passed here.
set -euo pipefail
# Android version is independent of iOS (iOS is driven by pubspec.yaml /
# scripts/build_apple_review.sh). The name is fixed here; the code defaults to
# the next unused value but can be overridden as the first argument for later
# uploads. versionCode must be strictly higher than every prior Play upload.
VERSION_NAME="3.1"
VERSION_CODE="${1:-17}"
if [[ ! "$VERSION_CODE" =~ ^[1-9][0-9]*$ ]]; then
  echo "Usage: bash scripts/build_android_release.sh [VERSION_CODE]   (default 17)" >&2
  exit 1
fi
cd "$(dirname "$0")/.."
flutter pub get
flutter build appbundle --release \
  --build-name="$VERSION_NAME" \
  --build-number="$VERSION_CODE" \
  --dart-define=LUMA_BILLING_ENABLED=true \
  --dart-define=LUMA_CE_BILLING_ENABLED=true
bundle="build/app/outputs/bundle/release/app-release.aab"
if [[ ! -f "$bundle" ]]; then
  echo "Expected bundle not found: $bundle" >&2
  exit 1
fi
echo "Built Play Store bundle: $bundle (versionName $VERSION_NAME, versionCode $VERSION_CODE)."
echo "Purchase environment is verified server-side; the build flag grants no access."
echo "Upload only this new bundle. This command has not uploaded or released it."
