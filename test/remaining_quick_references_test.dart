import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_chart.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_repository.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_screen.dart';

import 'quick_references_test.dart' show FakeReferences;

final remainingSource = File('supabase/seeds/remaining_quick_references.md')
    .readAsStringSync();

class RemainingReferences extends FakeReferences {
  @override
  Future<QuickReferenceContent?> content(String id) async {
    final row = rows.singleWhere((row) => row.id == id);
    final guide = remainingSource
        .split(' :: ${row.referenceId}\n')
        .last
        .split('\n# ')
        .first;
    return QuickReferenceContent(
      body: guide.split('## ${row.title}\n').last.split('\n## ').first.trim(),
      version: '2026-09-27',
    );
  }
}

void main() {
  final catalog =
      (jsonDecode(
            File('supabase/seeds/remaining_catalog.json').readAsStringSync(),
          ) as List)
          .map(
            (row) =>
                QuickReferenceSection.fromJson(row as Map<String, dynamic>),
          )
          .toList();

  test(
    '19 complete guides, chart-only, unique IDs and sourced clinical rows',
    () {
      expect(catalog.map((row) => row.referenceId).toSet(), hasLength(19));
      expect(catalog.map((row) => row.id).toSet(), hasLength(catalog.length));
      for (final guide
          in remainingSource.split(RegExp(r'^# ', multiLine: true)).skip(1)) {
        for (final section
            in guide.split(RegExp(r'^## ', multiLine: true)).skip(1)) {
          final lines = section
              .substring(section.indexOf('\n'))
              .trim()
              .split('\n')
              .where((line) => line.trim().isNotEmpty)
              .toList();
          expect(lines.length, greaterThanOrEqualTo(4));
          for (final line in lines) {
            expect(line.startsWith('|') && line.endsWith('|'), isTrue);
            expect(line.split('|'), hasLength(4));
          }
          for (final line in lines.skip(2)) {
            if (!line.contains('**Scope**')) expect(line, contains('https://'));
          }
        }
      }
    },
  );

  for (final entry in <String, String>{
    'propofol induction': 'induction-medications',
    'increase preload': 'hemodynamic-support',
    'Precedex drip': 'drip-quick-reference',
    'normal wedge': 'normal-hemodynamics',
    'AFib cardioversion': 'svt-afib-cardioversion',
    'WPW amiodarone': 'wpw-syndrome',
    'WPW orthodromic adenosine': 'wpw-syndrome',
    'antidromic procainamide': 'wpw-syndrome',
    'WPW delta wave': 'wpw-syndrome',
    'mitral stenosis': 'valve-disorders',
    'Ancef redose': 'antibiotic-redosing',
    'Eliquis reversal': 'anticoagulants-reversal',
    'MTP calcium': 'massive-transfusion',
    'Dilaudid dose': 'opioid-dosing',
    'lidocaine max dose': 'local-anesthetic-maxima',
    'lipid rescue': 'local-anesthetic-maxima',
    'PONV rescue': 'ponv',
    'sux contraindications': 'neuromuscular-blockade',
    'Bridion TOF': 'neuromuscular-blockade',
    'bronchospasm albuterol': 'bronchospasm',
    'anaphylaxis epinephrine': 'anaphylaxis',
    'preop glucose insulin': 'preop-glucose',
    'GLP1 diabetes': 'preop-glucose',
    'ACLS epinephrine': 'acls-medications',
    'PALS epinephrine': 'pals-medications',
  }.entries) {
    test('flexible search: ${entry.key}', () {
      expect(
        catalog
            .where((row) => row.matches(entry.key))
            .map((row) => row.referenceId),
        contains(entry.value),
      );
    });
  }

  test('current clinical guardrails preserved', () {
    for (final phrase in [
      'December 22, 2025',
      'First-dose maximum 300 mg; subsequent-dose maximum 150 mg',
      '0.01 mg/kg IV/IO every 3–5 min; max 1 mg/dose',
      'not neonatal resuscitation',
      'not a blanket hold',
      'TOF ratio ≥0.9 before extubation',
      'maximum total 12 mL/kg',
      'not the older 50–100 J',
      'anti-Xa reversal is incomplete',
      'patient-specific correction-insulin protocol',
    ]) {
      expect(remainingSource, contains(phrase));
    }
  });

  test(
    'WPW separates rhythms and retains stable live ID and safety guards',
    () {
      final wpw = remainingSource
          .split('# WPW Syndrome :: wpw-syndrome')
          .last
          .split('\n# ')
          .first;
      final rows = catalog
          .where((row) => row.referenceId == 'wpw-syndrome')
          .toList();
      expect(rows, hasLength(2));
      expect(rows.first.id, 'wpw-syndrome-pre-excitation-treatment');
      expect(rows.first.title, 'Rhythm-Based Assessment & Treatment');
      for (final phrase in [
        'WPW pattern: sinus rhythm',
        'Orthodromic AVRT: stable',
        'Antidromic AVRT: stable',
        'Pre-excited AF: stable',
        '6 mg rapid IV',
        'treat as VT',
        'PEA/asystole: nonshockable',
        'even when a pulse is present',
        'Stop the infusion when the arrhythmia terminates',
        'at least 4 h after infusion AND until QTc returns to baseline',
        'concurrently with ibutilide or within 4 h after ibutilide',
      ]) {
        expect(wpw, contains(phrase));
      }
      expect(wpw, isNot(contains('If pulseless or polymorphic VT/VF')));
    },
  );

  for (final id in [
    'pals-medications',
    'normal-hemodynamics',
    'induction-medications',
    'wpw-syndrome',
  ]) {
    testWidgets('$id renders compact chart with correct scope on mobile', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final row = catalog.firstWhere((row) => row.referenceId == id);
      final repo = RemainingReferences()
        ..rows.clear()
        ..rows.add(row);
      await tester.pumpWidget(
        MaterialApp(
          home: QuickReferencesScreen(
            repository: repo,
            initialQuery: row.referenceTitle,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(row.title));
      await tester.pumpAndSettle();
      expect(find.byType(QuickReferenceChart), findsOneWidget);
      if (id == 'pals-medications') {
        expect(
          find.textContaining('Pediatric resuscitation reference'),
          findsOneWidget,
        );
        expect(find.textContaining('Adult clinical reference'), findsNothing);
      } else {
        expect(
          find.textContaining('Adult clinical reference. Verify'),
          findsOneWidget,
        );
      }
      expect(find.text('Sign in'), findsNothing);
      expect(find.text('Access options'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
