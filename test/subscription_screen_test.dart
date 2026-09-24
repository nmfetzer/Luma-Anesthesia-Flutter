import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/screens/subscription_screen.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget app({double scale = 1, Future<bool> Function(Uri)? openExternal}) =>
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
              disableAnimations: true, textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: SubscriptionScreen(openExternal: openExternal),
        routes: {
          '/ce-halo': (_) => const CeAccessScreen(),
          '/account': (_) => const Scaffold(body: Text('Account destination')),
        },
      );

  testWidgets('paywall previews plans without pretending checkout is live',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();
    expect(find.text('LUMA PREMIUM'), findsOneWidget);
    expect(find.text('\$69.99'), findsOneWidget);
    expect(find.text('\$9.99'), findsOneWidget);
    expect(find.textContaining('1-year auto-renewable'), findsOneWidget);
    expect(find.textContaining('automatically renew unless canceled'),
        findsOneWidget);
    final checkout = find.widgetWithText(FilledButton, 'Purchases coming soon');
    expect(tester.widget<FilledButton>(checkout).onPressed, isNull);
    await tester.ensureVisible(find.text('Monthly'));
    await tester.tap(find.text('Monthly'));
    await tester.pump();
    expect(find.textContaining('1-month auto-renewable'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('legal links open the verified terms and privacy destinations',
      (tester) async {
    final opened = <Uri>[];
    await tester.pumpWidget(app(openExternal: (uri) async {
      opened.add(uri);
      return true;
    }));
    for (final label in ['Terms of Use / EULA', 'Privacy Policy']) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pump();
    }
    expect(opened.map((uri) => uri.toString()), [
      'https://lumaeducationalapps.com/terms-of-use-eula',
      'https://lumaeducationalapps.com/privacy-policy-1',
    ]);
  });

  testWidgets('failed legal link shows a readable fallback address',
      (tester) async {
    await tester.pumpWidget(app(openExternal: (_) async => false));
    await tester.ensureVisible(find.text('Privacy Policy'));
    await tester.tap(find.text('Privacy Policy'));
    await tester.pump();
    expect(find.textContaining('Could not open this page. Please visit'),
        findsOneWidget);
  });

  test('billing notices distinguish native stores from the web preview', () {
    final ios = subscriptionBillingNotice(TargetPlatform.iOS, isWeb: false);
    expect(ios, contains('Apple Account'));
    expect(ios, isNot(contains('Google Play')));
    final android =
        subscriptionBillingNotice(TargetPlatform.android, isWeb: false);
    expect(android, contains('Google Play'));
    expect(android, isNot(contains('Apple Account')));
    final web = subscriptionBillingNotice(TargetPlatform.iOS, isWeb: true);
    expect(web, contains('For iOS purchases:'));
    expect(web, contains('For Android purchases:'));
    expect(web, contains('not available in this Chrome preview'));
  });

  testWidgets('CE is separate, describes both bonuses and opens without login',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();
    expect(
        find.textContaining('No app subscription is required'), findsOneWidget);
    expect(find.textContaining('bonus activation are coming soon'),
        findsOneWidget);
    await tester.ensureVisible(find.text('Explore CE access'));
    await tester.tap(find.text('Explore CE access'));
    await tester.pumpAndSettle();
    expect(find.text('CE HALO'), findsOneWidget);
    expect(find.byType(CeAccessScreen), findsOneWidget);
    expect(
        find.textContaining('No app subscription is required'), findsOneWidget);
  });

  testWidgets('account link remains separate from checkout', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();
    await tester.ensureVisible(find.text('Sign in / My account'));
    await tester.tap(find.text('Sign in / My account'));
    await tester.pumpAndSettle();
    expect(find.text('Account destination'), findsOneWidget);
  });

  testWidgets('small screen and enlarged text remain scrollable',
      (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(scale: 2));
    await tester.pump();
    await tester.ensureVisible(find.text('Explore CE access'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
