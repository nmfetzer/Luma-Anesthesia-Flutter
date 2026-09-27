import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/ce/ce_course3_demo_data.dart';
import 'package:luma_anesthesia/ce/ce_demo_repository.dart';
import 'package:luma_anesthesia/ce/ce_repository.dart';

void main() {
  test('Course 3 has exact approval, 11 modules and 275 safe hints', () {
    final repo = SupabaseCeRepository(courseNumber: 3);
    expect(repo.courseId, '1047243');
    expect(repo.courseTitle, 'Legal Essentials for the CRNA');
    expect(repo.hasDesignatedCredits, false);
    expect(demoCourse3Catalog.containsKey('pharmacology_statement'), false);
    expect(demoCourse3Catalog.containsKey('pain_statement'), false);
    final modules = demoCourse3Catalog['modules'] as List;
    expect(modules.length, 11);
    expect(modules.fold<num>(0, (sum, m) => sum + (m['credits'] as num)), 20);
    expect(modules[8]['credits'], 1.75);
    expect(modules[9]['credits'], 1.25);
    var count = 0;
    for (final bank in demoCourse3Banks.values) {
      expect(bank.length, 25);
      for (final q in bank) {
        final removed = q['hint']['eliminate_choices'] as List;
        final remaining = q['hint']['remaining_choices'] as List;
        expect(removed.toSet().length, 2);
        expect(removed, isNot(contains(q['correct_choice'])));
        expect(remaining.toSet().length, 2);
        expect(remaining, contains(q['correct_choice']));
        expect({...removed, ...remaining}, {'a', 'b', 'c', 'd'});
        count++;
      }
    }
    expect(count, 275);
  });
  test(
    'Course 3 preview serves 15 questions with safe interactive hints',
    () async {
      final repo = DemoCeRepository(
        courseNumber: 3,
        catalog: demoCourse3Catalog,
        questionBanks: demoCourse3Banks,
      );
      await repo.call('demo_unlock');
      await repo.call('profile', {
        'full_name': 'Preview Test',
        'credentials': 'CRNA',
        'location': 'Rochester, NY',
        'aana_id': '',
        'participation_start_on': '2026-10-01',
        'participation_end_on': '2026-10-03',
      });
      for (final m in demoCourse3Catalog['modules']) {
        final args = <String, dynamic>{'module_id': m['id']};
        await repo.call('read', args);
        final quiz = await repo.call('quiz', args);
        expect(quiz['questions'].length, 15);
        for (final q in quiz['questions']) {
          final result = await repo.call('hint', {
            ...args,
            'attempt_id': quiz['attempt_id'],
            'question_id': q['question_id'],
          });
          expect(result['eliminated'].length, 2);
        }
      }
    },
  );
}
