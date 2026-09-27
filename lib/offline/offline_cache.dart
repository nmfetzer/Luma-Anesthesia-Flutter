import 'dart:async';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthRetryableFetchException;

import 'cache_storage.dart';
import 'cache_backend.dart';

class OfflineUnavailable implements Exception {
  const OfflineUnavailable();
  @override
  String toString() =>
      'This reference is not available offline. Connect to '
      'the internet and update your downloads. Paid access may need rechecking.';
}

/// Versioned records; no fallback on authorization or malformed-response errors.
/// Private payload, owner, timestamp and expiry are authenticated with AES-GCM.
class OfflineCache {
  OfflineCache({CacheBackend? storage, DateTime Function()? clock})
    : storage = storage ?? CacheStorage(),
      clock = clock ?? DateTime.now;
  static final _defaultInstance = OfflineCache();
  @visibleForTesting
  static OfflineCache? testInstance;
  static OfflineCache get instance => testInstance ?? _defaultInstance;
  final CacheBackend storage;
  final DateTime Function() clock;
  final notice = ValueNotifier<String?>(null);
  bool networkUnavailable = false;
  String? owner;
  DateTime? privateUntil;
  int generation = 0;
  bool strictWrites = false;
  String? writeFailure;
  final cipher = AesGcm.with256bits();
  Future<SecretKey>? _key;

  Future<SecretKey> _secret() => _key ??= () async {
    final saved = await storage.secret();
    if (saved != null) return SecretKey(base64Decode(saved));
    final key = await cipher.newSecretKey();
    await storage.saveSecret(base64Encode(await key.extractBytes()));
    return key;
  }();
  String _id(String key, bool private) =>
      private ? 'private:${owner ?? "none"}:$key' : 'public:$key';
  bool get privateAllowed =>
      storage.supportsPrivate &&
      owner != null &&
      privateUntil != null &&
      clock().isBefore(privateUntil!);
  void reconnect() {
    networkUnavailable = false;
    notice.value = null;
  }

  Future<void> setOwner(String? value) async {
    if (owner == value) return;
    generation++;
    privateUntil = null;
    owner = value;
    // Remove every other account's downloads before accepting this identity.
    for (final key in await storage.keys()) {
      if (key.startsWith('private:') && !key.startsWith('private:$value:')) {
        await storage.remove(key);
      }
    }
  }

  Future<void> revoke() async {
    generation++;
    privateUntil = null;
    for (final key in await storage.keys()) {
      if (key.startsWith('private:')) await storage.remove(key);
    }
  }

  Future<void> clear() async {
    generation++;
    privateUntil = null;
    for (final key in await storage.keys()) await storage.remove(key);
    reconnect();
  }

  Future<Map<String, dynamic>?> _read(String id, bool private) async {
    try {
      final raw = await storage.read(id);
      if (raw == null) return null;
      var data = jsonDecode(raw) as Map<String, dynamic>;
      if (private) {
        final box = SecretBox.fromConcatenation(
          base64Decode(data['sealed'] as String),
          nonceLength: 12,
          macLength: 16,
        );
        data = jsonDecode(
          utf8.decode(
            await cipher.decrypt(
              box,
              secretKey: await _secret(),
              aad: utf8.encode(id),
            ),
          ),
        ) as Map<String, dynamic>;
      }
      if (data['version'] != 1) return null;
      return data;
    } catch (_) {
      // Corrupt/tampered/older data is never rendered as a clinical reference.
      return null;
    }
  }

  Future<void> _write(
    String id,
    Map<String, dynamic> data,
    bool private,
  ) async {
    final epoch = generation;
    var encoded = jsonEncode(data);
    if (private) {
      final box = await cipher.encrypt(
        utf8.encode(encoded),
        secretKey: await _secret(),
        aad: utf8.encode(id),
      );
      encoded = jsonEncode({'sealed': base64Encode(box.concatenation())});
    }
    if (epoch != generation) throw const OfflineUnavailable();
    await storage.write(id, encoded);
    if (epoch != generation) {
      await storage.remove(id);
      throw const OfflineUnavailable();
    }
  }

  Future<void> grant(DateTime expiry) async {
    if (!storage.supportsPrivate || owner == null) return;
    final max = clock().add(const Duration(hours: 72));
    privateUntil = expiry.isBefore(max) ? expiry : max;
    if (!privateAllowed) {
      await revoke();
      return;
    }
    await _write(_id('_lease', true), {
      'version': 1,
      'owner': owner,
      'until': privateUntil!.toUtc().toIso8601String(),
      'last_seen': clock().toUtc().toIso8601String(),
    }, true);
  }

  Future<bool> restoreLease() async {
    if (!storage.supportsPrivate || owner == null) return false;
    final epoch = generation;
    final id = _id('_lease', true);
    final data = await _read(id, true);
    if (epoch != generation) return false;
    if (data == null || data['owner'] != owner) {
      privateUntil = null;
      return false;
    }
    final last = DateTime.parse(data['last_seen'] as String);
    if (clock().isBefore(last.subtract(const Duration(minutes: 5)))) {
      await revoke();
      return false;
    }
    privateUntil = DateTime.parse(data['until'] as String);
    if (!privateAllowed) {
      await revoke();
      return false;
    }
    data['last_seen'] = clock().toUtc().toIso8601String();
    await _write(id, data, true);
    return true;
  }

  Future<void> save(String key, Object? data, {bool private = false}) async {
    if (private && !privateAllowed) return;
    final id = _id(key, private);
    if (data == null) {
      await storage.remove(id);
      return;
    }
    await _write(id, {
      'version': 1,
      'data': data,
      'owner': private ? owner : null,
      'saved_at': clock().toUtc().toIso8601String(),
      if (private) 'until': privateUntil!.toUtc().toIso8601String(),
    }, private);
  }

  Future<Object?> saved(String key, {bool private = false}) async {
    final epoch = generation;
    if (private && !(await restoreLease())) throw const OfflineUnavailable();
    final data = await _read(_id(key, private), private);
    if (private && epoch != generation) throw const OfflineUnavailable();
    if (data == null) throw const OfflineUnavailable();
    if (private && data['owner'] != owner) {
      throw const OfflineUnavailable();
    }
    final date = DateTime.parse(data['saved_at'] as String).toLocal();
    final stale = clock().difference(date) > const Duration(days: 30);
    notice.value =
        '${stale ? "Older downloaded copy" : "Downloaded copy"} · '
        '${date.toIso8601String().substring(0, 10)}. Open Downloads to check for updates.';
    return data['data'];
  }

  static bool isConnectionError(Object error) =>
      error is TimeoutException ||
      error is http.ClientException ||
      error is AuthRetryableFetchException;

  Future<Object?> load(
    String key,
    Future<Object?> Function() fetch, {
    bool private = false,
    bool force = false,
    bool persist = true,
  }) async {
    if (networkUnavailable && !force) {
      try {
        return await saved(key, private: private);
      } on OfflineUnavailable {
        /* A missing download can be retried online. */
      }
    }
    final epoch = generation;
    try {
      final data = await fetch().timeout(Duration(seconds: force ? 120 : 15));
      if (private && epoch != generation) throw const OfflineUnavailable();
      try {
        if (persist) await save(key, data, private: private);
      } catch (_) {
        writeFailure =
            'Device storage unavailable or full. Download not complete.';
        if (strictWrites) rethrow;
      }
      return data;
    } catch (error) {
      if (!isConnectionError(error) || force) rethrow;
      networkUnavailable = true;
      return saved(key, private: private);
    }
  }
}
