import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:luma_anesthesia/offline/offline_cache.dart';
import 'package:luma_anesthesia/offline/offline_library.dart';

import 'offline_cache_test.dart' show MemoryCacheStorage;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SupabaseClient client;
  late OfflineCache cache;
  late OfflineLibrary library;
  late DateTime now;
  bool offline = false, denied = false, partial = false;
  final paths = <String>[];
  final requests = <Uri>[];
  setUp(() async {
    now = DateTime.now().toUtc();
    offline = denied = partial = false;
    paths.clear();
    requests.clear();
    cache = OfflineCache(storage: MemoryCacheStorage(), clock: () => now);
    client = SupabaseClient(
      'https://fixture.supabase.co',
      'not-a-real-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        paths.add(request.url.path);
        requests.add(request.url);
        if (offline) throw http.ClientException('Airplane mode');
        final path = request.url.path.split('/').last;
        Object? body;
        switch (path) {
          case 'token':
            body = {
              'access_token': 'fixture-token',
              'refresh_token': 'fixture-refresh',
              'token_type': 'bearer',
              'expires_in': 3600,
              'user': {
                'id': 'fixture-user',
                'aud': 'authenticated',
                'role': 'authenticated',
                'email': 'fixture@example.com',
                'created_at': now.toIso8601String(),
                'is_anonymous': false,
              },
            };
          case 'has_clinical_premium_access':
            body = !denied;
          case 'luma_content_entitlements':
            body = [
              {
                'valid_until': now
                    .add(const Duration(hours: 2))
                    .toIso8601String(),
                'revoked_at': null,
              },
            ];
          case 'luma_ce_bonus_purchases':
            body = [
              {
                'valid_until': now
                    .add(const Duration(hours: 4))
                    .toIso8601String(),
                'bonus_starts_at': now
                    .subtract(const Duration(hours: 1))
                    .toIso8601String(),
                'bonus_awarded': true,
                'revoked_at': null,
              },
            ];
          case 'medication':
            body = [
              {
                'id': 'med-1',
                'name': 'Fixture',
                'vasoactive_role': 'vasopressor',
              },
            ];
          case 'blood_products':
            body = [
              {'id': 'blood-1', 'name': 'Fixture'},
            ];
          case 'quick_reference_catalog':
            body = [
              {
                'id': 'quick-1',
                'reference_id': 'guide',
                'reference_title': 'Guide',
                'title': 'Section',
                'keywords': [],
                'sort_order': 1,
              },
            ];
          case 'quick_reference_sections':
            body = [
              {'id': 'quick-1', 'body': 'Free fixture', 'version': '1'},
            ];
          case 'crisis_catalog':
            body = [
              {
                'slug': 'free',
                'is_free': true,
                'release_status': 'published',
                'title': 'Free',
              },
              {
                'slug': 'paid',
                'is_free': false,
                'release_status': 'published',
                'title': 'Paid',
              },
              {
                'slug': 'draft',
                'is_free': false,
                'release_status': 'draft',
                'title': 'Draft',
              },
            ];
          case 'crisis_protocols':
            body = [
              {
                'slug': 'free',
                'content': {'test': 'free fixture'},
              },
              if (!partial)
                {
                  'slug': 'paid',
                  'content': {'test': 'paid fixture'},
                },
              {
                'slug': 'draft',
                'content': {'test': 'draft never saved'},
              },
            ];
          case 'special_consideration_catalog':
            body = [
              {
                'slug': 'condition',
                'review_status': 'published',
                'is_guest_preview': false,
              },
            ];
          case 'special_considerations':
            body = [
              {
                'slug': 'condition',
                'subtitle': 'Fixture',
                'content': {},
                'citations': [],
                'crisis_hub_links': [],
              },
            ];
          case 'special_consideration_deep_dives':
            body = [
              {'slug': 'condition', 'body': 'Deep fixture'},
            ];
          case 'medication_deep_dive':
            body = {'allowed': true, 'body': 'Medication fixture'};
          default:
            throw StateError('Unexpected mock route: $path');
        }
        return http.Response(
          jsonEncode(body),
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      }),
    );
    library = OfflineLibrary(client, cache: cache);
    await client.auth.signInWithPassword(
      email: 'fixture@example.com',
      password: 'test-fixture-only',
    );
  });
  tearDown(() async {
    await OfflineLibrary.dispose();
    await client.dispose();
  });

  test(
    'existing subscription and CE tables produce an expiry-bound offline lease',
    () async {
      await library.refreshAccess();
      expect(cache.privateUntil, now.add(const Duration(hours: 4)));
      expect(
        paths,
        containsAll([
          '/rest/v1/rpc/has_clinical_premium_access',
          '/rest/v1/luma_content_entitlements',
          '/rest/v1/luma_ce_bonus_purchases',
        ]),
      );
    },
  );
  test(
    'verified native download saves every group and excludes reviewer drafts',
    () async {
      expect(
        await library.download(),
        'Free and subscribed references downloaded.',
      );
      final stored = await cache.storage.keys();
      expect(
        stored,
        containsAll([
          'public:medications',
          'public:blood',
          'public:quick:quick-1',
          'public:crisis:free',
          'private:fixture-user:crisis:paid',
          'private:fixture-user:patho:condition',
          'private:fixture-user:med_deep:med-1',
          'private:fixture-user:patho_deep:condition',
          'public:download_complete',
        ]),
      );
      expect(stored.where((key) => key.contains('draft')), isEmpty);
      offline = true;
      cache.networkUnavailable = true;
      expect((await library.medications()).length, 1);
      expect(await library.medicationDeepDive('med-1'), {
        'allowed': true,
        'body': 'Medication fixture',
      });
      await library.refreshAccess();
      expect(cache.privateAllowed, isTrue);
    },
  );
  test(
    'a partial premium response cannot produce a complete-download marker',
    () async {
      partial = true;
      await expectLater(library.download(), throwsStateError);
      expect(
        await cache.storage.keys(),
        isNot(contains('public:download_complete')),
      );
      expect(OfflineLibrary.downloading, isFalse);
    },
  );
  test('vasopressor browse requests only vasoactive rows', () async {
    final rows = await library.vasoMedications();
    expect(rows, hasLength(1));
    final query = requests.last.queryParameters;
    expect(query['vasoactive_role'], 'in.("vasopressor","infusion")');
    expect(query['select'], isNot(contains('deep_dive_content')));
    expect(paths.where((p) => p.endsWith('/medication')), hasLength(1));
  });
  test(
    'vasopressor browse reuses a full offline medication download',
    () async {
      await library.medications();
      offline = true;
      cache.networkUnavailable = true;
      final rows = await library.vasoMedications();
      expect(rows.single['id'], 'med-1');
    },
  );
  test('online access revocation purges saved protected records', () async {
    await library.download();
    denied = true;
    await library.refreshAccess();
    expect(cache.privateAllowed, isFalse);
    expect(
      (await cache.storage.keys()).where((key) => key.startsWith('private:')),
      isEmpty,
    );
    expect(await cache.saved('quick:quick-1'), isNotNull);
  });
  test(
    'offline first use without a prior verified lease cannot create one',
    () async {
      offline = true;
      await library.refreshAccess();
      expect(cache.privateAllowed, isFalse);
      await expectLater(
        library.download(),
        throwsA(isA<http.ClientException>()),
      );
      expect(await cache.storage.keys(), isEmpty);
    },
  );
}
