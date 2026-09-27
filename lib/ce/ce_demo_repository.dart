// Preview only. Production main.dart never imports this library.
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ce_repository.dart';
import 'ce_demo_data.dart';

class DemoCeRepository extends CeRepository {
  @override
  bool get isDemo => true;
  @override
  bool get signedIn => true;
  bool unlocked = false, read = false, passed = false;
  Map<String, dynamic> profile = {}, completion = {};
  Map<String, String> answers = {};
  Map<String, dynamic> hints = {};
  int number = 0;
  bool submitted = true;
  int lastScore = 0;
  List<dynamic> questions = [];

  @override
  Future<Map<String, dynamic>> call(
    String action, [
    Map<String, dynamic> payload = const {},
  ]) async {
    switch (action) {
      case 'catalog':
        return demoCatalog;
      case 'demo_unlock':
        unlocked = true;
        return {};
      case 'access':
      case 'status':
        return {
          'has_access': unlocked,
          'is_preview': true,
          'profile': profile,
          'read': read,
          'passed': passed,
          'completed': completion.isNotEmpty,
          'completion': completion,
          'attempts_used': number,
        };
      case 'profile':
        profile = Map.of(payload);
        return {'saved': true};
      case 'document':
        final response =
            await http.get(Uri.base.resolve('ketamine_learner.pdf'));
        if (response.statusCode != 200) {
          throw Exception('Preview PDF unavailable');
        }
        return {'base64': base64Encode(response.bodyBytes)};
      case 'read':
        read = true;
        return {};
      case 'quiz':
        if (!read) throw Exception('Review the content first');
        if (submitted) {
          if (number >= 3) {
            throw Exception('Three attempts used. Contact info@cehalo.com.');
          }
          final forms = [
            List.generate(15, (i) => i),
            [...List.generate(7, (i) => i), ...List.generate(8, (i) => i + 15)],
            [
              ...List.generate(7, (i) => i + 7),
              ...List.generate(7, (i) => i + 15),
              23,
            ],
          ];
          questions = forms[number].map((i) => demoQuestions[i]).toList();
          number++;
          answers = {};
          hints = {};
          submitted = false;
        }
        return {
          'attempt_id': 'preview-$number',
          'number': number,
          'questions': questions,
          'answers': answers,
          'hints': hints,
        };
      case 'hint':
        final id = payload['question_id'] as String;
        final q = questions.firstWhere((q) => q['question_id'] == id);
        hints.putIfAbsent(
          id,
          () => ['a', 'b', 'c', 'd']
              .where((c) => c != q['correct_choice'])
              .take(2)
              .toList(),
        );
        if ((hints[id] as List).contains(answers[id])) answers.remove(id);
        return {'eliminated': hints[id], 'answers': answers};
      case 'save_answers':
        answers = Map<String, String>.from(payload['answers'] as Map);
        return {};
      case 'submit':
        if (!submitted) {
          answers = Map<String, String>.from(payload['answers'] as Map);
          if (answers.length != 15) throw Exception('Answer all 15 questions');
          lastScore = questions
              .where((q) => answers[q['question_id']] == q['correct_choice'])
              .length;
          passed = lastScore >= 12;
          submitted = true;
        }
        return {'score': lastScore, 'total': 15, 'passed': passed};
      case 'evaluate':
        if (!passed) throw Exception('Pass the assessment first');
        completion = {
          'learner': Map.of(profile),
          'location': payload['location'],
          'completed_at': DateTime.now().toUtc().toIso8601String(),
          'is_preview': true,
          'module_credits': 0,
          'course_complete': false,
        };
        return completion;
      default:
        throw Exception('Unsupported preview action');
    }
  }
}
