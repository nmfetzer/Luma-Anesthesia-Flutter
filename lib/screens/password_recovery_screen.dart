import 'package:flutter/material.dart';

import '../widgets/luma_home_button.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/account_access.dart';

/// The recovery token is exchanged by Supabase, never by this form.
class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key, this.access});
  final PasswordRecoveryAccess? access;
  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  bool _done = false;
  String? _error;
  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await (widget.access ?? SupabaseAccountAccess(Supabase.instance.client))
          .updatePassword(_password.text);
      _password.clear();
      _confirm.clear();
      if (mounted) setState(() => _done = true);
    } catch (_) {
      if (mounted)
        setState(
          () => _error = 'Unable to update your password. The link may have expired, or the password may not meet account requirements. Try again or request a new reset email from My Account.',
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Reset password'),
      actions: const [LumaHomeButton()],
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_done) ...[
                  const Text('Your password has been updated.'),
                  FilledButton(
                    onPressed: () =>
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/account', (_) => false),
                    child: const Text('Continue to My Account'),
                  ),
                ] else ...[
                  const Text('Choose a new password for your Luma account.'),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    enabled: !_busy,
                    autocorrect: false,
                    enableSuggestions: false,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: const InputDecoration(
                      labelText: 'New password',
                    ),
                    validator: (v) => (v ?? '').length < 8
                        ? 'Use at least 8 characters.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirm,
                    obscureText: true,
                    enabled: !_busy,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      labelText: 'Confirm new password',
                    ),
                    validator: (v) =>
                        v != _password.text ? 'Passwords must match.' : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _save,
                    child: Text(_busy ? 'Updating…' : 'Update password'),
                  ),
                  if (_error != null) Text(_error!),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/account', (_) => false),
                    child: const Text('Return to My Account'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
