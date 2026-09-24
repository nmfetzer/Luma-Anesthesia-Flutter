import 'package:flutter/material.dart';
import '../welcome/luma_theme.dart' as brand;
import '../welcome/welcome_background.dart';

/// Presentation only until store products and verified billing are connected.
/// This screen never grants access or changes a subscription.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _annual = true;
  static const _ink = brand.LumaColors.navy;
  static const _muted = Color(0xFF52606A);

  TextStyle _body({double size = 14}) =>
      brand.LumaText.body(size: size, color: _muted);

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
                                  'Go beyond the essentials with extended '
                                  'anesthesia reference content.',
                                  style: _body(size: 16)),
                              const SizedBox(height: 24),
                              _benefit(
                                  Icons.menu_book_outlined,
                                  'Go deeper into Special Considerations',
                                  'Extended reading across 240 conditions in '
                                      '12 clinical categories.'),
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
                                      'One yearly payment'),
                                  _plan(false, 'Monthly', '\$9.99', '/ month',
                                      'One monthly payment'),
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
                              const Divider(height: 32),
                              const CeAccessMessage(),
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/ce-halo'),
                                child: const Text('Explore CE access'),
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
          _bonus('1 course purchase', '1 month of complimentary app access'),
          const SizedBox(height: 12),
          _bonus('Bundle purchase', '3 months of complimentary app access'),
          const SizedBox(height: 12),
          Text('Course purchases and bonus activation are coming soon.',
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
        appBar: AppBar(title: const Text('CE HALO')),
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
