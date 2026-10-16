import 'dart:convert';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

typedef AcademyRpc = Future<dynamic> Function(
  String function,
  Map<String, dynamic> parameters,
);

/// Shared by native and web. Identity comes from the verified Supabase session,
/// never a caller-supplied account ID. No paid assets are bundled with the app.
class AcademyRepository {
  AcademyRepository(SupabaseClient client)
    : _rpc = ((name, params) => client.rpc(name, params: params)),
      _userId = (() => client.auth.currentUser?.id);
  AcademyRepository.test(this._rpc, this._userId);
  final AcademyRpc _rpc;
  final String? Function() _userId;
  String? get userId => _userId();

  Future<dynamic> _call(String name, [Map<String, dynamic>? args]) async {
    final owner = userId;
    if (owner == null) throw StateError('Sign in to use Academy');
    final value = await _rpc(name, args ?? {});
    if (owner != userId) throw StateError('Account changed; sign in again');
    return value;
  }

  Future<Map<String, dynamic>> catalog() async =>
      Map<String, dynamic>.from(await _call('academy_catalog') as Map);
  Future<Map<String, dynamic>> progress() async =>
      Map<String, dynamic>.from(await _call('academy_progress') as Map);
  Map<String, dynamic> _key(String id, String version) => {
    'p_level': id,
    'p_version': version,
  };
  Future<Map<String, dynamic>> level(String id, String version) async =>
      Map<String, dynamic>.from(
        await _call('academy_level', _key(id, version)) as Map,
      );
  Future<void> mark(String id, String version, String kind, String item) async {
    await _call('academy_mark', {
      ..._key(id, version),
      'p_kind': kind,
      'p_item': item,
    });
  }

  Future<Map<String, dynamic>> submit(
    String id,
    String version,
    String kind,
    String scope,
    String attempt,
    Map<String, String> answers,
  ) async => Map<String, dynamic>.from(
    await _call('academy_submit', {
      ..._key(id, version),
      'p_kind': kind,
      'p_scope': scope,
      'p_attempt': attempt,
      'p_answers': answers,
    }) as Map,
  );
  Future<Uint8List> document(String id, String version, String kind) async =>
      base64Decode(
        await _call('academy_document', {..._key(id, version), 'p_kind': kind})
            as String,
      );
}

class AcademyProgress {
  AcademyProgress(this.data);
  final Map<String, dynamic> data;
  Set<String> seen(String id, String version, String kind) =>
      (data['marks'] as List? ?? [])
          .whereType<Map>()
          .where(
            (m) =>
                m['levelId'] == id &&
                m['version'] == version &&
                m['kind'] == kind,
          )
          .map((m) => m['itemId'] as String)
          .toSet();
  Map? bestCheckpoint(String id, String version) {
    final attempts = (data['attempts'] as List? ?? [])
        .whereType<Map>()
        .where(
          (a) =>
              a['levelId'] == id &&
              a['version'] == version &&
              a['kind'] == 'checkpoint',
        )
        .toList();
    attempts.sort(
      (a, b) => (b['correct'] as int).compareTo(a['correct'] as int),
    );
    return attempts.isEmpty ? null : attempts.first;
  }
}
