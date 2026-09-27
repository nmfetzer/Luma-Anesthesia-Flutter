import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CeRepository {
  bool get isDemo => false;
  bool get signedIn;
  String? get accountId => null;
  Stream<String?> get accountChanges => const Stream.empty();
  Future<Map<String, dynamic>> call(
    String action, [
    Map<String, dynamic> payload = const {},
  ]);
}

class SupabaseCeRepository extends CeRepository {
  SupabaseClient get client => Supabase.instance.client;
  @override
  String? get accountId => client.auth.currentUser?.id;
  @override
  bool get signedIn =>
      client.auth.currentUser != null && !client.auth.currentUser!.isAnonymous;
  @override
  Stream<String?> get accountChanges => client.auth.onAuthStateChange
      .map((event) => event.session?.user.id)
      .distinct();

  @override
  Future<Map<String, dynamic>> call(
    String action, [
    Map<String, dynamic> payload = const {},
  ]) async {
    try {
      final result = action == 'certificate'
          ? await client.rpc(
              'ce_course1_certificate',
              params: {'p_action': payload['action'] ?? 'status'},
            )
          : action == 'records'
          ? await client.rpc(
              'ce_course1_records',
              params: {
                'p_month': payload['month'],
                'p_include_preview': payload['include_preview'] ?? false,
                'p_offset': payload['offset'] ?? 0,
              },
            )
          : await client.rpc(
              'ce_course1',
              params: {'p_action': action, 'p_payload': payload},
            );
      return Map<String, dynamic>.from(result as Map);
    } on PostgrestException catch (error) {
      throw Exception(error.message);
    }
  }
}
