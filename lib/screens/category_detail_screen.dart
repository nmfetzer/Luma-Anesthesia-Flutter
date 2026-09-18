// -----------------------------------------------------------------------------
// CategoryDetailScreen — the "Sedatives & Hypnotics" style screen.
//
// Matches your Base44 pattern:
//   • Fraunces H1 title
//   • Mono "N drugs" subtitle
//   • In-category search
//   • Drugs grouped by A-Z letter headers
//   • Right-edge alphabet index rail (26 letters, muted if empty, tap to jump)
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../data/medication_repository.dart';
import '../models/medication.dart';
import '../theme/luma_theme.dart';
import 'drug_detail_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  /// Pass null for the "All Medications" view.
  final String? category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late Future<List<Medication>> _future;
  final _scroll = ScrollController();
  final _letterKeys = <String, GlobalKey>{};
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = widget.category == null
        ? MedicationRepository.instance.all()
        : MedicationRepository.instance.inCategory(widget.category!);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.category ?? 'All Medications';
    return Scaffold(
      backgroundColor: LumaColors.cream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Drug Category',
            style: lumaBody(size: 14, weight: FontWeight.w500)),
      ),
      body: FutureBuilder<List<Medication>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snap.data!;
          final filtered = _query.isEmpty
              ? all
              : all
                  .where((m) =>
                      m.name.toLowerCase().contains(_query.toLowerCase()) ||
                      (m.brandName?.toLowerCase().contains(_query.toLowerCase()) ??
                          false))
                  .toList();

          final grouped = <String, List<Medication>>{};
          for (final m in filtered) {
            final letter = m.name.substring(0, 1).toUpperCase();
            grouped.putIfAbsent(letter, () => []).add(m);
          }
          final activeLetters = grouped.keys.toSet();
          _letterKeys.clear();
          for (final l in activeLetters) {
            _letterKeys[l] = GlobalKey();
          }

          return Stack(
            children: [
              CustomScrollView(
                controller: _scroll,
                slivers: [
                  SliverToBoxAdapter(child: _Header(title: title, count: all.length)),
                  SliverToBoxAdapter(child: _SearchField(onChanged: (v) {
                    setState(() => _query = v);
                  })),
                  for (final letter in grouped.keys.toList()..sort())
                    SliverToBoxAdapter(
                      key: _letterKeys[letter],
                      child: _LetterGroup(
                        letter: letter,
                        meds: grouped[letter]!,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
              Positioned(
                right: 4,
                top: 140,
                bottom: 20,
                child: _AlphaRail(
                  activeLetters: activeLetters,
                  onTap: _jumpTo,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _jumpTo(String letter) {
    final key = _letterKeys[letter];
    if (key?.currentContext == null) return;
    Scrollable.ensureVisible(
      key!.currentContext!,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      alignment: 0.05,
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final int count;
  const _Header({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: lumaDisplay(size: 26, weight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('$count drugs',
              style: lumaMono(size: 13, color: LumaColors.inkMuted)),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: LumaColors.creamElevated,
          borderRadius: BorderRadius.circular(LumaRadius.full),
          border: Border.all(color: LumaColors.divider, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 17, color: LumaColors.inkMuted),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                style: lumaBody(size: 14),
                decoration: InputDecoration.collapsed(
                  hintText: 'Search in this category',
                  hintStyle: lumaBody(size: 14, color: LumaColors.inkMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LetterGroup extends StatelessWidget {
  final String letter;
  final List<Medication> meds;
  const _LetterGroup({required this.letter, required this.meds});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
          child: Text(letter,
              style: lumaMono(
                size: 12,
                weight: FontWeight.w500,
                color: LumaColors.inkMuted,
              )),
        ),
        for (final m in meds) _DrugRow(med: m),
      ],
    );
  }
}

class _DrugRow extends StatelessWidget {
  final Medication med;
  const _DrugRow({required this.med});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DrugDetailScreen(medication: med)),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 44, 12),
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
                if (med.classShort != null) ...[
                  const SizedBox(height: 3),
                  Text(med.classShort!,
                      style: lumaBody(size: 13, color: LumaColors.inkSecondary)),
                ],
              ],
            ),
          ),
          if (med.highAlert) _FlagChip('HA', LumaColors.highAlert),
          if (med.isScheduled) ...[
            const SizedBox(width: 6),
            _FlagChip(med.deaLabel, LumaColors.caution),
          ],
        ],
      ),
      ),
    );
  }
}

class _FlagChip extends StatelessWidget {
  final String label;
  final Color color;
  const _FlagChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: lumaMono(size: 10, weight: FontWeight.w600, color: color)),
    );
  }
}

class _AlphaRail extends StatelessWidget {
  final Set<String> activeLetters;
  final ValueChanged<String> onTap;
  const _AlphaRail({required this.activeLetters, required this.onTap});

  static const _letters = [
    'A','B','C','D','E','F','G','H','I','J','K','L','M',
    'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final l in _letters)
            Expanded(
              child: GestureDetector(
                onTap: activeLetters.contains(l) ? () => onTap(l) : null,
                child: Center(
                  child: Text(l,
                      style: lumaMono(
                        size: 10,
                        weight: FontWeight.w500,
                        color: activeLetters.contains(l)
                            ? LumaColors.haloGold
                            : LumaColors.inkMuted.withValues(alpha: 0.35),
                      )),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
