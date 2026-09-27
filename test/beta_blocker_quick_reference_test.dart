import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_chart.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_repository.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_screen.dart';

import 'quick_references_test.dart' show FakeReferences;

class BetaBlockerReferences extends FakeReferences {
  @override
  Future<QuickReferenceContent?> content(String id) async {
    requestedId = id;
    if (!allowed) return null;
    final title = rows.singleWhere((row) => row.id == id).title;
    final source = File('supabase/seeds/beta_blocker_quick_reference.md')
        .readAsStringSync();
    return QuickReferenceContent(
      body: source.split('## $title\n').last.split('\n## ').first.trim(),
      version: '2026-09-27',
    );
  }
}

void main() {
  final catalog =
      (jsonDecode(
            File('supabase/seeds/beta_blocker_catalog.json').readAsStringSync(),
          ) as List)
          .map(
            (row) =>
                QuickReferenceSection.fromJson(row as Map<String, dynamic>),
          )
          .toList();
  List<String> results(String query) =>
      catalog.where((row) => row.matches(query)).map((row) => row.id).toList();

  test('three chart-only sections with sources and clinical boundaries', () {
    expect(catalog.map((row) => row.id).toSet().length, 3);
    final source = File('supabase/seeds/beta_blocker_quick_reference.md')
        .readAsStringSync();
    for (final chunk
        in source.split(RegExp(r'^## ', multiLine: true)).skip(1)) {
      for (final line
          in chunk
              .substring(chunk.indexOf('\n') + 1)
              .trim()
              .split('\n')
              .where((line) => line.isNotEmpty)) {
        expect(line.startsWith('|') && line.endsWith('|'), isTrue);
        if (line.contains('**') && !line.contains('**Scope**')) {
          expect(line, contains('https://'));
        }
      }
    }
    for (final boundary in [
      'off-label in the US',
      'pre-excited AF',
      'maximum 15 mg',
      '3 doses (3 mg)',
      'Maximum 36 mcg/kg/min',
      'no bolus in the US label',
      'optimally >7 days',
      'no immediate need',
    ]) {
      expect(source, contains(boundary));
    }
  });
  for (final query in [
    'Lopressor bolus',
    'metoprolol AF dose push',
    'Inderal bolus',
    'labetalol push',
    'Brevibloc bolus',
  ]) {
    test(
      'bolus search $query',
      () => expect(results(query), contains('beta-blocker-bolus')),
    );
  }
  for (final query in [
    'Brevibloc drip',
    'Rapiblyk infusion',
    'landiolol impaired cardiac function',
    'Trandate infusion',
  ]) {
    test(
      'infusion search $query',
      () => expect(results(query), contains('beta-blocker-infusion')),
    );
  }
  for (final query in [
    'beta blocker WPW',
    'metoprolol asthma',
    'beta blockers day of surgery',
    'propranolol hypoglycemia',
    'beta blocker cardioversion',
  ]) {
    test(
      'safety search $query',
      () => expect(results(query), contains('beta-blocker-safety')),
    );
  }
  test('no typo substitutions; content search is not a regimen generator', () {
    for (final query in ['metoprololx', 'nicardipine beta blocker']) {
      expect(results(query), isEmpty);
    }
    // These terms legitimately occur together in safety/context statements.
    expect(results('metoprolol infusion'), contains('beta-blocker-safety'));
    expect(results('landiolol bolus'), contains('beta-blocker-infusion'));
    expect(results('beta-blocker').length, 3);
  });
  for (final width in [375.0, 1280.0]) {
    for (final section in catalog) {
      testWidgets('${section.id} chart fits $width', (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = BetaBlockerReferences()..rows.addAll(catalog);
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
  testWidgets('search open back clear and second search', (tester) async {
    final repo = BetaBlockerReferences()..rows.addAll(catalog);
    await tester.pumpWidget(
      MaterialApp(home: QuickReferencesScreen(repository: repo)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Rapiblyk infusion');
    await tester.pumpAndSettle();
    await tester.tap(find.text('IV infusion chart'));
    await tester.pumpAndSettle();
    expect(repo.requestedId, 'beta-blocker-infusion');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'beta blocker WPW');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Safety & perioperative use'));
    await tester.pumpAndSettle();
    expect(repo.requestedId, 'beta-blocker-safety');
  });
}
