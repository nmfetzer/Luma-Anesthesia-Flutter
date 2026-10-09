import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:luma_anesthesia/billing/ce_billing.dart';
import 'package:luma_anesthesia/billing/ce_store_catalog.dart';

StoreProduct product(String id, {bool subscription = false}) => StoreProduct(
  id,
  'Test product',
  id,
  249.99,
  '€249,99',
  'EUR',
  productCategory: subscription
      ? ProductCategory.subscription
      : ProductCategory.nonSubscription,
  subscriptionPeriod: subscription ? 'P1M' : null,
);

Offerings offering(List<String> ids) => Offerings({
  'crna_courses': Offering('crna_courses', 'CE', const {}, [
    for (final id in ids)
      Package(
        'package_$id',
        PackageType.custom,
        product(id),
        const PresentedOfferingContext('crna_courses', null, null),
      ),
  ]),
});

void main() {
  test(
    'partial offering looks up only missing exact IDs and keeps store prices',
    () async {
      List<String>? requested;
      final catalog = CeStoreCatalog(
        platform: TargetPlatform.iOS,
        loadOfferings: () async => offering([CeProduct.medication]),
        loadProducts: (ids) async {
          requested = ids;
          return ids.map(product).toList();
        },
      );
      final loaded = await catalog.load();
      expect(requested, [
        CeProduct.uncommon,
        CeProduct.legal,
        CeProduct.bundle,
      ]);
      expect(loaded.map((p) => p.id), CeProduct.all.map((p) => p.id));
      expect(loaded.every((p) => p.price == '€249,99'), isTrue);
      expect(catalog.purchaseParams(CeProduct.medication)!.package, isNotNull);
      expect(
        catalog.purchaseParams(CeProduct.legal)!.product!.identifier,
        CeProduct.legal,
      );
      expect(catalog.diagnostic, isEmpty);
    },
  );

  test('complete offering needs no extra store lookup', () async {
    final catalog = CeStoreCatalog(
      platform: TargetPlatform.iOS,
      loadOfferings: () async =>
          offering(CeProduct.all.map((p) => p.id).toList()),
      loadProducts: (_) => throw StateError('must not be called'),
    );
    expect(await catalog.load(), hasLength(4));
    expect(catalog.diagnostic, isEmpty);
  });

  test(
    'offering error still permits explicit existing-product lookup',
    () async {
      final catalog = CeStoreCatalog(
        platform: TargetPlatform.iOS,
        loadOfferings: () async =>
            throw StateError('simulated offering failure'),
        loadProducts: (ids) async => ids.map(product).toList(),
      );
      expect(await catalog.load(), hasLength(4));
      expect(catalog.purchaseParams(CeProduct.uncommon)!.product, isNotNull);
      expect(catalog.diagnostic, contains('offering lookup'));
    },
  );

  test(
    'unreturned products stay disabled and are identified without secrets',
    () async {
      final catalog = CeStoreCatalog(
        platform: TargetPlatform.iOS,
        loadOfferings: () async => offering([CeProduct.medication]),
        loadProducts: (_) async => [],
      );
      expect(await catalog.load(), hasLength(1));
      expect(catalog.purchaseParams(CeProduct.legal), isNull);
      expect(catalog.diagnostic, contains(CeProduct.legal));
    },
  );

  test(
    'direct lookup failure retains Course 1 and never fabricates prices',
    () async {
      final catalog = CeStoreCatalog(
        platform: TargetPlatform.iOS,
        loadOfferings: () async => offering([CeProduct.medication]),
        loadProducts: (_) async => throw StateError('private diagnostic'),
      );
      expect(await catalog.load(), hasLength(1));
      expect(catalog.purchaseParams(CeProduct.bundle), isNull);
      expect(catalog.diagnostic, isNot(contains('private diagnostic')));
    },
  );

  test(
    'unknown IDs and subscription-shaped products cannot become CE purchases',
    () async {
      final catalog = CeStoreCatalog(
        platform: TargetPlatform.iOS,
        loadOfferings: () async => const Offerings({}),
        loadProducts: (_) async => [
          product('unrelated-product'),
          product(CeProduct.legal, subscription: true),
          product(CeProduct.uncommon),
        ],
      );
      expect((await catalog.load()).map((p) => p.id), [CeProduct.uncommon]);
      expect(catalog.purchaseParams('unrelated-product'), isNull);
      expect(catalog.purchaseParams(CeProduct.legal), isNull);
    },
  );

  test('retry replaces missing results and clears old diagnostics', () async {
    var complete = false;
    final catalog = CeStoreCatalog(
      platform: TargetPlatform.iOS,
      loadOfferings: () async => offering([CeProduct.medication]),
      loadProducts: (ids) async => complete ? ids.map(product).toList() : [],
    );
    expect(await catalog.load(), hasLength(1));
    complete = true;
    expect(await catalog.load(), hasLength(4));
    expect(catalog.diagnostic, isEmpty);
  });

  test('android fetches lowercase Play ids but exposes canonical ids', () async {
    List<String>? requested;
    final catalog = CeStoreCatalog(
      platform: TargetPlatform.android,
      loadOfferings: () async => const Offerings({}),
      loadProducts: (ids) async {
        requested = ids;
        return ids.map(product).toList();
      },
    );
    final loaded = await catalog.load();
    // The store is queried with the all-lowercase Play ids.
    expect(requested, [
      'medication_review_for_the_experienced_crna',
      'uncommon_anesthesia_events',
      'legal_essentials_crna',
      '3_course_bundle_pack',
    ]);
    // ...but the app sees the canonical (Apple) ids throughout.
    expect(loaded.map((p) => p.id), CeProduct.all.map((p) => p.id));
    // Purchase params resolve by canonical id to the lowercase store product.
    expect(
      catalog.purchaseParams(CeProduct.legal)!.product!.identifier,
      'legal_essentials_crna',
    );
  });

  test('CeProduct maps canonical ids to Play ids and back', () {
    // Capitalized Apple ids become all-lowercase on Android.
    expect(
      CeProduct.storeId(CeProduct.legal, TargetPlatform.android),
      'legal_essentials_crna',
    );
    expect(CeProduct.storeId(CeProduct.legal, TargetPlatform.iOS), CeProduct.legal);
    // Already-lowercase ids are identical on both stores.
    expect(
      CeProduct.storeId(CeProduct.uncommon, TargetPlatform.android),
      CeProduct.uncommon,
    );
    // Any store id maps back to its canonical id; unknown ids return null.
    expect(CeProduct.canonicalFor('legal_essentials_crna'), CeProduct.legal);
    expect(CeProduct.canonicalFor(CeProduct.legal), CeProduct.legal);
    expect(CeProduct.canonicalFor('not_a_course'), isNull);
  });
}
