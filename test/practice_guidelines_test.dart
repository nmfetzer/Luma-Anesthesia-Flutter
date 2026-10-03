import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:luma_anesthesia/launch/launch_scope.dart';
import 'package:luma_anesthesia/practice_guidelines/practice_guideline.dart';
import 'package:luma_anesthesia/practice_guidelines/practice_guideline_repository.dart';
import 'package:luma_anesthesia/practice_guidelines/practice_guidelines_screen.dart';
import 'package:luma_anesthesia/theme/luma_theme.dart';

final raw = jsonDecode(
  File('assets/data/practice_guidelines.json').readAsStringSync(),
) as List<dynamic>;
final catalog = PracticeGuidelineRepository.parse(raw);

class TestBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      jsonEncode(raw);
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(utf8.encode(jsonEncode(raw)));
}

class RecordingLauncher extends UrlLauncherPlatform {
  @override
  LinkDelegate? get linkDelegate => null;
  String? url;
  bool succeeds = true;
  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    this.url = url;
    return succeeds;
  }
}

PracticeGuidelineRepository offlineRepository() => PracticeGuidelineRepository(
  bundle: TestBundle(),
  remoteLoader: () async => throw const SocketException('Offline'),
);

Widget app(Widget screen, {double scale = 1}) => MaterialApp(
  theme: buildLumaTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: screen,
  routes: {'/home': (_) => const Scaffold(body: Text('Tile dashboard'))},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sanitized Base44 import has all 229 unique references', () {
    expect(catalog, hasLength(229));
    expect(catalog.where((r) => r.organization == 'ASA'), hasLength(126));
    expect(catalog.where((r) => r.organization == 'AANA'), hasLength(81));
    expect(catalog.where((r) => r.organization == 'CAA'), hasLength(22));
    expect(catalog.where((r) => r.linkKind == 'search'), hasLength(41));
    for (final row in raw.cast<Map>()) {
      expect(row.keys.toSet(), {
        'id',
        'organization',
        'publisher',
        'title',
        'category',
        'url',
        'hub_url',
        'link_kind',
        'keywords',
      });
      expect(row.containsKey('created_by'), isFalse);
    }
    expect(LaunchScope.isDeferred('/practice-guidelines'), isFalse);
  });

  test('only HTTPS publisher URLs are accepted', () {
    for (final url in [
      'javascript:alert(1)',
      'http://www.aana.com/',
      'https://evil.com/',
      'https://www.aana.com.evil.com/',
      'https://person@www.aana.com/',
      'https://www.aana.com:8443/',
      '/relative',
    ]) {
      expect(PracticeGuideline.safeUrl(url), isFalse);
      expect(
        () => PracticeGuideline.fromJson({
          ...raw.first as Map<String, dynamic>,
          'url': url,
        }),
        throwsFormatException,
      );
    }
    for (final entry in catalog) {
      expect(PracticeGuideline.safeUrl(entry.url), isTrue);
      expect(PracticeGuideline.safeUrl(entry.hubUrl), isTrue);
    }
  });

  test('multi-word search is case/punctuation insensitive', () {
    final record = catalog.firstWhere(
      (r) => r.title == 'Basic Standards for Preanesthesia Care',
    );
    expect(record.matches(' ASA   preanesthesia '), isTrue);
    expect(record.matches('preanesthesia no-such-term'), isFalse);
    expect(record.matches(''), isTrue);
  });

  test('full catalog is available without a network connection', () async {
    final repository = offlineRepository();
    expect(await repository.bundled(), hasLength(229));
    expect(await repository.refresh(catalog), isNull);
  });

  test(
    'invalid or incomplete server records do not erase bundled catalog',
    () async {
      for (final rows in [
        <dynamic>[],
        [raw.first],
        [...raw, raw.first],
        [
          {...raw.first as Map<String, dynamic>, 'url': 'https://evil.com'},
        ],
      ]) {
        final repository = PracticeGuidelineRepository(
          bundle: TestBundle(),
          remoteLoader: () async => rows,
        );
        expect(await repository.refresh(catalog), isNull);
      }
      final valid = PracticeGuidelineRepository(
        bundle: TestBundle(),
        remoteLoader: () async => raw,
      );
      expect(await valid.refresh(catalog), hasLength(229));
    },
  );

  testWidgets(
    'group filters, as-you-type search, category, clear and empty states',
    (tester) async {
      await tester.pumpWidget(
        app(PracticeGuidelinesScreen(repository: offlineRepository())),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'CAA'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Certified Anesthesiologist Assistant resources'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), 'code of conduct');
      await tester.pumpAndSettle();
      expect(find.text('NCCAA Code of Conduct'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'not a real reference');
      await tester.pumpAndSettle();
      expect(find.textContaining('No matching references'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'ASA'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Standard').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'preanesthesia');
      await tester.pumpAndSettle();
      expect(
        find.text('Basic Standards for Preanesthesia Care'),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.text('Basic Standards for Preanesthesia Care'),
      );
      await tester.tap(find.text('Basic Standards for Preanesthesia Care'));
      await tester.pumpAndSettle();
      expect(find.byType(PracticeGuidelineDetail), findsOneWidget);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Tile dashboard'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'search link is explicitly labeled and opens original publisher URL',
    (tester) async {
      final launcher = RecordingLauncher();
      UrlLauncherPlatform.instance = launcher;
      final entry = catalog.firstWhere((r) => r.linkKind == 'search');
      await tester.pumpWidget(app(PracticeGuidelineDetail(item: entry)));
      await tester.pumpAndSettle();
      expect(find.textContaining('not a specific document'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Search AANA'));
      await tester.pumpAndSettle();
      expect(launcher.url, entry.url);
      launcher.succeeds = false;
      await tester.tap(find.widgetWithText(FilledButton, 'Search AANA'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Could not open'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Browse publisher directory'),
        350,
      );
      launcher.succeeds = true;
      await tester.tap(find.text('Browse publisher directory'));
      await tester.pumpAndSettle();
      expect(launcher.url, entry.hubUrl);
    },
  );

  for (final size in [
    const Size(320, 568),
    const Size(375, 812),
    const Size(820, 1180),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('directory and long detail fit $size at $scale text', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          app(
            PracticeGuidelinesScreen(repository: offlineRepository()),
            scale: scale,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Home').hitTestable(), findsOneWidget);
        await tester.ensureVisible(
          find.byType(DropdownButtonFormField<String>),
        );
        await tester.pumpAndSettle();
        expect(
          find.byType(DropdownButtonFormField<String>).hitTestable(),
          findsOneWidget,
        );
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('All categories').last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final longest = catalog.reduce(
          (a, b) => a.title.length > b.title.length ? a : b,
        );
        await tester.pumpWidget(
          app(PracticeGuidelineDetail(item: longest), scale: scale),
        );
        await tester.pumpAndSettle();
        expect(find.text('Home').hitTestable(), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Browse publisher directory'),
          350,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
