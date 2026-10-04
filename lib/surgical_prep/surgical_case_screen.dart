import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/luma_theme.dart';
import '../widgets/luma_home_button.dart';
import '../widgets/premium_access_gate.dart';
import 'surgical_case.dart';

/// The shared reader for ALL surgical cases; the release access boundary remains
/// the existing subscription gate. Case content and routes are added separately
/// after clinical review, rather than shipping placeholders as references.
class SurgicalCaseScreen extends StatelessWidget {
  const SurgicalCaseScreen({
    super.key,
    required this.reference,
    this.checkAccess,
    this.accessChanges,
    this.openSource,
  });

  final SurgicalCaseReference reference;
  final Future<bool> Function()? checkAccess;
  final Stream<void>? accessChanges;
  final Future<bool> Function(Uri)? openSource;

  @override
  Widget build(BuildContext context) => PremiumAccessGate(
    checkAccess: checkAccess,
    accessChanges: accessChanges,
    builder: (_) => _CaseReader(
      key: ValueKey(reference.id),
      reference: reference,
      openSource: openSource,
    ),
  );
}

class _CaseReader extends StatefulWidget {
  const _CaseReader({super.key, required this.reference, this.openSource});
  final SurgicalCaseReference reference;
  final Future<bool> Function(Uri)? openSource;

  @override
  State<_CaseReader> createState() => _CaseReaderState();
}

class _CaseReaderState extends State<_CaseReader> {
  final _search = TextEditingController();
  final Set<String> _expanded = {};
  String get _query => _search.text.trim();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _visit(SurgicalSource source) async {
    try {
      final uri = Uri.parse(source.url);
      final opened =
          await (widget.openSource?.call(uri) ??
              launchUrl(uri, mode: LaunchMode.externalApplication));
      if (opened || !mounted) return;
    } catch (_) {
      if (!mounted) return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not open this source. Check your internet connection.',
        ),
      ),
    );
  }

  void _toggle(SurgicalSection section) {
    setState(() {
      // Searching reveals matching content. If the user collapses a result,
      // return to ordinary browsing and preserve the other revealed sections.
      final wasOpen = _query.isNotEmpty || _expanded.contains(section.id);
      if (_query.isNotEmpty) {
        _expanded.addAll(
          widget.reference.sections
              .where((s) => s.matches(_query))
              .map((s) => s.id),
        );
        _search.clear();
      }
      if (wasOpen) {
        _expanded.remove(section.id);
      } else {
        _expanded.add(section.id);
      }
    });
  }

  Widget _body(SurgicalSection section) => Column(
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
                child: Text(bullet, style: const TextStyle(height: 1.5)),
              ),
            ],
          ),
        ),
      for (final source in section.sources)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => _visit(source),
            child: Text(source.label),
          ),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final reference = widget.reference;
    final visible = reference.sections.where((s) => s.matches(_query)).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surgical case', overflow: TextOverflow.ellipsis),
        actions: const [LumaHomeButton()],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      reference.category,
                      style: const TextStyle(color: LumaColors.inkMuted),
                    ),
                    const SizedBox(height: 8),
                    Text(reference.title, style: lumaDisplay(size: 28)),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: LumaColors.haloGoldLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              'Quick clinical overview',
                              style: lumaDisplay(size: 24),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _body(reference.overview),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Search detailed sections',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear section search',
                                onPressed: () => setState(_search.clear),
                                icon: const Icon(Icons.close),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_query.isEmpty)
                      Wrap(
                        spacing: 12,
                        children: [
                          TextButton(
                            onPressed: () => setState(
                              () => _expanded.addAll(
                                reference.sections.map((s) => s.id),
                              ),
                            ),
                            child: const Text('Expand all'),
                          ),
                          TextButton(
                            onPressed: () => setState(_expanded.clear),
                            child: const Text('Collapse all'),
                          ),
                        ],
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Matching detailed sections are expanded. '
                          'The overview remains visible above.',
                        ),
                      ),
                    if (visible.isEmpty) ...[
                      const Text('No matching detailed sections.'),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => setState(_search.clear),
                          child: const Text('Show all sections'),
                        ),
                      ),
                    ],
                    for (final section in visible)
                      Card(
                        semanticContainer: false,
                        color: LumaColors.creamElevated,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Semantics(
                              container: true,
                              button: true,
                              expanded:
                                  _query.isNotEmpty ||
                                  _expanded.contains(section.id),
                              label: section.title,
                              onTap: () => _toggle(section),
                              child: ExcludeSemantics(
                                child: InkWell(
                                  onTap: () => _toggle(section),
                                  borderRadius: BorderRadius.circular(14),
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
                                          _query.isNotEmpty ||
                                                  _expanded.contains(section.id)
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_query.isNotEmpty ||
                                _expanded.contains(section.id))
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  18,
                                  0,
                                  18,
                                  12,
                                ),
                                child: _body(section),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      'Clinical reference for anesthesia professionals. '
                      'Use clinical judgment and institutional protocols. '
                      'External source websites require internet access.',
                      style: TextStyle(color: LumaColors.inkMuted, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
