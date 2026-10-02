import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef ReferenceJson = Map<String, dynamic>;

class DrugReferenceSnapshot {
  const DrugReferenceSnapshot(this.data, {this.savedOnly = false});
  final ReferenceJson data;
  final bool savedOnly;

  ReferenceJson source(String key) =>
      Map<String, dynamic>.from(data[key] as Map? ?? {});

  bool isStale(String key, {DateTime? now}) {
    final s = source(key);
    final checked = DateTime.tryParse(s['checked_at']?.toString() ?? '');
    return savedOnly ||
        s['refresh_failed'] == true ||
        checked == null ||
        (now ?? DateTime.now()).toUtc().difference(checked.toUtc()) >
            const Duration(hours: 24);
  }
}

abstract class DrugReferenceGateway {
  Future<DrugReferenceSnapshot?> saved(String id);
  Future<DrugReferenceSnapshot> refresh(String id);
}

class SupabaseDrugReferenceGateway implements DrugReferenceGateway {
  SupabaseDrugReferenceGateway._() : _fetchRemote = null;

  /// Injectable transport for testing the real cache/deduplication lifecycle.
  SupabaseDrugReferenceGateway.withTransport(this._fetchRemote);
  final Future<ReferenceJson> Function(String id)? _fetchRemote;
  static final instance = SupabaseDrugReferenceGateway._();
  final _pending = <String, Future<DrugReferenceSnapshot>>{};
  static String _key(String id) => 'luma_drug_reference_v1_$id';

  @override
  Future<DrugReferenceSnapshot?> saved(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 2),
      );
      final raw = prefs.getString(_key(id));
      if (raw == null) return null;
      final data = jsonDecode(raw) as ReferenceJson;
      if (data['schema'] != 1) return null;
      return DrugReferenceSnapshot(data, savedOnly: true);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DrugReferenceSnapshot> refresh(String id) =>
      _pending[id] ??= _fetch(id).whenComplete(() {
        // Do not return remove(): its value is this same in-flight Future,
        // and whenComplete would wait forever on itself.
        _pending.remove(id);
      });

  Future<DrugReferenceSnapshot> _fetch(String id) async {
    final ReferenceJson data;
    if (_fetchRemote != null) {
      data = await _fetchRemote(id);
    } else {
      final response = await Supabase.instance.client.functions
          .invoke('drug-reference-updates', body: {'medication_id': id})
          .timeout(const Duration(seconds: 30));
      if (response.status != 200) {
        throw StateError('Reference updates unavailable');
      }
      data = Map<String, dynamic>.from(response.data as Map);
    }
    if (data['schema'] != 1) {
      throw StateError('Reference updates unavailable');
    }
    // A partial provider failure must not erase a previously saved good source.
    final previous = await saved(id);
    for (final key in ['fda', 'dailymed']) {
      if ((data[key] as Map?)?['state'] != 'ok' &&
          previous?.source(key)['state'] == 'ok') {
        data[key] = {...previous!.source(key), 'refresh_failed': true};
      }
    }
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 2),
      );
      await prefs
          .setString(_key(id), jsonEncode(data))
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      // Storage failure should not hide a successful online response.
    }
    return DrugReferenceSnapshot(data);
  }
}
