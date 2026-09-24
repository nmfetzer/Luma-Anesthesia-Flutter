import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/luma_theme.dart';

abstract class AccountAccess {
  String? get email;
  Future<bool> submit(String email, String password, {required bool create});
  Future<void> signOut();
}

class SupabaseAccountAccess implements AccountAccess {
  SupabaseAccountAccess(this.client);
  final SupabaseClient client;

  @override
  String? get email => client.auth.currentUser?.isAnonymous == false
      ? client.auth.currentUser?.email
      : null;

  @override
  Future<bool> submit(String email, String password,
      {required bool create}) async {
    final result = create
        ? await client.auth.signUp(email: email, password: password)
        : await client.auth
            .signInWithPassword(email: email, password: password);
    return result.session != null;
  }

  @override
  Future<void> signOut() => client.auth.signOut();
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, this.access});
  final AccountAccess? access;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final AccountAccess _access;
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _create = false;
  bool _busy = false;
  bool _hidePassword = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _access = widget.access ?? SupabaseAccountAccess(Supabase.instance.client);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final signedIn = await _access.submit(_email.text.trim(), _password.text,
          create: _create);
      if (!mounted) return;
      _password.clear();
      if (signedIn) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _create = false;
          _message = 'Check your email to confirm your account, then return '
              'to this app and sign in. If you already have an account, sign in instead.';
        });
      }
    } on AuthException catch (error) {
      if (mounted) {
        setState(() => _message = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message =
            'Unable to connect. Check your connection and try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _busy = true);
    try {
      await _access.signOut();
      if (mounted) setState(() => _message = 'You are signed out.');
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Unable to sign out. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('My Account')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset('assets/branding/luma_icon.png', height: 72),
                      const SizedBox(height: 24),
                      Text(
                          _access.email != null
                              ? 'Your account'
                              : _create
                                  ? 'Create an account'
                                  : 'Welcome back',
                          style: lumaDisplay(size: 30)),
                      const SizedBox(height: 12),
                      if (_access.email != null) ...[
                        Text(_access.email!, style: lumaBody()),
                        const SizedBox(height: 16),
                        Text(
                            'Your account can read published Special Considerations. '
                            'Deep dives require an active clinical subscription.',
                            style: lumaBody()),
                        const SizedBox(height: 24),
                        OutlinedButton(
                            onPressed: _busy ? null : _signOut,
                            child: const Text('Sign out')),
                      ] else ...[
                        Text(
                            'A free account unlocks published Special Considerations. '
                            'Deep dives remain subscription-protected.',
                            style: lumaBody()),
                        const SizedBox(height: 24),
                        Form(
                          key: _form,
                          child: Column(children: [
                            TextFormField(
                              controller: _email,
                              enabled: !_busy,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              textInputAction: TextInputAction.next,
                              decoration:
                                  const InputDecoration(labelText: 'Email'),
                              validator: (value) =>
                                  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                          .hasMatch((value ?? '').trim())
                                      ? null
                                      : 'Enter a valid email address.',
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _password,
                              enabled: !_busy,
                              obscureText: _hidePassword,
                              autocorrect: false,
                              enableSuggestions: false,
                              autofillHints: [
                                _create
                                    ? AutofillHints.newPassword
                                    : AutofillHints.password
                              ],
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) {
                                if (!_busy) _submit();
                              },
                              decoration: InputDecoration(
                                  labelText: 'Password',
                                  suffixIcon: IconButton(
                                      tooltip: _hidePassword
                                          ? 'Show password'
                                          : 'Hide password',
                                      onPressed: () => setState(
                                          () => _hidePassword = !_hidePassword),
                                      icon: Icon(_hidePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off))),
                              validator: (value) {
                                if ((value ?? '').isEmpty)
                                  return 'Enter your password.';
                                if (_create && value!.length < 8) {
                                  return 'Use at least 8 characters.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                    onPressed: _busy ? null : _submit,
                                    child: Text(_busy
                                        ? 'Please wait…'
                                        : _create
                                            ? 'Create account'
                                            : 'Sign in'))),
                            TextButton(
                                onPressed: _busy
                                    ? null
                                    : () => setState(() {
                                          _create = !_create;
                                          _message = null;
                                          _password.clear();
                                        }),
                                child: Text(_create
                                    ? 'Already registered? Sign in'
                                    : 'New to Luma? Create an account')),
                          ]),
                        ),
                      ],
                      if (_message != null) ...[
                        const SizedBox(height: 20),
                        Semantics(
                            liveRegion: true,
                            child: Text(_message!, style: lumaBody())),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
