import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/medication_public_fields.dart';
import 'offline_cache.dart';

class OfflineLibrary {
  OfflineLibrary(this.client, {OfflineCache? cache})
    : cache = cache ?? OfflineCache.instance;
  final SupabaseClient client;
  final OfflineCache cache;
  static final accessChanged = StreamController<void>.broadcast();
  static Timer? _expiry;
  static StreamSubscription<AuthState>? _auth;
  static final progress = StreamController<String>.broadcast();
  static bool downloading = false;
  static Future<void> dispose() async {
    _expiry?.cancel();
    _expiry = null;
    await _auth?.cancel();
    _auth = null;
  }

  static Stream<void> authChanges(SupabaseClient client) =>
      Stream<void>.multi((controller) {
        final auth = client.auth.onAuthStateChange.listen(
          (_) => controller.add(null),
          onError: controller.addError,
        );
        final access = accessChanged.stream.listen((_) => controller.add(null));
        controller.onCancel = () async {
          await auth.cancel();
          await access.cancel();
        };
      }, isBroadcast: true);

  static Future<void> initialize(SupabaseClient client) async {
    final lib = OfflineLibrary(client);
    await lib.cache.setOwner(
      client.auth.currentUser?.isAnonymous == false
          ? client.auth.currentUser!.id
          : null,
    );
    await lib.cache.restoreLease();
    lib._scheduleExpiry();
    await _auth?.cancel();
    _auth = client.auth.onAuthStateChange.listen((state) async {
      try {
        await lib.cache.setOwner(
          state.session?.user.isAnonymous == false
              ? state.session!.user.id
              : null,
        );
        await lib.refreshAccess();
      } catch (_) {
        /* No offline grant on an unverified response. */
      }
      accessChanged.add(null);
    }, onError: (Object _, StackTrace __) {});
    unawaited(lib.refreshAccess().catchError((_) {}));
  }

  void _scheduleExpiry() {
    _expiry?.cancel();
    final until = cache.privateUntil;
    if (until == null) return;
    final delay = until.difference(cache.clock());
    _expiry = Timer(delay.isNegative ? Duration.zero : delay, () async {
      await cache.revoke();
      accessChanged.add(null);
    });
  }

  Future<void> refreshAccess() async {
    final id = client.auth.currentUser?.isAnonymous == false
        ? client.auth.currentUser!.id
        : null;
    await cache.setOwner(id);
    if (id == null || !cache.storage.supportsPrivate) return;
    final epoch = cache.generation;
    try {
      final allowed = await client
          .rpc('has_clinical_premium_access')
          .timeout(const Duration(seconds: 8));
      if (epoch != cache.generation) return;
      if (allowed != true) {
        await cache.revoke();
        accessChanged.add(null);
        return;
      }
      final entitlements = await client
          .from('luma_content_entitlements')
          .select('valid_until,revoked_at')
          .eq('user_id', id)
          .eq('entitlement', 'clinical_premium')
          .timeout(const Duration(seconds: 8));
      final bonuses = await client
          .from('luma_ce_bonus_purchases')
          .select('valid_until,revoked_at,bonus_starts_at,bonus_awarded')
          .eq('user_id', id)
          .timeout(const Duration(seconds: 8));
      if (epoch != cache.generation) return;
      final now = cache.clock();
      final expiries = <DateTime>[
        for (final row in entitlements)
          if (row['revoked_at'] == null)
            DateTime.parse(row['valid_until'] as String),
        for (final row in bonuses)
          if (row['revoked_at'] == null &&
              row['bonus_awarded'] == true &&
              !DateTime.parse(row['bonus_starts_at'] as String).isAfter(now))
            DateTime.parse(row['valid_until'] as String),
      ].where((date) => date.isAfter(now)).toList()..sort();
      if (expiries.isEmpty) {
        await cache.revoke();
      } else {
        await cache.grant(expiries.last);
      }
      _scheduleExpiry();
    } catch (error) {
      if (!OfflineCache.isConnectionError(error)) {
        await cache.revoke();
        accessChanged.add(null);
        rethrow;
      }
      await cache.restoreLease();
      _scheduleExpiry();
    }
  }

  Future<List<Map<String, dynamic>>> fetchRows(
    String table,
    String fields,
    String order, {
    String? publishedColumn,
  }) async {
    final rows = <Map<String, dynamic>>[];
    for (var offset = 0; ; offset += 200) {
      var query = client.from(table).select(fields);
      if (publishedColumn != null)
        query = query.eq(publishedColumn, 'published');
      final ordered = table == 'quick_reference_catalog'
          ? query
                .order('reference_id', ascending: true)
                .order('sort_order', ascending: true)
                .order('id', ascending: true)
          : table == 'crisis_catalog'
          ? query
                .order('sort_order', ascending: true)
                .order('title', ascending: true)
                .order('slug', ascending: true)
          : query.order(order, ascending: true);
      final page = await ordered
          .range(offset, offset + 199)
          .timeout(const Duration(seconds: 15));
      rows.addAll(page);
      if (page.length < 200) return rows;
    }
  }

