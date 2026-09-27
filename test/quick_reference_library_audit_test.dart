import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_repository.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_screen.dart';

import 'quick_references_test.dart' show FakeReferences;

final auditRows = (jsonDecode(
  File('supabase/seeds/all_quick_references.json').readAsStringSync(),
) as List).cast<Map<String, dynamic>>();

class AuditReferences extends FakeReferences {
  @override
  Future<QuickReferenceContent?> content(String id) async {
    final row = auditRows.singleWhere((row) => row['id'] == id);
    return QuickReferenceContent(
      body: row['body'] as String,
      version: row['version'] as String,
    );
  }
}

void main() {
  test('all 24 guides / 59 sourced, published sections are searchable', () {
    expect(auditRows, hasLength(59));
    expect(auditRows.map((r) => r['reference_id']).toSet(), hasLength(24));
    expect(auditRows.map((r) => r['id']).toSet(), hasLength(59));
    for (final row in auditRows) {
      final section = QuickReferenceSection.fromJson(row);
      expect(row['is_published'], isTrue);
      expect(row['body'], contains('https://'));
      expect(section.matches(section.title), isTrue, reason: section.id);
      expect(
        section.matches(section.referenceTitle),
        isTrue,
        reason: section.id,
      );
    }
  });

  for (final query in <String, String>{
    'bipolar and AICD': 'cied-electrocautery',
    'AICD electrocuatery': 'cied-electrocautery',
    'GLP1 aspiration': 'preop-glp1',
    'metformin clearance': 'preop-other-readiness',
    'glucose metformin': 'preop-glucose-hyperglycemia-medication-readiness',
    'labetalol orthostatic': 'beta-blocker-infusion',
    'hypotension extravasation': 'hypotension-safety',
    'WPW orthodromic adenosine': 'wpw-syndrome-medication-dosing-safety',
    'diltiazem repeat': 'svt-afib-cardioversion-svt-af-with-rvr',
    'droperidol QTc': 'ponv-prevention-rescue',
    'local anesthetics additive':
        'local-anesthetic-maxima-adult-single-dose-limits',
    'LAST observation': 'local-anesthetic-maxima-last-rescue',
    'enoxaparin protamine': 'anticoagulants-reversal-emergency-reversal-chart',
    'bronchospasm ketamine': 'bronchospasm-intraoperative-treatment',
    'bronchospasm magnesium': 'bronchospasm-intraoperative-treatment',
    'wheezing MgSO4': 'bronchospasm-intraoperative-treatment',
  }.entries) {
    test('library search ${query.key}', () {
      final row = auditRows.singleWhere((r) => r['id'] == query.value);
      expect(QuickReferenceSection.fromJson(row).matches(query.key), isTrue);
    });
  }

  test('bronchospasm adjunct rows retain approved doses and evidence limits', () {
    final row = auditRows.singleWhere(
      (r) => r['id'] == 'bronchospasm-intraoperative-treatment',
    );
    final body = row['body'] as String;
    expect(row['version'], '2026-09-27-r2');
    for (final phrase in [
      '**Ketamine: rescue adjunct**',
      '**10–50 mg IV**',
      '**Magnesium sulfate: refractory bronchospasm**',
      '**2 g IV over 20 minutes**',
      '**not routine first-line therapy**',
      '**potentiate neuromuscular blockade**',
      'quantitative neuromuscular monitoring',
      'PMC9482594',
      'PMC11702345',
      'Bronchospasm_during_anaesthesia_Update_2011.pdf',
    ]) {
      expect(body, contains(phrase));
    }
    expect('10–50 mg'.allMatches(body).length, 1);
  });

  test('audit corrections persist in generated server content', () {
    final bodies = auditRows.map((r) => r['body']).join('\n');
    for (final phrase in [
      'guidelines differ',
      'after **15 min**',
      'PEA/asystole are nonshockable',
      'Toxicity is additive',
      '4–6 h after cardiovascular instability',
      'US boxed warning',
      '≥12 h',
      'not one apheresis pack per RBC unit',
      '0.5–1 mcg/kg/min',
    ]) {
      expect(bodies, contains(phrase));
    }
    expect(bodies, isNot(contains('Not for WPW/pre-excited AF')));
    expect(bodies, isNot(contains('Do not use for pre-excited AF/WPW')));
  });

  for (final scale in [1.0, 1.5]) {
    for (final row in auditRows) {
      testWidgets('${row['id']} at 375px / ${scale}x text, free access', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = AuditReferences();
        addTearDown(repository.changes.close);
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: QuickReferenceReader(
              section: QuickReferenceSection.fromJson(row),
              repository: repository,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Sign in'), findsNothing);
        expect(find.text('Access options'), findsNothing);
        expect(find.textContaining('Content version'), findsOneWidget);
        expect(tester.takeException(), isNull);
        final scroll = tester.state<ScrollableState>(
          find.byType(Scrollable).first,
        );
        for (final fraction in [0.5, 1.0]) {
          scroll.position.jumpTo(scroll.position.maxScrollExtent * fraction);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  }
}
