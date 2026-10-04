import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/regional/regional_content.dart';
import 'package:luma_anesthesia/regional/regional_screen.dart';
import 'package:luma_anesthesia/home/home_search.dart';
import 'package:luma_anesthesia/screens/subscription_screen.dart';
import 'package:luma_anesthesia/theme/luma_theme.dart';

Widget regionalApp({
  String? topic,
  bool allowed = true,
  Future<bool> Function()? checker,
  Stream<void>? changes,
  double scale = 1,
}) => MaterialApp(
  theme: buildLumaTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
    child: child!,
  ),
  home: RegionalFeature(
    topicId: topic,
    checkAccess: checker ?? () async => allowed,
    accessChanges: changes ?? const Stream<void>.empty(),
  ),
  onGenerateRoute: (settings) {
    if (settings.name == '/home') {
      return MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Tile dashboard')),
      );
    }
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => RegionalFeature(
        topicId: Uri.parse(settings.name!).pathSegments.skip(1).firstOrNull,
        checkAccess: checker ?? () async => allowed,
        accessChanges: changes ?? const Stream<void>.empty(),
      ),
    );
  },
);

void main() {
  test('complete Base44 block inventory plus safety; unique routes and valid sources', () {
    expect(regionalTopics, hasLength(22));
    expect(regionalTopics.map((t) => t.id).toSet(), hasLength(22));
    for (final id in [
      'interscalene',
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
      'spinal',
      'epidural',
    ]) {
      expect(regionalTopic(id), isNotNull);
    }
    for (final topic in regionalTopics) {
      expect(topic.sections.length, greaterThanOrEqualTo(3));
      expect(searchRegionalTopics(topic.title), contains(topic));
      for (final section in topic.sections) {
        expect(section.bullets, isNotEmpty);
        expect(section.sources, isNotEmpty);
        for (final id in section.sources) {
          final source = regionalSources[id];
          expect(source, isNotNull, reason: id);
          final uri = Uri.parse(source!.url);
          expect(uri.scheme, 'https');
          expect(uri.path.length, greaterThan(1));
        }
      }
      for (final id in topic.related) {
        expect(regionalTopic(id), isNotNull);
      }
    }
  });

  test(
    'important clinical distinctions are not collapsed into generic rules',
    () {
      String text(String id) =>
          regionalTopic(id)!.sections.expand((s) => s.bullets).join(' ');
      expect(text('anticoagulation'), contains('36 hours'));
      expect(text('anticoagulation'), contains('24 hours'));
      expect(text('anticoagulation'), contains('first postoperative dose'));
      expect(text('anticoagulation'), contains('not the insertion criterion'));
      expect(text('liposomal-bupivacaine'), contains('not “266 mg per side”'));
      expect(text('liposomal-bupivacaine'), contains('96 hours'));
      expect(text('peng'), contains('not a guarantee'));
      expect(text('ipack'), contains('foot drop'));
      expect(text('last'), contains('12 mL/kg'));
      expect(text('last'), contains('less than 1 mcg/kg'));
      expect(
        text('local-anesthetics'),
        contains('does not provide a universal'),
      );
    },
  );

  test(
    'aliases and filters cover selection, medications, and abbreviations',
    () {
      for (final pair in {
        'PENG': 'peng',
        'Eliquis': 'anticoagulation',
        'TAP': 'tap',
        'saphenous': 'adductor-canal',
        'LAST': 'last',
        'EXPAREL': 'liposomal-bupivacaine',
      }.entries) {
        expect(
          searchRegionalTopics(pair.key).map((t) => t.id),
          contains(pair.value),
        );
      }
      expect(searchRegionalTopics('peng').first.id, 'peng');
      expect(searchRegionalTopics('zzzznotthere'), isEmpty);
      expect(
        searchRegionalTopics('', category: 'Upper extremity'),
        hasLength(4),
      );
    },
  );

  for (final topic in [null, ...regionalTopics.map((t) => t.id)]) {
    testWidgets('unpaid user cannot open ${topic ?? "hub"}', (tester) async {
      await tester.pumpWidget(regionalApp(topic: topic, allowed: false));
      await tester.pumpAndSettle();
      expect(find.byType(SubscriptionScreen), findsOneWidget);
      expect(find.byType(RegionalDetailScreen), findsNothing);
      expect(find.byType(RegionalLibraryScreen), findsNothing);
    });
  }

  testWidgets(
    'hub search, direct detail, related route, Home and invalid route',
    (tester) async {
      await tester.pumpWidget(regionalApp());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'peng');
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Pericapsular nerve group (PENG) block'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Pericapsular nerve group (PENG) block'));
      await tester.pumpAndSettle();
      expect(find.byType(RegionalDetailScreen), findsOneWidget);
      expect(find.text('Nonzero motor risk'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Femoral nerve block'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Femoral nerve block'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<RegionalDetailScreen>(find.byType(RegionalDetailScreen))
            .topic
            .id,
        'femoral',
      );
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Tile dashboard'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(regionalApp(topic: 'invalid'));
      await tester.pumpAndSettle();
      expect(
        find.text('This regional reference could not be found.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Browse regional references'));
      await tester.pumpAndSettle();
      expect(find.byType(RegionalLibraryScreen), findsOneWidget);
    },
  );

  testWidgets(
    'revoked access removes open detail and protects route underneath',
    (tester) async {
      var allowed = true;
      final changes = StreamController<void>.broadcast();
      addTearDown(changes.close);
      await tester.pumpWidget(
        regionalApp(checker: () async => allowed, changes: changes.stream),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'last');
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Local anesthetic systemic toxicity (LAST)'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Local anesthetic systemic toxicity (LAST)'));
      await tester.pumpAndSettle();
      allowed = false;
      changes.add(null);
      await tester.pumpAndSettle();
      expect(find.byType(RegionalDetailScreen), findsNothing);
      expect(find.byType(SubscriptionScreen), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(RegionalLibraryScreen), findsNothing);
      expect(find.byType(SubscriptionScreen), findsOneWidget);
    },
  );

  testWidgets(
    'homepage finds regional topics even when remote libraries fail',
    (tester) async {
      String? route;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeSearch(
              sections: const [],
              loadData: () async => throw StateError('Offline'),
            ),
          ),
          onGenerateRoute: (settings) {
            route = settings.name;
            return MaterialPageRoute<void>(
              builder: (_) =>
                  const Scaffold(body: Text('Regional named route')),
            );
          },
        ),
      );
      await tester.tap(find.byType(SearchBar));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'PENG');
      await tester.pumpAndSettle();
      expect(
        find.text('Pericapsular nerve group (PENG) block'),
        findsOneWidget,
      );
      expect(find.text('Nonzero motor risk'), findsNothing);
      await tester.tap(find.text('Pericapsular nerve group (PENG) block'));
      await tester.pumpAndSettle();
      expect(route, '/regional-procedures/peng');
    },
  );

  for (final size in [
    const Size(320, 568),
    const Size(375, 812),
    const Size(820, 1180),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('regional content fits $size with text scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        for (final id in [
          null,
          'anticoagulation',
          'interscalene',
          'last',
          'peng',
        ]) {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpWidget(regionalApp(topic: id, scale: scale));
          await tester.pumpAndSettle();
          await tester.drag(
            find.byType(SingleChildScrollView),
            const Offset(0, -600),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$id / $size / $scale',
          );
        }
      });
    }
  }
}
