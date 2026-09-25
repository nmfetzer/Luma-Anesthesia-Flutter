/// Approved product metadata, not a purchase or credit-grant implementation.
///
/// Future native checkout must fetch its localized price from the store, verify
/// transactions server-side, and grant credits only from the server's catalog.
/// These client constants must never authorize a balance change.
abstract final class LumaAiCatalog {
  static const iosProductId = 'luma_ai_credits_150';
  static const creditsPerPack = 150;
  static const usPreviewPrice = 'US\$4.99';
  static const mascotAsset = 'assets/branding/luma_assistant.png';

  // No StoreKit/Play billing or model adapter is connected in this release.
  static const purchasesEnabled = false;
  static const liveAiEnabled = false;

  // Do not infer a Google Play product or an included allowance from the pack.
  static const String? androidProductId = null;
  static const int? includedMonthlyCredits = null;
}
