import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/academy/academy_package.dart';
import 'package:luma_anesthesia/academy/academy_package_review_screen.dart';

// Nonclinical fixtures only. Paid course text and keys are not public assets.
Map<String, dynamic> fixture({String id = 'test', String version = 'v1'}) => {
  'schemaVersion': '1.0.0',
  'levelId': id,
  'version': version,
  'title': 'Example level',
  'scope': 'Nonclinical test fixture.',
  'sources': <String, dynamic>{},
  'decks': [
    {'id': 'd', 'title': 'Example deck', 'objective': 'Test navigation.'},
  ],
  'lessons': [
    {
      'id': 'l',
      'deckId': 'd',
      'title': 'Example lesson',
      'blocks': <dynamic>[],
    },
  ],
  'flashcards': [
    {
      'id': 'f',
      'deckId': 'd',
      'front': 'Example front',
      'back': 'Example back',
      'sourceIds': <String>[],
    },
  ],
  'practiceQuestions': [question('p')],
  'masteryCheckpoint': {
    'items': [question('m')],
  },
};
Map<String, dynamic> question(String id) => {
  'id': id,
  'deckId': 'd',
  'prompt': 'Choose example A.',
  'options': [
    for (final letter in ['A', 'B', 'C', 'D'])
      {'id': letter, 'text': 'Example $letter'},
  ],
  'correctOptionId': 'A',
  'rationale': 'Fixture rationale.',
  'distractorRationales': {
    'B': 'Fixture B.',
    'C': 'Fixture C.',
    'D': 'Fixture D.',
  },
  'sourceIds': <String>[],
  'lessonIds': ['l'],
};
void main() {
  test('parses canonical and legacy Cardiovascular top-level keys', () {
    final data = fixture();
    data['id'] = data.remove('levelId');
    data['contentVersion'] = data.remove('version');
    final p = AcademyPackage(data);
    expect(p.id, 'test');
    expect(p.version, 'v1');
  });
  test('invalid or duplicated assessment is rejected', () {
    final data = fixture();
    data['masteryCheckpoint'] = {
      'items': [question('p')],
    };
    expect(() => AcademyPackage(data), throwsFormatException);
  });
  test('local progress round-trips, scopes by version and deduplicates', () {
    final p = AcademyPackage(fixture());
    final progress = AcademyReviewProgress();
    progress.mark(p, 'lessons', 'l');
    progress.mark(p, 'lessons', 'l');
    progress.mark(p, 'cards', 'f');
    progress.score(p, 'checkpoint', 1, 1);
    final restored = AcademyReviewProgress.decode(progress.encode());
    expect(restored.seen(p, 'lessons'), {'l'});
    expect(restored.reviewGoalMet(p), isTrue);
    expect(
      restored.reviewGoalMet(AcademyPackage(fixture(version: 'v2'))),
      isFalse,
    );
  });
  test('best score does not drop; incomplete review is not complete', () {
    final p = AcademyPackage(fixture());
    final progress = AcademyReviewProgress();
    progress.score(p, 'checkpoint', 1, 1);
    progress.score(p, 'checkpoint', 0, 1);
    expect(progress.best(p, 'checkpoint'), 1);
    expect(progress.reviewGoalMet(p), isFalse);
    expect(() => progress.score(p, 'checkpoint', 2, 1), throwsArgumentError);
  });
  test('corrupt local storage is recoverable', () {
    expect(AcademyReviewProgress.decode('not json').data, isEmpty);
    expect(AcademyReviewProgress.decode('[]').data, isEmpty);
  });
  test('disabled purchases never grant entitlement', () async {
    expect(
      await AcademyPurchasesDisabled().hasServerVerifiedAcademyAccess('user'),
      isFalse,
    );
  });
  testWidgets('review path and deck navigation render at small width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final p = AcademyPackage(fixture());
    await tester.pumpWidget(
      MaterialApp(
        home: AcademyPackageReviewScreen(
          packages: [p],
          progress: AcademyReviewProgress(),
          save: () async {},
        ),
      ),
    );
    expect(find.text('Your A&P learning path'), findsOneWidget);
    await tester.tap(find.text('Example level'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Example deck'));
    await tester.pumpAndSettle();
    expect(find.text('Example lesson'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('checkpoint hides rationale until submit', (tester) async {
    final p = AcademyPackage(fixture());
    await tester.pumpWidget(
      MaterialApp(
        home: AcademyPackageReviewScreen(
          packages: [p],
          progress: AcademyReviewProgress(),
          save: () async {},
        ),
      ),
    );
    await tester.tap(find.text('Example level'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Attempt mastery checkpoint'));
    await tester.tap(find.text('Attempt mastery checkpoint'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A. Example A'));
    await tester.pump();
    expect(find.text('Fixture rationale.'), findsNothing);
    await tester.tap(find.text('Submit answers'));
    await tester.pumpAndSettle();
    expect(find.text('Fixture rationale.'), findsOneWidget);
    expect(find.text('1/1'), findsOneWidget);
  });
}
