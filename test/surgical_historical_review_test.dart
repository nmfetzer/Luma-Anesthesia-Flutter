import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/launch/launch_scope.dart';
import 'package:luma_anesthesia/surgical_prep/surgical_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const dir = 'docs/surgical-historical-review-2026-10-07';
  final records = (jsonDecode(
    File('assets/data/surgical_cases.json').readAsStringSync(),
  ) as List).cast<Map<String, dynamic>>();
  final ledger = jsonDecode(
    File('$dir/correction-ledger.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final reconciliation = jsonDecode(
    File('$dir/historical-reconciliation.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final baseline = jsonDecode(
    File('$dir/historical-audit-baseline.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  Map<String, dynamic> record(String id) =>
      records.firstWhere((r) => r['id'] == id);
  Map<String, dynamic> section(String id, String sid) =>
      (record(id)['sections'] as List).cast<Map<String, dynamic>>().firstWhere(
        (s) => s['id'] == sid,
      );
  String body(String id, String sid) =>
      (section(id, sid)['bullets'] as List).join(' ');

  setUpAll(() async => SurgicalCatalog.load());

  test(
    'ten exact postimages preserve identities, draft and deferred routes',
    () {
      expect(records.length, 350);
      expect((ledger['records'] as List).length, 10);
      for (final dynamic row in ledger['records']) {
        final r = record(row['id'] as String);
        expect(r, row['after']);
        expect(r['id'], row['before']['id']);
        expect(r['category'], row['before']['category']);
        expect(r['clinicalStatus'], 'draft');
        expect(LaunchScope.isDeferred('/surgical-prep/${r['id']}'), true);
      }
    },
  );
  test(
    'changed records have unique section identities and HTTPS references',
    () {
      for (final dynamic row in ledger['records']) {
        final sections = (record(row['id'] as String)['sections'] as List)
            .cast<Map<String, dynamic>>();
        expect(sections.map((s) => s['id']).toSet().length, sections.length);
        for (final s in sections) {
          expect(s['bullets'], isNotEmpty);
          expect(s['sources'], isNotEmpty);
          for (final dynamic source in s['sources']) {
            expect(Uri.parse(source['url'] as String).scheme, 'https');
          }
        }
      }
    },
  );
  test('bariatric recovery threshold is conditional and PONV is not a fixed regimen', () {
    for (final r in records.where((r) => r['category'] == 'Bariatric')) {
      final id = r['id'] as String;
      expect(body(id, 'emergence'), contains('at least 0.9'));
      expect(body(id, 'emergence'), contains('adductor pollicis'));
      expect(body(id, 'emergence'), contains('does not mandate blockade'));
      expect(
        body(id, 'ponv-plan'),
        contains('not proof of one uniquely effective'),
      );
      expect(body(id, 'ponv-plan'), contains('surgical complication'));
    }
  });
  test('RYGB NSAID risk is not negated by PPI prophylaxis', () {
    final text = body('roux-en-y-gastric-bypass-rygb', 'analgesia');
    expect(text, contains('marginal-ulcer risk'));
    expect(text, contains('at least three months'));
    expect(text, contains('not proof that NSAID exposure is risk-free'));
  });
  test(
    'burn hemoglobin threshold has population and active-bleeding exceptions',
    () {
      for (final id in [
        'burn-wound-debridement-excision',
        'burn-excision-and-split-thickness-skin-grafting',
      ]) {
        final text = body(id, 'blood-guideline');
        expect(text, contains('at least 20% TBSA'));
        expect(text, contains('pretransfusion hemoglobin below 7 g/dL'));
        expect(text, contains('do not apply to significant bleeding'));
        expect(text, contains('acute brain injury'));
        expect(text, contains('acute coronary syndrome'));
        expect(text, contains('not an instruction to withhold'));
      }
    },
  );
  test('burn TXA, cell salvage and timing retain evidence limits', () {
    const id = 'burn-excision-and-split-thickness-skin-grafting';
    expect(
      body(id, 'blood-conservation-evidence'),
      contains('weak conditional'),
    );
    expect(
      body(id, 'blood-conservation-evidence'),
      contains('limited burn-graft'),
    );
    expect(
      body(id, 'blood-conservation-evidence'),
      contains('could not establish burn-specific reinfusion safety'),
    );
    expect(body(id, 'timing-evidence'), contains('not explicitly adult-only'));
    expect(body(id, 'timing-evidence'), contains('not proof of equivalence'));
  });
  test('escharotomy local analgesia and reassessment are explicit', () {
    final text = body('burn-escharotomy', 'procedure');
    expect(text, contains('Local anesthetic is needed for unburnt skin'));
    expect(text, contains('GA is not invariably required'));
    expect(
      text,
      contains('Reassess distal perfusion or respiratory mechanics'),
    );
  });
  test(
    'ostomy review qualifies testing and escalates below-fascia necrosis',
    () {
      const id = 'ostomy-creation-reversal-ileostomy-colostomy';
      expect(body(id, 'closure'), contains('very low certainty'));
      expect(body(id, 'closure'), contains('Do not apply'));
      expect(body(id, 'stoma'), contains('below the fascia'));
      expect(body(id, 'stoma'), contains('blind instrumentation'));
    },
  );
  test('hemorrhoid preparation and antithrombotics preserve procedure distinctions', () {
    final text = body('hemorrhoidectomy', 'preparation-antithrombotics');
    expect(text, contains('isolated hemorrhoidectomy'));
    expect(text, contains('cleansing enema may be considered'));
    expect(text, contains('rubber-band ligation'));
    expect(text, contains('neuraxial'));
  });
  test('all 128 historical items preserve exact text, current evidence and nonapproval', () {
    final rows = (reconciliation['rows'] as List).cast<Map<String, dynamic>>();
    expect(rows.length, 128);
    expect(rows.map((r) => r['key']).toSet().length, 128);
    expect(reconciliation['clinicalApproval'], false);
    expect(reconciliation['releaseAuthorized'], false);
    expect(
      rows.where((r) => r['status'] == 'partially-covered-open').length,
      8,
    );
    for (final row in rows) {
      final report = (baseline['reports'] as List).firstWhere(
        (dynamic r) => r['id'] == row['historicalId'],
      );
      final index = row['index'] as int;
      final original = switch (row['kind']) {
        'reviewNote' => report['reviewNotes'][index],
        'evidenceGap' => report['evidenceGaps'][index],
        _ =>
          (baseline['issues'] as List)
              .where((dynamic r) => r['id'] == row['historicalId'])
              .toList()[index]['text'],
      };
      expect(row['originalText'], original);
      for (final dynamic e in row['evidence']) {
        final current = section(
          e['caseId'] as String,
          e['sectionId'] as String,
        );
        expect(e['bullets'], current['bullets']);
        expect(e['sources'], current['sources']);
      }
    }
  });
}
