import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/home/home_screen.dart';
import 'package:luma_anesthesia/welcome/welcome_carousel.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final size in [
    const Size(320, 568),
    const Size(375, 812),
    const Size(1280, 800)
  ]) {
    testWidgets('symbol-only account button opens account at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        home: const HomeScreen(),
        routes: {
          '/account': (_) => const Scaffold(body: Text('Account destination'))
        },
      ));
      await tester.pump(const Duration(milliseconds: 100));
      final button = find.byKey(const ValueKey('home-account-button'));
      final image = tester.widget<Image>(
          find.descendant(of: button, matching: find.byType(Image)));
      expect((image.image as AssetImage).assetName,
          'assets/branding/luma_symbol_halo.png');
      expect(tester.getSize(button).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
      expect(find.byTooltip('Account'), findsOneWidget);
      await tester.tap(button);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Account destination'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets(
        'welcome displays gold Luma below symbol without clipping at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester
          .pumpWidget(MaterialApp(home: WelcomeCarousel(onFinish: () {})));
      await tester.pump(const Duration(milliseconds: 100));
      final image = find.byType(Image);
      expect((tester.widget<Image>(image).image as AssetImage).assetName,
          'assets/branding/luma_symbol_halo.png');
      final wordmark = find.byKey(const ValueKey('welcome-luma-wordmark'));
      expect(find.text('Luma'), findsOneWidget);
      expect(tester.getRect(wordmark).top,
          greaterThan(tester.getRect(image).bottom));
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.text('Luma Anesthesia'), findsOneWidget);
      expect(find.text('Luma'), findsNothing);
      await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.text('Luma'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
