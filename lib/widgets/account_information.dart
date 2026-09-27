import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/luma_theme.dart';

/// Public account information. Reading policies never requires signing in.
class AccountInformation extends StatelessWidget {
  const AccountInformation({super.key, this.openExternal});

  final Future<bool> Function(Uri)? openExternal;

  static const clinicalDisclaimer =
      'Luma Anesthesia is a reference tool intended to support — not replace — '
      "clinical judgment. Always verify dosing with your institution's protocols "
      'and consult appropriate resources before administering any medication.';

  Future<void> _open(BuildContext context, Uri uri) async {
    try {
      final opened =
          await (openExternal?.call(uri) ??
              launchUrl(uri, mode: LaunchMode.externalApplication));
      if (opened) return;
    } catch (_) {
      // A browser or email app may be unavailable. Keep the address accessible.
    }
    if (!context.mounted) return;
    final address = uri.scheme == 'mailto' ? uri.path : uri.toString();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          uri.scheme == 'mailto' ? 'Contact CE HALO LLC' : 'Open this policy',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              uri.scheme == 'mailto'
                  ? 'An email app could not be opened. You can email us at:'
                  : 'Your browser could not be opened. Copy this address into your browser:',
            ),
            const SizedBox(height: 12),
            SelectableText(address),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await Clipboard.setData(ClipboardData(text: address));
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Address copied')));
              } catch (_) {
                // The selectable address remains usable if clipboard is blocked.
              }
            },
            child: const Text('Copy address'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Uri _email(String subject) => Uri(
    scheme: 'mailto',
    path: 'info@cehalo.com',
    query: 'subject=${Uri.encodeComponent(subject)}',
  );

  Widget _card(String title, List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: LumaColors.creamElevated,
      borderRadius: BorderRadius.circular(LumaRadius.lg),
      border: Border.all(color: LumaColors.dividerStrong),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: lumaDisplay(size: 24)),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );

  Widget _link(BuildContext context, String label, Uri uri) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: TextButton(
      style: TextButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        foregroundColor: LumaColors.inkNavy,
      ),
      onPressed: () => _open(context, uri),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: lumaBody(weight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Icon(
            uri.scheme == 'mailto' ? Icons.mail_outline : Icons.open_in_new,
            size: 18,
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Divider(height: 48),
      Semantics(
        header: true,
        child: Text('Help, policies & about', style: lumaDisplay(size: 28)),
      ),
      const SizedBox(height: 20),
      _card('About CE HALO LLC', [
        Text(
          'At CE HALO LLC, we are committed to continually improving Luma '
          'Anesthesia and the experience it provides for anesthesia professionals '
          'and learners. Your feedback helps us make the app clearer, more '
          'useful, and more reliable.',
          style: lumaBody(),
        ),
        const SizedBox(height: 12),
        Text(
          'Questions or suggestions? Contact info@cehalo.com.',
          style: lumaBody(),
        ),
        _link(
          context,
          'Contact CE HALO LLC',
          _email('Luma Anesthesia question or suggestion'),
        ),
        _link(
          context,
          'Report a content concern',
          _email('Luma Anesthesia content concern'),
        ),
        Text(
          'For a content concern, include the section name and the wording '
          'you would like us to review. Do not include patient-identifiable '
          'information or protected health information (PHI), including in '
          'screenshots or support emails.',
          style: lumaBody(size: 14, color: LumaColors.inkSecondary),
        ),
      ]),
      _card('CE completion & reporting', [
        Text(
          'Completed CEs are sent to the AANA at the end of every month.',
          style: lumaBody(weight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          'Keep a copy of your completion certificate. For a question about '
          'your completion record or AANA reporting, contact info@cehalo.com.',
          style: lumaBody(),
        ),
        _link(
          context,
          'Ask about CE reporting',
          _email('CE completion and AANA reporting'),
        ),
      ]),
      _card('Clinical reference disclaimer', [
        Text(clinicalDisclaimer, style: lumaBody()),
      ]),
      _card('Policies & privacy', [
        _link(
          context,
          'Privacy Policy',
          Uri.parse('https://cehalo.com/privacy-policy'),
        ),
        const Divider(height: 1),
        _link(
          context,
          'Medical Disclaimer',
          Uri.parse('https://cehalo.com/medical-disclaimer'),
        ),
        const Divider(height: 1),
        _link(
          context,
          'Terms of Use & EULA',
          Uri.parse('https://cehalo.com/terms-of-use-eula'),
        ),
        const Divider(height: 1),
        _link(
          context,
          'Data Protection & HIPAA Statement',
          Uri.parse('https://cehalo.com/data-protection-hipaa'),
        ),
        const SizedBox(height: 12),
        Text(
          'For questions about your personal data, or to request access, '
          'correction, or deletion, contact info@cehalo.com with the subject '
          '"Privacy Request".',
          style: lumaBody(size: 14, color: LumaColors.inkSecondary),
        ),
        _link(context, 'Contact us about your data', _email('Privacy Request')),
      ]),
    ],
  );
}
