import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/welcome/welcome_slides.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  const patho = 'Pathophysiology & Anesthesia Considerations';
  for (final width in [320.0, 375.0, 430.0, 820.0, 1280.0]) {
    for (final scale in [1.0, 1.6]) {
      testWidgets('welcome cards keep whole words at $width scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 1000),
                textScaler: TextScaler.linear(scale),
              ),
              child: const Scaffold(
                body: SingleChildScrollView(child: WelcomeSlideThree()),
              ),
            ),
          ),
        );
        final pathoCard = find.byKey(const ValueKey('welcome-feature-$patho'));
        expect(
          tester.getSize(pathoCard).width,
          closeTo((width > 720 ? 720 : width) - 56, 0.1),
        );
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text(patho),
        );
        for (final word in ['Pathophysiology', 'Considerations']) {
          final start = patho.indexOf(word);
          expect(
            paragraph
                .getBoxesForSelection(
                  TextSelection(
                    baseOffset: start,
                    extentOffset: start + word.length,
                  ),
                )
                .length,
            1,
            reason: '$word must not split mid-word',
          );
        }
        if (width >= 375 && scale == 1) {
          final first = tester.getSize(
            find.byKey(const ValueKey('welcome-feature-Crisis Hub')),
          );
          final second = tester.getSize(
            find.byKey(const ValueKey('welcome-feature-Drug Library')),
          );
          expect(
            first,
            second,
            reason: 'Paired cards align in width and height',
          );
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
