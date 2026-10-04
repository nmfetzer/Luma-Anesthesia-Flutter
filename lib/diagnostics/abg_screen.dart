import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/luma_theme.dart';
import '../widgets/luma_home_button.dart';
import 'abg_content.dart';
import 'diagnostics_notice.dart';

class AbgReferenceScreen extends StatefulWidget {
  const AbgReferenceScreen({
    super.key,
    this.showClinicalDraft = false,
    this.clinicalRelease = false,
    this.initialTopic,
  });
  final bool showClinicalDraft;
  final bool clinicalRelease;
  final String? initialTopic;

  @override
  State<AbgReferenceScreen> createState() => _AbgReferenceScreenState();
}

class _AbgReferenceScreenState extends State<AbgReferenceScreen> {
  final _search = TextEditingController();
  String _group = 'All';

  @override
  void initState() {
    super.initState();
    _search.text =
        abgTopics
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
    final selected = abgTopics
        .where((topic) => topic.id == widget.initialTopic)
        .firstOrNull;
    final topics = searchAbgTopics(_search.text, group: _group)
        .where(
          (topic) =>
              selected == null ||
              _search.text != selected.title ||
              topic.id == selected.id,
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('ABG & Acid–Base'),
        actions: const [LumaHomeButton()],
      ),
      body: !widget.showClinicalDraft && !widget.clinicalRelease
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'ABG & Acid–Base is in preparation. Clinical draft '
                  'content is not available in the released app.',
                ),
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    DiagnosticsNotice(reviewPreview: widget.showClinicalDraft),
                    const SizedBox(height: 20),
                    Text(
                      'Perioperative acid–base problems',
                      style: lumaDisplay(size: 28),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Differentials, management considerations and anesthesia '
                      'pitfalls. Select a clinical problem, or search a finding.',
                    ),
                    const SizedBox(height: 20),
                    Card(
                      margin: EdgeInsets.zero,
                      color: LumaColors.creamElevated,
                      child: ExpansionTile(
                        initiallyExpanded: widget.initialTopic == 'formulas',
                        key: const PageStorageKey('abg-compensation'),
                        title: const Text('Formulas & compensation'),
                        subtitle: const Text(
                          'Compensation · Anion gap · Delta gap',
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          16,
                        ),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Approximate responses, not treatment '
                              'targets. Compare with baseline, time course '
                              'and clinical context.',
                            ),
                          ),
                          _CompensationTable(),
                          ClinicalReferenceSection(section: gapReference),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Search ABG references',
                        hintText: 'SGLT2, lactate, hypercapnia…',
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
                        for (final group in abgGroups)
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
                              'No matching ABG references. Try a '
                              'different term or reset the filters.',
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
                          key: PageStorageKey('abg-${topic.id}'),
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
                              ),
                            for (final section in topic.sections)
                              ClinicalReferenceSection(section: section),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sources are linked within each section. '
                      'Verify current guidance and apply clinical judgment and institutional protocols.',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _AbgSourceButton extends StatelessWidget {
  const _AbgSourceButton({required this.label, required this.url});
  final String label, url;

  Future<void> _openSource(BuildContext context) async {
    try {
      if (await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )) {
        return;
      }
    } catch (_) {
      // Preserve a visible destination when the browser cannot open it.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to open source: $url')));
    }
  }

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: () => _openSource(context),
    icon: const Icon(Icons.open_in_new, size: 16),
    label: Text(label),
  );
}

class _CompensationTable extends StatelessWidget {
  const _CompensationTable();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final section in compensationReference)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: LumaColors.inkNavy.withValues(alpha: .14),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              for (final line in section.bullets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: SelectionArea(child: Text(line)),
                ),
            ],
          ),
        ),
      const _AbgSourceButton(
        label: 'Merck Manual · Compensation table',
        url: compensationSource,
      ),
    ],
  );
}

class ClinicalDifferentialTable extends StatelessWidget {
  const ClinicalDifferentialTable({
    super.key,
    required this.rows,
    this.title = 'Differential at a glance',
    this.processLabel = 'Process',
    this.cluesLabel = 'Distinguishing context',
    this.focusLabel = 'Evaluation / management focus',
    this.introduction,
  });
  final List<AbgDifferential> rows;
  final String title;
  final String processLabel;
  final String cluesLabel;
  final String focusLabel;
  final String? introduction;

  Widget _cell(String text, {bool heading = false}) => Padding(
    padding: const EdgeInsets.all(12),
    child: SelectionArea(
      child: Text(
        text,
        style: heading ? const TextStyle(fontWeight: FontWeight.w600) : null,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (introduction != null) ...[
          Text(introduction!),
          const SizedBox(height: 12),
        ],
        if (constraints.maxWidth >= 640)
          Table(
            columnWidths: const {
              0: FlexColumnWidth(.8),
              1: FlexColumnWidth(1.3),
              2: FlexColumnWidth(1.5),
            },
            border: TableBorder.all(
              color: LumaColors.inkNavy.withValues(alpha: .14),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  color: LumaColors.haloGoldLight,
                ),
                children: [
                  _cell(processLabel, heading: true),
                  _cell(cluesLabel, heading: true),
                  _cell(focusLabel, heading: true),
                ],
              ),
              for (final row in rows)
                TableRow(
                  children: [
                    _cell(row.process, heading: true),
                    _cell(row.clues),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectionArea(child: Text(row.focus)),
                          _AbgSourceButton(
                            label: row.sourceLabel,
                            url: row.url,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          )
        else
          for (final row in rows)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: LumaColors.inkNavy.withValues(alpha: .14),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.process,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cluesLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SelectionArea(child: Text(row.clues)),
                  const SizedBox(height: 8),
                  Text(
                    focusLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SelectionArea(child: Text(row.focus)),
                  _AbgSourceButton(label: row.sourceLabel, url: row.url),
                ],
              ),
            ),
      ],
    ),
  );
}

class ClinicalReferenceSection extends StatelessWidget {
  const ClinicalReferenceSection({super.key, required this.section});
  final AbgSection section;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: section.caution ? LumaColors.haloGoldLight : null,
      border: Border.all(color: LumaColors.inkNavy.withValues(alpha: .14)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        for (final bullet in section.bullets)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: SelectionArea(child: Text(bullet))),
              ],
            ),
          ),
        _AbgSourceButton(label: section.sourceLabel, url: section.url),
      ],
    ),
  );
}
