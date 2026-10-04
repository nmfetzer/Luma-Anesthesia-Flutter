import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/home/home_search.dart';
import 'package:luma_anesthesia/home/home_screen.dart';
import 'package:luma_anesthesia/home/home_tile.dart';
import 'package:luma_anesthesia/crisis/crisis_repository.dart';
import 'package:luma_anesthesia/models/medication.dart';
import 'package:luma_anesthesia/special_considerations/special_consideration.dart';

const sections = [
  HomeSearchSection(
    pathophysiologyTitle,
    '/special-considerations',
    keywords: 'special considerations',
  ),
  HomeSearchSection('Crisis Hub', '/crisis-guidelines'),
  HomeSearchSection(
    'Practice Guidelines',
    '/practice-guidelines',
    keywords: 'ASA AANA CAA AAAA NCCAA ARC-AA standards policies advisories',
  ),
  HomeSearchSection('Luma Academy', '/luma-academy'),
  HomeSearchSection(
    'Diagnostics',
    '/diagnostics',
    keywords: 'ABG ACT labs troponin BNP POCUS ultrasound carotid',
  ),
];
final data = HomeSearchData(
  medications: [
    Medication.fromJson({
      'id': 'test',
      'name': 'Propofol',
      'brand_name': 'Diprivan',
      'category': 'Anesthetics',
    }),
  ],
  conditions: const [
    SpecialConsiderationEntry(
      slug: 'aortic-stenosis',
      title: 'Aortic Stenosis',
      category: 'Cardiac',
      reviewStatus: 'published',
      searchTags: ['AS'],
    ),
    SpecialConsiderationEntry(
      slug: 'draft',
      title: 'Draft condition',
      category: 'Cardiac',
    ),
  ],
);

Future<void> openSearch(
  WidgetTester tester, {
  Future<HomeSearchData> Function()? loader,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: HomeSearch(
          sections: sections,
          loadData: loader ?? () async => data,
        ),
      ),
      routes: {
        '/special-considerations': (_) =>
            const Scaffold(body: Text('Condition library opened')),
      },
    ),
  );
  await tester.tap(find.byType(SearchBar));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('publisher searches find the launch guideline tile', (
    tester,
  ) async {
    await openSearch(tester);
    for (final query in ['ASA', 'AANA', 'CAA', 'NCCAA']) {
      await tester.enterText(find.byType(TextField).last, query);
      await tester.pumpAndSettle();
      expect(find.text('Practice Guidelines'), findsOneWidget);
    }
  });
  testWidgets('home search hides deferred pediatric topics but retains PALS', (
    tester,
  ) async {
    await openSearch(
      tester,
      loader: () async => const HomeSearchData(
        crises: [
          CrisisEntry(
            slug: 'child-fixture',
            title: 'Pediatric Emergency Fixture',
            category: 'pediatric',
            searchTerms: 'pediatric child emergency',
          ),
          CrisisEntry(
            slug: 'pals',
            title: 'PALS',
            category: 'resuscitation',
            searchTerms: 'pediatric advanced life support',
          ),
        ],
      ),
    );
    await tester.enterText(find.byType(TextField).last, 'pediatric');
    await tester.pumpAndSettle();
    expect(find.text('Pediatric Emergency Fixture'), findsNothing);
    expect(find.text('PALS'), findsOneWidget);
    expect(find.text('Crisis Hub · 1 results'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'child emergency');
    await tester.pumpAndSettle();
    expect(find.textContaining('No matches yet'), findsOneWidget);
  });
  testWidgets(
    'live matches update without submitting; names, brands and no results',
    (tester) async {
      await openSearch(tester);
      await tester.enterText(find.byType(TextField).last, 'pro');
      await tester.pumpAndSettle();
      expect(find.text('Propofol'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, 'dipr');
      await tester.pumpAndSettle();
      expect(find.text('Propofol'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, 'aortic');
      await tester.pumpAndSettle();
      expect(find.text('Aortic Stenosis'), findsOneWidget);
      expect(find.textContaining('No matches yet'), findsNothing);
      await tester.enterText(find.byType(TextField).last, 'draft');
      await tester.pumpAndSettle();
      expect(find.text('Draft condition'), findsNothing);
      expect(find.textContaining('No matches yet'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, '');
      await tester.pumpAndSettle();
      expect(find.text('Crisis Hub'), findsOneWidget);
    },
  );

  testWidgets('special considerations alias opens the restored library', (
    tester,
  ) async {
    await openSearch(tester);
    await tester.enterText(
      find.byType(TextField).last,
      'special considerations',
    );
    await tester.pumpAndSettle();
    expect(find.text(pathophysiologyTitle), findsOneWidget);
    await tester.tap(find.text(pathophysiologyTitle));
    await tester.pumpAndSettle();
    expect(find.text('Condition library opened'), findsOneWidget);
  });

  testWidgets('other deferred sections stay excluded from search', (
    tester,
  ) async {
    await openSearch(tester);
    await tester.enterText(find.byType(TextField).last, 'academy');
    await tester.pumpAndSettle();
    expect(find.text('Luma Academy'), findsNothing);
    expect(find.textContaining('No matches yet'), findsOneWidget);
  });

  testWidgets('section search remains usable if library loading fails', (
    tester,
  ) async {
    await openSearch(tester, loader: () async => throw StateError('Offline'));
    await tester.enterText(find.byType(TextField).last, 'crisis');
    await tester.pumpAndSettle();
    expect(find.text('Crisis Hub'), findsOneWidget);
    expect(find.text('Some library results could not load.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'troponin');
    await tester.pumpAndSettle();
    expect(find.text('Diagnostics references'), findsOneWidget);
    expect(find.text('Cardiac Troponin'), findsOneWidget);
    expect(find.textContaining('No matches yet'), findsNothing);
  });

  for (final size in [
    const Size(375, 812),
    const Size(768, 1024),
    const Size(1280, 800),
  ]) {
    testWidgets(
      'launch tiles include pathophysiology and onboarding at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
        await tester.pump(const Duration(milliseconds: 100));
        Finder tile(String route) => find.byWidgetPredicate(
          (w) => w is HomeTile && w.data.route == route,
        );
        expect(find.byType(HomeTile), findsNWidgets(10));
        for (final path in [
          '/drug-library',
          '/crisis-guidelines',
          '/vasopressors-infusions',
          '/ce-halo',
          '/quick-references',
          '/special-considerations',
          '/first-days-in-or',
          '/practice-guidelines',
          '/diagnostics',
          '/regional-procedures',
        ]) {
          expect(tile(path), findsOneWidget);
        }
        expect(find.text('Coming soon'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
