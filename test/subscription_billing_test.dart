import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/billing/revenuecat_billing.dart';
import 'package:luma_anesthesia/billing/subscription_billing.dart';

class FakeStore implements BillingGateway {
  @override
  String? userId = 'account-a';
  bool active = false;
  bool failVerification = false;
  String? failure;
  int purchases = 0;
  int restores = 0;
  Completer<bool>? verification;
  final identities = <String?>[];
  @override
  Future<void> identify(String? id) async {
    identities.add(id);
  }

  @override
  Future<List<BillingPlan>> plans() async => const [
    BillingPlan(
      SubscriptionTerm.monthly,
      RevenueCatConfig.appleMonthly,
      '€8,49',
    ),
    BillingPlan(
      SubscriptionTerm.annual,
      RevenueCatConfig.appleAnnual,
      '€65,99',
    ),
  ];
  @override
  Future<void> purchase(BillingPlan plan) async {
    purchases++;
    if (failure != null) throw BillingFailure(failure!);
  }

  @override
  Future<void> restore() async {
    restores++;
  }

  @override
  Future<bool> verify(String user) async {
    if (failVerification) throw StateError('offline');
    return verification == null ? active : verification!.future;
  }
}

/// Store that supports buying without an account (Guideline 5.1.1(v)).
class GuestStore extends FakeStore implements GuestBillingGateway {
  GuestStore() {
    userId = null;
  }
  @override
  bool isGuest = false;
  int guestStarts = 0;
  bool failGuest = false;
  final planIdentities = <String?>[];
  bool activateOnRestore = false;
  @override
  Future<void> restore() async {
    await super.restore();
    if (activateOnRestore) active = true;
  }

  @override
  Future<void> startGuest() async {
    guestStarts++;
    if (failGuest) throw const BillingFailure('Checkout could not start.');
    userId = 'guest-1';
    isGuest = true;
  }

  @override
  Future<List<BillingPlan>> plans() {
    planIdentities.add(userId);
    return super.plans();
  }
}

