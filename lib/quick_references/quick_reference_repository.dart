import 'package:supabase_flutter/supabase_flutter.dart';

/// Ignore spaces/punctuation so GLP1, GLP-1 and GLP 1 resolve identically.
String normalizeReferenceQuery(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

// Deliberately curated, not edit-distance matching: never guess drug names,
// doses, device models, or discard clinically meaningful "no"/"not".
const _searchFillers = {
  'a',
  'an',
  'and',
  'the',
  'with',
  'for',
  'in',
  'on',
  'of',
  'to',
  'is',
  'are',
  'does',
  'do',
  'can',
  'i',
  'use',
  'using',
  'patient',
  'patients',
  'have',
  'has',
};
const _searchAliases = {
  'aicd': 'icd',
  'aicds': 'icd',
  'icds': 'icd',
  'defibrillator': 'icd',
  'defibrillators': 'icd',
  'pacemakers': 'pacemaker',
  'pacer': 'pacemaker',
  'pacers': 'pacemaker',
  'ppm': 'pacemaker',
  'bovie': 'cautery',
  'electrocautery': 'cautery',
  'electrocuatery': 'cautery',
  'electrocautary': 'cautery',
  'electrosurgery': 'cautery',
  'electrosurgical': 'cautery',
  'magnets': 'magnet',
};

List<String> _referenceTokens(String value) => value
    .toLowerCase()
    .split(RegExp(r'[^a-z0-9]+'))
    .where((word) => word.isNotEmpty && !_searchFillers.contains(word))
    .map((word) => _searchAliases[word] ?? word)
    .toList();

class QuickReferenceSection {
  const QuickReferenceSection({
    required this.id,
    required this.referenceId,
    required this.referenceTitle,
    required this.title,
    this.keywords = const [],
  });

  final String id;
  final String referenceId;
  final String referenceTitle;
  final String title;
  final List<String> keywords;

  factory QuickReferenceSection.fromJson(Map<String, dynamic> json) =>
      QuickReferenceSection(
        id: json['id'] as String,
        referenceId: json['reference_id'] as String,
        referenceTitle: json['reference_title'] as String,
        title: json['title'] as String,
        keywords: List<String>.from(json['keywords'] as List? ?? const []),
      );

  bool matches(String query) {
    final normalized = normalizeReferenceQuery(query);
    if (normalized.isEmpty) return true;
    final tokens = _referenceTokens(query);
    if (tokens.isEmpty) return false;
    final fields = [title, referenceTitle, ...keywords];
    if (fields
        .any((field) => normalizeReferenceQuery(field).contains(normalized))) {
      return true;
    }
    final fieldTokens = fields.expand(_referenceTokens).toSet();
    return tokens.every(
      (token) => fieldTokens.any(
        (word) =>
            word == token || (token.length >= 3 && word.startsWith(token)),
      ),
    );
  }
}

class QuickReferenceContent {
  const QuickReferenceContent({required this.body, required this.version});
  final String body;
  final String version;
}

abstract class QuickReferenceDataSource {
  Future<List<QuickReferenceSection>> catalog();

  /// Null means unavailable under the current user's RLS permissions.
  Future<QuickReferenceContent?> content(String id);
  Stream<void> get authChanges;
}

class SupabaseQuickReferenceRepository implements QuickReferenceDataSource {
  SupabaseQuickReferenceRepository(this.client);
  final SupabaseClient client;

  @override
  Stream<void> get authChanges => client.auth.onAuthStateChange.map((_) {});

  @override
  Future<List<QuickReferenceSection>> catalog() async {
    final entries = <QuickReferenceSection>[];
    const pageSize = 200;
    for (var offset = 0;; offset += pageSize) {
      final rows = await client
          .from('quick_reference_catalog')
          .select('id,reference_id,reference_title,title,keywords')
          .order('reference_id', ascending: true)
          .order('sort_order', ascending: true)
          .order('id', ascending: true)
          .range(offset, offset + pageSize - 1)
          .timeout(const Duration(seconds: 15));
      entries.addAll(rows.map(QuickReferenceSection.fromJson));
      if (rows.length < pageSize) break;
    }
    return entries;
  }

  @override
  Future<QuickReferenceContent?> content(String id) async {
    final row = await client
        .from('quick_reference_sections')
        .select('body,version')
        .eq('id', id)
        .maybeSingle()
        .timeout(const Duration(seconds: 15));
    if (row == null) return null;
    return QuickReferenceContent(
      body: row['body'] as String,
      version: row['version'] as String,
    );
  }
}
