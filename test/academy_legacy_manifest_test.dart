import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/academy/academy_review_questions.dart';

void main() {
  test(
    'legacy import is complete against manifest and excluded from assets',
    () {
      final manifest = jsonDecode(
        File('review/academy/manifest.json').readAsStringSync(),
      );
      final List questions = jsonDecode(
        File('review/academy/questions.json').readAsStringSync(),
      );
      expect(questions.length, manifest['questionCount']);
      expect(questions.length, 601);
      expect(questions.map((q) => q['id']).toSet().length, questions.length);
      for (final q in questions) {
        expect(q['reviewStatus'], 'needs_clinical_review');
        expect(
          q['original']['answer'],
          inInclusiveRange(0, (q['original']['options'] as List).length - 1),
        );
      }
      for (final file in manifest['files']) {
        final bytes = File('review/academy/legacy-source/${file['file']}')
            .readAsBytesSync();
        expect(sha256.convert(bytes).toString(), file['sha256']);
      }
      for (final corrected in academyReviewQuestions) {
        expect(questions.where((q) => q['id'] == corrected.legacyId).length, 1);
      }
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec.contains('review/'), isFalse);
      expect(manifest['shippedInApp'], isFalse);
      expect(manifest['flashcardRecordsImported'], isFalse);
    },
  );
}
