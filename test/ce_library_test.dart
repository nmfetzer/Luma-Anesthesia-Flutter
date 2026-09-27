import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/ce/ce_library_screen.dart';
import 'package:luma_anesthesia/ce/ce_repository.dart';
import 'package:luma_anesthesia/ce/ce_demo_repository.dart';
import 'package:luma_anesthesia/ce/ce_demo_data.dart';
import 'package:luma_anesthesia/ce/ce_course2_demo_data.dart';
import 'package:luma_anesthesia/ce/ce_course3_demo_data.dart';

class LibraryRepo extends CeRepository {
  LibraryRepo(
    this.courseNumber, {
    this.provider = false,
    this.access = true,
    this.sandbox = false,
  });
  @override
  final int courseNumber;
  bool provider, access, fail = false;
  bool sandbox;
  String? user = 'learner';
  final events = StreamController<String?>.broadcast();
  final calls = <String>[];
  @override
  String? get accountId => user;
  @override
  bool get signedIn => user != null;
  @override
  Stream<String?> get accountChanges => events.stream;
  @override
  Future<Map<String, dynamic>> call(
    String action, [
    Map<String, dynamic> payload = const {},
  ]) async {
    calls.add(action);
    if (fail) throw Exception('network unavailable');
    if (action == 'catalog') {
      return {
        1: demoCatalog,
        2: demoCourse2Catalog,
        3: demoCourse3Catalog,
      }[courseNumber]!;
    }
    if (action == 'access') {
      return {
        'has_access': access,
        'is_provider': provider,
        'is_preview': provider || sandbox,
        'is_sandbox': sandbox,
        'profile': {'full_name': 'Test Learner', 'credentials': 'CRNA'},
        'module_statuses': {
          'course_${courseNumber}_module_1': {
            'read': true,
            'passed': true,
            'completed': true,
          },
        },
      };
    }
    return {};
  }
}

