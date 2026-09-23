class SpecialConsiderationEntry {
  const SpecialConsiderationEntry({
    required this.slug,
    required this.title,
    required this.category,
    this.searchTags = const [],
    this.reviewStatus = 'needs_review',
    this.isGuestPreview = false,
    this.reviewedAt,
    this.reviewedBy,
  });

  final String slug;
  final String title;
  final String category;
  final List<String> searchTags;
  final String reviewStatus;
  final bool isGuestPreview;
  final String? reviewedAt;
  final String? reviewedBy;

  bool get isPublished => reviewStatus == 'published';
  bool matches(String query) => [title, category, ...searchTags]
      .join(' ')
      .toLowerCase()
      .contains(query.trim().toLowerCase());

  factory SpecialConsiderationEntry.fromJson(Map<String, dynamic> row) =>
      SpecialConsiderationEntry(
        slug: row['slug'] as String,
        title: row['title'] as String,
        category: row['category'] as String,
        searchTags: List<String>.from(row['search_tags'] as List? ?? []),
        reviewStatus: row['review_status'] as String? ?? 'needs_review',
        isGuestPreview: row['is_guest_preview'] == true,
        reviewedAt: row['reviewed_at'] as String?,
        reviewedBy: row['reviewed_by'] as String?,
      );
}

class SpecialConsiderationDetail {
  const SpecialConsiderationDetail({
    required this.subtitle,
    required this.sections,
    required this.citations,
    required this.crisisTopics,
  });
  final String subtitle;
  final Map<String, String> sections;
  final List<Map<String, String>> citations;
  final List<String> crisisTopics;

  factory SpecialConsiderationDetail.fromJson(Map<String, dynamic> row) =>
      SpecialConsiderationDetail(
        subtitle: row['subtitle'] as String? ?? '',
        sections: Map<String, String>.from(row['content'] as Map? ?? {}),
        citations: (row['citations'] as List? ?? [])
            .map((r) => Map<String, String>.from(r as Map))
            .toList(),
        crisisTopics: List<String>.from(row['crisis_hub_links'] as List? ?? []),
      );
}

const specialConsiderationSections = <String, String>{
  'snapshot': 'At a glance',
  'pathophysiology': 'Pathophysiology',
  'preop_considerations': 'Preoperative considerations',
  'airway_access_positioning': 'Airway, access & positioning',
  'intraop_management': 'Intraoperative management',
  'emergence_postop': 'Emergence & postoperative care',
  'what_could_go_wrong': 'Potential complications',
  'pearls': 'Clinical pearls',
};
