// -----------------------------------------------------------------------------
// DrugsCategoriesScreen — the "Drug Category" list.
//
// Matches your Base44 pattern exactly:
//   • Global app bar (menu, back, title, search, home, avatar)
//   • Persistent search bar
//   • "Drugs" breadcrumb strip
//   • Full-width category rows (Fraunces title, mono count, chevron)
//   • 0.5px hairline dividers between rows
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../data/medication_repository.dart';
import '../models/medication.dart';
import '../theme/luma_theme.dart';
import '../widgets/luma_app_bar.dart';
import 'category_detail_screen.dart';

class DrugsCategoriesScreen extends StatefulWidget {
  const DrugsCategoriesScreen({super.key});

  @override
  State<DrugsCategoriesScreen> createState() => _DrugsCategoriesScreenState();
}

class _DrugsCategoriesScreenState extends State<DrugsCategoriesScreen> {
  late Future<Map<String, List<Medication>>> _future;

  @override
  void initState() {
    super.initState();
    _future = MedicationRepository.instance.byCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LumaColors.cream,
      appBar: const LumaAppBar(title: 'Luma Anesthesia'),
      body: FutureBuilder<Map<String, List<Medication>>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final byCat = snap.data!;
          final categories = byCat.keys.toList()..sort();
          final totalCount = byCat.values.fold<int>(0, (sum, l) => sum + l.length);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _SearchField()),
              const SliverToBoxAdapter(child: _Breadcrumb()),
              SliverList.builder(
                itemCount: categories.length + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return _CategoryRow(
                      title: 'All Medications',
                      count: totalCount,
                      onTap: () => _openAll(context),
                    );
                  }
                  final name = categories[i - 1];
                  return _CategoryRow(
                    title: name,
                    count: byCat[name]!.length,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CategoryDetailScreen(category: name),
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
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

class _SearchField extends StatelessWidget {
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
              child: Text(
                'Search drugs, protocols, cases…',
                style: lumaBody(size: 14, color: LumaColors.inkMuted),
              ),
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
          Text('Drugs', style: lumaBody(size: 13, color: LumaColors.inkSecondary)),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.title,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
                  Text(title, style: lumaDisplay(size: 17, weight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('$count drugs',
                      style: lumaMono(size: 12, color: LumaColors.inkMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: LumaColors.inkMuted),
          ],
        ),
      ),
    );
  }
}
