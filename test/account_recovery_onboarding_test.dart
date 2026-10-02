import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luma_anesthesia/screens/account_screen.dart';
import 'package:luma_anesthesia/screens/password_recovery_screen.dart';
import 'package:luma_anesthesia/welcome/welcome_gate.dart';
import 'package:luma_anesthesia/welcome/welcome_carousel.dart';
import 'package:luma_anesthesia/billing/subscription_billing.dart';

import 'account_screen_test.dart' show FakeAccount;

class RecoverableAccount extends FakeAccount implements PasswordRecoveryAccess {
  String? requestedEmail;
  String? savedPassword;
  bool fail = false;
  @override
  Future<void> requestPasswordReset(String email) async {
    if (fail) throw StateError('offline');
    requestedEmail = email;
  }

  @override
  Future<void> updatePassword(String password) async {
    if (fail) throw StateError('expired');
    savedPassword = password;
  }
}

class RestoreGateway implements BillingGateway {
  int restored = 0;
  int purchased = 0;
  @override
  String? get userId => 'test-user';
  @override
  Future<void> identify(String? userId) async {}
  @override
  Future<List<BillingPlan>> plans() async => [];
  @override
  Future<bool> verify(String userId) async => restored > 0;
  @override
  Future<void> restore() async {
    restored++;
  }

  @override
  Future<void> purchase(BillingPlan plan) async {
    purchased++;
  }
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('welcome completion persists across gate recreation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      WelcomeGate.policyPreferenceKey: WelcomeGate.policyVersion,
    });
    Widget app() =>
        const MaterialApp(home: WelcomeGate(child: Text('Home fixture')));
    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(WelcomeCarousel), findsOneWidget);
    tester.widget<WelcomeCarousel>(find.byType(WelcomeCarousel)).onFinish();
    await tester.pumpAndSettle();
    expect(find.text('Home fixture'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getBool(
        WelcomeGate.preferenceKey,
      ),
      true,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeCarousel), findsNothing);
    expect(find.text('Home fixture'), findsOneWidget);
  });
  testWidgets('forgot password needs email, not current password', (
    tester,
  ) async {
    final account = RecoverableAccount();
    await tester.pumpWidget(MaterialApp(home: AccountScreen(access: account)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Forgot password?'));
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send reset email'));
    await tester.pumpAndSettle();
    expect(account.requestedEmail, isNull);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Account email'),
      'learner@example.com',
    );
    await tester.tap(find.text('Send reset email'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(account.requestedEmail, 'learner@example.com');
    expect(account.submissions, 0);
    expect(
      find.textContaining('If an eligible account exists'),
      findsOneWidget,
    );
  });
  testWidgets(
    'recovery validates matching passwords and handles expired link',
    (tester) async {
      final account = RecoverableAccount()..fail = true;
      await tester.pumpWidget(
        MaterialApp(home: PasswordRecoveryScreen(access: account)),
      );
      await tester.enterText(find.byType(TextFormField).first, 'new-password');
      await tester.enterText(find.byType(TextFormField).last, 'different');
      await tester.tap(find.text('Update password'));
      await tester.pumpAndSettle();
      expect(find.text('Passwords must match.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).last, 'new-password');
      await tester.tap(find.text('Update password'));
      await tester.pumpAndSettle();
      expect(find.textContaining('The link may have expired'), findsOneWidget);
      account.fail = false;
      await tester.tap(find.text('Update password'));
      await tester.pumpAndSettle();
      expect(account.savedPassword, 'new-password');
      expect(find.text('Your password has been updated.'), findsOneWidget);
    },
  );
  testWidgets('Account restores only after sign in and never purchases', (
    tester,
  ) async {
    final account = RecoverableAccount();
    final gateway = RestoreGateway();
    final billing = SubscriptionBilling(gateway: gateway);
    addTearDown(billing.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: AccountScreen(access: account, billing: billing),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Restore Purchases'));
    await tester.tap(find.text('Restore Purchases'));
    await tester.pumpAndSettle();
    expect(gateway.restored, 0);
    account.completeSocialSignIn();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Restore Purchases'));
    await tester.tap(find.text('Restore Purchases'));
    await tester.pumpAndSettle();
    expect(gateway.restored, 1);
    expect(gateway.purchased, 0);
    expect(billing.verified, true);
  });
}
