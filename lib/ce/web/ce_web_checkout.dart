import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../billing/ce_billing.dart';
import '../../config.dart';
import '../ce_paywall_copy.dart';
import '../ce_repository.dart';
import '../ce_screen.dart';

/// Only ce_portal_main wraps the app in this scope. Mobile entry is unchanged.
class CeWebCheckoutScope extends InheritedWidget {
  const CeWebCheckoutScope({super.key, required super.child, this.service});
  final CeWebService? service;
  static CeWebCheckoutScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CeWebCheckoutScope>();
  @override
  bool updateShouldNotify(CeWebCheckoutScope oldWidget) =>
      service != oldWidget.service;
}

const webProductCodes = {
  CeProduct.medication: 'medication',
  CeProduct.uncommon: 'uncommon',
  CeProduct.legal: 'legal',
  CeProduct.bundle: 'bundle',
};
const webCourseNumbers = {'medication': 1, 'uncommon': 2, 'legal': 3};

class CeWebState {
  const CeWebState({
    required this.userId,
    this.existingCourses = const {},
    this.testCourses = const {},
    this.testOrders = const [],
  });
  final String userId;
  final Set<int> existingCourses;
  final Set<int> testCourses;
  final List<Map<String, dynamic>> testOrders;

  bool owns(String code, {bool test = false}) {
    final owned = test ? testCourses : existingCourses;
    return code == 'bundle'
        ? owned.containsAll([1, 2, 3])
        : owned.contains(webCourseNumbers[code]);
  }

  bool bundleOverlaps() => existingCourses.isNotEmpty || testCourses.isNotEmpty;
}

abstract class CeWebService {
  String? get userId;
  Stream<String?> get accounts;
  bool get configured;
  Future<CeWebState> load();
  Future<Uri> checkout(String code);
}

class SupabaseCeWebService implements CeWebService {
  static const enabled = bool.fromEnvironment('LUMA_CE_STRIPE_TEST_ENABLED');
  static const endpoint = String.fromEnvironment('LUMA_CE_STRIPE_TEST_ENDPOINT');
  SupabaseClient get client => Supabase.instance.client;
  @override
  String? get userId => client.auth.currentUser?.isAnonymous == false
      ? client.auth.currentUser?.id
      : null;
  @override
  Stream<String?> get accounts =>
      client.auth.onAuthStateChange.map((_) => userId).distinct();
  @override
  bool get configured {
    final uri = Uri.tryParse(endpoint);
    return enabled &&
        uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.host != Uri.parse(LumaConfig.supabaseUrl).host &&
        uri.userInfo.isEmpty &&
        !uri.hasQuery &&
        !uri.hasFragment;
  }

  Future<Map<String, dynamic>> request(
    String action,
    Map<String, dynamic> body,
    String expected,
  ) async {
    if (!configured || userId != expected) {
      throw Exception('Stripe testing is not configured for this session.');
    }
    final token = client.auth.currentSession?.accessToken;
    if (token == null) throw Exception('Sign in with your Luma account.');
    final response = await http
        .post(
          Uri.parse('${endpoint.replaceAll(RegExp(r'/+$'), '')}/$action'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));
    if (userId != expected) throw Exception('Your account changed. Please retry.');
    final data = jsonDecode(response.body);
    if (data is! Map) throw Exception('Unable to verify test checkout.');
    if (response.statusCode != 200) {
      throw Exception(data['error'] is String
          ? data['error']
          : 'Test checkout is unavailable.');
    }
    if (data['test_only'] != true || data['user_id'] != expected) {
      throw Exception('Test checkout identity could not be verified.');
    }
    return Map<String, dynamic>.from(data);
  }

  static Set<int> courses(dynamic raw) {
    if (raw is! List || raw.any((n) => n is! int || n < 1 || n > 3)) {
      throw Exception('Course access could not be verified.');
    }
    return raw.cast<int>().toSet();
  }

