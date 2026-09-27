import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:luma_anesthesia/offline/cache_storage.dart';
import 'package:luma_anesthesia/offline/offline_cache.dart';

class MemoryCacheStorage extends CacheStorage {
  final data = <String, String>{};
  String? secretValue;
  bool failWrites = false;
  bool privateSupport = true;
  @override
  Future<String?> read(String key) async => data[key];
  @override
  Future<void> write(String key, String value) async {
    if (failWrites) throw StateError('Full');
    data[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    data.remove(key);
  }

  @override
  Future<List<String>> keys() async => data.keys.toList();
  @override
  Future<String?> secret() async => secretValue;
  @override
  Future<void> saveSecret(String value) async {
    secretValue = value;
  }

  @override
  bool get supportsPrivate => privateSupport;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MemoryCacheStorage storage;
  late OfflineCache cache;
  late DateTime now;
  setUp(() {
    now = DateTime.utc(2026, 9, 27, 12);
    storage = MemoryCacheStorage();
    cache = OfflineCache(storage: storage, clock: () => now);
  });
  Future<void> grant({Duration expiry = const Duration(days: 30)}) async {
    await cache.setOwner('user-a');
    await cache.grant(now.add(expiry));
  }

  test('public download survives restart and a network failure', () async {
    await cache.load(
      'meds',
      () async => [
        {'name': 'fixture'},
      ],
    );
    final restarted = OfflineCache(storage: storage, clock: () => now);
    expect(
      await restarted.load('meds', () => throw http.ClientException('offline')),
      [
        {'name': 'fixture'},
      ],
    );
    expect(restarted.notice.value, contains('2026-09-27'));
  });
  test(
    'private content is encrypted and restored only for its owner',
    () async {
      await grant();
      await cache.save('clinical', {
        'body': 'protected test prose',
      }, private: true);
      expect(
        storage.data.values.join(),
        isNot(contains('protected test prose')),
      );
      final restarted = OfflineCache(storage: storage, clock: () => now);
      await restarted.setOwner('user-a');
      expect(await restarted.saved('clinical', private: true), {
        'body': 'protected test prose',
      });
    },
  );
  test('private access is capped at 72 hours', () async {
    await grant();
    expect(cache.privateUntil, now.add(const Duration(hours: 72)));
    await cache.save('clinical', 'test', private: true);
    now = now.add(const Duration(hours: 72));
    await expectLater(
      cache.saved('clinical', private: true),
      throwsA(isA<OfflineUnavailable>()),
    );
    expect(storage.data.keys.where((k) => k.startsWith('private:')), isEmpty);
  });
  test('actual access expiration wins over 72-hour limit', () async {
    await grant(expiry: const Duration(hours: 2));
    await cache.save('clinical', 'test', private: true);
    now = now.add(const Duration(hours: 2));
    await expectLater(
      cache.saved('clinical', private: true),
      throwsA(isA<OfflineUnavailable>()),
    );
  });
  test('signout purges protected but preserves public downloads', () async {
    await grant();
    await cache.save('public', 'free');
    await cache.save('clinical', 'private', private: true);
    await cache.setOwner(null);
    expect(await cache.saved('public'), 'free');
    expect(storage.data.keys.where((k) => k.startsWith('private:')), isEmpty);
  });
  test('another account cannot open the prior account download', () async {
    await grant();
    await cache.save('clinical', 'private', private: true);
    await cache.setOwner('user-b');
    await cache.grant(now.add(const Duration(days: 1)));
    await expectLater(
      cache.saved('clinical', private: true),
      throwsA(isA<OfflineUnavailable>()),
    );
  });
  test('clock rollback invalidates the lease', () async {
    await grant();
    now = now.subtract(const Duration(hours: 1));
    expect(await cache.restoreLease(), isFalse);
    expect(cache.privateAllowed, isFalse);
  });
  test('tampered ciphertext never renders', () async {
    await grant();
    await cache.save('clinical', 'private', private: true);
    final envelope =
        jsonDecode(storage.data['private:user-a:clinical']!) as Map;
    final bytes = base64Decode(envelope['sealed'] as String);
    bytes[15] ^= 1;
    storage.data['private:user-a:clinical'] = jsonEncode({
      'sealed': base64Encode(bytes),
    });
    await expectLater(
      cache.saved('clinical', private: true),
      throwsA(isA<OfflineUnavailable>()),
    );
  });
  test(
    'authorization and parser failures do not fall back to saved data',
    () async {
      await cache.save('clinical', 'old');
      await expectLater(
        cache.load('clinical', () => throw StateError('403')),
        throwsStateError,
      );
      await expectLater(
        cache.load('clinical', () => throw const FormatException()),
        throwsFormatException,
      );
    },
  );
  test(
    'incomplete remote fetch preserves the last complete cached set',
    () async {
      await cache.save('meds', ['complete']);
      expect(await cache.load('meds', () => throw TimeoutException('page 2')), [
        'complete',
      ]);
    },
  );
  test('authoritative null removes a cached record', () async {
    await cache.save('record', 'old');
    expect(await cache.load('record', () async => null), isNull);
    await expectLater(
      cache.saved('record'),
      throwsA(isA<OfflineUnavailable>()),
    );
  });
  test(
    'explicit downloads fail rather than report completion from old cache',
    () async {
      await cache.save('meds', ['old']);
      await expectLater(
        cache.load(
          'meds',
          () => throw http.ClientException('offline'),
          force: true,
        ),
        throwsA(isA<http.ClientException>()),
      );
    },
  );
  test(
    'storage failure leaves online reading available but fails strict download',
    () async {
      storage.failWrites = true;
      expect(await cache.load('meds', () async => ['online']), ['online']);
      expect(cache.writeFailure, isNotNull);
      cache.strictWrites = true;
      await expectLater(
        cache.load('meds', () async => ['online']),
        throwsStateError,
      );
    },
  );
  test(
    'web storage never persists private payloads or an offline lease',
    () async {
      storage.privateSupport = false;
      await grant();
      expect(
        await cache.load('clinical', () async => 'private', private: true),
        'private',
      );
      expect(storage.data, isEmpty);
      expect(cache.privateAllowed, isFalse);
    },
  );
  test(
    'in-flight private responses cannot outlive an account change',
    () async {
      await grant();
      final response = Completer<Object?>();
      final fetch = cache.load(
        'clinical',
        () => response.future,
        private: true,
      );
      final assertion = expectLater(fetch, throwsA(isA<OfflineUnavailable>()));
      await cache.setOwner('user-b');
      response.complete('old account content');
      await assertion;
      expect(storage.data.keys.where((k) => k.contains('clinical')), isEmpty);
    },
  );
  test('a missing download can retry online without restarting app', () async {
    cache.networkUnavailable = true;
    expect(
      await cache.load('new', () async => 'now connected'),
      'now connected',
    );
  });
  test('clear removes all references and the lease', () async {
    await grant();
    await cache.save('free', 'data');
    await cache.clear();
    expect(storage.data, isEmpty);
    expect(cache.privateAllowed, isFalse);
  });
}
