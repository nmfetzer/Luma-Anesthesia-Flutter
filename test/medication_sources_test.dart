import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:luma_anesthesia/models/medication.dart';
import 'package:luma_anesthesia/screens/drug_detail_screen.dart'
    as drug_library;
import 'package:luma_anesthesia/vasopressors/drug_detail_screen.dart' as vaso;
import 'package:luma_anesthesia/widgets/clinical_source_link.dart';
import 'package:luma_anesthesia/widgets/medication_deep_dive.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class RecordingLauncher extends UrlLauncherPlatform {
  @override
  LinkDelegate? get linkDelegate => null;
  String? lastUrl;
  LaunchOptions? lastOptions;
  bool fail = false;
  bool throwError = false;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    lastUrl = url;
    lastOptions = options;
    if (throwError) throw StateError('No browser');
    return !fail;
  }
}

class MemoryAuthStorage extends GotrueAsyncStorage {
  @override
  Future<String?> getItem({required String key}) async => null;
  @override
  Future<void> setItem({required String key, required String value}) async {}
  @override
  Future<void> removeItem({required String key}) async {}
}

void main() {
  const url = 'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=test';
  final row = {
    'id': 'test',
    'name': 'Source fixture',
    'sources': [
      jsonEncode(
          {'number': 1, 'tier': 1, 'citation': 'Direct label', 'url': url}),
    ],
  };
  late RecordingLauncher launcher;

  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test',
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: MemoryAuthStorage(),
        autoRefreshToken: false,
        detectSessionInUri: false,
      ),
    );
  });
  tearDownAll(() => Supabase.instance.dispose());
  setUp(() {
    launcher = RecordingLauncher();
    UrlLauncherPlatform.instance = launcher;
  });

  test('imported JSON source strings and numeric tiers survive parsing', () {
    final med = Medication.fromJson(row);
    expect(med.sources, hasLength(1));
    expect(med.sources.single.tier, '1');
    expect(med.sources.single.url, url);
  });

  test('mixed formats sort, while malformed data does not crash', () {
    final sources = MedicationSource.parseList([
      {'number': '2', 'tier': 'primary', 'citation': 'Second'},
      '{"number":1,"citation":"First","url":" https://example.com "}',
      'not json',
      '[]',
      null,
      4,
    ]);
    expect(sources.map((s) => s.citation), ['First', 'Second']);
    expect(sources.first.url, 'https://example.com');
    expect(MedicationSource.parseList(null), isEmpty);
  });

  test('only absolute HTTP and HTTPS source links are enabled', () {
    for (final invalid in [
      null,
      '',
      '/relative',
      'https:',
      'javascript:alert(1)',
      'file:///tmp/a'
    ]) {
      expect(ClinicalSourceLink.validUri(invalid), isNull);
    }
    expect(ClinicalSourceLink.validUri(url)?.host, 'dailymed.nlm.nih.gov');
  });

  testWidgets('authorized Deep Dive links use the same safe external launcher',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MedicationDeepDive(
          medicationId: 'test',
          load: () async => {
            'allowed': true,
            'body': '## References\n[Human prescribing information]($url)',
          },
        ),
      ),
    ));
    expect(find.byType(MarkdownBody), findsNothing);
    await tester.tap(find.text('Open Deep Dive'));
    await tester.pumpAndSettle();
    final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
    markdown.onTapLink!('Human prescribing information', url, '');
    await tester.pumpAndSettle();
    expect(launcher.lastUrl, url);
    expect(launcher.lastOptions?.webOnlyWindowName, '_blank');
    expect(tester.takeException(), isNull);
  });

  for (final route in ['library', 'vasopressors']) {
    testWidgets('$route renders imported citation and opens its exact URL',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: route == 'library'
            ? drug_library.DrugDetailScreen(
                medication: Medication.fromJson(row))
            : vaso.DrugDetailScreen(drug: row),
      ));
      await tester.pumpAndSettle();
      if (route == 'library') {
        await tester.scrollUntilVisible(find.text('Sources'), 300);
        await tester.tap(find.text('Sources'));
        await tester.pumpAndSettle();
      }
      await tester.scrollUntilVisible(find.text('Direct label'), 300);
      await tester.ensureVisible(find.text('Direct label'));
      await tester.tap(find.text('Direct label'));
      await tester.pumpAndSettle();
      expect(launcher.lastUrl, url);
      expect(launcher.lastOptions?.webOnlyWindowName, '_blank');
      expect(tester.takeException(), isNull);
    });
  }

  for (final throws in [false, true]) {
    testWidgets('failed source launch gives feedback, exception=$throws',
        (tester) async {
      launcher.fail = true;
      launcher.throwError = throws;
      await tester.pumpWidget(const MaterialApp(
        home:
            Scaffold(body: ClinicalSourceLink(url: url, child: Text('Label'))),
      ));
      await tester.tap(find.text('Label'));
      await tester.pump();
      expect(find.text('Could not open $url'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
