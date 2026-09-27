/// Exact Apple products. Course ownership and bonus dates are server decisions.
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
  static bool accepts(String id) => all.any((p) => p.id == id);
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
