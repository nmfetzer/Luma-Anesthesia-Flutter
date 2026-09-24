import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/screens/account_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAccount implements AccountAccess {
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
}
