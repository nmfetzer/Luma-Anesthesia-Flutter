import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/luma_home_button.dart';

import '../theme/luma_theme.dart';
import 'ce_certificate_screen.dart';
import 'ce_records_screen.dart';
import 'ce_repository.dart';
import 'ce_screen.dart';

/// The production library uses the same repositories and server access checks
/// as each course. Injected repositories are for isolated previews and tests.
class CeLibraryScreen extends StatefulWidget {
  const CeLibraryScreen({super.key, this.repositories});
  final List<CeRepository>? repositories;

  @override
  State<CeLibraryScreen> createState() => _CeLibraryScreenState();
}

class _CeLibraryScreenState extends State<CeLibraryScreen> {
  late final repos =
      widget.repositories ??
      [
        for (final n in [1, 2, 3]) SupabaseCeRepository(courseNumber: n),
      ];
  final access = <int, Map<String, dynamic>>{};
  final errors = <int, String>{};
  final subscriptions = <StreamSubscription<String?>>[];
  int generation = 0;
  bool loading = true;
  String section = 'courses';
  final scroll = ScrollController();

  bool get demo => repos.every((r) => r.isDemo);
  bool get signedIn => repos.first.signedIn;
  bool get provider => access.values.any((s) => s['is_provider'] == true);

  @override
  void initState() {
    super.initState();
    for (final repo in repos) {
      subscriptions.add(repo.accountChanges.listen((_) => load()));
    }
    load();
  }

  @override
  void dispose() {
    generation++;
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    scroll.dispose();
    super.dispose();
  }

  Future<void> load() async {
    final request = ++generation;
    setState(() {
      loading = true;
      access.clear();
      errors.clear();
      // A revoked provider role must never leave the dashboard selected.
      if (section == 'provider') section = 'courses';
    });
    final next = <int, Map<String, dynamic>>{};
    final failures = <int, String>{};
    for (final repo in repos) {
      if (!repo.signedIn) continue;
      final account = repo.accountId;
      try {
        final result = await repo.call('access');
        if (account == repo.accountId) next[repo.courseNumber] = result;
      } catch (_) {
        failures[repo.courseNumber] =
            'Course access could not be loaded. Please retry.';
      }
      if (!mounted || request != generation) return;
    }
    if (!mounted || request != generation) return;
    setState(() {
      access.addAll(next);
      errors.addAll(failures);
      loading = false;
    });
  }

  int completed(CeRepository repo) =>
      ((access[repo.courseNumber]?['module_statuses'] as Map?) ?? {}).values
          .where((m) => m is Map && m['completed'] == true)
          .length
          .clamp(0, repo.moduleCount);

