import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/billing/ce_billing.dart';
import 'package:luma_anesthesia/billing/subscription_billing.dart';
import 'package:luma_anesthesia/ce/ce_purchase_screen.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_shortcut.dart';

import 'ce_billing_test.dart' show CeFake;

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  Widget app(Widget screen, {double scale = 1}) => MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(disableAnimations: true, textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: screen,
    routes: {
      '/home': (_) => const Scaffold(body: Text('Dashboard')),
      '/ce-halo': (_) => const Scaffold(body: Text('CE library')),
      '/account': (_) => const Scaffold(body: Text('Account')),
    },
  );

  for (final product in CeProduct.all) {
    for (final size in [const Size(375, 812), const Size(820, 1180)]) {
      testWidgets('${product.id} has one purchase at $size', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final fake = CeFake()
          ..enabled = CeProduct.all.map((p) => p.id).toSet()
          ..storeProducts = [
            for (final p in CeProduct.all) CeStoreProduct(p.id, '€199,99'),
          ];
        final billing = SubscriptionBilling(gateway: fake);
        await tester.pumpWidget(
          app(CePurchaseScreen(productId: product.id, billing: billing)),
        );
        await tester.pumpAndSettle();
        expect(find.byType(FilledButton), findsOneWidget);
        expect(find.text('Purchase for €199,99'), findsOneWidget);
        expect(
          find.text(
            product.id == CeProduct.bundle
                ? 'Up to 3 complimentary months of Luma Premium'
                : '1 complimentary month of Luma Premium',
          ),
          findsOneWidget,
        );
        await tester.ensureVisible(find.text('Privacy Policy'));
        await tester.pumpAndSettle();
        expect(find.text('Home').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        billing.dispose();
      });
    }
  }

  testWidgets('large text, narrow screen and legal links remain usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final opened = <String>[];
    await tester.pumpWidget(
      app(
        CePurchaseScreen(
          productId: CeProduct.uncommon,
          openExternal: (uri) async {
            opened.add('$uri');
            return true;
          },
        ),
        scale: 2,
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacy Policy'));
    expect(opened, ['https://cehalo.com/privacy-policy']);
    expect(find.text('Home').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('options index opens matching paywall without purchasing', (
    tester,
  ) async {
    final fake = CeFake();
    final billing = SubscriptionBilling(gateway: fake);
    await tester.pumpWidget(app(CePurchaseScreen(billing: billing)));
    await tester.pumpAndSettle();
    expect(find.byType(FilledButton), findsNothing);
    await tester.tap(find.text('Legal Essentials for the CRNA'));
    await tester.pumpAndSettle();
    expect(find.text('LEGAL ESSENTIALS'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(fake.purchases, 0);
    await tester.pumpWidget(const SizedBox());
    billing.dispose();
  });

  testWidgets('guest sees account entry, not an enabled purchase', (
    tester,
  ) async {
    final fake = CeFake()..userId = null;
    final billing = SubscriptionBilling(gateway: fake);
    await tester.pumpWidget(
      app(CePurchaseScreen(productId: CeProduct.medication, billing: billing)),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sign in to purchase'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in to purchase'));
    await tester.pumpAndSettle();
    expect(find.text('Account'), findsOneWidget);
    expect(fake.purchases, 0);
    await tester.pumpWidget(const SizedBox());
    billing.dispose();
  });

  test('course number maps to the exact existing Apple product', () {
    expect(CePurchaseScreen.productForCourse(1), CeProduct.medication);
    expect(CePurchaseScreen.productForCourse(2), CeProduct.uncommon);
    expect(CePurchaseScreen.productForCourse(3), CeProduct.legal);
    expect(() => CePurchaseScreen.productForCourse(4), throwsArgumentError);
  });

  testWidgets('Quick Reference overlay stays off product-specific paywalls', (
    tester,
  ) async {
    final observer = QuickReferenceRouteObserver();
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: key,
        navigatorObservers: [observer],
        home: const Scaffold(),
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const Scaffold(),
        ),
      ),
    );
    key.currentState!.pushNamed('/ce-purchase?product=${CeProduct.legal}');
    await tester.pumpAndSettle();
    expect(observer.visible.value, isFalse);
  });
}
