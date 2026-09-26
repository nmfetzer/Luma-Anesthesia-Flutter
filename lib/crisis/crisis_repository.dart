import 'package:supabase_flutter/supabase_flutter.dart';

const crisisCategories = {
  'resuscitation': 'ACLS/PALS/BLS',
  'neurological': 'Neurological',
  'cardiac': 'Cardiac/Circulation',
  'airway': 'Airway & Ventilation',
  'toxicity': 'Allergy/Toxicity/Reactions',
  'regional': 'Regional',
  'metabolic': 'Metabolic & Endocrine',
  'ob': 'OB Emergencies',
  'pediatric': 'Pediatric Emergencies',
  'mental': 'Mental Emergencies (for Healthcare Providers)',
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
  Stream<void> get authChanges => client.auth.onAuthStateChange.map((_) {});
  @override
  Future<List<CrisisEntry>> catalog() async {
    final result = <CrisisEntry>[];
    for (var offset = 0;; offset += 200) {
      final rows = await client
          .from('crisis_catalog')
          .select('slug,title,category,search_terms,is_free,release_status')
          .order('sort_order')
          .order('title')
          .order('slug')
          .range(offset, offset + 199)
          .timeout(const Duration(seconds: 15));
      result.addAll(rows.map(CrisisEntry.fromJson));
      if (rows.length < 200) return result;
    }
  }

  @override
  Future<Map<String, dynamic>?> detail(String slug) async {
    // RLS, not the widget, decides whether this caller can read clinical prose.
    // No persistent cache: signing out immediately removes reviewer content.
    if (client.auth.currentUser != null &&
        !client.auth.currentUser!.isAnonymous) {
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
    }
    final row = await client
        .from('crisis_protocols')
        .select('content')
        .eq('slug', slug)
        .maybeSingle()
        .timeout(const Duration(seconds: 15));
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
    final reviewer = await client
        .rpc('is_crisis_reviewer')
        .timeout(const Duration(seconds: 15));
    final premium = await client
        .rpc('has_clinical_premium_access')
        .timeout(const Duration(seconds: 15));
    return CrisisAccess(reviewer: reviewer == true, premium: premium == true);
  }
}
