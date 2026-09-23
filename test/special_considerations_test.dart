import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/special_considerations/special_consideration.dart';
import 'package:luma_anesthesia/special_considerations/special_consideration_detail_screen.dart';
import 'package:luma_anesthesia/special_considerations/special_consideration_repository.dart';
import 'package:luma_anesthesia/special_considerations/special_considerations_screen.dart';

const draft = SpecialConsiderationEntry(
  slug: 'draft-condition',
  title: 'Draft condition',
  category: 'Cardiac',
  searchTags: ['alternate name'],
);
const published = SpecialConsiderationEntry(
  slug: 'published-condition',
  title: 'Published condition',
  category: 'Hematology & Coagulation',
  reviewStatus: 'published',
  isGuestPreview: true,
);
const sample = SpecialConsiderationDetail(
  subtitle: 'Testing only. Not a clinical record.',
  sections: {
    'snapshot': 'A **formatted** test paragraph.',
    'pathophysiology': '- First test bullet\n- Second test bullet',
    'preop_considerations': 'Test preoperative content',
    'airway_access_positioning': 'Test airway content',
    'intraop_management': 'Test intraoperative content',
    'emergence_postop': 'Test recovery content',
    'what_could_go_wrong': 'Test complication content',
    'pearls': 'Test pearl content',
  },
  citations: [
    {'label': 'Example reference', 'url': 'https://example.com'},
  ],
  crisisTopics: ['Example crisis topic'],
);

class FakeRepository implements SpecialConsiderationDataSource {
  List<SpecialConsiderationEntry> entries = [draft, published];
  SpecialConsiderationDetail? body = sample;
  String? premium;
  bool fail = false;
  int detailRequests = 0;
  int deepRequests = 0;
  @override
  bool hasAccount = false;
  final controller = StreamController<void>.broadcast();
  @override
  Stream<void> get authChanges => controller.stream;
  @override
  Future<List<SpecialConsiderationEntry>> catalog() async {
    if (fail) throw StateError('Offline');
    return entries;
  }

  @override
  Future<SpecialConsiderationDetail?> detail(String slug) async {
    detailRequests++;
    if (fail) throw StateError('Offline');
    return body;
  }

  @override
  Future<String?> deepDive(String slug) async {
    deepRequests++;
    return premium;
  }
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('catalog search handles title, category, tags, and whitespace', () {
    expect(draft.matches('  ALTERNATE NAME '), isTrue);
    expect(draft.matches('cardiac'), isTrue);
    expect(draft.matches('absent'), isFalse);
    expect(draft.isPublished, isFalse);
  });

  test('JSON parsing defaults to review pending', () {
    final entry = SpecialConsiderationEntry.fromJson({
      'slug': 'test',
      'title': 'Test',
      'category': 'Cardiac',
    });
    expect(entry.isPublished, isFalse);
    expect(entry.isGuestPreview, isFalse);
    expect(entry.searchTags, isEmpty);
  });

