import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/regional/regional_content.dart';
import 'package:luma_anesthesia/screens/subscription_screen.dart';

import 'regional_test.dart' show regionalApp;

const expandedIds = [
  'supraclavicular',
  'infraclavicular',
  'axillary',
  'femoral',
  'adductor-canal',
  'ipack',
  'popliteal',
  'tap',
  'quadratus-lumborum',
  'esp',
  'peng',
  'epidural',
  'spinal',
];

void main() {
  test('13 expanded blocks preserve inventory and source-linked depth', () {
    expect(regionalTopics, hasLength(22));
    expect(
      regionalTopics.where((t) => t.sections.first.title == 'At a glance'),
      hasLength(14),
    );
    for (final id in expandedIds) {
      final topic = regionalTopic(id)!;
      expect(topic.sections, hasLength(10), reason: id);
      expect(topic.sections.first.title, 'At a glance');
      expect(topic.sections.map((s) => s.title).toSet(), hasLength(10));
      for (final section in topic.sections) {
        expect(section.bullets.length, greaterThanOrEqualTo(3));
        expect(section.sources, isNotEmpty);
        for (final source in section.sources) {
          expect(regionalSources.containsKey(source), isTrue, reason: source);
        }
      }
      expect(searchRegionalTopics(topic.title), contains(topic));
    }
  });

  test('block-specific distinctions remain explicit', () {
    String content(String id) =>
        regionalTopic(id)!.sections.expand((s) => s.bullets).join(' ');
    expect(content('supraclavicular'), contains('not reliably phrenic-free'));
    expect(content('axillary'), contains('musculocutaneous'));
    expect(content('adductor-canal'), contains('quadriceps'));
    expect(content('ipack'), contains('2 of 30'));
    expect(content('popliteal'), contains('133 mg'));
    expect(content('tap'), contains('visceral pain'));
    expect(content('peng'), contains('not a guarantee'));
    for (final id in ['epidural', 'spinal']) {
      expect(
        regionalTopic(id)!.sections
            .any((s) => s.title == 'Technique & injection safeguards'),
        isFalse,
      );
    }
  });

  for (final id in expandedIds) {
    testWidgets('$id has functioning technique and medication shortcuts', (
      tester,
    ) async {
      await tester.pumpWidget(regionalApp(topic: id));
      await tester.pumpAndSettle();
      expect(find.text('At a glance'), findsOneWidget);
      expect(find.text('Interscalene\nbrachial plexus block'), findsNothing);
      final topic = regionalTopic(id)!;
      for (final entry in {
        'Technique': topic.sections.firstWhere(
          (s) => s.title.startsWith('Technique'),
        ),
        'Medications': topic.sections.firstWhere(
          (s) =>
              s.title.startsWith('Local anesthetics') ||
              s.title.startsWith('Medications'),
        ),
        'Troubleshooting': topic.sections.firstWhere(
          (s) => s.title.startsWith('Block assessment'),
        ),
        'Urgent concerns': topic.sections.firstWhere(
          (s) =>
              s.title.startsWith('Complications') ||
              s.title == 'Nonzero motor risk',
        ),
        'Evidence': topic.sections.last,
      }.entries) {
        await tester.ensureVisible(find.text(entry.key));
        await tester.tap(find.text(entry.key));
        await tester.pumpAndSettle();
        expect(
          find.text(entry.value.bullets.first, findRichText: true),
          findsOneWidget,
          reason: '$id ${entry.key}',
        );
        expect(tester.takeException(), isNull);
      }
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Tile dashboard'), findsOneWidget);
    });

    for (final size in [const Size(320, 568), const Size(820, 1180)]) {
      testWidgets('$id fully expanded at $size with double text', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(regionalApp(topic: id, scale: 2));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Expand all'));
        await tester.tap(find.text('Expand all'));
        await tester.pumpAndSettle();
        for (final section in regionalTopic(id)!.sections.skip(1)) {
          await tester.ensureVisible(find.text(section.title));
          await tester.pumpAndSettle();
          expect(
            find.text(section.bullets.first, findRichText: true),
            findsOneWidget,
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '$id ${section.title}',
          );
        }
      });
    }
  }

  testWidgets('neuraxial search filters, resets and retains Home', (
    tester,
  ) async {
    await tester.pumpWidget(regionalApp(topic: 'spinal'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'baricity');
    await tester.pumpAndSettle();
    expect(find.text('Selection & coverage'), findsNothing);
    expect(
      find.text('Matching sections are expanded. Clear search to browse all.'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Technique'));
    await tester.tap(find.text('Technique'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    expect(find.text('Selection & coverage'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'notamatchxyz');
    await tester.pumpAndSettle();
    expect(find.text('No matching detailed sections.'), findsOneWidget);
    await tester.ensureVisible(find.text('Show all sections'));
    await tester.tap(find.text('Show all sections'));
    await tester.pumpAndSettle();
    expect(find.text('Selection & coverage'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Tile dashboard'), findsOneWidget);
  });

  testWidgets('revoked subscription removes comprehensive reader', (
    tester,
  ) async {
    var allowed = true;
    final changes = StreamController<void>.broadcast();
    addTearDown(changes.close);
    await tester.pumpWidget(
      regionalApp(
        topic: 'spinal',
        checker: () async => allowed,
        changes: changes.stream,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('At a glance'), findsOneWidget);
    allowed = false;
    changes.add(null);
    await tester.pumpAndSettle();
    expect(find.text('At a glance'), findsNothing);
    expect(find.byType(SubscriptionScreen), findsOneWidget);
  });
}
