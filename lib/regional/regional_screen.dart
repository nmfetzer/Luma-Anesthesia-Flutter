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
  Widget build(BuildContext context) => Scaffold(
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
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
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
                      child: Text(bullet, style: const TextStyle(height: 1.5)),
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
                    Navigator.of(context).pushNamed(regionalTopic(id)!.route),
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
