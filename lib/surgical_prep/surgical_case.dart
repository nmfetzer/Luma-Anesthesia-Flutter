/// Structured case reference. No patient-specific calculation or checklist state.
class SurgicalSource {
  SurgicalSource({required this.label, required this.url}) {
    final uri = Uri.tryParse(url);
    if (label.trim().isEmpty ||
        uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty) {
      throw ArgumentError('A named HTTPS source is required.');
    }
  }

  final String label;
  final String url;
}

class SurgicalSection {
  SurgicalSection({
    required this.id,
    required this.title,
    required List<String> bullets,
    required List<SurgicalSource> sources,
  }) : bullets = List.unmodifiable(bullets),
       sources = List.unmodifiable(sources) {
    if (id.trim().isEmpty ||
        title.trim().isEmpty ||
        bullets.isEmpty ||
        bullets.any((b) => b.trim().isEmpty) ||
        sources.isEmpty) {
      throw ArgumentError(
        'Each section needs an ID, title, bullets and sources.',
      );
    }
  }

  final String id;
  final String title;
  final List<String> bullets;
  final List<SurgicalSource> sources;

  bool matches(String query) {
    final text = '$title ${bullets.join(' ')}'.toLowerCase();
    return query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .every(text.contains);
  }
}

class SurgicalCaseReference {
  SurgicalCaseReference({
    required this.id,
    required this.title,
    required this.category,
    required this.overview,
    required List<SurgicalSection> sections,
    List<String> aliases = const [],
  }) : sections = List.unmodifiable(sections),
       aliases = List.unmodifiable(aliases) {
    if (id.trim().isEmpty ||
        title.trim().isEmpty ||
        category.trim().isEmpty ||
        sections.isEmpty ||
        sections.map((s) => s.id).toSet().length != sections.length ||
        sections.any((s) => s.id == overview.id)) {
      throw ArgumentError(
        'A case needs metadata and uniquely identified details.',
      );
    }
  }

  final String id;
  final String title;
  final String category;
  final SurgicalSection overview;
  final List<SurgicalSection> sections;
  final List<String> aliases;
  String get route => '/surgical-prep/$id';
}
