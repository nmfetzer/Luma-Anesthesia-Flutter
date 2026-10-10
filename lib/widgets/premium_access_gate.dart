import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../billing/revenuecat_billing.dart';
import '../offline/offline_cache.dart';
import '../offline/offline_library.dart';
import '../screens/subscription_screen.dart';
import 'luma_home_button.dart';

/// A section boundary, not a replacement for server-side private-content RLS.
/// Public medication fields remain available in the free Drug Library.
class PremiumAccessGate extends StatefulWidget {
  const PremiumAccessGate({
    super.key,
    required this.builder,
    this.checkAccess,
    this.accessChanges,
  });

  final WidgetBuilder builder;
  final Future<bool> Function()? checkAccess;
  final Stream<void>? accessChanges;

  @override
  State<PremiumAccessGate> createState() => _PremiumAccessGateState();
}

class _PremiumAccessGateState extends State<PremiumAccessGate>
    with WidgetsBindingObserver {
  StreamSubscription<void>? _changes;
  Timer? _timer;
  bool? _allowed;
  bool _failed = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _changes =
        (widget.accessChanges ??
                OfflineLibrary.authChanges(Supabase.instance.client))
            .listen((_) => _check());
    LumaBilling.instance.controller.addListener(_billingChanged);
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _check(invalidate: false),
    );
    _check();
  }

  void _billingChanged() {
    if (LumaBilling.instance.controller.verified) _check(invalidate: false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<bool> _serverAccess() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    // Guest subscribers qualify; has_clinical_premium_access decides.
    if (user == null) return false;
    final owner = user.id;
    final cache = OfflineCache.instance;
    await cache.setOwner(owner);
    try {
      final allowed = await client
          .rpc('has_clinical_premium_access')
          .timeout(const Duration(seconds: 8));
      if (client.auth.currentUser?.id != owner) return false;
      // A definitive server denial always wins over an older offline lease.
      if (allowed != true) await cache.revoke();
      return allowed == true;
    } catch (error) {
      if (!OfflineCache.isConnectionError(error)) rethrow;
      if (client.auth.currentUser?.id != owner || cache.owner != owner) {
        return false;
      }
      return cache.restoreLease();
    }
  }

  Future<void> _check({bool invalidate = true}) async {
    final generation = ++_generation;
    // Remove the protected subtree immediately on identity/access changes.
    setState(() {
      if (invalidate) _allowed = null;
      _failed = false;
    });
    try {
      final allowed = await (widget.checkAccess ?? _serverAccess)();
      if (!mounted || generation != _generation) return;
      setState(() => _allowed = allowed);
    } catch (_) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _allowed = false;
        _failed = true;
      });
    }
  }

  @override
  void dispose() {
    ++_generation;
    _timer?.cancel();
    _changes?.cancel();
    LumaBilling.instance.controller.removeListener(_billingChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_allowed == true) return widget.builder(context);
    if (_allowed == false && !_failed) return const SubscriptionScreen();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium references'),
        actions: const [LumaHomeButton()],
      ),
      body: Center(
        child: _failed
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unable to verify access. Please try again.'),
                  TextButton(onPressed: _check, child: const Text('Retry')),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
