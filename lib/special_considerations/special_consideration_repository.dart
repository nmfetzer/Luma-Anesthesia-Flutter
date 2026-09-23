import 'package:supabase_flutter/supabase_flutter.dart';
import 'special_consideration.dart';

abstract class SpecialConsiderationDataSource {
  Future<List<SpecialConsiderationEntry>> catalog();
  Future<SpecialConsiderationDetail?> detail(String slug);
  Future<String?> deepDive(String slug);
  bool get hasAccount;
  Stream<void> get authChanges;
}

class SupabaseSpecialConsiderationRepository
    implements SpecialConsiderationDataSource {
  SupabaseSpecialConsiderationRepository(this.client);
  final SupabaseClient client;

  @override
  bool get hasAccount =>
      client.auth.currentUser != null && !client.auth.currentUser!.isAnonymous;

  @override
  Stream<void> get authChanges => client.auth.onAuthStateChange.map((_) {});

  @override
  Future<List<SpecialConsiderationEntry>> catalog() async {
    // Explicit pagination avoids the default Supabase row limit as this grows.
    final result = <SpecialConsiderationEntry>[];
    const pageSize = 200;
    for (var offset = 0;; offset += pageSize) {
      final rows = await client
          .from('special_consideration_catalog')
          .select('slug,title,category,search_tags,review_status,'
              'is_guest_preview,reviewed_at,reviewed_by')
          .order('category', ascending: true)
          .order('title', ascending: true)
          .order('slug', ascending: true)
          .range(offset, offset + pageSize - 1);
      result.addAll(rows.map(SpecialConsiderationEntry.fromJson));
      if (rows.length < pageSize) return result;
    }
  }

  @override
  Future<SpecialConsiderationDetail?> detail(String slug) async {
    final row = await client
        .from('special_considerations')
        .select('subtitle,content,citations,crisis_hub_links')
        .eq('slug', slug)
        .maybeSingle();
    return row == null ? null : SpecialConsiderationDetail.fromJson(row);
  }

  @override
  Future<String?> deepDive(String slug) async {
    // Separate request and table: premium prose is never sent in the catalog
    // or basic detail payload and is not cached on the device.
    final row = await client
        .from('special_consideration_deep_dives')
        .select('body')
        .eq('slug', slug)
        .maybeSingle();
    return row?['body'] as String?;
  }
}
