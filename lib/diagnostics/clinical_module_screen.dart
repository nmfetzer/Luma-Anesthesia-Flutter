import 'package:flutter/material.dart';

import '../theme/luma_theme.dart';
import '../widgets/luma_home_button.dart';
import 'abg_screen.dart';
import 'clinical_modules.dart';
import 'diagnostics_notice.dart';

class ClinicalModuleScreen extends StatefulWidget {
  const ClinicalModuleScreen({
    super.key,
    required this.module,
    this.showClinicalDraft = false,
    this.clinicalRelease = false,
    this.initialTopic,
  });
  final ClinicalModule module;
  final bool showClinicalDraft;
  final bool clinicalRelease;
  final String? initialTopic;

  @override
  State<ClinicalModuleScreen> createState() => _ClinicalModuleScreenState();
}

class _ClinicalModuleScreenState extends State<ClinicalModuleScreen> {
  final _search = TextEditingController();
  String _group = 'All';

  @override
  void initState() {
    super.initState();
    _search.text =
        widget.module.topics
            .where((topic) => topic.id == widget.initialTopic)
            .firstOrNull
            ?.title ??
        '';
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    final selected = module.topics
        .where((topic) => topic.id == widget.initialTopic)
        .firstOrNull;
    final topics = searchClinicalTopics(module, _search.text, group: _group)
        .where(
          (topic) =>
              selected == null ||
              _search.text != selected.title ||
              topic.id == selected.id,
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(module.title),
        actions: const [LumaHomeButton()],
      ),
      body: !widget.showClinicalDraft && !widget.clinicalRelease
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
                    DiagnosticsNotice(reviewPreview: widget.showClinicalDraft),
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
                          initiallyExpanded: topic.id == widget.initialTopic,
                          key: PageStorageKey(topic.id),
                          title: Text(topic.title),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text('${topic.group} · ${topic.summary}'),
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            16,
                          ),
                          children: [
                            if (topic.differential.isNotEmpty)
                              ClinicalDifferentialTable(
                                rows: topic.differential,
                                title: module.id == 'carotid'
                                    ? 'How much is the internal carotid artery narrowed?'
                                    : 'Differential at a glance',
                                processLabel: module.id == 'carotid'
                                    ? 'Degree of narrowing'
                                    : 'Process',
                                cluesLabel: module.id == 'carotid'
                                    ? 'Ultrasound findings'
                                    : 'Distinguishing context',
                                focusLabel: module.id == 'carotid'
                                    ? 'How to interpret this'
                                    : 'Evaluation / management focus',
                                introduction: module.id == 'carotid'
                                    ? 'These categories describe artery narrowing, not a percentage risk of stroke. Use the complete vascular-lab interpretation, not one velocity value alone. These criteria do not apply to carotid stents or arteries after surgery.'
                                    : null,
                              ),
                            for (final section in topic.sections)
                              ClinicalReferenceSection(section: section),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sources are linked within each section. Verify current guidance and apply clinical judgment and institutional protocols.',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
