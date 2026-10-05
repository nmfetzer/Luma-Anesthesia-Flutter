import 'package:flutter/material.dart';

import '../theme/luma_theme.dart';
import '../widgets/luma_home_button.dart';
import '../widgets/premium_access_gate.dart';
import 'surgical_catalog.dart';
import 'surgical_case.dart';
import 'surgical_case_screen.dart';

class SurgicalPrepFeature extends StatelessWidget {
  const SurgicalPrepFeature({
    super.key,
    this.caseId,
    this.checkAccess,
    this.accessChanges,
  });
  final String? caseId;
  final Future<bool> Function()? checkAccess;
  final Stream<void>? accessChanges;
  @override
  Widget build(BuildContext context) => caseId == null
      ? PremiumAccessGate(
          checkAccess: checkAccess,
          accessChanges: accessChanges,
          builder: (_) => const SurgicalLibraryScreen(),
        )
      // The detail reader owns its gate. Loading bundled bytes does not display
      // clinical content and must not duplicate an entitlement request.
      : _CaseLoader(
          caseId: caseId!,
          checkAccess: checkAccess,
          accessChanges: accessChanges,
        );
}

class _CaseLoader extends StatefulWidget {
  const _CaseLoader({
    required this.caseId,
    this.checkAccess,
    this.accessChanges,
  });
  final String caseId;
  final Future<bool> Function()? checkAccess;
  final Stream<void>? accessChanges;
  @override
  State<_CaseLoader> createState() => _CaseLoaderState();
}

class _CaseLoaderState extends State<_CaseLoader> {
  late Future<Map<String, SurgicalCaseReference>> _data =
      SurgicalCatalog.load();
  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<Map<String, SurgicalCaseReference>>(
    future: _data,
    builder: (context, snapshot) {
      final reference = snapshot.data?[widget.caseId];
      if (reference != null) {
        return SurgicalCaseScreen(
          reference: reference,
          checkAccess: widget.checkAccess,
          accessChanges: widget.accessChanges,
        );
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text('Surgical case'),
          actions: const [LumaHomeButton()],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: snapshot.connectionState != ConnectionState.done
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        snapshot.hasError
                            ? 'The bundled case library could not be loaded.'
                            : 'This surgical case could not be found.',
                      ),
                      if (snapshot.hasError)
                        TextButton(
                          onPressed: () =>
                              setState(() => _data = SurgicalCatalog.load()),
                          child: const Text('Retry'),
                        ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context)
                                .pushReplacementNamed('/surgical-prep'),
                        child: const Text('Browse surgical cases'),
                      ),
                    ],
                  ),
          ),
        ),
      );
    },
  );
}

class SurgicalLibraryScreen extends StatefulWidget {
  const SurgicalLibraryScreen({super.key});
  @override
  State<SurgicalLibraryScreen> createState() => _SurgicalLibraryScreenState();
}

class _SurgicalLibraryScreenState extends State<SurgicalLibraryScreen> {
  final _search = TextEditingController();
  String _category = 'All';
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matches = searchSurgicalCases(_search.text, category: _category);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Surgical Case Prep',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: const [LumaHomeButton()],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Adult & OB cases', style: lumaDisplay(size: 28)),
                        const SizedBox(height: 8),
                        const Text(
                          'Quick clinical overviews with expandable perioperative references.',
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Clinical review drafts · Not yet approved for release',
                          style: TextStyle(color: LumaColors.inkMuted),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _search,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Search surgical cases',
                            hintText:
                                'Procedure, abbreviation or clinical topic',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _search.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear case search',
                                    onPressed: () => setState(_search.clear),
                                    icon: const Icon(Icons.close),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          key: ValueKey(_category),
                          initialValue: _category,
                          isExpanded: true,
                          itemHeight: null,
                          decoration: const InputDecoration(
                            labelText: 'Specialty',
                          ),
                          items: surgicalCategories
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _category = v ?? 'All'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (matches.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'No matching surgical cases. Try another term or specialty.',
                          ),
                          TextButton(
                            onPressed: () => setState(() {
                              _search.clear();
                              _category = 'All';
                            }),
                            child: const Text('Reset search and filters'),
                          ),
                        ],
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  sliver: SliverList.builder(
                    itemCount: matches.length,
                    itemBuilder: (context, i) {
                      final c = matches[i];
                      return Card(
                        color: LumaColors.creamElevated,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          title: Text(
                            c.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(c.category),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).pushNamed(c.route),
                        ),
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
