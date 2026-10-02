import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/data/drug_reference_updates.dart';
import 'package:luma_anesthesia/models/medication.dart';
import 'package:luma_anesthesia/widgets/drug_reference_updates_panel.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'medication_sources_test.dart' show RecordingLauncher;

Map<String, dynamic> fixture({List<Map<String, dynamic>> fdaRows = const []}) =>
    {
      'schema': 1,
      'fda': {
        'state': 'ok',
        'checked_at': DateTime.now().toUtc().toIso8601String(),
        'source_updated': '2026-10-01',
        'total': fdaRows.length,
        'rows': fdaRows,
      },
      'dailymed': {
        'state': 'ok',
        'checked_at': DateTime.now().toUtc().toIso8601String(),
        'rows': <Map<String, dynamic>>[],
        'total': 0,
      },
    };

class FakeGateway implements DrugReferenceGateway {
  int calls = 0;
  bool fail = false;
  bool storageFails = false;
  DrugReferenceSnapshot? cache;
  DrugReferenceSnapshot result = DrugReferenceSnapshot(fixture());
  @override
  Future<DrugReferenceSnapshot?> saved(String id) async {
    if (storageFails) throw StateError('Storage blocked');
    return cache;
  }

  @override
  Future<DrugReferenceSnapshot> refresh(String id) async {
    calls++;
    if (fail) throw StateError('offline');
    return result;
  }
}

