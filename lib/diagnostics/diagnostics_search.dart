import 'abg_content.dart';
import 'clinical_modules.dart';
import 'diagnostics_content.dart';

/// Local index derived from the same content the reference screens display.
/// Results expose titles/categories only; routes still pass through the
/// Diagnostics entitlement boundary before showing clinical content.
class DiagnosticsSearchResult {
  const DiagnosticsSearchResult({
    required this.sectionId,
    required this.topicId,
    required this.title,
    required this.category,
    required this.keywords,
  });

  final String sectionId, topicId, title, category, keywords;

  String get route => Uri(
    path: '/diagnostics/$sectionId',
    queryParameters: {'topic': topicId},
  ).toString();
}

String _normalize(String text) => text
    .toLowerCase()
    .replaceAll('₀', '0')
    .replaceAll('₁', '1')
    .replaceAll('₂', '2')
    .replaceAll('₃', '3')
    .replaceAll('₄', '4')
    .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
    .trim();

DiagnosticsSearchResult _topic(
  String sectionId,
  String category,
  AbgTopic t,
) => DiagnosticsSearchResult(
  sectionId: sectionId,
  topicId: t.id,
  title: t.title,
  category: category,
  keywords:
      '${t.group} ${t.summary} ${t.aliases} '
      '${t.sections.map((s) => '${s.title} ${s.bullets.join(' ')}').join(' ')} '
      '${t.differential.map((d) => '${d.process} ${d.clues} ${d.focus}').join(' ')}',
);

final diagnosticsSearchIndex = List<DiagnosticsSearchResult>.unmodifiable([
  for (final lab in labReferences)
    DiagnosticsSearchResult(
      sectionId: 'labs',
      topicId: lab.id,
      title: lab.title,
      category: 'Lab Values',
      keywords:
          '${lab.group} ${lab.aliases} ${lab.bullets.join(' ')} '
          '${lab.clinicalSections.map((s) => '${s.title} ${s.bullets.join(' ')}').join(' ')}',
    ),
  for (final topic in abgTopics) _topic('abg', 'ABG & Acid–Base', topic),
  const DiagnosticsSearchResult(
    sectionId: 'abg',
    topicId: 'formulas',
    title: 'Formulas & compensation',
    category: 'ABG & Acid–Base',
    keywords:
        'Winter Winters formula anion gap delta gap metabolic respiratory '
        'acidosis alkalosis bicarbonate HCO3 PaCO2 compensation',
  ),
  for (final module in clinicalModules)
    for (final topic in module.topics) _topic(module.id, module.title, topic),
]);

// Normalize once rather than repeatedly scanning/normalizing the clinical
// library on every keystroke. No network or account is needed to find a title.
final _searchTokens = {
  for (final item in diagnosticsSearchIndex)
    item: _normalize('${item.title} ${item.category} ${item.keywords}')
        .split(RegExp(r'\s+'))
        .toSet(),
};

List<DiagnosticsSearchResult> searchDiagnosticsTopics(String query) {
  final normalized = _normalize(query);
  if (normalized.isEmpty) return const [];
  final words = normalized.split(' ');
  bool matches(String text) {
    final tokens = _normalize(text).split(' ');
    return words.every((word) => tokens.any((token) => token.startsWith(word)));
  }

  int score(DiagnosticsSearchResult item) {
    final title = _normalize(item.title);
    if (title == normalized) return 0;
    if (words.every(title.split(' ').contains)) return 1;
    if (matches(item.title)) return 2;
    return 3;
  }

  final results = diagnosticsSearchIndex
      .where(
        (item) => words.every(
          (word) => _searchTokens[item]!.any((token) => token.startsWith(word)),
        ),
      )
      .toList();
  results.sort((a, b) {
    final rank = score(a).compareTo(score(b));
    return rank != 0 ? rank : a.title.compareTo(b.title);
  });
  return results;
}
