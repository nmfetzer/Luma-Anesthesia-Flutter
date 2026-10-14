/// Review-only study content. Source checking is not clinician approval.
class AcademyQuestion {
  const AcademyQuestion({
    required this.id,
    required this.topic,
    required this.prompt,
    required this.options,
    required this.answer,
    required this.rationale,
    required this.sourceTitle,
    required this.sourceUrl,
    required this.legacyId,
  });

  final String id;
  final String topic;
  final String prompt;
  final List<String> options;
  final int answer;
  final String rationale;
  final String sourceTitle;
  final String sourceUrl;
  final String legacyId;

  String get reviewStatus => 'source_checked_awaiting_clinician_review';
}

/// Session-only practice progress. Points never grant CE, entitlement or AI credit.
class AcademyRound {
  AcademyRound(Iterable<AcademyQuestion> questions)
    : questions = List.unmodifiable(questions) {
    if (this.questions.isEmpty) throw ArgumentError('A round needs questions');
    if (this.questions.map((q) => q.id).toSet().length !=
        this.questions.length) {
      throw ArgumentError('Question IDs must be unique');
    }
  }
  final List<AcademyQuestion> questions;
  final Map<String, int> _answers = {};
  int _index = 0;
  int get index => _index;
  AcademyQuestion get current => questions[_index];
  int? get selected => _answers[current.id];
  bool get answered => selected != null;
  bool get isCorrect => selected == current.answer;
  bool get isLast => _index == questions.length - 1;
  bool get complete => _answers.length == questions.length;
  int get correctCount =>
      questions.where((q) => _answers[q.id] == q.answer).length;
  int get points => correctCount * 10;
  List<AcademyQuestion> get missed => questions
      .where((q) => _answers.containsKey(q.id) && _answers[q.id] != q.answer)
      .toList(growable: false);

  void answer(int option) {
    if (option < 0 || option >= current.options.length) {
      throw RangeError.index(option, current.options);
    }
    if (answered) return; // Cannot change an answer after seeing its rationale.
    _answers[current.id] = option;
  }

  void next() {
    if (!answered || isLast) return;
    _index++;
  }
}
