import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/surgical_prep/drafts/laparoscopic_cholecystectomy.dart';

void main() {
  test(
    'populated adult preview has overview, all details and named HTTPS sources',
    () {
      final c = laparoscopicCholecystectomyDraft;
      expect(c.overview.bullets, hasLength(4));
      expect(c.sections, hasLength(11));
      for (final section in [c.overview, ...c.sections]) {
        expect(section.bullets, isNotEmpty);
        expect(section.sources, isNotEmpty);
        for (final source in section.sources) {
          expect(Uri.parse(source.url).scheme, 'https');
        }
      }
      final text = c.sections.expand((s) => s.bullets).join(' ');
      expect(text, contains('at least 0.9'));
      expect(text, contains('adductor pollicis'));
      expect(text, contains('against combining'));
      expect(text, contains('evidence searched through December 2022'));
      expect(
        text,
        contains('does not represent independent clinical approval'),
      );
      expect(text, isNot(contains('ETT mandatory')));
    },
  );
}
