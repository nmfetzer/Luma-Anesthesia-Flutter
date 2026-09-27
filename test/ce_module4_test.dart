import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/ce/ce_demo_repository.dart';
import 'package:luma_anesthesia/ce/ce_demo_data.dart';

void main() {
  test('Module 4 has 25 clinical questions and valid two-choice hints', () {
    expect(demoNmbaQuestions.length, 25);
    expect(demoCatalog['modules'].length, 11);
    for (final q in demoNmbaQuestions) {
      expect(q['module_id'], 'course_1_module_4');
      final eliminated = q['hint']['eliminate_choices'] as List;
      expect(eliminated.toSet().length, 2);
      expect(eliminated.contains(q['correct_choice']), false);
      expect(q['source_urls'], isNotEmpty);
    }
  });
  test('Module 4 inherits registration without changing Modules 1-3', () async {
    final repo = DemoCeRepository();
    await repo.call('demo_unlock');
    await repo.call('profile', {
      'full_name': 'Module Four Learner',
      'credentials': 'CRNA',
      'aana_id': '',
      'location': 'Rochester, NY',
    });
    final earlier = <String, String>{};
    for (var n = 1; n <= 3; n++) {
      final id = 'course_1_module_$n';
      await repo.call('read', {'module_id': id});
      final a = await repo.call('quiz', {'module_id': id});
      earlier[id] = a['attempt_id'];
    }
    const args = {'module_id': 'course_1_module_4'};
    expect((await repo.call('access', args))['read'], false);
    await repo.call('read', args);
    final a = await repo.call('quiz', args);
    expect(a['questions'].length, 15);
    for (final q in a['questions'] as List) {
      final h = await repo.call('hint', {
        ...args,
        'question_id': q['question_id'],
      });
      expect(h['eliminated'], q['hint']['eliminate_choices']);
      expect((h['eliminated'] as List).contains(q['correct_choice']), false);
    }
    expect((await repo.call('quiz', args))['hints'].length, 15);
    final score = await repo.call('submit', {
      ...args,
      'answers': {
        for (final q in a['questions'] as List)
          q['question_id']: q['correct_choice'],
      },
    });
    expect(score['score'], 15);
    final complete = await repo.call('evaluate', {
      ...args,
      'ratings': List.filled(10, 1),
      'learned': 'Use measured block depth for reversal.',
      'barriers': 'None',
      'attestation': true,
    });
    expect(complete['learner']['full_name'], 'Module Four Learner');
    expect(complete['location'], 'Rochester, NY');
    expect(complete['module_credits'], 0);
    expect(complete['module_id'], 'course_1_module_4');
    for (final prior in earlier.entries) {
      expect(
        (await repo.call('quiz', {'module_id': prior.key}))['attempt_id'],
        prior.value,
      );
    }
    expect((await repo.call('records'))['total'], 0);
    final records = await repo.call('records', {'include_preview': true});
    expect(records['rows'][0]['module_id'], 'course_1_module_4');
  });
}
