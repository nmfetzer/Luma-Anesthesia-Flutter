// -----------------------------------------------------------------------------
// DrugsCategoriesScreen — top-level drug library entry.
//
//   • Global app bar (menu, back, title, search, home, avatar)
//   • Live search bar — typing shows drug results with brand + category
//   • "Drugs" breadcrumb strip
//   • Custom category order (per Luma taxonomy) — NOT alphabetical
//   • Priority anesthesia categories rendered bold
//   • "All Medications" pinned at top
//   • Empty categories shown as headers with "coming soon" state
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../data/medication_repository.dart';
import '../models/medication.dart';
import '../theme/luma_theme.dart';
import '../widgets/luma_app_bar.dart';
import 'category_detail_screen.dart';
import 'drug_detail_screen.dart';

/// The canonical Luma category order (not alphabetical).
/// The first 12 are the priority anesthesia section (rendered bold).
/// The remaining are alphabetized support categories (regular weight).
const List<String> kLumaCategoryOrder = [
  // ── Priority anesthesia section (BOLD) ──────────────────────
  'Emergency & Crisis drugs',
  'Anesthetics-IV induction',
  'Analgesics & Pain control',
  'Anesthetics-Inhalation',
  'Anesthetics-Local & Regional',
  'Cardiac & Hemodynamics',
  'Neuromuscular Blockades',
  'Airway & Pulmonary Medications',
  'OB anesthesia',
  'Pediatric anesthesia',
  'Pre-op Medication Considerations',
  // ── Support section (alphabetical, regular weight) ───────────
  'Antibiotics & Antimicrobial',
  'Anticoagulation & Hematology',
  'Antidotes & Reversals',
  'Antiemetics & GI',
  'Antineoplastics/Chemotherapy',
  'Diagnostics & Dyes',
  'Electrolytes & Fluids',
  'Endocrine & Metabolic',
  'Immunosuppresants & Transplant',
  'Neurological Medications',
  'Psychiatric Medications',
  'Sedatives & Hypnotics',
];

/// Categories rendered bold in the list (first 11 = priority section).
const int kPrioritySectionCount = 11;

class DrugsCategoriesScreen extends StatefulWidget {
  const DrugsCategoriesScreen({super.key});

  @override
  State<DrugsCategoriesScreen> createState() => _DrugsCategoriesScreenState();
}

class _DrugsCategoriesScreenState extends State<DrugsCategoriesScreen> {
  late Future<_LibraryData> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _loadLibrary();
  }

  Future<_LibraryData> _loadLibrary() async {
    final repo = MedicationRepository.instance;
    final byCat = await repo.byCategory();
    final all = await repo.all();
    return _LibraryData(byCategory: byCat, allMeds: all);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LumaColors.cream,
      appBar: const LumaAppBar(title: 'Luma Anesthesia'),
      body: FutureBuilder<_LibraryData>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data!;
          final byCat = data.byCategory;
          final totalCount = data.allMeds.length;
          final isSearching = _query.trim().isNotEmpty;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _SearchField(
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SliverToBoxAdapter(child: _Breadcrumb()),

              if (isSearching)
                _buildSearchResults(data.allMeds)
              else
                _buildCategoryList(byCat, totalCount),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(List<Medication> allMeds) {
    final q = _query.trim().toLowerCase();
    final matches = allMeds.where((m) {
      if (m.name.toLowerCase().contains(q)) return true;
      if (m.brandName?.toLowerCase().contains(q) ?? false) return true;
      if (m.classShort?.toLowerCase().contains(q) ?? false) return true;
      return false;
    }).toList()
      ..sort((a, b) {
        // Prefer name matches at start
        final aStarts = a.name.toLowerCase().startsWith(q);
        final bStarts = b.name.toLowerCase().startsWith(q);
        if (aStarts != bStarts) return aStarts ? -1 : 1;
        return a.name.compareTo(b.name);
      });

    if (matches.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 40, color: LumaColors.inkMuted),
              const SizedBox(height: 12),
              Text('No matches for "$_query"',
                  style: lumaBody(size: 15, color: LumaColors.inkSecondary)),
              const SizedBox(height: 4),
              Text('Try a different name or brand',
                  style: lumaBody(size: 13, color: LumaColors.inkMuted)),
            ],
          ),
        ),
      );
    }

    return SliverList.builder(
      itemCount: matches.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              '${matches.length} match${matches.length == 1 ? "" : "es"}',
              style: lumaMono(size: 12, color: LumaColors.inkMuted),
            ),
          );
        }
        final med = matches[i - 1];
        return _SearchResultRow(med: med);
      },
    );
  }

  Widget _buildCategoryList(Map<String, List<Medication>> byCat, int totalCount) {
    // Build items in canonical order.
    final items = <_CategoryListItem>[];
    // "All Medications" first
    items.add(_CategoryListItem(
      title: 'All Medications',
      count: totalCount,
      isBold: true,
      onTap: () => _openAll(context),
    ));
    // Then the canonical list
    for (int i = 0; i < kLumaCategoryOrder.length; i++) {
      final name = kLumaCategoryOrder[i];
      final drugs = byCat[name] ?? [];
      final isBold = i < kPrioritySectionCount;
      items.add(_CategoryListItem(
        title: name,
        count: drugs.length,
        isBold: isBold,
        onTap: drugs.isEmpty
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CategoryDetailScreen(category: name),
                  ),
                ),
      ));
    }
    // Any drugs in categories NOT in the canonical list (safety net — should be empty)
    final orphanCats = byCat.keys
        .where((c) => !kLumaCategoryOrder.contains(c))
        .toList()
      ..sort();
    for (final name in orphanCats) {
      items.add(_CategoryListItem(
        title: name,
        count: byCat[name]!.length,
        isBold: false,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryDetailScreen(category: name),
          ),
        ),
      ));
    }

    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, i) => _CategoryRow(item: items[i]),
    );
  }

  void _openAll(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CategoryDetailScreen(category: null),
      ),
    );
  }
}

