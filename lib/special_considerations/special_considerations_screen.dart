import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';
import '../theme/luma_theme.dart';
import 'special_consideration.dart';
import 'special_consideration_detail_screen.dart';
import 'special_consideration_repository.dart';

/// Uses the existing home and drawer route. No authentication required to browse.
class SpecialConsiderationsScreen extends StatefulWidget {
  const SpecialConsiderationsScreen({
    super.key,
    this.repository,
    this.onSignIn,
    this.onSubscribe,
    this.onCrisisTopic,
  });
  final SpecialConsiderationDataSource? repository;
  final VoidCallback? onSignIn;
  final VoidCallback? onSubscribe;
  final ValueChanged<String>? onCrisisTopic;

  @override
  State<SpecialConsiderationsScreen> createState() =>
      _SpecialConsiderationsScreenState();
}

class _SpecialConsiderationsScreenState
    extends State<SpecialConsiderationsScreen> {
  SpecialConsiderationDataSource? _repository;
  late Future<List<SpecialConsiderationEntry>> _catalog;
  final _search = TextEditingController();
  String? _category;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        (LumaConfig.supabaseConfigured
            ? SupabaseSpecialConsiderationRepository(Supabase.instance.client)
            : null);
    _catalog = _load();
  }

  Future<List<SpecialConsiderationEntry>> _load() =>
      _repository?.catalog() ?? Future.value([]);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Special Considerations')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: FutureBuilder<List<SpecialConsiderationEntry>>(
                future: _catalog,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _StateMessage(
                      title: 'Unable to load the library',
                      body: 'Check your connection and try again.',
                      action: 'Try again',
                      onAction: () => setState(() {
                        _catalog = _load();
                      }),
                    );
                  }
                  final all = snapshot.data ?? [];
                  if (all.isEmpty) {
                    return const _StateMessage(
                      title: 'The library is being prepared',
                      body: 'Special Considerations entries will appear here '
                          'when they are available.',
                    );
                  }
                  final categories = all.map((e) => e.category).toSet().toList()
                    ..sort();
                  final searching = _search.text.trim().isNotEmpty;
                  final entries = all
                      .where(
                        (e) =>
                            (_category == null || e.category == _category) &&
                            e.matches(_search.text),
                      )
                      .toList();
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prepare with perspective.',
                                style: lumaDisplay(size: 28),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Condition-specific anesthetic planning, '
                                'from preoperative assessment to recovery.',
                                style: lumaBody(color: LumaColors.inkSecondary),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _search,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  labelText: 'Search conditions or keywords',
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: searching
                                      ? IconButton(
                                          tooltip: 'Clear search',
                                          icon: const Icon(Icons.close),
                                          onPressed: () =>
                                              setState(_search.clear),
                                        )
                                      : null,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              if (_category != null)
                                TextButton.icon(
                                  onPressed: () =>
                                      setState(() => _category = null),
                                  icon: const Icon(Icons.arrow_back, size: 18),
                                  label: const Text('All categories'),
                                ),
                              const SizedBox(height: 16),
                              Text(
                                _category ??
                                    (searching
                                        ? 'Search results'
                                        : 'Categories'),
                                style: lumaDisplay(size: 21),
                              ),
                              const SizedBox(height: 6),
                              if (all.any((e) => !e.isPublished))
                                Text(
                                  'Imported drafts are listed for visibility. '
                                  'Their clinical content stays unavailable '
                                  'until reviewed.',
                                  style: lumaBody(
                                    size: 13,
                                    color: LumaColors.inkMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (_category == null && !searching)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverList.list(
                            children: categories.map((category) {
                              final group =
                                  all.where((e) => e.category == category);
                              final ready =
                                  group.where((e) => e.isPublished).length;
                              return _LibraryRow(
                                title: category,
                                subtitle: '${group.length} entries · '
                                    '$ready reviewed',
                                onTap: () =>
                                    setState(() => _category = category),
                              );
                            }).toList(),
                          ),
                        )
                      else if (entries.isEmpty)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No matching conditions. '
                                'Try a different name or keyword.'),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverList.builder(
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              return _LibraryRow(
                                title: entry.title,
                                subtitle: entry.isPublished
                                    ? '${entry.category}${entry.isGuestPreview ? ' · Free preview' : ''}'
                                    : '${entry.category} · Review pending',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        SpecialConsiderationDetailScreen(
                                      entry: entry,
                                      repository: _repository!,
                                      onSignIn: widget.onSignIn,
                                      onSubscribe: widget.onSubscribe,
                                      onCrisisTopic: widget.onCrisisTopic,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
}

class _LibraryRow extends StatelessWidget {
  const _LibraryRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: LumaColors.divider)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          title: Text(title, style: lumaDisplay(size: 18)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              subtitle,
              style: lumaBody(size: 13, color: LumaColors.inkMuted),
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: LumaColors.inkMuted),
          onTap: onTap,
        ),
      );
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.title,
    required this.body,
    this.action,
    this.onAction,
  });
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: lumaDisplay(size: 22)),
              const SizedBox(height: 12),
              Text(body, textAlign: TextAlign.center, style: lumaBody()),
              if (onAction != null)
                TextButton(onPressed: onAction, child: Text(action!)),
            ],
          ),
        ),
      );
}
