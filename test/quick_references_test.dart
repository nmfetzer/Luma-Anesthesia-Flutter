import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_repository.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_screen.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_shortcut.dart';

const glp = QuickReferenceSection(
  id: 'preop-glp1',
  referenceId: 'pre-op-clearance-guidelines',
  referenceTitle: 'Pre-Op Clearance Guidelines',
  title: 'GLP-1 / GIP–GLP-1: aspiration risk & fasting',
  keywords: [
    'GLP1',
    'semaglutide',
    'Ozempic',
    'tirzepatide',
    'Mounjaro',
    'SPAQI',
  ],
);
const other = QuickReferenceSection(
  id: 'preop-testing',
  referenceId: 'pre-op-clearance-guidelines',
  referenceTitle: 'Pre-Op Clearance Guidelines',
  title: 'ECG, echo, biomarkers & stress testing',
  keywords: ['EKG', 'BNP'],
);

class FakeReferences implements QuickReferenceDataSource {
  final changes = StreamController<void>.broadcast(sync: true);
  bool allowed = true;
  bool failCatalog = false;
  bool failContent = false;
  String? requestedId;
  final List<QuickReferenceSection> rows = [glp, other];
  @override
  Stream<void> get authChanges => changes.stream;
  @override
  Future<List<QuickReferenceSection>> catalog() async {
    if (failCatalog) throw Exception('offline');
    return rows;
  }

  @override
  Future<QuickReferenceContent?> content(String id) async {
    requestedId = id;
    if (failContent) throw Exception('offline');
    if (!allowed) return null;
    return const QuickReferenceContent(
      body:
          '### Targeted content\n\n- Individualize the plan.\n\n'
          '[Guideline](https://pmc.ncbi.nlm.nih.gov/articles/PMC11666732/)',
      version: '2026-09-27',
    );
  }
}