void main() {
  late FakeGateway gateway;
  setUp(() => gateway = FakeGateway());
  test(
    'real gateway deduplicates, completes, saves and permits a later refresh',
    () async {
      SharedPreferences.setMockInitialValues({});
      final completer = Completer<Map<String, dynamic>>();
      var calls = 0;
      final real = SupabaseDrugReferenceGateway.withTransport((_) {
        calls++;
        return completer.future;
      });
      final first = real.refresh('drug');
      final second = real.refresh('drug');
      expect(identical(first, second), true);
      completer.complete(fixture());
      await first.timeout(const Duration(seconds: 3));
      await second.timeout(const Duration(seconds: 3));
      expect(calls, 1);
      expect((await real.saved('drug'))?.savedOnly, true);
      await real.refresh('drug').timeout(const Duration(seconds: 3));
      expect(calls, 2);
    },
  );
  test(
    'real gateway preserves a good saved source through partial failure',
    () async {
      SharedPreferences.setMockInitialValues({});
      final real = SupabaseDrugReferenceGateway.withTransport(
        (_) async => fixture(),
      );
      await real.refresh('drug').timeout(const Duration(seconds: 3));
      final failed = SupabaseDrugReferenceGateway.withTransport(
        (_) async => {
          ...fixture(),
          'fda': {'state': 'unavailable', 'rows': []},
        },
      );
      final result = await failed
          .refresh('drug')
          .timeout(const Duration(seconds: 3));
      expect(result.source('fda')['state'], 'ok');
      expect(result.source('fda')['refresh_failed'], true);
    },
  );
  test(
    'malformed saved metadata is ignored without blocking online access',
    () async {
      SharedPreferences.setMockInitialValues({
        'luma_drug_reference_v1_bad': 'invalid json',
      });
      expect(await SupabaseDrugReferenceGateway.instance.saved('bad'), isNull);
    },
  );
  Future<void> render(WidgetTester t, {double scale = 1}) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: SingleChildScrollView(
              child: DrugReferenceUpdatesPanel(
                medication: Medication.fromJson({
                  'id': 'propofol',
                  'name': 'Propofol',
                }),
                gateway: gateway,
              ),
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  Future<void> expand(WidgetTester t) async {
    await t.tap(find.text('Shortages & official labeling'));
    await t.pumpAndSettle();
  }

  test(
    'timestamp age, failed refresh, saved-only and missing dates are stale',
    () {
      final now = DateTime.utc(2026, 10, 2);
      final data = fixture();
      data['fda']['checked_at'] = '2026-10-01T13:00:00Z';
      expect(DrugReferenceSnapshot(data).isStale('fda', now: now), false);
      expect(
        DrugReferenceSnapshot(data, savedOnly: true).isStale('fda', now: now),
        true,
      );
      data['fda']['checked_at'] = '2026-09-29T00:00:00Z';
      expect(DrugReferenceSnapshot(data).isStale('fda', now: now), true);
      expect(const DrugReferenceSnapshot({}).isStale('fda'), true);
    },
  );
  testWidgets(
    'no provider call until expanded; empty result never says no shortage',
    (t) async {
      await render(t);
      expect(gateway.calls, 0);
      await expand(t);
      expect(gateway.calls, 1);
      expect(
        find.textContaining('This does not confirm availability'),
        findsOneWidget,
      );
      expect(find.text('No shortage'), findsNothing);
      await t.tap(find.text('Shortages & official labeling'));
      await t.pumpAndSettle();
      await expand(t);
      expect(gateway.calls, 1);
    },
  );
  testWidgets('storage failure still permits online refresh', (t) async {
    gateway.storageFails = true;
    await render(t);
    await expand(t);
    expect(gateway.calls, 1);
    expect(
      find.textContaining('This does not confirm availability'),
      findsOneWidget,
    );
    expect(t.takeException(), isNull);
  });
  testWidgets('outage displays saved warning and never advances last checked', (
    t,
  ) async {
    final data = fixture();
    data['fda']['checked_at'] = '2026-09-01T00:00:00Z';
    gateway.cache = DrugReferenceSnapshot(data, savedOnly: true);
    gateway.fail = true;
    await render(t);
    await expand(t);
    expect(find.textContaining('Could not refresh'), findsOneWidget);
    expect(find.textContaining('Saved information'), findsWidgets);
    expect(find.text('Last checked: 2026-09-01 00:00 UTC'), findsOneWidget);
  });
  testWidgets('uncached failure has fallback links and retry', (t) async {
    gateway.fail = true;
    await render(t);
    await expand(t);
    expect(find.textContaining('Updates are unavailable'), findsNWidgets(2));
    expect(find.text('Open FDA shortage database'), findsOneWidget);
    await t.ensureVisible(find.text('Check for updates'));
    await t.tap(find.text('Check for updates'));
    await t.pumpAndSettle();
    expect(gateway.calls, 2);
  });
  testWidgets(
    'shows formulation and distinct report/availability statuses; safe links work',
    (t) async {
      gateway.result = DrugReferenceSnapshot(
        fixture(
          fdaRows: [
            {
              'title': 'Drug injection',
              'status': 'Current',
              'availability': 'Available',
              'presentation': '1 mg/mL',
              'company': 'Manufacturer',
              'ndc': '123-45-67',
              'url': 'https://api.fda.gov/drug/shortages.json?search=example',
            },
          ],
        ),
      );
      final launcher = RecordingLauncher();
      UrlLauncherPlatform.instance = launcher;
      await render(t);
      await expand(t);
      expect(find.text('FDA report status: Current'), findsOneWidget);
      expect(find.text('Product availability: Available'), findsOneWidget);
      expect(find.text('Presentation: 1 mg/mL'), findsOneWidget);
      await t.ensureVisible(find.text('View FDA source record'));
      await t.tap(find.text('View FDA source record'));
      await t.pumpAndSettle();
      expect(launcher.lastUrl, startsWith('https://api.fda.gov/'));
    },
  );
  testWidgets(
    '320px and 200% text have no overflow; untrusted source URL is not clickable',
    (t) async {
      t.view.physicalSize = const Size(320, 640);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      gateway.result = DrugReferenceSnapshot(
        fixture(
          fdaRows: [
            {
              'title': 'Long formulation name with multiple clinically relevant words',
              'url': 'https://example.com/untrusted',
            },
          ],
        ),
      );
      await render(t, scale: 2);
      await expand(t);
      expect(find.text('View FDA source record'), findsNothing);
      expect(t.takeException(), isNull);
    },
  );
}
