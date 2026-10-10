import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:luma_anesthesia/auth/account_access.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'medication_sources_test.dart' show MemoryAuthStorage;

void main() {
  test(
    'email confirmation and reset use the registered mobile callback',
    () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'https://example.supabase.co',
        'public-test-key',
        authOptions: AuthClientOptions(
          pkceAsyncStorage: MemoryAuthStorage(),
          autoRefreshToken: false,
        ),
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response(
            request.url.path.endsWith('/signup')
                ? jsonEncode({
                    'id': 'test-user',
                    'aud': 'authenticated',
                    'role': 'authenticated',
                    'email': 'test@example.com',
                    'created_at': '2026-09-27T00:00:00Z',
                    'app_metadata': {},
                    'user_metadata': {},
                  })
                : '{}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      final access = SupabaseAccountAccess(client);
      expect(
        await access.submit('test@example.com', 'test-password', create: true),
        isFalse,
      );
      await access.requestPasswordReset('test@example.com');
      expect(requests.map((r) => r.url.path), [
        '/auth/v1/signup',
        '/auth/v1/recover',
      ]);
      for (final request in requests) {
        expect(request.url.queryParameters['redirect_to'], mobileAuthRedirect);
      }
      await client.dispose();
    },
  );
  test(
    'web redirect retains the app base and drops stale codes and hash routes',
    () {
      final redirect = accountAuthRedirect(
        isWeb: true,
        base: Uri.parse('http://localhost:7357/?code=old#/account'),
      );
      expect(redirect, 'http://localhost:7357/?auth_callback=1');
      expect(
        accountAuthRedirect(
          isWeb: true,
          base: Uri.parse(
            'https://example.com/luma/index.html?error=old#/account',
          ),
        ),
        'https://example.com/luma/index.html?auth_callback=1',
      );
      expect(
        accountAuthRedirect(isWeb: false, base: Uri()),
        mobileAuthRedirect,
      );
    },
  );

  test(
    'public settings enable only explicitly configured supported providers',
    () async {
      final client = SupabaseClient(
        'https://example.supabase.co',
        'public-test-key',
      );
      final transport = MockClient((request) async {
        expect(request.url.path, '/auth/v1/settings');
        expect(request.headers, contains('apikey'));
        expect(request.headers.containsKey('authorization'), isFalse);
        return http.Response(
          '{"external":{"apple":false,"google":true,"github":true}}',
          200,
        );
      });
      final access = SupabaseAccountAccess(client, settingsClient: transport);
      expect(await access.enabledProviders(), {OAuthProvider.google});
      transport.close();
      await client.dispose();
    },
  );

  test('failed settings lookup never enables providers by default', () async {
    final client = SupabaseClient(
      'https://example.supabase.co',
      'public-test-key',
    );
    final transport = MockClient((_) async => http.Response('{}', 503));
    final access = SupabaseAccountAccess(client, settingsClient: transport);
    await expectLater(access.enabledProviders(), throwsA(isA<AuthException>()));
    transport.close();
    await client.dispose();
  });

  group('Guideline 4: sign-in stays inside the app', () {
    test('native apps never send social sign-in to the external browser', () {
      expect(socialAuthLaunchMode(isWeb: false), LaunchMode.inAppBrowserView);
      expect(socialAuthLaunchMode(isWeb: true), LaunchMode.externalApplication);
      expect(
        usesNativeAppleSignIn(isWeb: false, platform: TargetPlatform.iOS),
        isTrue,
      );
      expect(
        usesNativeAppleSignIn(isWeb: false, platform: TargetPlatform.macOS),
        isTrue,
      );
      expect(
        usesNativeAppleSignIn(isWeb: false, platform: TargetPlatform.android),
        isFalse,
      );
      expect(
        usesNativeAppleSignIn(isWeb: true, platform: TargetPlatform.iOS),
        isFalse,
      );
    });

    test(
      'native Apple exchanges the token with the raw nonce Apple hashed',
      () async {
        final requests = <http.Request>[];
        String? hashedForApple;
        final client = SupabaseClient(
          'https://example.supabase.co',
          'public-test-key',
          authOptions: AuthClientOptions(
            pkceAsyncStorage: MemoryAuthStorage(),
            autoRefreshToken: false,
          ),
          httpClient: MockClient((request) async {
            requests.add(request);
            return http.Response(
              jsonEncode({
                'access_token': 'access',
                'token_type': 'bearer',
                'expires_in': 3600,
                'refresh_token': 'refresh',
                'user': {
                  'id': 'apple-user',
                  'aud': 'authenticated',
                  'role': 'authenticated',
                  'email': 'apple@example.com',
                  'created_at': '2026-10-10T00:00:00Z',
                  'app_metadata': {'provider': 'apple'},
                  'user_metadata': {},
                },
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        );
        final access = SupabaseAccountAccess(
          client,
          nativeApple: true,
          appleCredential: (hashed) async {
            hashedForApple = hashed;
            return const AppleIdCredential(
              'apple-id-token',
              givenName: 'Nicole',
              familyName: 'Tester',
            );
          },
        );
        expect(await access.signInWithProvider(OAuthProvider.apple), isTrue);
        expect(requests.first.url.path, '/auth/v1/token');
        expect(requests.first.url.queryParameters['grant_type'], 'id_token');
        final body = jsonDecode(requests.first.body) as Map<String, dynamic>;
        expect(body['provider'], 'apple');
        expect(body['id_token'], 'apple-id-token');
        expect(hashNonce(body['nonce'] as String), hashedForApple);
        expect(body['nonce'], isNot(hashedForApple));
        // First authorization stores Apple's one-time name share.
        expect(requests[1].url.path, '/auth/v1/user');
        expect(requests[1].method, 'PUT');
        expect(
          jsonDecode(requests[1].body)['data']['full_name'],
          'Nicole Tester',
        );
        expect(access.email, 'apple@example.com');
        await client.dispose();
      },
    );

    test('canceling the Apple sheet makes no network request', () async {
      final requests = <http.Request>[];
      final client = SupabaseClient(
        'https://example.supabase.co',
        'public-test-key',
        authOptions: AuthClientOptions(
          pkceAsyncStorage: MemoryAuthStorage(),
          autoRefreshToken: false,
        ),
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response('{}', 500);
        }),
      );
      final access = SupabaseAccountAccess(
        client,
        nativeApple: true,
        appleCredential: (_) async => throw const SignInCanceled(),
      );
      await expectLater(
        access.signInWithProvider(OAuthProvider.apple),
        throwsA(isA<SignInCanceled>()),
      );
      expect(requests, isEmpty);
      await client.dispose();
    });

    test('nonces are unique and hashed with SHA-256', () {
      final first = generateRawNonce();
      expect(first, isNot(generateRawNonce()));
      expect(
        hashNonce('abc'),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });
  });
}
