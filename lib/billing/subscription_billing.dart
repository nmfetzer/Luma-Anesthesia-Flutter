import 'package:flutter/foundation.dart';

import 'ce_billing.dart';

enum SubscriptionTerm { monthly, annual }

class BillingPlan {
  const BillingPlan(this.term, this.productId, this.price);
  final SubscriptionTerm term;
  final String productId;
  final String price;
}

class BillingFailure implements Exception {
  const BillingFailure(this.message);
  final String message;
}

abstract interface class BillingGateway {
  String? get userId;
  Future<void> identify(String? userId);
  Future<List<BillingPlan>> plans();
  Future<void> purchase(BillingPlan plan);
  Future<void> restore();

  /// Server validates RevenueCat independently; SDK data is never authority.
  Future<bool> verify(String userId);
}

/// Serializes store operations and discards results after an account change.
class SubscriptionBilling extends ChangeNotifier {
  SubscriptionBilling({
    this.gateway,
    this.unavailableMessage =
        'Subscriptions are being prepared. No payment will be taken.',
  });
  final BillingGateway? gateway;
  final String unavailableMessage;
  List<BillingPlan> plans = const [];
  bool busy = false;
  bool verified = false;
  bool serverReady = false;
  String? message;
  int _identityVersion = 0;
  bool _refreshPending = false;
  bool _disposed = false;
  bool _ceRefreshPending = false;
  List<CeStoreProduct> ceProducts = const [];
  CePurchaseStatus? ceStatus;
  bool ceReady = false;
  final Set<String> _awaitingCe = {};

  CeBillingGateway? get ceGateway =>
      gateway is CeBillingGateway && (gateway as CeBillingGateway).ceSupported
      ? gateway as CeBillingGateway
      : null;
  bool get ceAvailable => ceGateway != null;
  String get ceStoreDiagnostic => gateway is CeStoreDiagnosticSource
      ? (gateway as CeStoreDiagnosticSource).ceStoreDiagnostic
      : '';
  bool ceAwaitingVerification(String id) => _awaitingCe.contains(id);
  bool cePriceMissing(String id) =>
      ceReady &&
      ceStatus?.enabled.contains(id) == true &&
      ceStatus?.owned.contains(id) != true &&
      !ceProducts.any((product) => product.id == id);
  bool canPurchaseCe(String id) =>
      ceAvailable &&
      signedIn &&
      ceReady &&
      !busy &&
      ceStatus?.userId == gateway?.userId &&
      ceStatus!.enabled.contains(id) &&
      !ceStatus!.owned.contains(id) &&
      !_awaitingCe.contains(id) &&
      ceProducts.any((p) => p.id == id);

  /// Uses the SAME operation lock and SDK identity as subscription checkout.
  Future<void> refreshCe() async {
    if (!ceAvailable || _disposed) return;
    if (busy) {
      _ceRefreshPending = true;
      return;
    }
    await _run(() async {
      final user = gateway!.userId;
      final version = _identityVersion;
      await gateway!.identify(user);
      final products = await ceGateway!.ceProducts();
      if (!_sameUser(version, user)) return;
      ceProducts = products;
      if (user == null) {
        ceReady = false;
        message =
            'Sign in to link CE purchases and certificates to your account.';
        return;
      }
      await _readCeStatus(user, version);
    });
  }

  Future<void> _readCeStatus(String user, int version) async {
    final status = await ceGateway!.ceStatus(user);
    if (!_sameUser(version, user)) return;
    if (status.userId != user) throw StateError('CE account mismatch');
    ceStatus = status;
    ceReady = true;
    _awaitingCe.removeAll(status.owned);
  }

  Future<void> purchaseCe(String id) async {
    if (!canPurchaseCe(id)) return;
    final product = ceProducts.firstWhere((p) => p.id == id);
    await _run(() async {
      final user = gateway!.userId!;
      final version = _identityVersion;
      await _readCeStatus(user, version);
      if (!_sameUser(version, user) ||
          !ceStatus!.enabled.contains(id) ||
          ceStatus!.owned.contains(id)) {
        return;
      }
      await ceGateway!.purchaseCe(product);
      if (!_sameUser(version, user)) return;
      // A successful native sheet is NOT proof of server fulfillment.
      _awaitingCe.add(id);
      await _readCeStatus(user, version);
      if (!_sameUser(version, user)) return;
      message = ceStatus!.owned.contains(id)
          ? 'Your CE purchase is verified. Return to your course to continue.'
          : 'Apple completed checkout. Course verification is pending. '
                'Use Refresh CE access; do not purchase again.';
    });
  }

