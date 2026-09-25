import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/ai/luma_ai_catalog.dart';
import 'package:luma_anesthesia/home/home_screen.dart';
import 'package:luma_anesthesia/home/luma_ai_tile.dart';
import 'package:luma_anesthesia/screens/luma_assistant_screen.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final size in [
    const Size(375, 812),
    const Size(768, 1024),
    const Size(1280, 800),
  ]) {
    testWidgets('mascot tile opens safety notice and returns home at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        home: const HomeScreen(),
        routes: {
          '/home': (_) => const HomeScreen(),
          '/luma-ai': (_) => const LumaAssistantScreen(),
        },
      ));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(LumaAiTile), findsOneWidget);
      final image = tester.widget<Image>(find.descendant(
          of: find.byType(LumaAiTile), matching: find.byType(Image)));
      expect((image.image as AssetImage).assetName, LumaAiCatalog.mascotAsset);
      await tester.ensureVisible(find.byType(LumaAiTile));
      await tester.tap(find.byType(LumaAiTile));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Before using Luma AI'), findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(LumaAssistantScreen),
              matching: find.byType(TextField)),
          findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Home'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(LumaAiTile), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