void main() {
  test('billing disabled by default and no real prices invented', () {
    final c = SubscriptionBilling();
    expect(RevenueCatConfig.enabled, false);
    expect(RevenueCatConfig.ceEnabled, false);
    expect(RevenueCatConfig.appleKey.startsWith('appl_'), true);
    expect(RevenueCatConfig.appleKey.startsWith('sk_'), false);
    expect(RevenueCatConfig.googleKey.startsWith('goog_'), true);
    expect(RevenueCatConfig.googleKey.startsWith('sk_'), false);
    expect(c.canPurchase, false);
    expect(c.plan(SubscriptionTerm.annual), null);
  });
  test('only exact existing products on matching platform accepted', () {
    expect(
      RevenueCatConfig.accepts(
        RevenueCatConfig.appleMonthly,
        SubscriptionTerm.monthly,
        TargetPlatform.iOS,
      ),
      true,
    );
    expect(
      RevenueCatConfig.accepts(
        RevenueCatConfig.googleAnnual,
        SubscriptionTerm.annual,
        TargetPlatform.android,
      ),
      true,
    );
    for (final id in [
      'Luma_Nurse_Monthly',
      'icu_lifetime',
      RevenueCatConfig.appleAnnual,
      RevenueCatConfig.googleMonthly,
    ]) {
      expect(
        RevenueCatConfig.accepts(
          id,
          SubscriptionTerm.monthly,
          TargetPlatform.iOS,
        ),
        false,
      );
    }
  });
  test(
    'store price retained and server readiness required before purchase',
    () async {
      final store = FakeStore();
      final c = SubscriptionBilling(gateway: store);
      await c.purchase(SubscriptionTerm.annual);
      expect(store.purchases, 0);
      await c.refresh();
      expect(c.plan(SubscriptionTerm.annual)?.price, '€65,99');
      expect(c.canPurchase, true);
    },
  );
  test('store completion alone does not grant access', () async {
    final store = FakeStore();
    final c = SubscriptionBilling(gateway: store);
    await c.refresh();
    await c.purchase(SubscriptionTerm.annual);
    expect(store.purchases, 1);
    expect(c.verified, false);
    expect(c.message, contains('Do not buy again'));
  });
  test('restore verifies access without making a purchase', () async {
    final store = FakeStore();
    final c = SubscriptionBilling(gateway: store);
    await c.refresh();
    store.active = true;
    await c.restore();
    expect(store.restores, 1);
    expect(store.purchases, 0);
    expect(c.verified, true);
  });
  test('verification failure blocks checkout', () async {
    final store = FakeStore()..failVerification = true;
    final c = SubscriptionBilling(gateway: store);
    await c.refresh();
    await c.purchase(SubscriptionTerm.monthly);
    expect(store.purchases, 0);
    expect(c.canPurchase, false);
  });
  test('canceled or pending transaction never grants access', () async {
    for (final failure in ['Purchase canceled.', 'Payment pending approval.']) {
      final store = FakeStore()..failure = failure;
      final c = SubscriptionBilling(gateway: store);
      await c.refresh();
      await c.purchase(SubscriptionTerm.monthly);
      expect(c.verified, false);
      expect(c.message, failure);
      expect(c.busy, false);
    }
  });
  test('double taps launch only one transaction', () async {
    final store = FakeStore();
    final c = SubscriptionBilling(gateway: store);
    await c.refresh();
    store.verification = Completer<bool>();
    final first = c.purchase(SubscriptionTerm.monthly);
    await c.purchase(SubscriptionTerm.monthly);
    store.verification!.complete(false);
    await first;
    expect(store.purchases, 1);
  });
  test('sign out discards in-flight verification and clears access', () async {
    final store = FakeStore();
    final c = SubscriptionBilling(gateway: store);
    await c.refresh();
    store.verification = Completer<bool>();
    final pending = c.refresh();
    await Future<void>.delayed(Duration.zero);
    store.userId = null;
    c.identityChanged();
    store.verification!.complete(true);
    await pending;
    expect(c.verified, false);
    expect(c.canPurchase, false);
    expect(store.identities.last, null);
  });
  test('active subscriber is not charged a second time', () async {
    final store = FakeStore();
    final c = SubscriptionBilling(gateway: store);
    await c.refresh();
    store.active = true;
    await c.purchase(SubscriptionTerm.annual);
    expect(store.purchases, 0);
    expect(c.verified, true);
  });
  group('guest purchases (Guideline 5.1.1(v))', () {
    test('signed-out shoppers see prices without a session', () async {
      final store = GuestStore();
      final c = SubscriptionBilling(gateway: store);
      await c.refresh();
      expect(store.guestStarts, 0);
      expect(c.plan(SubscriptionTerm.monthly)?.price, '€8,49');
      expect(c.hasIdentity, isFalse);
      expect(c.canStartPurchase, isTrue);
      expect(c.canRestore, isTrue);
      expect(c.message, isNull);
    });

    test('subscribe starts a guest session and buys under it', () async {
      final store = GuestStore();
      final c = SubscriptionBilling(gateway: store);
      await c.refresh();
      await c.purchase(SubscriptionTerm.annual);
      expect(store.guestStarts, 1);
      expect(store.purchases, 1);
      expect(store.identities, contains('guest-1'));
      expect(store.planIdentities.last, 'guest-1');
      expect(c.isGuest, isTrue);
      expect(c.signedIn, isFalse, reason: 'guests never unlock CE checkout');
    });

    test('restore works without an account', () async {
      final store = GuestStore();
      final c = SubscriptionBilling(gateway: store);
      await c.refresh();
      store.active = true;
      await c.restore();
      expect(store.guestStarts, 1);
      expect(store.restores, 1);
      expect(store.purchases, 0);
      expect(c.verified, isTrue);
    });

    test('a failed guest start takes no payment', () async {
      final store = GuestStore()..failGuest = true;
      final c = SubscriptionBilling(gateway: store);
      await c.refresh();
      await c.purchase(SubscriptionTerm.monthly);
      expect(store.purchases, 0);
      expect(c.busy, isFalse);
      expect(c.message, 'Checkout could not start.');
    });

    test('token refresh for the same identity keeps checkout state', () async {
      final store = GuestStore();
      final c = SubscriptionBilling(gateway: store);
      await c.refresh();
      await c.purchase(SubscriptionTerm.monthly);
      store.active = true;
      await c.refresh();
      expect(c.verified, isTrue);
      await c.identityChanged();
      expect(c.verified, isTrue);
    });

    test('a paying guest who signs in moves the purchase by restore', () async {
      final store = GuestStore();
      final c = SubscriptionBilling(gateway: store);
      await c.refresh();
      store.active = true;
      await c.restore();
      expect(c.verified, isTrue);
      final restoresBefore = store.restores;
      // Signs in to an existing account; the server has no lease yet.
      store
        ..userId = 'account-b'
        ..isGuest = false
        ..active = false
        ..activateOnRestore = true;
      await c.identityChanged();
      final calls = store.restores - restoresBefore;
      expect(calls, 1);
      expect(c.signedIn, isTrue);
      expect(c.verified, isTrue);
    });

    test('an unpaid guest who signs in is not prompted to restore', () async {
      final store = GuestStore();
      final c = SubscriptionBilling(gateway: store);
      await c.refresh();
      await c.purchase(SubscriptionTerm.monthly);
      store
        ..userId = 'account-b'
        ..isGuest = false;
      await c.identityChanged();
      expect(store.restores, 0);
    });

    test('stores without guest support still ask for sign-in', () async {
      final store = FakeStore()..userId = null;
      final c = SubscriptionBilling(gateway: store);
      await c.refresh();
      expect(c.guestCheckout, isFalse);
      expect(c.canStartPurchase, isFalse);
      expect(c.canRestore, isFalse);
      expect(c.message, contains('Sign in'));
    });
  });
}
