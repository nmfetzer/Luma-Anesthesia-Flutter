import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../billing/ce_billing.dart';
import '../billing/revenuecat_billing.dart';
import '../billing/subscription_billing.dart';
import '../welcome/luma_theme.dart' as brand;
import '../welcome/welcome_background.dart';
import '../widgets/luma_home_button.dart';
import 'ce_paywall_copy.dart';

/// Each route presents ONE exact course or bundle. The no-ID route is only
/// an options index; it never displays four separate checkout forms.
class CePurchaseScreen extends StatefulWidget {
  const CePurchaseScreen({
    super.key,
    this.billing,
    this.productId,
    this.openExternal,
  });
  final SubscriptionBilling? billing;
  final String? productId;
  final Future<bool> Function(Uri)? openExternal;

  static String productForCourse(int courseNumber) => switch (courseNumber) {
    1 => CeProduct.medication,
    2 => CeProduct.uncommon,
    3 => CeProduct.legal,
    _ => throw ArgumentError.value(courseNumber, 'courseNumber'),
  };

  @override
  State<CePurchaseScreen> createState() => _CePurchaseScreenState();
}

class _CePurchaseScreenState extends State<CePurchaseScreen> {
  late final billing = widget.billing ?? LumaBilling.instance.controller;
  static const navy = brand.LumaColors.navy;
  static const cream = brand.LumaColors.cream;
  static const muted = Color(0xFF52606A);

