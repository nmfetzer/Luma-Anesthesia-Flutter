import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/screens/luma_assistant_screen.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  testWidgets('Luma preview does not imply paid AI is connected', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LumaAssistantScreen()));
    await tester.pump();
    expect(find.text('Meet Luma'), findsOneWidget);
    expect(find.textContaining('not connected yet'), findsOneWidget);
    expect(find.textContaining('Amounts and prices'), findsOneWidget);
    expect(find.textContaining('Do not share patient-identifying'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Chat coming soon')).onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
