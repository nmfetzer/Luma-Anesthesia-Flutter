import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../billing/revenuecat_billing.dart';
import '../billing/subscription_billing.dart';
import '../welcome/luma_theme.dart' as brand;
import '../welcome/welcome_background.dart';
import '../widgets/luma_home_button.dart';

/// One subscription page. Reference prices never authorize a transaction:
/// checkout requires the actual store package and server purchase eligibility.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key, this.openExternal, this.billing});
  final SubscriptionBilling? billing;
  final Future<bool> Function(Uri)? openExternal;

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _annual = true;
  late final SubscriptionBilling _billing =
      widget.billing ?? LumaBilling.instance.controller;
  SubscriptionTerm get _term =>
      _annual ? SubscriptionTerm.annual : SubscriptionTerm.monthly;
  static const _ink = brand.LumaColors.navy;

  @override
  void initState() {
    super.initState();
    _billing.addListener(_changed);
    _billing.refresh();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _billing.removeListener(_changed);
    super.dispose();
  }

  String _price(SubscriptionTerm term) =>
      _billing.plan(term)?.price ??
      (term == SubscriptionTerm.annual ? r'$69.99' : r'$9.99');

  Future<void> _account() async {
    await Navigator.pushNamed(context, '/account');
    if (mounted) await _billing.refresh();
  }

  Future<void> _openLegal(String address) async {
    try {
      final uri = Uri.parse(address);
      final opened =
          await (widget.openExternal?.call(uri) ??
              launchUrl(uri, mode: LaunchMode.externalApplication));
      if (!opened) throw StateError('Unable to open legal page');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open this page. Please visit $address'),
        ),
      );
    }
  }

  TextStyle _body([double size = 13]) =>
      brand.LumaText.body(size: size, color: const Color(0xFF52606A));

  @override
  Widget build(BuildContext context) {
    final loaded = _billing.plan(_term) != null;
    final canBuy = _billing.canPurchase && loaded;
    return Scaffold(
      backgroundColor: brand.LumaColors.navyDeep,
      body: Stack(
        children: [
          const WelcomeBackground(heroHaloOpacity: 0),
          SafeArea(
            child: Column(
              children: [
                // Navigation stays visible, including at large text sizes.
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
                        child: Text('Luma', style: brand.LumaText.wordmark()),
                      ),
                      const LumaHomeButton(color: brand.LumaColors.cream),
                      IconButton(
                        tooltip: 'Close subscription options',
                        onPressed: () => Navigator.of(context).maybePop(),
                        color: brand.LumaColors.cream,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: brand.LumaColors.cream,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: brand.LumaColors.goldSoft,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'LUMA PREMIUM',
                                style: _body(11).copyWith(
                                  letterSpacing: 1.6,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your clinical companion',
                                style: brand.LumaText.title(
                                  size: 26,
                                  color: _ink,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _benefit(
                                'Vasopressors, Infusions & Transfusions',
                              ),
                              _benefit('Crisis Hub clinical references'),
                              _benefit(
                                'Pathophysiology & Anesthesia Considerations',
                              ),
                              _benefit('Drug Library Deep Dives'),
                              _benefit(
                                'Diagnostics: labs, acid–base & imaging',
                              ),
                              _benefit(
                                'Regional anesthesia: blocks, safety & recovery',
                              ),
                              const SizedBox(height: 8),
                              if (MediaQuery.textScalerOf(context).scale(14) >
                                  21)
                                Column(
                                  children: [
                                    _plan(false, 'Monthly'),
                                    const SizedBox(height: 10),
                                    _plan(true, 'Yearly'),
                                  ],
                                )
                              else
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _plan(false, 'Monthly')),
                                    const SizedBox(width: 10),
                                    Expanded(child: _plan(true, 'Yearly')),
                                  ],
                                ),
                              const SizedBox(height: 7),
                              Text(
                                loaded
                                    ? '${_annual ? '1-year' : '1-month'} auto-renewable subscription. '
                                          'Billed ${_price(_term)} per ${_annual ? 'year' : 'month'}.'
                                    : 'Prices shown in USD. Your app store confirms local pricing before purchase.',
                                style: _body(11),
                              ),
                              const SizedBox(height: 10),
                              FilledButton(
                                onPressed: _billing.busy || _billing.verified
                                    ? null
                                    : !_billing.signedIn
                                    ? _account
                                    : canBuy
                                    ? () => _billing.purchase(_term)
                                    : null,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _ink,
                                  foregroundColor: brand.LumaColors.cream,
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                child: Text(
                                  _billing.busy
                                      ? 'Please wait…'
                                      : _billing.verified
                                      ? 'Premium access verified'
                                      : !_billing.signedIn
                                      ? 'Sign in to subscribe'
                                      : !_billing.available
                                      ? 'Purchases coming soon'
                                      : 'Subscribe ${_annual ? 'annually' : 'monthly'}',
                                ),
                              ),
                              if (_billing.signedIn && _billing.message != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    _billing.message!,
                                    style: _body(12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              if (!_billing.available)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    'Preview only. Store purchases are not enabled here.',
                                    style: _body(11),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                children: [
                                  TextButton(
                                    onPressed:
                                        _billing.available &&
                                            _billing.signedIn &&
                                            _billing.serverReady &&
                                            !_billing.busy
                                        ? _billing.restore
                                        : null,
                                    child: const Text('Restore purchases'),
                                  ),
                                  TextButton(
                                    onPressed: _billing.busy
                                        ? null
                                        : _billing.signedIn
                                        ? _billing.refresh
                                        : _account,
                                    child: Text(
                                      _billing.signedIn
                                          ? 'Refresh access'
                                          : 'Create account',
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Subscriptions automatically renew unless canceled at least '
                                '24 hours before the end of the current period. '
                                '${subscriptionBillingNotice(Theme.of(context).platform, isWeb: kIsWeb)}',
                                style: _body(11),
                              ),
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () => _openLegal(
                                      'https://cehalo.com/terms-of-use-eula',
                                    ),
                                    child: const Text('Terms of Use / EULA'),
                                  ),
                                  TextButton(
                                    onPressed: () => _openLegal(
                                      'https://cehalo.com/privacy-policy',
                                    ),
                                    child: const Text('Privacy Policy'),
                                  ),
                                ],
                              ),
                              const Divider(height: 12),
                              Text(
                                'No app subscription is required for AANA-approved CE. '
                                'Courses are purchased separately.',
                                textAlign: TextAlign.center,
                                style: _body(12),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/ce-halo'),
                                child: const Text('Explore CE access'),
                              ),
                              Text(
                                'Basic Drug Library, Quick References and provider mental health support stay free.',
                                textAlign: TextAlign.center,
                                style: _body(11),
                              ),
                            ],
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
  }

  Widget _benefit(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check, size: 17, color: _ink),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: _body(13).copyWith(color: _ink)),
        ),
      ],
    ),
  );

  Widget _plan(bool annual, String label) {
    final selected = annual == _annual;
    final price = _price(
      annual ? SubscriptionTerm.annual : SubscriptionTerm.monthly,
    );
    return Semantics(
      button: true,
      selected: selected,
      label: '$label plan, $price per ${annual ? 'year' : 'month'}',
      child: Material(
        color: selected ? const Color(0xFFEDE4D2) : brand.LumaColors.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? _ink : const Color(0xFFC8C0B2),
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _annual = annual),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: _body(13)
                      .copyWith(color: _ink, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(price, style: brand.LumaText.title(size: 24, color: _ink)),
                Text(annual ? 'per year' : 'per month', style: _body(11)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String subscriptionBillingNotice(
  TargetPlatform platform, {
  required bool isWeb,
}) {
  const apple =
      'Payment is charged to your Apple Account at confirmation. '
      'Renewal is charged within 24 hours before the next period. '
      'Manage or cancel in Settings > your name > Subscriptions.';
  const google =
      'Payment is charged through your Google Play account. '
      'Manage or cancel in Google Play > Payments & subscriptions > Subscriptions.';
  if (isWeb) {
    return 'For iOS purchases: $apple\n'
        'For Android purchases: $google\n'
        'Store billing is not available in this Chrome preview.';
  }
  return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS
      ? apple
      : google;
}

class CeAccessMessage extends StatelessWidget {
  const CeAccessMessage({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Your CE. Your choice.',
        style: brand.LumaText.title(size: 24, color: brand.LumaColors.navy),
      ),
      const SizedBox(height: 12),
      const Text(
        'No app subscription is required to access AANA-approved CE content. '
        'Courses and bundles are purchased separately.',
      ),
      const SizedBox(height: 16),
      const Text(
        '1 course purchase: 1 complimentary month, one time.\n'
        'Bundle purchase: up to 3 complimentary months total.',
      ),
      const SizedBox(height: 12),
      const Text(
        'Planned activation: access is added after a verified course purchase. '
        'No code and no automatic subscription charge. '
        'Maximum 3 bonus months per account across stores. '
        'If you already received the course month, the bundle adds only 2 more months '
        'after any remaining CE bonus access. Additional course purchases and restores '
        'add no months. Existing paid subscription billing is unchanged. '
        'Course purchases and bonus activation are coming soon.',
      ),
    ],
  );
}

class CeAccessScreen extends StatelessWidget {
  const CeAccessScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('CE HALO'),
      actions: const [LumaHomeButton()],
    ),
    body: const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Center(child: SizedBox(width: 580, child: CeAccessMessage())),
    ),
  );
}
