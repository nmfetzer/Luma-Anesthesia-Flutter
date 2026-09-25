import 'package:flutter/material.dart';
import '../widgets/luma_home_button.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../welcome/luma_theme.dart' as brand;
import '../welcome/welcome_background.dart';

/// Presentation only until store products and verified billing are connected.
/// This screen never grants access or changes a subscription.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key, this.openExternal});

  /// Optional launcher for testing legal links without opening a real browser.
  final Future<bool> Function(Uri)? openExternal;

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _annual = true;
  static const _ink = brand.LumaColors.navy;
  static const _muted = Color(0xFF52606A);

  TextStyle _body({double size = 14}) =>
      brand.LumaText.body(size: size, color: _muted);

  Future<void> _openLegal(String address) async {
    try {
      final uri = Uri.parse(address);
      final opened = await (widget.openExternal?.call(uri) ??
          launchUrl(uri, mode: LaunchMode.externalApplication));
      if (!opened) throw StateError('Unable to open legal page');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not open this page. Please visit $address'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: brand.LumaColors.navyDeep,
        body: Stack(
          children: [
            const WelcomeBackground(heroHaloOpacity: 0),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/branding/luma_icon.png',
                                height: 44, excludeFromSemantics: true),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('Luma Anesthesia',
                                  style: brand.LumaText.wordmark()),
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
                        const SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(
                              MediaQuery.sizeOf(context).width < 440 ? 24 : 36),
                          decoration: BoxDecoration(
                            color: brand.LumaColors.cream,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: brand.LumaColors.goldSoft, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('LUMA PREMIUM',
                                  style: _body(size: 12).copyWith(
                                      color: _ink,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              Text(
                                  'A deeper understanding.\nA clearer perspective.',
                                  style: brand.LumaText.title(
                                      size: 32, color: _ink)),
                              const SizedBox(height: 12),
                              Text(
                                  'Unlock subscriber-only anesthesia reference content. '
                                  'Creating an account alone does not unlock paid sections.',
                                  style: _body(size: 16)),
                              const SizedBox(height: 24),
                              _benefit(
                                  Icons.menu_book_outlined,
                                  'Unlock Pathophysiology & Anesthesia Considerations',
                                  'Condition references and deep dives across '
                                      '240 conditions in 12 clinical categories.'),
                              _benefit(
                                  Icons.medication_outlined,
                                  'Explore Drug Library Deep Dives',
                                  'Extended medication reading is subscription-only. '
                                      'All other Drug Library content remains free.'),
                              _benefit(
                                  Icons.account_tree_outlined,
                                  'Connect physiology to perioperative care',
                                  'Explore the reasoning behind condition-specific '
                                      'anesthetic considerations.'),
                              _benefit(
                                  Icons.fact_check_outlined,
                                  'Keep the evidence in view',
                                  'Follow references and patient-specific cautions '
                                      'as you study and prepare.'),
                              const SizedBox(height: 8),
                              LayoutBuilder(builder: (context, constraints) {
                                final plans = [
                                  _plan(true, 'Annual', '\$69.99', '/ year',
                                      'Billed annually. Auto-renews.'),
                                  _plan(false, 'Monthly', '\$9.99', '/ month',
                                      'Billed monthly. Auto-renews.'),
                                ];
                                if (constraints.maxWidth < 350) {
                                  return Column(children: [
                                    plans[0],
                                    const SizedBox(height: 12),
                                    plans[1],
                                  ]);
                                }
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: plans[0]),
                                    const SizedBox(width: 12),
                                    Expanded(child: plans[1]),
                                  ],
                                );
                              }),
                              const SizedBox(height: 16),
                              Text(
                                  _annual
                                      ? 'Luma Premium Annual: a 1-year auto-renewable '
                                          'subscription at the preview price of \$69.99 per year.'
                                      : 'Luma Premium Monthly: a 1-month auto-renewable '
                                          'subscription at the preview price of \$9.99 per month.',
                                  style: _body(size: 12)),
                              const SizedBox(height: 8),
                              Text(
                                  'Subscriptions automatically renew unless canceled. '
                                  'Cancel before your next renewal to avoid another charge. '
                                  'Access continues through the paid subscription period.',
                                  style: _body(size: 12)),
                              const SizedBox(height: 8),
                              Text(
                                  subscriptionBillingNotice(
                                      Theme.of(context).platform,
                                      isWeb: kIsWeb),
                                  style: _body(size: 12)),
                              const SizedBox(height: 12),
                              const FilledButton(
                                onPressed: null,
                                child: Text('Purchases coming soon'),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                  'Plan preview only. Checkout and purchase restoration '
                                  'are not connected yet. No payment will be taken.',
                                  textAlign: TextAlign.center,
                                  style: _body(size: 12)),
                              const SizedBox(height: 16),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pushNamed(
                                        context, '/account'),
                                    child: const Text('Sign in / My account'),
                                  ),
                                  const TextButton(
                                    onPressed: null,
                                    child: Text('Restore purchases'),
                                  ),
                                ],
                              ),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                children: [
                                  TextButton(
                                    onPressed: () => _openLegal(
                                        'https://lumaeducationalapps.com/terms-of-use-eula'),
                                    child: const Text('Terms of Use / EULA'),
                                  ),
                                  TextButton(
                                    onPressed: () => _openLegal(
                                        'https://lumaeducationalapps.com/privacy-policy-1'),
                                    child: const Text('Privacy Policy'),
                                  ),
                                ],
                              ),
                              const Divider(height: 32),
                              const CeAccessMessage(),
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/ce-halo'),
                                child: const Text('Explore CE access'),
                              ),
                              const Divider(height: 32),
                              Text('Meet Luma, your AI learning companion',
                                  style: brand.LumaText.title(size: 24, color: _ink)),
                              const SizedBox(height: 8),
                              Text('Coming soon: an included AI-credit allowance '
                                  'with eligible plans and optional credit packs. '
                                  'Amounts and prices are not finalized. AI is not '
                                  'included in this preview.',
                                  style: _body()),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/luma-ai'),
                                child: const Text('Meet Luma'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                            'Clinical reference and education. Not a substitute '
                            'for clinical judgment or local protocols.',
                            textAlign: TextAlign.center,
                            style: brand.LumaText.body(
                                size: 12, color: brand.LumaColors.cream)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _benefit(IconData icon, String title, String description) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _ink, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: _body()
                          .copyWith(color: _ink, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(description, style: _body()),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _plan(
      bool annual, String name, String price, String period, String note) {
    final selected = annual == _annual;
    return Semantics(
      button: true,
      selected: selected,
      label: '$name plan, $price $period',
      child: Material(
        color: selected ? const Color(0xFFEDE4D2) : brand.LumaColors.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: selected ? _ink : const Color(0xFFC8C0B2),
              width: selected ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _annual = annual),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: _ink,
                      size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(name,
                        style: _body().copyWith(
                            color: _ink, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 12),
                Text(price, style: brand.LumaText.title(size: 28, color: _ink)),
                Text(period, style: _body()),
                const SizedBox(height: 8),
                Text(note, style: _body(size: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Web is a preview, not an Apple or Google checkout surface.
String subscriptionBillingNotice(TargetPlatform platform,
    {required bool isWeb}) {
  const apple =
      'Payment is charged to your Apple Account at purchase confirmation. '
      'Renewal is charged within 24 hours before the next subscription period. '
      'Manage or cancel in Settings > your name > Subscriptions.';
  const google = 'Payment is charged through your Google Play account. '
      'Manage or cancel in Google Play > Payments & subscriptions > Subscriptions.';
  if (isWeb) {
    return 'For iOS purchases: $apple\n\n'
        'For Android purchases: $google\n\n'
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
          Text('Your CE. Your choice.',
              style:
                  brand.LumaText.title(size: 24, color: brand.LumaColors.navy)),
          const SizedBox(height: 8),
          Text(
            'No app subscription is required to access AANA-approved CE content. '
            'Courses and bundles are purchased separately.',
            style: brand.LumaText.body(size: 14, color: brand.LumaColors.navy),
          ),
          const SizedBox(height: 16),
          _bonus('1 course purchase', '1 complimentary month, one time'),
          const SizedBox(height: 12),
          _bonus('Bundle purchase', '3 complimentary months, one time'),
          const SizedBox(height: 12),
          Text('Planned activation: access is added to your account after a '
              'verified course purchase. No code and no automatic subscription '
              'charge. Repeat purchases do not add more free months. '
              'Complimentary access includes the same Luma AI-credit allowance '
              'as a subscription once AI launches; credit amounts are being finalized. '
              'Course purchases and bonus activation are coming soon.',
              style: brand.LumaText.body(
                  size: 12, color: const Color(0xFF52606A))),
        ],
      );

  Widget _bonus(String title, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              color: brand.LumaColors.navy, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: '$title\n',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: value),
              ]),
              style:
                  brand.LumaText.body(size: 14, color: brand.LumaColors.navy),
            ),
          ),
        ],
      );
}

/// The CE entry point stays outside the app-subscription gate.
/// No courses, approval identifiers or checkout products are fabricated.
class CeAccessScreen extends StatelessWidget {
  const CeAccessScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('CE HALO'),
          actions: const [LumaHomeButton()],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: const CeAccessMessage(),
            ),
          ),
        ),
      );
}
