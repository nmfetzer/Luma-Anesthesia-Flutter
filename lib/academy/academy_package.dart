import 'dart:convert';

/// Private review bundles only. This model does not grant a store entitlement.
class AcademyPackage {
  AcademyPackage(Map<String, dynamic> input) : data = Map.unmodifiable(input) {
    if (id.isEmpty || title.isEmpty || data['schemaVersion'] != '1.0.0') {
      throw const FormatException('Unsupported Academy package');
    }
    if (lessons.isEmpty ||
        cards.isEmpty ||
        practice.isEmpty ||
        checkpoint.isEmpty) {
      throw const FormatException('Incomplete Academy package');
    }
    final ids = <String>{};
    for (final q in [...practice, ...checkpoint]) {
      final options = (q['options'] as List).cast<Map<String, dynamic>>();
      final keys = options.map((o) => o['id']).toSet();
      if (!ids.add(q['id'] as String) ||
          options.length != 4 ||
          keys.length != 4 ||
          !keys.contains(q['correctOptionId'])) {
        throw const FormatException('Invalid assessment');
      }
    }
  }
  final Map<String, dynamic> data;
  String get id => (data['levelId'] ?? data['id'] ?? '') as String;
  String get title => data['title'] as String;
  String get version => (data['version'] ?? data['contentVersion']) as String;
  List<Map<String, dynamic>> list(String key) =>
      (data[key] as List).cast<Map<String, dynamic>>();
  List<Map<String, dynamic>> get decks => list('decks');
  List<Map<String, dynamic>> get lessons => list('lessons');
  List<Map<String, dynamic>> get cards => list('flashcards');
  List<Map<String, dynamic>> get practice => list('practiceQuestions');
  List<Map<String, dynamic>> get checkpoint =>
      ((data['masteryCheckpoint'] as Map)['items'] as List)
          .cast<Map<String, dynamic>>();
  int get proposedMinimum => (checkpoint.length * .9).ceil();
  String get progressKey => '$id@$version';
}

/// Device-local owner-review progress, version scoped and deliberately separate
/// from any future server-verified paid Academy progression.
class AcademyReviewProgress {
  AcademyReviewProgress([Map<String, dynamic>? value])
    : data = value ?? <String, dynamic>{};
  factory AcademyReviewProgress.decode(String? raw) {
    try {
      final value = jsonDecode(raw ?? '{}');
      return AcademyReviewProgress(Map<String, dynamic>.from(value as Map));
    } catch (_) {
      return AcademyReviewProgress();
    }
  }
  final Map<String, dynamic> data;
  Map<String, dynamic> _level(AcademyPackage p) {
    final value = data[p.progressKey];
    if (value is! Map<String, dynamic>) {
      data[p.progressKey] = <String, dynamic>{};
    }
    return data[p.progressKey] as Map<String, dynamic>;
  }

  Set<String> seen(AcademyPackage p, String kind) {
    final value = _level(p)[kind];
    return value is List ? value.whereType<String>().toSet() : <String>{};
  }

  void mark(AcademyPackage p, String kind, String id) {
    _level(p)[kind] = (seen(p, kind)..add(id)).toList();
  }

  int? best(AcademyPackage p, String kind) {
    final value = _level(p)['${kind}Best'];
    return value is int ? value : null;
  }

  void score(AcademyPackage p, String kind, int correct, int total) {
    if (correct < 0 || correct > total) throw ArgumentError('Invalid score');
    final level = _level(p);
    level['${kind}Best'] = correct > (best(p, kind) ?? -1)
        ? correct
        : best(p, kind);
    level['${kind}Last'] = correct;
    level['${kind}Total'] = total;
    level['${kind}Attempts'] =
        (level['${kind}Attempts'] is int
            ? level['${kind}Attempts'] as int
            : 0) +
        1;
  }

  bool reviewGoalMet(AcademyPackage p) =>
      p.lessons.every((l) => seen(p, 'lessons').contains(l['id'])) &&
      p.cards.every((c) => seen(p, 'cards').contains(c['id'])) &&
      (best(p, 'checkpoint') ?? -1) >= p.proposedMinimum;
  String encode() => jsonEncode(data);
}

/// Never use review results or a client-side boolean to unlock paid content.
abstract interface class AcademyEntitlementVerifier {
  Future<bool> hasServerVerifiedAcademyAccess(String accountId);
}

class AcademyPurchasesDisabled implements AcademyEntitlementVerifier {
  @override
  Future<bool> hasServerVerifiedAcademyAccess(String accountId) async => false;
}
