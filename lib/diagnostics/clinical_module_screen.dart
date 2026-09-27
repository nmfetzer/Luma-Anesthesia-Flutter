import 'package:flutter/material.dart';
import '../theme/luma_theme.dart';
import '../widgets/luma_home_button.dart';
import 'abg_screen.dart';
import 'clinical_modules.dart';

class ClinicalModuleScreen extends StatefulWidget {
  const ClinicalModuleScreen({
    super.key,
    required this.module,
    this.showClinicalDraft = false,
  });
  final ClinicalModule module;
  final bool showClinicalDraft;

  @override
  State<ClinicalModuleScreen> createState() => _ClinicalModuleScreenState();
}

class _ClinicalModuleScreenState extends State<ClinicalModuleScreen> {
  final _search = TextEditingController();
  String _group = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    final topics = searchClinicalTopics(module, _search.text, group: _group);
    return Scaffold(
      appBar:
          AppBar(title: Text(module.title), actions: const [LumaHomeButton()]),
      body: !widget.showClinicalDraft
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${module.title} is in preparation. Clinical draft content is not available in the released app.',
                ),
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: ListView(
                  key: PageStorageKey('module-${module.id}'),
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: LumaColors.haloGoldLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'REVIEW PREVIEW\nAdult perioperative reference. Draft content is not released for patient care. Follow clinical judgment and institutional protocols.',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(module.heading, style: lumaDisplay(size: 28)),
                    const SizedBox(height: 8),
                    Text(module.description),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Search ${module.title} references',
                        hintText: module.hint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                onPressed: () => setState(_search.clear),
                                icon: const Icon(Icons.close),
                              ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final group in module.groups)
                          ChoiceChip(
                            label: Text(group),
                            selected: _group == group,
                            onSelected: (_) => setState(() => _group = group),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${topics.length} of ${module.topics.length} reference cards',
                      style: const TextStyle(color: LumaColors.inkMuted),
                    ),
                    const SizedBox(height: 12),
                    if (topics.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'No matching references. Try a different term or reset the filters.',
                            ),
                            TextButton(
                              onPressed: () => setState(() {
                                _search.clear();
                                _group = 'All';
                              }),
                              child: const Text('Reset search and filters'),
                            ),
                          ],
                        ),
                      ),
                    for (final topic in topics)
                      Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: LumaColors.creamElevated,
                        child: ExpansionTile(
                          key: PageStorageKey(topic.id),
                          title: Text(topic.title),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text('${topic.group} · ${topic.summary}'),
                          ),
                          childrenPadding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          children: [
                            if (topic.differential.isNotEmpty)
                              ClinicalDifferentialTable(
                                rows: topic.differential,
                                title: module.id == 'carotid'
                                    ? 'Native internal carotid artery criteria'
                                    : 'Differential at a glance',
                              ),
                            for (final section in topic.sections)
                              ClinicalReferenceSection(section: section),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sources are linked within each section. Source checking is not a substitute for clinician review of this draft.',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
