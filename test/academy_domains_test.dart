import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/academy/academy_repository.dart';
import 'package:luma_anesthesia/academy/academy_screen.dart';

void main() {
  for (final width in [375.0, 1280.0]) {
    testWidgets('NCE domains and topic navigation at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = AcademyRepository.test((name, args) async {
        if (name == 'academy_progress') return {'marks': [], 'attempts': []};
        if (name == 'academy_catalog') {
          return {
            'hasAccess': true,
            'accessKind': 'owner_review',
            'levels': [
              for (final id in ['I.A.1', 'I.C.1', 'I.B.1'])
                {
                  'id': id,
                  'version': 'test',
                  'position': id == 'I.A.1' ? 1 : 10,
                  'title': id == 'I.A.1'
                      ? 'A&P fixture'
                      : id == 'I.C.1'
                      ? 'Pharmacology fixture'
                      : 'Pathophysiology fixture',
                  'deckCount': 2,
                  'cardCount': 0,
                  'lessonCount': 0,
                },
            ],
          };
        }
        if (name == 'academy_level') {
          expect(args['p_level'], 'I.B.1');
          return {
            'levelId': 'I.B.1',
            'version': 'test',
            'domainTitle': 'Pathophysiology',
            'topics': [
              {'id': 'I.B.1.a', 'title': 'First outline topic'},
              {'id': 'I.B.1.b', 'title': 'Second outline topic'},
            ],
            'decks': [
              {'id': 'D1', 'topicId': 'I.B.1.a', 'title': 'First mini-deck'},
              {'id': 'D2', 'topicId': 'I.B.1.b', 'title': 'Second mini-deck'},
            ],
            'lessons': [],
            'flashcards': [],
            'practiceQuestions': [],
            'masteryCheckpoint': {'items': []},
            'documents': [],
          };
        }
        throw StateError('Unexpected RPC: $name');
      }, () => 'synthetic-owner');
      await tester.pumpWidget(
        MaterialApp(home: AcademyLearningHome(repository: repo)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Your NCE learning path'), findsOneWidget);
      expect(find.text('Anatomy & Physiology'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Pharmacology fixture'), 200);
      expect(find.text('Pharmacology'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Pathophysiology fixture'),
        200,
      );
      await tester.ensureVisible(
        find.ancestor(
          of: find.text('Pathophysiology fixture'),
          matching: find.byType(ListTile),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pathophysiology'), findsOneWidget);
      await tester.tap(find.text('Pathophysiology fixture'));
      await tester.pumpAndSettle();
      expect(find.text('I.B.1  /  PATHOPHYSIOLOGY'), findsOneWidget);
      expect(find.text('I.B.1.a  /  First outline topic'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('I.B.1.b  /  Second outline topic'),
        200,
      );
      expect(find.text('I.B.1.b  /  Second outline topic'), findsOneWidget);
      await tester.ensureVisible(
        find.ancestor(
          of: find.text('2. Second mini-deck'),
          matching: find.byType(ExpansionTile),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('2. Second mini-deck'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Recall this deck'), 150);
      await tester.pumpAndSettle();
      expect(find.text('Practice this deck'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
