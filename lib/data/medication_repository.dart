// -----------------------------------------------------------------------------
// MedicationRepository — single source the UI reads from.
//
// If Supabase is configured (see lib/config.dart), reads from the `medication`
// table. Otherwise falls back to the bundled sample JSON, so the app runs
// out-of-the-box while you get Supabase set up.
// -----------------------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../models/medication.dart';
import '../offline/offline_library.dart';

class MedicationRepository {
  MedicationRepository._();
  static final MedicationRepository instance = MedicationRepository._();

  List<Medication>? _cache;
  Future<List<Medication>>? _pending;

  Future<List<Medication>> all() {
    if (_cache != null) return Future.value(_cache!);
    return _pending ??= _load().whenComplete(() => _pending = null);
  }

  /// Warm only the public library after Home is shown. Shares the same in-flight
  /// request with search/browse; failures are retried when the library is opened.
  Future<void> warmUp() async {
    try {
      await all();
    } catch (_) {
      // Background work must not interrupt navigation or show a blocking error.
    }
  }

  Future<List<Medication>> _load() async {
    if (LumaConfig.supabaseConfigured) {
      final rows = await OfflineLibrary(Supabase.instance.client).medications();
      final medications = rows.map(Medication.fromJson).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      // Commit only a complete result, never a partial page after a failure.
      _cache = medications;
    } else {
      final raw = await rootBundle.loadString('assets/data/medications.json');
      final list = jsonDecode(raw) as List;
      _cache = list
          .map((r) => Medication.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    return _cache!;
  }

  /// Category name → medications, sorted A-Z by name.
  /// Includes drugs whose PRIMARY category matches, PLUS drugs cross-listed
  /// via secondary_categories (so, e.g., Norepinephrine appears in both
  /// 'Cardiac & Hemodynamics' and 'Emergency & Crisis drugs').
  Future<Map<String, List<Medication>>> byCategory() async {
    final meds = await all();
    final map = <String, List<Medication>>{};
    for (final m in meds) {
      map.putIfAbsent(m.category, () => []).add(m);
      for (final sc in m.secondaryCategories) {
        if (sc == m.category) continue; // avoid double-adding
        map.putIfAbsent(sc, () => []).add(m);
      }
    }
    for (final list in map.values) {
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return map;
  }

  /// All drugs matching a category (primary OR secondary).
  Future<List<Medication>> inCategory(String category) async {
    final meds = await all();
    final list = meds
        .where(
          (m) =>
              m.category == category ||
              m.secondaryCategories.contains(category),
        )
        .toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  void clearCache() => _cache = null;
}
