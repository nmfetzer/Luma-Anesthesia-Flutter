import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/billing/ce_billing.dart';
import 'package:luma_anesthesia/billing/subscription_billing.dart';
import 'package:luma_anesthesia/ce/ce_purchase_screen.dart';

class CeFake implements BillingGateway, CeBillingGateway {
  @override
  String? userId = 'a';
  @override
  bool ceSupported = true;
  Set<String> enabled = {CeProduct.medication, CeProduct.bundle};
  Set<String> owned = {};
  int purchases = 0, restores = 0;
  bool offline = false;
  Completer<void>? pending;
  String? wrongUser;
  @override
  Future<void> identify(String? id) async {}
  @override
  Future<List<BillingPlan>> plans() async => [];
  @override
  Future<void> purchase(BillingPlan plan) async {}
  @override
  Future<bool> verify(String user) async => false;
  @override
  Future<void> restore() async {
    restores++;
  }

  @override
  Future<List<CeStoreProduct>> ceProducts() async => storeProducts;
  List<CeStoreProduct> storeProducts = const [
    CeStoreProduct(CeProduct.medication, '€249,99'),
    CeStoreProduct(CeProduct.bundle, '€499,99'),
  ];
  @override
  Future<CePurchaseStatus> ceStatus(String expectedUser) async {
    await pending?.future;
    if (offline) throw StateError('offline');
    return CePurchaseStatus(
      userId: wrongUser ?? expectedUser,
      enabled: Set.of(enabled),
      owned: Set.of(owned),
    );
  }

