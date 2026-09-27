import 'package:supabase_flutter/supabase_flutter.dart';

import '../offline/offline_library.dart';

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
    if (fields.any(
      (field) => normalizeReferenceQuery(field).contains(normalized),
    )) {
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

  /// Published bodies are free for everyone; null means unavailable/unpublished.
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
    final rows = await OfflineLibrary(client).quickCatalog();
    return rows.map(QuickReferenceSection.fromJson).toList();
  }

  @override
  Future<QuickReferenceContent?> content(String id) async {
    final row = await OfflineLibrary(
      client,
    ).detail('quick:$id', 'quick_reference_sections', 'body,version', 'id', id);
    if (row == null) return null;
    return QuickReferenceContent(
      body: row['body'] as String,
      version: row['version'] as String,
    );
  }
}
