import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';

const mobileAuthRedirect = 'com.luma.anesthesia://login-callback/';

/// The SDK exchanges the PKCE code in the query before the account view opens.
/// Do not include a Flutter hash route, tokens, or old callback query parameters.
String accountAuthRedirect({required bool isWeb, required Uri base}) => isWeb
    ? Uri(
        scheme: base.scheme,
        host: base.host,
        port: base.hasPort ? base.port : null,
        path: base.path,
        queryParameters: {'auth_callback': '1'},
      ).toString()
    : mobileAuthRedirect;

abstract class AccountAccess {
  String? get email;
  Stream<void> get changes;
  Future<Set<OAuthProvider>> enabledProviders();
  Future<bool> signInWithProvider(OAuthProvider provider);
  Future<bool> submit(String email, String password, {required bool create});
  Future<void> signOut();
}

class SupabaseAccountAccess implements AccountAccess {
  SupabaseAccountAccess(this.client, {this.settingsClient});
  final SupabaseClient client;
  final http.Client? settingsClient;

  @override
  String? get email => client.auth.currentUser?.isAnonymous == false
      ? client.auth.currentUser?.email
      : null;

  @override
  Stream<void> get changes => client.auth.onAuthStateChange.map((_) {});

  @override
  Future<Set<OAuthProvider>> enabledProviders() async {
    final transport = settingsClient ?? http.Client();
    try {
      // Public provider availability only. Never read provider secrets.
      final response = await transport.get(
        Uri.parse('${LumaConfig.supabaseUrl}/auth/v1/settings'),
        headers: {'apikey': LumaConfig.supabaseAnonKey},
      ).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw const AuthException('Unable to check sign-in availability.');
      }
      final settings = jsonDecode(response.body) as Map<String, dynamic>;
      final external = settings['external'] as Map<String, dynamic>? ?? {};
      return {
        if (external['apple'] == true) OAuthProvider.apple,
        if (external['google'] == true) OAuthProvider.google,
      };
    } finally {
      if (settingsClient == null) transport.close();
    }
  }

  @override
  Future<bool> signInWithProvider(OAuthProvider provider) {
    if (provider != OAuthProvider.apple && provider != OAuthProvider.google) {
      throw ArgumentError('Unsupported sign-in provider');
    }
    // A successful launch is not a successful login. The UI observes changes.
    return client.auth.signInWithOAuth(
      provider,
      redirectTo: accountAuthRedirect(isWeb: kIsWeb, base: Uri.base),
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

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
