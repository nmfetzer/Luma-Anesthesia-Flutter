import 'package:flutter/foundation.dart';

/// Store products for the CE courses. Course ownership and bonus dates are
/// server decisions. Apple uses the exact App Store ids (some capitalized);
/// Google Play ids must be all-lowercase, so each capitalized id maps to an
/// all-lowercase Play id. The canonical (Apple) id is used everywhere in-app.
class CeProduct {
  const CeProduct(this.id, this.title);
  final String id;
  final String title;
  static const medication = 'Medication_Review_for_the_Experienced_CRNA';
  static const uncommon = 'uncommon_anesthesia_events';
  static const legal = 'legal_essentials_CRNA';
  static const bundle = '3_course_bundle_pack';
  static const all = [
    CeProduct(medication, 'A Medication Review for the Experienced CRNA'),
    CeProduct(uncommon, 'Uncommon but Catastrophic Anesthesia Events'),
    CeProduct(legal, 'Legal Essentials for the CRNA'),
    CeProduct(bundle, 'Three-course bundle'),
  ];

  // Google Play forbids capital letters in product ids, so each canonical
  // (Apple) id maps to an all-lowercase Play id. Already-lowercase ids reuse
  // the same string on both stores.
  static const _googleIds = <String, String>{
    medication: 'medication_review_for_the_experienced_crna',
    uncommon: 'uncommon_anesthesia_events',
    legal: 'legal_essentials_crna',
    bundle: '3_course_bundle_pack',
  };

  /// True when [id] is a canonical course id used across the app.
  static bool accepts(String id) => all.any((p) => p.id == id);

  /// The store product id for canonical [id] on [platform]. Android uses the
  /// all-lowercase Play id; every other platform uses the canonical id.
  static String storeId(String id, TargetPlatform platform) =>
      platform == TargetPlatform.android ? (_googleIds[id] ?? id) : id;

  /// Maps any store id (canonical/Apple or Play) back to its canonical id,
  /// or null when it is not a known CE course product.
  static String? canonicalFor(String id) {
    if (accepts(id)) return id;
    for (final entry in _googleIds.entries) {
      if (entry.value == id) return entry.key;
    }
    return null;
  }
}

class CeStoreProduct {
  const CeStoreProduct(this.id, this.price);
  final String id;
  final String price;
}

class CePurchaseStatus {
  const CePurchaseStatus({
    required this.userId,
    required this.enabled,
    required this.owned,
    this.appleReview = false,
  });
  final String userId;
  final Set<String> enabled;
  final Set<String> owned;
  final bool appleReview;
}

abstract interface class CeBillingGateway {
  bool get ceSupported;
  Future<List<CeStoreProduct>> ceProducts();
  Future<CePurchaseStatus> ceStatus(String expectedUser);
  Future<void> purchaseCe(CeStoreProduct product);
}

/// Safe product-loading diagnostics only: no receipts, credentials or accounts.
abstract interface class CeStoreDiagnosticSource {
  String get ceStoreDiagnostic;
}