  @override
  Future<void> purchaseCe(CeStoreProduct product) async {
    purchases++;
  }
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  Widget app(SubscriptionBilling billing, String id) => MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: child!,
    ),
    home: CePurchaseScreen(billing: billing, productId: id),
  );
  testWidgets(
    'missing price is retryable, not described as an unreleased course',
    (tester) async {
      final fake = CeFake()..enabled.add(CeProduct.uncommon);
      final c = SubscriptionBilling(gateway: fake);
      await tester.pumpWidget(app(c, CeProduct.uncommon));
      await tester.pumpAndSettle();
      expect(find.text('Not available for purchase yet'), findsNothing);
      expect(find.text('Price could not be loaded'), findsOneWidget);
      expect(c.canPurchaseCe(CeProduct.uncommon), isFalse);
      fake.storeProducts = [
        ...fake.storeProducts,
        const CeStoreProduct(CeProduct.uncommon, '€179,99'),
      ];
      await tester.ensureVisible(find.text('Retry loading price'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retry loading price'));
      await tester.pumpAndSettle();
      expect(find.text('Purchase for €179,99'), findsOneWidget);
      expect(c.canPurchaseCe(CeProduct.uncommon), isTrue);
      expect(fake.purchases, 0);
      await tester.pumpWidget(const SizedBox());
      c.dispose();
    },
  );
  testWidgets(
    'CE storefront displays localized price without opening checkout',
    (tester) async {
      final fake = CeFake();
      final c = SubscriptionBilling(gateway: fake);
      await tester.pumpWidget(app(c, CeProduct.medication));
      await tester.pumpAndSettle();
      expect(find.text('Purchase for €249,99'), findsOneWidget);
      expect(
        find.text('A Medication Review for the Experienced CRNA'),
        findsOneWidget,
      );
      expect(fake.purchases, 0);
      await tester.ensureVisible(find.text('Purchase for €249,99'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Purchase for €249,99'));
      await tester.pumpAndSettle();
      expect(fake.purchases, 1);
      expect(c.ceStatus!.owned, isEmpty);
      await tester.pumpWidget(const SizedBox());
      c.dispose();
    },
  );
  testWidgets('disabled preview cannot purchase and supports narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = SubscriptionBilling();
    await tester.pumpWidget(app(c, CeProduct.medication));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Design preview. Complete purchases'),
      findsOneWidget,
    );
    expect(tester.takeException(), null);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -2000),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), null);
    await tester.pumpWidget(const SizedBox());
    c.dispose();
  });
  test(
    'CE requires server readiness, release gate and exact product',
    () async {
      final fake = CeFake();
      final c = SubscriptionBilling(gateway: fake);
      await c.purchaseCe(CeProduct.medication);
      expect(fake.purchases, 0);
      await c.refreshCe();
      expect(c.ceProducts.first.price, '€249,99');
      expect(c.canPurchaseCe(CeProduct.medication), true);
      expect(c.canPurchaseCe(CeProduct.legal), false);
      expect(c.canPurchaseCe('unknown'), false);
    },
  );
  test('disabled flag and signed-out accounts cannot purchase', () async {
    final fake = CeFake()..ceSupported = false;
    final c = SubscriptionBilling(gateway: fake);
    await c.refreshCe();
    expect(c.ceAvailable, false);
    fake.ceSupported = true;
    fake.userId = null;
    await c.refreshCe();
    expect(c.canPurchaseCe(CeProduct.medication), false);
    expect(fake.purchases, 0);
  });
  test('release rechecked immediately before opening Apple checkout', () async {
    final fake = CeFake();
    final c = SubscriptionBilling(gateway: fake);
    await c.refreshCe();
    fake.enabled.clear();
    await c.purchaseCe(CeProduct.medication);
    expect(fake.purchases, 0);
  });
  test(
    'successful store sheet never self-grants or allows a repeat tap',
    () async {
      final fake = CeFake();
      final c = SubscriptionBilling(gateway: fake);
      await c.refreshCe();
      await c.purchaseCe(CeProduct.medication);
      expect(fake.purchases, 1);
      expect(c.ceStatus!.owned, isEmpty);
      expect(c.message, contains('verification is pending'));
      await c.purchaseCe(CeProduct.medication);
      expect(fake.purchases, 1);
      fake.owned.add(CeProduct.medication);
      await c.refreshCe();
      expect(c.ceStatus!.owned, contains(CeProduct.medication));
    },
  );
  test('restore does not charge or require sales to be enabled', () async {
    final fake = CeFake()..enabled.clear();
    fake.owned.add(CeProduct.medication);
    final c = SubscriptionBilling(gateway: fake);
    await c.restoreCe();
    expect(fake.restores, 1);
    expect(fake.purchases, 0);
    expect(c.ceStatus!.owned, contains(CeProduct.medication));
  });
  test('offline preflight never opens store', () async {
    final fake = CeFake();
    final c = SubscriptionBilling(gateway: fake);
    await c.refreshCe();
    fake.offline = true;
    await c.purchaseCe(CeProduct.medication);
    expect(fake.purchases, 0);
    expect(c.ceReady, false);
  });
  test(
    'different-account response cannot unlock or authorize purchase',
    () async {
      final fake = CeFake()..wrongUser = 'victim';
      final c = SubscriptionBilling(gateway: fake);
      await c.refreshCe();
      expect(c.ceReady, false);
      expect(c.ceStatus, null);
    },
  );
  test(
    'account switch discards stale CE results and never purchases',
    () async {
      final fake = CeFake();
      final c = SubscriptionBilling(gateway: fake);
      await c.refreshCe();
      fake.pending = Completer<void>();
      final action = c.purchaseCe(CeProduct.medication);
      fake.userId = null;
      c.identityChanged();
      fake.pending!.complete();
      await action;
      expect(fake.purchases, 0);
      expect(c.ceStatus, null);
      expect(c.ceReady, false);
    },
  );
  test('CE and subscription operations share the same busy lock', () async {
    final fake = CeFake();
    final c = SubscriptionBilling(gateway: fake);
    await c.refreshCe();
    fake.pending = Completer<void>();
    final action = c.purchaseCe(CeProduct.medication);
    await c.restoreCe();
    await c.purchaseCe(CeProduct.medication);
    fake.pending!.complete();
    await action;
    expect(fake.purchases, 1);
    expect(fake.restores, 0);
  });
}
