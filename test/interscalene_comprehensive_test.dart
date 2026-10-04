import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/regional/regional_content.dart';

import 'regional_test.dart' show regionalApp;

void main() {
  test('interscalene expansion is complete, source-linked, and searchable', () {
    final topic = regionalTopic('interscalene')!;
    expect(topic.sections, hasLength(13));
    final text = topic.sections.expand((s) => s.bullets).join(' ');
    for (final phrase in [
      'not a dependable stand-alone block',
      'does not guarantee diaphragm preservation',
      'Negative aspiration does not exclude',
      'No universal depth rule',
      '133 mg',
      '96 hours',
      'no single concentration-volume recipe',
      'searched through December 2022',
      '2,130 adults',
    ]) {
      expect(text, contains(phrase));
    }
    for (final section in topic.sections) {
      expect(section.sources, isNotEmpty);
      for (final id in section.sources) {
        expect(regionalSources.containsKey(id), isTrue);
      }
    }
    for (final term in ['ISB', 'rebound', 'superior trunk', 'hoarseness']) {
      expect(searchRegionalTopics(term), contains(topic));
    }
  });

  testWidgets('summary, shortcuts, expansion, search and reset work', (
    tester,
  ) async {
    await tester.pumpWidget(regionalApp(topic: 'interscalene'));
    await tester.pumpAndSettle();
    expect(find.text('At a glance'), findsOneWidget);
    final anatomy = regionalTopic('interscalene')!.sections
        .firstWhere((s) => s.title == 'Anatomy & ultrasound orientation')
        .bullets
        .first;
    expect(find.text(anatomy, findRichText: true), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Anatomy'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Anatomy'));
    await tester.pumpAndSettle();
    expect(find.text(anatomy, findRichText: true), findsOneWidget);
    await tester.tap(find.text('Anatomy & ultrasound orientation'));
    await tester.pumpAndSettle();
    expect(find.text(anatomy, findRichText: true), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Expand all'),
      -400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Expand all'));
    await tester.pumpAndSettle();
    expect(find.text(anatomy, findRichText: true), findsOneWidget);
    await tester.tap(find.text('Collapse all'));
    await tester.pumpAndSettle();
    expect(find.text(anatomy, findRichText: true), findsNothing);

    await tester.enterText(find.byType(TextField), '133 mg');
    await tester.pumpAndSettle();
    expect(find.text('Liposomal bupivacaine & adjuvants'), findsOneWidget);
    expect(find.text('Selection & consent'), findsNothing);
    await tester.enterText(find.byType(TextField), 'zzzznomatch');
    await tester.pumpAndSettle();
    expect(find.text('No matching detailed sections.'), findsOneWidget);
    await tester.ensureVisible(find.text('Show all sections'));
    await tester.tap(find.text('Show all sections'));
    await tester.pumpAndSettle();
    expect(find.text('Selection & consent'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Tile dashboard'), findsOneWidget);
  });

  for (final size in [const Size(320, 568), const Size(820, 1180)]) {
    testWidgets('all expanded content fits $size at double text', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(regionalApp(topic: 'interscalene', scale: 2));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Expand all'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Expand all'));
      await tester.pumpAndSettle();
      for (final section in regionalTopic('interscalene')!.sections.skip(1)) {
        await tester.ensureVisible(find.text(section.title));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: section.title);
      }
    });
  }
}
