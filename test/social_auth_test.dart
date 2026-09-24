import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:luma_anesthesia/auth/account_access.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
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
              'https://example.com/luma/index.html?error=old#/account'),
        ),
        'https://example.com/luma/index.html?auth_callback=1');
    expect(accountAuthRedirect(isWeb: false, base: Uri()), mobileAuthRedirect);
  });

  test('public settings enable only explicitly configured supported providers',
      () async {
    final client =
        SupabaseClient('https://example.supabase.co', 'public-test-key');
    final transport = MockClient((request) async {
      expect(request.url.path, '/auth/v1/settings');
      expect(request.headers, contains('apikey'));
      expect(request.headers.containsKey('authorization'), isFalse);
      return http.Response(
          '{"external":{"apple":false,"google":true,"github":true}}', 200);
    });
    final access = SupabaseAccountAccess(client, settingsClient: transport);
    expect(await access.enabledProviders(), {OAuthProvider.google});
    transport.close();
    await client.dispose();
  });

  test('failed settings lookup never enables providers by default', () async {
    final client =
        SupabaseClient('https://example.supabase.co', 'public-test-key');
    final transport = MockClient((_) async => http.Response('{}', 503));
    final access = SupabaseAccountAccess(client, settingsClient: transport);
    await expectLater(access.enabledProviders(), throwsA(isA<AuthException>()));
    transport.close();
    await client.dispose();
  });
}
