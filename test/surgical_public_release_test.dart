import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/main.dart';
import 'package:luma_anesthesia/home/home_screen.dart';
import 'package:luma_anesthesia/home/home_tile.dart';
import 'package:luma_anesthesia/home/home_menu_drawer.dart';
import 'package:luma_anesthesia/launch/launch_scope.dart';
import 'package:luma_anesthesia/surgical_prep/surgical_public_text.dart';
import 'package:luma_anesthesia/surgical_prep/surgical_catalog.dart';
import 'package:luma_anesthesia/surgical_prep/surgical_library_screen.dart';
import 'package:luma_anesthesia/surgical_prep/surgical_case_screen.dart';
import 'package:luma_anesthesia/screens/subscription_screen.dart';
import 'package:luma_anesthesia/theme/luma_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pas = 'placenta-accreta-spectrum-pas-cesarean-hysterectomy';
  const gyn = 'gynecology-anesthesia-framework';
  const cardiac = 'high-risk-obstetric-anesthesia-cardiac-disease-in-pregnancy';
  final records = (jsonDecode(
    File('assets/data/surgical_cases.json').readAsStringSync(),
  ) as List).cast<Map<String, dynamic>>();
  Map<String, dynamic> record(String id) =>
      records.firstWhere((r) => r['id'] == id);
  String body(String id, String sid) =>
      ((record(id)['sections'] as List).firstWhere(
                (s) => s['id'] == sid,
              )['bullets']
              as List)
          .join(' ');
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('surgical case prep is public; other deferred sections stay closed', () {
    expect(LaunchScope.isDeferred('/surgical-prep'), false);
    expect(LaunchScope.isDeferred('/surgical-prep/specialty/obstetric'), false);
    for (final path in ['/luma-ai', '/ekg', '/luma-academy']) {
      expect(LaunchScope.isDeferred(path), true);
    }
    expect(
      File('scripts/build_surgical_testflight_review.sh').existsSync(),
      false,
    );
  });
  test(
    'public text drops draft status wording and keeps clinical release',
    () async {
      final cases = await SurgicalCatalog.load();
      final shown = [
        for (final c in cases.values) ...[
          c.category,
          for (final s in [c.overview, ...c.sections]) ...s.bullets,
        ],
      ].join(' ');
      for (final internal in [
        'review draft',
        'clinical-review draft',
        'Clinical draft',
        'owner review',
        'available for review only',
        'review before release',
        'review is required before release',
        'essential before release',
        'authorize release',
      ]) {
        expect(shown, isNot(contains(internal)), reason: internal);
      }
      expect(shown, contains('Before release, discuss staged reperfusion'));
      expect(shown, contains('before release/completion'));
      expect(shown, contains('signoff has not been recorded'));
      expect(
        publicSurgicalText(
          'Adult clinical review draft, not a patient-specific order set.',
        ),
        'Adult clinical reference, not a patient-specific order set.',
      );
      expect(
        publicSurgicalBullets([
          'This remains a clinical-review draft. Evidence reconciliation, software testing and source integration do not establish independent clinician approval or authorize release.',
        ]),
        isEmpty,
      );
    },
  );
  test('nine recorded source updates preserve identities and draft status', () {
    final ledger = jsonDecode(
      File('docs/surgical-testflight-2026-10-08/correction-ledger.json')
          .readAsStringSync(),
    ) as Map;
    expect(ledger['clinicalApproval'], false);
    expect(ledger['nativeUpload'], false);
    expect(ledger['records'], hasLength(9));
    expect(records, hasLength(350));
    for (final row in ledger['records'] as List) {
      expect(record(row['id'] as String), row['after']);
      expect(row['after']['clinicalStatus'], 'draft');
      expect(row['after']['category'], row['before']['category']);
      expect(row['after']['reviewNotice'], isNotEmpty);
    }
  });
  test(
    'ERAS full text replaces blocked status without hiding GLP-1 difference',
    () {
      expect(
        body(gyn, 'eras-verification'),
        contains('prior full-text access hold is closed'),
      );
      expect(
        body(gyn, 'eras-verification'),
        isNot(contains('could not be verified')),
      );
      expect(body(gyn, 'glp1-guidance'), contains('differs from'));
      expect(
        body(gyn, 'glp1-guidance'),
        contains('not translate either statement'),
      );
      expect(
        body(gyn, 'glp1-guidance'),
        contains('not prove an empty stomach'),
      );
    },
  );
  test('oncology updates distinguish laparotomy, MIS and neuraxial timing', () {
    for (final id in [
      gyn,
      'gynecologic-oncology-staging-laparotomy',
      'ovarian-cancer-debulking-cytoreductive-surgery',
      'radical-hysterectomy',
      'pelvic-exenteration',
    ]) {
      expect(body(id, 'vte'), contains('28-day'));
      expect(body(id, 'vte'), contains('not automatically extend'));
      expect(body(id, 'vte'), contains('at least 12 hours'));
      expect(body(id, 'vte'), contains('catheter removal before LMWH'));
      expect(body(id, 'pain'), contains('more than two antiemetic agents'));
      expect(body(id, 'fluids'), contains('goal-directed'));
    }
  });
  test('PAS is attributed, urgent exceptions retained, discrepancy not declared closed', () {
    expect(body(pas, 'timing-source-hold'), contains('ACOG/SMFM'));
    expect(body(pas, 'timing-source-hold'), contains('34+0–35+6'));
    expect(body(pas, 'timing-source-hold'), contains('preeclampsia'));
    expect(
      body(pas, 'timing-source-hold'),
      contains('No authoritative correction'),
    );
    expect(body(pas, 'timing-source-hold'), contains('Do not average'));
  });
  test('specialist checks are not represented as signoff', () {
    for (final id in [
      'lvad-placement-left-ventricular-assist-device',
      'ecmo-cannulation-decannulation',
      cardiac,
    ]) {
      expect(
        record(id)['reviewNotice'],
        contains('Specialist signoff pending'),
      );
      expect(body(id, 'evidence'), contains('signoff has not been recorded'));
    }
  });
  test('new content is indexed and all review notices reach model', () async {
    final cases = await SurgicalCatalog.load();
    expect(cases, hasLength(351));
    expect(cases[pas]!.reviewNotice, contains('RCOG'));
    expect(searchSurgicalCases('GLP1').map((r) => r.id), contains(gyn));
    expect(searchSurgicalCases('Caprini').map((r) => r.id), contains(gyn));
  });
  testWidgets(
    'real main routes open surgical prep with the real access check',
    (tester) async {
      await tester.pumpWidget(const LumaApp());
      await tester.pump(const Duration(milliseconds: 500));
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final context = tester.element(find.byType(MaterialApp));
      for (final path in [
        '/surgical-prep',
        '/surgical-prep/',
        '/surgical-prep/$pas',
        '/surgical-prep/specialty/obstetric',
        '/surgical-prep?review=true',
      ]) {
        final route = app.onGenerateRoute!(
          RouteSettings(name: path),
        ) as MaterialPageRoute;
        final screen = route.builder(context);
        expect(screen, isA<SurgicalPrepFeature>());
        expect((screen as SurgicalPrepFeature).checkAccess, isNull);
        expect(screen.accessChanges, isNull);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  for (final id in [null, pas, 'specialty/obstetric']) {
    testWidgets(
      'public release never grants unpaid access to ${id ?? 'catalog'}',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildLumaTheme(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: SurgicalPrepFeature(
              caseId: id,
              checkAccess: () async => false,
              accessChanges: const Stream.empty(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(SubscriptionScreen), findsOneWidget);
        expect(find.text('Quick clinical overview'), findsNothing);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  testWidgets('home and drawer show surgical case prep on small phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(2),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    final tile = find.byWidgetPredicate(
      (w) => w is HomeTile && w.data.route == '/surgical-prep',
    );
    expect(tile, findsOneWidget);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    expect(tile.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HomeMenuDrawer())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Surgical Case Prep'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('case warning visible above overview, including at large text', (
    tester,
  ) async {
    final cases = await SurgicalCatalog.load();
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLumaTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(2),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: SurgicalCaseScreen(
          reference: cases[pas]!,
          checkAccess: () async => true,
          accessChanges: const Stream.empty(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final notice = find.byKey(const ValueKey('surgical-review-notice'));
    expect(notice, findsOneWidget);
    expect(
      tester.getTopLeft(notice).dy,
      lessThan(tester.getTopLeft(find.text('Quick clinical overview')).dy),
    );
    await tester.ensureVisible(notice);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
