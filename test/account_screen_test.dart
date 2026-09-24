import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/screens/account_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAccount implements AccountAccess {
  FakeAccount() {
    addTearDown(_changes.close);
  }

  final _changes = StreamController<void>.broadcast();
  @override
  Stream<void> get changes => _changes.stream;
  Set<OAuthProvider> providers = {OAuthProvider.apple, OAuthProvider.google};
  bool failProviderCheck = false;
  bool failSocialLaunch = false;
  bool openBrowser = true;
  final socialCalls = <OAuthProvider>[];
  @override
  Future<Set<OAuthProvider>> enabledProviders() async {
    if (failProviderCheck) throw StateError('offline');
    return providers;
  }

  @override
  Future<bool> signInWithProvider(OAuthProvider provider) async {
    socialCalls.add(provider);
    if (failSocialLaunch) throw StateError('provider unavailable');
    return openBrowser;
  }

  void completeSocialSignIn() {
    email = 'review@example.com';
    _changes.add(null);
  }

  @override
  String? email;
  bool immediateSession = true;
  int submissions = 0;
  bool? lastCreate;
  bool rejectLogin = false;
  @override
  Future<bool> submit(String email, String password,
      {required bool create}) async {
    submissions++;
    lastCreate = create;
    if (rejectLogin) {
      throw const AuthException('Invalid login credentials',
          code: 'invalid_credentials');
    }
    if (immediateSession) this.email = email;
    return immediateSession;
  }

  @override
  Future<void> signOut() async {
    email = null;
  }
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('validates before submitting credentials', (tester) async {
    final account = FakeAccount();
    await tester.pumpWidget(MaterialApp(home: AccountScreen(access: account)));
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(account.submissions, 0);
    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });

  testWidgets('confirmed account signs in and can sign out', (tester) async {
    final account = FakeAccount();
    await tester.pumpWidget(MaterialApp(home: AccountScreen(access: account)));
    await tester.enterText(
        find.byType(TextFormField).at(0), 'review@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'test-password');
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(account.email, 'review@example.com');
    expect(find.text('Your account'), findsOneWidget);
    await tester.ensureVisible(find.text('Sign out'));
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(account.email, isNull);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('signup without a session asks for email confirmation',
      (tester) async {
    final account = FakeAccount()..immediateSession = false;
    await tester.pumpWidget(MaterialApp(home: AccountScreen(access: account)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('New account'));
    await tester.tap(find.text('New account'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byType(TextFormField).at(0), 'review@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'test-password');
    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(account.lastCreate, true);
    expect(account.email, isNull);
    expect(find.textContaining('Check your email to confirm'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('invalid login explains new account registration safely',
      (tester) async {
    final account = FakeAccount()..rejectLogin = true;
    await tester.pumpWidget(MaterialApp(home: AccountScreen(access: account)));
    await tester.enterText(
        find.byType(TextFormField).at(0), 'review@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'test-password');
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.textContaining('We could not sign you in'), findsOneWidget);
    await tester.ensureVisible(find.text('New account'));
    await tester.tap(find.text('New account'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsOneWidget);
    expect(account.email, isNull);
  });

  testWidgets(
      'both providers launch their own flow without submitting a password',
      (tester) async {
    final account = FakeAccount();
    await tester.pumpWidget(MaterialApp(home: AccountScreen(access: account)));
    await tester.pumpAndSettle();
    for (final name in ['Apple', 'Google']) {
      await tester.ensureVisible(find.text('Continue with $name'));
      await tester.tap(find.text('Continue with $name'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Continue with $name in your browser'),
          findsOneWidget);
      expect(find.text('Your account'), findsNothing);
    }
    expect(account.socialCalls, [OAuthProvider.apple, OAuthProvider.google]);
    expect(account.submissions, 0);
    account.completeSocialSignIn();
    await tester.pumpAndSettle();
    expect(find.text('Your account'), findsOneWidget);
    expect(find.text('Continue with Google'), findsNothing);
  });

  testWidgets('disabled backend providers do not open misleading login pages',
      (tester) async {
    final account = FakeAccount()..providers = {};
    await tester.pumpWidget(MaterialApp(home: AccountScreen(access: account)));
    await tester.pumpAndSettle();
    for (final name in ['Apple', 'Google']) {
      final button = find.widgetWithText(OutlinedButton, 'Continue with $name');
      expect(tester.widget<OutlinedButton>(button).onPressed, isNull);
    }
    expect(find.textContaining('still being set up'), findsOneWidget);
    account.providers = {OAuthProvider.google};
    await tester.ensureVisible(find.text('Check availability again'));
    await tester.tap(find.text('Check availability again'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Continue with Google'))
            .onPressed,
        isNotNull);
    expect(account.socialCalls, isEmpty);
  });

  testWidgets(
      'launch failure and callback errors recover without claiming success',
      (tester) async {
    final account = FakeAccount()..openBrowser = false;
    await tester.pumpWidget(MaterialApp(home: AccountScreen(access: account)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with Apple'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not open Apple sign-in'), findsOneWidget);
    account.failSocialLaunch = true;
    await tester.ensureVisible(find.text('Continue with Google'));
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(
        find.textContaining('Google sign-in is unavailable'), findsOneWidget);
    account._changes.addError(StateError('invalid callback'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sign-in was not completed'), findsOneWidget);
    expect(find.text('Your account'), findsNothing);
  });

  testWidgets('provider lookup failure can be retried', (tester) async {
    final account = FakeAccount()..failProviderCheck = true;
    await tester.pumpWidget(MaterialApp(home: AccountScreen(access: account)));
    await tester.pumpAndSettle();
    expect(
        find.textContaining('Could not check social sign-in'), findsOneWidget);
    account.failProviderCheck = false;
    await tester.ensureVisible(find.text('Check availability again'));
    await tester.tap(find.text('Check availability again'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Continue with Apple'))
            .onPressed,
        isNotNull);
  });

  testWidgets('a callback landing page can return to the app after sign-in',
      (tester) async {
    final account = FakeAccount()..email = 'review@example.com';
    await tester.pumpWidget(MaterialApp(
      home: AccountScreen(access: account),
      routes: {'/home': (_) => const Scaffold(body: Text('Luma home'))},
    ));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue to Luma'));
    await tester.tap(find.text('Continue to Luma'));
    await tester.pumpAndSettle();
    expect(find.text('Luma home'), findsOneWidget);
  });

  testWidgets('embedded preview does not start an unrecoverable OAuth redirect',
      (tester) async {
    final account = FakeAccount();
    await tester.pumpWidget(MaterialApp(
        home: AccountScreen(access: account, allowSocialSignIn: false)));
    await tester.pumpAndSettle();
    expect(find.textContaining('unavailable inside this embedded preview'),
        findsOneWidget);
    expect(
        tester
            .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Continue with Apple'))
            .onPressed,
        isNull);
    expect(account.socialCalls, isEmpty);
  });

  testWidgets('social login and email remain usable with enlarged mobile text',
      (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(2)),
        child: child!,
      ),
      home: AccountScreen(access: FakeAccount()),
    ));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue with Google'));
    await tester.ensureVisible(find.text('Sign in'));
  });
}
