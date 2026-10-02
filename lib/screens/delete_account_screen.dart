import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/account_deletion.dart';
import '../widgets/luma_home_button.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key, this.access, this.openExternal});
  final AccountDeletionAccess? access;
  final Future<bool> Function(Uri)? openExternal;
  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _confirmed = false;
  bool _busy = false;
  String? _error;
  DeletionReceipt? _receipt;
  AccountDeletionAccess? _access;
  bool? _available;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    try {
      _access =
          widget.access ?? SupabaseAccountDeletion(Supabase.instance.client);
      final available = await _access!.isAvailable();
      if (mounted) setState(() => _available = available);
    } catch (_) {
      if (mounted) setState(() => _available = false);
    }
  }

  Future<void> _open(String address) async {
    try {
      final uri = Uri.parse(address);
      if (await (widget.openExternal?.call(uri) ??
          launchUrl(uri, mode: LaunchMode.externalApplication)))
        return;
    } catch (_) {}
    if (mounted)
      setState(() => _error = 'Could not open this page. Visit $address');
  }

  Future<void> _submit() async {
    if (!_confirmed || _busy || _available != true) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Request permanent account deletion?'),
        content: const Text(
          'This submits a request to delete your Luma account and associated data, '
          'except records that must be retained as described in the Privacy Policy. '
          'It does not cancel Apple or Google subscriptions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep my account'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit deletion request'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final receipt = await _access!.requestDeletion();
      if (mounted) setState(() => _receipt = receipt);
    } catch (_) {
      if (mounted)
        setState(
          () => _error =
              'Your deletion request could not be confirmed. Your account has not '
              'been deleted. Check your connection and try again. If the problem '
              'continues, contact info@cehalo.com.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Delete account'),
      actions: const [LumaHomeButton()],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_receipt != null) ...[
                  const Text(
                    'Deletion request received',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your account has not been deleted yet. CE HALO will process '
                    'your request by ${_receipt!.dueAt.toLocal().toString().substring(0, 10)} '
                    'and confirm completion by email.',
                  ),
                  const SizedBox(height: 16),
                  SelectableText('Request reference: ${_receipt!.id}'),
                ] else ...[
                  const Text(
                    'Permanently delete your Luma account',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _available == true
                        ? 'Submit your request here without calling or emailing support. '
                              'CE HALO processes deletion requests within 7 days and confirms '
                              'completion by email. Your account remains active while the request is pending.'
                        : _available == null
                        ? 'Checking account deletion availability…'
                        : 'In-app deletion requests are not available right now. No request '
                              'has been submitted. Retry while connected or contact info@cehalo.com.',
                  ),
                  if (_available == false)
                    TextButton(
                      onPressed: _checkAvailability,
                      child: const Text('Check availability again'),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Deletion removes your account and associated personal data that '
                    'CE HALO is not required to retain. You will lose access to saved '
                    'course progress and account-linked content. Save your certificates first.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Minimum CE credit records may be retained for accreditor or legal '
                    'requirements. Limited billing, fraud-prevention or dispute records '
                    'may also need to be retained, as explained in the Privacy Policy.',
                  ),
                ],
                const SizedBox(height: 20),
                const Text(
                  'Subscriptions are separate',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Deleting your account does not cancel an Apple or Google subscription '
                  'or automatically issue a refund. Cancel any active subscription in '
                  'the store to avoid further charges. You can request deletion now '
                  'without waiting for the subscription to expire.',
                ),
                TextButton(
                  onPressed: () =>
                      _open('https://apps.apple.com/account/subscriptions'),
                  child: const Text('Manage Apple subscriptions'),
                ),
                TextButton(
                  onPressed: () => _open(
                    'https://play.google.com/store/account/subscriptions',
                  ),
                  child: const Text('Manage Google Play subscriptions'),
                ),
                TextButton(
                  onPressed: () => _open('https://cehalo.com/privacy-policy'),
                  child: const Text('Privacy Policy and retention'),
                ),
                if (_receipt == null) ...[
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _confirmed,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text(
                      'I understand and want to request permanent account deletion.',
                    ),
                    onChanged: _busy || _available != true
                        ? null
                        : (value) =>
                              setState(() => _confirmed = value ?? false),
                  ),
                  FilledButton(
                    onPressed: _confirmed && !_busy && _available == true
                        ? _submit
                        : null,
                    child: Text(
                      _busy ? 'Submitting…' : 'Request account deletion',
                    ),
                  ),
                ],
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SelectableText(_error!),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
