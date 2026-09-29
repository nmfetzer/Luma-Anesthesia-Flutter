import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/vasopressors/vasopressors_screen.dart';
import 'package:luma_anesthesia/screens/subscription_screen.dart';
import 'package:luma_anesthesia/widgets/premium_access_gate.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget app(Widget child) => MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: child!,
    ),
    home: child,
    routes: {'/home': (_) => const Scaffold(body: Text('Dashboard'))},
  );

  testWidgets('guest/unpaid section loads no medication or transfusion rows', (
    tester,
  ) async {
    var loads = 0;
    await tester.pumpWidget(
      app(
        VasopressorsScreen(
          checkAccess: () async => false,
          accessChanges: const Stream.empty(),
          loadMedications: () async {
            loads++;
            return [];
          },
          loadBloodProducts: () async {
            loads++;
            return [];
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(loads, 0);
    expect(find.byType(SubscriptionScreen), findsOneWidget);
    expect(find.text(r'$9.99'), findsOneWidget);
    expect(find.text(r'$69.99'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('revocation removes an already-open medication detail', (
    tester,
  ) async {
    var allowed = true;
    final changes = StreamController<void>.broadcast();
    addTearDown(changes.close);
    await tester.pumpWidget(
      app(
        VasopressorsScreen(
          checkAccess: () async => allowed,
          accessChanges: changes.stream,
          loadMedications: () async => [
            {
              'name': 'Test pressor',
              'vasoactive_role': 'vasopressor',
              'adult_dose': 'Protected section detail',
            },
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test pressor'));
    await tester.pumpAndSettle();
    expect(find.text('Protected section detail'), findsOneWidget);
    allowed = false;
    changes.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Protected section detail'), findsNothing);
    expect(find.byType(SubscriptionScreen), findsOneWidget);
  });

  testWidgets('stale successful check cannot unlock another account', (
    tester,
  ) async {
    final changes = StreamController<void>.broadcast();
    addTearDown(changes.close);
    final oldCheck = Completer<bool>();
    var calls = 0;
    await tester.pumpWidget(
      app(
        PremiumAccessGate(
          checkAccess: () =>
              calls++ == 0 ? oldCheck.future : Future.value(false),
          accessChanges: changes.stream,
          builder: (_) => const Text('PRIVATE'),
        ),
      ),
    );
    changes.add(null);
    await tester.pumpAndSettle();
    oldCheck.complete(true);
    await tester.pumpAndSettle();
    expect(find.text('PRIVATE'), findsNothing);
    expect(find.byType(SubscriptionScreen), findsOneWidget);
  });

  testWidgets('verification error fails closed and can retry', (tester) async {
    var fail = true;
    await tester.pumpWidget(
      app(
        PremiumAccessGate(
          checkAccess: () async {
            if (fail) throw StateError('not a network error');
            return true;
          },
          accessChanges: const Stream.empty(),
          builder: (_) => const Text('VERIFIED'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('VERIFIED'), findsNothing);
    fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('VERIFIED'), findsOneWidget);
  });
}
