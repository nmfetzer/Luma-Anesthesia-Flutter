import 'package:flutter/material.dart';

import '../widgets/luma_home_button.dart';

import '../billing/ce_billing.dart';
import '../billing/revenuecat_billing.dart';
import '../billing/subscription_billing.dart';

/// Native Apple storefront. No receipt, bonus duration or access is trusted here.
class CePurchaseScreen extends StatefulWidget {
  const CePurchaseScreen({super.key, this.billing});
  final SubscriptionBilling? billing;
  @override
  State<CePurchaseScreen> createState() => _CePurchaseScreenState();
}

class _CePurchaseScreenState extends State<CePurchaseScreen> {
  late final billing = widget.billing ?? LumaBilling.instance.controller;
  @override
  void initState() {
    super.initState();
    billing.addListener(changed);
    billing.refreshCe();
  }

  void changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    billing.removeListener(changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('CE courses & purchases'),
      actions: const [LumaHomeButton()],
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'CE courses are separate one-time purchases. A clinical '
          'subscription does not include CE courses.',
        ),
        const SizedBox(height: 16),
        if (billing.ceStatus?.appleReview == true)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Designated Apple test account. Use TestFlight or Apple sandbox '
              'for testing. Course activity and certificates are previews only '
              'and do not earn CE credit.',
            ),
          ),
        if (!billing.ceAvailable)
          const Text(
            'Apple checkout is being prepared. No payment will be taken. '
            'Checkout is not available in the Chrome preview.',
          ),
        if (billing.ceAvailable && !billing.signedIn)
          OutlinedButton(
            onPressed: billing.busy
                ? null
                : () async {
                    await Navigator.of(context).pushNamed('/account');
                    await billing.refreshCe();
                  },
            child: const Text('Sign in for CE purchases'),
          ),
        for (final product in CeProduct.all) ...[
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.id == CeProduct.bundle
                        ? 'Includes all three courses. Up to three complimentary '
                              'calendar months of clinical access in total per account.'
                        : 'Includes one complimentary calendar month of clinical '
                              'access on your first individual-course purchase only.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: billing.canPurchaseCe(product.id)
                        ? () => billing.purchaseCe(product.id)
                        : null,
                    child: Text(label(product.id)),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (billing.busy) const LinearProgressIndicator(),
        if (billing.message != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(billing.message!, semanticsLabel: billing.message),
          ),
        OutlinedButton(
          onPressed: billing.ceAvailable && !billing.busy
              ? billing.refreshCe
              : null,
          child: const Text('Refresh CE access'),
        ),
        TextButton(
          onPressed: billing.ceAvailable && billing.signedIn && !billing.busy
              ? billing.restoreCe
              : null,
          child: const Text('Restore CE purchases'),
        ),
        const Text(
          'Maximum three complimentary calendar months per account '
          'across stores. A bundle adds only two months after a prior course '
          'month. Additional individual courses and restores add no months. '
          'Refunds do not reset eligibility. Bonus access does not enroll you '
          'in a subscription or change existing subscription billing. '
          'Course ownership is separate from bonus expiry.',
        ),
      ],
    ),
  );
  String label(String id) {
    if (billing.ceStatus?.owned.contains(id) == true) return 'Purchased';
    for (final product in billing.ceProducts) {
      if (product.id == id && billing.ceStatus?.enabled.contains(id) == true) {
        return 'Purchase for ${product.price}';
      }
    }
    return 'Not available for purchase yet';
  }
}