  @override
  Future<CeWebState> load() async {
    final expected = userId;
    if (expected == null) throw Exception('Sign in with your Luma account.');
    if (configured) {
      final data = await request('status', {}, expected);
      final rawOrders = data['orders'];
      if (rawOrders is! List || rawOrders.any((o) => o is! Map)) {
        throw Exception('Test payment status could not be verified.');
      }
      return CeWebState(
        userId: expected,
        existingCourses: courses(data['existing_courses']),
        testCourses: courses(data['test_courses']),
        testOrders: rawOrders
            .map((o) => Map<String, dynamic>.from(o as Map))
            .toList(),
      );
    }
    // Reads existing RLS-protected ownership even while checkout is disabled.
    // No course state/preview grants are created by this query.
    final rows = await client
        .from('luma_ce_bonus_purchases')
        .select('store,product_id,revoked_at')
        .eq('user_id', expected);
    final owned = <int>{};
    for (final row in rows) {
      if (row['revoked_at'] != null) continue;
      final code = row['store'] == 'APP_STORE'
          ? webProductCodes[row['product_id']]
          : null;
      if (code == null) {
        throw Exception(
          'An existing store purchase needs mapping review. '
          'Do not buy again; use the course library or contact support.',
        );
      }
      if (code == 'bundle') {
        owned.addAll([1, 2, 3]);
      } else {
        owned.add(webCourseNumbers[code]!);
      }
    }
    if (userId != expected) throw Exception('Your account changed. Please retry.');
    return CeWebState(userId: expected, existingCourses: owned);
  }

  @override
  Future<Uri> checkout(String code) async {
    final expected = userId;
    if (expected == null) throw Exception('Sign in with your Luma account.');
    final data = await request('checkout', {'product_code': code}, expected);
    final uri = Uri.tryParse(data['url'] is String ? data['url'] as String : '');
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'checkout.stripe.com' ||
        uri.userInfo.isNotEmpty) {
      throw Exception('Unexpected checkout destination.');
    }
    return uri;
  }
}

class CeWebPurchaseScreen extends StatefulWidget {
  const CeWebPurchaseScreen({super.key, this.productId, this.service, this.open});
  final String? productId;
  final CeWebService? service;
  final Future<bool> Function(Uri)? open;
  @override
  State<CeWebPurchaseScreen> createState() => _CeWebPurchaseScreenState();
}

