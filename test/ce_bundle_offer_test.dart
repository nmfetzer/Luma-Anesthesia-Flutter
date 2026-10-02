import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luma_anesthesia/billing/ce_billing.dart';
import 'package:luma_anesthesia/billing/subscription_billing.dart';
import 'package:luma_anesthesia/ce/ce_bundle_offer.dart';
import 'package:luma_anesthesia/ce/ce_library_screen.dart';
import 'package:luma_anesthesia/ce/ce_purchase_screen.dart';

import 'ce_library_test.dart' show LibraryRepo;

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> mount(
    WidgetTester tester, {
    bool ownsAll = false,
    bool provider = false,
    bool busy = false,
  }) async {
    final repos = [
      for (final n in [1, 2, 3])
        LibraryRepo(n, access: ownsAll, provider: provider),
    ];
    for (final repo in repos) {
      addTearDown(repo.events.close);
    }
    final billing = SubscriptionBilling()..busy = busy;
    addTearDown(billing.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: CeLibraryScreen(repositories: repos, billing: billing),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('offer appears once; dismissal does not hide the bundle card', (
    tester,
  ) async {
    await mount(tester);
    expect(find.byType(CeBundleOfferDialog), findsOneWidget);
    expect(find.text('60 total MAC Ed CE credits'), findsOneWidget);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.byType(CeBundleOfferDialog), findsNothing);
    expect(find.byType(CeBundleOfferCard), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getBool(ceBundleOfferSeenKey),
      isTrue,
    );
    await tester.tap(find.byTooltip('Refresh course access'));
    await tester.pumpAndSettle();
    expect(find.byType(CeBundleOfferDialog), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await mount(tester);
    expect(find.byType(CeBundleOfferDialog), findsNothing);
    expect(find.byType(CeBundleOfferCard), findsOneWidget);
  });

  testWidgets(
    'explore opens existing bundle paywall, not an individual course',
    (tester) async {
      await mount(tester);
      await tester.tap(find.byKey(const ValueKey('ce-bundle-offer-view')));
      // The destination paywall has an intentionally continuous star animation.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(CeBundleOfferDialog), findsNothing);
      final paywall = tester.widget<CePurchaseScreen>(
        find.byType(CePurchaseScreen),
      );
      expect(paywall.productId, CeProduct.bundle);
      expect(
        paywall.billing!.ceAwaitingVerification(CeProduct.bundle),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('existing owners do not receive a redundant bundle offer', (
    tester,
  ) async {
    await mount(tester, ownsAll: true);
    expect(find.byType(CeBundleOfferDialog), findsNothing);
    expect(find.byType(CeBundleOfferCard), findsNothing);
  });

  testWidgets('providers and active checkout are not interrupted', (
    tester,
  ) async {
    await mount(tester, provider: true);
    expect(find.byType(CeBundleOfferDialog), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await mount(tester, busy: true);
    expect(find.byType(CeBundleOfferDialog), findsNothing);
    expect(find.byType(CeBundleOfferCard), findsNothing);
  });

  for (final width in [320.0, 390.0, 820.0]) {
    testWidgets('scrollable offer fits $width at large text size', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await mount(tester);
      expect(find.byType(CeBundleOfferDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Not now'));
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.byType(CeBundleOfferDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