  CeProduct? get selected {
    for (final product in CeProduct.all) {
      if (product.id == widget.productId) return product;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    billing.addListener(changed);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) billing.refreshCe();
    });
  }

  void changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    billing.removeListener(changed);
    super.dispose();
  }

  Future<void> signIn() async {
    await Navigator.of(context).pushNamed('/account');
    if (mounted) await billing.refreshCe();
  }

  Future<void> open(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await (widget.openExternal?.call(uri) ??
          launchUrl(uri, mode: LaunchMode.externalApplication))) {
        throw StateError('Unable to open page');
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please visit $url')));
    }
  }

  Future<void> showProduct(String id) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      settings: const RouteSettings(name: '/ce-purchase'),
      builder: (_) => CePurchaseScreen(
        productId: id,
        billing: billing,
        openExternal: widget.openExternal,
      ),
    ),
  );

  TextStyle body([double size = 14]) =>
      brand.LumaText.body(size: size, color: muted);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: brand.LumaColors.navyDeep,
    body: Stack(
      children: [
        const WelcomeBackground(heroHaloOpacity: 0),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/branding/luma_symbol_halo.png',
                      height: 38,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'CE HALO',
                        style: brand.LumaText.body(
                          size: 16,
                          color: brand.LumaColors.goldSoft,
                        ),
                      ),
                    ),
                    const LumaHomeButton(color: cream),
                    IconButton(
                      tooltip: 'Close CE purchase options',
                      color: cream,
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context)
                              .pushReplacementNamed('/ce-halo');
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Material(
                        color: cream,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: const BorderSide(
                            color: brand.LumaColors.goldSoft,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(
                            MediaQuery.sizeOf(context).width < 400 ? 20 : 28,
                          ),
                          child: selected == null
                              ? options()
                              : paywall(selected!),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget options() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Choose your next course',
        style: brand.LumaText.title(size: 28, color: navy),
      ),
      const SizedBox(height: 10),
      Text(
        'Explore an individual course or the complete three-course bundle. '
        'No app subscription required.',
        style: body(),
      ),
      const SizedBox(height: 20),
      for (final product in CeProduct.all)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OutlinedButton(
            onPressed: () => showProduct(product.id),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              foregroundColor: navy,
            ),
            child: Row(
              children: [
                Expanded(child: Text(product.title)),
                const SizedBox(width: 10),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
    ],
  );

  Widget paywall(CeProduct product) {
    final copy = CePaywallCopy.byProduct[product.id]!;
    final bundle = product.id == CeProduct.bundle;
    final owned = billing.ceStatus?.owned.contains(product.id) == true;
    final price = billing.ceProducts
        .where((p) => p.id == product.id)
        .firstOrNull
        ?.price;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          copy.kicker,
          style: body(12)
              .copyWith(letterSpacing: 1.3, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          bundle ? 'Three courses.\nOne complete collection.' : product.title,
          style: brand.LumaText.title(size: 28, color: navy),
        ),
        const SizedBox(height: 12),
        Text(
          bundle
              ? '60 MAC Ed CE credits across three courses'
              : '20 MAC Ed CE credits',
          style: body(14).copyWith(color: navy, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(copy.description, style: body()),
        const SizedBox(height: 16),
        for (final highlight in copy.highlights)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check, size: 18, color: navy),
                const SizedBox(width: 10),
                Expanded(child: Text(highlight, style: body(13))),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE4D2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bundle
                    ? 'Up to 3 complimentary months of Luma Premium'
                    : '1 complimentary month of Luma Premium',
                style: body(14)
                    .copyWith(color: navy, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              Text(
                bundle
                    ? 'Three bonus months total per account. A prior course '
                          'bonus counts toward this total.'
                    : 'Included with your first individual-course purchase, one time.',
                style: body(12),
              ),
              const SizedBox(height: 4),
              Text('No automatic subscription enrollment.', style: body(12)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (price != null && !owned) ...[
          Text(price, style: brand.LumaText.title(size: 30, color: navy)),
          const SizedBox(height: 3),
        ],
        Text(
          'One-time purchase. No app subscription required.',
          style: body(12),
        ),
        const SizedBox(height: 12),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: navy,
            foregroundColor: cream,
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: owned
              ? () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacementNamed('/ce-halo');
                  }
                }
              : billing.busy
              ? null
              : billing.ceAvailable && !billing.signedIn
              ? signIn
              : billing.canPurchaseCe(product.id)
              ? () => billing.purchaseCe(product.id)
              : null,
          child: Text(label(product.id)),
        ),
        if (billing.cePriceMissing(product.id) && !billing.busy)
          TextButton(
            onPressed: billing.refreshCe,
            child: const Text('Retry loading price'),
          ),
        if (!billing.ceAvailable)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Design preview. Complete purchases in the iOS app; '
              'no payment is taken here.',
              textAlign: TextAlign.center,
              style: body(12),
            ),
          ),
        if (billing.ceStatus?.appleReview == true)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'TestFlight sandbox: test purchases and preview learning '
              'do not award CE credit.',
              textAlign: TextAlign.center,
              style: body(12),
            ),
          ),
        if (billing.message != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              billing.message!,
              style: body(12),
              textAlign: TextAlign.center,
            ),
          ),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            TextButton(
              onPressed:
                  billing.ceAvailable && billing.signedIn && !billing.busy
                  ? billing.restoreCe
                  : null,
              child: const Text('Restore purchases'),
            ),
            TextButton(
              onPressed: billing.ceAvailable && !billing.busy
                  ? billing.refreshCe
                  : null,
              child: const Text('Refresh access'),
            ),
          ],
        ),
        Text(
          'CE credit and certificates require successful completion of the '
          'course requirements. Payment alone does not award credit.',
          style: body(12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text('Purchase & bonus details', style: body(13)),
          children: [
            Text(
              'Payment is processed through your app store at confirmation. '
              'This is a one-time course purchase, not an auto-renewing subscription. '
              'Clinical app subscriptions do not include these courses.\n\n'
              'Maximum three complimentary calendar months per account across stores. '
              'A bundle adds only two months after a prior course month. '
              'Additional individual courses and restores add no months. '
              'Refunds do not reset bonus eligibility. Existing paid subscription '
              'billing is unchanged. Course ownership is separate from bonus expiry.',
              style: body(12),
            ),
            const SizedBox(height: 12),
          ],
        ),
        if (billing.ceStatus?.appleReview == true &&
            billing.ceStoreDiagnostic.isNotEmpty)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('Test purchase loading details', style: body(13)),
            children: [
              SelectableText(billing.ceStoreDiagnostic, style: body(12)),
            ],
          ),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            TextButton(
              onPressed: () => open('https://cehalo.com/terms-of-use-eula'),
              child: const Text('Terms of Use'),
            ),
            TextButton(
              onPressed: () => open('https://cehalo.com/privacy-policy'),
              child: const Text('Privacy Policy'),
            ),
          ],
        ),
        if (!bundle)
          TextButton(
            onPressed: () => showProduct(CeProduct.bundle),
            child: const Text('Explore the three-course bundle'),
          ),
      ],
    );
  }

  String label(String id) {
    if (billing.ceStatus?.owned.contains(id) == true) {
      return 'Purchased · Continue';
    }
    if (billing.ceAwaitingVerification(id)) return 'Verifying purchase';
    if (billing.busy) return 'Loading…';
    if (!billing.ceAvailable) return 'Available in the iOS app';
    if (!billing.signedIn) return 'Sign in to purchase';
    if (!billing.ceReady) return 'Unable to check purchase access';
    if (billing.ceStatus?.enabled.contains(id) != true) {
      return 'Purchases are not enabled for this course';
    }
    for (final product in billing.ceProducts) {
      if (product.id == id) return 'Purchase for ${product.price}';
    }
    return 'Price could not be loaded';
  }
}
