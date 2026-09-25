import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/screens/luma_assistant_screen.dart';
import 'package:luma_anesthesia/widgets/luma_ai_safety_notice.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets(
      'AI preview requires explicit safety acknowledgement and permits declining',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const Scaffold(
          body: SingleChildScrollView(
              child: LumaAiSafetyNotice(onAcknowledged: _noop))),
      routes: {'/home': (_) => const Scaffold(body: Text('Home tiles'))},
    ));
    final continueButton =
        find.widgetWithText(FilledButton, 'Continue to AI preview');
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);
    expect(find.textContaining('AI can make mistakes'), findsOneWidget);
    expect(find.textContaining('This acknowledgement is not'), findsOneWidget);
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNotNull);
    await tester.ensureVisible(find.text('Not now, return home'));
    await tester.tap(find.text('Not now, return home'));
    await tester.pumpAndSettle();
    expect(find.text('Home tiles'), findsOneWidget);
  });

  testWidgets('acknowledgement opens preview, never live chat', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LumaAssistantScreen()));
    await tester.pump();
    expect(find.text('Before using Luma AI'), findsOneWidget);
    expect(find.text('Chat coming soon'), findsNothing);
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.ensureVisible(find.text('Continue to AI preview'));
    await tester.tap(find.text('Continue to AI preview'));
    await tester.pump();
    final chat = find.widgetWithText(FilledButton, 'Chat coming soon');
    expect(tester.widget<FilledButton>(chat).onPressed, isNull);
    await tester.ensureVisible(find.text('Review AI safety notice'));
    await tester.tap(find.text('Review AI safety notice'));
    await tester.pump();
    expect(find.text('Before using Luma AI'), findsOneWidget);
  });
}

void _noop() {}
