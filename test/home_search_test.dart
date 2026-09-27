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
  HomeSearchSection('Luma Academy', '/luma-academy'),
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
      expect(find.text('Aortic Stenosis'), findsNothing);
      expect(find.textContaining('No matches yet'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, 'draft');
      await tester.pumpAndSettle();
      expect(find.text('Draft condition'), findsNothing);
      expect(find.textContaining('No matches yet'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, '');
      await tester.pumpAndSettle();
      expect(find.text('Crisis Hub'), findsOneWidget);
    },
  );

  testWidgets('deferred aliases do not reopen hidden content', (tester) async {
    await openSearch(tester);
    await tester.enterText(
      find.byType(TextField).last,
      'special considerations',
    );
    await tester.pumpAndSettle();
    expect(find.text(pathophysiologyTitle), findsNothing);
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
  });

  for (final size in [
    const Size(375, 812),
    const Size(768, 1024),
    const Size(1280, 800),
  ]) {
    testWidgets('five launch tiles replace deferred areas at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump(const Duration(milliseconds: 100));
      Finder tile(String route) =>
          find.byWidgetPredicate((w) => w is HomeTile && w.data.route == route);
      expect(find.byType(HomeTile), findsNWidgets(5));
      for (final path in [
        '/drug-library',
        '/crisis-guidelines',
        '/vasopressors-infusions',
        '/ce-halo',
        '/quick-references',
      ]) {
        expect(tile(path), findsOneWidget);
      }
      expect(tile('/special-considerations'), findsNothing);
      expect(tile('/diagnostics'), findsNothing);
      expect(find.text('Coming soon'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
