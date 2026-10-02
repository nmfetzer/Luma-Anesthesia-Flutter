import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/billing/ce_billing.dart';
import 'package:luma_anesthesia/ce/ce_purchase_screen.dart';
import 'package:luma_anesthesia/ce/web/ce_web_checkout.dart';

class WebFake extends CeWebService {
  @override
  bool live = false;
  @override
  String? userId = 'test-user';
  @override
  bool configured = false;
  final events = StreamController<String?>.broadcast();
  @override
  Stream<String?> get accounts => events.stream;
  CeWebState value = const CeWebState(userId: 'test-user');
  int checkouts = 0;
  @override
  Future<CeWebState> load() async => value;
  @override
  Future<Uri> checkout(String code) async {
    checkouts++;
    return Uri.parse('https://checkout.stripe.com/c/pay/test-fixture');
  }
}

void main() {
  Widget app(WebFake service, {String id = CeProduct.medication}) =>
      CeWebCheckoutScope(
        service: service,
        child: MaterialApp(
          home: CePurchaseScreen(productId: id),
          routes: {
            '/account': (_) => const Scaffold(body: Text('Luma login')),
            '/ce-halo': (_) => const Scaffold(body: Text('Course library')),
          },
        ),
      );

  test('test checkout is disabled in ordinary builds', () {
    expect(SupabaseCeWebService.enabled, isFalse);
    expect(SupabaseCeWebService.endpoint, isEmpty);
    expect(SupabaseCeLiveService.liveEnabled, isFalse);
  });
  testWidgets('portal replaces iOS-only messaging without enabling checkout', (t) async {
    final service = WebFake();
    await t.pumpWidget(app(service));
    await t.pumpAndSettle();
    expect(find.text('Website checkout not enabled'), findsOneWidget);
    expect(find.text('Available in the iOS app'), findsNothing);
    final button = t.widget<FilledButton>(find.widgetWithText(FilledButton, 'Website checkout not enabled'));
    expect(button.onPressed, isNull);
    expect(service.checkouts, 0);
  });
  testWidgets('existing owner sees open course rather than repurchase', (t) async {
    final service = WebFake()
      ..value = const CeWebState(userId: 'test-user', existingCourses: {1});
    await t.pumpWidget(app(service));
    await t.pumpAndSettle();
    expect(find.text('Open course'), findsOneWidget);
    expect(find.text('Continue to Stripe test checkout'), findsNothing);
    expect(service.checkouts, 0);
  });
  testWidgets('test ownership does not open a production course', (t) async {
    final service = WebFake()
      ..configured = true
      ..value = const CeWebState(userId: 'test-user', testCourses: {1});
    await t.pumpWidget(app(service));
    await t.pumpAndSettle();
    expect(find.text('Test purchase verified · Production course access is unchanged.'), findsOneWidget);
    expect(find.text('Open course'), findsNothing);
    expect(service.checkouts, 0);
  });
  testWidgets('partial bundle ownership blocks duplicate purchase', (t) async {
    final service = WebFake()
      ..configured = true
      ..value = const CeWebState(userId: 'test-user', existingCourses: {1});
    await t.pumpWidget(app(service, id: CeProduct.bundle));
    await t.pumpAndSettle();
    final button = t.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue to Stripe test checkout'));
    expect(button.onPressed, isNull);
  });
  testWidgets('guest uses existing Luma login and never opens checkout', (t) async {
    final service = WebFake()..userId = null;
    await t.pumpWidget(app(service));
    await t.pumpAndSettle();
    await t.tap(find.text('Sign in with your Luma account'));
    await t.pumpAndSettle();
    expect(find.text('Luma login'), findsOneWidget);
    expect(service.checkouts, 0);
  });
  testWidgets('live portal uses secure checkout wording, not iOS or sandbox', (t) async {
    final service = WebFake()..live = true..configured = true;
    await t.pumpWidget(app(service));
    await t.pumpAndSettle();
    expect(find.text('Continue to secure checkout'), findsOneWidget);
    expect(find.textContaining('STRIPE TEST MODE'), findsNothing);
    expect(find.text('Available in the iOS app'), findsNothing);
  });
  testWidgets('live server availability gate disables purchase', (t) async {
    final service = WebFake()..live = true..configured = true
      ..value = const CeWebState(userId: 'test-user', checkoutAvailable: false);
    await t.pumpWidget(app(service));
    await t.pumpAndSettle();
    final button = t.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Website checkout unavailable'));
    expect(button.onPressed, isNull);
    expect(service.checkouts, 0);
  });
  testWidgets('account change clears previously displayed ownership', (t) async {
    final service = WebFake()
      ..value = const CeWebState(userId: 'test-user', existingCourses: {1});
    await t.pumpWidget(app(service));
    await t.pumpAndSettle();
    expect(find.text('Open course'), findsOneWidget);
    service.userId = null;
    service.events.add(null);
    await t.pumpAndSettle();
    expect(find.text('Open course'), findsNothing);
  });
  for (final width in [320.0, 1280.0]) {
    testWidgets('web test screen fits $width', (t) async {
      t.view.physicalSize = Size(width, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(app(WebFake(), id: CeProduct.bundle));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  }
}
