import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/home/education_labels.dart';
import 'package:luma_anesthesia/home/home_menu_drawer.dart';
import 'package:luma_anesthesia/home/home_screen.dart';
import 'package:luma_anesthesia/home/home_tile.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'CE tile has credit label and unchanged route at scale $scale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
                disableAnimations: true,
              ),
              child: child!,
            ),
            home: const HomeScreen(),
            routes: {
              '/ce-halo': (_) =>
                  const Scaffold(body: Text('CE courses opened')),
            },
          ),
        );
        await tester.pumpAndSettle();
        final tile = find.byWidgetPredicate(
          (w) => w is HomeTile && w.data.route == '/ce-halo',
        );
        expect(
          tester.widget<HomeTile>(tile).data.titlePlain,
          ceHaloNavigationLabel,
        );
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        expect(find.text(ceHaloNavigationLabel).hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text(ceHaloNavigationLabel));
        await tester.pumpAndSettle();
        expect(find.text('CE courses opened'), findsOneWidget);
      },
    );
  }

  testWidgets('drawer CE link uses the same label and destination', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(drawer: HomeMenuDrawer(), body: SizedBox.shrink()),
        routes: {
          '/ce-halo': (_) => const Scaffold(body: Text('CE courses opened')),
        },
      ),
    );
    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(ceHaloNavigationLabel),
      250,
      scrollable: find.descendant(
        of: find.byType(HomeMenuDrawer),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.text(ceHaloNavigationLabel));
    await tester.pumpAndSettle();
    expect(find.text('CE courses opened'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
