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
      loadOfferings: () async => offering([CeProduct.medication]),
      loadProducts: (ids) async => complete ? ids.map(product).toList() : [],
    );
    expect(await catalog.load(), hasLength(1));
    complete = true;
    expect(await catalog.load(), hasLength(4));
    expect(catalog.diagnostic, isEmpty);
  });
}
