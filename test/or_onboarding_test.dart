import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/home/home_screen.dart';
import 'package:luma_anesthesia/home/home_tile.dart';
import 'package:luma_anesthesia/references/or_onboarding_screen.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget app(Widget child, {double scale = 1}) => MaterialApp(
    builder: (context, widget) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(disableAnimations: true, textScaler: TextScaler.linear(scale)),
      child: widget!,
    ),
    home: child,
    routes: {
      '/home': (_) => const Scaffold(body: Text('Tile dashboard')),
      OrOnboardingScreen.route: (_) =>
          const Scaffold(body: Text('Onboarding reader')),
    },
  );

  testWidgets('bundled PDF is readable without a network or account', (
    tester,
  ) async {
    final data = await rootBundle.load(OrOnboardingScreen.asset);
    expect(data.lengthInBytes, 3697552);
    expect(
      String.fromCharCodes(data.buffer.asUint8List(data.offsetInBytes, 5)),
      '%PDF-',
    );
    await tester.pumpWidget(
      app(
        OrOnboardingScreen(
          viewerBuilder: (bytes) => Text('Bundled bytes: ${bytes.length}'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bundled bytes: 3697552'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Tile dashboard'), findsOneWidget);
  });

  testWidgets('PDF error can retry and refresh without a purchase', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      app(
        OrOnboardingScreen(
          loadBytes: () async {
            if (++calls == 1) throw StateError('asset unavailable');
            return Uint8List.fromList('%PDF-test'.codeUnits);
          },
          viewerBuilder: (_) => const Text('Document ready'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Document ready'), findsOneWidget);
    await tester.tap(find.byTooltip('Reload PDF'));
    await tester.pumpAndSettle();
    expect(calls, 3);
  });

  for (final size in [const Size(320, 568), const Size(820, 1180)]) {
    testWidgets('reader navigation fits $size with large text', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        app(
          OrOnboardingScreen(
            loadBytes: () async => Uint8List(0),
            viewerBuilder: (_) => const Center(child: Text('PDF')),
          ),
          scale: 2,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Home').hitTestable(), findsOneWidget);
      expect(find.byTooltip('Reload PDF').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('home contains a bottom onboarding tile with a working route', (
    tester,
  ) async {
    await tester.pumpWidget(app(const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 50));
    final tile = find.byWidgetPredicate(
      (w) => w is HomeTile && w.data.route == OrOnboardingScreen.route,
    );
    expect(tile, findsOneWidget);
    final tiles = tester.widgetList<HomeTile>(find.byType(HomeTile)).toList();
    expect(tiles.last.data.route, OrOnboardingScreen.route);
    await tester.ensureVisible(tile);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(find.text('Onboarding reader'), findsOneWidget);
  });
}
