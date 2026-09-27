import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/diagnostics/diagnostics_content.dart';
import 'package:luma_anesthesia/diagnostics/diagnostics_screen.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  test('hub includes seven Base44 categories without EKG', () {
    expect(diagnosticCategories.length, 7);
    expect(diagnosticCategories.map((e) => e.id).toSet().length, 7);
    expect(searchDiagnosticCategories('EKG'), isEmpty);
    expect(searchDiagnosticCategories('ECG'), isEmpty);
    expect(
      searchDiagnosticCategories('ultrasound').map((e) => e.id),
      containsAll(['pocus', 'carotid']),
    );
    expect(searchDiagnosticCategories('blood gas').single.id, 'abg');
    expect(searchDiagnosticCategories('nonsense'), isEmpty);
  });

  test('lab draft has unique IDs, source links, units and working aliases', () {
    expect(labReferences.length, 35);
    expect(labReferences.map((e) => e.id).toSet().length, 35);
    for (final entry in labReferences) {
      expect(entry.interval, isNotEmpty);
      expect(entry.bullets, isNotEmpty);
      expect(entry.clinicalSections, isNotEmpty);
      for (final section in entry.clinicalSections) {
        expect(section.title, isNotEmpty);
        expect(section.sourceLabel, isNotEmpty);
        expect(section.bullets, isNotEmpty);
      }
      for (final url in [
        entry.intervalUrl,
        entry.explanationUrl,
        ...entry.clinicalSections.map((s) => s.url),
      ]) {
        expect(Uri.parse(url).scheme, 'https');
        expect(Uri.parse(url).host, isNotEmpty);
        expect(Uri.parse(url).path.length, greaterThan(1));
      }
    }
    expect(searchLabReferences('Hgb').single.id, 'hemoglobin');
    expect(searchLabReferences('K+').single.id, 'potassium');
    expect(searchLabReferences('', group: 'Blood Counts').length, 5);
    expect(searchLabReferences('', group: 'Coagulation').length, 7);
    expect(
      searchLabReferences('neuraxial').map((e) => e.id),
      containsAll(['pt-inr', 'platelets']),
    );
    expect(
      searchLabReferences('hypoglycemia', urgentOnly: true).single.id,
      'glucose',
    );
    expect(
      searchLabReferences('', urgentOnly: true),
      everyElement(
        isA<LabReference>()
            .having((e) => e.hasUrgentContext, 'has urgent context', isTrue),
      ),
    );
    expect(labReferences.where((e) => !e.hasExampleInterval).length, 5);
    expect(
      labClinicalGuidance.keys.toSet(),
      labReferences.map((e) => e.id).toSet(),
    );
  });

  test('expanded labs support clinical aliases and both requested groups', () {
    for (final pair in {
      'activated clotting time': 'act',
      'CPK': 'ck',
      'CKMB': 'ck-mb',
      'lactic acid': 'lactate',
      'BNP': 'bnp',
      'NTproBNP': 'nt-probnp',
    }.entries) {
      expect(
        searchLabReferences(pair.key).map((e) => e.id),
        contains(pair.value),
      );
    }
    expect(
      searchDiagnosticCategories('ACT').map((e) => e.id),
      contains('labs'),
    );
    expect(
      searchLabReferences('', group: 'Perfusion & Cardiac Markers')
          .map((e) => e.id),
      containsAll(['lactate', 'troponin', 'ck', 'ck-mb', 'bnp', 'nt-probnp']),
    );
    for (final id in [
      'pt-inr',
      'aptt',
      'fibrinogen',
      'anti-xa',
      'viscoelastic',
      'd-dimer',
      'act',
      'lactate',
      'troponin',
      'ck',
      'ck-mb',
      'bnp',
      'nt-probnp',
    ]) {
      final card = labReferences.singleWhere((e) => e.id == id);
      expect(card.clinicalSections.length, greaterThanOrEqualTo(2), reason: id);
      expect(
        card.clinicalSections.expand((s) => s.bullets).length,
        greaterThanOrEqualTo(7),
        reason: id,
      );
    }
  });

  test('ACT separates baseline, CPB targets, device exceptions and reversal',
      () {
    final card = labReferences.singleWhere((e) => e.id == 'act');
    expect(card.interval, contains('74–137'));
    expect(card.interval, contains('82–152'));
    expect(card.interval, isNot(contains('480')));
    final text = card.clinicalSections.expand((s) => s.bullets).join(' ');
    for (final value in [
      'above 480 seconds',
      'above 400 seconds',
      'device-specific exception',
      'residual heparin',
      'Excess protamine',
      'antithrombin',
      'fresh sample',
      '250–300 seconds',
      '300–350 seconds',
      '200–250 seconds',
      '≥300',
      'class IIb, level C',
      'not establish one universal numeric ACT goal',
    ]) {
      expect(text, contains(value));
    }
  });

  test('natriuretic peptides separate HF diagnosis from perioperative risk',
      () {
    for (final id in ['bnp', 'nt-probnp']) {
      final card = labReferences.singleWhere((e) => e.id == id);
      expect(card.hasExampleInterval, isFalse);
      expect(card.interval, contains('not a universal normal range'));
      final text = card.clinicalSections.expand((s) => s.bullets).join(' ');
      expect(text, contains('elevated-risk noncardiac surgery'));
      expect(text, contains('renal'));
      expect(text.toLowerCase(), contains('obesity'));
      expect(text, contains('fluid responsiveness'));
      expect(text, contains(id == 'bnp' ? 'BNP >92' : 'NT-proBNP ≥300'));
      expect(text, contains(id == 'bnp' ? '<35 pg/mL' : '<125 pg/mL'));
      expect(text, contains(id == 'bnp' ? '<100 pg/mL' : '<300 pg/mL'));
    }
    expect(searchDiagnosticCategories('NTproBNP').single.id, 'labs');
    expect(
      searchLabReferences('', group: 'Perfusion & Cardiac Markers').length,
      6,
    );
  });

  test('cardiac and perfusion values retain assay, units and interpretation',
      () {
    final troponin = labReferences.singleWhere((e) => e.id == 'troponin');
    expect(troponin.hasExampleInterval, isFalse);
    expect(troponin.interval, contains('ng/L'));
    final troponinText =
        troponin.clinicalSections.expand((s) => s.bullets).join(' ');
    expect(troponinText, contains('not universal diagnostic cutoffs'));
    expect(troponinText, contains('99th-percentile'));
    expect(troponinText, contains('evidence of ischemia'));
    expect(
      labReferences.singleWhere((e) => e.id == 'lactate').interval,
      contains('0.5–2.0 mmol/L'),
    );
    expect(
      labReferences.singleWhere((e) => e.id == 'ck').interval,
      contains('39–308 U/L'),
    );
    expect(
      labReferences.singleWhere((e) => e.id == 'ck-mb').interval,
      contains('0.0–3.5 ng/mL'),
    );
  });

  testWidgets('ACT expands at mobile width with sources and no overflow',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: LabValuesScreen(showClinicalDraft: true)),
    );
    await tester.enterText(find.byType(TextField), 'activated clotting time');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('ACT / Activated Clotting Time'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('ACT / Activated Clotting Time'));
    await tester.pumpAndSettle();
    expect(
      find.text('Abbott · Device-specific baseline ranges'),
      findsOneWidget,
    );
    await tester.ensureVisible(
      find.text('Cardiopulmonary bypass: target and device exception'),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('normal app cannot view draft lab values', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LabValuesScreen()));
    expect(
      find.textContaining('not available in the released app'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);
    expect(find.text('135–145 mEq/L'), findsNothing);
  });

  testWidgets('hub search opens labs without exposing EKG', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DiagnosticsScreen(showClinicalDraft: true)),
    );
    await tester.enterText(find.byType(TextField), 'lab');
    await tester.pump();
    await tester.tap(find.text('Lab Values'));
    await tester.pumpAndSettle();
    expect(find.byType(LabValuesScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ECG');
    await tester.pump();
    expect(find.text('EKG / ECG'), findsNothing);
    expect(find.textContaining('No matching sections.'), findsOneWidget);
  });

  testWidgets('lab search expands bullets, filters and clears', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: LabValuesScreen(showClinicalDraft: true)),
    );
    await tester.enterText(find.byType(TextField), 'potassium');
    await tester.pump();
    await tester.ensureVisible(find.text('Potassium (K)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Potassium (K)'));
    await tester.pumpAndSettle();
    expect(find.text('MedlinePlus · Reference interval'), findsOneWidget);
    expect(
      find.text('Example interval, not a treatment threshold.'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'nothingmatches');
    await tester.pump();
    expect(find.textContaining('No matching lab values.'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(find.text('35 matching reference cards'), findsOneWidget);
    await tester.ensureVisible(find.text('Blood Counts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blood Counts'));
    await tester.pump();
    expect(find.text('5 matching reference cards'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('coagulation and urgent filters combine and can be reset',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(home: LabValuesScreen(showClinicalDraft: true)),
    );
    await tester.ensureVisible(find.text('Coagulation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coagulation'));
    await tester.pumpAndSettle();
    expect(find.text('7 matching reference cards'), findsOneWidget);
    await tester.ensureVisible(find.text('Urgent findings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Urgent findings'));
    await tester.pumpAndSettle();
    expect(find.text('1 matching reference card'), findsOneWidget);
    await tester.ensureVisible(find.text('Fibrinogen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fibrinogen'));
    await tester.pumpAndSettle();
    expect(
      find.text('Major bleeding: trauma-specific threshold'),
      findsOneWidget,
    );
    expect(find.textContaining('not a universal obstetric'), findsOneWidget);
    await tester.ensureVisible(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'troponin');
    await tester.pumpAndSettle();
    expect(find.textContaining('No matching lab values.'), findsOneWidget);
    await tester.ensureVisible(find.text('All'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('1 matching reference card'), findsOneWidget);
    await tester.ensureVisible(find.text('Cardiac Troponin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cardiac Troponin'));
    await tester.pumpAndSettle();
    expect(
      find.text('Assay context, not a universal numeric cutoff.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('unmigrated section states its status and returns',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DiagnosticsScreen()));
    await tester.enterText(find.byType(TextField), 'POCUS');
    await tester.pump();
    await tester.tap(find.text('POCUS').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('not complete yet'), findsOneWidget);
    await tester.tap(find.text('Back to Diagnostics'));
    await tester.pumpAndSettle();
    expect(find.byType(DiagnosticsScreen), findsOneWidget);
  });
}
