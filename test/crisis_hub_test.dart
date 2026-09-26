import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/crisis/crisis_repository.dart';
import 'package:luma_anesthesia/crisis/crisis_screen.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';

class CrisisSourceLauncher extends UrlLauncherPlatform {
  @override
  LinkDelegate? get linkDelegate => null;
  String? opened;
  LaunchOptions? options;
  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    opened = url;
    this.options = options;
    return true;
  }
}

const mh = CrisisEntry(
    slug: 'mh',
    title: 'Malignant Hyperthermia',
    category: 'toxicity',
    searchTerms: 'MH');
const airway = CrisisEntry(
    slug: 'cico',
    title: 'CICO',
    category: 'airway',
    searchTerms: "Can't Intubate Can't Oxygenate");

class FakeCrisis implements CrisisDataSource {
  bool reviewer = false;
  bool fail = false;
  final events = StreamController<void>.broadcast();
  @override
  Stream<void> get authChanges => events.stream;
  @override
  Future<List<CrisisEntry>> catalog() async {
    if (fail) throw StateError('offline');
    return [mh, airway];
  }

  @override
  Future<CrisisAccess> access() async => CrisisAccess(reviewer: reviewer);
  @override
  Future<Map<String, dynamic>?> detail(String slug) async => reviewer
      ? {
          'summary': 'Test fixture, not clinical guidance.',
          'steps': [
            {
              'action': 'Example action',
              'details': 'Example detail',
              'is_critical': true
            }
          ],
          'sources': [
            {
              'title': 'Example guideline',
              'url': 'https://example.org/guideline'
            }
          ],
          'migration_flags': ['Test review flag'],
        }
      : null;
}

Widget host(Widget child) => MaterialApp(home: child, routes: {
      '/home': (_) => const Scaffold(body: Text('Home tiles')),
      '/account': (_) => const Scaffold(body: Text('Account test')),
      '/subscribe': (_) => const Scaffold(body: Text('Paywall test')),
    });
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  test('Acronyms and multi-word search match metadata only', () {
    expect(mh.matches('MH'), isTrue);
    expect(airway.matches('intubate oxygenate'), isTrue);
    expect(mh.matches('unrelated'), isFalse);
    expect(
        CrisisEntry.fromJson({'slug': 'x', 'title': 'X', 'category': 'airway'})
            .isPublished,
        isFalse);
  });
  testWidgets('search filters immediately, clears, and opens a draft safely',
      (t) async {
    final repo = FakeCrisis();
    addTearDown(repo.events.close);
    await t.pumpWidget(host(CrisisHubScreen(repository: repo)));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'MH');
    await t.pumpAndSettle();
    expect(find.text('Malignant Hyperthermia'), findsOneWidget);
    expect(find.text('CICO'), findsNothing);
    await t.tap(find.text('Malignant Hyperthermia'));
    await t.pumpAndSettle();
    expect(find.textContaining('not yet released for patient care'),
        findsOneWidget);
    expect(find.text('View subscription options'), findsNothing);
    expect(find.text('Example action'), findsNothing);
  });
  testWidgets(
      'reference sections have no checklist and sign-out clears content',
      (t) async {
    final repo = FakeCrisis()..reviewer = true;
    addTearDown(repo.events.close);
    await t.pumpWidget(host(CrisisDetailScreen(entry: mh, repository: repo)));
    await t.pumpAndSettle();
    expect(find.textContaining('OWNER REVIEW'), findsOneWidget);
    expect(find.textContaining('Clinical review and release approval'),
        findsOneWidget);
    expect(find.textContaining('Original Base44 content is preserved'),
        findsNothing);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Clinical management considerations'), findsOneWidget);
    expect(find.text('Example action'), findsOneWidget);
    expect(find.text('Example detail'), findsOneWidget);
    expect(find.text('Critical clinical consideration'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.textContaining('Checklist'), findsNothing);
    expect(find.text('Reset'), findsNothing);
    expect(find.text('1. Example action'), findsNothing);
    repo.reviewer = false;
    repo.events.add(null);
    await t.pumpAndSettle();
    expect(find.text('Example action'), findsNothing);
    expect(find.text('Example detail'), findsNothing);
    expect(find.textContaining('not yet released for patient care'),
        findsOneWidget);
  });
  testWidgets('offline retry and empty search remain usable', (t) async {
    final repo = FakeCrisis()..fail = true;
    addTearDown(repo.events.close);
    await t.pumpWidget(host(CrisisHubScreen(repository: repo)));
    await t.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    repo.fail = false;
    await t.tap(find.text('Retry'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'does not exist');
    await t.pumpAndSettle();
    expect(find.textContaining('No matching emergencies'), findsOneWidget);
    await t.tap(find.byTooltip('Clear search'));
    await t.pumpAndSettle();
    expect(find.text('CICO'), findsOneWidget);
  });
  testWidgets('Crisis reference opens the exact source in a separate window',
      (t) async {
    final previous = UrlLauncherPlatform.instance;
    final launcher = CrisisSourceLauncher();
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() => UrlLauncherPlatform.instance = previous);
    final repo = FakeCrisis()..reviewer = true;
    addTearDown(repo.events.close);
    await t.pumpWidget(host(CrisisDetailScreen(entry: mh, repository: repo)));
    await t.pumpAndSettle();
    final source = find.text('Example guideline');
    await t.ensureVisible(source);
    await t.pumpAndSettle();
    await t.tap(source);
    await t.pumpAndSettle();
    expect(launcher.opened, 'https://example.org/guideline');
    expect(launcher.options?.webOnlyWindowName, '_blank');
  });
  testWidgets('published paid entry uses existing paywall, not account unlock',
      (t) async {
    final repo = FakeCrisis();
    addTearDown(repo.events.close);
    await t.pumpWidget(host(CrisisDetailScreen(
        entry: const CrisisEntry(
            slug: 'paid',
            title: 'Paid reference',
            category: 'cardiac',
            isPublished: true),
        repository: repo)));
    await t.pumpAndSettle();
    expect(find.text('View subscription options'), findsOneWidget);
    await t.tap(find.text('View subscription options'));
    await t.pumpAndSettle();
    expect(find.text('Paywall test'), findsOneWidget);
  });
}
