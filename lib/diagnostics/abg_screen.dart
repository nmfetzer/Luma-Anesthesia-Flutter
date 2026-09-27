import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/luma_theme.dart';
import '../widgets/luma_home_button.dart';
import 'abg_content.dart';

class AbgReferenceScreen extends StatefulWidget {
  const AbgReferenceScreen({super.key, this.showClinicalDraft = false});
  final bool showClinicalDraft;

  @override
  State<AbgReferenceScreen> createState() => _AbgReferenceScreenState();
}

class _AbgReferenceScreenState extends State<AbgReferenceScreen> {
  final _search = TextEditingController();
  String _group = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topics = searchAbgTopics(_search.text, group: _group);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ABG & Acid–Base'),
        actions: const [LumaHomeButton()],
      ),
      body: !widget.showClinicalDraft
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('ABG & Acid–Base is in preparation. Clinical draft '
                    'content is not available in the released app.'),
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: LumaColors.haloGoldLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('REVIEW PREVIEW\n'
                          'Adult educational reference. Draft content is not '
                          'released for patient care. Follow clinical judgment '
                          'and institutional protocols.'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Interpret the whole picture',
                      style: lumaDisplay(size: 28),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        'Acid–base patterns, compensation and anesthesia '
                        'context. Reference formulas and teaching cases only; '
                        'no patient-specific calculator.'),
                    const SizedBox(height: 20),
                    Card(
                      margin: EdgeInsets.zero,
                      color: LumaColors.creamElevated,
                      child: ExpansionTile(
                        key: const PageStorageKey('abg-compensation'),
                        title: const Text('Compensation quick reference'),
                        subtitle:
                            const Text('Four patterns · Acute vs chronic'),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('Approximate responses, not treatment '
                                'targets. Compare with baseline, time course '
                                'and clinical context.'),
                          ),
                          for (final section in compensationReference)
                            _Section(section: section),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Search ABG references',
                        hintText: 'Winter, anion gap, EtCO2…',
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
                    Text(
                      '${topics.length} of ${abgTopics.length} reference cards',
                      style: const TextStyle(color: LumaColors.inkMuted),
                    ),
                    const SizedBox(height: 12),
                    if (topics.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('No matching ABG references. Try a '
                                'different term or reset the filters.'),
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
                          key: PageStorageKey('abg-${topic.id}'),
                          title: Text(topic.title),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text('${topic.group} · ${topic.summary}'),
                          ),
                          childrenPadding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          children: [
                            for (final section in topic.sections)
                              _Section(section: section),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Text('Sources are linked within each section. '
                        'Source checking is not a substitute for clinician '
                        'review of this draft.'),
                  ],
                ),
              ),
            ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.section});
  final AbgSection section;

  Future<void> _openSource(BuildContext context) async {
    try {
      if (await launchUrl(
        Uri.parse(section.url),
        mode: LaunchMode.externalApplication,
      )) {
        return;
      }
    } catch (_) {
      // Preserve a visible destination when the browser cannot open it.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open source: ${section.url}'),
        ),
      );
    }
  }

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
            TextButton.icon(
              onPressed: () => _openSource(context),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text(section.sourceLabel),
            ),
          ],
        ),
      );
}
