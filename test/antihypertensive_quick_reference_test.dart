import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_chart.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_repository.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_screen.dart';

import 'quick_references_test.dart' show FakeReferences;

class ChartReferences extends FakeReferences {
  @override
  Future<QuickReferenceContent?> content(String id) async {
    requestedId = id;
    if (!allowed) return null;
    final title = rows.singleWhere((row) => row.id == id).title;
    final source = File('supabase/seeds/antihypertensive_quick_reference.md')
        .readAsStringSync();
    final body = source.split('## $title\n').last.split('\n## ').first.trim();
    return QuickReferenceContent(body: body, version: '2026-09-27');
  }
}

void main() {
  testWidgets('chart fallback handles unexpected non-table content safely', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: QuickReferenceChart(body: 'Content unavailable.')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Content unavailable.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  final catalog =
      (jsonDecode(
            File('supabase/seeds/antihypertensive_catalog.json')
                .readAsStringSync(),
          ) as List)
          .map(
            (row) =>
                QuickReferenceSection.fromJson(row as Map<String, dynamic>),
          )
          .toList();
  List<String> results(String query) =>
      catalog.where((row) => row.matches(query)).map((row) => row.id).toList();
  test('three chart-only sections with unique stable IDs', () {
    expect(catalog.length, 3);
    expect(catalog.map((row) => row.id).toSet().length, 3);
    final source = File('supabase/seeds/antihypertensive_quick_reference.md')
        .readAsStringSync();
    for (final chunk
        in source.split(RegExp(r'^## ', multiLine: true)).skip(1)) {
      final body = chunk.substring(chunk.indexOf('\n') + 1).trim();
      expect(
        body
            .split('\n')
            .every((line) => line.trim().isEmpty || line.startsWith('|')),
        isTrue,
      );
      expect(body, contains('https://'));
    }
  });
  for (final query in [
    'nicardipine',
    'Cardene drip',
    'clevidipine egg allergy',
    'Cleviprex dose',
    'nitroglycerin infusion',
    'SNP renal',
    'nitroprusside maximum',
  ]) {
    test('infusion search: $query', () {
      expect(results(query), contains('antihypertensive-infusion'));
    });
  }
  for (final query in [
    'hydralazine dose',
    'labetalol bolus',
    'metoprolol BP',
    'esmolol push',
  ]) {
    test('bolus search: $query', () {
      expect(results(query), contains('antihypertensive-bolus'));
    });
  }
  test('no accidental medication substitution', () {
    expect(results('phenylephrine'), isEmpty);
    expect(results('nicardipinex'), isEmpty);
    // Keyword co-occurrence can retrieve a safety chart, not prescribe a bolus.
    expect(results('nicardipine bolus'), ['antihypertensive-safety']);
  });
  for (final width in [375.0, 1280.0]) {
    for (final id in ['antihypertensive-bolus', 'antihypertensive-infusion']) {
      testWidgets('$id reader fits width $width and uses drug safety banner', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = ChartReferences()..rows.addAll(catalog);
        await tester.pumpWidget(
          MaterialApp(
            home: QuickReferenceReader(
              section: catalog.singleWhere((row) => row.id == id),
              repository: repo,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Adult monitored IV reference'),
          findsOneWidget,
        );
        expect(find.textContaining('Confirm the exact device'), findsNothing);
        expect(find.textContaining('GLP-1 guidance'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ListView), const Offset(0, -700));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('brand search opens infusion chart directly', (tester) async {
    final repo = ChartReferences()..rows.addAll(catalog);
    await tester.pumpWidget(
      MaterialApp(home: QuickReferencesScreen(repository: repo)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Cardene drip');
    await tester.pumpAndSettle();
    await tester.tap(find.text('IV infusion chart'));
    await tester.pumpAndSettle();
    expect(repo.requestedId, 'antihypertensive-infusion');
    expect(find.textContaining('Adult monitored IV reference'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
