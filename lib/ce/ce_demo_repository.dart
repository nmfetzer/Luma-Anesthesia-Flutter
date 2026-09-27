// Preview only. Production main.dart never imports this library.
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ce_repository.dart';
import 'ce_demo_data.dart';

class DemoCeRepository extends CeRepository {
  final Map<String, _DemoModuleRepository> _modules = {};
  Map<String, dynamic> profile = {};
  bool unlocked = false;
  @override
  bool get isDemo => true;
  @override
  bool get signedIn => true;
  @override
  Future<Map<String, dynamic>> call(
    String action, [
    Map<String, dynamic> payload = const {},
  ]) async {
    if (action == 'catalog') return demoCatalog;
    if (action == 'demo_unlock') {
      unlocked = true;
      return {};
    }
    if (action == 'records') {
      final rows = payload['include_preview'] == true
          ? _modules.values
                .where((m) => m.completion.isNotEmpty)
                .where(
                  (m) =>
                      payload['month'] == null ||
                      (m.completion['completed_at'] as String).startsWith(
                        payload['month'] as String,
                      ),
                )
                .map(
                  (m) => <String, dynamic>{
                    ...m.completion,
                    ...Map<String, dynamic>.from(
                      m.completion['learner'] as Map,
                    ),
                    'account_id': 'design-preview',
                    'course_id': '1047239',
                    'reporting_class': '196397',
                    'quiz_attempts': [
                      {'score': m.lastScore, 'number': m.number},
                    ],
                    'evaluation': m.evaluation,
                    'reporting_status': 'PREVIEW - NOT REPORTABLE',
                    'full_course_awarded': false,
                  },
                )
                .toList()
          : <Map<String, dynamic>>[];
      return {'rows': rows, 'total': rows.length};
    }
    final id = payload['module_id'] as String? ?? 'course_1_module_1';
    final metadata = (demoCatalog['modules'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((m) => m['id'] == id);
    final state = _modules.putIfAbsent(
      id,
      () => _DemoModuleRepository(metadata),
    );
    state.unlocked = unlocked;
    if (action == 'profile') {
      profile = {
        for (final key in ['full_name', 'credentials', 'aana_id', 'location'])
          key: payload[key] ?? '',
      };
    }
    state.profile = profile;
    final response = await state.call(action, payload);
    if (action == 'access' || action == 'status') {
      response['module_id'] = id;
      response['is_provider'] = unlocked;
      response['module_statuses'] = {
        for (final entry in _modules.entries)
          entry.key: {
            'read': entry.value.read,
            'passed': entry.value.passed,
            'completed': entry.value.completion.isNotEmpty,
            'attempts_used': entry.value.number,
          },
      };
    }
    return response;
  }
}

class _DemoModuleRepository extends CeRepository {
  _DemoModuleRepository(this.metadata);
  final Map<String, dynamic> metadata;
  String get moduleId => metadata['id'] as String;
  List<dynamic> get bank => switch (moduleId) {
    'course_1_module_1' => demoQuestions,
    'course_1_module_2' => demoGlp1Questions,
    'course_1_module_3' => demoBenzodiazepineQuestions,
    _ => throw StateError('No preview question bank for $moduleId'),
  };
  @override
  bool get isDemo => true;
  @override
  bool get signedIn => true;
  bool unlocked = false, read = false, passed = false;
  Map<String, dynamic> profile = {}, completion = {};
  Map<String, dynamic> evaluation = {};
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
        final response = await http.get(
          Uri.base.resolve('${metadata['resource_prefix']}_learner.pdf'),
        );
        if (response.statusCode != 200) {
          throw Exception('Preview PDF unavailable');
        }
        return {'base64': base64Encode(response.bodyBytes)};
      case 'read':
        read = true;
        return {};
      case 'quiz':
        if (!read) throw Exception('Review the content first');
        if (passed) throw Exception('Assessment already passed');
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
          questions = forms[number].map((i) => bank[i]).toList();
          number++;
          answers = {};
          hints = {};
          submitted = false;
        }
        return {
          'attempt_id': '$moduleId-preview-$number',
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
          () =>
              q['hint']?['eliminate_choices'] ??
              [
                'a',
                'b',
                'c',
                'd',
              ].where((c) => c != q['correct_choice']).take(2).toList(),
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
        evaluation = Map.of(payload);
        completion = {
          'module_id': moduleId,
          'learner': Map.of(profile),
          'location': profile['location'],
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
