import 'package:supabase_flutter/supabase_flutter.dart';

import '../offline/offline_library.dart';
import '../offline/offline_cache.dart';

const crisisCategories = {
  'resuscitation': 'ACLS/PALS/BLS',
  'neurological': 'Neurological',
  'cardiac': 'Cardiac/Circulation',
  'airway': 'Airway & Ventilation',
  'toxicity': 'Allergy/Toxicity/Reactions',
  'regional': 'Regional',
  'metabolic': 'Metabolic & Endocrine',
  'ob': 'OB Emergencies',
  'mental': 'Mental Health & Recovery',
};

class CrisisEntry {
  const CrisisEntry({
    required this.slug,
    required this.title,
    required this.category,
    this.searchTerms = '',
    this.isFree = false,
    this.isPublished = false,
  });
  final String slug, title, category, searchTerms;
  final bool isFree, isPublished;
  factory CrisisEntry.fromJson(Map<String, dynamic> json) => CrisisEntry(
    slug: json['slug'] as String,
    title: json['title'] as String,
    category: json['category'] as String,
    searchTerms: json['search_terms'] as String? ?? '',
    isFree: json['is_free'] == true,
    isPublished: json['release_status'] == 'published',
  );
  String get categoryLabel => crisisCategories[category] ?? category;
  // Temporarily reserved for a future pediatric anesthesia pack.
  // Presentation-only: preserve database records and existing access rules.
  // Mental-health resources use the bundled, always-free support entry instead
  // of a second legacy reference tile.
  bool get isVisibleInHub => category != 'pediatric' && category != 'mental';
  bool matches(String query) {
    final text = '$title $searchTerms $categoryLabel'.toLowerCase();
    return query
        .toLowerCase()
        .trim()
        .split(RegExp(r'\s+'))
        .every(text.contains);
  }
}

class CrisisAccess {
  const CrisisAccess({this.reviewer = false, this.premium = false});
  final bool reviewer, premium;
}

abstract class CrisisDataSource {
  Future<List<CrisisEntry>> catalog();
  Future<Map<String, dynamic>?> detail(String slug);
  Future<CrisisAccess> access();
  Stream<void> get authChanges;
}

class SupabaseCrisisRepository implements CrisisDataSource {
  SupabaseCrisisRepository(this.client);
  final SupabaseClient client;
  @override
  Stream<void> get authChanges => OfflineLibrary.authChanges(client);
  @override
  Future<List<CrisisEntry>> catalog() async {
    final rows = await OfflineLibrary(client).crisisCatalog();
    return rows
        .map(CrisisEntry.fromJson)
        .where((entry) => entry.isVisibleInHub)
        .toList();
  }

  @override
  Future<Map<String, dynamic>?> detail(String slug) async {
    // RLS, not the widget, decides whether this caller can read clinical prose.
    // Reviewer drafts are online-only and are never persisted.
    if (client.auth.currentUser != null &&
        !client.auth.currentUser!.isAnonymous &&
        !OfflineCache.instance.networkUnavailable) {
      try {
        final draft = await client
            .from('crisis_reference_drafts')
            .select('content,revision')
            .eq('slug', slug)
            .maybeSingle()
            .timeout(const Duration(seconds: 15));
        if (draft != null) {
          return {
            ...Map<String, dynamic>.from(draft['content'] as Map),
            '_review_draft': true,
            '_revision': draft['revision'],
          };
        }
      } catch (error) {
        if (!OfflineCache.isConnectionError(error)) rethrow;
        OfflineCache.instance.networkUnavailable = true;
      }
    }
    final library = OfflineLibrary(client);
    final row = await library.detail(
      'crisis:$slug',
      'crisis_protocols',
      'content',
      'slug',
      slug,
      private: !await library.freeCrisis(slug),
    );
    return row == null
        ? null
        : Map<String, dynamic>.from(row['content'] as Map);
  }

  @override
  Future<CrisisAccess> access() async {
    if (client.auth.currentUser == null ||
        client.auth.currentUser!.isAnonymous) {
      return const CrisisAccess();
    }
    if (OfflineCache.instance.networkUnavailable) {
      return CrisisAccess(premium: await OfflineCache.instance.restoreLease());
    }
    try {
      final reviewer = await client
          .rpc('is_crisis_reviewer')
          .timeout(const Duration(seconds: 15));
      final premium = await client
          .rpc('has_clinical_premium_access')
          .timeout(const Duration(seconds: 15));
      return CrisisAccess(reviewer: reviewer == true, premium: premium == true);
    } catch (error) {
      if (!OfflineCache.isConnectionError(error)) rethrow;
      OfflineCache.instance.networkUnavailable = true;
      return CrisisAccess(premium: await OfflineCache.instance.restoreLease());
    }
  }
}