  Future<List<Map<String, dynamic>>> rows(
    String key,
    String table,
    String fields,
    String order, {
    bool force = false,
    String? publishedColumn,
  }) async {
    final data = await cache.load(
      key,
      () => fetchRows(table, fields, order, publishedColumn: publishedColumn),
      force: force,
    );
    return (data as List)
        .map((r) => Map<String, dynamic>.from(r as Map))
        .toList();
  }

  Future<List<Map<String, dynamic>>> medications({bool force = false}) => rows(
    'medications',
    'medication',
    medicationPublicFields,
    'id',
    force: force,
  );
  Future<List<Map<String, dynamic>>> blood({bool force = false}) =>
      rows('blood', 'blood_products', '*', 'id', force: force);
  Future<List<Map<String, dynamic>>> quickCatalog({bool force = false}) =>
      rows(
        'quick_catalog',
        'quick_reference_catalog',
        'id,reference_id,reference_title,title,keywords,sort_order',
        'id',
        force: force,
      ).then(
        (rows) => rows
          ..sort((a, b) {
            final group = '${a['reference_id']}'.compareTo(
              '${b['reference_id']}',
            );
            return group != 0
                ? group
                : ((a['sort_order'] as num?) ?? 0).compareTo(
                    (b['sort_order'] as num?) ?? 0,
                  );
          }),
      );
  Future<List<Map<String, dynamic>>> crisisCatalog({bool force = false}) =>
      rows(
        'crisis_catalog',
        'crisis_catalog',
        'slug,title,category,search_terms,is_free,release_status,sort_order',
        'slug',
        force: force,
      ).then(
        (rows) => rows
          ..sort((a, b) {
            final order = ((a['sort_order'] as num?) ?? 0).compareTo(
              (b['sort_order'] as num?) ?? 0,
            );
            return order != 0
                ? order
                : '${a['title']}'.compareTo('${b['title']}');
          }),
      );
  Future<List<Map<String, dynamic>>> pathoCatalog({bool force = false}) => rows(
    'patho_catalog',
    'special_consideration_catalog',
    'slug,title,category,search_tags,review_status,is_guest_preview,reviewed_at,reviewed_by',
    'slug',
    force: force,
  );
  Future<Map<String, dynamic>?> detail(
    String key,
    String table,
    String fields,
    String column,
    String id, {
    bool private = false,
  }) async {
    // Only published records belong in the offline reference library.
    if ((table == 'special_considerations' ||
            table == 'special_consideration_deep_dives') &&
        !(await pathoCatalog()).any(
          (r) => r['slug'] == id && r['review_status'] == 'published',
        )) {
      return null;
    }
    final data = await cache.load(key, () {
      var query = client.from(table).select(fields).eq(column, id);
      if (table == 'special_consideration_deep_dives') {
        query = query.eq('review_status', 'published');
      }
      return query.maybeSingle();
    }, private: private);
    return data == null ? null : Map<String, dynamic>.from(data as Map);
  }

  Future<bool> freeCrisis(String slug) async => (await crisisCatalog()).any(
    (r) =>
        r['slug'] == slug &&
        r['is_free'] == true &&
        r['release_status'] == 'published',
  );
  Future<bool> freePatho(String slug) async => (await pathoCatalog()).any(
    (r) =>
        r['slug'] == slug &&
        r['is_guest_preview'] == true &&
        r['review_status'] == 'published',
  );
  Future<Map<String, dynamic>> medicationDeepDive(
    String id, {
    bool force = false,
  }) async {
    final data = await cache.load(
      'med_deep:$id',
      () async {
        final result = Map<String, dynamic>.from(
          await client.rpc(
            'medication_deep_dive',
            params: {'p_medication_id': id},
          ),
        );
        if (result['allowed'] != true) {
          await cache.storage.remove('private:${cache.owner}:med_deep:$id');
          if (cache.privateAllowed) {
            await cache.revoke();
            accessChanged.add(null);
          }
          return null;
        }
        return result;
      },
      private: true,
      force: force,
    );
    return data == null
        ? {'allowed': false}
        : Map<String, dynamic>.from(data as Map);
  }

