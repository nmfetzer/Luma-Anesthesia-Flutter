import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';

import 'surgical_case.dart';
import 'abdominal_gi_groups.dart';
import 'drafts/laparoscopic_cholecystectomy.dart';

part 'surgical_index.dart';

class SurgicalCaseIndex {
  const SurgicalCaseIndex(
    this.id,
    this.title,
    this.category,
    this.aliases,
    this.keywords,
  );
  final String id, title, category, aliases, keywords;
  String get route => '/surgical-prep/$id';
}

// Cross-list canonical records without copying their clinical content.
final surgicalSpecialtyCrossListings = <String, Set<String>>{
  'ENT & shared airway': {'tracheostomy-placement'},
  'Endocrine': {
    'thyroidectomy',
    'transsphenoidal-pituitary-surgery-tsps-endoscopic',
    'craniopharyngioma-resection-adult',
    'whipple-procedure-pancreaticoduodenectomy',
  },
  for (final entry in surgicalAbdominalGiGroups.entries)
    entry.key: entry.value.values.expand((ids) => ids).toSet(),
};

String _normalize(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

// Token index is initialized only on the first case search, not on app startup.
final _tokens = {
  for (final item in surgicalIndex)
    item.id: _normalize('${item.title} ${item.aliases} ${item.keywords}')
        .split(' ')
        .toSet(),
};

List<SurgicalCaseIndex> searchSurgicalCases(
  String query, {
  String category = 'All',
}) {
  final q = _normalize(query);
  final words = q.split(' ');
  final results = surgicalIndex
      .where(
        (item) =>
            (category == 'All' ||
                item.category == category ||
                (surgicalSpecialtyCrossListings[category]?.contains(item.id) ??
                    false)) &&
            // Keep the canonical thyroid URL/content unchanged, but place its
            // specialty discovery in Endocrine, not the abdominal procedure list.
            !(category == 'General & abdominal' &&
                item.id == 'thyroidectomy') &&
            (q.isEmpty ||
                words.every(
                  (w) => _tokens[item.id]!.any((t) => t.startsWith(w)),
                )),
      )
      .toList();
  int rank(SurgicalCaseIndex c) {
    if (_normalize(c.title) == q) return 0;
    if (_normalize(c.title).contains(q)) return 1;
    if (_normalize(c.aliases).contains(q)) return 2;
    return 3;
  }

  results.sort((a, b) {
    final r = rank(a).compareTo(rank(b));
    return r == 0 ? a.title.compareTo(b.title) : r;
  });
  return results;
}

List<String> get surgicalCategories => [
  'All',
  ...(surgicalIndex.map((r) => r.category).toSet().toList()..sort()),
];

/// Bundled, offline reference text. Entitlement checks belong at every route.
class SurgicalCatalog {
  static Future<Map<String, SurgicalCaseReference>>? _pending;
  static Map<String, SurgicalCaseReference>? _loaded;
  static Future<Map<String, SurgicalCaseReference>> load() {
    if (_loaded != null) return SynchronousFuture(_loaded!);
    return _pending ??= _read().catchError((Object e) {
      _pending = null; // A storage error can be retried.
      throw e;
    });
  }

  static Future<Map<String, SurgicalCaseReference>> _read() async {
    final text = await rootBundle.loadString('assets/data/surgical_cases.json');
    final records = jsonDecode(text) as List<dynamic>;
    SurgicalSection section(Map<String, dynamic> s) => SurgicalSection(
      id: s['id'] as String,
      title: s['title'] as String,
      bullets: List<String>.from(s['bullets'] as List),
      sources: (s['sources'] as List)
          .map(
            (e) => SurgicalSource(
              label: e['label'] as String,
              url: e['url'] as String,
            ),
          )
          .toList(),
    );
    return _loaded = Map.unmodifiable({
      for (final dynamic r in records)
        r['id'] as String: SurgicalCaseReference(
          id: r['id'] as String,
          title: r['title'] as String,
          category: '${r['category']} · Clinical draft',
          aliases: List<String>.from(r['aliases'] as List),
          overview: section(Map<String, dynamic>.from(r['overview'] as Map)),
          sections: (r['sections'] as List)
              .map((e) => section(Map<String, dynamic>.from(e as Map)))
              .toList(),
        ),
      laparoscopicCholecystectomyDraft.id: laparoscopicCholecystectomyDraft,
    });
  }
}
