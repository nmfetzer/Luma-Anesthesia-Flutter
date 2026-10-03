import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'practice_guideline.dart';

typedef GuidelineRemoteLoader = Future<List<dynamic>> Function();

class PracticeGuidelineRepository {
  PracticeGuidelineRepository({AssetBundle? bundle, this.remoteLoader})
    : bundle = bundle ?? rootBundle;
  final AssetBundle bundle;
  final GuidelineRemoteLoader? remoteLoader;

  static List<PracticeGuideline> parse(List<dynamic> rows) {
    final result = rows
        .map(
          (row) =>
              PracticeGuideline.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
    if (result.map((r) => r.id).toSet().length != result.length) {
      throw const FormatException('Duplicate practice reference');
    }
    result.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    return result;
  }

  Future<List<PracticeGuideline>> bundled() async => parse(
    jsonDecode(await bundle.loadString('assets/data/practice_guidelines.json'))
        as List<dynamic>,
  );

  /// No network wait on first render. Missing/unavailable migration is harmless.
  /// Empty, partial, or malformed remote imports cannot erase bundled references.
  Future<List<PracticeGuideline>?> refresh(
    List<PracticeGuideline> fallback,
  ) async {
    try {
      final rows =
          await (remoteLoader?.call() ??
                  Supabase.instance.client
                      .from('practice_guidelines')
                      .select(
                        'id,organization,publisher,title,category,url,hub_url,link_kind,keywords',
                      )
                      .limit(1000))
              .timeout(const Duration(seconds: 5));
      final remote = parse(rows);
      final ids = remote.map((r) => r.id).toSet();
      return fallback.every((r) => ids.contains(r.id)) ? remote : null;
    } catch (_) {
      return null;
    }
  }
}
