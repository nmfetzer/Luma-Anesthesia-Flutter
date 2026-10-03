import 'package:flutter/material.dart';

import '../theme/luma_theme.dart';
import '../widgets/clinical_source_link.dart';
import '../widgets/luma_home_button.dart';
import 'practice_guideline.dart';
import 'practice_guideline_repository.dart';

const _navy = Color(0xFF0F2A3D);
const _gold = Color(0xFFE6CF9C);

class PracticeGuidelinesScreen extends StatefulWidget {
  const PracticeGuidelinesScreen({
    super.key,
    this.repository,
    this.initialQuery = '',
  });
  final PracticeGuidelineRepository? repository;
  final String initialQuery;

  @override
  State<PracticeGuidelinesScreen> createState() =>
      _PracticeGuidelinesScreenState();
}

class _PracticeGuidelinesScreenState extends State<PracticeGuidelinesScreen> {
  late final _repository = widget.repository ?? PracticeGuidelineRepository();
  late final _search = TextEditingController(text: widget.initialQuery);
  List<PracticeGuideline>? _items;
  String _organization = 'All';
  String? _category;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _repository.bundled();
      if (!mounted) return;
      setState(() {
        _items = items;
        _error = false;
      });
      final updated = await _repository.refresh(items);
      if (mounted && updated != null) setState(() => _items = updated);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final organizations = (_items ?? [])
        .where(
          (item) =>
              _organization == 'All' || item.organization == _organization,
        )
        .toList();
    final categories = organizations.map((r) => r.category).toSet().toList()
      ..sort();
    final filtered = organizations
        .where(
          (r) =>
              (_category == null || r.category == _category) &&
              r.matches(_search.text),
        )
        .toList();
    return Scaffold(
      backgroundColor: LumaColors.cream,
      appBar: AppBar(
        title: const Text(
          'Practice Guidelines',
          style: TextStyle(fontSize: 18),
        ),
        actions: const [LumaHomeButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _navy,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Guidance, at the source.',
                                style: TextStyle(
                                  fontFamily: 'Fraunces',
                                  fontSize: 26,
                                  color: _gold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'ASA, AANA & CAA resources in one place.',
                                style: TextStyle(
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Browse the directory offline. Open publisher documents online.',
                                style: TextStyle(
                                  color: Color(0xFFD4DEE4),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _search,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Search practice resources',
                            hintText: 'Airway, monitoring, ethics…',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _search.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    icon: const Icon(Icons.close),
                                    onPressed: () =>
                                        setState(() => _search.clear()),
                                  ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: ['All', 'ASA', 'AANA', 'CAA']
                              .map(
                                (org) => ChoiceChip(
                                  label: Text(org),
                                  selectedColor: _gold,
                                  selected: _organization == org,
                                  onSelected: (_) => setState(() {
                                    _organization = org;
                                    _category = null;
                                  }),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        Text(switch (_organization) {
                          'ASA' => 'American Society of Anesthesiologists',
                          'AANA' =>
                            'American Association of Nurse Anesthesiology',
                          'CAA' => 'Certified Anesthesiologist Assistant resources from AAAA, NCCAA, ARC-AA and ASA.',
                          _ => 'Standards, guidelines, advisories & professional resources',
                        }, style: const TextStyle(height: 1.5)),
                        if (categories.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            key: ValueKey(_organization),
                            initialValue: _category ?? '',
                            isExpanded: true,
                            itemHeight: null,
                            decoration: const InputDecoration(
                              labelText: 'Document category',
                            ),
                            selectedItemBuilder: (_) =>
                                ['All categories', ...categories]
                                    .map(
                                      (label) => Text(
                                        label,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                    .toList(),
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('All categories'),
                              ),
                              ...categories.map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: Text(category),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) => setState(
                              () => _category = value == '' ? null : value,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (_error)
                  SliverToBoxAdapter(
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() => _error = false);
                          _load();
                        },
                        child: const Text(
                          'Could not load directory. Try again.',
                        ),
                      ),
                    ),
                  )
                else if (_items == null)
                  const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (filtered.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No matching references. Try another term or choose All categories.',
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            margin: EdgeInsets.zero,
                            color: LumaColors.creamElevated,
                            surfaceTintColor: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PracticeGuidelineDetail(item: item),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.publisher} · ${item.category}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: LumaColors.inkSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${item.linkLabel} ↗',
                                      style: const TextStyle(
                                        color: _navy,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Independent reference directory. Luma is not affiliated with or endorsed by these organizations. '
                      'Consult the publisher for the current version and access requirements.',
                      style: TextStyle(
                        fontSize: 13,
                        color: LumaColors.inkSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PracticeGuidelineDetail extends StatelessWidget {
  const PracticeGuidelineDetail({super.key, required this.item});
  final PracticeGuideline item;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Reference'),
      actions: const [LumaHomeButton()],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                item.publisher,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(
                  fontFamily: 'Fraunces',
                  fontSize: 28,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),
              Text(item.category),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ClinicalSourceLink.open(context, item.url),
                icon: const Icon(Icons.open_in_new),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(item.linkLabel),
                ),
              ),
              const SizedBox(height: 10),
              ClinicalSourceLink(
                url: item.url,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    item.url,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (item.linkKind == 'search') ...[
                const _Bullet(
                  'This entry opens the publisher’s search results, not a specific document. Select the matching title and confirm its publication or revision date.',
                ),
              ],
              const _Bullet(
                'Internet access is needed to open the publisher’s page or PDF. Some resources may require membership, sign-in or payment to the publisher.',
              ),
              const _Bullet(
                'The reference directory is stored in the app; full publisher documents are not included in the offline download.',
              ),
              const _Bullet(
                'Check the current revision, patient population and applicability before use. Archived or superseded documents may remain on publisher websites.',
              ),
              const _Bullet(
                'Position statements and certification requirements are not interchangeable with clinical practice guidelines. Scope of practice and privileges depend on applicable law and institutional policy.',
              ),
              const _Bullet(
                'These resources support, not replace, clinical judgment and institutional protocols. Document content belongs to its publisher.',
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => ClinicalSourceLink.open(context, item.hubUrl),
                icon: const Icon(Icons.open_in_new),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Browse publisher directory'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  ', style: TextStyle(height: 1.5)),
        Expanded(child: Text(text, style: const TextStyle(height: 1.5))),
      ],
    ),
  );
}