  /// Explicit, resumable download. Completion marker is written only if every
  /// requested public group succeeds. Protected records remain account-bound.
  Future<String> download() async {
    if (downloading) throw StateError('A download is already running.');
    downloading = true;
    cache.reconnect();
    cache.strictWrites = true;
    cache.writeFailure = null;
    final startOwner = client.auth.currentUser?.id;
    void checkOwner() {
      if (client.auth.currentUser?.id != startOwner) {
        throw StateError('Account changed. Restart the download.');
      }
    }

    try {
      await cache.storage.remove('public:download_complete');
      await refreshAccess();
      final includePrivate = cache.privateAllowed;
      progress.add('Downloading Drug Library and infusion references…');
      final meds = await medications(force: true);
      await blood(force: true);
      progress.add('Downloading Quick References…');
      final quick = await quickCatalog(force: true);
      final quickBodies = await fetchRows(
        'quick_reference_sections',
        'id,body,version',
        'id',
      );
      for (final row in quickBodies) {
        await cache.save('quick:${row['id']}', row);
      }
      if (quick.any((r) => !quickBodies.any((b) => b['id'] == r['id']))) {
        throw StateError('A Quick Reference body was unavailable. Try again.');
      }
      checkOwner();
      progress.add('Downloading published Crisis Hub references…');
      final crises = await crisisCatalog(force: true);
      final freeCrises = crises
          .where(
            (r) => r['is_free'] == true && r['release_status'] == 'published',
          )
          .map((r) => r['slug'])
          .toSet();
      final publishedCrises = crises
          .where((r) => r['release_status'] == 'published')
          .map((r) => r['slug'])
          .toSet();
      final crisisRows = await fetchRows(
        'crisis_protocols',
        'slug,content',
        'slug',
      );
      for (final row in crisisRows) {
        checkOwner();
        if (!publishedCrises.contains(row['slug'])) continue;
        await cache.save(
          'crisis:${row['slug']}',
          row,
          private: !freeCrises.contains(row['slug']),
        );
      }
      if (freeCrises.any((slug) => !crisisRows.any((r) => r['slug'] == slug))) {
        throw StateError(
          'Some free Crisis references were unavailable. Try again.',
        );
      }
      progress.add('Downloading Pathophysiology references…');
      final patho = await pathoCatalog(force: true);
      final publishedPatho = patho
          .where((r) => r['review_status'] == 'published')
          .map((r) => r['slug'])
          .toSet();
      final freePatho = patho
          .where(
            (r) =>
                r['is_guest_preview'] == true &&
                r['review_status'] == 'published',
          )
          .map((r) => r['slug'])
          .toSet();
      final pathoRows = await fetchRows(
        'special_considerations',
        'slug,subtitle,content,citations,crisis_hub_links',
        'slug',
      );
      for (final row in pathoRows) {
        checkOwner();
        if (!publishedPatho.contains(row['slug'])) continue;
        await cache.save(
          'patho:${row['slug']}',
          row,
          private: !freePatho.contains(row['slug']),
        );
      }
      if (freePatho.any((slug) => !pathoRows.any((r) => r['slug'] == slug))) {
        throw StateError(
          'Some free Pathophysiology references were unavailable. Try again.',
        );
      }
      if (includePrivate) {
        if (publishedPatho.any(
              (slug) => !pathoRows.any((r) => r['slug'] == slug),
            ) ||
            publishedCrises.any(
              (slug) => !crisisRows.any((r) => r['slug'] == slug),
            )) {
          throw StateError(
            'Some subscribed references were unavailable. Try again.',
          );
        }
        progress.add('Downloading subscribed Deep Dives…');
        final deep = await fetchRows(
          'special_consideration_deep_dives',
          'slug,body',
          'slug',
          publishedColumn: 'review_status',
        );
        for (final row in deep) {
          checkOwner();
          if (!publishedPatho.contains(row['slug'])) continue;
          await cache.save('patho_deep:${row['slug']}', row, private: true);
        }
        // No public bulk projection of medication Deep Dives. Use the existing
        // server-authorized RPC for each medication, with bounded batches.
        for (var i = 0; i < meds.length; i += 4) {
          checkOwner();
          progress.add('Deep Dives: ${i + 1} of ${meds.length}…');
          final results = await Future.wait(
            meds
                .skip(i)
                .take(4)
                .map((r) => medicationDeepDive(r['id'] as String, force: true)),
          );
          if (results.any((r) => r['allowed'] != true) ||
              !cache.privateAllowed) {
            throw StateError('Paid access changed. Reconnect and try again.');
          }
        }
      }
      checkOwner();
      if (includePrivate && !cache.privateAllowed) {
        throw StateError(
          'Paid offline access expired. Reconnect and try again.',
        );
      }
      if (cache.writeFailure != null) throw StateError(cache.writeFailure!);
      final message = cache.privateAllowed
          ? 'Free and subscribed references downloaded.'
          : 'Free references downloaded. Protected offline downloads require '
                'active access in the installed iOS or Android app.';
      await cache.save('download_complete', {
        'message': message,
        'saved_at': cache.clock().toUtc().toIso8601String(),
      });
      return message;
    } finally {
      cache.strictWrites = false;
      downloading = false;
      progress.add('Download ended.');
    }
  }
}
