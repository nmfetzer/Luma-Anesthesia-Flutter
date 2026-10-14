// Optional design captures, not release acceptance or clinical approval.
// flutter test --dart-define=LUMA_CAPTURE_REVIEW=true --update-goldens \
//   test/academy_preview_capture_test.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/academy/academy_review_screen.dart';

void main() {
  testWidgets('capture Academy review home and answer', (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final family in ['Inter', 'Fraunces']) {
      final loader = FontLoader(family)
        ..addFont(rootBundle.load('assets/fonts/offline/$family-Regular.ttf'));
      await loader.load();
    }
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF153247)),
        ),
        home: const RepaintBoundary(
          key: ValueKey('academy-capture'),
          child: AcademyReviewScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('academy-capture')),
      matchesGoldenFile(
        '../review/academy/previews/luma-academy-study-home.png',
      ),
    );
    await tester.tap(find.text('Start practice'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('academy-answer-1')));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(390, 1280);
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('academy-capture')),
      matchesGoldenFile(
        '../review/academy/previews/luma-academy-practice-round.png',
      ),
    );
    expect(tester.takeException(), isNull);
  }, skip: !const bool.fromEnvironment('LUMA_CAPTURE_REVIEW'));
}