class _LibraryData {
  final Map<String, List<Medication>> byCategory;
  final List<Medication> allMeds;
  _LibraryData({required this.byCategory, required this.allMeds});
}

class _CategoryListItem {
  final String title;
  final int count;
  final bool isBold;
  final VoidCallback? onTap;
  _CategoryListItem({
    required this.title,
    required this.count,
    required this.isBold,
    required this.onTap,
  });
}

// -----------------------------------------------------------------------------
// Widgets
// -----------------------------------------------------------------------------

class _SearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: LumaColors.creamElevated,
          borderRadius: BorderRadius.circular(LumaRadius.full),
          border: Border.all(color: LumaColors.divider, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 18, color: LumaColors.inkMuted),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: widget.onChanged,
                style: lumaBody(size: 14),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration.collapsed(
                  hintText: 'Search medications, brands, drug classes…',
                  hintStyle: lumaBody(size: 14, color: LumaColors.inkMuted),
                ),
              ),
            ),
            if (_controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  widget.onChanged('');
                  setState(() {});
                },
                child: Icon(Icons.close, size: 16, color: LumaColors.inkMuted),
              ),
          ],
        ),
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: LumaColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.home_outlined, size: 15, color: LumaColors.inkMuted),
          const SizedBox(width: 6),
          Text('Drugs',
              style: lumaBody(size: 13, color: LumaColors.inkSecondary)),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final _CategoryListItem item;
  const _CategoryRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isEmpty = item.count == 0;
    return InkWell(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: LumaColors.divider, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: lumaDisplay(
                      size: 17,
                      weight: item.isBold ? FontWeight.w700 : FontWeight.w500,
                      color: isEmpty
                          ? LumaColors.inkMuted
                          : LumaColors.inkPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEmpty ? 'Coming soon' : '${item.count} drugs',
                    style: lumaMono(size: 12, color: LumaColors.inkMuted),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isEmpty
                  ? LumaColors.inkMuted.withValues(alpha: 0.4)
                  : LumaColors.inkMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultRow extends StatelessWidget {
  final Medication med;
  const _SearchResultRow({required this.med});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DrugDetailScreen(medication: med)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: LumaColors.divider, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: lumaDisplay(size: 16, weight: FontWeight.w600),
                      children: [
                        TextSpan(text: med.name),
                        if (med.brandName != null)
                          TextSpan(
                            text: '  (${med.brandName})',
                            style: lumaBody(
                              size: 13,
                              weight: FontWeight.w400,
                              color: LumaColors.inkMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    med.category,
                    style: lumaMono(size: 11, color: LumaColors.inkMuted),
                  ),
                ],
              ),
            ),
            if (med.highAlert)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: LumaColors.highAlert.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('HA',
                    style: lumaMono(
                        size: 10,
                        weight: FontWeight.w600,
                        color: LumaColors.highAlert)),
              ),
          ],
        ),
      ),
    );
  }
}
