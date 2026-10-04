import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/surgical_prep/surgical_case.dart';
import 'package:luma_anesthesia/surgical_prep/surgical_case_screen.dart';
import 'package:luma_anesthesia/theme/luma_theme.dart';
import 'package:luma_anesthesia/screens/subscription_screen.dart';

// Deliberately nonclinical fixtures: layout tests are not medical content.
final source = SurgicalSource(
  label: 'Fixture reference',
  url: 'https://example.org/reference',
);
SurgicalSection section(String id, String title, String bullet) =>
    SurgicalSection(id: id, title: title, bullets: [bullet], sources: [source]);
SurgicalCaseReference fixture(String id) => SurgicalCaseReference(
  id: id,
  title: 'Adult and obstetric surgical case reference with a long title',
  category: 'Layout test',
  overview: section('overview', 'Overview', 'Quick summary stays visible.'),
  sections: [
    section(
      'preop',
      'Preoperative considerations',
      'Detailed preoperative fixture.',
    ),
    section(
      'recovery',
      'Emergence & postoperative care',
      'Recovery keyword fixture.',
    ),
  ],
);

Widget app({
  double scale = 1,
  String id = 'case-a',
  Future<bool> Function(Uri)? opener,
}) => MaterialApp(
  theme: buildLumaTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: SurgicalCaseScreen(
    reference: fixture(id),
    checkAccess: () async => true,
    accessChanges: const Stream<void>.empty(),
    openSource: opener,
  ),
  routes: {'/home': (_) => const Scaffold(body: Text('Tile dashboard'))},
);

Future<void> tapText(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label).first);
  await tester.tap(find.text(label).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('case contents disappear if premium access is revoked', (
    tester,
  ) async {
    final changes = StreamController<void>.broadcast();
    addTearDown(changes.close);
    var allowed = true;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLumaTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: SurgicalCaseScreen(
          reference: fixture('gated-case'),
          checkAccess: () async => allowed,
          accessChanges: changes.stream,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Quick clinical overview'), findsOneWidget);
    allowed = false;
    changes.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Quick clinical overview'), findsNothing);
    expect(find.byType(SubscriptionScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  test('models reject missing overview detail, duplicated sections and unsafe links', () {
    expect(
      () => SurgicalSource(label: 'Bad', url: 'javascript:alert(1)'),
      throwsArgumentError,
    );
    expect(
      () => SurgicalSection(
        id: 'a',
        title: 'Empty',
        bullets: [],
        sources: [source],
      ),
      throwsArgumentError,
    );
    final s = section('a', 'A', 'Bullet');
    expect(
      () => SurgicalCaseReference(
        id: 'c',
        title: 'Case',
        category: 'Adult',
        overview: section('overview', 'Overview', 'Summary'),
        sections: [s, s],
      ),
      throwsArgumentError,
    );
    expect(() => fixture('a').sections.clear(), throwsUnsupportedError);
  });

  testWidgets(
    'overview is always open; details start closed and toggle together or individually',
    (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.text('Quick clinical overview'), findsOneWidget);
      expect(find.text('Quick summary stays visible.'), findsOneWidget);
      expect(find.text('Detailed preoperative fixture.'), findsNothing);
      expect(find.byType(Checkbox), findsNothing);
      await tapText(tester, 'Preoperative considerations');
      expect(find.text('Detailed preoperative fixture.'), findsOneWidget);
      await tapText(tester, 'Collapse all');
      expect(find.text('Detailed preoperative fixture.'), findsNothing);
      expect(find.text('Quick summary stays visible.'), findsOneWidget);
      await tapText(tester, 'Expand all');
      expect(find.text('Recovery keyword fixture.'), findsOneWidget);
      await tapText(tester, 'Home');
      expect(find.text('Tile dashboard'), findsOneWidget);
    },
  );

  testWidgets(
    'search reveals matches without hiding overview; reset restores browsing',
    (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'recovery keyword');
      await tester.pumpAndSettle();
      expect(find.text('Recovery keyword fixture.'), findsOneWidget);
      expect(find.text('Preoperative considerations'), findsNothing);
      expect(find.text('Quick summary stays visible.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'not-present');
      await tester.pumpAndSettle();
      expect(find.text('No matching detailed sections.'), findsOneWidget);
      await tapText(tester, 'Show all sections');
      expect(find.text('Preoperative considerations'), findsOneWidget);
      expect(find.text('Recovery keyword fixture.'), findsNothing);
    },
  );

  testWidgets('source failures are handled and correct URI is passed', (
    tester,
  ) async {
    Uri? visited;
    await tester.pumpWidget(
      app(
        opener: (uri) async {
          visited = uri;
          return false;
        },
      ),
    );
    await tester.pumpAndSettle();
    await tapText(tester, 'Fixture reference');
    expect(visited.toString(), source.url);
    expect(
      find.text('Could not open this source. Check your internet connection.'),
      findsOneWidget,
    );
  });

  testWidgets('changing cases resets expansion and search state', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tapText(tester, 'Expand all');
    await tester.pumpWidget(app(id: 'case-b'));
    await tester.pumpAndSettle();
    expect(find.text('Detailed preoperative fixture.'), findsNothing);
    expect(find.text('Quick summary stays visible.'), findsOneWidget);
  });

  for (final size in [const Size(320, 568), const Size(820, 1180)]) {
    testWidgets('overview and expanded details fit $size at double text size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(app(scale: 2));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tapText(tester, 'Expand all');
      for (final label in [
        'Detailed preoperative fixture.',
        'Recovery keyword fixture.',
      ]) {
        await tester.ensureVisible(find.text(label));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tapText(tester, 'Home');
      expect(find.text('Tile dashboard'), findsOneWidget);
    });
  }
}
