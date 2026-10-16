import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/academy/academy_repository.dart';
import 'package:luma_anesthesia/academy/academy_screen.dart';

void main() {
  test(
    'No caller-supplied account ID and rejects anonymous requests',
    () async {
      var called = false;
      final repo = AcademyRepository.test((_, __) async {
        called = true;
        return {};
      }, () => null);
      await expectLater(repo.progress(), throwsStateError);
      expect(called, false);
    },
  );
  test('Account switch rejects an in-flight response', () async {
    var user = 'A';
    final pending = Completer<dynamic>();
    final repo = AcademyRepository.test((_, __) => pending.future, () => user);
    final request = repo.catalog();
    user = 'B';
    pending.complete({'hasAccess': true});
    await expectLater(request, throwsStateError);
  });
  test('Marks contain version and item but never UID or score', () async {
    Map<String, dynamic>? params;
    final repo = AcademyRepository.test((name, args) async {
      expect(name, 'academy_mark');
      params = args;
      return {'saved': true};
    }, () => 'user');
    await repo.mark('I.A.1', 'v2', 'cards', 'F1');
    expect(params, {
      'p_level': 'I.A.1',
      'p_version': 'v2',
      'p_kind': 'cards',
      'p_item': 'F1',
    });
  });
  test(
    'Submission retries retain attempt token and send selections, not grades',
    () async {
      final requests = <Map<String, dynamic>>[];
      final repo = AcademyRepository.test((_, args) async {
        requests.add(args);
        return {'correct': 1};
      }, () => 'user');
      await repo.submit('I.A.1', 'v2', 'checkpoint', 'all', 'token', {
        'Q1': 'A',
      });
      await repo.submit('I.A.1', 'v2', 'checkpoint', 'all', 'token', {
        'Q1': 'A',
      });
      expect(requests[0], requests[1]);
      expect(requests[0].containsKey('correct'), false);
      expect(requests[0].containsKey('user_id'), false);
    },
  );
  test(
    'Progress is version isolated, deduplicated, and best score retained',
    () {
      final progress = AcademyProgress({
        'marks': [
          {
            'levelId': 'I.A.1',
            'version': 'v1',
            'kind': 'cards',
            'itemId': 'old',
          },
          {
            'levelId': 'I.A.1',
            'version': 'v2',
            'kind': 'cards',
            'itemId': 'new',
          },
          {
            'levelId': 'I.A.1',
            'version': 'v2',
            'kind': 'cards',
            'itemId': 'new',
          },
        ],
        'attempts': [
          {
            'levelId': 'I.A.1',
            'version': 'v2',
            'kind': 'checkpoint',
            'correct': 23,
          },
          {
            'levelId': 'I.A.1',
            'version': 'v2',
            'kind': 'checkpoint',
            'correct': 15,
          },
        ],
      });
      expect(progress.seen('I.A.1', 'v2', 'cards'), {'new'});
      expect(progress.bestCheckpoint('I.A.1', 'v2')?['correct'], 23);
      expect(progress.bestCheckpoint('I.A.1', 'v1'), null);
    },
  );
  testWidgets(
    'Unentitled account sees locked catalog without fetching content',
    (tester) async {
      final calls = <String>[];
      final repo = AcademyRepository.test((name, _) async {
        calls.add(name);
        return {
          'hasAccess': false,
          'levels': [
            {
              'id': 'I.A.1',
              'version': 'v2',
              'position': 1,
              'title': 'Cardiovascular',
              'deckCount': 9,
              'cardCount': 54,
              'lessonCount': 18,
            },
          ],
        };
      }, () => 'user');
      await tester.pumpWidget(
        MaterialApp(home: AcademyLearningHome(repository: repo)),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('access is not active'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(calls, ['academy_catalog']);
      await tester.tap(find.text('Cardiovascular'));
      expect(calls, ['academy_catalog']);
    },
  );
  testWidgets(
    'Mobile layout shows all sections and refreshes shared progress',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var progressCalls = 0;
      final repo = AcademyRepository.test((name, _) async {
        if (name == 'academy_progress') {
          progressCalls++;
          return {'marks': [], 'attempts': []};
        }
        return {
          'hasAccess': true,
          'accessKind': 'owner_review',
          'levels': List.generate(
            9,
            (i) => {
              'id': 'I.A.${i + 1}',
              'version': 'v2',
              'position': i + 1,
              'title': 'Section ${i + 1}',
              'deckCount': 12,
              'cardCount': 48,
              'lessonCount': 24,
            },
          ),
        };
      }, () => 'user');
      await tester.pumpWidget(
        MaterialApp(home: AcademyLearningHome(repository: repo)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Refresh account progress'));
      await tester.pumpAndSettle();
      expect(progressCalls, 2);
      await tester.scrollUntilVisible(find.text('Section 9'), 300);
      expect(find.text('Section 9'), findsOneWidget);
    },
  );
}
