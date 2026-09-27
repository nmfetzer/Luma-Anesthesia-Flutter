import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/home/home_screen.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_shortcut.dart';
import 'package:luma_anesthesia/welcome/welcome_carousel.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final size in [
    const Size(320, 568),
    const Size(375, 812),
    const Size(820, 1180),
    const Size(1280, 900),
  ]) {
    testWidgets('welcome introduces searchable pre-op guidance at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(home: WelcomeCarousel(onFinish: () {})),
      );
      await tester.pump(const Duration(milliseconds: 100));
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.text('Continue'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1500));
      }
      expect(find.text('Quick References'), findsOneWidget);
      final copy = find.text(
        'Tap Quick Ref for searchable, source-linked guidance. Start with Pre-Op Clearance Guidelines, including GLP-1 considerations.',
      );
      expect(copy, findsOneWidget);
      await tester.ensureVisible(copy);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('Quick Ref leaves home footer unobstructed at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final navigatorKey = GlobalKey<NavigatorState>();
      final observer = QuickReferenceRouteObserver();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: [observer],
          initialRoute: '/home',
          routes: {
            '/': (_) => const SizedBox.shrink(),
            '/home': (_) => const HomeScreen(),
          },
          builder: (context, child) => QuickReferenceShortcut(
            observer: observer,
            navigatorKey: navigatorKey,
            child: child!,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final shortcut = tester.getRect(find.byType(ElevatedButton));
      for (final label in ['AANA-APPROVED CE', 'REVIEWED BY CLINICIANS']) {
        expect(shortcut.overlaps(tester.getRect(find.text(label))), isFalse);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
