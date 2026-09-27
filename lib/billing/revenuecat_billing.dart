import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'subscription_billing.dart';

class RevenueCatConfig {
  static const enabled = bool.fromEnvironment('LUMA_BILLING_ENABLED');
  static const appleKey = String.fromEnvironment('REVENUECAT_APPLE_PUBLIC_KEY');
  static const googleKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_PUBLIC_KEY',
  );
  static const entitlement = 'Luma Anesthesia App Pro';
  static const offering = 'default';
  static const appleMonthly = 'Luma_Anesthesia_App_Monthly';
  static const appleAnnual = 'Luma_Anesthesia_Yearly_Pro';
  static const googleMonthly = 'luma_anesthesia_app_monthly:monthly';
  static const googleAnnual = 'luma_anesthesia_yearly_pro:yearly';

  static bool accepts(
    String id,
    SubscriptionTerm term,
    TargetPlatform platform,
  ) =>
      id ==
      (platform == TargetPlatform.iOS
          ? (term == SubscriptionTerm.annual ? appleAnnual : appleMonthly)
          : (term == SubscriptionTerm.annual ? googleAnnual : googleMonthly));
}

/// App-lifetime coordinator. Preview/web entrypoints never configure store SDKs.
class LumaBilling with WidgetsBindingObserver {
  LumaBilling._();
  static final instance = LumaBilling._();
  SubscriptionBilling controller = SubscriptionBilling(
    unavailableMessage: kIsWeb
        ? 'Native checkout is not available in this Chrome preview. '
              'Subscriptions will be available in the iOS and Android apps.'
        : 'Subscriptions are being prepared. No payment will be taken.',
  );
  StreamSubscription<AuthState>? _auth;
  Timer? _timer;
  bool _started = false;

  void start(SupabaseClient client) {
    if (_started) return;
    _started = true;
    if (!RevenueCatConfig.enabled || kIsWeb) return;
    final platform = defaultTargetPlatform;
    if (platform != TargetPlatform.iOS && platform != TargetPlatform.android) {
      return;
    }
    final key = platform == TargetPlatform.iOS
        ? RevenueCatConfig.appleKey
        : RevenueCatConfig.googleKey;
    final prefix = platform == TargetPlatform.iOS ? 'appl_' : 'goog_';
    if (!key.startsWith(prefix)) return; // Reject secret/test/wrong-store keys.
    controller = SubscriptionBilling(
      gateway: RevenueCatGateway(client, key, platform),
    );
    _auth = client.auth.onAuthStateChange.listen(
      (_) => controller.identityChanged(),
    );
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => controller.refresh(),
    );
    unawaited(controller.refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(controller.refresh());
  }

  void dispose() {
    _auth?.cancel();
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
  }
}

class RevenueCatGateway implements BillingGateway {
  RevenueCatGateway(this.client, this.key, this.platform);
  final SupabaseClient client;
  final String key;
  final TargetPlatform platform;
  final Map<String, Package> _packages = {};
  @override
  String? get userId {
    final user = client.auth.currentUser;
    return user == null || user.isAnonymous ? null : user.id;
  }

  @override
  Future<void> identify(String? userId) async {
    if (!await Purchases.isConfigured) {
      await Purchases.configure(
        PurchasesConfiguration(key)..appUserID = userId,
      );
    } else if (userId == null) {
      if (!await Purchases.isAnonymous) await Purchases.logOut();
    } else if (await Purchases.appUserID != userId) {
      await Purchases.logIn(userId);
    }
  }

  @override
  Future<List<BillingPlan>> plans() async {
    final offering =
        (await Purchases.getOfferings()).all[RevenueCatConfig.offering];
    _packages.clear();
    final result = <BillingPlan>[];
    for (final term in SubscriptionTerm.values) {
      final package = term == SubscriptionTerm.annual
          ? offering?.annual
          : offering?.monthly;
      if (package == null) continue;
      final product = package.storeProduct;
      // No fallbacks to Nurse, ICU, AI credits, lifetime or other apps.
      if (!RevenueCatConfig.accepts(product.identifier, term, platform)) {
        continue;
      }
      if (product.subscriptionPeriod !=
          (term == SubscriptionTerm.annual ? 'P1Y' : 'P1M')) {
        continue;
      }
      _packages[product.identifier] = package;
      result.add(BillingPlan(term, product.identifier, product.priceString));
    }
    return result;
  }

  @override
  Future<void> purchase(BillingPlan plan) => _storeAction(() async {
    await _requireCurrentIdentity();
    final package = _packages[plan.productId];
    if (package == null ||
        !RevenueCatConfig.accepts(plan.productId, plan.term, platform)) {
      throw const BillingFailure(
        'This subscription is unavailable. Refresh and try again.',
      );
    }
    // Existing subscriptions are managed through the store, not a second purchase.
    final info = await Purchases.getCustomerInfo();
    if (info.entitlements.active.containsKey(RevenueCatConfig.entitlement)) {
      throw const BillingFailure(
        'You already have an active subscription. '
        'Use Refresh access or manage your plan in your store account.',
      );
    }
    await Purchases.purchase(PurchaseParams.package(package));
  });

  @override
  Future<void> restore() => _storeAction(() async {
    await _requireCurrentIdentity();
    await Purchases.restorePurchases();
  });

  Future<void> _requireCurrentIdentity() async {
    final expected = userId;
    if (expected == null ||
        await Purchases.appUserID != expected ||
        expected != userId) {
      throw const BillingFailure(
        'Your account changed. Use Refresh access before continuing.',
      );
    }
  }

  Future<void> _storeAction(Future<void> Function() action) async {
    try {
      await action();
    } on PlatformException catch (error) {
      switch (PurchasesErrorHelper.getErrorCode(error)) {
        case PurchasesErrorCode.purchaseCancelledError:
          throw const BillingFailure(
            'Purchase canceled. No access was changed.',
          );
        case PurchasesErrorCode.paymentPendingError:
          throw const BillingFailure(
            'Your store payment is pending approval. '
            'Access will activate after verification. Do not purchase again.',
          );
        default:
          throw const BillingFailure(
            'The store could not complete this request. '
            'If charged, use Restore purchases instead of purchasing again.',
          );
      }
    }
  }

  @override
  Future<bool> verify(String expectedUser) async {
    final session = client.auth.currentSession;
    if (session == null ||
        session.user.id != expectedUser ||
        session.user.isAnonymous) {
      throw const BillingFailure('Please sign in to your Luma account first.');
    }
    final response = await client.functions.invoke(
      'revenuecat-sync',
      headers: {'Authorization': 'Bearer ${session.accessToken}'},
      body: const <String, dynamic>{},
    );
    if (response.status != 200 ||
        response.data is! Map ||
        response.data['user_id'] != expectedUser ||
        response.data['active'] is! bool) {
      throw StateError('Server verification unavailable');
    }
    return response.data['active'] == true;
  }
}
