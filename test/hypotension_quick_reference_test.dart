import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_chart.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_repository.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_screen.dart';

import 'quick_references_test.dart' show FakeReferences;

class HypotensionReferences extends FakeReferences {
  @override
  Future<QuickReferenceContent?> content(String id) async {
    requestedId = id;
    if (!allowed) return null;
    final title = rows.singleWhere((row) => row.id == id).title;
    final source = File('supabase/seeds/hypotension_quick_reference.md')
        .readAsStringSync();
    final body = source.split('## $title\n').last.split('\n## ').first.trim();
    return QuickReferenceContent(body: body, version: '2026-09-27');
  }
}

void main() {
  final catalog =
      (jsonDecode(
            File('supabase/seeds/hypotension_catalog.json').readAsStringSync(),
          ) as List)
          .map(
            (row) =>
                QuickReferenceSection.fromJson(row as Map<String, dynamic>),
          )
          .toList();
  List<String> results(String query) =>
      catalog.where((row) => row.matches(query)).map((row) => row.id).toList();

  test('three unique chart-only sections, source-linked clinical rows', () {
    expect(catalog.map((row) => row.id).toSet().length, 3);
    final source = File('supabase/seeds/hypotension_quick_reference.md')
        .readAsStringSync();
    for (final chunk
        in source.split(RegExp(r'^## ', multiLine: true)).skip(1)) {
      final body = chunk.substring(chunk.indexOf('\n') + 1).trim();
      for (final line in body.split('\n').where((line) => line.isNotEmpty)) {
        expect(line.startsWith('|') && line.endsWith('|'), isTrue);
        if (line.contains('**') && !line.contains('**Scope**')) {
          expect(line, contains('https://'));
        }
      }
    }
    expect(source, contains('Not a cardiac-arrest or anaphylaxis'));
    expect(source, contains('off-label'));
    expect(source, contains('units/min'));
  });
  for (final query in [
    'ephedrine dose',
    'Neo push',
    'norepi bolus',
    'adrenaline push dose',
    'vasopressin bolus',
    'Akovaz',
  ]) {
    test('bolus search: $query', () {
      expect(results(query), ['hypotension-bolus']);
    });
  }
  for (final query in [
    'Levophed drip',
    'phenylephrine infusion',
    'vasopressin units infusion',
    'dopamine dose drip',
    'epi ideal body weight',
  ]) {
    test('infusion search: $query', () {
      expect(results(query), ['hypotension-infusion']);
    });
  }
  test('safety search and no invented dose matches', () {
    expect(results('norepinephrine extravasation'), ['hypotension-safety']);
    expect(results('phentolamine'), ['hypotension-safety']);
    expect(results('ephedrine infusion'), isEmpty);
    expect(results('dopamine bolus'), isEmpty);
    expect(results('phenylephrinex'), isEmpty);
    expect(results('nicardipine'), isEmpty);
  });
  for (final width in [375.0, 1280.0]) {
    for (final section in catalog) {
      testWidgets('${section.id} uses chart renderer at $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = HypotensionReferences()..rows.addAll(catalog);
        await tester.pumpWidget(
          MaterialApp(
            home: QuickReferenceReader(section: section, repository: repo),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(QuickReferenceChart), findsOneWidget);
        expect(
          find.textContaining('Adult monitored IV reference'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ListView), const Offset(0, -900));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('search opens matching hypotension chart', (tester) async {
    final repo = HypotensionReferences()..rows.addAll(catalog);
    await tester.pumpWidget(
      MaterialApp(home: QuickReferencesScreen(repository: repo)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Levophed drip');
    await tester.pumpAndSettle();
    await tester.tap(find.text('IV infusion chart'));
    await tester.pumpAndSettle();
    expect(repo.requestedId, 'hypotension-infusion');
    expect(find.byType(QuickReferenceChart), findsOneWidget);
  });
}
