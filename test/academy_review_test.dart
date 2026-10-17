import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/academy/academy_question.dart';
import 'package:luma_anesthesia/academy/academy_review_questions.dart';
import 'package:luma_anesthesia/academy/academy_review_screen.dart';
import 'package:luma_anesthesia/launch/launch_scope.dart';

void main() {
  test('Connected Academy does not release legacy unapproved questions', () {
    expect(LaunchScope.isDeferred('/luma-academy'), !LaunchScope.academyConnected);
    for (final q in academyReviewQuestions) {
      expect(q.reviewStatus, 'source_checked_awaiting_clinician_review');
      expect(q.sourceUrl, startsWith('https://dailymed.nlm.nih.gov/'));
      expect(q.legacyId, startsWith('ABAPracticeExamData:'));
      expect(q.answer, inInclusiveRange(0, q.options.length - 1));
    }
  });

  test('round scores once, prevents skips, and retains missed questions', () {
    final round = AcademyRound(academyReviewQuestions);
    round.next();
    expect(round.index, 0);
    round.answer(0); // Incorrect first response.
    round.answer(1); // No credit for changing after viewing the rationale.
    expect(round.selected, 0);
    expect(round.points, 0);
    round.next();
    round.answer(round.current.answer);
    round.next();
    round.answer(round.current.answer);
    expect(round.complete, isTrue);
    expect(round.points, 20);
    expect(round.missed.map((q) => q.id), ['etomidate-adrenal-effects']);
    final retry = AcademyRound(round.missed);
    expect(retry.questions.length, 1);
    expect(retry.points, 0);
    expect(() => retry.answer(999), throwsRangeError);
    expect(() => AcademyRound([]), throwsArgumentError);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('practice, rationale and retry work at text scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const AcademyReviewScreen(),
        ),
      );
      Future<void> tapText(String text) async {
        await tester.scrollUntilVisible(find.text(text), 250);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(text));
        await tester.pumpAndSettle();
        await tester.tap(find.text(text));
        await tester.pumpAndSettle();
      }

      await tapText('Start practice');
      for (var index = 0; index < 3; index++) {
        final answer = find.byKey(const ValueKey('academy-answer-0'));
        await tester.scrollUntilVisible(answer, 200);
        await tester.pumpAndSettle();
        await tester.ensureVisible(answer);
        await tester.pumpAndSettle();
        await tester.tap(answer);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tapText(index == 2 ? 'See round summary' : 'Next question');
      }
      expect(find.text('1 of 3 correct'), findsOneWidget);
      await tapText('Revisit 2 missed');
      expect(find.text('Question 1 of 2 · 0 study points'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
