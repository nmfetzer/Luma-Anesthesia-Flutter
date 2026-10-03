import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/diagnostics/diagnostics_access.dart';
import 'package:luma_anesthesia/diagnostics/diagnostics_screen.dart';
import 'package:luma_anesthesia/diagnostics/abg_screen.dart';
import 'package:luma_anesthesia/diagnostics/clinical_module_screen.dart';
import 'package:luma_anesthesia/diagnostics/clinical_modules.dart';
import 'package:luma_anesthesia/diagnostics/diagnostics_content.dart';
import 'package:luma_anesthesia/launch/launch_scope.dart';
import 'package:luma_anesthesia/main.dart';
import 'package:luma_anesthesia/screens/subscription_screen.dart';
import 'package:luma_anesthesia/theme/luma_theme.dart';

Widget app(Widget child, {double scale = 1}) => MaterialApp(
  theme: buildLumaTheme(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
    child: child!,
  ),
  home: child,
  routes: {'/home': (_) => const Scaffold(body: Text('Tile dashboard'))},
);

void main() {
  test('release entry never enables private-review access by default', () {
    expect(const LumaApp().diagnosticsReviewPreview, isFalse);
    expect(const DiagnosticsFeature().reviewPreview, isFalse);
    expect(LaunchScope.isDeferred('/diagnostics'), isFalse);
    expect(LaunchScope.isDeferred('/luma-ai'), isTrue);
    expect(LaunchScope.isDeferred('/ekg'), isTrue);
  });

  for (final path in [
    null,
    'labs',
    'abg',
    'pfts',
    'echo',
    'imaging',
    'pocus',
    'carotid',
  ]) {
    testWidgets('unpaid access is blocked at ${path ?? 'hub'}', (tester) async {
      await tester.pumpWidget(
        app(
          DiagnosticsFeature(
            initialSection: path,
            checkAccess: () async => false,
            accessChanges: const Stream.empty(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SubscriptionScreen), findsOneWidget);
      expect(find.byType(AbgReferenceScreen), findsNothing);
      expect(find.byType(LabValuesScreen), findsNothing);
      expect(find.byType(ClinicalModuleScreen), findsNothing);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Tile dashboard'), findsOneWidget);
    });
  }

  testWidgets('signout/revocation also removes an open lab detail', (
    tester,
  ) async {
    var allowed = true;
    final changes = StreamController<void>.broadcast();
    addTearDown(changes.close);
    await tester.pumpWidget(
      app(
        DiagnosticsFeature(
          checkAccess: () async => allowed,
          accessChanges: changes.stream,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lab Values'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ACT');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('ACT / Activated Clotting Time'),
      250,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('ACT / Activated Clotting Time'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('act-comparison-chart')), findsOneWidget);
    allowed = false;
    changes.add(null);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('act-comparison-chart')), findsNothing);
    expect(find.byType(SubscriptionScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(SubscriptionScreen), findsOneWidget);
  });

  testWidgets(
    'approved hub exposes all seven complete areas and no item counts',
    (tester) async {
      await tester.pumpWidget(
        app(
          DiagnosticsFeature(
            checkAccess: () async => true,
            accessChanges: const Stream.empty(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final scroll = find.byType(Scrollable).first;
      for (final category in diagnosticCategories) {
        await tester.scrollUntilVisible(
          find.text(category.title),
          250,
          scrollable: scroll,
        );
        await tester.pumpAndSettle();
        expect(find.text(category.title), findsOneWidget);
      }
      expect(find.textContaining('Review draft'), findsNothing);
      expect(find.textContaining('In preparation'), findsNothing);
      expect(find.textContaining('reference cards'), findsNothing);
    },
  );

  testWidgets(
    'explicit private preview works offline without bypassing release default',
    (tester) async {
      await tester.pumpWidget(
        app(const DiagnosticsFeature(reviewPreview: true)),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('REVIEW PREVIEW'), findsOneWidget);
      expect(find.byType(SubscriptionScreen), findsNothing);
    },
  );

  for (final size in [
    const Size(320, 568),
    const Size(375, 812),
    const Size(820, 1180),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('all released diagnostics fit $size at $scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final screens = [
          const DiagnosticsScreen(clinicalRelease: true),
          const LabValuesScreen(clinicalRelease: true),
          const AbgReferenceScreen(clinicalRelease: true),
          for (final module in clinicalModules)
            ClinicalModuleScreen(module: module, clinicalRelease: true),
        ];
        for (final screen in screens) {
          await tester.pumpWidget(app(screen, scale: scale));
          await tester.pumpAndSettle();
          expect(find.text('Home').hitTestable(), findsOneWidget);
          expect(
            tester.takeException(),
            isNull,
            reason: '${screen.runtimeType}',
          );
          await tester.pumpWidget(const SizedBox());
        }
      });
    }
  }
}
