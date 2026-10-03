import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/diagnostics/clinical_modules.dart';
import 'package:luma_anesthesia/diagnostics/clinical_module_screen.dart';
import 'package:luma_anesthesia/diagnostics/diagnostics_screen.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  test(
      'five modules contain 29 distinct substantive cards with HTTPS citations',
      () {
    expect(
      clinicalModules.map((m) => m.id),
      ['pfts', 'echo', 'imaging', 'pocus', 'carotid'],
    );
    final topics = clinicalModules.expand((m) => m.topics).toList();
    expect(topics.length, 29);
    expect(topics.map((t) => t.id).toSet().length, topics.length);
    for (final topic in topics) {
      expect(topic.sections.length, greaterThanOrEqualTo(2), reason: topic.id);
      for (final section in topic.sections) {
        expect(
          section.bullets.length,
          greaterThanOrEqualTo(2),
          reason: topic.id,
        );
        expect(Uri.parse(section.url).scheme, 'https');
        expect(section.sourceLabel, isNotEmpty);
      }
      for (final row in topic.differential) {
        expect(Uri.parse(row.url).scheme, 'https');
        expect(row.clues, isNotEmpty);
        expect(row.focus, isNotEmpty);
      }
    }
  });

  test('clinical caveats and current criteria stay present', () {
    final text = clinicalModules
        .expand((m) => m.topics)
        .expand((t) => t.sections)
        .expand((s) => s.bullets)
        .join(' ');
    for (final phrase in [
      'greater than 10% of the predicted',
      'should not be applied in intraoperative settings',
      'MR Conditional does not mean unrestricted',
      '125–180 cm/s',
      'not a low-risk result',
      'not recommend prophylactic CEA',
    ]) {
      expect(text, contains(phrase));
    }
  });

  test('search matches aliases, Unicode values, text, and group intersections',
      () {
    expect(searchClinicalTopics(clinicalModules[0], 'DLCO'), isNotEmpty);
    expect(searchClinicalTopics(clinicalModules[0], 'FEV₁'), isNotEmpty);
    expect(
      searchClinicalTopics(clinicalModules[1], 'LVOTO')
          .any((t) => t.id == 'echo-obstruction'),
      isTrue,
    );
    expect(
      searchClinicalTopics(clinicalModules[3], 'full stomach').single.id,
      'pocus-gastric',
    );
    expect(searchClinicalTopics(clinicalModules[4], 'stent'), isNotEmpty);
    expect(
      searchClinicalTopics(clinicalModules[3], '', group: 'Lung').single.id,
      'pocus-lung',
    );
    expect(
      searchClinicalTopics(clinicalModules[3], 'gastric', group: 'Lung'),
      isEmpty,
    );
    expect(searchClinicalTopics(clinicalModules[0], 'notareference'), isEmpty);
  });

  for (final module in clinicalModules) {
    testWidgets('${module.id}: production guard hides draft content',
        (tester) async {
      await tester
          .pumpWidget(MaterialApp(home: ClinicalModuleScreen(module: module)));
      expect(
        find.textContaining('not available in the released app'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('${module.id}: hub navigation, live search and expansion',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DiagnosticsScreen(showClinicalDraft: true)),
      );
      await tester.enterText(find.byType(TextField), module.title);
      await tester.pump();
      await tester.tap(find.text(module.title).last);
      await tester.pumpAndSettle();
      expect(find.text(module.heading), findsOneWidget);
      await tester.enterText(find.byType(TextField), module.topics.first.title);
      await tester.pumpAndSettle();
      expect(
        find.text('1 of ${module.topics.length} reference cards'),
        findsNothing,
      );
      await tester.ensureVisible(find.text(module.topics.first.title).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(module.topics.first.title).last);
      await tester.pumpAndSettle();
      expect(
        find.text(module.topics.first.sections.first.title),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('mobile criteria stack, source buttons, and empty reset work',
      (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: ClinicalModuleScreen(
          module: clinicalModules.last,
          showClinicalDraft: true,
        ),
      ),
    );
    await tester.scrollUntilVisible(
      find.text(carotidTopics.first.title),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(carotidTopics.first.title));
    await tester.pumpAndSettle();
    expect(
      find.text('How much is the internal carotid artery narrowed?'),
      findsOneWidget,
    );
    expect(find.text('Normal: no plaque'), findsOneWidget);
    expect(find.text('Mild narrowing: less than 50%'), findsOneWidget);
    expect(find.text('Ultrasound findings'), findsWidgets);
    expect(find.text('How to interpret this'), findsWidgets);
    expect(find.text('Distinguishing context'), findsNothing);
    expect(find.text('Evaluation / management focus'), findsNothing);
    expect(carotidTopics.first.differential.length, 6);
    expect(carotidTopics.first.differential[2].focus, contains('125–180 cm/s'));
    expect(find.byType(Table), findsNothing);
    expect(find.text('Source: IAC 2023 recommendations'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byType(TextField),
      -350,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'notareference');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Reset search and filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset search and filters'));
    await tester.pumpAndSettle();
    expect(find.text('5 of 5 reference cards'), findsNothing);
  });
}
