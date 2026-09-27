import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/luma_theme.dart';
import '../widgets/clinical_source_link.dart';
import '../widgets/luma_home_button.dart';
import 'quick_reference_chart.dart';
import 'quick_reference_repository.dart';

const quickReferenceBlue = Color(0xFF176AD6);

class QuickReferencesScreen extends StatefulWidget {
  const QuickReferencesScreen({
    super.key,
    this.repository,
    this.initialQuery = '',
  });
  final QuickReferenceDataSource? repository;
  final String initialQuery;

  @override
  State<QuickReferencesScreen> createState() => _QuickReferencesScreenState();
}

class _QuickReferencesScreenState extends State<QuickReferencesScreen> {
  late final QuickReferenceDataSource _repository;
  late final TextEditingController _search;
  late Future<List<QuickReferenceSection>> _catalog;
  String? _referenceId;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ??
        SupabaseQuickReferenceRepository(Supabase.instance.client);
    _search = TextEditingController(text: widget.initialQuery);
    _catalog = _repository.catalog();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick References'),
        actions: const [LumaHomeButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Search Quick References',
                      hintText: 'GLP1, bipolar and AICD, nicardipine…',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: quickReferenceBlue,
                      ),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() => _search.clear()),
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<QuickReferenceSection>>(
                    future: _catalog,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return _Notice(
                          text: 'Quick References could not load. Check your connection and try again.',
                          action: 'Try again',
                          onAction: () => setState(() {
                            _catalog = _repository.catalog();
                          }),
                        );
                      }
                      final all = snapshot.data ?? [];
                      final searching = normalizeReferenceQuery(_search.text)
                          .isNotEmpty;
                      final sections = all
                          .where(
                            (s) =>
                                (!searching && _referenceId != null
                                    ? s.referenceId == _referenceId
                                    : true) &&
                                s.matches(_search.text),
                          )
                          .toList();
                      if (all.isEmpty) {
                        return const _Notice(
                          text: 'No quick references are available yet.',
                        );
                      }
                      if (sections.isEmpty) {
                        return const _Notice(
                          text: 'No matching sections. Try a medication name or another clinical term.',
                        );
                      }
                      if (!searching && _referenceId == null) {
                        final references = <String, QuickReferenceSection>{};
                        for (final section in all) {
                          references.putIfAbsent(
                            section.referenceId,
                            () => section,
                          );
                        }
                        return ListView(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                          children: [
                            const Text(
                              'Search a topic or browse a guide.',
                              style: TextStyle(color: LumaColors.inkSecondary),
                            ),
                            const SizedBox(height: 16),
                            for (final reference in references.values)
                              Card(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(20),
                                  leading: const Icon(
                                    Icons.article_outlined,
                                    color: quickReferenceBlue,
                                  ),
                                  title: Text(
                                    reference.referenceTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '${all.where((s) => s.referenceId == reference.referenceId).length} sections · Tap to browse',
                                    ),
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => setState(
                                    () => _referenceId = reference.referenceId,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                        children: [
                          if (!searching)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                icon: const Icon(Icons.arrow_back, size: 18),
                                label: const Text('All references'),
                                onPressed: () =>
                                    setState(() => _referenceId = null),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              searching
                                  ? '${sections.length} matching ${sections.length == 1 ? 'section' : 'sections'}'
                                  : sections.first.referenceTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          for (final section in sections)
                            Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                title: Text(section.title),
                                subtitle: searching
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(section.referenceTitle),
                                      )
                                    : null,
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: quickReferenceBlue,
                                ),
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      settings: const RouteSettings(
                                        name: '/quick-reference-detail',
                                      ),
                                      builder: (_) => QuickReferenceReader(
                                        section: section,
                                        repository: _repository,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      );
                    },
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

class QuickReferenceReader extends StatefulWidget {
  const QuickReferenceReader({
    super.key,
    required this.section,
    required this.repository,
  });
  final QuickReferenceSection section;
  final QuickReferenceDataSource repository;
  @override
  State<QuickReferenceReader> createState() => _QuickReferenceReaderState();
}

class _QuickReferenceReaderState extends State<QuickReferenceReader>
    with WidgetsBindingObserver {
  StreamSubscription<void>? _auth;
  QuickReferenceContent? _content;
  bool _loading = true;
  bool _failed = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _auth = widget.repository.authChanges.listen((_) => _load());
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    final request = ++_request;
    // Never leave a previous user's protected body on screen while rechecking.
    setState(() {
      _content = null;
      _loading = true;
      _failed = false;
    });
    try {
      final content = await widget.repository.content(widget.section.id);
      if (!mounted || request != _request) return;
      setState(() {
        _content = content;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || request != _request) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    ++_request;
    _auth?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Reference'),
        actions: const [LumaHomeButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _failed
                ? _Notice(
                    text: 'This section could not load. Check your connection and try again.',
                    action: 'Try again',
                    onAction: _load,
                  )
                : _content == null
                ? _Notice(
                    text: 'This clinical reference requires eligible Luma clinical access. Sign in to your account, or review access options.',
                    action: 'Sign in',
                    onAction: () async {
                      await Navigator.of(context).pushNamed('/account');
                      if (mounted) _load();
                    },
                    secondaryAction: 'Access options',
                    onSecondaryAction: () async {
                      await Navigator.of(context).pushNamed('/subscribe');
                      if (mounted) _load();
                    },
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 36),
                    children: [
                      Text(
                        widget.section.referenceTitle,
                        style: const TextStyle(
                          color: quickReferenceBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.section.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Content version ${_content!.version} · '
                        '${widget.section.referenceId == 'pre-op-clearance-guidelines' ? 'Adult noncardiac surgery' : 'Adult perioperative reference'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF2FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.section.referenceId ==
                                  'pre-op-clearance-guidelines'
                              ? 'Clinical reference, not a declaration of clearance. '
                                    'Individualize assessment and follow local policy. '
                                    'GLP-1 guidance is separately sourced from the cardiovascular guideline.'
                              : widget.section.referenceId == 'aicds-pacemakers'
                              ? 'Clinical reference, not a patient-specific device prescription. '
                                    'Confirm the exact device and magnet response with the CIED team; '
                                    'follow manufacturer instructions and local policy.'
                              : 'Adult monitored IV reference. Verify dose, units, concentration, '
                                    'contraindications and patient-specific BP/HR targets; follow local policy.',
                          style: const TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (widget.section.referenceId ==
                              'antihypertensive-dosing' ||
                          widget.section.referenceId == 'hypotension-dosing' ||
                          widget.section.referenceId == 'beta-blocker-dosing')
                        QuickReferenceChart(
                          body: _content!.body,
                          nameColumnFlex:
                              widget.section.referenceId == 'hypotension-dosing'
                              ? 1.2
                              : 1,
                        )
                      else
                        MarkdownBody(
                          data: _content!.body,
                          selectable: true,
                          onTapLink: (text, href, title) =>
                              ClinicalSourceLink.open(context, href),
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: LumaColors.inkPrimary,
                            ),
                            h3: const TextStyle(
                              fontSize: 19,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                            ),
                            h3Padding: const EdgeInsets.only(
                              top: 14,
                              bottom: 10,
                            ),
                            listBullet: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                            ),
                            listIndent: 20,
                            blockSpacing: 14,
                            a: const TextStyle(
                              color: quickReferenceBlue,
                              decoration: TextDecoration.underline,
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

class _Notice extends StatelessWidget {
  const _Notice({
    required this.text,
    this.action,
    this.onAction,
    this.secondaryAction,
    this.onSecondaryAction,
  });
  final String text;
  final String? action;
  final VoidCallback? onAction;
  final String? secondaryAction;
  final VoidCallback? onSecondaryAction;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.menu_book_outlined,
            color: quickReferenceBlue,
            size: 36,
          ),
          const SizedBox(height: 16),
          Text(text, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: 18),
            FilledButton(onPressed: onAction, child: Text(action!)),
          ],
          if (secondaryAction != null)
            TextButton(
              onPressed: onSecondaryAction,
              child: Text(secondaryAction!),
            ),
        ],
      ),
    ),
  );
}
