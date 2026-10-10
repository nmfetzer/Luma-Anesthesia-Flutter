import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/billing/checkout_policy.dart';

void main() {
  bool allowed(
    CheckoutPolicy policy, {
    bool customers = false,
    bool review = false,
    TargetPlatform platform = TargetPlatform.iOS,
  }) => policy.allowsSubscriptions(
    customerBuild: customers,
    reviewBuild: review,
    platform: platform,
  );

  test('review flag alone cannot authorize an ordinary customer', () {
    expect(allowed(const CheckoutPolicy(false, false), review: true), isFalse);
    expect(
      allowed(
        const CheckoutPolicy(false, false),
        customers: true,
        review: true,
      ),
      isFalse,
    );
  });
  test('designated reviewer requires review build and iOS', () {
    const policy = CheckoutPolicy(true, false);
    expect(allowed(policy), isFalse);
    expect(allowed(policy, customers: true), isFalse);
    expect(allowed(policy, review: true), isTrue);
    expect(
      allowed(policy, review: true, platform: TargetPlatform.android),
      isFalse,
    );
  });
  test('customer enablement needs both build and server switch', () {
    const policy = CheckoutPolicy(false, true);
    expect(allowed(policy, review: true), isFalse);
    expect(allowed(policy, customers: true), isTrue);
    expect(allowed(const CheckoutPolicy(true, true), customers: true), isFalse);
  });
  test(
    'release build supports both server-authorized review and customers',
    () {
      expect(
        allowed(
          const CheckoutPolicy(true, true),
          customers: true,
          review: true,
        ),
        isTrue,
      );
      expect(
        allowed(
          const CheckoutPolicy(false, true),
          customers: true,
          review: true,
        ),
        isTrue,
      );
      expect(
        allowed(
          const CheckoutPolicy(false, false),
          customers: true,
          review: true,
        ),
        isFalse,
      );
    },
  );
  test('missing, malformed and cross-account responses fail closed', () {
    for (final raw in [
      null,
      {},
      {'user_id': 'u', 'apple_review': true},
      {
        'user_id': 'other',
        'apple_review': true,
        'customer_subscriptions_enabled': true,
      },
      {
        'user_id': 'u',
        'apple_review': 'true',
        'customer_subscriptions_enabled': false,
      },
    ]) {
      expect(() => CheckoutPolicy.parse(raw, 'u'), throwsStateError);
    }
    expect(
      CheckoutPolicy.parse({
        'user_id': 'u',
        'apple_review': false,
        'customer_subscriptions_enabled': false,
      }, 'u').appleReview,
      isFalse,
    );
  });
  test('Android tester accounts follow the customer rule', () {
    const tester = CheckoutPolicy(true, true);
    expect(
      allowed(tester, customers: true, platform: TargetPlatform.android),
      isTrue,
    );
    expect(
      allowed(
        const CheckoutPolicy(true, false),
        customers: true,
        platform: TargetPlatform.android,
      ),
      isFalse,
    );
    expect(
      allowed(tester, review: true, platform: TargetPlatform.android),
      isFalse,
    );
  });
}
