import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/luma_theme.dart';
import '../widgets/luma_home_button.dart';
import 'diagnostics_content.dart';
import 'abg_screen.dart';
import 'clinical_modules.dart';
import 'clinical_module_screen.dart';
import 'diagnostics_access.dart';
import 'diagnostics_notice.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({
    super.key,
    this.showClinicalDraft = false,
    this.clinicalRelease = false,
  });
  final bool showClinicalDraft;
  final bool clinicalRelease;

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(DiagnosticCategory category) {
    final access = DiagnosticsAccessScope.maybeOf(context);
    final page = switch (category.id) {
      'labs' => LabValuesScreen(
        showClinicalDraft: widget.showClinicalDraft,
        clinicalRelease: widget.clinicalRelease,
      ),
      'abg' => AbgReferenceScreen(
        showClinicalDraft: widget.showClinicalDraft,
        clinicalRelease: widget.clinicalRelease,
      ),
      _ =>
        (widget.showClinicalDraft || widget.clinicalRelease) &&
                clinicalModules.any((m) => m.id == category.id)
            ? ClinicalModuleScreen(
                module: clinicalModules.firstWhere((m) => m.id == category.id),
                showClinicalDraft: widget.showClinicalDraft,
                clinicalRelease: widget.clinicalRelease,
              )
            : _PreparationScreen(category: category),
    };
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => access?.protect(page) ?? page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = searchDiagnosticCategories(_search.text);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        actions: const [LumaHomeButton()],
      ),
      body: _ReferenceWidth(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Labs & Diagnostics', style: lumaDisplay(size: 28)),
            const SizedBox(height: 8),
            const Text(
              'Explore laboratory and diagnostic references in one place.',
            ),
            const SizedBox(height: 16),
            DiagnosticsNotice(reviewPreview: widget.showClinicalDraft),
            const SizedBox(height: 16),
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Search diagnostic sections',
                hintText: 'Lab values, ABG, ultrasound…',
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
            const SizedBox(height: 20),
            if (categories.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'No matching sections. Try labs, ABG, or ultrasound.',
                ),
              ),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 640 ? 2 : 1;
                final width =
                    (constraints.maxWidth - (columns - 1) * 12) / columns;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final category in categories)
                      SizedBox(
                        width: width,
                        child: Card(
                          color: LumaColors.creamElevated,
                          margin: EdgeInsets.zero,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _open(category),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          category.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(category.description),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LabValuesScreen extends StatefulWidget {
  const LabValuesScreen({
    super.key,
    this.showClinicalDraft = false,
    this.clinicalRelease = false,
    this.initialTopic,
  });
  final bool showClinicalDraft;
  final bool clinicalRelease;
  final String? initialTopic;

  @override
  State<LabValuesScreen> createState() => _LabValuesScreenState();
}

class _LabValuesScreenState extends State<LabValuesScreen> {
  final _search = TextEditingController();
  String _group = 'All';
  bool _urgentOnly = false;

  @override
  void initState() {
    super.initState();
    final selected = labReferences
        .where((entry) => entry.id == widget.initialTopic)
        .firstOrNull;
    _search.text = selected?.title ?? '';
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries =
        searchLabReferences(
          _search.text,
          group: _group,
          urgentOnly: _urgentOnly,
        ).where((entry) {
          final selected = labReferences
              .where((item) => item.id == widget.initialTopic)
              .firstOrNull;
          return selected == null ||
              _search.text != selected.title ||
              entry.id == selected.id;
        }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Values'),
        actions: const [LumaHomeButton()],
      ),
      body: !widget.showClinicalDraft && !widget.clinicalRelease
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Lab Values is in preparation. Clinical draft content '
                  'is not available in the released app.',
                ),
              ),
            )
          : _ReferenceWidth(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverList.list(
                      children: [
                        DiagnosticsNotice(
                          reviewPreview: widget.showClinicalDraft,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Adult lab interpretation',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Use the interval and units on the patient’s laboratory '
                          'report. These examples are not critical-value limits, '
                          'transfusion triggers, or procedural clearance criteria.',
                        ),
                        const _SourceLink(
                          label: 'How to interpret reference ranges',
                          url: labResultsGuide,
                        ),
                        const Text(
                          'Clinical guidance is grouped separately below each example interval. '
                          'Urgent findings are selected clinical cautions, not an exhaustive '
                          'critical-value list. Follow local laboratory alerts and institutional protocols.',
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _search,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Search lab values',
                            hintText: 'ACT, troponin, CPK, lactate…',
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilterChip(
                            label: const Text('Urgent findings'),
                            selected: _urgentOnly,
                            onSelected: (value) =>
                                setState(() => _urgentOnly = value),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            for (final group in [
                              'All',
                              ...labReferences.map((e) => e.group).toSet(),
                            ])
                              ChoiceChip(
                                label: Text(group),
                                selected: _group == group,
                                onSelected: (_) =>
                                    setState(() => _group = group),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (entries.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'No matching lab values. Clear the search or choose another group.',
                            ),
                          ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return Card(
                          color: LumaColors.creamElevated,
                          key: ValueKey(entry.id),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ExpansionTile(
                            key: PageStorageKey('lab-${entry.id}'),
                            initiallyExpanded: entry.id == widget.initialTopic,
                            title: Text(
                              entry.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(entry.interval),
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              16,
                            ),
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              if (entry.id == 'act')
                                const _ActComparisonChart(),
                              const Divider(),
                              Text(
                                entry.hasExampleInterval
                                    ? 'Example interval, not a treatment threshold.'
                                    : 'Assay context, not a universal numeric cutoff.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: LumaColors.inkMuted,
                                ),
                              ),
                              const SizedBox(height: 12),
                              for (final bullet in entry.bullets)
                                _LabBullet(bullet),
                              _SourceLink(
                                label: entry.intervalLabel,
                                url: entry.intervalUrl,
                              ),
                              if (entry.explanationUrl != entry.intervalUrl)
                                _SourceLink(
                                  label: entry.explanationLabel,
                                  url: entry.explanationUrl,
                                ),
                              for (final section in entry.clinicalSections)
                                _ClinicalSection(section),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ActComparisonChart extends StatelessWidget {
  const _ActComparisonChart();

  static const _rows = [
    (
      procedure: 'CPB',
      target: '>480 seconds',
      caveat: 'Cardiopulmonary bypass. Certain maximally activated or microcuvette systems: >400 seconds. Use the validated device-specific perfusion protocol.',
      source: 'STS/SCA/AmSECT · CPB guideline',
      url: actGuidelineSource,
    ),
    (
      procedure: 'PCI (UFH)',
      target:
          '250–300 seconds: HemoTec / i-STAT\n'
          '300–350 seconds: Hemochron',
      caveat: 'With unfractionated heparin. Planned IV GP IIb/IIIa inhibitor: 200–250 seconds. Higher targets may be considered for CTO or ACS; confirm the procedural protocol.',
      source: 'ACC/AHA/SCAI · PCI guideline',
      url: pciActSource,
    ),
    (
      procedure: 'AF ablation',
      target: '≥300 seconds',
      caveat: 'Left atrial ablation. Maintain with unfractionated heparin and regular ACT checks. Some centers use higher targets; follow the electrophysiology protocol.',
      source: 'EHRA/HRS · AF ablation consensus',
      url: ablationActSource,
    ),
    (
      procedure: 'Arterial surgery',
      target: 'No universal numeric target',
      caveat: 'Open or endovascular procedures. ESVS: ACT-guided additional UFH or reversal may be considered (IIb, C). Follow an agreed procedure- and device-specific institutional protocol.',
      source: 'ESVS · Arterial surgery guidance',
      url: vascularActSource,
    ),
  ];

  @override
  Widget build(BuildContext context) => Padding(
    key: const ValueKey('act-comparison-chart'),
    padding: const EdgeInsets.only(top: 12, bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACT targets by procedure',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Procedural anticoagulation targets, not normal ranges. '
          'Confirm the procedure, analyzer, medications, and local protocol.',
        ),
        const SizedBox(height: 12),
        Table(
          key: const ValueKey('act-procedure-table'),
          columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2.3)},
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          border: TableBorder.all(
            color: LumaColors.inkMuted.withValues(alpha: 0.25),
          ),
          children: [
            const TableRow(
              decoration: BoxDecoration(color: LumaColors.haloGoldLight),
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Procedure',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'ACT target & key qualifications',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            for (final row in _rows)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      row.procedure,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.target,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: LumaColors.inkNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(row.caveat),
                        const SizedBox(height: 6),
                        _SourceLink(label: row.source, url: row.url),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    ),
  );
}

class _LabBullet extends StatelessWidget {
  const _LabBullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  '),
        Expanded(child: SelectionArea(child: Text(text))),
      ],
    ),
  );
}

class _ClinicalSection extends StatelessWidget {
  const _ClinicalSection(this.section);
  final LabClinicalSection section;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 16),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: section.urgent ? LumaColors.haloGoldLight : null,
      border: Border.all(color: LumaColors.inkMuted.withValues(alpha: 0.2)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.urgent)
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text(
              'IMPORTANT CLINICAL CONTEXT',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        Text(
          section.title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        for (final bullet in section.bullets) _LabBullet(bullet),
        _SourceLink(label: section.sourceLabel, url: section.url),
      ],
    ),
  );
}

class _PreparationScreen extends StatelessWidget {
  const _PreparationScreen({required this.category});
  final DiagnosticCategory category;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(category.title),
      actions: const [LumaHomeButton()],
    ),
    body: _ReferenceWidth(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            category.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(category.description),
          const SizedBox(height: 24),
          const Text(
            'In preparation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'The Base44 material for this section has been identified. '
            'Its expanded Flutter reference and source review are not complete yet.',
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Diagnostics'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ReferenceWidth extends StatelessWidget {
  const _ReferenceWidth({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 960),
      child: child,
    ),
  );
}

class _SourceLink extends StatelessWidget {
  const _SourceLink({required this.label, required this.url});
  final String label;
  final String url;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () async {
      try {
        final opened = await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
        if (!opened) throw StateError('Could not open reference');
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to open source. $url')),
          );
        }
      }
    },
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.open_in_new, size: 16),
        const SizedBox(width: 8),
        Flexible(child: Text(label)),
      ],
    ),
  );
}