  Future<void> openCourse(
    CeRepository repo, {
    bool registration = false,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CeCourseScreen(
          repository: repo,
          initialSection: registration ? 'details' : 'catalog',
        ),
      ),
    );
    if (mounted) await load();
  }

  Future<void> openCertificate(CeRepository repo) async {
    final profile = access[repo.courseNumber]?['profile'] as Map? ?? {};
    if ((profile['full_name'] as String? ?? '').isEmpty) {
      await openCourse(repo, registration: true);
      return;
    }
    final edit = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CeCertificateScreen(repository: repo)),
    );
    if (!mounted) return;
    if (edit == true) {
      await openCourse(repo, registration: true);
    } else {
      await load();
    }
  }

  void showSection(String value) {
    setState(() => section = value);
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  Widget heading(String text) =>
      Text(text, style: lumaDisplay(size: 30, color: ceNavy));
  Widget description(String text) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 24),
    child: Text(text, style: lumaBody(color: LumaColors.inkMuted)),
  );

  Widget card(CeRepository repo, double width) {
    final state = access[repo.courseNumber] ?? {};
    final count = completed(repo);
    final hasAccess = state['has_access'] == true;
    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 208),
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: ceNavy,
                border: Border(bottom: BorderSide(color: ceGold, width: 3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'COURSE ${repo.courseNumber.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: ceGold,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/branding/ce_halo_symbol.png',
                        width: 32,
                        height: 38,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    repo.courseTitle,
                    style: lumaDisplay(size: 24, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '20.00 MAC Ed CE credits',
                    style: lumaBody(size: 18, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${repo.moduleCount} modules · AANA prior approved',
                    style: lumaBody(size: 13, color: LumaColors.inkMuted),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    errors.containsKey(repo.courseNumber)
                        ? 'Access unavailable'
                        : loading
                        ? 'Checking access…'
                        : !hasAccess
                        ? 'View course information'
                        : state['is_preview'] == true
                        ? '${state['is_sandbox'] == true ? 'Sandbox preview' : 'Creator access'} · $count/${repo.moduleCount} preview modules'
                        : '$count of ${repo.moduleCount} modules complete',
                    style: lumaBody(size: 12, color: LumaColors.inkMuted),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: count / repo.moduleCount,
                    color: ceNavy,
                    backgroundColor: LumaColors.cream,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => openCourse(repo),
                      child: Text(hasAccess ? 'Open course' : 'View course'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> courses() {
    final underway = repos
        .where(
          (r) =>
              access[r.courseNumber]?['has_access'] == true &&
              ((access[r.courseNumber]?['module_statuses'] as Map?) ?? {})
                  .values
                  .any((m) => m is Map && m['read'] == true) &&
              completed(r) < r.moduleCount,
        )
        .firstOrNull;
    return [
      heading('Course library'),
      description('Your courses, progress, and next steps. All in one place.'),
      if (underway != null) ...[
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PICK UP WHERE YOU LEFT OFF',
                  style: TextStyle(fontSize: 12, color: Color(0xFF76603C)),
                ),
                const SizedBox(height: 10),
                Text(underway.courseTitle, style: lumaDisplay(size: 22)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => openCourse(underway),
                  child: const Text('Continue learning'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
      LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1000
              ? 3
              : constraints.maxWidth >= 640
              ? 2
              : 1;
          final width = (constraints.maxWidth - 20 * (columns - 1)) / columns;
          return Wrap(
            spacing: 20,
            runSpacing: 24,
            children: [for (final repo in repos) card(repo, width)],
          );
        },
      ),
    ];
  }

  List<Widget> certificates() => [
    heading('My certificates'),
    description(
      'Review each course’s requirements and retrieve its certificate when eligible. '
      'Official credits require all modules, passing quizzes, and evaluations. '
      'Creator previews do not award credits.',
    ),
    LayoutBuilder(
      builder: (context, constraints) {
        // Reserve the tallest title for every card, without truncating long names
        // or relying on fixed heights that break at larger accessibility sizes.
        final titleStyle = DefaultTextStyle.of(context).style
            .merge(lumaDisplay(size: 22));
        var titleHeight = 0.0;
        for (final repo in repos) {
          final painter = TextPainter(
            text: TextSpan(text: repo.courseTitle, style: titleStyle),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout(maxWidth: constraints.maxWidth - 48);
          if (painter.height > titleHeight) titleHeight = painter.height;
          painter.dispose();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final repo in repos)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  key: ValueKey('ce-certificate-card-${repo.courseNumber}'),
                  margin: EdgeInsets.zero,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: titleHeight,
                          child: Text(repo.courseTitle, style: titleStyle),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '20.00 MAC Ed CE credits · Course ID ${repo.courseId}',
                        ),
                        const SizedBox(height: 16),
                        if (access[repo.courseNumber]?['has_access'] == true)
                          FilledButton(
                            onPressed: () => openCertificate(repo),
                            child: const Text(
                              'View certificate & requirements',
                            ),
                          )
                        else
                          OutlinedButton(
                            onPressed: () => openCourse(repo),
                            child: const Text('View course access'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  ];

  List<Widget> providerDashboard() => [
    heading('Provider dashboard'),
    description(
      'Choose a course to view account-linked completion records and monthly '
      'AANA reporting exports. Preview activity is separate from reportable credits.',
    ),
    for (final repo in repos)
      if (access[repo.courseNumber]?['is_provider'] == true)
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(repo.courseTitle, style: lumaDisplay(size: 22)),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => CeRecordsScreen(repository: repo),
                    ),
                  ),
                  icon: const Icon(Icons.table_view_outlined),
                  label: const Text('Records & monthly exports'),
                ),
              ],
            ),
          ),
        ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/branding/ce_halo_symbol.png',
            width: 28,
            height: 36,
          ),
          const SizedBox(width: 10),
          const Flexible(child: Text('CE HALO', maxLines: 1)),
        ],
      ),
      actions: [
        const LumaHomeButton(),
        IconButton(
          tooltip: 'Refresh course access',
          onPressed: loading ? null : load,
          icon: const Icon(Icons.refresh),
        ),
        if (!demo)
          IconButton(
            tooltip: signedIn ? 'My account' : 'Sign in',
            onPressed: () async {
              await Navigator.of(context).pushNamed('/account');
              if (mounted) await load();
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
      ],
    ),
    body: SafeArea(
      child: Column(
        children: [
          if (demo)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: ceNavy,
              child: const Text(
                'DESIGN PREVIEW · No payment or CE credit is recorded',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                for (final item in const {
                  'courses': 'Courses',
                  'certificates': 'My certificates',
                  'provider': 'Provider dashboard',
                }.entries)
                  if (item.key != 'provider' || provider)
                    TextButton(
                      onPressed: () => showSection(item.key),
                      style: TextButton.styleFrom(
                        backgroundColor: section == item.key
                            ? LumaColors.cream
                            : null,
                        textStyle: TextStyle(
                          fontWeight: section == item.key
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      child: Text(item.value),
                    ),
              ],
            ),
          ),
          if (loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: SingleChildScrollView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 36),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (errors.isNotEmpty) ...[
                        const Text(
                          'Some course progress could not be loaded. '
                          'Your saved records have not changed.',
                        ),
                        TextButton(
                          onPressed: load,
                          child: const Text('Retry access'),
                        ),
                        const SizedBox(height: 16),
                      ],
                      ...switch (section) {
                        'certificates' => certificates(),
                        'provider' when provider => providerDashboard(),
                        _ => courses(),
                      },
                      const SizedBox(height: 32),
                      const Center(
                        child: Text(
                          'CE HALO LLC · info@cehalo.com',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
