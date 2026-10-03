import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/home/home_screen.dart';
import 'package:luma_anesthesia/home/home_tile.dart';
import 'package:luma_anesthesia/welcome/welcome_carousel.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget app(Widget screen, Size size, double scale) => MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        padding: const EdgeInsets.only(top: 44, bottom: 34),
        textScaler: TextScaler.linear(scale),
        disableAnimations: true,
      ),
      child: child!,
    ),
    home: screen,
    routes: {
      '/provider-support': (_) => const Scaffold(body: Text('Free support')),
      '/drug-library': (_) => const Scaffold(body: Text('Medication list')),
    },
  );

  void sizeFor(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Finder tile(String route) =>
      find.byWidgetPredicate((w) => w is HomeTile && w.data.route == route);

  for (final size in [
    const Size(320, 568),
    const Size(375, 667),
    const Size(390, 844),
    const Size(820, 1180),
    const Size(844, 390),
  ]) {
    for (final scale in [1.0, 1.6, 2.0]) {
      testWidgets('welcome full carousel $size text $scale', (tester) async {
        sizeFor(tester, size);
        var finished = false;
        await tester.pumpWidget(
          app(WelcomeCarousel(onFinish: () => finished = true), size, scale),
        );
        await tester.pumpAndSettle();
        for (var index = 0; index < 4; index++) {
          final cta = find.byKey(const ValueKey('welcome-next'));
          final reading = find.byKey(ValueKey('welcome-scroll-$index'));
          expect(cta.hitTestable(), findsOneWidget);
          final rect = tester.getRect(cta);
          expect(rect.bottom, lessThanOrEqualTo(size.height - 34));
          expect(rect.top, greaterThanOrEqualTo(44));
          expect(tester.getRect(reading).bottom, lessThan(rect.top));
          if (index == 2) {
            await tester.ensureVisible(find.text('Provider Support'));
            await tester.pumpAndSettle();
            expect(find.text('Provider Support').hitTestable(), findsOneWidget);
            expect(cta.hitTestable(), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
          await tester.tap(cta);
          await tester.pumpAndSettle();
        }
        expect(finished, isTrue);
        // Dots permit going backwards, not just advancing with Continue.
        await tester.tap(find.byTooltip('Welcome page 1'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('welcome-luma-wordmark')).hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final size in [
    const Size(320, 568),
    const Size(375, 667),
    const Size(820, 1180),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('mixed home grid $size text $scale', (tester) async {
        sizeFor(tester, size);
        await tester.pumpWidget(app(const HomeScreen(), size, scale));
        await tester.pumpAndSettle();
        expect(find.byType(HomeTile), findsNWidgets(8));
        final drug = tester.getRect(tile('/drug-library'));
        final crisis = tester.getRect(tile('/crisis-guidelines'));
        final patho = tester.getRect(tile('/special-considerations'));
        if (scale == 1) {
          expect(drug.top, closeTo(crisis.top, 0.1));
          expect(drug.height, closeTo(crisis.height, 0.1));
          expect(patho.width, greaterThan(drug.width * 1.9));
          expect(drug.height, lessThan(152));
        } else {
          expect(crisis.top, greaterThanOrEqualTo(drug.bottom));
          expect(patho.width, closeTo(drug.width, 0.1));
        }
        await tester.ensureVisible(tile('/first-days-in-or'));
        await tester.pumpAndSettle();
        expect(tile('/first-days-in-or').hitTestable(), findsOneWidget);
        await tester.ensureVisible(find.text('Coming soon'));
        await tester.pumpAndSettle();
        expect(find.text('• Diagnostics'), findsNothing);
        await tester.tap(find.text('Coming soon'));
        await tester.pumpAndSettle();
        expect(find.text('• Diagnostics'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(
          find.text('Mental Health & Recovery Support'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Mental Health & Recovery Support'));
        await tester.pumpAndSettle();
        expect(find.text('Free support'), findsOneWidget);
      });
    }
  }
}
