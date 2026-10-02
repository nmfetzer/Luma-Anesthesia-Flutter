import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/account_information.dart';

class LumaPolicy {
  const LumaPolicy(this.title, this.url, this.summary);
  final String title;
  final String url;
  final String summary;
}

const lumaPolicies = [
  LumaPolicy(
    'Privacy Policy',
    'https://cehalo.com/privacy-policy',
    'How CE HALO handles account information, purchases and CE records.',
  ),
  LumaPolicy(
    'Medical Disclaimer',
    'https://cehalo.com/medical-disclaimer',
    'Educational and professional reference only. Verify clinical information independently.',
  ),
  LumaPolicy(
    'Terms of Use & EULA',
    'https://cehalo.com/terms-of-use-eula',
    'The terms governing use of Luma and its content.',
  ),
  LumaPolicy(
    'Data Protection & HIPAA Statement',
    'https://cehalo.com/data-protection-hipaa',
    'Do not enter patient identifiers or protected health information into Luma.',
  ),
];

/// Acknowledgment of core policies only, not marketing, tracking or AI consent.
class PolicyAgreementScreen extends StatefulWidget {
  const PolicyAgreementScreen({
    super.key,
    required this.onAccept,
    this.openExternal,
  });
  final Future<void> Function() onAccept;
  final Future<bool> Function(Uri)? openExternal;
  @override
  State<PolicyAgreementScreen> createState() => _PolicyAgreementScreenState();
}

class _PolicyAgreementScreenState extends State<PolicyAgreementScreen> {
  final _accepted = List<bool>.filled(lumaPolicies.length, false);
  bool _busy = false;
  String? _error;
  bool get _all => _accepted.every((value) => value);

  Future<void> _open(LumaPolicy policy) async {
    try {
      final uri = Uri.parse(policy.url);
      if (await (widget.openExternal?.call(uri) ??
          launchUrl(uri, mode: LaunchMode.externalApplication)))
        return;
    } catch (_) {}
    if (!mounted) return;
    setState(
      () => _error =
          'The policy could not be opened. Connect to the internet and try again, '
          'or open ${policy.url} in your browser.',
    );
  }

  Future<void> _accept() async {
    if (!_all || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onAccept();
    } catch (_) {
      if (mounted)
        setState(
          () => _error = 'Your agreement could not be saved. Please try again.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Scaffold(
      backgroundColor: const Color(0xFF10283A),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/branding/luma_symbol_halo.png',
                    height: 56,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Before you begin',
                    style: TextStyle(
                      color: Color(0xFFE2C78D),
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please read and acknowledge all four policies before using Luma. '
                    'You can revisit them anytime in My Account.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: const Color(0xFFF7F1E5),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          CheckboxListTile(
                            key: const ValueKey('policy-agree-all'),
                            value: _all,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text(
                              'Agree to all',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: const Text(
                              'Acknowledge and accept all four policies below.',
                            ),
                            onChanged: _busy
                                ? null
                                : (value) => setState(() {
                                    for (var i = 0; i < _accepted.length; i++) {
                                      _accepted[i] = value ?? false;
                                    }
                                  }),
                          ),
                          const Divider(),
                          for (var i = 0; i < lumaPolicies.length; i++) ...[
                            CheckboxListTile(
                              key: ValueKey('policy-$i'),
                              value: _accepted[i],
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(lumaPolicies[i].title),
                              subtitle: Text(lumaPolicies[i].summary),
                              onChanged: _busy
                                  ? null
                                  : (value) => setState(
                                      () => _accepted[i] = value ?? false,
                                    ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () => _open(lumaPolicies[i]),
                                child: Text('Read ${lumaPolicies[i].title}'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AccountInformation.clinicalDisclaimer,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Luma is not a medical device and does not diagnose, treat, cure, '
                    'or prevent any medical condition. Consult an appropriate healthcare '
                    'professional for medical advice, diagnosis or treatment.\n\n'
                    'This acknowledgment does not authorize marketing, tracking or '
                    'sharing personal information with an AI provider.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: SelectableText(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  const SizedBox(height: 20),
                  FilledButton(
                    key: const ValueKey('policy-continue'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE2C78D),
                      foregroundColor: const Color(0xFF10283A),
                      disabledBackgroundColor: const Color(0xFF53616B),
                      disabledForegroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: _all && !_busy ? _accept : null,
                    child: Text(_busy ? 'Saving…' : 'Agree and continue'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'If you do not agree, close the app. No account or purchase is required '
                    'to acknowledge these policies.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
