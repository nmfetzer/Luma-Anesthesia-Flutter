import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'welcome_carousel.dart';
import '../policies/policy_agreement_screen.dart';

/// Per-install/browser onboarding. Signing out never clears this preference.
class WelcomeGate extends StatefulWidget {
  const WelcomeGate({super.key, required this.child});
  final Widget child;
  static const preferenceKey = 'luma_welcome_completed_v1';
  // Published CE HALO privacy policy, verified October 2, 2026.
  // Bump this whenever a revised policy requires fresh acknowledgment.
  static const policyVersion = '2026-10-02-v2';
  static const policyPreferenceKey = 'luma_policy_agreement';
  @override
  State<WelcomeGate> createState() => _WelcomeGateState();
}

class _WelcomeGateState extends State<WelcomeGate> {
  bool? _completed;
  bool _saving = false;
  bool _policiesAccepted = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    bool completed = false;
    try {
      final preferences = await SharedPreferences.getInstance();
      _policiesAccepted =
          preferences.getString(WelcomeGate.policyPreferenceKey) ==
          WelcomeGate.policyVersion;
      completed = preferences.getBool(WelcomeGate.preferenceKey) ?? false;
    } catch (_) {
      /* Unavailable local storage must not block the app. */
    }
    if (mounted) setState(() => _completed = completed);
  }

  Future<void> _acceptPolicies() async {
    final preferences = await SharedPreferences.getInstance();
    final timestampSaved = await preferences.setString(
      '${WelcomeGate.policyPreferenceKey}_accepted_at',
      DateTime.now().toUtc().toIso8601String(),
    );
    if (!timestampSaved) throw StateError('Unable to save acceptance time');
    final saved = await preferences.setString(
      WelcomeGate.policyPreferenceKey,
      WelcomeGate.policyVersion,
    );
    if (!saved) throw StateError('Unable to save policy version');
    if (mounted) setState(() => _policiesAccepted = true);
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
  // MaterialApp.builder places this gate above its Navigator. Supply an overlay
  // even before the Navigator is mounted: desktop tooltips and text-selection
  // controls require it. Keep the gate outside navigation to block deep links.
  Widget build(BuildContext context) => Overlay.wrap(
    child: _completed == null
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : _completed!
        ? _policiesAccepted
              ? widget.child
              : PolicyAgreementScreen(onAccept: _acceptPolicies)
        : WelcomeCarousel(onFinish: _finish),
  );
}
