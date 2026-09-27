import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/ce/ce_demo_repository.dart';
import 'package:luma_anesthesia/ce/ce_demo_data.dart';
import 'package:luma_anesthesia/ce/ce_screen.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  test(
      'preview forms are 15 questions with seven-question overlap and durable hints',
      () async {
    final repo = DemoCeRepository();
    await repo.call('demo_unlock');
    await repo.call('read');
    final forms = <Set<String>>[];
    for (int n = 0; n < 3; n++) {
      final a = await repo.call('quiz');
      final questions = a['questions'] as List;
      expect(questions.length, 15);
      forms.add(questions.map((q) => q['question_id'] as String).toSet());
      final hint = await repo
          .call('hint', {'question_id': questions.first['question_id']});
      expect((hint['eliminated'] as List).length, 2);
      expect(
          (hint['eliminated'] as List)
              .contains(questions.first['correct_choice']),
          false);
      final resume = await repo.call('quiz');
      expect(resume['attempt_id'], a['attempt_id']);
      expect((resume['hints'] as Map).length, 1);
      await repo.call('submit', {
        'answers': {
          for (final q in questions)
            q['question_id']: ['a', 'b', 'c', 'd']
                .firstWhere((c) => c != q['correct_choice']),
        }
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
      }
    });
    expect(result['score'], 15);
    final completion =
        await repo.call('evaluate', {'location': 'Preview city'});
    expect(completion['module_credits'], 0);
    expect(completion['course_complete'], false);
  });
  for (final width in [375.0, 1280.0]) {
    testWidgets('course catalog and learner form fit at $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
          MaterialApp(home: CeCourseScreen(repository: DemoCeRepository())));
      await tester.pumpAndSettle();
      expect(find.text('A Medication Review for the Experienced CRNA'),
          findsOneWidget);
      expect(find.text('20.00 MAC Ed CE credits'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final start = find.text('Preview the post-purchase experience');
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pumpAndSettle();
      expect(find.text('Your learner details'), findsOneWidget);
      expect(find.text('AANA ID (optional)'), findsOneWidget);
      final save = find.text('Save details & view modules');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text('This field is required'), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  }
}
