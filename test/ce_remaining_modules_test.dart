import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/ce/ce_demo_data.dart';
import 'package:luma_anesthesia/ce/ce_demo_repository.dart';

void main() {
  test(
    'Complete catalog preserves 20 MAC Ed / 17.5 pharmacology / 2.5 pain',
    () {
      final modules = demoCatalog['modules'] as List;
      expect(modules.length, 11);
      for (final entry in {
        'credits': 20,
        'pharmacology_credits': 17.5,
        'pain_credits': 2.5,
      }.entries) {
        expect(
          modules.fold<num>(0, (sum, m) => sum + (m[entry.key] as num)),
          entry.value,
        );
      }
      for (var n = 5; n <= 11; n++) {
        final bank = demoRemainingQuestions['course_1_module_$n'] as List;
        expect(bank.length, 25);
        for (final q in bank) {
          final eliminated = q['hint']['eliminate_choices'] as List;
          expect(eliminated.toSet().length, 2);
          expect(eliminated.contains(q['correct_choice']), false);
          expect(q['source_urls'], isNotEmpty);
          expect(q['learning_objective_ids'], isNotEmpty);
        }
      }
    },
  );
  test('Seven modules share registration, maintain independent progress, and link evaluations', () async {
    final repo = DemoCeRepository();
    await repo.call('demo_unlock');
    await repo.call('profile', {
      'full_name': 'Final Modules Tester',
      'credentials': 'CRNA',
      'aana_id': '',
      'location': 'Rochester, NY',
    });
    final earlier = <String, String>{};
    for (var n = 1; n <= 4; n++) {
      final args = {'module_id': 'course_1_module_$n'};
      await repo.call('read', args);
      earlier[args['module_id']!] = (await repo.call(
        'quiz',
        args,
      ))['attempt_id'];
    }
    for (var n = 5; n <= 11; n++) {
      final args = {'module_id': 'course_1_module_$n'};
      expect((await repo.call('access', args))['read'], false);
      await repo.call('read', args);
      final attempt = await repo.call('quiz', args);
      expect(attempt['questions'].length, 15);
      for (final q in attempt['questions'] as List) {
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
      final score = await repo.call('submit', {
        ...args,
        'answers': {
          for (final q in attempt['questions'] as List)
            q['question_id']: q['correct_choice'],
        },
      });
      expect(score['score'], 15);
      final complete = await repo.call('evaluate', {
        ...args,
        'ratings': List.filled(10, 1),
        'learned': 'Individualized drug selection.',
        'barriers': 'None',
        'attestation': true,
      });
      expect(complete['learner']['full_name'], 'Final Modules Tester');
      expect(complete['location'], 'Rochester, NY');
      expect(complete['module_credits'], 0);
      expect(complete['module_id'], args['module_id']);
    }
    for (final entry in earlier.entries) {
      expect(
        (await repo.call('quiz', {'module_id': entry.key}))['attempt_id'],
        entry.value,
      );
    }
    expect((await repo.call('records'))['total'], 0);
    expect((await repo.call('records', {'include_preview': true}))['total'], 7);
  });
}