void main() {
  test(
    'repository requests ascending order and paginates past 200 sections',
    () async {
      final requests = <Uri>[];
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        httpClient: MockClient((request) async {
          requests.add(request.url);
          final offset = int.parse(request.url.queryParameters['offset']!);
          final rows = List.generate(
            offset == 0 ? 200 : 1,
            (i) => {
              'id': 'section-${offset + i}',
              'reference_id': 'ref',
              'reference_title': 'Guide',
              'title': 'Section ${offset + i}',
              'keywords': <String>[],
            },
          );
          return http.Response(
            jsonEncode(rows),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      final rows = await SupabaseQuickReferenceRepository(client).catalog();
      expect(rows.length, 201);
      expect(requests.length, 2);
      expect(
        requests.first.queryParameters['order'],
        'reference_id.asc.nullslast,sort_order.asc.nullslast,id.asc.nullslast',
      );
      await client.dispose();
    },
  );
  test('punctuation, case, aliases and multi-field terms resolve sections', () {
    for (final query in [
      'GLP1',
      'glp-1',
      'GLP 1',
      'semaglutide',
      'Ozempic',
      'tirzepatide',
      'Mounjaro',
      'glp1 aspiration',
      'pre op',
    ]) {
      expect(glp.matches(query), isTrue, reason: query);
    }
    expect(glp.matches('BNP'), isFalse);
    expect(glp.matches('unrelated medication'), isFalse);
    expect(other.matches('BNP'), isTrue);
  });

  testWidgets(
    'search opens the matching section directly and retains query on back',
    (tester) async {
      final repo = FakeReferences();
      await tester.pumpWidget(
        MaterialApp(home: QuickReferencesScreen(repository: repo)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pre-Op Clearance Guidelines'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'GLP1');
      await tester.pumpAndSettle();
      expect(find.text('1 matching section'), findsOneWidget);
      expect(find.text(other.title), findsNothing);
      await tester.tap(find.text(glp.title));
      await tester.pumpAndSettle();
      expect(repo.requestedId, 'preop-glp1');
      expect(find.text('Targeted content'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('GLP1'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(
        find.text('Free access · Search a topic or browse a guide.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('browse guide and return to all references', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: QuickReferencesScreen(repository: FakeReferences())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pre-Op Clearance Guidelines'));
    await tester.pumpAndSettle();
    expect(find.text(glp.title), findsOneWidget);
    expect(find.text(other.title), findsOneWidget);
    await tester.tap(find.text('All references'));
    await tester.pumpAndSettle();
    expect(
      find.text('Free access · Search a topic or browse a guide.'),
      findsOneWidget,
    );
  });

  testWidgets('empty search and offline catalog recover', (tester) async {
    final repo = FakeReferences()..failCatalog = true;
    await tester.pumpWidget(
      MaterialApp(home: QuickReferencesScreen(repository: repo)),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('could not load'), findsOneWidget);
    repo.failCatalog = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'xyzmissing');
    await tester.pumpAndSettle();
    expect(find.textContaining('No matching sections'), findsOneWidget);
  });

  testWidgets('unavailable section retries without any sign-in or paywall', (
    tester,
  ) async {
    final repo = FakeReferences();
    await tester.pumpWidget(
      MaterialApp(
        home: QuickReferenceReader(section: glp, repository: repo),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Targeted content'), findsOneWidget);
    repo.allowed = false;
    repo.changes.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Targeted content'), findsNothing);
    expect(find.text('Sign in'), findsNothing);
    expect(find.text('Access options'), findsNothing);
    expect(
      find.textContaining('free and do not require a subscription'),
      findsOneWidget,
    );
    repo.allowed = true;
    repo.changes.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Targeted content'), findsOneWidget);
  });

  testWidgets('auth changes do not gate published free content', (
    tester,
  ) async {
    final repo = FakeReferences();
    await tester.pumpWidget(
      MaterialApp(
        home: QuickReferenceReader(section: glp, repository: repo),
      ),
    );
    await tester.pumpAndSettle();
    repo.changes.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Targeted content'), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);
    expect(find.text('Access options'), findsNothing);
  });

  testWidgets('reader offline error retries without crashing', (tester) async {
    final repo = FakeReferences()..failContent = true;
    await tester.pumpWidget(
      MaterialApp(
        home: QuickReferenceReader(section: glp, repository: repo),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Try again'), findsOneWidget);
    repo.failContent = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Targeted content'), findsOneWidget);
  });

  testWidgets(
    'ivory Quick Ref pill hides on welcome, account, dialogs and references',
    (tester) async {
      final key = GlobalKey<NavigatorState>();
      final observer = QuickReferenceRouteObserver();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          navigatorObservers: [observer],
          builder: (context, child) => QuickReferenceShortcut(
            observer: observer,
            navigatorKey: key,
            child: child!,
          ),
          home: const Scaffold(body: Text('Welcome')),
          routes: {
            '/home': (_) => const Scaffold(body: Text('Home')),
            '/account': (_) => const Scaffold(body: Text('Account')),
            '/quick-references': (_) =>
                const Scaffold(body: Text('References')),
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Quick References'), findsNothing);
      key.currentState!.pushNamed('/home');
      await tester.pumpAndSettle();
      expect(find.text('Quick Ref'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
      final button = tester.widget<ElevatedButton>(
        find.descendant(
          of: find.byTooltip('Quick References'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(
        button.style!.backgroundColor!.resolve({}),
        const Color(0xFFFCFAF6),
      );
      expect(
        button.style!.foregroundColor!.resolve({}),
        const Color(0xFF205D9F),
      );
      expect(button.style!.shape!.resolve({}), isA<StadiumBorder>());
      expect(
        tester.getSize(find.byTooltip('Quick References')).height,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(find.byTooltip('Quick References'));
      await tester.pumpAndSettle();
      expect(find.text('References'), findsOneWidget);
      expect(find.byTooltip('Quick References'), findsNothing);
      key.currentState!.pop();
      await tester.pumpAndSettle();
      key.currentState!.pushNamed('/account');
      await tester.pumpAndSettle();
      expect(find.byTooltip('Quick References'), findsNothing);
      key.currentState!.pop();
      await tester.pumpAndSettle();
      unawaited(
        showDialog<void>(
          context: key.currentContext!,
          builder: (_) => const AlertDialog(content: Text('Dialog')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Quick References'), findsNothing);
      key.currentState!.pop();
      await tester.pumpAndSettle();
      expect(find.byTooltip('Quick References'), findsOneWidget);
    },
  );

  testWidgets('small screen and enlarged text do not overflow', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: QuickReferencesScreen(
          repository: FakeReferences(),
          initialQuery: 'GLP1',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text(glp.title));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
