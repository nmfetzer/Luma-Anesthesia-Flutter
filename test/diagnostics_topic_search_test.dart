import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/diagnostics/abg_content.dart';
import 'package:luma_anesthesia/diagnostics/clinical_modules.dart';
import 'package:luma_anesthesia/diagnostics/diagnostics_access.dart';
import 'package:luma_anesthesia/diagnostics/diagnostics_content.dart';
import 'package:luma_anesthesia/diagnostics/diagnostics_search.dart';
import 'package:luma_anesthesia/home/home_search.dart';
import 'package:luma_anesthesia/screens/subscription_screen.dart';
import 'package:luma_anesthesia/theme/luma_theme.dart';

Widget host(Widget child) => MaterialApp(
  theme: buildLumaTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child!,
  ),
  home: child,
);

void main() {
  test('every canonical lab and topic has a unique, searchable route', () {
    expect(
      diagnosticsSearchIndex.length,
      labReferences.length +
          abgTopics.length +
          clinicalModules.fold<int>(0, (n, m) => n + m.topics.length) +
          1,
    );
    expect(
      diagnosticsSearchIndex.map((e) => e.route).toSet().length,
      diagnosticsSearchIndex.length,
    );
    for (final topic in diagnosticsSearchIndex) {
      expect(searchDiagnosticsTopics(topic.title), contains(topic));
      final route = Uri.parse(topic.route);
      expect(route.pathSegments, ['diagnostics', topic.sectionId]);
      expect(route.queryParameters['topic'], topic.topicId);
    }
    expect(searchDiagnosticsTopics('   '), isEmpty);
    expect(searchDiagnosticsTopics('???'), isEmpty);
    expect(searchDiagnosticsTopics('zzzznotareference'), isEmpty);
  });

  test('abbreviations, partial typing and punctuation find direct topics', () {
    for (final example in {
      'ACT': 'act',
      'activated clotting': 'act',
      'trop': 'troponin',
      'metabolic acidosis': 'unexplained-acidosis',
      'carotid stenosis': 'carotid-grade',
      'CKMB': 'ck-mb',
      'anion gap': 'formulas',
    }.entries) {
      expect(
        searchDiagnosticsTopics(example.key).map((e) => e.topicId),
        contains(example.value),
        reason: example.key,
      );
    }
    expect(searchDiagnosticsTopics('ACT').first.topicId, 'act');
    expect(searchDiagnosticsTopics('troponin').first.topicId, 'troponin');
    expect(
      searchDiagnosticsTopics('NT-proBNP').map((e) => e.route),
      searchDiagnosticsTopics('nt probnp').map((e) => e.route),
    );
  });

  testWidgets(
    'homepage results appear before remote libraries and open a gated named route',
    (tester) async {
      final pending = Completer<HomeSearchData>();
      String? opened;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeSearch(
              sections: const [],
              loadData: () => pending.future,
            ),
          ),
          onGenerateRoute: (settings) {
            opened = settings.name;
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) =>
                  const Scaffold(body: Text('Named Diagnostics route')),
            );
          },
        ),
      );
      await tester.tap(find.byType(SearchBar));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.enterText(find.byType(TextField).last, 'ACT');
      await tester.pump();
      expect(find.text('ACT / Activated Clotting Time'), findsOneWidget);
      expect(find.text('ACT targets by procedure'), findsNothing);
      expect(find.textContaining('No matches yet'), findsNothing);
      await tester.tap(find.text('ACT / Activated Clotting Time'));
      pending.complete(const HomeSearchData());
      await tester.pumpAndSettle();
      expect(opened, '/diagnostics/labs?topic=act');
      expect(find.text('Named Diagnostics route'), findsOneWidget);
    },
  );

  for (final topic in diagnosticsSearchIndex) {
    testWidgets(
      'direct route opens only ${topic.sectionId}/${topic.topicId} expanded',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 1800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          host(
            DiagnosticsFeature(
              initialSection: topic.sectionId,
              initialTopic: topic.topicId,
              checkAccess: () async => true,
              accessChanges: const Stream<void>.empty(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final tiles = tester.widgetList<ExpansionTile>(
          find.byType(ExpansionTile),
        );
        final target = tiles.where(
          (tile) =>
              tile.title is Text && (tile.title as Text).data == topic.title,
        );
        expect(target, hasLength(1));
        expect(target.single.initiallyExpanded, isTrue);
        if (topic.topicId != 'formulas') {
          expect(find.byType(TextField), findsOneWidget);
          expect(
            tester.widget<TextField>(find.byType(TextField)).controller!.text,
            topic.title,
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final section in diagnosticCategories) {
    testWidgets('unpaid deep topic remains gated: ${section.id}', (
      tester,
    ) async {
      final topic = diagnosticsSearchIndex.firstWhere(
        (e) => e.sectionId == section.id,
      );
      await tester.pumpWidget(
        host(
          DiagnosticsFeature(
            initialSection: section.id,
            initialTopic: topic.topicId,
            checkAccess: () async => false,
            accessChanges: const Stream<void>.empty(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SubscriptionScreen), findsOneWidget);
      expect(find.text(topic.title), findsNothing);
    });
  }

  testWidgets(
    'clear selected-topic search restores the library; invalid topic is safe',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        host(
          DiagnosticsFeature(
            initialSection: 'labs',
            initialTopic: 'act',
            checkAccess: () async => true,
            accessChanges: const Stream<void>.empty(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(find.text('Sodium (Na)'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        host(
          DiagnosticsFeature(
            initialSection: 'labs',
            initialTopic: 'not-a-topic',
            checkAccess: () async => true,
            accessChanges: const Stream<void>.empty(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sodium (Na)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
