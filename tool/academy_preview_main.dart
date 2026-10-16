// Private embedded preview only. Production uses lib/ce_portal_main.dart.
// Authentication is memory-only; learning progress remains in Supabase.
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:luma_anesthesia/academy/academy_screen.dart';
import 'package:luma_anesthesia/config.dart';
import 'package:luma_anesthesia/theme/luma_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: LumaConfig.supabaseUrl,
    publishableKey: LumaConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      persistSession: false,
      detectSessionInUri: false,
      authFlowType: AuthFlowType.implicit,
    ),
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildLumaTheme(),
      home: const AcademyScreen(),
      routes: {'/account': (_) => const _PreviewLogin()},
      builder: (context, child) => Column(
        children: [
          Material(
            color: const Color(0xFF081428),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Private Academy preview · account progress is saved; sign-in lasts only for this preview session.',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Supabase.instance.client.auth.signOut(
                        scope: SignOutScope.local,
                      ),
                      child: const Text(
                        'Sign out',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: child ?? const SizedBox.shrink()),
        ],
      ),
    ),
  );
}

class _PreviewLogin extends StatefulWidget {
  const _PreviewLogin();
  @override
  State<_PreviewLogin> createState() => _PreviewLoginState();
}

class _PreviewLoginState extends State<_PreviewLogin> {
  final email = TextEditingController(), password = TextEditingController();
  bool busy = false;
  String? error;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email.text.trim(),
        password: password.text,
      );
      password.clear();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted)
        setState(
          () => error = 'Sign-in was not completed. Check your Luma email and password, then retry.',
        );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign in to Luma')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Use your existing Luma account. This private preview does not create accounts, sell courses, or retain your password.',
            ),
            const SizedBox(height: 24),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Luma account email',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Password'),
              onSubmitted: busy ? null : (_) => submit(),
            ),
            const SizedBox(height: 24),
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            FilledButton(
              onPressed: busy ? null : submit,
              child: Text(busy ? 'Signing in…' : 'Sign in'),
            ),
          ],
        ),
      ),
    ),
  );
}