  Future<void> restoreCe() async {
    if (!ceAvailable || !signedIn || busy) return;
    await _run(() async {
      final user = gateway!.userId!;
      final version = _identityVersion;
      await gateway!.identify(user);
      await _readCeStatus(user, version);
      if (!_sameUser(version, user)) return;
      await gateway!.restore();
      if (!_sameUser(version, user)) return;
      await _readCeStatus(user, version);
      if (!_sameUser(version, user)) return;
      message = ceStatus!.owned.isNotEmpty
          ? 'Verified CE purchases restored. Return to your course to continue.'
          : 'No CE purchase has been verified for this account yet. '
                'If you purchased, refresh later or contact info@cehalo.com. Do not buy again.';
    });
  }

  bool get available => gateway != null;
  bool get signedIn => gateway?.userId != null;
  bool get canPurchase =>
      available && signedIn && serverReady && !busy && !verified;
  BillingPlan? plan(SubscriptionTerm term) {
    for (final item in plans) {
      if (item.term == term) return item;
    }
    return null;
  }

  void identityChanged() {
    _identityVersion++;
    verified = false;
    serverReady = false;
    ceStatus = null;
    ceReady = false;
    ceProducts = const [];
    _awaitingCe.clear();
    _ceRefreshPending = ceAvailable;
    message = null;
    _emit();
    if (busy) {
      _refreshPending = true;
    } else {
      refresh();
    }
  }

  Future<void> refresh() => _run(() async {
    final source = gateway!;
    final version = _identityVersion;
    final user = source.userId;
    await source.identify(user);
    final loaded = await source.plans();
    if (!_sameUser(version, user)) return;
    plans = loaded;
    if (user == null) {
      message =
          'Sign in to link a purchase to your Luma account. '
          'Creating an account does not start a subscription.';
      return;
    }
    final active = await source.verify(user);
    if (!_sameUser(version, user)) return;
    verified = active;
    serverReady = true;
    message = active ? 'Your premium access is verified.' : null;
  });

  Future<void> purchase(SubscriptionTerm term) async {
    final selected = plan(term);
    if (!canPurchase || selected == null) return;
    await _transaction(() => gateway!.purchase(selected), buying: true);
  }

  Future<void> restore() async {
    if (!available || !signedIn || busy || !serverReady) return;
    await _transaction(() => gateway!.restore());
  }

  Future<void> _transaction(
    Future<void> Function() action, {
    bool buying = false,
  }) => _run(() async {
    final user = gateway!.userId!;
    final version = _identityVersion;
    // Check server availability before opening native checkout.
    final alreadyActive = await gateway!.verify(user);
    if (!_sameUser(version, user)) return;
    if (alreadyActive && buying) {
      verified = true;
      message = 'Your premium access is already verified.';
      return;
    }
    await action();
    if (!_sameUser(version, user)) return;
    message = 'Checking your purchase securely…';
    _emit();
    final active = await gateway!.verify(user);
    if (!_sameUser(version, user)) return;
    verified = active;
    serverReady = true;
    message = active
        ? 'Your premium access is verified. You can return to your reference.'
        : 'No active subscription was verified yet. If the store confirmed your '
              'purchase, use Refresh access or Restore purchases. Do not buy again.';
  });

  Future<void> _run(Future<void> Function() action) async {
    if (gateway == null || busy || _disposed) return;
    busy = true;
    message = null;
    _emit();
    try {
      await action();
    } on BillingFailure catch (error) {
      message = error.message;
    } catch (_) {
      serverReady = false;
      ceReady = false;
      message =
          'Unable to verify billing right now. Check your connection and '
          'use Refresh access. If charged, do not purchase again.';
    } finally {
      busy = false;
      _emit();
      if (_refreshPending && !_disposed) {
        _refreshPending = false;
        await refresh();
      }
      if (_ceRefreshPending && !_disposed) {
        _ceRefreshPending = false;
        await refreshCe();
      }
    }
  }

  bool _sameUser(int version, String? user) =>
      version == _identityVersion && user == gateway?.userId && !_disposed;
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
