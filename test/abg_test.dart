import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/diagnostics/abg_content.dart';
import 'package:luma_anesthesia/diagnostics/abg_screen.dart';
import 'package:luma_anesthesia/diagnostics/diagnostics_screen.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  test('14 distinct sourced references and four compensation patterns', () {
    expect(abgTopics.length, 14);
    expect(abgTopics.map((e) => e.id).toSet().length, 14);
    expect(compensationReference.length, 4);
    for (final section in [
      ...compensationReference,
      for (final topic in abgTopics) ...topic.sections,
    ]) {
      expect(section.title, isNotEmpty);
      expect(section.bullets, isNotEmpty);
      expect(section.sourceLabel, isNotEmpty);
      expect(Uri.parse(section.url).scheme, 'https');
      expect(Uri.parse(section.url).host, isNotEmpty);
    }
    expect(compensationReference[0].bullets.first, contains('1.5 × HCO₃⁻'));
    expect(compensationReference[0].bullets.first, contains('8 ± 2'));
    expect(compensationReference[2].bullets[0], contains('1–2'));
    expect(compensationReference[2].bullets[1], contains('3–4'));
    expect(compensationReference[3].bullets[1], contains('4–5'));
  });

  test('search supports aliases, clinical text, unicode and group filters', () {
    expect(searchAbgTopics('EtCO2').map((e) => e.id), contains('capnography'));
    expect(
      searchAbgTopics('anion-gap').map((e) => e.id),
      contains('anion-gap'),
    );
    expect(
      searchAbgTopics('Winter', group: 'Primary disorders').single.id,
      'metabolic-acidosis',
    );
    expect(searchAbgTopics('', group: 'Primary disorders').length, 4);
    expect(searchAbgTopics('nonsense'), isEmpty);
    expect(
      searchAbgTopics('HCO3').map((e) => e.id),
      containsAll(['orientation', 'metabolic-acidosis']),
    );
  });

  testWidgets('default released screen does not expose the draft',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AbgReferenceScreen()));
    expect(
      find.textContaining('not available in the released app'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Compensation quick reference'), findsNothing);
  });

  testWidgets('hub opens ABG preview and quick reference expands',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: DiagnosticsScreen(showClinicalDraft: true)),
    );
    await tester.enterText(find.byType(TextField), 'ABG');
    await tester.pump();
    await tester.tap(find.text('ABG & Acid–Base'));
    await tester.pumpAndSettle();
    expect(find.byType(AbgReferenceScreen), findsOneWidget);
    expect(find.text('14 of 14 reference cards'), findsOneWidget);
    await tester.tap(find.text('Compensation quick reference'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Expected PaCO₂ ='), findsOneWidget);
    expect(find.text('Merck Manual · Compensation table'), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('search, expansion, empty state and reset work', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: AbgReferenceScreen(showClinicalDraft: true)),
    );
    await tester.tap(find.text('Primary disorders'));
    await tester.pump();
    expect(find.text('4 of 14 reference cards'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Winter');
    await tester.pump();
    expect(find.text('1 of 14 reference cards'), findsOneWidget);
    await tester.tap(find.text('Metabolic acidosis'));
    await tester.pumpAndSettle();
    expect(find.text('Anesthesia caution'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'unknown term');
    await tester.pumpAndSettle();
    expect(find.textContaining('No matching ABG references.'), findsOneWidget);
    await tester.tap(find.text('Reset search and filters'));
    await tester.pump();
    expect(find.text('14 of 14 reference cards'), findsOneWidget);
    expect(
      find.byType(TextField),
      findsOneWidget,
    ); // No patient-input calculator.
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile layout renders without overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: AbgReferenceScreen(showClinicalDraft: true)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
