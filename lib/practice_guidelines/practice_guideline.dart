/// A publisher reference, not a locally reproduced clinical guideline.
class PracticeGuideline {
  const PracticeGuideline({
    required this.id,
    required this.organization,
    required this.publisher,
    required this.title,
    required this.category,
    required this.url,
    required this.hubUrl,
    required this.linkKind,
    this.keywords = '',
  });

  final String id, organization, publisher, title, category;
  final String url, hubUrl, linkKind, keywords;

  static const allowedHosts = {
    'www.asahq.org',
    'pubs.asahq.org',
    'doi.org',
    'www.aana.com',
    'www.anesthetist.org',
    'nccaa.org',
    'www.arc-aa.org',
  };

  static bool safeUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.scheme == 'https' &&
        allowedHosts.contains(uri.host) &&
        uri.userInfo.isEmpty &&
        !uri.hasPort;
  }

  factory PracticeGuideline.fromJson(Map<String, dynamic> row) {
    String field(String name) => row[name] is String ? row[name] as String : '';
    final item = PracticeGuideline(
      id: field('id'),
      organization: field('organization'),
      publisher: field('publisher'),
      title: field('title'),
      category: field('category'),
      url: field('url'),
      hubUrl: field('hub_url'),
      linkKind: field('link_kind'),
      keywords: field('keywords'),
    );
    if (item.id.isEmpty ||
        item.title.isEmpty ||
        item.category.isEmpty ||
        item.publisher.isEmpty ||
        !['ASA', 'AANA', 'CAA'].contains(item.organization) ||
        !['page', 'pdf', 'search'].contains(item.linkKind) ||
        !safeUrl(item.url) ||
        !safeUrl(item.hubUrl)) {
      throw const FormatException('Invalid practice reference');
    }
    return item;
  }

  String get linkLabel => switch (linkKind) {
    'search' => 'Search $publisher',
    'pdf' => 'Open publisher PDF',
    _ => 'Open publisher reference',
  };

  bool matches(String query) {
    final text = normalize(
      '$title $organization $publisher $category $keywords',
    );
    return normalize(query)
        .split(' ')
        .where((s) => s.isNotEmpty)
        .every(text.contains);
  }

  static String normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}
