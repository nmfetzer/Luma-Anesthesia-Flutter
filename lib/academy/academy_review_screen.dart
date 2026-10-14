import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'academy_question.dart';
import 'academy_review_questions.dart';

/// Private design/content review entry only; not routed from the released app.
class AcademyReviewScreen extends StatefulWidget {
  const AcademyReviewScreen({super.key});

  @override
  State<AcademyReviewScreen> createState() => _AcademyReviewScreenState();
}

class _AcademyReviewScreenState extends State<AcademyReviewScreen> {
  AcademyRound? _round;
  bool _results = false;
  final _scroll = ScrollController();
  static const _navy = Color(0xFF153247);
  static const _cream = Color(0xFFF7F1E6);

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _top() {
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _start(List<AcademyQuestion> questions) {
    setState(() {
      _round = AcademyRound(questions);
      _results = false;
    });
    _top();
  }

  Future<void> _source(AcademyQuestion question) async {
    try {
      final opened = await launchUrl(
        Uri.parse(question.sourceUrl),
        mode: LaunchMode.externalApplication,
      );
      if (opened) return;
    } catch (_) {
      // Leave the rationale visible even if an external source cannot open.
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open the source. Try again online.'),
        ),
      );
    }
  }

  Widget _card(List<Widget> children, {bool dark = false}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: dark ? _navy : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE3DACC)),
    ),
    child: DefaultTextStyle(
      style: TextStyle(
        fontFamily: 'Inter',
        color: dark ? _cream : _navy,
        fontSize: 15,
        height: 1.45,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final round = _round;
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        foregroundColor: _navy,
        title: const Text('Luma Academy'),
        actions: [
          if (round != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _round = null;
                  _results = false;
                });
                _top();
              },
              child: const Text('Study home'),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              const Text(
                'PRIVATE REVIEW • NOT FOR CLINICAL USE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Color(0xFF735526),
                ),
              ),
              const SizedBox(height: 16),
              if (round == null)
                ..._home()
              else if (_results)
                ..._summary(round)
              else
                ..._question(round),
              const SizedBox(height: 24),
              const Text(
                'Academy is practice, not approved CE. Study points have no '
                'monetary or credit value. Content awaits clinician approval. '
                'This preview saves no account progress.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFF5E6A70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _home() => [
    const Text(
      'A little practice.\nA brighter understanding.',
      style: TextStyle(
        fontFamily: 'Fraunces',
        fontSize: 30,
        height: 1.15,
        color: _navy,
      ),
    ),
    const SizedBox(height: 12),
    const Text(
      'Build knowledge one short round at a time. Learn why, revisit what '
      'you missed, and keep moving forward.',
      style: TextStyle(color: Color(0xFF536471), height: 1.5),
    ),
    const SizedBox(height: 24),
    _card([
      const Text(
        'YOUR FIRST PRACTICE ROUND',
        style: TextStyle(
          fontSize: 10,
          letterSpacing: 1.2,
          color: Color(0xFFE6CF9C),
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'Anesthesia pharmacology',
        style: TextStyle(fontFamily: 'Fraunces', fontSize: 23),
      ),
      const SizedBox(height: 8),
      const Text('3 source-checked questions • No timer'),
      const SizedBox(height: 18),
      FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFE6CF9C),
          foregroundColor: _navy,
          minimumSize: const Size.fromHeight(48),
        ),
        onPressed: () => _start(academyReviewQuestions),
        child: const Text('Start practice'),
      ),
    ], dark: true),
    const SizedBox(height: 24),
    const Text(
      'Your learning path',
      style: TextStyle(fontFamily: 'Fraunces', fontSize: 23, color: _navy),
    ),
    const SizedBox(height: 12),
    _card([
      for (final (index, question) in academyReviewQuestions.indexed)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: _cream,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: _navy),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(question.topic)),
            ],
          ),
        ),
    ]),
    const SizedBox(height: 16),
    const Text(
      'Preview: one sample round, not the full Academy library.',
      style: TextStyle(fontSize: 12, color: Color(0xFF536471)),
    ),
  ];

  List<Widget> _question(AcademyRound round) => [
    Text(
      'Question ${round.index + 1} of ${round.questions.length} · '
      '${round.points} study points',
    ),
    const SizedBox(height: 10),
    LinearProgressIndicator(
      value: (round.index + (round.answered ? 1 : 0)) / round.questions.length,
      color: _navy,
      backgroundColor: const Color(0xFFE3DACC),
    ),
    const SizedBox(height: 20),
    _card([
      Text(
        round.current.topic,
        style: const TextStyle(fontSize: 12, color: Color(0xFF735526)),
      ),
      const SizedBox(height: 12),
      Text(
        round.current.prompt,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 20),
      for (final (index, option) in round.current.options.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OutlinedButton(
            key: ValueKey('academy-answer-$index'),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              foregroundColor: _navy,
              disabledForegroundColor: _navy,
              padding: const EdgeInsets.all(16),
              minimumSize: const Size.fromHeight(48),
              backgroundColor: round.selected == index ? _cream : null,
            ),
            onPressed: round.answered
                ? null
                : () => setState(() => round.answer(index)),
            child: Row(
              children: [
                Text('${String.fromCharCode(65 + index)}. '),
                Expanded(child: Text(option)),
              ],
            ),
          ),
        ),
    ]),
    if (round.answered) ...[
      const SizedBox(height: 16),
      _card([
        Text(
          round.isCorrect
              ? 'Correct. Here is why.'
              : 'A useful one to revisit.',
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text('Answer: ${round.current.options[round.current.answer]}'),
        const SizedBox(height: 12),
        Text(round.current.rationale),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _source(round.current),
          child: Text(round.current.sourceTitle),
        ),
      ]),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: () {
          setState(() {
            if (round.isLast) {
              _results = true;
            } else {
              round.next();
            }
          });
          _top();
        },
        child: Text(round.isLast ? 'See round summary' : 'Next question'),
      ),
    ],
  ];

  List<Widget> _summary(AcademyRound round) => [
    const Text(
      'Practice complete',
      style: TextStyle(fontFamily: 'Fraunces', fontSize: 30, color: _navy),
    ),
    const SizedBox(height: 20),
    _card([
      Text(
        '${round.correctCount} of ${round.questions.length} correct',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),
      Text('${round.points} study points this round'),
      const SizedBox(height: 12),
      const Text(
        'A practice score is not a measure of clinical competence '
        'or a prediction of board-exam performance.',
      ),
      if (round.missed.isNotEmpty) ...[
        const SizedBox(height: 18),
        FilledButton(
          onPressed: () => _start(round.missed),
          child: Text('Revisit ${round.missed.length} missed'),
        ),
      ],
      const SizedBox(height: 12),
      TextButton(
        onPressed: () => _start(academyReviewQuestions),
        child: const Text('Practice all again'),
      ),
    ]),
  ];
}
