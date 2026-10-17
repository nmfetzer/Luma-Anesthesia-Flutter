import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ce_library_screen.dart';
import 'ce_web_checkout.dart';

/// Web entry only, behind an explicit release flag. Native billing is unchanged.
class CeGuestCheckout extends StatefulWidget {
  const CeGuestCheckout({super.key, this.productId, this.activate = false});
  static const enabled = bool.fromEnvironment('LUMA_CE_PURCHASE_FIRST');
  final String? productId;
  final bool activate;
  static bool freshEmailSession(Session? session) {
    try {
      final claims = jsonDecode(
        utf8.decode(
          base64Url.decode(
            base64Url.normalize(session!.accessToken.split('.')[1]),
          ),
        ),
      ) as Map;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return (claims['amr'] as List? ?? []).any(
        (x) =>
            ['otp', 'magiclink'].contains(x['method']) &&
            x['timestamp'] is num &&
            x['timestamp'] >= now - 1800,
      );
    } catch (_) {
      return false;
    }
  }

  @override
  State<CeGuestCheckout> createState() => _CeGuestCheckoutState();
}

class _CeGuestCheckoutState extends State<CeGuestCheckout> {
  static const navy = Color(0xFF142B40);
  static const cream = Color(0xFFFAF7F0);
  final email = TextEditingController();
  final name = TextEditingController();
  final password = TextEditingController();
  final form = GlobalKey<FormState>();
  StreamSubscription<AuthState>? listener;
  Map<String, dynamic>? catalog, purchases;
  String? selected, error, notice, role;
  bool busy = false, activation = false, accept = false;
  SupabaseClient get client => Supabase.instance.client;
  bool get verified =>
      CeGuestCheckout.freshEmailSession(client.auth.currentSession);

  @override
  void initState() {
    super.initState();
    selected = webProductCodes[widget.productId];
    activation =
        widget.activate ||
        Uri.base.queryParameters['ce_guest'] == 'return' ||
        verified;
    email.text = client.auth.currentUser?.email ?? '';
    listener = client.auth.onAuthStateChange.listen((_) {
      if (verified && mounted) {
        setState(() => activation = true);
        run(loadPurchases);
      }
    });
    run(() async {
      catalog = await request('guest-catalog', {});
      if (verified) await loadPurchases();
    });
  }

  @override
  void dispose() {
    listener?.cancel();
    email.dispose();
    name.dispose();
    password.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> request(
    String action,
    Map<String, dynamic> body, {
    bool signed = false,
  }) async {
    final token = client.auth.currentSession?.accessToken;
    if (signed && token == null) throw Exception('Verify your purchase email.');
    final r = await http
        .post(
          Uri.parse('${SupabaseCeLiveService.liveEndpoint}/$action'),
          headers: {
            'Content-Type': 'application/json',
            if (signed) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 40));
    final data = jsonDecode(r.body);
    if (r.statusCode != 200 || data is! Map || data['live'] != true) {
      throw Exception(
        data is Map && data['error'] is String
            ? data['error']
            : 'The service is unavailable. If you paid, do not pay again.',
      );
    }
    return Map<String, dynamic>.from(data);
  }

  Future<void> run(Future<void> Function() task) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await task();
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> loadPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    purchases = await request('guest-list', {
      if (prefs.getString('ce_guest_last') != null)
        'request_id': prefs.getString('ce_guest_last'),
    }, signed: true);
  }

