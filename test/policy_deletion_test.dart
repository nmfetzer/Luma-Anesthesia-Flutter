import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luma_anesthesia/auth/account_deletion.dart';
import 'package:luma_anesthesia/policies/policy_agreement_screen.dart';
import 'package:luma_anesthesia/screens/delete_account_screen.dart';
import 'package:luma_anesthesia/welcome/welcome_carousel.dart';
import 'package:luma_anesthesia/welcome/welcome_gate.dart';

class FakeDeletion implements AccountDeletionAccess {
  bool available = true;
  bool fail = false;
  int calls = 0;
  @override
  Future<bool> isAvailable() async => available;
  @override
  Future<DeletionReceipt> requestDeletion() async {
    calls++;
    if (fail) throw StateError('offline');
    return DeletionReceipt(
      id: 'test-receipt',
      dueAt: DateTime.utc(2026, 10, 9),
    );
  }
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('four unchecked policies, agree-all and individual deselect', (
    tester,
  ) async {
    int calls = 0;
    final urls = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: PolicyAgreementScreen(
          onAccept: () async {
            calls++;
          },
          openExternal: (uri) async {
            urls.add(uri.toString());
            return true;
          },
        ),
      ),
    );
    final button = find.byKey(const ValueKey('policy-continue'));
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    expect(
      tester
          .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
          .every((box) => box.value == false),
      true,
    );
    await tester.tap(find.byKey(const ValueKey('policy-agree-all')));
    await tester.pump();
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
    await tester.ensureVisible(find.byKey(const ValueKey('policy-1')));
    await tester.tap(find.byKey(const ValueKey('policy-1')));
    await tester.pump();
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    for (final policy in lumaPolicies) {
      final read = find.text('Read ${policy.title}');
      await tester.ensureVisible(read);
      await tester.tap(read);
      await tester.pump();
    }
    expect(urls, lumaPolicies.map((p) => p.url).toList());
    expect(calls, 0);
  });
  testWidgets('welcome then policies then app, persists once across restart', (
    tester,
  ) async {
    Widget app() =>
        const MaterialApp(home: WelcomeGate(child: Text('App content')));
    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    tester.widget<WelcomeCarousel>(find.byType(WelcomeCarousel)).onFinish();
    await tester.pumpAndSettle();
    expect(find.byType(PolicyAgreementScreen), findsOneWidget);
    expect(find.text('App content'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('policy-agree-all')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('policy-continue')));
    await tester.tap(find.byKey(const ValueKey('policy-continue')));
    await tester.pumpAndSettle();
    expect(find.text('App content'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString(WelcomeGate.policyPreferenceKey),
      WelcomeGate.policyVersion,
    );
    expect(
      prefs.getString('${WelcomeGate.policyPreferenceKey}_accepted_at'),
      isNotNull,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.byType(PolicyAgreementScreen), findsNothing);
    expect(find.text('App content'), findsOneWidget);
  });
  testWidgets(
    'existing installs and changed policy version require acknowledgment',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        WelcomeGate.preferenceKey: true,
        WelcomeGate.policyPreferenceKey: 'old-version',
      });
      await tester.pumpWidget(
        const MaterialApp(home: WelcomeGate(child: Text('Hidden'))),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeCarousel), findsNothing);
      expect(find.byType(PolicyAgreementScreen), findsOneWidget);
      expect(find.text('Hidden'), findsNothing);
    },
  );
  testWidgets('save and policy-link failures never accept silently', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PolicyAgreementScreen(
          onAccept: () async => throw StateError('storage'),
          openExternal: (_) async => false,
        ),
      ),
    );
    await tester.tap(find.text('Read Privacy Policy'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('The policy could not be opened'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byKey(const ValueKey('policy-agree-all')));
    await tester.tap(find.byKey(const ValueKey('policy-agree-all')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('policy-continue')));
    await tester.tap(find.byKey(const ValueKey('policy-continue')));
    await tester.pumpAndSettle();
    expect(find.textContaining('could not be saved'), findsOneWidget);
  });
  testWidgets('policy gate protects named deep links outside navigator', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({WelcomeGate.preferenceKey: true});
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/protected',
        routes: {
          '/': (_) => const Text('Home'),
          '/protected': (_) => const Text('Protected'),
        },
        builder: (_, child) => WelcomeGate(child: child!),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Protected'), findsNothing);
    expect(find.byType(PolicyAgreementScreen), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('policy-agree-all')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('policy-continue')));
    await tester.tap(find.byKey(const ValueKey('policy-continue')));
    await tester.pumpAndSettle();
    expect(find.text('Protected'), findsOneWidget);
  });
  for (final scale in [1.0, 2.0]) {
    testWidgets('policy agreement fits 320px with text scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (_, child) => MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: PolicyAgreementScreen(onAccept: () async {}),
        ),
      );
      await tester.ensureVisible(find.byKey(const ValueKey('policy-continue')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'deletion needs confirmation, cancel does not submit, receipt is pending',
    (tester) async {
      final access = FakeDeletion();
      await tester.pumpWidget(
        MaterialApp(home: DeleteAccountScreen(access: access)),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.ensureVisible(find.text('Request account deletion'));
      await tester.tap(find.text('Request account deletion'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep my account'));
      await tester.pumpAndSettle();
      expect(access.calls, 0);
      await tester.tap(find.text('Request account deletion'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit deletion request'));
      await tester.pumpAndSettle();
      expect(access.calls, 1);
      expect(
        find.textContaining('Your account has not been deleted yet'),
        findsOneWidget,
      );
    },
  );
  testWidgets('unavailable deletion service cannot accept a request', (
    tester,
  ) async {
    final access = FakeDeletion()..available = false;
    await tester.pumpWidget(
      MaterialApp(home: DeleteAccountScreen(access: access)),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(
      find.textContaining('No request has been submitted'),
      findsOneWidget,
    );
    expect(access.calls, 0);
  });
  testWidgets('deletion failure never claims success', (tester) async {
    final access = FakeDeletion()..fail = true;
    await tester.pumpWidget(
      MaterialApp(home: DeleteAccountScreen(access: access)),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.ensureVisible(find.text('Request account deletion'));
    await tester.tap(find.text('Request account deletion'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit deletion request'));
    await tester.pumpAndSettle();
    expect(find.textContaining('could not be confirmed'), findsOneWidget);
    expect(find.text('Deletion request received'), findsNothing);
  });
}
