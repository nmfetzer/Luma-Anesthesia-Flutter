import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/luma_theme.dart';
import '../widgets/luma_home_button.dart';
import '../widgets/clinical_source_link.dart';
import 'crisis_repository.dart';
import 'crisis_reference_sections.dart';
import 'crisis_algorithm_links.dart';

class CrisisHubScreen extends StatefulWidget {
  const CrisisHubScreen({super.key, this.repository, this.initialQuery = ''});
  final CrisisDataSource? repository;
  final String initialQuery;
  @override
  State<CrisisHubScreen> createState() => _CrisisHubScreenState();
}

class _CrisisHubScreenState extends State<CrisisHubScreen> {
  late final CrisisDataSource _repo =
      widget.repository ?? SupabaseCrisisRepository(Supabase.instance.client);
  late final TextEditingController _search =
      TextEditingController(text: widget.initialQuery);
  late Future<List<CrisisEntry>> _catalog = _repo.catalog();
  String? _category;
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('Crisis Hub'), actions: const [LumaHomeButton()]),
        body: SafeArea(
            child: Center(
                child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Clinical crisis references',
                          style: lumaDisplay(size: 26)),
                      const SizedBox(height: 8),
                      const Text(
                          'Topic-based clinical reference material. Use clinical judgment and current institutional protocols; do not delay emergency support.'),
                      const SizedBox(height: 16),
                      TextField(
                          controller: _search,
                          decoration: InputDecoration(
                              labelText: 'Search emergencies or acronyms',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _search.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Clear search',
                                      icon: const Icon(Icons.close),
                                      onPressed: () => setState(_search.clear)),
                              border: const OutlineInputBorder()),
                          onChanged: (_) => setState(() {})),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: [
                            Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                    label: const Text('All topics'),
                                    selected: _category == null,
                                    onSelected: (_) =>
                                        setState(() => _category = null))),
                            for (final category in crisisCategories.entries)
                              Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                      label: Text(category.value),
                                      selected: _category == category.key,
                                      onSelected: (_) => setState(
                                          () => _category = category.key))),
                          ])),
                    ])),
            Expanded(
                child: FutureBuilder<List<CrisisEntry>>(
                    future: _catalog,
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return _LoadFailure(
                            onRetry: () => setState(() {
                                  _catalog = _repo.catalog();
                                }));
                      if (!snapshot.hasData)
                        return const Center(child: CircularProgressIndicator());
                      final rows = snapshot.data!
                          .where((e) =>
                              (_category == null || e.category == _category) &&
                              e.matches(_search.text))
                          .toList();
                      if (rows.isEmpty)
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                    'No matching emergencies. Try another name or choose All topics.')));
                      return ListView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          children: [
                            for (final cat in crisisCategories.entries)
                              if (rows.any((r) => r.category == cat.key)) ...[
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Text(cat.value,
                                        style: lumaDisplay(size: 22))),
                                for (final entry
                                    in rows.where((r) => r.category == cat.key))
                                  Card(
                                      color: LumaColors.creamElevated,
                                      child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.all(16),
                                          leading: const Icon(
                                              Icons.emergency_outlined,
                                              color: LumaColors.highAlert),
                                          title: Text(entry.title,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                          subtitle: Text(!entry.isPublished
                                              ? 'Clinical review pending'
                                              : entry.isFree
                                                  ? 'Free reference'
                                                  : 'Subscription reference'),
                                          trailing:
                                              const Icon(Icons.chevron_right),
                                          onTap: () => Navigator.of(context)
                                              .push(MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      CrisisDetailScreen(
                                                          entry: entry,
                                                          repository:
                                                              _repo))))),
                              ],
                          ]);
                    })),
          ]),
        ))),
      );
}

class CrisisDetailScreen extends StatefulWidget {
  const CrisisDetailScreen(
      {super.key, required this.entry, required this.repository});
  final CrisisEntry entry;
  final CrisisDataSource repository;
  @override
  State<CrisisDetailScreen> createState() => _CrisisDetailScreenState();
}

class _CrisisDetailScreenState extends State<CrisisDetailScreen> {
  late Future<({CrisisAccess access, Map<String, dynamic>? content})> _load;
  StreamSubscription<void>? _auth;
  var _version = 0;
  @override
  void initState() {
    super.initState();
    _load = _fetch();
    _auth = widget.repository.authChanges.listen((_) {
      if (mounted)
        setState(() {
          _version++;
          _load = _fetch();
        });
    });
  }

  Future<({CrisisAccess access, Map<String, dynamic>? content})>
      _fetch() async {
    final access = await widget.repository.access();
    final content = await widget.repository.detail(widget.entry.slug);
    return (access: access, content: content);
  }

  @override
  void dispose() {
    _auth?.cancel();
    super.dispose();
  }