  String uuid() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final h = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  Future<void> pay() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'ce_guest_request_$selected';
    final id = prefs.getString(key) ?? uuid();
    await prefs.setString(key, id);
    await prefs.setString('ce_guest_last', id);
    final result = await request('guest-checkout', {
      'product_code': selected,
      'request_id': id,
    });
    if (result['paid'] == true) {
      activation = true;
      notice = 'Your previous checkout is saved. Verify your email; do not pay again.';
      return;
    }
    if (result['expired'] == true) {
      await prefs.remove(key);
      notice = 'Stripe confirmed that checkout expired unpaid. You can now start a new checkout.';
      return;
    }
    final url = Uri.parse(result['url'] as String);
    if (url.scheme != 'https' || url.host != 'checkout.stripe.com') {
      throw Exception('The secure payment address could not be verified.');
    }
    if (!await launchUrl(url, webOnlyWindowName: '_self')) {
      throw Exception('Could not open secure checkout. Please try again.');
    }
  }

  Future<void> verifyEmail() async {
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.text.trim())) {
      throw Exception('Enter the email used at checkout.');
    }
    await client.auth.signInWithOtp(
      email: email.text.trim(),
      emailRedirectTo: 'https://ce.cehalo.com',
    );
    notice =
        'Check your email and open the sign-in link in this browser. '
        'Your payment is saved even if you leave this page.';
  }

  Future<void> claim(Map order) async {
    if (!form.currentState!.validate() || !accept) {
      throw Exception(
        'Complete your profile and acknowledge the account security step.',
      );
    }
    final result = await request('guest-claim', {
      'order_id': order['id'],
      'full_name': name.text.trim(),
      'role': role,
      'password': password.text,
      'accept': accept,
    }, signed: true);
    password.clear();
    await loadPurchases();
    notice = result['needs_review'] == true
        ? 'You already own part of this purchase. Contact CE HALO support for an overlap review; your existing progress is unchanged.'
        : 'Your course access is activated. Open My courses to begin.';
  }

  String title(String code) => switch (code) {
    'medication' => 'Medication Review for the Experienced CRNA',
    'uncommon' => 'Uncommon Anesthesia Events',
    'legal' => 'Legal Essentials for the CRNA',
    'bundle' => 'The Three-Course Bundle',
    _ => 'CE HALO courses',
  };
  Widget action(
    String text,
    VoidCallback onPressed, {
    bool secondary = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: secondary
        ? OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: busy ? null : onPressed, child: Text(text))
        : FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: busy ? null : onPressed, child: Text(text)),
  );

  Widget field(
    TextEditingController controller,
    String label, {
    bool secret = false,
    String? Function(String?)? validate,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: TextFormField(
      controller: controller,
      obscureText: secret,
      autocorrect: !secret,
      enableSuggestions: !secret,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validate,
    ),
  );

  List<Widget> checkoutBody() {
    final products = (catalog?['products'] as List? ?? []).cast<Map>();
    if (selected == null) {
      return [
        const Text(
          'Choose your next course.',
          style: TextStyle(fontFamily: 'Fraunces', fontSize: 34),
        ),
        const SizedBox(height: 16),
        const Text(
          'Purchase first. Activate your learner account after payment.',
        ),
        for (final p in products)
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(18),
              title: Text(
                title(p['code']),
                style: const TextStyle(fontSize: 20),
              ),
              subtitle: Text(
                '\$${(p['amount'] / 100).toStringAsFixed(2)} · One-time purchase',
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: busy ? null : () => setState(() => selected = p['code']),
            ),
          ),
      ];
    }
    final matching = products.where((p) => p['code'] == selected).toList();
    final p = matching.isEmpty ? null : matching.first;
    final ready = catalog?['enabled'] == true && p?['enabled'] == true;
    return [
      const Text(
        'No account needed to purchase.',
        style: TextStyle(fontSize: 15),
      ),
      const SizedBox(height: 12),
      Text(
        title(selected!),
        style: const TextStyle(fontFamily: 'Fraunces', fontSize: 34),
      ),
      const SizedBox(height: 20),
      if (p != null)
        Text(
          '\$${(p['amount'] / 100).toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
        ),
      const SizedBox(height: 16),
      const Text(
        'One-time payment. No automatic subscription. Course credit and certificates require completing all course requirements.',
      ),
      const SizedBox(height: 20),
      const Text(
        'Already use Luma? Use the same email at checkout. After payment, verify that email and complete your learner profile to connect your access.',
      ),
      const SizedBox(height: 20),
      if (ready)
        action('Continue to secure payment', () => run(pay))
      else
        const Text(
          'Purchase-first checkout is not open yet. Existing course access is unchanged.',
        ),
      action(
        'Already purchased? Activate access',
        () => setState(() => activation = true),
        secondary: true,
      ),
      action(
        'Choose a different course',
        () => setState(() => selected = null),
        secondary: true,
      ),
      const Text(
        'If you already own this course or part of the bundle, open My courses instead of buying again.',
      ),
    ];
  }

  List<Widget> activationBody() {
    if (!verified) {
      return [
        const Text(
          'Your purchase stays saved.',
          style: TextStyle(fontFamily: 'Fraunces', fontSize: 34),
        ),
        const SizedBox(height: 16),
        const Text(
          'Use the email from your Stripe checkout. We will verify it before linking any purchase to a new or existing Luma account.',
        ),
        field(email, 'Email used at checkout'),
        action('Email my secure activation link', () => run(verifyEmail)),
        const Text(
          'You do not need to pay again. Check spam or junk if the email does not arrive.',
        ),
      ];
    }
    final orders = (purchases?['orders'] as List? ?? []).cast<Map>();
    final paid = orders
        .where(
          (o) =>
              o['state'] == 'paid' &&
              o['claimed'] != true &&
              o['needs_review'] != true,
        )
        .toList();
    return [
      const Text(
        'Activate your learning.',
        style: TextStyle(fontFamily: 'Fraunces', fontSize: 34),
      ),
      const SizedBox(height: 12),
      Text(
        'Verified email: ${purchases?['email'] ?? client.auth.currentUser?.email ?? ''}',
      ),
      const SizedBox(height: 18),
      for (final order in orders)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '${title(order['product_code'])}: ${order['needs_review'] == true
                ? 'Contact support for purchase overlap'
                : order['claimed'] == true
                ? 'Activated'
                : order['state']}',
          ),
        ),
      if (orders.isEmpty)
        const Text(
          'No saved purchase was found for this email yet. If payment just completed, refresh shortly. Check that this is the exact email used at Stripe; do not pay again.',
        ),
      if (paid.isNotEmpty) ...[
        field(
          name,
          'Full learner name',
          validate: (v) =>
              (v?.trim().length ?? 0) >= 2 ? null : 'Enter your full name.',
        ),
        DropdownButtonFormField<String>(
          initialValue: role,
          decoration: const InputDecoration(labelText: 'Professional role'),
          items: [
            'CRNA',
            'SRNA',
            'RN',
            'Physician',
            'Other clinician',
          ].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
          onChanged: (v) => setState(() => role = v),
          validator: (v) => v == null ? 'Choose your role.' : null,
        ),
        field(
          password,
          'Set your Luma password (12+ characters)',
          secret: true,
          validate: (v) =>
              (v?.length ?? 0) >= 12 ? null : 'Use at least 12 characters.',
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: accept,
          onChanged: (v) => setState(() => accept = v ?? false),
          title: const Text(
            'I understand this secures my account with this password and signs out other sessions. Existing courses and learning progress stay intact.',
          ),
        ),
        for (final order in paid)
          action(
            'Activate ${title(order['product_code'])}',
            () => run(() => claim(order)),
          ),
      ],
      action(
        'Refresh saved purchases',
        () => run(loadPurchases),
        secondary: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: cream,
    appBar: AppBar(
      title: const Text('CE HALO'),
      backgroundColor: cream,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const CeLibraryScreen())),
          child: const Text('My courses'),
        ),
      ],
    ),
    body: SelectionArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: navy, fontSize: 16, height: 1.5),
              child: Form(
                key: form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      activation
                          ? 'CHECKOUT / ACTIVATE ACCESS'
                          : 'CHECKOUT / COURSE SELECTION',
                      style: const TextStyle(fontSize: 12, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 24),
                    if (busy) const LinearProgressIndicator(),
                    const SizedBox(height: 12),
                    ...activation ? activationBody() : checkoutBody(),
                    if (notice != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(notice!),
                        ),
                      ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            error!,
                            style: const TextStyle(color: Color(0xFF922E30)),
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                    const Text(
                      'CE HALO LLC · Your email connects your purchases and course access.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
