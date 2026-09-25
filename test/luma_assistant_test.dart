import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/screens/luma_assistant_screen.dart';
import 'package:luma_anesthesia/ai/luma_ai_catalog.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  testWidgets('Luma preview does not imply paid AI is connected',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LumaAssistantScreen()));
    await tester.pump();
    expect(find.text('Meet Luma'), findsOneWidget);
    expect(find.text('Before using Luma AI'), findsOneWidget);
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.ensureVisible(find.text('Continue to AI preview'));
    await tester.tap(find.text('Continue to AI preview'));
    await tester.pump();
    expect(find.textContaining('not connected yet'), findsOneWidget);
    expect(find.text('150 credits'), findsOneWidget);
    expect(find.text('US\$4.99 · One-time purchase'), findsOneWidget);
    expect(find.textContaining('included monthly allowance'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(
                find.byKey(const Key('luma-credit-purchase-disabled')))
            .onPressed,
        isNull);
    expect(find.textContaining('Do not share patient-identifying'),
        findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Chat coming soon'))
            .onPressed,
        isNull);
    expect(tester.takeException(), isNull);
  });

  test('approved iOS catalog stays disconnected and does not invent grants',
      () {
    expect(LumaAiCatalog.iosProductId, 'luma_ai_credits_150');
    expect(LumaAiCatalog.creditsPerPack, 150);
    expect(LumaAiCatalog.purchasesEnabled, isFalse);
    expect(LumaAiCatalog.liveAiEnabled, isFalse);
    expect(LumaAiCatalog.includedMonthlyCredits, isNull);
    expect(LumaAiCatalog.androidProductId, isNull);
  });
}