  testWidgets(
      'full twelve-category catalog remains searchable beyond 200 entries',
      (tester) async {
    final repo = FakeRepository()
      ..entries = [
        for (final category in specialConsiderationCategoryOrder)
          for (var i = 0; i < 20; i++)
            SpecialConsiderationEntry(
              slug: '$category-$i',
              title: '$category example $i',
              category: category,
              searchTags: [i == 19 ? 'last entry' : 'fixture'],
            ),
      ];
    addTearDown(repo.controller.close);
    await tester.pumpWidget(MaterialApp(
      home: SpecialConsiderationsScreen(repository: repo),
    ));
    await tester.pumpAndSettle();
    expect(find.text('240 entries · 12 categories'), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
    await tester.enterText(
      find.byType(TextField),
      'Ethical & Situational example 19',
    );
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(ListTile, 'Ethical & Situational example 19'),
      findsOneWidget,
    );
    expect(find.textContaining('Review pending'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Categories'), findsOneWidget);
    await tester.ensureVisible(find.text('Pulmonary'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pulmonary'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'last entry');
    await tester.pumpAndSettle();
    expect(find.text('Pulmonary example 19'), findsOneWidget);
    expect(find.text('Ethical & Situational example 19'), findsNothing);
  });

  testWidgets('catalog categories, search, draft detail and back navigation',
      (tester) async {
    final repo = FakeRepository();
    addTearDown(repo.controller.close);
    await tester.pumpWidget(MaterialApp(
      home: SpecialConsiderationsScreen(repository: repo),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Cardiac'), findsOneWidget);
    expect(find.text('Hematology & Coagulation'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'alternate');
    await tester.pumpAndSettle();
    expect(find.text('Draft condition'), findsOneWidget);
    expect(find.text('Published condition'), findsNothing);
    await tester.tap(find.text('Draft condition'));
    await tester.pumpAndSettle();
    expect(find.text('Clinical review pending'), findsOneWidget);
    expect(repo.detailRequests, 0);
    expect(repo.deepRequests, 0);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Search results'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'not found');
    await tester.pumpAndSettle();
    expect(find.textContaining('No matching conditions'), findsOneWidget);
  });

  testWidgets('network error retries successfully', (tester) async {
    final repo = FakeRepository()..fail = true;
    addTearDown(repo.controller.close);
    await tester.pumpWidget(MaterialApp(
      home: SpecialConsiderationsScreen(repository: repo),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Unable to load the library'), findsOneWidget);
    repo.fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Categories'), findsOneWidget);
  });

  testWidgets('empty catalog is explicit', (tester) async {
    final repo = FakeRepository()..entries = [];
    addTearDown(repo.controller.close);
    await tester.pumpWidget(MaterialApp(
      home: SpecialConsiderationsScreen(repository: repo),
    ));
    await tester.pumpAndSettle();
    expect(find.text('The library is being prepared'), findsOneWidget);
  });

  testWidgets('published preview renders all sections without fetching premium',
      (tester) async {
    final repo = FakeRepository();
    addTearDown(repo.controller.close);
    await tester.pumpWidget(MaterialApp(
      home:
          SpecialConsiderationDetailScreen(entry: published, repository: repo),
    ));
    await tester.pumpAndSettle();
    for (final label in specialConsiderationSections.values) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('References'), findsOneWidget);
    expect(find.text('Example reference'), findsOneWidget);
    expect(repo.deepRequests, 0);
  });

  testWidgets('denied basic request reveals no content', (tester) async {
    final repo = FakeRepository()..body = null;
    addTearDown(repo.controller.close);
    await tester.pumpWidget(MaterialApp(
      home:
          SpecialConsiderationDetailScreen(entry: published, repository: repo),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Sign in to read this entry'), findsOneWidget);
    expect(find.text('At a glance'), findsNothing);
  });

  testWidgets('sign out removes protected content and refetches',
      (tester) async {
    final repo = FakeRepository()..hasAccount = true;
    addTearDown(repo.controller.close);
    await tester.pumpWidget(MaterialApp(
      home:
          SpecialConsiderationDetailScreen(entry: published, repository: repo),
    ));
    await tester.pumpAndSettle();
    expect(find.text('At a glance'), findsOneWidget);
    repo.hasAccount = false;
    repo.body = null;
    repo.controller.add(null);
    await tester.pumpAndSettle();
    expect(find.text('At a glance'), findsNothing);
    expect(find.text('Sign in to read this entry'), findsOneWidget);
  });

  testWidgets('deep dive loads only on request and is cleared on sign out',
      (tester) async {
    final repo = FakeRepository()
      ..hasAccount = true
      ..premium = 'Premium test content';
    addTearDown(repo.controller.close);
    await tester.pumpWidget(MaterialApp(
      home:
          SpecialConsiderationDetailScreen(entry: published, repository: repo),
    ));
    await tester.pumpAndSettle();
    expect(repo.deepRequests, 0);
    await tester.ensureVisible(find.text('Open deep dive'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open deep dive'));
    await tester.pumpAndSettle();
    expect(repo.deepRequests, 1);
    expect(find.text('Premium test content'), findsOneWidget);
    repo.hasAccount = false;
    repo.controller.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Premium test content'), findsNothing);
  });

  testWidgets('unavailable deep dive shows access message without prose',
      (tester) async {
    final repo = FakeRepository()..hasAccount = true;
    addTearDown(repo.controller.close);
    await tester.pumpWidget(MaterialApp(
      home:
          SpecialConsiderationDetailScreen(entry: published, repository: repo),
    ));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Open deep dive'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open deep dive'));
    await tester.pumpAndSettle();
    expect(
        find.textContaining('not available to this account'), findsOneWidget);
  });

  testWidgets('small display and large text do not overflow', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = FakeRepository();
    addTearDown(repo.controller.close);
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1.8)),
        child: child!,
      ),
      home: SpecialConsiderationsScreen(repository: repo),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Cardiac'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cardiac'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cardiac'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Draft condition'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Draft condition'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Draft condition'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
