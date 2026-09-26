import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:luma_anesthesia/crisis/crisis_algorithm_links.dart';

class ChartLauncher extends UrlLauncherPlatform {
  @override
  LinkDelegate? get linkDelegate => null;
  String? url;
  LaunchOptions? options;
  bool succeeds = true;
  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    this.url = url;
    this.options = options;
    return succeeds;
  }
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  for (final slug in ['cardiac_meds', 'pals']) {
    testWidgets('$slug chart links fit a phone and open exact official PDFs',
        (t) async {
      t.view.physicalSize = const Size(375, 812);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final previous = UrlLauncherPlatform.instance;
      final launcher = ChartLauncher();
      UrlLauncherPlatform.instance = launcher;
      addTearDown(() => UrlLauncherPlatform.instance = previous);
      await t.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: CrisisAlgorithmLinks(slug: slug))))));
      await t.pumpAndSettle();
      expect(find.text('Quick-access algorithms'), findsOneWidget);
      for (final algorithm in crisisAlgorithms[slug]!) {
        final button = find.widgetWithText(OutlinedButton, algorithm.title);
        await t.ensureVisible(button);
        await t.tap(button);
        await t.pumpAndSettle();
        expect(launcher.url, algorithm.url);
        expect(launcher.options?.webOnlyWindowName, '_blank');
        expect(t.takeException(), isNull);
      }
      if (slug == 'cardiac_meds') {
        final notice = find.text('Read AHA correction notice');
        await t.ensureVisible(notice);
        await t.tap(notice);
        await t.pumpAndSettle();
        expect(launcher.url, bradycardiaCorrectionUrl);
      }
      launcher.succeeds = false;
      final first = find.text(crisisAlgorithms[slug]!.first.title);
      await t.ensureVisible(first);
      await t.tap(first);
      await t.pumpAndSettle();
      expect(find.textContaining('Could not open'), findsOneWidget);
    });
  }
  testWidgets('unrelated references do not show resuscitation algorithms',
      (t) async {
    await t.pumpWidget(const MaterialApp(
        home: Scaffold(body: CrisisAlgorithmLinks(slug: 'cva'))));
    expect(find.text('Quick-access algorithms'), findsNothing);
  });
}