  Widget _markdown(String text) => MarkdownBody(
      data: text,
      selectable: true,
      imageBuilder: (uri, title, alt) =>
          Text(alt ?? 'Legacy illustration omitted'),
      onTapLink: (_, href, __) => ClinicalSourceLink.open(context, href),
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: lumaBody(size: 16),
          h3: lumaBody(size: 17, weight: FontWeight.w700)));
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('Crisis reference'),
            actions: const [LumaHomeButton()]),
        body: SafeArea(
            child: Center(
                child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: FutureBuilder(
            key: ValueKey(_version),
            future: _load,
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return _LoadFailure(
                    onRetry: () => setState(() {
                          _version++;
                          _load = _fetch();
                        }));
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final result = snapshot.data!;
              final content = result.content;
              if (content == null)
                return ListView(padding: const EdgeInsets.all(24), children: [
                  Text(widget.entry.title, style: lumaDisplay(size: 28)),
                  const SizedBox(height: 20),
                  Icon(
                      widget.entry.isPublished
                          ? Icons.lock_outline
                          : Icons.fact_check_outlined,
                      size: 44),
                  const SizedBox(height: 16),
                  Text(widget.entry.isPublished
                      ? widget.entry.isFree ||
                              result.access.premium ||
                              result.access.reviewer
                          ? 'This reference is temporarily unavailable. Please return to Crisis Hub and try again.'
                          : 'A subscription is required for this reference. Creating an account alone does not unlock paid content.'
                      : 'This clinical reference is held for review and is not yet released for patient care.'),
                  const SizedBox(height: 16),
                  if (widget.entry.isPublished &&
                      !widget.entry.isFree &&
                      !result.access.premium &&
                      !result.access.reviewer)
                    FilledButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/subscribe'),
                        child: const Text('View subscription options')),
                  OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/account'),
                      child: Text(widget.entry.isPublished
                          ? 'Sign in to your account'
                          : 'Owner sign-in to review')),
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back to Crisis Hub')),
                ]);
              // Preserve the reviewed source content while presenting it as
              // reference sections, never as an interactive treatment checklist.
              final sections = (content['steps'] as List? ?? []).cast<Map>();
              final sources = (content['sources'] as List? ?? []).cast<Map>();
              String value(String key) => content[key]?.toString() ?? '';
              return ListView(padding: const EdgeInsets.all(24), children: [
                Text(widget.entry.categoryLabel,
                    style: lumaBody(size: 13, color: LumaColors.inkMuted)),
                const SizedBox(height: 8),
                Text(widget.entry.title, style: lumaDisplay(size: 28)),
                const SizedBox(height: 20),
                if (!widget.entry.isPublished ||
                    content['_review_draft'] == true)
                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: LumaColors.haloGoldLight,
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                                'OWNER REVIEW • NOT RELEASED FOR PATIENT CARE',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            const Text(
                                'Draft clinical reference. Clinical review and release approval are required before patient-care use.'),
                            for (final flag
                                in content['migration_flags'] as List? ?? [])
                              Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text('• $flag')),
                          ])),
                const SizedBox(height: 16),
                if (crisisAlgorithms.containsKey(widget.entry.slug)) ...[
                  CrisisAlgorithmLinks(slug: widget.entry.slug),
                  const SizedBox(height: 24),
                ],
                if (value('summary').isNotEmpty) ...[
                  Text('Overview', style: lumaDisplay(size: 22)),
                  const SizedBox(height: 8),
                  SelectableText(value('summary'), style: lumaBody(size: 16)),
                ],
                if (sections.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Clinical management considerations',
                      style: lumaDisplay(size: 22)),
                  for (final section in sections)
                    Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Semantics(
                                  header: true,
                                  child: Text('${section['action'] ?? ''}',
                                      style: lumaBody(
                                          size: 18, weight: FontWeight.w700))),
                              if (section['details'] != null) ...[
                                const SizedBox(height: 8),
                                SelectableText('${section['details']}',
                                    style: lumaBody(size: 16)),
                              ],
                              if (section['is_critical'] == true) ...[
                                const SizedBox(height: 8),
                                Text('Critical clinical consideration',
                                    style: lumaBody(
                                        size: 13,
                                        weight: FontWeight.w700,
                                        color: LumaColors.highAlert)),
                              ],
                            ])),
                ],
                for (final field in {
                  'key_drugs': 'Key drugs',
                  'notes': 'Clinical notes'
                }.entries)
                  if (value(field.key).isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(field.value, style: lumaDisplay(size: 22)),
                    const SizedBox(height: 8),
                    SelectableText(value(field.key), style: lumaBody(size: 16)),
                  ],
                if (value('body_markdown').isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _markdown(value('body_markdown')),
                ],
                if (content['reference_sections'] is List) ...[
                  const SizedBox(height: 24),
                  CrisisReferenceSections(
                    sections:
                        (content['reference_sections'] as List).cast<Map>(),
                  ),
                ],
                if (value('supplement_markdown').isNotEmpty) ...[
                  const SizedBox(height: 24),
                  ExpansionTile(
                      title:
                          const Text('Additional Base44 card (unreconciled)'),
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(12),
                            child: _markdown(value('supplement_markdown')))
                      ]),
                ],
                const SizedBox(height: 24),
                Text('References', style: lumaDisplay(size: 22)),
                if (value('reference').isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(value('reference'))),
                if (sources.isEmpty)
                  const Text(
                      'The original reference needs direct source links before release.'),
                for (final source in sources)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ClinicalSourceLink(
                          url: source['url']?.toString(),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.open_in_new, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(
                                        '${source['title'] ?? source['url'] ?? 'Reference'}',
                                        style: const TextStyle(
                                            decoration:
                                                TextDecoration.underline))),
                              ]))),
                const SizedBox(height: 24),
                OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/drug-library'),
                    child: const Text('Open Drug Library')),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to Crisis Hub')),
              ]);
            },
          ),
        ))),
      );
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_outlined, size: 36),
            const SizedBox(height: 12),
            const Text(
                'Crisis Hub could not load. Check your connection and retry. Do not delay emergency care.'),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ])));
}
