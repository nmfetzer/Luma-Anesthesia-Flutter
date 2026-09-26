import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/crisis/crisis_reference_sections.dart';
import 'package:luma_anesthesia/crisis/crisis_repository.dart';
import 'package:luma_anesthesia/crisis/crisis_screen.dart';

class RevisionFixture implements CrisisDataSource {
  bool reviewer = true;
  final events = StreamController<void>.broadcast();
  @override
  Stream<void> get authChanges => events.stream;
  @override
  Future<CrisisAccess> access() async => CrisisAccess(reviewer: reviewer);
  @override
  Future<List<CrisisEntry>> catalog() async => [];
  @override
  Future<Map<String, dynamic>?> detail(String slug) async => reviewer
      ? {'_review_draft': true, 'reference_sections': sections}
      : {'summary': 'Published fixture remains available.'};
}

const sections = [
  {
    'id': 'a',
    'title': 'First discussion',
    'body_markdown': 'Distinct alpha content.'
  },
  {
    'id': 'b',
    'title': 'Second discussion',
    'body_markdown': 'Distinct beta content.'
  },
];

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  test('ten categories retain the requested order and support category search',
      () {
    expect(crisisCategories.keys, [
      'resuscitation',
      'neurological',
      'cardiac',
      'airway',
      'toxicity',
      'regional',
      'metabolic',
      'ob',
      'pediatric',
      'mental'
    ]);
    expect(
        const CrisisEntry(
                slug: 'cva', title: 'CVA / Stroke', category: 'neurological')
            .matches('neurological'),
        isTrue);
  });
  test('mobile table conversion retains values, qualifiers and source URLs',
      () {
    const input =
        '| Item | Detail |\n|---|---|\n| Example | ONLY selected patients [Label](https://example.org/label) |\n\nAfter table.';
    final output = stackReferenceTables(input);
    expect(output, contains('**Item:** Example'));
    expect(
        output,
        contains(
            '**Detail:** ONLY selected patients [Label](https://example.org/label)'));
    expect(output, contains('After table.'));
    expect(output, isNot(contains('|---|')));
  });
  testWidgets('readable sections filter by body text without checkboxes',
      (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: CrisisReferenceSections(sections: sections)))));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'beta');
    await t.pumpAndSettle();
    expect(find.text('First discussion'), findsNothing);
    expect(find.text('Second discussion'), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
    expect(t.takeException(), isNull);
    await t.enterText(find.byType(TextField), 'not-found');
    await t.pumpAndSettle();
    expect(find.textContaining('No matching sections'), findsOneWidget);
  });
  testWidgets(
      'published entry still labels new revision as draft and clears on signout',
      (t) async {
    final repo = RevisionFixture();
    addTearDown(repo.events.close);
    await t.pumpWidget(MaterialApp(
        home: CrisisDetailScreen(
            entry: const CrisisEntry(
                slug: 'cva',
                title: 'CVA / Stroke',
                category: 'neurological',
                isPublished: true),
            repository: repo)));
    await t.pumpAndSettle();
    expect(find.textContaining('OWNER REVIEW'), findsOneWidget);
    expect(find.text('First discussion'), findsOneWidget);
    repo.reviewer = false;
    repo.events.add(null);
    await t.pumpAndSettle();
    expect(find.textContaining('OWNER REVIEW'), findsNothing);
    expect(find.text('First discussion'), findsNothing);
    expect(find.text('Published fixture remains available.'), findsOneWidget);
  });
}
