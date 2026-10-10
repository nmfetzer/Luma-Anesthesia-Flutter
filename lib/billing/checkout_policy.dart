import 'package:flutter/foundation.dart';

/// Server response must match the current permanent account. Neither a build
/// flag nor a client-provided "reviewer" value is sufficient authorization.
class CheckoutPolicy {
  const CheckoutPolicy(this.appleReview, this.customerSubscriptions);
  final bool appleReview;
  final bool customerSubscriptions;

  factory CheckoutPolicy.parse(dynamic raw, String expectedUser) {
    if (raw is! Map ||
        raw['user_id'] != expectedUser ||
        raw['apple_review'] is! bool ||
        raw['customer_subscriptions_enabled'] is! bool) {
      throw StateError('Billing policy unavailable');
    }
    return CheckoutPolicy(
      raw['apple_review'] as bool,
      raw['customer_subscriptions_enabled'] as bool,
    );
  }

  /// Sandbox tester status only applies to Apple's review/TestFlight checkout.
  /// On Android a tester account follows the normal customer rule, so new
  /// accounts are not blocked from real Google Play purchases.
  bool allowsSubscriptions({
    required bool customerBuild,
    required bool reviewBuild,
    required TargetPlatform platform,
  }) => appleReview && platform == TargetPlatform.iOS
      ? reviewBuild
      : customerBuild && customerSubscriptions;
}
