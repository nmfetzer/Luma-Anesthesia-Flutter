import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/ce/ce_demo_repository.dart';
import 'package:luma_anesthesia/ce/ce_demo_data.dart';
import 'package:luma_anesthesia/ce/ce_screen.dart';
import 'package:luma_anesthesia/ce/ce_records_screen.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  test('preview forms are 15 questions with seven-question overlap and durable hints', () async {
    final repo = DemoCeRepository();
    await repo.call('demo_unlock');
    await repo.call('read');
    final forms = <Set<String>>[];
    for (int n = 0; n < 3; n++) {
      final a = await repo.call('quiz');
      final questions = a['questions'] as List;
      expect(questions.length, 15);
      forms.add(questions.map((q) => q['question_id'] as String).toSet());
      final hint = await repo.call('hint', {
        'question_id': questions.first['question_id'],
      });
      expect((hint['eliminated'] as List).length, 2);
      expect(
        (hint['eliminated'] as List).contains(
          questions.first['correct_choice'],
        ),
        false,
      );
      final resume = await repo.call('quiz');
      expect(resume['attempt_id'], a['attempt_id']);
      expect((resume['hints'] as Map).length, 1);
      await repo.call('submit', {
        'answers': {
          for (final q in questions)
            q['question_id']: [
              'a',
              'b',
              'c',
              'd',
            ].firstWhere((c) => c != q['correct_choice']),
        },
      });
    }
    expect(forms[0].intersection(forms[1]).length, 7);
    expect(forms[0].intersection(forms[2]).length, 7);
    expect(forms[1].intersection(forms[2]).length, 7);
    await expectLater(repo.call('quiz'), throwsException);
  });
  test('preview completion never earns official credit', () async {
    final repo = DemoCeRepository();
    await expectLater(repo.call('evaluate'), throwsException);
    await repo.call('read');
    await repo.call('quiz');
    final result = await repo.call('submit', {
      'answers': {
        for (final q in demoQuestions.take(15))
          q['question_id']: q['correct_choice'],
      },
    });
    expect(result['score'], 15);
    final completion = await repo.call('evaluate', {
      'location': 'Preview city',
    });
    expect(completion['module_credits'], 0);
    expect(completion['course_complete'], false);
  });
  for (final width in [375.0, 1280.0]) {
    testWidgets('course catalog and learner form fit at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(home: CeCourseScreen(repository: DemoCeRepository())),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('A Medication Review for the Experienced CRNA'),
        findsOneWidget,
      );
      expect(find.text('20.00 MAC Ed CE credits'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final start = find.text('Preview the post-purchase experience');
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pumpAndSettle();
      expect(find.text('Your course registration'), findsOneWidget);
      expect(find.text('AANA ID (optional)'), findsOneWidget);
      final save = find.text('Save details & view modules');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text('This field is required'), findsNWidgets(3));
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextFormField).at(0), 'Catalog Tester');
      await tester.enterText(find.byType(TextFormField).at(1), 'CRNA');
      await tester.enterText(find.byType(TextFormField).at(3), 'Rochester, NY');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.textContaining('11 of 11 modules loaded'), findsOneWidget);
      expect(find.text('More modules to come'), findsNothing);
      expect(find.text('REMAINING 0 MODULES'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  test(
    'Module 2 hints and progress are isolated; registration is shared',
    () async {
      final repo = DemoCeRepository();
      await repo.call('demo_unlock');
      await repo.call('profile', {
        'module_id': 'course_1_module_1',
        'full_name': 'Registered Learner',
        'credentials': 'CRNA',
        'location': 'Rochester, NY',
      });
      await repo.call('read');
      final ketamine = await repo.call('quiz');
      const args = {'module_id': 'course_1_module_2'};
      expect((await repo.call('access', args))['read'], false);
      await repo.call('read', args);
      final glp = await repo.call('quiz', args);
      expect(glp['number'], 1);
      for (final q in glp['questions'] as List) {
        final hint = await repo.call('hint', {
          ...args,
          'question_id': q['question_id'],
        });
        expect(hint['eliminated'], q['hint']['eliminate_choices']);
        expect(
          (hint['eliminated'] as List).contains(q['correct_choice']),
          false,
        );
      }
      await repo.call('submit', {
        ...args,
        'answers': {
          for (final q in glp['questions'] as List)
            q['question_id']: q['correct_choice'],
        },
      });
      final result = await repo.call('evaluate', {
        ...args,
        'attestation': true,
      });
      expect(result['learner']['full_name'], 'Registered Learner');
      expect(result['location'], 'Rochester, NY');
      expect(result['module_id'], 'course_1_module_2');
      expect(result['module_credits'], 0);
      expect((await repo.call('quiz'))['attempt_id'], ketamine['attempt_id']);
      expect((await repo.call('records'))['total'], 0);
      expect(
        (await repo.call('records', {'include_preview': true}))['total'],
        1,
      );
      expect(
        (await repo.call('records', {
          'include_preview': true,
        }))['rows'][0]['module_id'],
        'course_1_module_2',
      );
    },
  );
  test(
    'Module 3 has its own bank, hints, evaluation and linked records',
    () async {
      final repo = DemoCeRepository();
      await repo.call('demo_unlock');
      await repo.call('profile', {
        'full_name': 'Module Three Learner',
        'credentials': 'CRNA',
        'location': 'Rochester, NY',
      });
      final catalog = await repo.call('catalog');
      final modules = catalog['modules'] as List;
      final metadata = modules.singleWhere(
        (m) => m['id'] == 'course_1_module_3',
      );
      expect(metadata['objectives'].length, 5);
      expect(metadata['evaluation_items'].length, 5);
      const m2 = {'module_id': 'course_1_module_2'};
      const m3 = {'module_id': 'course_1_module_3'};
      await repo.call('read', m2);
      final prior = await repo.call('quiz', m2);
      expect((await repo.call('access', m3))['read'], false);
      await repo.call('read', m3);
      final attempt = await repo.call('quiz', m3);
      expect(attempt['questions'].length, 15);
      for (final q in attempt['questions'] as List) {
        expect(q['module_id'], 'course_1_module_3');
        final hint = await repo.call('hint', {
          ...m3,
          'question_id': q['question_id'],
        });
        expect(hint['eliminated'].length, 2);
        expect(
          (hint['eliminated'] as List).contains(q['correct_choice']),
          false,
        );
      }
      final score = await repo.call('submit', {
        ...m3,
        'answers': {
          for (final q in attempt['questions'] as List)
            q['question_id']: q['correct_choice'],
        },
      });
      expect(score['score'], 15);
      final complete = await repo.call('evaluate', {
        ...m3,
        'ratings': List.filled(10, 1),
        'learned': 'Pediatric re-sedation differs from initial titration.',
        'barriers': 'None',
        'attestation': true,
      });
      expect(complete['module_id'], 'course_1_module_3');
      expect(complete['learner']['full_name'], 'Module Three Learner');
      expect(complete['module_credits'], 0);
      expect((await repo.call('quiz', m2))['attempt_id'], prior['attempt_id']);
      expect((await repo.call('records'))['total'], 0);
      final ledger = await repo.call('records', {'include_preview': true});
      expect(ledger['rows'][0]['module_id'], 'course_1_module_3');
    },
  );
  test('CSV protects formula cells and preserves structured records', () {
    final csv = ceRecordsCsv([
      {
        'full_name': ' =HYPERLINK("bad")',
        'evaluation': {
          'ratings': [1, 2],
        },
      },
    ]);
    expect(csv, contains("' =HYPERLINK"));
    expect(csv, contains('""ratings""'));
    expect(csv, contains('full_course_awarded'));
  });
}
