import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/luma_theme.dart';
import '../widgets/luma_home_button.dart';
import '../widgets/premium_access_gate.dart';
import 'regional_content.dart';

/// Named hub and topic routes both use the same existing subscription boundary.
class RegionalFeature extends StatelessWidget {
  const RegionalFeature({
    super.key,
    this.topicId,
    this.checkAccess,
    this.accessChanges,
  });
  final String? topicId;
  final Future<bool> Function()? checkAccess;
  final Stream<void>? accessChanges;

  @override
  Widget build(BuildContext context) => PremiumAccessGate(
    checkAccess: checkAccess,
    accessChanges: accessChanges,
    builder: (_) {
      final topic = regionalTopic(topicId);
      if (topicId != null && topic == null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Regional reference'),
            actions: const [LumaHomeButton()],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('This regional reference could not be found.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        Navigator.of(context)
                            .pushReplacementNamed('/regional-procedures'),
                    child: const Text('Browse regional references'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return topic == null
          ? const RegionalLibraryScreen()
          : RegionalDetailScreen(topic: topic);
    },
  );
}

class RegionalLibraryScreen extends StatefulWidget {
  const RegionalLibraryScreen({super.key});
  @override
  State<RegionalLibraryScreen> createState() => _RegionalLibraryScreenState();
}

class _RegionalLibraryScreenState extends State<RegionalLibraryScreen> {
  final _search = TextEditingController();
  String _category = 'All';
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topics = searchRegionalTopics(_search.text, category: _category);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Regional & Procedures',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: const [LumaHomeButton()],
      ),
      body: _ReferenceBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Regional anesthesia', style: lumaDisplay(size: 28)),
            const SizedBox(height: 8),
            const Text(
              'Block selection, coverage, safety, and recovery. '
              'Practical references for adult anesthesia care.',
            ),
            const SizedBox(height: 20),
            const _ReferenceNotice(),
            const SizedBox(height: 20),
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Search regional references',
                hintText: 'Interscalene, apixaban, PENG, LAST…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () => setState(_search.clear),
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in regionalCategories)
                  ChoiceChip(
                    label: Text(category),
                    selected: category == _category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (topics.isEmpty) ...[
              const Text(
                'No matching regional references. Try a block name, '
                'medication, procedure, or safety topic.',
              ),
              TextButton(
                onPressed: () => setState(() {
                  _search.clear();
                  _category = 'All';
                }),
                child: const Text('Reset search and filters'),
              ),
            ],
            for (final topic in topics)
              Card(
                color: LumaColors.creamElevated,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  title: Text(
                    topic.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('${topic.category}\n${topic.summary}'),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pushNamed(topic.route),
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'Reference text is included in the app. Source websites '
              'require internet access.',
              style: TextStyle(color: LumaColors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class RegionalDetailScreen extends StatelessWidget {
  const RegionalDetailScreen({super.key, required this.topic});
  final RegionalTopic topic;
  @override
  Widget build(BuildContext context) =>
      topic.sections.first.title == 'At a glance'
      ? _ComprehensiveRegionalDetail(topic: topic)
      : Scaffold(
          appBar: AppBar(
            title: const Text('Regional reference'),
            actions: const [LumaHomeButton()],
          ),
          body: _ReferenceBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  topic.category,
                  style: const TextStyle(color: LumaColors.inkMuted),
                ),
                const SizedBox(height: 8),
                Text(topic.title, style: lumaDisplay(size: 28)),
                const SizedBox(height: 10),
                Text(topic.summary),
                const SizedBox(height: 20),
                const _ReferenceNotice(),
                for (final section in topic.sections) ...[
                  const SizedBox(height: 24),
                  Text(
                    section.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final bullet in section.bullets)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  '),
                          Expanded(
                            child: Text(
                              bullet,
                              style: const TextStyle(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final id in section.sources)
                        _SourceButton(source: regionalSources[id]!),
                    ],
                  ),
                  const Divider(height: 20),
                ],
                if (topic.related.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Related references',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  for (final id in topic.related)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(regionalTopic(id)!.title),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.of(context)
                              .pushNamed(regionalTopic(id)!.route),
                    ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Use current institutional protocols and the complete source '
                  'documents. This reference does not replace supervised procedural '
                  'training, clinical judgment, or an individualized anesthetic plan.',
                  style: TextStyle(color: LumaColors.inkMuted),
                ),
              ],
            ),
          ),
        );
}

/// Expanded block references share a searchable, progressive-disclosure reader.
/// All entry points still pass through RegionalFeature's subscription gate.
class _ComprehensiveRegionalDetail extends StatefulWidget {
  const _ComprehensiveRegionalDetail({required this.topic});
  final RegionalTopic topic;

  @override
  State<_ComprehensiveRegionalDetail> createState() =>
      _ComprehensiveRegionalDetailState();
}

class _ComprehensiveRegionalDetailState
    extends State<_ComprehensiveRegionalDetail> {
  final _search = TextEditingController();
  final Set<String> _open = {};
  late final Map<String, GlobalKey> _anchors = {
    for (final section in widget.topic.sections.skip(1))
      section.title: GlobalKey(),
  };

  Map<String, String> get _shortcuts {
    final result = <String, String>{};
    for (final section in widget.topic.sections.skip(1)) {
      final title = section.title;
      if (title.startsWith('Anatomy')) {
        result['Anatomy'] = title;
      } else if (title.startsWith('Technique')) {
        result['Technique'] = title;
      } else if (title.startsWith('Local anesthetics') ||
          title.startsWith('Medications')) {
        result['Medications'] = title;
      } else if (title.startsWith('Block assessment')) {
        result['Troubleshooting'] = title;
      } else if (title.startsWith('Complications') ||
          title == 'Nonzero motor risk') {
        result['Urgent concerns'] = title;
      } else if (title.startsWith('Continuous catheter') ||
          title.startsWith('Catheter')) {
        result['Catheters'] = title;
      } else if (title.startsWith('Recovery') ||
          title.startsWith('Ongoing care')) {
        result['Recovery'] = title;
      } else if (title.startsWith('Evidence')) {
        result['Evidence'] = title;
      }
    }
    return result;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _jump(String title) {
    FocusScope.of(context).unfocus();
    setState(() {
      _search.clear();
      _open.add(title);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = _anchors[title]?.currentContext;
      if (target == null) return;
      Scrollable.ensureVisible(
        target,
        alignment: 0,
        duration: MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 250),
      );
    });
  }

  void _toggle(RegionalSection section, List<RegionalSection> visible) {
    setState(() {
      final searching = _search.text.trim().isNotEmpty;
      final wasOpen = searching || _open.contains(section.title);
      if (searching) {
        _open.addAll(visible.map((s) => s.title));
        _search.clear();
      }
      if (wasOpen) {
        _open.remove(section.title);
      } else {
        _open.add(section.title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final sections = widget.topic.sections.skip(1).where((section) {
      final text = '${section.title} ${section.bullets.join(' ')}'
          .toLowerCase();
      return query.isEmpty || query.split(RegExp(r'\s+')).every(text.contains);
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.topic.id == 'interscalene'
              ? 'Interscalene'
              : widget.topic.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: const [LumaHomeButton()],
      ),
      body: _ReferenceBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${widget.topic.category.toUpperCase()} · ADULT REFERENCE',
              style: const TextStyle(
                color: LumaColors.inkMuted,
                fontSize: 12,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.topic.id == 'interscalene'
                  ? 'Interscalene\nbrachial plexus block'
                  : widget.topic.title,
              style: lumaDisplay(size: 28),
            ),
            const SizedBox(height: 10),
            Text(widget.topic.summary),
            const SizedBox(height: 12),
            const Text(
              'Evidence checked October 4, 2026',
              style: TextStyle(color: LumaColors.inkMuted, fontSize: 12),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: LumaColors.haloGoldLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('At a glance', style: lumaDisplay(size: 22)),
                  const SizedBox(height: 12),
                  _RegionalSectionBody(section: widget.topic.sections.first),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Go directly to', style: lumaDisplay(size: 22)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in _shortcuts.entries)
                  OutlinedButton(
                    onPressed: () => _jump(entry.value),
                    child: Text(entry.key),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Search detailed sections',
                hintText: 'Coverage, anatomy, medication…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear section search',
                        onPressed: () => setState(_search.clear),
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            if (query.isEmpty)
              Wrap(
                spacing: 12,
                children: [
                  TextButton(
                    onPressed: () => setState(() {
                      _open.addAll(_anchors.keys);
                    }),
                    child: const Text('Expand all'),
                  ),
                  TextButton(
                    onPressed: () => setState(_open.clear),
                    child: const Text('Collapse all'),
                  ),
                ],
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Matching sections are expanded. Clear search to browse all.',
                  style: TextStyle(color: LumaColors.inkMuted),
                ),
              ),
            if (sections.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('No matching detailed sections.'),
                    TextButton(
                      onPressed: () => setState(_search.clear),
                      child: const Text('Show all sections'),
                    ),
                  ],
                ),
              ),
            for (final section in sections)
              Container(
                key: _anchors[section.title],
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: LumaColors.creamElevated,
                  border: Border.all(color: LumaColors.divider),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      button: true,
                      label:
                          '${query.isNotEmpty || _open.contains(section.title) ? "Collapse" : "Expand"} ${section.title}',
                      onTap: () => _toggle(section, sections),
                      child: ExcludeSemantics(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _toggle(section, sections),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    section.title,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  query.isNotEmpty ||
                                          _open.contains(section.title)
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (query.isNotEmpty || _open.contains(section.title))
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                        child: _RegionalSectionBody(section: section),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Text('Related references', style: lumaDisplay(size: 22)),
            const SizedBox(height: 8),
            for (final id in widget.topic.related)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(regionalTopic(id)!.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.of(context).pushNamed(regionalTopic(id)!.route),
              ),
            const SizedBox(height: 24),
            const Text(
              'Clinical reference for trained practitioners, not a substitute '
              'for supervised procedural training, institutional protocols, '
              'or individualized clinical judgment. Text is available offline '
              'with valid app access; external sources and atlas images '
              'require internet.',
              style: TextStyle(color: LumaColors.inkMuted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionalSectionBody extends StatelessWidget {
  const _RegionalSectionBody({required this.section});
  final RegionalSection section;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final bullet in section.bullets)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('•  ', style: TextStyle(height: 1.5)),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      if (bullet.contains(':')) ...[
                        TextSpan(
                          text: bullet.substring(0, bullet.indexOf(':') + 1),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: bullet.substring(bullet.indexOf(':') + 1),
                        ),
                      ] else
                        TextSpan(text: bullet),
                    ],
                  ),
                  style: const TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
        ),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final id in section.sources)
            _SourceButton(source: regionalSources[id]!),
        ],
      ),
    ],
  );
}

class _ReferenceNotice extends StatelessWidget {
  const _ReferenceNotice();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: LumaColors.haloGoldLight,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Text(
      'Adult clinical reference. Confirm anatomy, formulation, '
      'total local anesthetic exposure, antithrombotic timing, and local '
      'protocols. Coverage and motor effects vary; no block is risk-free.',
      style: TextStyle(height: 1.45),
    ),
  );
}

class _ReferenceBody extends StatelessWidget {
  const _ReferenceBody({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 88),
          child: child,
        ),
      ),
    ),
  );
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({required this.source});
  final RegionalSource source;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () async {
      try {
        final opened = await launchUrl(
          Uri.parse(source.url),
          mode: LaunchMode.externalApplication,
        );
        if (opened || !context.mounted) return;
      } catch (_) {
        if (!context.mounted) return;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to open this source. '
              'Check your connection and try again.',
            ),
          ),
        );
      }
    },
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.open_in_new, size: 16),
        const SizedBox(width: 8),
        Flexible(child: Text(source.label)),
      ],
    ),
  );
}
