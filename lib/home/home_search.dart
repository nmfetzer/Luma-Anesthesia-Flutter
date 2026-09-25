import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';
import '../data/medication_repository.dart';
import '../models/medication.dart';
import '../screens/drug_detail_screen.dart';
import '../special_considerations/special_consideration.dart';
import '../special_considerations/special_consideration_detail_screen.dart';
import '../special_considerations/special_consideration_repository.dart';

const pathophysiologyTitle = 'Pathophysiology & Anesthesia Considerations';

class HomeSearchSection {
  const HomeSearchSection(this.title, this.route, {this.keywords = ''});
  final String title;
  final String route;
  final String keywords;
}

class HomeSearchData {
  const HomeSearchData({
    this.medications = const [],
    this.conditions = const [],
    this.unavailable = const [],
  });
  final List<Medication> medications;
  final List<SpecialConsiderationEntry> conditions;
  final List<String> unavailable;
}

/// Search indexes only free medication fields and public condition metadata.
/// Opening a condition uses the existing server-enforced entitlement flow.
class HomeSearch extends StatefulWidget {
  const HomeSearch({super.key, required this.sections, this.loadData});
  final List<HomeSearchSection> sections;
  final Future<HomeSearchData> Function()? loadData;

  @override
  State<HomeSearch> createState() => _HomeSearchState();
}

class _HomeSearchState extends State<HomeSearch> {
  final _controller = SearchController();
  Future<HomeSearchData>? _data;

  Future<HomeSearchData> _load() async {
    if (widget.loadData != null) {
      try {
        return await widget.loadData!();
      } catch (_) {
        return const HomeSearchData(unavailable: ['Library']);
      }
    }
    var medications = <Medication>[];
    var conditions = <SpecialConsiderationEntry>[];
    final unavailable = <String>[];
    await Future.wait([
      () async {
        try {
          medications = await MedicationRepository.instance
              .all()
              .timeout(const Duration(seconds: 20));
        } catch (_) {
          unavailable.add('Drug Library');
        }
      }(),
      () async {
        try {
          if (LumaConfig.supabaseConfigured) {
            conditions = await SupabaseSpecialConsiderationRepository(
                    Supabase.instance.client)
                .catalog()
                .timeout(const Duration(seconds: 20));
          }
        } catch (_) {
          unavailable.add(pathophysiologyTitle);
        }
      }(),
    ]);
    return HomeSearchData(
      medications: medications,
      conditions: conditions.where((e) => e.isPublished).toList(),
      unavailable: unavailable,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open(Widget? screen, {String? route}) {
    final navigator = Navigator.of(context);
    _controller.closeView('');
    if (route != null) {
      navigator.pushNamed(route);
    } else {
      navigator.push(MaterialPageRoute<void>(builder: (_) => screen!));
    }
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SearchAnchor(
          searchController: _controller,
          viewHintText: 'Search drugs, conditions, or sections',
          viewBackgroundColor: const Color(0xFFF7F1E6),
          viewConstraints: const BoxConstraints(maxWidth: 640, maxHeight: 620),
          builder: (context, controller) => SearchBar(
            controller: controller,
            hintText: 'Search drugs, pathophysiology & more',
            textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 14)),
            backgroundColor: const WidgetStatePropertyAll(Color(0xFFF7F1E6)),
            constraints: const BoxConstraints(minHeight: 48),
            leading: const Icon(Icons.search),
            onTap: controller.openView,
            onChanged: (_) => controller.openView(),
          ),
          suggestionsBuilder: (context, controller) {
            _data ??= _load();
            return [
              FutureBuilder<HomeSearchData>(
                future: _data,
                builder: (context, snapshot) => _results(
                    controller.text, snapshot.data,
                    loading: snapshot.connectionState != ConnectionState.done,
                    failed: snapshot.hasError),
              ),
            ];
          },
        ),
      );

  Widget _results(String query, HomeSearchData? data,
      {required bool loading, required bool failed}) {
    final words = query.toLowerCase().trim().split(RegExp(r'\s+'));
    final searching = query.trim().isNotEmpty;
    bool matches(String text) =>
        words.every((word) => text.toLowerCase().contains(word));
    final sections = widget.sections
        .where((s) => matches('${s.title} ${s.keywords}'))
        .toList();
    final medications = searching
        ? (data?.medications ?? [])
            .where((m) => matches(
                '${m.name} ${m.brandName ?? ''} ${m.category} ${m.classShort ?? ''}'))
            .toList()
        : <Medication>[];
    final conditions = searching
        ? (data?.conditions ?? [])
            .where((e) =>
                e.isPublished &&
                matches('${e.title} ${e.category} ${e.searchTags.join(' ')}'))
            .toList()
        : <SpecialConsiderationEntry>[];
    final navigator = Navigator.of(this.context);
    Widget heading(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child:
              Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (sections.isNotEmpty) heading('App sections'),
        for (final section in sections)
          ListTile(
            title: Text(section.title),
            leading: const Icon(Icons.grid_view_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(null, route: section.route),
          ),
        if (medications.isNotEmpty)
          heading('Drug Library · ${medications.length} results'),
        for (final medication in medications.take(30))
          ListTile(
            title: Text(medication.name),
            subtitle: Text(medication.brandName ?? medication.category),
            leading: const Icon(Icons.medication_outlined),
            onTap: () => _open(DrugDetailScreen(medication: medication)),
          ),
        if (conditions.isNotEmpty)
          heading('$pathophysiologyTitle · ${conditions.length} results'),
        for (final entry in conditions.take(30))
          ListTile(
            title: Text(entry.title),
            subtitle: Text(entry.category),
            leading: const Icon(Icons.menu_book_outlined),
            onTap: () => _open(SpecialConsiderationDetailScreen(
              entry: entry,
              repository: SupabaseSpecialConsiderationRepository(
                  Supabase.instance.client),
              onSignIn: () => navigator.pushNamed('/account'),
              onSubscribe: () => navigator.pushNamed('/subscribe'),
            )),
          ),
        if (medications.length > 30 || conditions.length > 30)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Showing the first 30 matches in each library. '
                'Keep typing to narrow your search.'),
          ),
        if (loading && searching)
          const ListTile(
            leading: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)),
            title: Text('Loading library results…'),
          ),
        if (failed || (data?.unavailable.isNotEmpty ?? false))
          ListTile(
            title: const Text('Some library results could not load.'),
            subtitle: const Text('Check your connection, then retry. '
                'App sections are still available.'),
            trailing: TextButton(
              onPressed: () {
                _data = null;
                _controller.closeView(query);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _controller.openView();
                });
              },
              child: const Text('Retry'),
            ),
          ),
        if (!loading &&
            !failed &&
            searching &&
            sections.isEmpty &&
            medications.isEmpty &&
            conditions.isEmpty &&
            (data?.unavailable.isEmpty ?? true))
          const Padding(
            padding: EdgeInsets.all(24),
            child:
                Text('No matches yet. Try a drug name, condition, or section.'),
          ),
      ],
    );
  }
}
