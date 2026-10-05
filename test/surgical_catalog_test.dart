import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/surgical_prep/surgical_catalog.dart';
import 'package:luma_anesthesia/surgical_prep/surgical_library_screen.dart';
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
  test('251 unique adult/OB references are bundled and all remain release-deferred', () async {
    final raw = jsonDecode(
      await rootBundle.loadString('assets/data/surgical_cases.json'),
    ) as List;
    final cases = await SurgicalCatalog.load();
    expect(raw.length, 250);
    expect(cases.length, 251);
    expect(surgicalIndex.length, cases.length);
    expect(surgicalIndex.map((r) => r.id).toSet().length, 251);
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
