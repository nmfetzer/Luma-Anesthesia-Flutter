// Temporary destination after the welcome carousel completes.
// Replace with your real sign-in screen (Apple / Google / Email / Guest).

import 'package:flutter/material.dart';
import '../welcome/luma_theme.dart';

class SignInPlaceholder extends StatelessWidget {
  const SignInPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LumaColors.navyDeep,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sign-in placeholder', textAlign: TextAlign.center, style: LumaText.title(size: 26)),
                const SizedBox(height: 12),
                Text(
                  'This is where Sign in with Apple, Google, Email, and Continue as guest will live.',
                  textAlign: TextAlign.center,
                  style: LumaText.body(),
                ),
                const SizedBox(height: 32),
                Material(
                  color: LumaColors.cream,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    customBorder: const StadiumBorder(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      child: Text('Back to welcome', style: LumaText.cta()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
