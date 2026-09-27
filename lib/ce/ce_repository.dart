import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CeRepository {
  int get courseNumber => 1;
  String get courseId => courseNumber == 2 ? '1047241' : '1047239';
  String get courseTitle => courseNumber == 2
      ? 'Uncommon but Catastrophic Anesthesia Events'
      : 'A Medication Review for the Experienced CRNA';
  int get moduleCount => courseNumber == 2 ? 10 : 11;
  String get pharmacologyCredits => courseNumber == 2 ? '10.50' : '17.50';
  String get painCredits => courseNumber == 2 ? '1.00' : '2.50';
  bool get isDemo => false;
  bool get signedIn;
  String? get accountId => null;
  Stream<String?> get accountChanges => const Stream.empty();
  Future<Uint8List> certificatePdf() async => throw UnsupportedError(
    'Official certificates are unavailable in preview.',
  );
  Future<Map<String, dynamic>> call(
    String action, [
    Map<String, dynamic> payload = const {},
  ]);
}

class SupabaseCeRepository extends CeRepository {
  SupabaseCeRepository({this.courseNumber = 1})
    : assert(courseNumber == 1 || courseNumber == 2);
  @override
  final int courseNumber;
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
  Future<Uint8List> certificatePdf() async {
    try {
      final response = await client.functions.invoke(
        'ce-course$courseNumber-certificate',
        body: {'action': 'download'},
      );
      final data = response.data;
      if (data is! Uint8List ||
          data.length < 5 ||
          String.fromCharCodes(data.take(5)) != '%PDF-') {
        throw Exception(
          'Your certificate could not be retrieved. Please retry.',
        );
      }
      return data;
    } on FunctionException {
      throw Exception(
        'Your saved certificate is temporarily unavailable. Please retry or contact info@cehalo.com.',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> call(
    String action, [
    Map<String, dynamic> payload = const {},
  ]) async {
    try {
      final result = action == 'certificate'
          ? await client.rpc(
              'ce_course${courseNumber}_certificate',
              params: {'p_action': payload['action'] ?? 'status'},
            )
          : action == 'certificate_records'
          ? await client.rpc(
              'ce_course${courseNumber}_certificate_records',
              params: {
                'p_month': payload['month'],
                'p_offset': payload['offset'] ?? 0,
              },
            )
          : action == 'records'
          ? await client.rpc(
              'ce_course${courseNumber}_records',
              params: {
                'p_month': payload['month'],
                'p_include_preview': payload['include_preview'] ?? false,
                'p_offset': payload['offset'] ?? 0,
              },
            )
          : await client.rpc(
              'ce_course$courseNumber',
              params: {'p_action': action, 'p_payload': payload},
            );
      return Map<String, dynamic>.from(result as Map);
    } on PostgrestException catch (error) {
      throw Exception(error.message);
    }
  }
}
