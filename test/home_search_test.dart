import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/home/home_search.dart';
import 'package:luma_anesthesia/home/home_screen.dart';
import 'package:luma_anesthesia/home/home_tile.dart';
import 'package:luma_anesthesia/models/medication.dart';
import 'package:luma_anesthesia/special_considerations/special_consideration.dart';

const sections = [
  HomeSearchSection(pathophysiologyTitle, '/special-considerations',
      keywords: 'special considerations'),
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
    })
  ],
  conditions: const [
    SpecialConsiderationEntry(
        slug: 'aortic-stenosis',
        title: 'Aortic Stenosis',
        category: 'Cardiac',
        reviewStatus: 'published',
        searchTags: ['AS']),
    SpecialConsiderationEntry(
        slug: 'draft', title: 'Draft condition', category: 'Cardiac'),
  ],
);

Future<void> openSearch(WidgetTester tester,
    {Future<HomeSearchData> Function()? loader}) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
        body: HomeSearch(
            sections: sections, loadData: loader ?? () async => data)),
    routes: {
      '/special-considerations': (_) =>
          const Scaffold(body: Text('Condition library opened'))
    },
  ));
  await tester.tap(find.byType(SearchBar));
  await tester.pumpAndSettle();
}

void main() {
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
    expect(find.text('$pathophysiologyTitle · 1 results'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'draft');
    await tester.pumpAndSettle();
    expect(find.text('Draft condition'), findsNothing);
    expect(find.textContaining('No matches yet'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '');
    await tester.pumpAndSettle();
    expect(find.text('Crisis Hub'), findsOneWidget);
  });

  testWidgets('old search alias opens newly named section', (tester) async {
    await openSearch(tester);
    await tester.enterText(
        find.byType(TextField).last, 'special considerations');
    await tester.pumpAndSettle();
    expect(find.text(pathophysiologyTitle), findsOneWidget);
    await tester.tap(find.text(pathophysiologyTitle));
    await tester.pumpAndSettle();
    expect(find.text('Condition library opened'), findsOneWidget);
  });

  testWidgets('section search remains usable if library loading fails',
      (tester) async {
    await openSearch(tester, loader: () async => throw StateError('Offline'));
    await tester.enterText(find.byType(TextField).last, 'patho');
    await tester.pumpAndSettle();
    expect(find.text(pathophysiologyTitle), findsOneWidget);
    expect(find.text('Some library results could not load.'), findsOneWidget);
  });

  for (final size in [
    const Size(375, 812),
    const Size(768, 1024),
    const Size(1280, 800)
  ]) {
    testWidgets('swapped tiles and full new title fit $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump(const Duration(milliseconds: 100));
      Finder tile(String route) =>
          find.byWidgetPredicate((w) => w is HomeTile && w.data.route == route);
      expect(
          tester.getTopLeft(tile('/crisis-guidelines')).dy,
          lessThan(tester.getTopLeft(tile('/special-considerations')).dy +
              (size.width >= 1024 ? 1 : 0)));
      expect(tester.getTopLeft(tile('/luma-academy')).dy,
          greaterThan(tester.getTopLeft(tile('/practice-guidelines')).dy));
      expect(
          find.text(pathophysiologyTitle, findRichText: true), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