class _CeWebPurchaseScreenState extends State<CeWebPurchaseScreen>
    with WidgetsBindingObserver {
  late CeWebService service;
  StreamSubscription<String?>? subscription;
  CeWebState? state;
  String? error;
  bool busy = false;
  bool initialized = false;
  int generation = 0;
  static const navy = Color(0xFF152C3B);
  static const cream = Color(0xFFFAF7EF);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    initialized = true;
    service = widget.service ??
        CeWebCheckoutScope.maybeOf(context)?.service ??
        SupabaseCeWebService();
    WidgetsBinding.instance.addObserver(this);
    subscription = service.accounts.listen((_) => refresh());
    refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState value) {
    if (value == AppLifecycleState.resumed) refresh();
  }

  @override
  void dispose() {
    generation++;
    subscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> refresh() async {
    final request = ++generation;
    final expected = service.userId;
    setState(() { busy = true; error = null; state = null; });
    try {
      final result = expected == null ? null : await service.load();
      if (!mounted || request != generation || service.userId != expected) return;
      if (result != null && result.userId != expected) {
        throw Exception('Course access identity could not be verified.');
      }
      setState(() => state = result);
    } catch (e) {
      if (mounted && request == generation) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted && request == generation) setState(() => busy = false);
    }
  }

  Future<void> signIn() async {
    await Navigator.of(context).pushNamed('/account');
    if (mounted) await refresh();
  }

  Future<void> buy(String code) async {
    final expected = service.userId;
    final request = ++generation;
    setState(() { busy = true; error = null; });
    try {
      final uri = await service.checkout(code);
      if (!mounted || request != generation || service.userId != expected) return;
      final opened = await (widget.open?.call(uri) ??
          launchUrl(uri, webOnlyWindowName: '_self'));
      if (!opened) throw Exception('Unable to open Stripe test checkout.');
    } catch (e) {
      if (mounted && request == generation) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted && request == generation) setState(() => busy = false);
    }
  }

  void openOwned(String code) {
    if (code == 'bundle') {
      Navigator.of(context).pushNamed('/ce-halo');
    } else {
      Navigator.of(context).push<void>(MaterialPageRoute(
        builder: (_) => CeCourseScreen(
          repository: SupabaseCeRepository(courseNumber: webCourseNumbers[code]!),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = CeProduct.all.where((p) => p.id == widget.productId).firstOrNull;
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: const Text('CE HALO · Website'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pushNamed('/ce-halo'),
            child: const Text('Course library')),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text('Website checkout preparation',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.w600, color: navy)),
              const SizedBox(height: 12),
              Text(service.configured
                  ? 'STRIPE TEST MODE · No real payment, CE credit, certificate, '
                    'course unlock, or complimentary access is awarded by this test.'
                  : 'Website purchases are being prepared. No payment is taken here. '
                    'Sign in with your existing Luma account to check courses you already own.'),
              const SizedBox(height: 12),
              const Text('Your existing course ownership and saved progress remain '
                'with your Luma account. You do not need to buy an owned course again.'),
              const SizedBox(height: 20),
              if (busy) const LinearProgressIndicator(),
              if (service.userId == null)
                FilledButton(onPressed: busy ? null : signIn,
                  child: const Text('Sign in with your Luma account')),
              if (error != null) ...[
                Text(error!, style: const TextStyle(color: Color(0xFF9A3030))),
                TextButton(onPressed: busy ? null : refresh, child: const Text('Retry access check')),
              ],
              for (final product in selected == null ? CeProduct.all : [selected])
                productCard(product, selected == null),
              if (service.userId != null)
                OutlinedButton(onPressed: busy ? null : refresh,
                  child: const Text('Refresh account and test status')),
              const SizedBox(height: 16),
              const Text('Test purchases are recorded separately and do not change '
                'Apple/Google purchases or your real complimentary-access balance. '
                'Existing course access remains subject to the course requirements.'),
              const SizedBox(height: 12),
              Wrap(spacing: 16, children: [
                TextButton(onPressed: () => launchUrl(Uri.parse('https://cehalo.com/terms-of-use-eula')),
                  child: const Text('Terms of Use')),
                TextButton(onPressed: () => launchUrl(Uri.parse('https://cehalo.com/privacy-policy')),
                  child: const Text('Privacy Policy')),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget productCard(CeProduct product, bool index) {
    final code = webProductCodes[product.id]!;
    final owned = state?.owns(code) == true;
    final tested = state?.owns(code, test: true) == true;
    final overlap = code == 'bundle' && state?.bundleOverlaps() == true && !owned && !tested;
    final pending = state?.testOrders.any((o) =>
        o['product_code'] == code && o['state'] == 'pending') == true;
    final copy = CePaywallCopy.byProduct[product.id]!;
    final enabled = !busy && state != null && error == null && service.configured;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 14),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(product.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text(copy.description),
          const SizedBox(height: 12),
          if (!index) ...[
            for (final highlight in copy.highlights)
              Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('• $highlight')),
            const SizedBox(height: 8),
          ],
          Text(code == 'bundle' ? 'Planned website price: \$699.99 USD · one-time'
              : 'Planned website price: \$249.99 USD · one-time'),
          const SizedBox(height: 8),
          Text(code == 'bundle'
              ? 'Complimentary-access rule: three months total per account, '
                'or two additional months after a prior one-month course bonus.'
              : 'Complimentary-access rule: one month with the first individual course, once per account.'),
          const Text('Three-month lifetime maximum across purchase channels. '
            'Refunds do not reset eligibility. No automatic subscription enrollment.'),
          const SizedBox(height: 16),
          if (overlap)
            const Text('You already own part of this bundle. Choose an unowned '
              'individual course; bundle upgrades are not enabled on this test website.'),
          if (owned)
            FilledButton(onPressed: busy ? null : () => openOwned(code),
              child: const Text('Open course'))
          else if (tested)
            const Text('Test purchase verified · Production course access is unchanged.')
          else if (service.userId == null)
            OutlinedButton(onPressed: busy ? null : signIn, child: const Text('Sign in to check access'))
          else
            FilledButton(
              onPressed: enabled && !overlap ? () => buy(code) : null,
              child: Text(!service.configured ? 'Website checkout not enabled'
                  : pending ? 'Resume or check test checkout' : 'Continue to Stripe test checkout'),
            ),
          if (service.configured && !owned && !tested)
            const Padding(padding: EdgeInsets.only(top: 8),
              child: Text('Use test payment details only. A return from Stripe is '
                'not proof of payment; the server must verify it.')),
        ]),
      ),
    );
  }
}
