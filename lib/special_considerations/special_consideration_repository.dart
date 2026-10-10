import 'package:supabase_flutter/supabase_flutter.dart';

import 'special_consideration.dart';
import '../offline/offline_library.dart';

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
  // Guests who subscribed without an account (Guideline 5.1.1(v)) qualify;
  // the server still decides access for every deep dive.
  bool get hasAccount => client.auth.currentUser != null;

  @override
  Stream<void> get authChanges => OfflineLibrary.authChanges(client);

  @override
  Future<List<SpecialConsiderationEntry>> catalog() async {
    final rows = await OfflineLibrary(client).pathoCatalog();
    return rows.map(SpecialConsiderationEntry.fromJson).toList();
  }

  @override
  Future<SpecialConsiderationDetail?> detail(String slug) async {
    final library = OfflineLibrary(client);
    final row = await library.detail(
      'patho:$slug',
      'special_considerations',
      'subtitle,content,citations,crisis_hub_links',
      'slug',
      slug,
      private: !await library.freePatho(slug),
    );
    return row == null ? null : SpecialConsiderationDetail.fromJson(row);
  }

  @override
  Future<String?> deepDive(String slug) async {
    final row = await OfflineLibrary(client).detail(
      'patho_deep:$slug',
      'special_consideration_deep_dives',
      'body',
      'slug',
      slug,
      private: true,
    );
    return row?['body'] as String?;
  }
}
