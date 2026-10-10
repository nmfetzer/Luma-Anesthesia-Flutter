import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/surgical_prep/surgical_catalog.dart';
import 'package:luma_anesthesia/surgical_prep/final_specialty_groups.dart';
import 'package:luma_anesthesia/surgical_prep/surgical_library_screen.dart';
import 'package:luma_anesthesia/launch/launch_scope.dart';
import 'package:luma_anesthesia/screens/subscription_screen.dart';
import 'package:luma_anesthesia/theme/luma_theme.dart';

Widget page(String id, {bool allowed = true, double scale = 1}) => MaterialApp(
  theme: buildLumaTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(disableAnimations: true, textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: SurgicalPrepFeature(
    caseId: id,
    checkAccess: () async => allowed,
    accessChanges: const Stream<void>.empty(),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => SurgicalCatalog.load());

  test(
    'all original inventory entries resolve, including the split burn route',
    () async {
      final fixture = jsonDecode(
        await File('test/fixtures/surgical_preservation.json').readAsString(),
      ) as Map;
      final cases = await SurgicalCatalog.load();
      expect((fixture['originalIds'] as List).length, 243);
      for (final id in fixture['originalIds'] as List) {
        if (id == 'escharotomy-fasciotomy-for-burns') {
          expect(cases.containsKey('burn-escharotomy'), true);
          expect(cases.containsKey('burn-fasciotomy'), true);
        } else {
          expect(cases.containsKey(id), true, reason: '$id');
        }
      }
      expect(cases.values.where((c) => c.category == 'Obstetric').length, 9);
    },
  );

  test(
    'six specialty groups contain every canonical entry and no duplicate tiles',
    () async {
      final cases = await SurgicalCatalog.load();
      expect(surgicalFinalSpecialtyGroups.length, 6);
      for (final entry in surgicalFinalSpecialtyGroups.entries) {
        final listed = entry.value.values.expand((ids) => ids).toList();
        expect(listed.length, listed.toSet().length, reason: entry.key);
        expect(
          listed.toSet(),
          searchSurgicalCases('', category: entry.key).map((c) => c.id).toSet(),
          reason: entry.key,
        );
        for (final id in listed) {
          expect(cases.containsKey(id), true);
          expect(LaunchScope.isDeferred('/surgical-prep/$id'), false);
        }
      }
      expect(
        searchSurgicalCases(
          'nephrostomy',
          category: 'Urology',
        ).map((c) => c.id),
        contains('percutaneous-nephrostomy'),
      );
      expect(
        searchSurgicalCases(
          'root ascending',
          category: 'Vascular',
        ).map((c) => c.id),
        contains('aortic-root-ascending-aorta-repair'),
      );
    },
  );

  test(
    'new clinical distinctions and prior safety corrections remain searchable',
    () async {
      final cases = await SurgicalCatalog.load();
      String body(String id) =>
          cases[id]!.sections.expand((s) => s.bullets).join(' ');
      expect(
        body('mri-under-anesthesia-adult'),
        contains('Quench is not routine'),
      );
      expect(
        body('ophthalmology-clinical-framework'),
        contains('while intraocular gas remains'),
      );
      expect(
        body('free-flap-anesthesia-framework'),
        contains('not universally contraindicated'),
      );
      expect(body('trauma-massive-hemorrhage'), contains('within three hours'));
      expect(
        body('acute-spinal-cord-injury-trauma'),
        contains('not a mandate to lower a spontaneously higher MAP'),
      );
      expect(
        body('turp-transurethral-resection-of-the-prostate'),
        contains('normal sodium does not exclude'),
      );
      expect(
        body('turbt-transurethral-resection-of-bladder-tumor'),
        contains('Spinal anesthesia does not reliably'),
      );
      expect(
        body('ruptured-abdominal-aortic-aneurysm-raaa'),
        contains('does not automatically imply GA'),
      );
      expect(
        body('split-thickness-full-thickness-skin-graft'),
        contains('cannot be cleared by the calendar alone'),
      );
      expect(
        body('pyeloplasty-open-robotic'),
        isNot(contains('dexketoprofen 50 mg')),
      );
      expect(
        body('craniotomy-for-traumatic-brain-injury-tbi'),
        contains('35–45 mmHg'),
      );
    },
  );

  for (final category in surgicalFinalSpecialtyGroups.keys) {
    testWidgets('$category grouped list fits a small phone at double text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        page('specialty/${surgicalSpecialtySlug(category)}', scale: 2),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(SubscriptionScreen), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  }
  for (final id in [
    'mri-under-anesthesia-adult',
    'ophthalmic-block-safety',
    'head-neck-free-flap-reconstruction',
    'trauma-massive-hemorrhage',
    'turp-transurethral-resection-of-the-prostate',
    'thoracoabdominal-aortic-repair',
  ]) {
    testWidgets('$id remains gated and renders its overview when entitled', (
      tester,
    ) async {
      await tester.pumpWidget(page(id, allowed: false));
      await tester.pumpAndSettle();
      expect(find.byType(SubscriptionScreen), findsOneWidget);
      expect(find.text('Quick clinical overview'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(page(id, scale: 2));
      await tester.pumpAndSettle();
      expect(find.text('Quick clinical overview'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
  test('all 350 JSON records retain populated cited details', () async {
    final rows = jsonDecode(
      await rootBundle.loadString('assets/data/surgical_cases.json'),
    ) as List;
    expect(rows.length, 350);
    for (final row in rows) {
      expect((row['sections'] as List).length, greaterThanOrEqualTo(10));
    }
  });
}
