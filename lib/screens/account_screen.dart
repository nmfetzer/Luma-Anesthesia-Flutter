import 'dart:async';

import 'package:flutter/material.dart';
import '../widgets/luma_home_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/account_access.dart';
import '../theme/luma_theme.dart';

export '../auth/account_access.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
    this.access,
    this.allowSocialSignIn = true,
  });
  final AccountAccess? access;

  /// Embedded previews have no persistent PKCE storage or valid callback origin.
  final bool allowSocialSignIn;

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
  StreamSubscription<void>? _authSubscription;
  Set<OAuthProvider> _providers = {};
  bool _checkingProviders = true;
  bool _providerCheckFailed = false;

  @override
  void initState() {
    super.initState();
    _access = widget.access ?? SupabaseAccountAccess(Supabase.instance.client);
    _authSubscription = _access.changes.listen((_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        if (_access.email != null) {
          _password.clear();
          _message = null;
        }
      });
    }, onError: (Object error, StackTrace stackTrace) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = 'Sign-in was not completed. Please try again, or use email.';
      });
    });
    unawaited(_loadProviders());
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _loadProviders() async {
    if (!widget.allowSocialSignIn) {
      setState(() => _checkingProviders = false);
      return;
    }
    setState(() {
      _checkingProviders = true;
      _providerCheckFailed = false;
    });
    try {
      final providers = await _access.enabledProviders();
      if (mounted) setState(() => _providers = providers);
    } catch (_) {
      if (mounted) {
        setState(() {
          _providers = {};
          _providerCheckFailed = true;
        });
      }
    } finally {
      if (mounted) setState(() => _checkingProviders = false);
    }
  }

  Future<void> _socialSignIn(OAuthProvider provider) async {
    if (_busy || !_providers.contains(provider) || !widget.allowSocialSignIn) {
      return;
    }
    final name = provider == OAuthProvider.apple ? 'Apple' : 'Google';
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final opened = await _access.signInWithProvider(provider);
      if (!mounted || _access.email != null) return;
      setState(() => _message = opened
          ? 'Continue with $name in your browser, then return to Luma. '
              'If you canceled, you can try again or use email.'
          : 'Could not open $name sign-in. Please try again.');
    } catch (_) {
      if (mounted) {
        setState(() => _message =
            '$name sign-in is unavailable right now. Please try again or use email.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _socialButton(OAuthProvider provider) {
    final apple = provider == OAuthProvider.apple;
    final enabled = widget.allowSocialSignIn &&
        !_busy &&
        !_checkingProviders &&
        _providers.contains(provider);
    return OutlinedButton.icon(
      onPressed: enabled ? () => _socialSignIn(provider) : null,
      style: OutlinedButton.styleFrom(
        backgroundColor: apple ? Colors.black : Colors.white,
        foregroundColor: apple ? Colors.white : const Color(0xFF1F1F1F),
        disabledBackgroundColor: apple ? const Color(0xFF303030) : Colors.white,
        disabledForegroundColor:
            apple ? Colors.white70 : const Color(0xFF747775),
        side: BorderSide(
          color: apple ? Colors.black : const Color(0xFF747775),
        ),
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      icon: apple
          ? const Icon(Icons.apple, size: 22)
          : Image.asset('assets/branding/google_g.png',
              width: 20, height: 20, excludeFromSemantics: true),
      label: Text(apple ? 'Continue with Apple' : 'Continue with Google'),
    );
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
        setState(() => _message = error.code == 'invalid_credentials' ||
                error.message
                    .toLowerCase()
                    .contains('invalid login credentials')
            ? 'We could not sign you in. Check your email and password. '
                'If this is your first time in the new Luma app, choose '
                'New account to register. Your previous app login may not '
                'be registered here yet.'
            : error.message);
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

  void _returnToApp() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('My Account'),
          leading: BackButton(onPressed: _returnToApp),
          actions: const [LumaHomeButton()],
        ),
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
                      Image.asset(
                        'assets/branding/luma_symbol_halo.png',
                        height: 72,
                        fit: BoxFit.contain,
                        semanticLabel: 'Luma symbol and halo',
                      ),
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
                        FilledButton(
                          onPressed: _returnToApp,
                          child: const Text('Continue to Luma'),
                        ),
                        const SizedBox(height: 16),
                        Text(
                            'Creating an account does not unlock paid content. '
                            'Pathophysiology & Anesthesia Considerations and deep dives require an active '
                            'subscription or authorized complimentary app access.',
                            style: lumaBody()),
                        const SizedBox(height: 12),
                        TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/subscribe'),
                            child: const Text('Preview Luma Premium')),
                        const SizedBox(height: 24),
                        OutlinedButton(
                            onPressed: _busy ? null : _signOut,
                            child: const Text('Sign out')),
                      ] else ...[
                        _socialButton(OAuthProvider.apple),
                        const SizedBox(height: 12),
                        _socialButton(OAuthProvider.google),
                        const SizedBox(height: 12),
                        Text(
                          'Sign in or create your free account. '
                          'These buttons do not purchase a subscription.',
                          style: lumaBody(size: 13),
                        ),
                        if (_checkingProviders)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('Checking sign-in availability…'),
                          )
                        else if (!widget.allowSocialSignIn)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                                'Social sign-in is unavailable inside this '
                                'embedded preview. Use the app or your local Chrome build.'),
                          )
                        else if (_providerCheckFailed ||
                            _providers.length < 2) ...[
                          const SizedBox(height: 8),
                          Text(_providerCheckFailed
                              ? 'Could not check social sign-in availability. '
                                  'Email sign-in is still available below.'
                              : 'Unavailable sign-in options are still being set up. '
                                  'You can use email below.'),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: _busy ? null : _loadProviders,
                              child: const Text('Check availability again'),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        const Row(children: [
                          Expanded(child: Divider()),
                          Flexible(
                            flex: 3,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('or use email',
                                  textAlign: TextAlign.center),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ]),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Existing account'),
                              selected: !_create,
                              onSelected: _busy
                                  ? null
                                  : (_) => setState(() {
                                        _create = false;
                                        _message = null;
                                        _password.clear();
                                      }),
                            ),
                            ChoiceChip(
                              label: const Text('New account'),
                              selected: _create,
                              onSelected: _busy
                                  ? null
                                  : (_) => setState(() {
                                        _create = true;
                                        _message = null;
                                        _password.clear();
                                      }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                            '${_create ? 'Create your free Luma account here. ' : 'Already registered in this new Luma app? Sign in below. '
                                'First visit? Choose New account above. '}'
                            'An account identifies you; it does not unlock paid content. '
                            'Pathophysiology & Anesthesia Considerations and Drug Library Deep Dives require '
                            'a subscription or authorized complimentary app access. '
                            'Other Drug Library content stays free.',
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
