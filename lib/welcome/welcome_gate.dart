import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'welcome_carousel.dart';

/// Per-install/browser onboarding. Signing out never clears this preference.
class WelcomeGate extends StatefulWidget {
  const WelcomeGate({super.key, required this.child});
  final Widget child;
  static const preferenceKey = 'luma_welcome_completed_v1';
  @override
  State<WelcomeGate> createState() => _WelcomeGateState();
}

class _WelcomeGateState extends State<WelcomeGate> {
  bool? _completed;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    bool completed = false;
    try {
      completed =
          (await SharedPreferences.getInstance()).getBool(
            WelcomeGate.preferenceKey,
          ) ??
          false;
    } catch (_) {
      /* Unavailable local storage must not block the app. */
    }
    if (mounted) setState(() => _completed = completed);
  }

  Future<void> _finish() async {
    if (_saving) return;
    _saving = true;
    try {
      await (await SharedPreferences.getInstance()).setBool(
        WelcomeGate.preferenceKey,
        true,
      );
    } catch (_) {
      /* This launch can continue even if storage is unavailable. */
    }
    if (mounted) setState(() => _completed = true);
  }

  @override
  Widget build(BuildContext context) => _completed == null
      ? const Scaffold(body: Center(child: CircularProgressIndicator()))
      : _completed!
      ? widget.child
      : WelcomeCarousel(onFinish: _finish);
}
