import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/screens/account_screen.dart';
import 'package:luma_anesthesia/screens/password_recovery_screen.dart';
import 'package:luma_anesthesia/screens/subscription_screen.dart';
import 'package:luma_anesthesia/special_considerations/special_considerations_screen.dart';
import 'package:luma_anesthesia/crisis/crisis_screen.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_screen.dart';
import 'package:luma_anesthesia/vasopressors/vasopressors_screen.dart';

import 'account_recovery_onboarding_test.dart' show RecoverableAccount;
import 'special_considerations_test.dart' show FakeRepository;
import 'crisis_hub_test.dart' show FakeCrisis;
import 'quick_references_test.dart' show FakeReferences;
import 'vasopressors_test.dart' show drugs, blood;

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  final sizes = {
    'small iPhone': const Size(320, 568),
    'iPhone portrait': const Size(390, 844),
    'iPad portrait': const Size(820, 1180),
    'iPad landscape': const Size(1180, 820),
  };
  for (final device in sizes.entries) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('${device.key} launch screens at text scale $scale', (
        t,
      ) async {
        t.view.physicalSize = device.value;
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        final account = RecoverableAccount();
        final patho = FakeRepository();
        final crisis = FakeCrisis();
        final quick = FakeReferences();
        addTearDown(patho.controller.close);
        addTearDown(crisis.events.close);
        addTearDown(quick.changes.close);
        final screens = <Widget>[
          AccountScreen(access: account),
          PasswordRecoveryScreen(access: account),
          const SubscriptionScreen(),
          SpecialConsiderationsScreen(repository: patho),
          CrisisHubScreen(repository: crisis),
          QuickReferencesScreen(repository: quick),
          VasopressorsScreen(
            checkAccess: () async => true,
            accessChanges: const Stream.empty(),
            loadMedications: () async => drugs,
            loadBloodProducts: () async => blood,
          ),
        ];
        for (final screen in screens) {
          await t.pumpWidget(
            MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: screen,
            ),
          );
          await t.pump();
          await t.pump(const Duration(seconds: 1));
          expect(t.takeException(), isNull, reason: '${screen.runtimeType}');
          await t.pumpWidget(const SizedBox());
        }
      });
    }
  }
  testWidgets(
    'forgot password fits small iPhone with keyboard and larger text',
    (t) async {
      t.view.physicalSize = const Size(320, 568);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final account = RecoverableAccount();
      var keyboard = false;
      Widget app() => MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.5),
            viewInsets: EdgeInsets.only(bottom: keyboard ? 290 : 0),
          ),
          child: child!,
        ),
        home: AccountScreen(access: account),
      );
      await t.pumpWidget(app());
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Forgot password?'));
      await t.tap(find.text('Forgot password?'));
      await t.pumpAndSettle();
      keyboard = true;
      await t.pumpWidget(app());
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await t.ensureVisible(find.text('Send reset email'));
      await t.tap(find.text('Send reset email'));
      await t.pumpAndSettle();
      expect(account.requestedEmail, isNull);
      expect(t.takeException(), isNull);
    },
  );
}
