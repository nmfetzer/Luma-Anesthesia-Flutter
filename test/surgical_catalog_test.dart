import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/surgical_prep/surgical_catalog.dart';
import 'package:luma_anesthesia/surgical_prep/surgical_library_screen.dart';
import 'package:luma_anesthesia/surgical_prep/ep_groups.dart';
import 'package:luma_anesthesia/surgical_prep/abdominal_gi_groups.dart';
import 'package:luma_anesthesia/surgical_prep/gynecology_groups.dart';
import 'package:luma_anesthesia/surgical_prep/hpb_groups.dart';
import 'package:luma_anesthesia/surgical_prep/neuro_groups.dart';
import 'package:luma_anesthesia/screens/subscription_screen.dart';
import 'package:luma_anesthesia/theme/luma_theme.dart';
import 'package:luma_anesthesia/launch/launch_scope.dart';

Widget app({
  String? id,
  bool allowed = true,
  double scale = 1,
  Future<bool> Function()? checker,
}) => MaterialApp(
  theme: buildLumaTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(disableAnimations: true, textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: SurgicalPrepFeature(
    caseId: id,
    checkAccess: checker ?? () async => allowed,
    accessChanges: const Stream<void>.empty(),
  ),
  onGenerateRoute: (settings) {
    if (settings.name == '/home') {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(body: Text('Dashboard')),
      );
    }
    final uri = Uri.parse(settings.name!);
    return MaterialPageRoute(
      builder: (_) => SurgicalPrepFeature(
        caseId: uri.pathSegments.length > 1
            ? uri.pathSegments.skip(1).join('/')
            : null,
        checkAccess: () async => allowed,
        accessChanges: const Stream<void>.empty(),
      ),
    );
  },
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Prime real asset I/O outside any individual widget test's fake-async zone.
  setUpAll(() async {
    await SurgicalCatalog.load();
  });
  test('351 unique adult/OB references are bundled and all remain release-deferred', () async {
    final raw = jsonDecode(
      await rootBundle.loadString('assets/data/surgical_cases.json'),
    ) as List;
    final cases = await SurgicalCatalog.load();
    expect(raw.length, 350);
    expect(cases.length, 351);
    expect(surgicalIndex.length, cases.length);
    expect(surgicalIndex.map((r) => r.id).toSet().length, 351);
    expect(surgicalCategories.length, 23); // 22 categories and All.
    for (final item in surgicalIndex) {
      expect(cases.containsKey(item.id), true, reason: item.title);
      expect(LaunchScope.isDeferred(item.route), true);
      expect(item.title.toLowerCase(), isNot(contains('pediatric')));
      expect(item.aliases.toLowerCase(), isNot(contains('pediatric')));
      final c = cases[item.id]!;
      expect(
        c.overview.bullets.length,
        inInclusiveRange(3, 5),
        reason: c.title,
      );
      expect(c.sections.length, greaterThanOrEqualTo(10));
      for (final section in [c.overview, ...c.sections]) {
        expect(section.bullets, isNotEmpty);
        expect(section.sources, isNotEmpty);
        for (final source in section.sources) {
          final uri = Uri.parse(source.url);
          expect(uri.scheme, 'https');
          expect(uri.host, isNotEmpty);
        }
      }
    }
    expect(identical(cases, await SurgicalCatalog.load()), true);
  });

  test('case search matches titles, prefixes, aliases and clinical text', () {
    expect(
      searchSurgicalCases('LAP CHOLE').first.id,
      'laparoscopic-cholecystectomy',
    );
    expect(searchSurgicalCases('cesar'), isNotEmpty);
    expect(searchSurgicalCases('zzzzunknownterm'), isEmpty);
    expect(searchSurgicalCases('pneumoperitoneum'), isNotEmpty);
    expect(searchSurgicalCases('', category: 'Obstetric'), isNotEmpty);
    expect(
      searchSurgicalCases(
        '',
        category: 'Obstetric',
      ).every((c) => c.category == 'Obstetric'),
      true,
    );
  });

  test('neuro groups retain canonical routes including endocrine overlap', () {
    final listed = surgicalNeuroGroups.values.expand((ids) => ids).toList();
    final found = searchSurgicalCases('', category: 'Neuro & spine');
    expect(listed, hasLength(31));
    expect(listed.toSet().length, listed.length);
    expect(found.map((c) => c.id).toSet(), listed.toSet());
    expect(
      listed,
      containsAll([
        'transsphenoidal-pituitary-surgery-tsps-endoscopic',
        'craniopharyngioma-resection-adult',
      ]),
    );
    expect(
      searchSurgicalCases(
        '2026 stroke guideline',
        category: 'Neuro & spine',
      ).any((c) => c.id == 'mechanical-thrombectomy-for-ischemic-stroke'),
      isTrue,
    );
    expect(
      searchSurgicalCases(
        'intramedullary',
        category: 'Neuro & spine',
      ).any((c) => c.id == 'spinal-cord-tumor-resection'),
      isTrue,
    );
  });

  test(
    'neuro disease-specific pressure, rescue and device qualifiers persist',
    () async {
      final cases = await SurgicalCatalog.load();
      String d(String id) =>
          cases[id]!.sections.expand((s) => s.bullets).join(' ');
      expect(
        d('mechanical-thrombectomy-for-ischemic-stroke'),
        contains('first 72 hours is harmful'),
      );
      expect(
        d('mechanical-thrombectomy-for-ischemic-stroke'),
        contains('without another BP indication'),
      );
      expect(
        d('craniotomy-for-traumatic-brain-injury-tbi'),
        contains('not blanket targets'),
      );
      expect(
        d('craniotomy-for-traumatic-brain-injury-tbi'),
        contains('methylprednisolone increases mortality'),
      );
      expect(
        d('craniotomy-for-cerebral-aneurysm-clipping'),
        contains('does not establish one universal BP target'),
      );
      expect(
        d('intracerebral-hemorrhage-evacuation'),
        contains('without emergency surgery'),
      );
      expect(
        d('mep-monitoring-anesthesia-considerations'),
        contains('immediately announce it'),
      );
      expect(
        d('mep-monitoring-anesthesia-considerations'),
        contains('in parallel'),
      );
      expect(
        d('external-ventricular-drain-evd-placement'),
        contains('Do not routinely clamp every EVD'),
      );
      expect(
        d('acdf-anterior-cervical-discectomy-and-fusion'),
        contains('cannot wait for routine imaging'),
      );
      expect(
        d('spinal-cord-stimulator-scs-implantation'),
        contains('not a blanket prohibition'),
      );
      expect(
        d('spinal-cord-stimulator-scs-implantation'),
        contains('never assume a magnet universally'),
      );
      expect(
        d('intracranial-avm-resection'),
        contains('not a proven one-size BP recipe'),
      );
    },
  );

  for (final width in [390.0, 900.0]) {
    testWidgets('neuro groups open at width $width and double text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1050);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(app(id: 'specialty/neuro-spine', scale: 2));
      await tester.pumpAndSettle();
      expect(find.text('Planning & neuromonitoring'), findsOneWidget);
      await tester.ensureVisible(
        find.text('Neuro & Spine: Clinical Framework'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Neuro & Spine: Clinical Framework'));
      await tester.pumpAndSettle();
      expect(find.text('Quick clinical overview'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  test('HPB grouping reuses GI and endocrine canonical references', () {
    final listed = surgicalHpbGroups.values.expand((ids) => ids).toList();
    final found = searchSurgicalCases(
      '',
      category: 'Hepatobiliary & transplant',
    );
    expect(listed, hasLength(21));
    expect(listed.toSet().length, listed.length);
    expect(found.map((c) => c.id).toSet(), listed.toSet());
    for (final id in [
      'insulinoma-resection',
      'pancreatic-neuroendocrine-tumor-resection',
      'whipple-procedure-pancreaticoduodenectomy',
      'ercp-endoscopic-retrograde-cholangiopancreatography',
    ]) {
      expect(found.where((c) => c.id == id), hasLength(1));
      expect(found.singleWhere((c) => c.id == id).route, '/surgical-prep/$id');
    }
    expect(
      searchSurgicalCases(
        'anhepatic',
        category: 'Hepatobiliary & transplant',
      ).any((c) => c.id == 'liver-transplant'),
      isTrue,
    );
  });

  test(
    'HPB safety qualifiers distinguish INR, perfusion and urgent drainage',
    () async {
      final cases = await SurgicalCatalog.load();
      String d(String id) =>
          cases[id]!.sections.expand((s) => s.bullets).join(' ');
      expect(
        d('hepatic-resection-open-laparoscopic'),
        contains('Do not chase a CVP number'),
      );
      expect(
        d('hepatic-resection-open-laparoscopic'),
        contains('must not delay source control or CPR'),
      );
      expect(
        d('cirrhosis-portal-hypertension-perioperative'),
        contains('INR alone does not measure overall bleeding risk'),
      );
      expect(
        d('cholangitis-obstructed-biliary-drainage'),
        contains('not permission to wait'),
      );
      expect(
        d('pancreatitis-necrosis-intervention'),
        contains('not routine prophylaxis for sterile pancreatitis'),
      );
      expect(
        d('liver-transplant'),
        contains('do not wait for a formal post-reperfusion-syndrome'),
      );
      expect(d('tips-portal-decompression'), contains('at least overnight'));
      expect(d('living-donor-hepatectomy'), contains('ability to withdraw'));
    },
  );

  testWidgets('HPB groups and canonical overview fit narrow double-text view', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1050);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      app(
        id: 'specialty/${surgicalSpecialtySlug('Hepatobiliary & transplant')}',
        scale: 2,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Planning & liver physiology'), findsOneWidget);
    await tester.ensureVisible(find.text('Hepatobiliary: Clinical Framework'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hepatobiliary: Clinical Framework'));
    await tester.pumpAndSettle();
    expect(find.text('Quick clinical overview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test(
    'gynecology groups preserve routes and keep postpartum hemorrhage in OB',
    () {
      final listed = surgicalGynecologyGroups.values
          .expand((ids) => ids)
          .toList();
      final found = searchSurgicalCases('', category: 'Gynecology');
      expect(listed, hasLength(27));
      expect(listed.toSet().length, listed.length);
      expect(found.map((c) => c.id).toSet(), listed.toSet());
      expect(
        listed,
        containsAll(['cervical-cerclage', 'postpartum-tubal-ligation']),
      );
      expect(listed, isNot(contains('postpartum-hemorrhage-management')));
      expect(
        searchSurgicalCases(
          'postpartum hemorrhage',
          category: 'Obstetric',
        ).any((c) => c.id == 'postpartum-hemorrhage-management'),
        isTrue,
      );
      expect(
        searchSurgicalCases('open oophorectomy', category: 'Gynecology').any(
          (c) =>
              c.route ==
              '/surgical-prep/laparoscopic-ovarian-cystectomy-oophorectomy',
        ),
        isTrue,
      );
      expect(
        searchSurgicalCases(
          'fluid deficit',
          category: 'Gynecology',
        ).any((c) => c.id == 'hysteroscopy'),
        isTrue,
      );
    },
  );

  test('gynecology clinical qualifiers remain explicit', () async {
    final cases = await SurgicalCatalog.load();
    String details(String id) =>
        cases[id]!.sections.expand((s) => s.bullets).join(' ');
    final hyst = details('hysteroscopy');
    expect(hyst, contains('1000 mL for hypotonic and 2500 mL for isotonic'));
    expect(hyst, contains('750 mL hypotonic and 1500 mL isotonic'));
    expect(hyst, contains('not identical to intravascular absorption'));
    expect(hyst, contains('isotonic saline generally avoids this mechanism'));
    expect(hyst, contains('not proven safe intravascular doses'));
    expect(
      details('myomectomy-open-laparoscopic'),
      contains('rather than systemic hypotension'),
    );
    expect(
      details('myomectomy-open-laparoscopic'),
      contains('do not establish a universally safe dose'),
    );
    expect(
      details('dilation-and-curettage-d-c'),
      contains('contraindicated in hypertension'),
    );
    expect(
      details('salpingectomy-ectopic-pregnancy-surgery'),
      contains('do not automatically apply every late-pregnancy'),
    );
    expect(
      details('endometrial-ablation'),
      contains('do not impose hysteroscopic saline deficit limits'),
    );
    expect(
      details('robotic-hysterectomy'),
      contains('even with palpable pulses'),
    );
    expect(details('robotic-hysterectomy'), contains('TOF ratio at least 0.9'));
    expect(
      details('gynecologic-oncology-staging-laparotomy'),
      contains('not accessible for verification'),
    );
  });

  for (final width in [390.0, 900.0]) {
    testWidgets('gynecology groups open at width $width and double text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1050);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(app(id: 'specialty/gynecology', scale: 2));
      await tester.pumpAndSettle();
      expect(find.text('Planning & emergencies'), findsOneWidget);
      await tester.ensureVisible(find.text('Gynecology: Clinical Framework'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gynecology: Clinical Framework'));
      await tester.pumpAndSettle();
      expect(find.text('Quick clinical overview'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  test(
    'abdominal and GI groups are complete, unique and reuse canonical routes',
    () {
      for (final entry in surgicalAbdominalGiGroups.entries) {
        final listed = entry.value.values.expand((ids) => ids).toList();
        final found = searchSurgicalCases('', category: entry.key);
        expect(listed.toSet().length, listed.length);
        expect(found.map((c) => c.id).toSet(), listed.toSet());
        expect(found.map((c) => c.route).toSet().length, found.length);
      }
      expect(searchSurgicalCases('', category: 'GI endoscopy'), hasLength(16));
      expect(
        searchSurgicalCases('', category: 'General & abdominal'),
        hasLength(39),
      );
      for (final category in ['General & abdominal', 'GI endoscopy']) {
        expect(
          searchSurgicalCases(
            'PEG',
            category: category,
          ).any((c) => c.id == 'feeding-tube-placement-peg-j-tube'),
          isTrue,
        );
      }
      expect(
        searchSurgicalCases(
          '',
          category: 'General & abdominal',
        ).any((c) => c.id == 'thyroidectomy'),
        isFalse,
      );
      expect(
        searchSurgicalCases('thyroidectomy', category: 'Endocrine').first.route,
        '/surgical-prep/thyroidectomy',
      );
      expect(
        searchSurgicalCases(
          'bronchoscopy',
          category: 'GI endoscopy',
        ).any((c) => c.id == 'bronchoscopy-flexible-rigid'),
        isFalse,
      );
    },
  );

  test(
    'new abdominal and GI clinical qualifiers remain searchable and explicit',
    () async {
      final cases = await SurgicalCatalog.load();
      String details(String id) =>
          cases[id]!.sections.expand((s) => s.bullets).join(' ');
      expect(
        details('ercp-endoscopic-retrograde-cholangiopancreatography'),
        contains('Age or ASA classification alone'),
      );
      expect(
        details('upper-gi-bleed-endoscopic-hemostasis'),
        contains('advises against routine prophylactic intubation'),
      );
      expect(
        details('feeding-tube-placement-peg-j-tube'),
        contains('against routine withholding of antiplatelets'),
      );
      expect(
        details('variceal-banding-hemorrhage'),
        contains('does not reliably represent hemostatic status'),
      );
      expect(
        details('capsule-endoscopy-placement'),
        contains('not a reason by itself to provide IV sedation'),
      );
      expect(
        details('poem-peroral-endoscopic-myotomy'),
        contains('not mandatory prerequisites for rescue'),
      );
      expect(
        details('hepatic-resection-open-laparoscopic'),
        contains('Do not chase a CVP number'),
      );
      expect(
        details('ruptured-abdominal-aortic-aneurysm-raaa'),
        contains('not an instruction to tolerate absent perfusion'),
      );
      expect(
        searchSurgicalCases(
          'capnothorax',
          category: 'GI endoscopy',
        ).any((c) => c.id == 'poem-peroral-endoscopic-myotomy'),
        isTrue,
      );
      expect(
        searchSurgicalCases(
          'loss of domain',
          category: 'General & abdominal',
        ).any(
          (c) => c.id == 'robotic-hernia-repair-abdominal-wall-reconstruction',
        ),
        isTrue,
      );
    },
  );

  for (final category in ['General & abdominal', 'GI endoscopy']) {
    testWidgets(
      '$category grouping and case opening fit narrow double-text view',
      (tester) async {
        tester.view.physicalSize = const Size(390, 1050);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          app(id: 'specialty/${surgicalSpecialtySlug(category)}', scale: 2),
        );
        await tester.pumpAndSettle();
        final firstGroup = surgicalAbdominalGiGroups[category]!.keys.first;
        expect(find.text(firstGroup), findsOneWidget);
        final title = category == 'GI endoscopy'
            ? 'GI / Endoscopy: Clinical Framework'
            : 'General & Abdominal: Clinical Framework';
        await tester.ensureVisible(find.text(title));
        await tester.pumpAndSettle();
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        expect(find.text('Quick clinical overview'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  test(
    'EP groups cover every reference exactly once and retain clinical depth',
    () async {
      final cases = await SurgicalCatalog.load();
      final ep = searchSurgicalCases('', category: 'EP & structural heart');
      final grouped = surgicalEpGroups.values.expand((ids) => ids).toList();
      expect(ep.length, 26);
      expect(grouped.length, 26);
      expect(grouped.toSet().length, 26);
      expect(grouped.toSet(), ep.map((c) => c.id).toSet());
      expect(surgicalEpGroups.keys.toList(), [
        'EP ablation & cardioversion',
        'Cardiac devices',
        'Structural heart interventions',
        'Special & high-risk cath-lab cases',
      ]);
      for (final id in grouped) {
        final c = cases[id]!;
        expect(c.overview.bullets.length, 4);
        expect(c.sections.length, greaterThanOrEqualTo(10));
        expect(c.sections.map((s) => s.id).toSet().length, c.sections.length);
      }
    },
  );

  test('EP safety distinctions are searchable and source-linked', () async {
    final cases = await SurgicalCatalog.load();
    String body(String id) => [
      ...cases[id]!.overview.bullets,
      ...cases[id]!.sections.expand((s) => s.bullets),
    ].join(' ');
    expect(
      body('ventricular-tachycardia-vt-ablation'),
      contains('not mandatory for every VT'),
    );
    expect(
      body('atrial-fibrillation-ablation-pulmonary-vein-isolation'),
      contains('Hemolysis'),
    );
    expect(
      body('elective-cardioversion-dccv'),
      contains('under 48 hours is always safe'),
    );
    expect(
      body('elective-cardioversion-dccv'),
      contains('negative TEE does not eliminate'),
    );
    expect(
      body('lead-extraction-transvenous'),
      contains('Absence of a large pericardial effusion'),
    );
    expect(
      body('transcatheter-tricuspid-interventions'),
      contains('effective RV afterload'),
    );
    expect(body('adult-vsd-device-closure'), contains('not post-infarction'));
    expect(
      body('ice-guided-structural-planning'),
      contains('not a separate intervention'),
    );
    for (final term in ['hemolysis', 'BASILICA', 'neo-LVOT', 'CRT', 'LINQ']) {
      expect(
        searchSurgicalCases(term, category: 'EP & structural heart'),
        isNotEmpty,
        reason: term,
      );
    }
  });

  for (final width in [320.0, 820.0]) {
    testWidgets('EP groups and search work at width $width with large text', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 1100));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        app(id: 'specialty/ep-structural-heart', scale: 2),
      );
      await tester.pumpAndSettle();
      expect(find.text('EP ablation & cardioversion'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'BASILICA');
      await tester.pumpAndSettle();
      expect(find.text('Aortic Valve-in-Valve TAVR'), findsOneWidget);
      expect(find.text('EP ablation & cardioversion'), findsNothing);
      await tester.tap(find.text('Aortic Valve-in-Valve TAVR'));
      await tester.pumpAndSettle();
      expect(find.text('Quick clinical overview'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  test(
    'Endocrine cross-listing preserves canonical routes without duplicates',
    () async {
      final cases = await SurgicalCatalog.load();
      final endocrine = searchSurgicalCases('', category: 'Endocrine');
      expect(endocrine.length, 14);
      expect(endocrine.map((c) => c.id).toSet().length, 14);
      for (final c in endocrine) {
        expect(cases[c.id]!.overview.bullets.length, 4);
        expect(cases[c.id]!.sections.length, inInclusiveRange(12, 14));
      }
      final whipple = searchSurgicalCases(
        'Whipple',
        category: 'Endocrine',
      ).first;
      expect(whipple.category, 'Hepatobiliary & transplant');
      expect(
        whipple.route,
        '/surgical-prep/whipple-procedure-pancreaticoduodenectomy',
      );
      expect(surgicalIndex.where((c) => c.id == whipple.id).length, 1);
      expect(
        searchSurgicalCases(
          'thyroidectomy',
          category: 'General & abdominal',
        ).any((c) => c.id == 'thyroidectomy'),
        false,
      );
      expect(
        searchSurgicalCases(
          'adipsic',
          category: 'Endocrine',
        ).any((c) => c.id == 'craniopharyngioma-resection-adult'),
        true,
      );
    },
  );

  test('Endocrine clinical qualifiers survive catalog generation', () async {
    final cases = await SurgicalCatalog.load();
    String body(String id) => [
      cases[id]!.overview,
      ...cases[id]!.sections,
    ].expand((s) => s.bullets).join(' ');
    expect(body('thyroidectomy'), contains('including the strap layer'));
    expect(
      body('thyroidectomy'),
      contains('do not delay decompression for imaging'),
    );
    expect(body('parathyroidectomy'), contains('Hungry bone syndrome'));
    expect(
      body('pheochromocytoma-resection'),
      contains('only after adequate alpha blockade'),
    );
    expect(
      body('cortisol-producing-adrenal-tumor'),
      contains('empirical postoperative glucocorticoid replacement'),
    );
    expect(
      body('aldosterone-producing-adrenal-tumor'),
      contains('hyperkalemia'),
    );
    expect(
      body('transsphenoidal-pituitary-surgery-tsps-endoscopic'),
      contains('Do not apply a blanket postoperative fluid restriction'),
    );
    expect(
      body('acromegaly-pituitary-surgery'),
      contains('Do not give repeated DDAVP solely'),
    );
    expect(
      body('cushing-disease-transsphenoidal-surgery'),
      contains('not routine withholding'),
    );
    expect(
      body('craniopharyngioma-resection-adult'),
      contains('Do not rely on drink-to-thirst instructions alone'),
    );
    expect(
      body('insulinoma-resection'),
      contains('unreliable stand-alone marker'),
    );
    expect(
      body('insulinoma-resection'),
      contains('paradoxically worsen hypoglycemia'),
    );
    expect(
      body('pancreatic-neuroendocrine-tumor-resection'),
      contains('bicarbonate-loss metabolic acidosis'),
    );
    expect(
      body('men-syndromes-surgical-planning'),
      contains('not increased as it is in MEN2A'),
    );
    expect(
      body('whipple-procedure-pancreaticoduodenectomy'),
      contains('not mandatory'),
    );
  });

  test(
    'generator change uses asynchronous pacing and ICD magnet qualification',
    () async {
      final cases = await SurgicalCatalog.load();
      final section = cases['pacemaker-icd-generator-change']!.sections
          .firstWhere((s) => s.id == 'intraop');
      final body = section.bullets.join(' ');
      expect(body, contains('asynchronous-pacing'));
      expect(body, isNot(contains('to a synchronous mode')));
      expect(body, contains('without changing its pacing mode'));
      expect(body, contains('possible interruption of pacing support'));
      expect(
        section.sources.any((s) => s.url.contains('j.jacc.2024.06.013')),
        true,
      );
      expect(
        searchSurgicalCases(
          'asynchronous',
          category: 'EP & structural heart',
        ).any((c) => c.id == 'pacemaker-icd-generator-change'),
        true,
      );
    },
  );

  test('plastic skin graft harmonizes burn succinylcholine cautions', () async {
    final cases = await SurgicalCatalog.load();
    final body = cases['split-thickness-full-thickness-skin-graft']!.sections
        .expand((s) => s.bullets)
        .join(' ');
    expect(body, contains('after the first 24 hours'));
    expect(
      body,
      contains('rather than treating 24–48 hours as an assured safe window'),
    );
    expect(body, contains('cannot be cleared by the calendar alone'));
    expect(body, contains('electrical/crush muscle injury'));
    expect(body, isNot(contains('avoid succinylcholine from 48 hours')));
  });

  test(
    'loop recorder does not prescribe universal magnet activation',
    () async {
      final cases = await SurgicalCatalog.load();
      final section = cases['implantable-loop-recorder-ilr-placement']!.sections
          .firstWhere((s) => s.id == 'procedure');
      final body = section.bullets.join(' ');
      expect(body, contains('workflows are device-specific'));
      expect(body, contains('rather than assuming magnet activation'));
      expect(body, contains('when prescribed'));
      expect(
        body,
        isNot(contains('The device is activated by passing a magnet')),
      );
      expect(section.sources.any((s) => s.url.contains('medtronic.com')), true);
      expect(
        searchSurgicalCases(
          'LINQ',
          category: 'EP & structural heart',
        ).any((c) => c.id == 'implantable-loop-recorder-ilr-placement'),
        true,
      );
    },
  );

  test(
    'ENT cross-lists tracheostomy without moving or duplicating its route',
    () async {
      const id = 'tracheostomy-placement';
      final cases = await SurgicalCatalog.load();
      expect(cases[id]!.category, 'General & abdominal · Clinical draft');
      expect(
        surgicalIndex.singleWhere((c) => c.id == id).category,
        'General & abdominal',
      );
      expect(surgicalIndex.where((c) => c.id == id).length, 1);
      expect(
        searchSurgicalCases('', category: 'ENT & shared airway').length,
        15,
      );
      for (final category in [
        'ENT & shared airway',
        'General & abdominal',
        'All',
      ]) {
        final matches = searchSurgicalCases(
          'tracheostomy',
          category: category,
        ).where((c) => c.id == id).toList();
        expect(matches.length, 1);
        expect(matches.single.route, '/surgical-prep/tracheostomy-placement');
      }
    },
  );

  testWidgets('ENT tracheostomy shortcut opens the existing reference', (
    tester,
  ) async {
    await tester.pumpWidget(app(id: 'specialty/ent-shared-airway'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'tracheostomy');
    await tester.pumpAndSettle();
    expect(find.text('Tracheostomy Placement'), findsOneWidget);
    expect(find.text('Related case · General & abdominal'), findsOneWidget);
    await tester.ensureVisible(find.text('Tracheostomy Placement'));
    await tester.tap(find.text('Tracheostomy Placement'));
    await tester.pumpAndSettle();
    expect(find.text('Quick clinical overview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('ENT expansion preserves adult airway safety distinctions', () async {
    final cases = await SurgicalCatalog.load();
    final ent = cases.values.where(
      (c) => c.category.startsWith('ENT & shared airway'),
    );
    expect(ent.length, 14);
    for (final c in ent) {
      expect(c.overview.bullets.length, 4);
      expect(c.sections.length, inInclusiveRange(11, 14));
    }
    String body(String id) =>
        cases[id]!.sections.expand((s) => s.bullets).join(' ');
    expect(
      body('laryngectomy-total-partial'),
      contains(
        'Oral/nasal intubation or face-mask ventilation cannot ventilate the lungs.',
      ),
    );
    final awake = body('awake-fiber-optic-intubation-afoi');
    expect(awake, contains('9 mg/kg LEAN body weight'));
    expect(awake, contains('not actual body weight and not a target'));
    expect(awake, contains('Postponement is the default'));
    expect(
      body('microlaryngoscopy-vocal-cord-surgery'),
      contains('patent expiratory path'),
    );
    expect(
      body('tympanoplasty'),
      contains('Nitrous oxide is generally avoided'),
    );
    expect(
      body('tonsillectomy-and-adenoidectomy-t-a-adult'),
      contains('pediatric-specific'),
    );
    expect(body('airway-foreign-body-removal'), contains('en bloc'));
  });

  test('ENT clinical terms resolve to their existing procedure routes', () {
    for (final entry in {
      'AFOI': 'awake-fiber-optic-intubation-afoi',
      'jet ventilation': 'microlaryngoscopy-vocal-cord-surgery',
      'epiglottitis': 'tracheal-intubation-for-epiglottitis',
      'cholesteatoma': 'mastoidectomy',
    }.entries) {
      expect(
        searchSurgicalCases(
          entry.key,
          category: 'ENT & shared airway',
        ).any((c) => c.id == entry.value),
        true,
        reason: entry.key,
      );
    }
  });

  test(
    'cardiothoracic expansion preserves scope and safety distinctions',
    () async {
      final cases = await SurgicalCatalog.load();
      final ct = cases.values.where(
        (c) => c.category.startsWith('Cardiac & thoracic'),
      );
      expect(ct.length, 25);
      for (final c in ct) {
        expect(c.sections.length, greaterThanOrEqualTo(11));
        expect(c.overview.bullets.length, 4);
      }
      String body(String id) =>
          cases[id]!.sections.expand((s) => s.bullets).join(' ');
      expect(
        body('cabg-coronary-artery-bypass-grafting'),
        contains('ACT >480 seconds'),
      );
      expect(
        body('cabg-coronary-artery-bypass-grafting'),
        contains('system-specific target'),
      );
      expect(
        body('mitral-valve-repair-replacement'),
        contains('afterload mismatch'),
      );
      expect(
        body('mitral-valve-repair-replacement'),
        contains('reducing inotropic'),
      );
      expect(body('tricuspid-valve-repair-replacement'), contains('CVP'));
      expect(
        body('mediastinal-mass-resection'),
        contains('does not prove routine induction safe'),
      );
      expect(
        body('ecmo-cannulation-decannulation'),
        contains('no direct hemodynamic support'),
      );
      expect(body('ecmo-cannulation-decannulation'), contains('Right-radial'));
      expect(
        body('lvad-placement-left-ventricular-assist-device'),
        contains('Console flow is an estimate'),
      );
      expect(
        body('esophagectomy-ivor-lewis-mckeown-minimally-invasive'),
        contains('Do not insert an NG/OG tube blindly'),
      );
      expect(body('thymectomy-vats-open-robotic'), contains('quantitative'));
      expect(
        cases['mediastinoscopy']!.sections.any((s) => s.id == 'hypoxemia'),
        false,
      );
      expect(
        searchSurgicalCases('SAM')
            .any((c) => c.id == 'mitral-valve-repair-replacement'),
        true,
      );
      expect(
        searchSurgicalCases('Harlequin').single.id,
        'ecmo-cannulation-decannulation',
      );
      expect(
        searchSurgicalCases('mediastinal mass')
            .any((c) => c.id == 'mediastinal-mass-resection'),
        true,
      );
    },
  );

  test(
    'colorectal expansion preserves distinct pathways and searchable details',
    () async {
      final cases = await SurgicalCatalog.load();
      final colorectal = cases.values.where(
        (c) => c.category.startsWith('Colorectal'),
      );
      expect(colorectal.length, 7);
      for (final c in colorectal) {
        expect(c.overview.bullets.length, 4);
        if (c.id == 'hemorrhoidectomy') {
          expect(c.sections.length, 14);
          expect(
            c.sections.any((s) => s.id == 'preparation-antithrombotics'),
            true,
          );
        } else {
          expect(c.sections.length, inInclusiveRange(12, 13));
        }
      }
      String body(String id) =>
          cases[id]!.sections.expand((s) => s.bullets).join(' ');
      expect(
        body('colectomy-open-laparoscopic-robotic'),
        contains('combined with oral antibiotics'),
      );
      expect(
        body('colectomy-open-laparoscopic-robotic'),
        contains('not routinely recommended for laparoscopic'),
      );
      expect(
        body('low-anterior-resection-lar'),
        contains('Preserved pulses do not exclude'),
      );
      expect(
        body('abdominoperineal-resection-apr'),
        contains('no other anastomosis'),
      );
      expect(
        body('ostomy-creation-reversal-ileostomy-colostomy'),
        contains('no universally reliable volume threshold'),
      );
      expect(
        body('bowel-obstruction-surgery-open-laparoscopic'),
        contains('does not guarantee an empty stomach'),
      );
      expect(
        body('bowel-obstruction-surgery-open-laparoscopic'),
        contains('Do not delay urgent source control'),
      );
      expect(
        body('hemorrhoidectomy'),
        contains('routine postoperative analgesic adjunct'),
      );
      expect(
        body('anal-fistula-repair-fistulotomy-lift-seton'),
        contains('cutting seton is not sphincter-sparing'),
      );
      expect(
        searchSurgicalCases('high output stoma')
            .any((c) => c.id == 'ostomy-creation-reversal-ileostomy-colostomy'),
        true,
      );
      expect(
        searchSurgicalCases(
          'pudendal',
          category: 'Colorectal',
        ).any((c) => c.id == 'hemorrhoidectomy'),
        true,
      );
      expect(
        searchSurgicalCases(
          'well leg compartment',
          category: 'Colorectal',
        ).any((c) => c.id == 'low-anterior-resection-lar'),
        true,
      );
    },
  );

  test(
    'dental references preserve adult scope and procedure-specific safeguards',
    () async {
      final cases = await SurgicalCatalog.load();
      final dental = cases.values.where(
        (c) => c.category.startsWith('Dental & maxillofacial'),
      );
      expect(dental.length, 2);
      for (final c in dental) {
        expect(c.overview.bullets.length, 4);
        expect(c.sections.length, inInclusiveRange(16, 17));
      }
      String body(String id) =>
          cases[id]!.sections.expand((s) => s.bullets).join(' ');
      final rehab = body(
        'dental-rehabilitation-under-general-anesthesia-adult',
      );
      final jaw = body('orthognathic-surgery-bimaxillary-osteotomy');
      expect(rehab, contains('Do not infer incapacity'));
      expect(rehab, contains('no longer recommend routine'));
      expect(rehab, contains('NSAID alone or with acetaminophen'));
      expect(
        rehab,
        contains('smaller preformed nasal RAE tube is also shorter'),
      );
      expect(jaw, contains('no universal minimum MAP'));
      expect(jaw, contains('Immediately ask the surgeon to stop'));
      expect(jaw, contains('elastics require a release plan'));
      expect(
        jaw,
        contains(
          'cuff leak can add information but does not guarantee success',
        ),
      );
      expect(jaw, contains('does not establish a universal regimen'));
      expect(
        searchSurgicalCases('BSSO').first.id,
        'orthognathic-surgery-bimaxillary-osteotomy',
      );
      expect(
        searchSurgicalCases(
          'trigeminocardiac',
          category: 'Dental & maxillofacial',
        ).single.id,
        'orthognathic-surgery-bimaxillary-osteotomy',
      );
      expect(
        searchSurgicalCases('nasal RAE').any(
          (c) => c.id == 'dental-rehabilitation-under-general-anesthesia-adult',
        ),
        true,
      );
    },
  );

  test('manual safety corrections survive catalog generation', () async {
    final cases = await SurgicalCatalog.load();
    final tbi = cases['craniotomy-for-traumatic-brain-injury-tbi']!;
    final airway = tbi.sections.firstWhere((s) => s.id == 'airway');
    expect(airway.bullets.join(' '), contains('35–45 mmHg'));
    expect(
      airway.bullets.join(' '),
      contains('when intracranial hypertension is absent'),
    );
    expect(
      airway.bullets.join(' '),
      isNot(contains('should be maintained at 30–35')),
    );
    expect(
      tbi.sections
          .expand((s) => s.sources)
          .any(
            (s) =>
                s.url == 'https://braintrauma.org/coma/guidelines/severe-tbi',
          ),
      true,
    );
    final pyelo = cases['pyeloplasty-open-robotic']!;
    expect(
      pyelo.sections.expand((s) => s.bullets).join(' '),
      isNot(contains('dexketoprofen 50 mg')),
    );
    for (final c in cases.values) {
      for (final source in [
        c.overview,
        ...c.sections,
      ].expand((s) => s.sources)) {
        expect(source.label, isNot(contains('*')));
      }
    }
  });

  testWidgets(
    'unsubscribed hub and direct detail show paywall, never case content',
    (tester) async {
      for (final id in [
        null,
        'specialty/bariatric',
        'specialty/burns',
        'specialty/colorectal',
        'specialty/dental-maxillofacial',
        'orthognathic-surgery-bimaxillary-osteotomy',
        'colectomy-open-laparoscopic-robotic',
        'escharotomy-fasciotomy-for-burns',
        'laparoscopic-cholecystectomy',
      ]) {
        await tester.pumpWidget(app(id: id, allowed: false));
        await tester.pumpAndSettle();
        expect(find.byType(SubscriptionScreen), findsOneWidget);
        expect(find.text('Quick clinical overview'), findsNothing);
        expect(find.text('Choose a specialty'), findsNothing);
        expect(find.text('Bariatric cases'), findsNothing);
        await tester.pumpWidget(const SizedBox());
      }
    },
  );

  testWidgets('detail checks entitlement once, then shows bundled content', (
    tester,
  ) async {
    var checks = 0;
    await tester.pumpWidget(
      app(
        id: 'laparoscopic-cholecystectomy',
        checker: () async {
          checks++;
          return true;
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(checks, 1);
    expect(find.text('Quick clinical overview'), findsOneWidget);
  });

  testWidgets('hub search opens case and Home returns to dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'lap chole');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laparoscopic cholecystectomy'));
    await tester.pumpAndSettle();
    expect(find.text('Quick clinical overview'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets(
    'unknown route gives useful recovery instead of empty reference',
    (tester) async {
      await tester.pumpWidget(app(id: 'missing-case'));
      await tester.pumpAndSettle();
      expect(
        find.text('This surgical case could not be found.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Browse specialties'));
      await tester.pumpAndSettle();
      expect(find.text('Choose a specialty'), findsOneWidget);
    },
  );

  for (final width in [320.0, 820.0]) {
    testWidgets('Endocrine related case fits width $width at double text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(app(id: 'specialty/endocrine', scale: 2));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Whipple');
      await tester.pumpAndSettle();
      expect(find.text('Adjacent HPB case'), findsOneWidget);
      await tester.ensureVisible(
        find.text('Whipple Procedure (Pancreaticoduodenectomy)'),
      );
      await tester.tap(
        find.text('Whipple Procedure (Pancreaticoduodenectomy)'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Quick clinical overview'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets(
      'ENT specialty and awake airway reference fit width $width at double text',
      (tester) async {
        tester.view.physicalSize = Size(width, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          app(id: 'specialty/ent-shared-airway', scale: 2),
        );
        await tester.pumpAndSettle();
        expect(find.text('ENT & shared airway cases'), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'AFOI');
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.text('Awake Fiber-Optic Intubation (AFOI)'),
        );
        await tester.tap(find.text('Awake Fiber-Optic Intubation (AFOI)'));
        await tester.pumpAndSettle();
        expect(find.text('Quick clinical overview'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets(
      'dental specialty and jaw reference fit width $width at double text',
      (tester) async {
        tester.view.physicalSize = Size(width, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          app(id: 'specialty/dental-maxillofacial', scale: 2),
        );
        await tester.pumpAndSettle();
        expect(find.text('Dental & maxillofacial cases'), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'BSSO');
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.text('Orthognathic Surgery (Bimaxillary Osteotomy)'),
        );
        await tester.tap(
          find.text('Orthognathic Surgery (Bimaxillary Osteotomy)'),
        );
        await tester.pumpAndSettle();
        expect(find.text('Quick clinical overview'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets(
      'colorectal specialty and detail fit width $width at double text',
      (tester) async {
        tester.view.physicalSize = Size(width, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(app(id: 'specialty/colorectal', scale: 2));
        await tester.pumpAndSettle();
        expect(find.text('Colorectal cases'), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'hemorrhoidectomy');
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Hemorrhoidectomy'));
        await tester.tap(find.text('Hemorrhoidectomy'));
        await tester.pumpAndSettle();
        expect(find.text('Quick clinical overview'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets(
      'cardiothoracic tiles and new detail fit width $width at double text',
      (tester) async {
        tester.view.physicalSize = Size(width, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          app(id: 'specialty/cardiac-thoracic', scale: 2),
        );
        await tester.pumpAndSettle();
        expect(find.text('Cardiac & thoracic cases'), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'mitral');
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.text('Mitral Valve Repair / Replacement'),
        );
        await tester.tap(find.text('Mitral Valve Repair / Replacement'));
        await tester.pumpAndSettle();
        expect(find.text('Quick clinical overview'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets(
      'specialty tiles fit width $width with double text and searches reset',
      (tester) async {
        tester.view.physicalSize = Size(width, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(app(scale: 2));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Bariatric'));
        await tester.tap(find.text('Bariatric'));
        await tester.pumpAndSettle();
        expect(find.text('Bariatric cases'), findsOneWidget);
        expect(find.text('Cesarean Delivery'), findsNothing);
        await tester.enterText(find.byType(TextField), 'zzzzunknownterm');
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Reset search'));
        await tester.tap(find.text('Reset search'));
        await tester.pumpAndSettle();
        expect(find.text('No matching cases. Try another term.'), findsNothing);
        await tester.ensureVisible(find.text('All specialties'));
        await tester.tap(find.text('All specialties'));
        await tester.pumpAndSettle();
        expect(find.text('Choose a specialty'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  test(
    'Bariatric content includes five cases and preserves clinical qualifiers',
    () async {
      final cases = await SurgicalCatalog.load();
      final bariatric = searchSurgicalCases('', category: 'Bariatric');
      expect(bariatric.length, 5);
      expect(
        searchSurgicalCases('lap band').first.id,
        'adjustable-gastric-band-lap-band',
      );
      expect(searchSurgicalCases('SADI').first.id, 'sadi-s');
      final sleeve = cases['sleeve-gastrectomy']!;
      final text = [
        ...sleeve.overview.bullets,
        ...sleeve.sections.expand((s) => s.bullets),
      ].join(' ');
      for (final phrase in [
        '58.35%',
        '80% refers to stomach',
        'calibration bougie',
        'ACTUAL body weight',
        'Most patients can continue GLP-1',
        'historical',
        'CPAP is not automatically prohibited',
        'Propofol maintenance/TIVA',
      ]) {
        expect(text, contains(phrase));
      }
      expect(
        surgicalCategories
            .where((c) => c != 'All')
            .map(surgicalSpecialtySlug)
            .toSet()
            .length,
        22,
      );
    },
  );

  test(
    'Burns has seven cases and clinically important searchable warnings',
    () async {
      final cases = await SurgicalCatalog.load();
      expect(searchSurgicalCases('', category: 'Burns').length, 7);
      expect(cases.containsKey('burn-fasciotomy'), true);
      expect(cases.containsKey('burn-escharotomy'), true);
      final text = cases['burn-wound-debridement-excision']!.sections
          .expand((s) => s.bullets)
          .join(' ');
      for (final term in [
        'after the first 24 hours',
        'months or longer',
        'first-24-hour volume estimate',
        'co-oximetry',
        'CYANOKIT',
        'donor',
        'quantitative neuromuscular',
        'Hypothermia',
      ]) {
        expect(text, contains(term));
      }
      expect(
        cases['burn-related-amputation']!.overview.bullets.join(' '),
        contains('phantom limb'),
      );
    },
  );

  testWidgets('old combined burn URL opens Burns specialty and Home works', (
    tester,
  ) async {
    await tester.pumpWidget(app(id: 'escharotomy-fasciotomy-for-burns'));
    await tester.pumpAndSettle();
    expect(find.text('Burns cases'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('library reserves footer clearance for the floating shortcut', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    final bottom = tester.getRect(find.byType(CustomScrollView)).bottom;
    final screen =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(screen - bottom, greaterThanOrEqualTo(84));
  });

  testWidgets('specialty opens case and unknown specialty can recover', (
    tester,
  ) async {
    await tester.pumpWidget(app(id: 'specialty/bariatric'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'sleeve gastrectomy');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sleeve Gastrectomy'));
    await tester.pumpAndSettle();
    expect(find.text('Quick clinical overview'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app(id: 'specialty/not-real'));
    await tester.pumpAndSettle();
    expect(find.text('This specialty could not be found.'), findsOneWidget);
    await tester.tap(find.text('Browse specialties'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a specialty'), findsOneWidget);
  });
}
