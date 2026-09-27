import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_repository.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_screen.dart';

import 'quick_references_test.dart' show FakeReferences, glp;

void main() {
  final catalog =
      (jsonDecode(File('supabase/seeds/cied_catalog.json').readAsStringSync())
              as List)
          .map(
            (row) =>
                QuickReferenceSection.fromJson(row as Map<String, dynamic>),
          )
          .toList();
  List<String> results(String query) =>
      catalog.where((s) => s.matches(query)).map((s) => s.id).toList();

  test('approved guide has 11 uniquely identified searchable sections', () {
    expect(catalog.length, 11);
    expect(catalog.map((s) => s.id).toSet().length, 11);
  });
  for (final query in [
    'bipolar and AICD',
    'AICD and bipolar',
    'bipolar pacemaker',
    'BIPOLAR & AICD?',
    'Bovie ICD',
    'cautery with defibrillator',
    'monopolar pacemaker',
    'grounding pad AICD',
    'bipolar electrocuatery with an AICD',
    'bipolar electrocautary and pacers',
    'Can I use bipolar electrosurgery with an implantable defibrillator?',
    'cautery with CRT-D',
  ]) {
    test('direct cautery result: $query', () {
      expect(results(query), ['cied-electrocautery']);
    });
  }
  test(
    'specific model and troubleshooting terms find the matching section',
    () {
      expect(results('Micra and magnet'), contains('cied-exceptions'));
      expect(results('magnet not working'), ['cied-exceptions']);
      expect(results('Biotronik 8 hours'), ['cied-exceptions']);
      expect(results('AICD reactivation'), contains('cied-postop'));
    },
  );
  test('no broad typo guessing, unrelated results, or ignored negation', () {
    expect(results('bipolar and semaglutide'), isEmpty);
    expect(results('bipolar not AICD'), isEmpty);
    expect(results('and the with'), isEmpty);
    expect(results('unknownrandomterm'), isEmpty);
    expect(glp.matches('semaglutidex'), isFalse);
    expect(glp.matches('GLP1 and aspiration'), isTrue);
    expect(glp.matches('GLP 1'), isTrue);
    expect(glp.matches('pre op'), isTrue);
  });
  testWidgets('natural phrase opens cautery directly and retains query', (
    tester,
  ) async {
    final repo = FakeReferences()..rows.addAll(catalog);
    await tester.pumpWidget(
      MaterialApp(home: QuickReferencesScreen(repository: repo)),
    );
    await tester.pumpAndSettle();
    expect(find.text('AICDs & Pacemakers'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'bipolar and AICD');
    await tester.pumpAndSettle();
    expect(find.text('1 matching section'), findsOneWidget);
    await tester.tap(find.text('Electrocautery and EMI precautions'));
    await tester.pumpAndSettle();
    expect(repo.requestedId, 'cied-electrocautery');
    expect(
      find.textContaining('not a patient-specific device prescription'),
      findsOneWidget,
    );
    expect(
      find.textContaining('GLP-1 guidance is separately sourced'),
      findsNothing,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('bipolar and AICD'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
