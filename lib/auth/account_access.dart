import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart' show closeInAppWebView;

import '../config.dart';
import '../offline/offline_cache.dart';
import '../offline/offline_library.dart';

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

/// Apple and Google sign-in must stay inside the app (App Review Guideline 4).
/// Web keeps the existing same-tab redirect; native apps use an in-app sheet.
LaunchMode socialAuthLaunchMode({required bool isWeb}) =>
    isWeb ? LaunchMode.externalApplication : LaunchMode.inAppBrowserView;

/// Apple devices use the native Sign in with Apple sheet instead of a webpage.
bool usesNativeAppleSignIn({
  required bool isWeb,
  required TargetPlatform platform,
}) =>
    !isWeb &&
    (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS);

/// The person closed the native sign-in sheet. Nothing changed.
class SignInCanceled implements Exception {
  const SignInCanceled();
}

class AppleIdCredential {
  const AppleIdCredential(this.idToken, {this.givenName, this.familyName});
  final String idToken;
  final String? givenName;
  final String? familyName;

  String get fullName => [givenName, familyName]
      .whereType<String>()
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .join(' ');
}

/// Requests a native Apple credential bound to [hashedNonce].
typedef AppleCredentialRequest = Future<AppleIdCredential> Function(
  String hashedNonce,
);

Future<AppleIdCredential> requestNativeAppleCredential(
  String hashedNonce,
) async {
  try {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );
    final token = credential.identityToken;
    if (token == null || token.isEmpty) {
      throw const AuthException('Apple did not return a sign-in token.');
    }
    return AppleIdCredential(
      token,
      givenName: credential.givenName,
      familyName: credential.familyName,
    );
  } on SignInWithAppleAuthorizationException catch (error) {
    if (error.code == AuthorizationErrorCode.canceled) {
      throw const SignInCanceled();
    }
    rethrow;
  }
}

/// Single-use random nonce. Only its SHA-256 hash is sent to Apple.
String generateRawNonce([Random? random]) {
  final source = random ?? Random.secure();
  return base64Url.encode(List<int>.generate(32, (_) => source.nextInt(256)));
}

String hashNonce(String rawNonce) =>
    sha256.convert(utf8.encode(rawNonce)).toString();

abstract class AccountAccess {
  String? get email;
  Stream<void> get changes;
  Future<Set<OAuthProvider>> enabledProviders();
  Future<bool> signInWithProvider(OAuthProvider provider);
  Future<bool> submit(String email, String password, {required bool create});
  Future<void> signOut();
}

abstract interface class PasswordRecoveryAccess {
  Future<void> requestPasswordReset(String email);
  Future<void> updatePassword(String password);
}

class SupabaseAccountAccess implements AccountAccess, PasswordRecoveryAccess {
  SupabaseAccountAccess(
    this.client, {
    this.settingsClient,
    this.appleCredential = requestNativeAppleCredential,
    bool? nativeApple,
  }) : nativeApple =
           nativeApple ??
           usesNativeAppleSignIn(
             isWeb: kIsWeb,
             platform: defaultTargetPlatform,
           );
  final SupabaseClient client;
  final http.Client? settingsClient;
  final AppleCredentialRequest appleCredential;
  final bool nativeApple;

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
      final response = await transport
          .get(
            Uri.parse('${LumaConfig.supabaseUrl}/auth/v1/settings'),
            headers: {'apikey': LumaConfig.supabaseAnonKey},
          )
          .timeout(const Duration(seconds: 12));
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
    if (provider == OAuthProvider.apple && nativeApple) {
      return _signInWithNativeApple();
    }
    // A successful launch is not a successful login. The UI observes changes.
    if (!kIsWeb) _closeSignInSheetAfterLogin();
    return client.auth.signInWithOAuth(
      provider,
      redirectTo: accountAuthRedirect(isWeb: kIsWeb, base: Uri.base),
      authScreenLaunchMode: socialAuthLaunchMode(isWeb: kIsWeb),
    );
  }

  StreamSubscription<AuthState>? _sheetWatch;

  /// Supabase does not dismiss the in-app sign-in sheet after the callback.
  void _closeSignInSheetAfterLogin() {
    _sheetWatch?.cancel();
    _sheetWatch = client.auth.onAuthStateChange.listen((state) {
      if (state.event != AuthChangeEvent.signedIn) return;
      _sheetWatch?.cancel();
      _sheetWatch = null;
      closeInAppWebView().catchError((_) {});
    }, onError: (_) {});
  }

  /// Native Sign in with Apple. Supabase verifies Apple's token and nonce.
  Future<bool> _signInWithNativeApple() async {
    final rawNonce = generateRawNonce();
    final credential = await appleCredential(hashNonce(rawNonce));
    final result = await client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: credential.idToken,
      nonce: rawNonce,
    );
    // Apple shares the name only on the first authorization.
    final name = credential.fullName;
    if (result.session != null && name.isNotEmpty) {
      try {
        await client.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': name,
              if (credential.givenName?.trim().isNotEmpty == true)
                'given_name': credential.givenName!.trim(),
              if (credential.familyName?.trim().isNotEmpty == true)
                'family_name': credential.familyName!.trim(),
            },
          ),
        );
      } catch (_) {
        // The sign-in succeeded; a missing display name is not fatal.
      }
    }
    return result.session != null;
  }

  @override
  Future<bool> submit(
    String email,
    String password, {
    required bool create,
  }) async {
    final result = create
        ? await client.auth.signUp(
            email: email,
            password: password,
            emailRedirectTo: accountAuthRedirect(isWeb: kIsWeb, base: Uri.base),
          )
        : await client.auth.signInWithPassword(
            email: email,
            password: password,
          );
    return result.session != null;
  }

  @override
  Future<void> signOut() async {
    await OfflineCache.instance.setOwner(null);
    OfflineLibrary.accessChanged.add(null);
    await client.auth.signOut(scope: SignOutScope.local);
  }

  @override
  Future<void> requestPasswordReset(String email) {
    final redirect = Uri.parse(
      accountAuthRedirect(isWeb: kIsWeb, base: Uri.base),
    );
    return client.auth.resetPasswordForEmail(
      email,
      redirectTo: kIsWeb
          ? redirect
                .replace(
                  queryParameters: {
                    ...redirect.queryParameters,
                    'recovery': '1',
                  },
                )
                .toString()
          : mobileAuthRedirect,
    );
  }

  @override
  Future<void> updatePassword(String password) async {
    if (client.auth.currentSession == null) {
      throw const AuthException(
        'This reset link has expired. Request a new link.',
      );
    }
    await client.auth.updateUser(UserAttributes(password: password));
  }
}
