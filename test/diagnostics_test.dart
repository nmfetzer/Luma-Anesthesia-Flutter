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
    expect(searchDiagnosticCategories('ultrasound').map((e) => e.id),
        containsAll(['pocus', 'carotid']));
    expect(searchDiagnosticCategories('blood gas').single.id, 'abg');
    expect(searchDiagnosticCategories('nonsense'), isEmpty);
  });

  test('lab draft has unique IDs, source links, units and working aliases', () {
    expect(labReferences.length, 19);
    expect(labReferences.map((e) => e.id).toSet().length, 19);
    for (final entry in labReferences) {
      expect(entry.interval, isNotEmpty);
      expect(entry.bullets, isNotEmpty);
      for (final url in [entry.intervalUrl, entry.explanationUrl]) {
        expect(Uri.parse(url).scheme, 'https');
        expect(Uri.parse(url).host, 'medlineplus.gov');
        expect(Uri.parse(url).path.length, greaterThan(1));
      }
    }
    expect(searchLabReferences('Hgb').single.id, 'hemoglobin');
    expect(searchLabReferences('K+').single.id, 'potassium');
    expect(searchLabReferences('', group: 'Blood Counts').length, 5);
  });

  testWidgets('normal app cannot view draft lab values', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LabValuesScreen()));
    expect(find.textContaining('not available in the released app'),
        findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('135–145 mEq/L'), findsNothing);
  });

  testWidgets('hub search opens labs without exposing EKG', (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: DiagnosticsScreen(showClinicalDraft: true)));
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
    await tester.pumpWidget(
        const MaterialApp(home: LabValuesScreen(showClinicalDraft: true)));
    await tester.enterText(find.byType(TextField), 'potassium');
    await tester.pump();
    await tester.ensureVisible(find.text('Potassium (K)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Potassium (K)'));
    await tester.pumpAndSettle();
    expect(find.text('MedlinePlus · Reference interval'), findsOneWidget);
    expect(find.text('Example interval, not a treatment threshold.'),
        findsOneWidget);
    await tester.ensureVisible(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'nothingmatches');
    await tester.pump();
    expect(find.textContaining('No matching lab values.'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(find.text('19 matching reference cards'), findsOneWidget);
    await tester.ensureVisible(find.text('Blood Counts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blood Counts'));
    await tester.pump();
    expect(find.text('5 matching reference cards'), findsOneWidget);
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
