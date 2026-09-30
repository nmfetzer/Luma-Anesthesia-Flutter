import 'package:purchases_flutter/purchases_flutter.dart';

import 'ce_billing.dart';

/// A partial offering must not be mistaken for an unreleased course.
/// Only existing, allowlisted, one-time store products may reach checkout.
class CeStoreCatalog {
  CeStoreCatalog({
    Future<Offerings> Function()? loadOfferings,
    Future<List<StoreProduct>> Function(List<String>)? loadProducts,
  }) : _loadOfferings = loadOfferings ?? Purchases.getOfferings,
       _loadProducts = loadProducts ?? _fetchProducts;

  final Future<Offerings> Function() _loadOfferings;
  final Future<List<StoreProduct>> Function(List<String>) _loadProducts;
  final Map<String, Package> packages = {};
  final Map<String, StoreProduct> products = {};
  String diagnostic = '';
  static const offeringId = 'crna_courses';
  static const _timeout = Duration(seconds: 12);

  static Future<List<StoreProduct>> _fetchProducts(List<String> ids) =>
      Purchases.getProducts(
        ids,
        productCategory: ProductCategory.nonSubscription,
      );

  bool _accepts(StoreProduct product) =>
      CeProduct.accepts(product.identifier) &&
      product.subscriptionPeriod == null &&
      product.productCategory != ProductCategory.subscription;

  Future<List<CeStoreProduct>> load() async {
    packages.clear();
    products.clear();
    final notes = <String>[];
    try {
      final offering = (await _loadOfferings().timeout(_timeout))
          .all[offeringId];
      if (offering == null) notes.add('CE offering was not returned.');
      for (final package in offering?.availablePackages ?? <Package>[]) {
        final product = package.storeProduct;
        if (!_accepts(product)) continue;
        packages.putIfAbsent(product.identifier, () => package);
        products.putIfAbsent(product.identifier, () => product);
      }
    } catch (_) {
      notes.add('CE offering lookup could not complete.');
    }

    final missing = [
      for (final item in CeProduct.all)
        if (!products.containsKey(item.id)) item.id,
    ];
    if (missing.isNotEmpty) {
      try {
        final direct = await _loadProducts(missing).timeout(_timeout);
        for (final product in direct) {
          if (missing.contains(product.identifier) && _accepts(product)) {
            products[product.identifier] = product;
          }
        }
      } catch (_) {
        // Preserve successfully fetched packages while leaving missing items
        // disabled. No invented price or synthetic store product is allowed.
        notes.add('Direct store-product lookup could not complete.');
      }
    }
    final unresolved = [
      for (final item in CeProduct.all)
        if (!products.containsKey(item.id)) item.id,
    ];
    if (unresolved.isNotEmpty) {
      notes.add(
        'No purchasable store product returned for: ${unresolved.join(', ')}.',
      );
    }
    diagnostic = notes.join('\n');
    return [
      for (final item in CeProduct.all)
        if (products[item.id] case final product?)
          CeStoreProduct(product.identifier, product.priceString),
    ];
  }

  PurchaseParams? purchaseParams(String id) {
    if (!CeProduct.accepts(id)) return null;
    final package = packages[id];
    if (package != null) return PurchaseParams.package(package);
    final product = products[id];
    return product == null ? null : PurchaseParams.storeProduct(product);
  }
}
