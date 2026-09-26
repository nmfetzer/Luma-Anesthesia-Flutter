import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/crisis/provider_support_screen.dart';
import 'package:luma_anesthesia/crisis/crisis_screen.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'crisis_hub_test.dart' show FakeCrisis, CrisisSourceLauncher;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  final payload = File('assets/data/provider_support.json').readAsStringSync();
  final data = jsonDecode(payload) as Map;
  test('all jurisdictions, citations, and explicit treatment gaps are retained',
      () {
    final states = (data['states'] as List).cast<Map>();
    expect(states.map((e) => e['state']).toSet().length, 51);
    expect(states.where((e) => e['state'] == 'Wisconsin').single['note'],
        contains('not a Wisconsin PHP'));
    expect((data['facilities'] as List).length, 4);
    expect((data['sections'] as List).length, 7);
    expect(payload, contains('November 30, 2025'));
    expect(payload, contains('not a 24/7 emergency line'));
    for (final row in states) {
      expect(Uri.parse(row['source'] as String).scheme, 'https');
    }
  });
  for (final width in [390.0, 1200.0]) {
    testWidgets(
        'public support renders and launches only requested contacts at $width',
        (t) async {
      t.view.physicalSize = Size(width, 844);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final launcher = CrisisSourceLauncher();
      UrlLauncherPlatform.instance = launcher;
      await t.pumpWidget(MaterialApp(
          home: ProviderSupportScreen(
        loadContent: () async => Map<String, dynamic>.from(data),
      )));
      await t.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await t.pumpAndSettle();
      expect(find.text('Call 988'), findsOneWidget);
      expect(find.textContaining('Free access, no account required.'),
          findsOneWidget);
      expect(launcher.opened, isNull);
      await t.tap(find.text('Call 988'));
      await t.pumpAndSettle();
      expect(launcher.opened, 'tel:988');
      await t.tap(find.text('Text 988'));
      await t.pumpAndSettle();
      expect(launcher.opened, 'sms:988');
      await t.ensureVisible(find.text('988 chat and crisis support'));
      await t.tap(find.text('988 chat and crisis support'));
      await t.pumpAndSettle();
      expect(launcher.opened, 'https://988lifeline.org/');
      expect(t.takeException(), isNull);
    });
  }
  testWidgets(
      'state picker filters facilities and clear restores the selection',
      (t) async {
    t.view.physicalSize = const Size(1200, 1600);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(MaterialApp(
        home: ProviderSupportScreen(
      loadContent: () async => Map<String, dynamic>.from(data),
    )));
    await t.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await t.pumpAndSettle();
    await t.ensureVisible(find.byKey(const ValueKey('support-state')));
    await t.tap(find.byKey(const ValueKey('support-state')));
    await t.pumpAndSettle();
    await t.scrollUntilVisible(find.text('Indiana').last, 300,
        scrollable: find.byType(Scrollable).last);
    await t.tap(find.text('Indiana').last);
    await t.pumpAndSettle();
    expect(find.text('Parkdale Center · Indiana'), findsOneWidget);
    expect(find.text('Geisinger Marworth · Pennsylvania'), findsNothing);
    expect(
        find.text(
            'Indiana State Medical Association Physician Assistance Program'),
        findsOneWidget);
    await t.ensureVisible(find.text('Clear state filter'));
    await t.tap(find.text('Clear state filter'));
    await t.pumpAndSettle();
    expect(find.text('Geisinger Marworth · Pennsylvania'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets(
      'support remains reachable from Crisis Hub during database failure',
      (t) async {
    final repo = FakeCrisis()..fail = true;
    addTearDown(repo.events.close);
    await t.pumpWidget(MaterialApp(home: CrisisHubScreen(repository: repo)));
    await t.pumpAndSettle();
    expect(find.text('Mental Health & Recovery Support'), findsOneWidget);
    await t.tap(find.text('Mental Health & Recovery Support'));
    await t.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await t.pumpAndSettle();
    expect(find.text('Call 988'), findsOneWidget);
    expect(find.text('View subscription options'), findsNothing);
    expect(t.takeException(), isNull);
  });
  testWidgets('asset failure never hides immediate help', (t) async {
    await t.pumpWidget(MaterialApp(
        home: ProviderSupportScreen(
      loadContent: () async => throw StateError('unavailable'),
    )));
    await t.pumpAndSettle();
    expect(find.text('Call 988'), findsOneWidget);
    await t.scrollUntilVisible(
        find.textContaining('The full directory could not load.'), 300);
    expect(find.textContaining('The full directory could not load.'),
        findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
