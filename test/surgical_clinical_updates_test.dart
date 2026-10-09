import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/launch/launch_scope.dart';
import 'package:luma_anesthesia/surgical_prep/surgical_catalog.dart';

import 'support/surgical_correction_history.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<Map<String, dynamic>> records;
  late Map<String, dynamic> ledger;
  Map<String, dynamic> record(String id) =>
      records.firstWhere((r) => r['id'] == id);
  Map<String, dynamic> section(String id, String sid) =>
      (record(id)['sections'] as List).cast<Map<String, dynamic>>().firstWhere(
        (s) => s['id'] == sid,
      );
  String body(String id, String sid) =>
      (section(id, sid)['bullets'] as List).join(' ');
  setUpAll(() async {
    records = (jsonDecode(
      await File('assets/data/surgical_cases.json').readAsString(),
    ) as List).cast<Map<String, dynamic>>();
    ledger = jsonDecode(
      await File('docs/surgical-review-2026-10-07/correction-ledger.json')
          .readAsString(),
    ) as Map<String, dynamic>;
    await SurgicalCatalog.load();
  });
  test('nineteen exact corrections preserve inventory, identities, draft and release gates', () {
    expect(records.length, 350);
    expect(records.map((r) => r['id']).toSet().length, 350);
    expect((ledger['records'] as List).length, 19);
    for (final dynamic row in ledger['records']) {
      final r = record(row['id'] as String);
      expect(
        r,
        equals(
          latestSurgicalPostimage(
            Map<String, dynamic>.from(row['after'] as Map),
          ),
        ),
      );
      expect(r['id'], row['before']['id']);
      expect(r['category'], row['before']['category']);
      expect(r['clinicalStatus'], 'draft');
      expect(LaunchScope.isDeferred('/surgical-prep/${r['id']}'), true);
    }
    expect(records.where((r) => r['category'] == 'Obstetric').length, 9);
  });
  test('updated sections have unique identities and HTTPS sources', () {
    for (final dynamic row in ledger['records']) {
      final r = record(row['id'] as String);
      final sections = (r['sections'] as List).cast<Map<String, dynamic>>();
      expect(sections.map((s) => s['id']).toSet().length, sections.length);
      for (final s in [r['overview'] as Map<String, dynamic>, ...sections]) {
        expect(s['bullets'], isNotEmpty);
        expect(s['sources'], isNotEmpty);
        for (final dynamic source in s['sources']) {
          expect(Uri.parse(source['url'] as String).scheme, 'https');
          expect(source['label'], isNotEmpty);
        }
      }
    }
  });
  test(
    'blood patch has qualified platelets, red flags and no mandatory imaging',
    () {
      const id = 'epidural-blood-patch';
      expect(body(id, 'hemostasis'), contains('70 × 10⁹/L (70,000/µL)'));
      expect(
        body(id, 'hemostasis'),
        contains('not an automatic EBP clearance'),
      );
      expect(body(id, 'preop'), contains('visual changes'));
      expect(body(id, 'procedure'), contains('not established as mandatory'));
      expect(body(id, 'intraop'), contains('not a mandatory volume'));
      expect(body(id, 'emergence'), contains('until headache resolves'));
      expect(jsonEncode(record(id)), isNot(contains('PMC3265991')));
    },
  );
  test('labor epidural distinguishes LMWH regimens and links LAST rescue', () {
    const id = 'labor-epidural-placement';
    expect(body(id, 'antithrombotics'), contains('twice-daily'));
    expect(body(id, 'antithrombotics'), contains('once-daily'));
    expect(body(id, 'antithrombotics'), contains('renal'));
    expect(body(id, 'last-rescue'), contains('20% lipid'));
    expect(body(id, 'last-rescue'), contains('12 mL/kg'));
    expect(body(id, 'last-rescue'), contains('differs from standard ACLS'));
  });
  test('cesarean timing and morphine monitoring are scoped not absolute', () {
    const id = 'urgent-emergent-c-section-category-1-2';
    expect(
      body(id, 'urgency'),
      contains('in most situations within 30 minutes'),
    );
    expect(body(id, 'urgency'), contains('not permission to wait'));
    expect(body(id, 'opioid-monitoring'), contains('healthy low-risk'));
    expect(
      body(id, 'opioid-monitoring'),
      contains('every two hours for 12 hours'),
    );
    expect(body(id, 'opioid-monitoring'), contains('not prescribing'));
  });
  test('PPH TXA timing is from birth and bundle scope is not overstated', () {
    const id = 'postpartum-hemorrhage-management';
    expect(body(id, 'intraop'), contains('measured from birth'));
    expect(body(id, 'intraop'), contains('1 g IV over 10 minutes'));
    expect(
      body(id, 'intraop'),
      contains('formal bundle recommendation is for vaginal birth'),
    );
    expect(body(id, 'fluids'), contains('Do not impose one fixed'));
    expect(body(id, 'fluids'), contains('at least 2 g/L'));
  });
  test('cardiac PAH and HM3 guidance stays lesion and device specific', () {
    expect(
      body(
        'high-risk-obstetric-anesthesia-cardiac-disease-in-pregnancy',
        'lesion-specific',
      ),
      contains('not an ICU rule for all cardiac'),
    );
    expect(
      body('lvad-placement-left-ventricular-assist-device', 'anticoagulation'),
      contains('not permission to stop VKA'),
    );
    expect(
      body('ecmo-cannulation-decannulation', 'anticoagulation'),
      contains('not a universal VA-ECMO target'),
    );
  });
  test('HELLP interval not generalized and ERAS full-text reconciliation is recorded', () {
    expect(
      body('preeclampsia-severe-preeclampsia-anesthesia-management', 'preop'),
      contains('do not apply a six-hour rule indiscriminately'),
    );
    expect(
      body('gynecology-anesthesia-framework', 'eras-verification'),
      contains('prior full-text access hold is closed'),
    );
  });
  test('new clinical concepts are searchable', () {
    expect(
      searchSurgicalCases('ARIES').map((c) => c.id),
      contains('lvad-placement-left-ventricular-assist-device'),
    );
    expect(
      searchSurgicalCases('antithrombotics').map((c) => c.id),
      contains('labor-epidural-placement'),
    );
  });
  test('orthopedic additions preserve procedural and evidence boundaries', () {
    expect(
      body('shoulder-arthroscopy', 'brain-level-pressure'),
      contains('arm pressure overestimates'),
    );
    expect(
      body('shoulder-arthroscopy', 'brain-level-pressure'),
      contains('not establish a single validated'),
    );
    expect(
      body('rotator-cuff-repair-arthroscopic', 'irrigation-airway'),
      contains('before extubation'),
    );
    expect(
      body('total-hip-arthroplasty-tha', 'cement-safety'),
      contains('direct focus is cemented hemiarthroplasty'),
    );
    expect(
      body('long-bone-orif-tibia-femur-humerus', 'compartment-surveillance'),
      contains('severe pain is not always present'),
    );
    expect(
      body('long-bone-orif-tibia-femur-humerus', 'compartment-surveillance'),
      contains('not universally prohibited'),
    );
    expect(
      body('total-knee-arthroplasty-tka', 'antithrombotic-coordination'),
      contains('catheter removal'),
    );
  });
  test(
    'PAS timing discrepancy and cardiac uterotonic caveats remain explicit',
    () {
      expect(
        body(
          'placenta-accreta-spectrum-pas-cesarean-hysterectomy',
          'timing-source-hold',
        ),
        contains('internally inconsistent'),
      );
      expect(
        body(
          'placenta-accreta-spectrum-pas-cesarean-hysterectomy',
          'procedure',
        ),
        contains('not a universal rule'),
      );
      expect(
        body(
          'high-risk-obstetric-anesthesia-cardiac-disease-in-pregnancy',
          'uterotonic-cautions',
        ),
        contains('pulmonary hypertension'),
      );
      expect(
        body(
          'high-risk-obstetric-anesthesia-cardiac-disease-in-pregnancy',
          'uterotonic-cautions',
        ),
        contains('Methylergonovine'),
      );
    },
  );
}
