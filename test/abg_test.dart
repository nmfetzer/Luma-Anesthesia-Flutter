import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/diagnostics/abg_content.dart';
import 'package:luma_anesthesia/diagnostics/abg_screen.dart';
import 'package:luma_anesthesia/diagnostics/diagnostics_screen.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  test('clinician references replace basic teaching and synthetic cases', () {
    expect(abgTopics.length, 12);
    expect(abgTopics.map((e) => e.id).toSet().length, 12);
    expect(abgGroups, isNot(contains('Teaching cases')));
    expect(abgTopics.map((e) => e.id), isNot(contains('examples')));
    expect(abgTopics.map((e) => e.id), isNot(contains('orientation')));
    expect(abgTopics.where((e) => e.differential.isNotEmpty).length, 3);
    for (final topic in abgTopics) {
      expect(topic.sections.length, greaterThanOrEqualTo(2));
      for (final row in topic.differential) {
        expect(row.process, isNotEmpty);
        expect(row.clues, isNotEmpty);
        expect(row.focus, isNotEmpty);
        expect(row.sourceLabel, isNotEmpty);
        expect(Uri.parse(row.url).scheme, 'https');
      }
    }
    for (final section in [
      ...compensationReference,
      gapReference,
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

  test('search matches clinical problems, aliases and differential context',
      () {
    expect(searchAbgTopics('EtCO2').map((e) => e.id), contains('hypercapnia'));
    expect(
      searchAbgTopics('SGLT2').map((e) => e.id),
      contains('euglycemic-dka'),
    );
    expect(
      searchAbgTopics('anion-gap').map((e) => e.id),
      contains('unexplained-acidosis'),
    );
    expect(searchAbgTopics('SODa').single.id, 'bicarbonate');
    expect(searchAbgTopics('', group: 'Metabolic').length, 5);
    expect(searchAbgTopics('', group: 'Ventilation').length, 3);
    expect(searchAbgTopics('nonsense'), isEmpty);
  });

  test('DKA and buffer content retains scoped thresholds and evidence', () {
    final dka = abgTopics.singleWhere((t) => t.id == 'euglycemic-dka');
    final text = dka.sections.expand((s) => s.bullets).join(' ');
    expect(text, contains('potassium is <3.5'));
    expect(text, contains('potassium is >3.5'));
    expect(text, contains('pH <7.0'));
    expect(text, contains('ketones <0.6'));
    final buffer = abgTopics.singleWhere((t) => t.id == 'bicarbonate');
    expect(
      buffer.sections.map((s) => s.url),
      containsAll([
        'https://pubmed.ncbi.nlm.nih.gov/41159812/',
        'https://pubmed.ncbi.nlm.nih.gov/42283370/',
      ]),
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
    expect(find.text('Formulas & compensation'), findsNothing);
  });

  testWidgets('hub opens clinician preview and compact formula panel',
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
    expect(find.text('Perioperative acid–base problems'), findsOneWidget);
    expect(find.text('12 of 12 reference cards'), findsNothing);
    await tester.tap(find.text('Formulas & compensation'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Expected PaCO₂ ='), findsOneWidget);
    expect(find.text('Merck Manual · Compensation table'), findsOneWidget);
    await tester.tap(find.text('Formulas & compensation'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('search, filters, differential table and reset work',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: AbgReferenceScreen(showClinicalDraft: true)),
    );
    await tester.tap(find.text('Metabolic'));
    await tester.pump();
    expect(find.text('5 of 12 reference cards'), findsNothing);
    await tester.enterText(find.byType(TextField), 'unexplained');
    await tester.pump();
    await tester
        .tap(find.text('Unexplained intraoperative metabolic acidosis'));
    await tester.pumpAndSettle();
    expect(find.text('Differential at a glance'), findsOneWidget);
    expect(find.byType(Table), findsOneWidget);
    expect(find.text('Lactate-associated'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'unknown term');
    await tester.pumpAndSettle();
    expect(find.textContaining('No matching ABG references.'), findsOneWidget);
    await tester.tap(find.text('Reset search and filters'));
    await tester.pumpAndSettle();
    expect(find.text('12 of 12 reference cards'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile differential becomes labeled blocks without overflow',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: AbgReferenceScreen(showClinicalDraft: true)),
    );
    await tester.enterText(find.byType(TextField), 'unexplained');
    await tester.pumpAndSettle();
    await tester
        .tap(find.text('Unexplained intraoperative metabolic acidosis'));
    await tester.pumpAndSettle();
    expect(find.text('Differential at a glance'), findsOneWidget);
    expect(find.byType(Table), findsNothing);
    expect(find.text('Distinguishing context'), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });
}
