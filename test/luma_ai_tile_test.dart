import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/home/home_screen.dart';
import 'package:luma_anesthesia/home/luma_ai_tile.dart';

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(375, 812),
    const Size(768, 1024),
    const Size(1280, 800),
  ]) {
    testWidgets(
      'coming-soon panel stays visible without enabling AI at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(LumaAiTile), findsNothing);
        await tester.ensureVisible(find.text('Coming soon'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Coming soon'), findsOneWidget);
        expect(find.byType(LumaAiTile), findsNothing);
        await tester.tap(find.text('Coming soon'));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('• Luma AI'), findsOneWidget);
        expect(find.text('• Diagnostics'), findsOneWidget);
        expect(
          find.text(
            'You’ll be notified in the app when new features and updates are available.',
          ),
          findsOneWidget,
        );
        expect(
          find.text(
            'Private preview only. This panel is omitted from the store build.',
          ),
          findsNothing,
        );
        expect(find.text('• EKG'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
