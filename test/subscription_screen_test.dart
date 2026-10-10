import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/screens/subscription_screen.dart';
import 'package:luma_anesthesia/billing/subscription_billing.dart';

import 'subscription_billing_test.dart' show FakeStore, GuestStore;

class TrialStore extends FakeStore {
  @override
  Future<List<BillingPlan>> plans() async => const [
    BillingPlan(
      SubscriptionTerm.monthly,
      'Luma_Anesthesia_App_Monthly',
      r'$9.99',
      freeTrial: '2-week',
    ),
    BillingPlan(
      SubscriptionTerm.annual,
      'Luma_Anesthesia_Yearly_Pro',
      r'$69.99',
    ),
  ];
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget app({double scale = 1, Future<bool> Function(Uri)? openExternal}) =>
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
            textScaler: TextScaler.linear(scale),
          ),
          child: child!,
        ),
        home: SubscriptionScreen(openExternal: openExternal),
        routes: {
          '/ce-halo': (_) => const CeAccessScreen(),
          '/account': (_) => const Scaffold(body: Text('Account destination')),
        },
      );

  testWidgets('paywall previews plans without pretending checkout is live', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pump();
    final logo = tester.widget<Image>(find.byType(Image));
    expect(
      (logo.image as AssetImage).assetName,
      'assets/branding/luma_symbol_halo.png',
    );
    expect(logo.fit, BoxFit.contain);
    expect(find.text('LUMA PREMIUM'), findsOneWidget);
    expect(find.text(r'$9.99'), findsOneWidget);
    expect(find.text(r'$69.99'), findsOneWidget);
    expect(find.textContaining('Prices shown in USD'), findsOneWidget);
    expect(
      find.textContaining('automatically renew unless canceled'),
      findsOneWidget,
    );
    final checkout = find.widgetWithText(FilledButton, 'Sign in to subscribe');
    expect(tester.widget<FilledButton>(checkout).onPressed, isNotNull);
    await tester.ensureVisible(find.text('Monthly'));
    await tester.tap(find.text('Monthly'));
    await tester.pump();
    expect(find.textContaining('Prices shown in USD'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('configured paywall uses localized price and selected plan', (
    tester,
  ) async {
    final store = FakeStore();
    final billing = SubscriptionBilling(gateway: store);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: SubscriptionScreen(billing: billing),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('€65,99'), findsOneWidget);
    expect(find.text('€8,49'), findsOneWidget);
    expect(find.textContaining('1-year auto-renewable'), findsOneWidget);
    await tester.ensureVisible(find.text('Subscribe annually'));
    await tester.tap(find.text('Subscribe annually'));
    await tester.pumpAndSettle();
    expect(store.purchases, 1);
    expect(find.textContaining('Do not buy again'), findsOneWidget);
    expect(billing.verified, false);
    expect(tester.takeException(), isNull);
  });

  testWidgets('legal links open the verified terms and privacy destinations', (
    tester,
  ) async {
    final opened = <Uri>[];
    await tester.pumpWidget(
      app(
        openExternal: (uri) async {
          opened.add(uri);
          return true;
        },
      ),
    );
    for (final label in ['Terms of Use / EULA', 'Privacy Policy']) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pump();
    }
    expect(opened.map((uri) => uri.toString()), [
      'https://cehalo.com/terms-of-use-eula',
      'https://cehalo.com/privacy-policy',
    ]);
  });

  testWidgets('failed legal link shows a readable fallback address', (
    tester,
  ) async {
    await tester.pumpWidget(app(openExternal: (_) async => false));
    await tester.ensureVisible(find.text('Privacy Policy'));
    await tester.tap(find.text('Privacy Policy'));
    await tester.pump();
    expect(
      find.textContaining('Could not open this page. Please visit'),
      findsOneWidget,
    );
  });

  test('billing notices distinguish native stores from the web preview', () {
    final ios = subscriptionBillingNotice(TargetPlatform.iOS, isWeb: false);
    expect(ios, contains('Apple Account'));
    expect(ios, isNot(contains('Google Play')));
    final android = subscriptionBillingNotice(
      TargetPlatform.android,
      isWeb: false,
    );
    expect(android, contains('Google Play'));
    expect(android, isNot(contains('Apple Account')));
    final web = subscriptionBillingNotice(TargetPlatform.iOS, isWeb: true);
    expect(web, contains('For iOS purchases:'));
    expect(web, contains('For Android purchases:'));
    expect(web, contains('not available in this Chrome preview'));
  });

  testWidgets(
    'CE is separate, describes both bonuses and opens without login',
    (tester) async {
      await tester.pumpWidget(app());
      await tester.pump();
      expect(
        find.textContaining('No app subscription is required'),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('Explore CE access'));
      await tester.tap(find.text('Explore CE access'));
      await tester.pumpAndSettle();
      expect(find.text('CE HALO'), findsOneWidget);
      expect(find.byType(CeAccessScreen), findsOneWidget);
      expect(
        find.textContaining('Maximum 3 bonus months per account across stores'),
        findsOneWidget,
      );
      expect(
        find.textContaining('No app subscription is required'),
        findsOneWidget,
      );
    },
  );

  testWidgets('account link remains separate from checkout', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();
    await tester.ensureVisible(find.text('Sign in to subscribe'));
    await tester.tap(find.text('Sign in to subscribe'));
    await tester.pumpAndSettle();
    expect(find.text('Account destination'), findsOneWidget);
  });

  testWidgets('small screen and enlarged text remain scrollable', (
    tester,
  ) async {
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

  for (final size in [
    const Size(320, 740),
    const Size(390, 844),
    const Size(820, 1180),
    const Size(1180, 820),
  ]) {
    testWidgets('plans, subscribe and pinned Home are usable at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(app());
      await tester.pump();
      expect(find.text(r'$9.99').hitTestable(), findsOneWidget);
      expect(find.text(r'$69.99').hitTestable(), findsOneWidget);
      expect(find.text('Sign in to subscribe').hitTestable(), findsOneWidget);
      await tester.ensureVisible(find.text('Explore CE access'));
      expect(find.text('Home').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('guests can subscribe and restore without an account', (
    tester,
  ) async {
    final store = GuestStore();
    final billing = SubscriptionBilling(gateway: store);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: SubscriptionScreen(billing: billing),
        routes: {
          '/account': (_) => const Scaffold(body: Text('Account destination')),
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign in to subscribe'), findsNothing);
    expect(
      find.textContaining('No account needed to subscribe'),
      findsOneWidget,
    );
    expect(find.text('Create free account'), findsOneWidget);
    final restore = find.widgetWithText(TextButton, 'Restore purchases');
    expect(tester.widget<TextButton>(restore).onPressed, isNotNull);
    await tester.ensureVisible(find.text('Subscribe annually'));
    await tester.tap(find.text('Subscribe annually'));
    await tester.pumpAndSettle();
    expect(store.guestStarts, 1);
    expect(store.purchases, 1);
    expect(find.text('Account destination'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('paywall discloses the free trial and the charge after it', (
    tester,
  ) async {
    final billing = SubscriptionBilling(gateway: TrialStore());
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: SubscriptionScreen(billing: billing),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('2-week free trial'), findsOneWidget);
    await tester.ensureVisible(find.text('Monthly'));
    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(
        r'2-week free trial for eligible new subscribers, then $9.99 per month until canceled',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('before the trial ends'), findsOneWidget);
    await tester.ensureVisible(find.text('Yearly'));
    await tester.tap(find.text('Yearly'));
    await tester.pumpAndSettle();
    expect(find.textContaining(r'Billed $69.99 per year.'), findsOneWidget);
    expect(find.textContaining('free trial for eligible'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('free trial length formats store periods', () {
    expect(freeTrialLength(2, 'week'), '2-week');
    expect(freeTrialLength(14, 'day'), '14-day');
    expect(freeTrialLength(0, 'week'), isNull);
    expect(freeTrialLength(1, 'unknown'), isNull);
  });

  testWidgets('trial wording fits a small phone at double text size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final billing = SubscriptionBilling(gateway: TrialStore());
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
            textScaler: const TextScaler.linear(2),
          ),
          child: child!,
        ),
        home: SubscriptionScreen(billing: billing),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Monthly'));
    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.textContaining('before the trial ends'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