void main() {
  final moduleTiles = find.byWidgetPredicate(
    (w) => w is ListTile && w.key.toString().contains('ce-module-'),
  );
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  Future<List<LibraryRepo>> mount(
    WidgetTester t, {
    double width = 1280,
    bool provider = false,
    bool access = true,
    bool sandbox = false,
  }) async {
    t.view.physicalSize = Size(width, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final repos = [
      for (final n in [1, 2, 3])
        LibraryRepo(n, provider: provider, access: access, sandbox: sandbox),
    ];
    for (final repo in repos) {
      addTearDown(repo.events.close);
    }
    await t.pumpWidget(MaterialApp(home: CeLibraryScreen(repositories: repos)));
    await t.pumpAndSettle();
    return repos;
  }

  for (final width in [320.0, 390.0, 820.0, 1440.0]) {
    testWidgets('library, modules and back fit $width', (t) async {
      await mount(t, width: width);
      expect(find.text('Course library'), findsOneWidget);
      expect(find.text('Open course'), findsNWidgets(3));
      expect(find.text('Provider dashboard'), findsNothing);
      expect(t.takeException(), isNull);
      await t.ensureVisible(find.text('Open course').last);
      await t.tap(find.text('Open course').last);
      await t.pumpAndSettle();
      expect(find.text('Legal Essentials for the CRNA'), findsOneWidget);
      expect(moduleTiles, findsNWidgets(11));
      expect(find.text('Continue module 2'), findsOneWidget);
      expect(find.text('Provider records & exports'), findsNothing);
      expect(find.textContaining('Browse Course'), findsNothing);
      expect(t.takeException(), isNull);
      final moduleTwo = find.byKey(
        const ValueKey('ce-module-course_3_module_2'),
      );
      await t.ensureVisible(moduleTwo);
      await t.tap(moduleTwo);
      await t.pumpAndSettle();
      expect(moduleTiles, findsNothing);
      expect(find.text('Read learner content'), findsOneWidget);
      expect(find.textContaining('Informed Consent'), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.tap(find.byTooltip('Back to course'));
      await t.pumpAndSettle();
      await t.tap(find.text('All courses'));
      await t.pumpAndSettle();
      expect(find.text('Course library'), findsOneWidget);
      await t.tap(find.text('My certificates'));
      await t.pumpAndSettle();
      expect(find.text('View certificate & requirements'), findsNWidgets(3));
      expect(t.takeException(), isNull);
    });
  }
  testWidgets('sandbox preview never exposes the provider dashboard', (
    t,
  ) async {
    await mount(t, sandbox: true);
    expect(find.textContaining('Sandbox preview'), findsNWidgets(3));
    expect(find.text('Provider dashboard'), findsNothing);
    expect(find.textContaining('Creator access'), findsNothing);
    await t.tap(find.text('Open course').first);
    await t.pumpAndSettle();
    expect(
      find.textContaining('Apple sandbox preview is unlocked'),
      findsOneWidget,
    );
  });
  testWidgets('provider dashboard is separate and disappears on sign out', (
    t,
  ) async {
    final repos = await mount(t, provider: true);
    expect(find.text('Provider dashboard'), findsOneWidget);
    await t.tap(find.text('Provider dashboard'));
    await t.pumpAndSettle();
    expect(find.text('Records & monthly exports'), findsNWidgets(3));
    expect(find.text('Open course'), findsNothing);
    for (final repo in repos) {
      repo.user = null;
      repo.events.add(null);
    }
    await t.pumpAndSettle();
    expect(find.text('Provider dashboard'), findsNothing);
    expect(find.text('Course library'), findsOneWidget);
    expect(find.textContaining('preview modules'), findsNothing);
  });
  testWidgets('locked course exposes no content or registration bypass', (
    t,
  ) async {
    final repos = await mount(t, access: false);
    await t.tap(find.text('View course').first);
    await t.pumpAndSettle();
    expect(find.text('View CE purchase options'), findsOneWidget);
    expect(find.text('Read learner content'), findsNothing);
    expect(find.text('Edit course registration'), findsNothing);
    expect(moduleTiles, findsNWidgets(11));
    expect(t.widget<ListTile>(moduleTiles.first).onTap, isNull);
    expect(
      repos.first.calls.any(
        (c) => ['document', 'quiz', 'profile', 'issue'].contains(c),
      ),
      false,
    );
  });
  testWidgets('failed refresh removes stale progress and supports retry', (
    t,
  ) async {
    final repos = await mount(t);
    repos.first.fail = true;
    await t.tap(find.byTooltip('Refresh course access'));
    await t.pumpAndSettle();
    expect(find.text('Access unavailable'), findsOneWidget);
    expect(find.text('Retry access'), findsOneWidget);
    repos.first.fail = false;
    await t.tap(find.text('Retry access'));
    await t.pumpAndSettle();
    expect(find.text('Retry access'), findsNothing);
    expect(find.text('Open course'), findsNWidgets(3));
  });
  testWidgets('course quiz keeps two-answer hints after library navigation', (
    t,
  ) async {
    final repo = DemoCeRepository(
      courseNumber: 3,
      catalog: demoCourse3Catalog,
      questionBanks: demoCourse3Banks,
    );
    await repo.call('demo_unlock');
    await repo.call('profile', {
      'full_name': 'Preview Learner',
      'credentials': 'CRNA',
    });
    await repo.call('read');
    t.view.physicalSize = const Size(1280, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(home: CeLibraryScreen(repositories: [repo])),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('Open course'));
    await t.pumpAndSettle();
    await t.tap(find.text('Continue module 1'));
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Start or resume assessment'));
    await t.tap(find.text('Start or resume assessment'));
    await t.pumpAndSettle();
    final hint = find.text('Use hint: eliminate 2 wrong answers');
    expect(hint, findsOneWidget);
    await t.ensureVisible(hint);
    await t.tap(hint);
    await t.pumpAndSettle();
    expect(
      find.text('Hint used: two incorrect choices removed'),
      findsOneWidget,
    );
    final options = [
      'A',
      'B',
      'C',
      'D',
    ].where((letter) => find.text(letter).evaluate().isNotEmpty);
    expect(options.length, 2);
    expect(t.takeException(), isNull);
  });
}
