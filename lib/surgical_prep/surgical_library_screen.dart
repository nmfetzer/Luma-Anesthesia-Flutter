import 'package:flutter/material.dart';

import '../theme/luma_theme.dart';
import '../widgets/luma_home_button.dart';
import '../widgets/premium_access_gate.dart';
import 'surgical_catalog.dart';
import 'surgical_case.dart';
import 'surgical_case_screen.dart';

String surgicalSpecialtySlug(String category) => category
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');
String surgicalSpecialtyRoute(String category) =>
    '/surgical-prep/specialty/${surgicalSpecialtySlug(category)}';

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
  Widget build(BuildContext context) {
    if (caseId == 'escharotomy-fasciotomy-for-burns') {
      // Preserve the former combined reference URL without conflating procedures.
      return PremiumAccessGate(
        checkAccess: checkAccess,
        accessChanges: accessChanges,
        builder: (_) => const SurgicalLibraryScreen(category: 'Burns'),
      );
    }
    final specialty = caseId?.startsWith('specialty/') ?? false;
    if (caseId == null || specialty) {
      String? category;
      if (specialty) {
        for (final c in surgicalCategories.where((c) => c != 'All')) {
          if (surgicalSpecialtySlug(c) ==
              caseId!.substring('specialty/'.length)) {
            category = c;
            break;
          }
        }
      }
      return PremiumAccessGate(
        checkAccess: checkAccess,
        accessChanges: accessChanges,
        builder: (_) => specialty && category == null
            ? const _MissingCase(specialty: true)
            : SurgicalLibraryScreen(category: category),
      );
    }
    return _CaseLoader(
      caseId: caseId!,
      checkAccess: checkAccess,
      accessChanges: accessChanges,
    );
  }
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
  Widget build(BuildContext context) =>
      FutureBuilder<Map<String, SurgicalCaseReference>>(
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
          if (snapshot.connectionState != ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Surgical case'),
                actions: const [LumaHomeButton()],
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          return _MissingCase(
            error: snapshot.hasError,
            retry: () => setState(() => _data = SurgicalCatalog.load()),
          );
        },
      );
}

class _MissingCase extends StatelessWidget {
  const _MissingCase({this.specialty = false, this.error = false, this.retry});
  final bool specialty, error;
  final VoidCallback? retry;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Surgical Case Prep'),
      actions: const [LumaHomeButton()],
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              error
                  ? 'The bundled case library could not be loaded.'
                  : specialty
                  ? 'This specialty could not be found.'
                  : 'This surgical case could not be found.',
            ),
            if (error) TextButton(onPressed: retry, child: const Text('Retry')),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/surgical-prep'),
              child: const Text('Browse specialties'),
            ),
          ],
        ),
      ),
    ),
  );
}

class SurgicalLibraryScreen extends StatefulWidget {
  const SurgicalLibraryScreen({super.key, this.category});
  final String? category;
  @override
  State<SurgicalLibraryScreen> createState() => _SurgicalLibraryScreenState();
}

class _SurgicalLibraryScreenState extends State<SurgicalLibraryScreen> {
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Widget _caseTile(SurgicalCaseIndex c) => Card(
    color: LumaColors.creamElevated,
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: widget.category == null
          ? Text(c.category)
          : [
              'biliopancreatic-diversion-duodenal-switch',
              'sadi-s',
            ].contains(c.id)
          ? const Text('Less common procedure')
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).pushNamed(c.route),
    ),
  );

  Widget _specialties() => LayoutBuilder(
    builder: (context, constraints) {
      final largeText = MediaQuery.textScalerOf(context).scale(16) > 22;
      final columns = largeText || constraints.maxWidth < 340
          ? 1
          : constraints.maxWidth >= 750
          ? 3
          : 2;
      final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
      final categories = surgicalCategories.where((c) => c != 'All').toList();
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final category in categories)
            SizedBox(
              width: width,
              child: Card(
                margin: EdgeInsets.zero,
                color: LumaColors.creamElevated,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () =>
                      Navigator.of(context)
                          .pushNamed(surgicalSpecialtyRoute(category)),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 100),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final isSearching = _search.text.trim().isNotEmpty;
    final showCases = widget.category != null || isSearching;
    final matches = searchSurgicalCases(
      _search.text,
      category: widget.category ?? 'All',
    );
    const preferredOrder = {
      'ENT & shared airway': [
        'functional-endoscopic-sinus-surgery-fess',
        'septoplasty-turbinate-reduction',
        'tonsillectomy-and-adenoidectomy-t-a-adult',
        'tympanoplasty',
        'mastoidectomy',
        'myringotomy-with-tube-placement-adult',
        'parotidectomy-superficial-total',
        'neck-dissection-radical-modified-selective',
        'laryngectomy-total-partial',
        'microlaryngoscopy-vocal-cord-surgery',
        'airway-foreign-body-removal',
        'awake-fiber-optic-intubation-afoi',
        'tracheal-intubation-for-epiglottitis',
        'maxillofacial-trauma-surgery-panfacial-fractures',
      ],
      'Bariatric': [
        'sleeve-gastrectomy',
        'roux-en-y-gastric-bypass-rygb',
        'adjustable-gastric-band-lap-band',
        'biliopancreatic-diversion-duodenal-switch',
        'sadi-s',
      ],
      'Burns': [
        'burn-wound-debridement-excision',
        'burn-excision-and-split-thickness-skin-grafting',
        'burn-full-thickness-graft-flap-reconstruction',
        'burn-escharotomy',
        'burn-fasciotomy',
        'burn-related-amputation',
        'burn-contracture-release-reconstruction',
      ],
      'Dental & maxillofacial': [
        'dental-rehabilitation-under-general-anesthesia-adult',
        'orthognathic-surgery-bimaxillary-osteotomy',
      ],
      'Colorectal': [
        'colectomy-open-laparoscopic-robotic',
        'low-anterior-resection-lar',
        'abdominoperineal-resection-apr',
        'ostomy-creation-reversal-ileostomy-colostomy',
        'bowel-obstruction-surgery-open-laparoscopic',
        'hemorrhoidectomy',
        'anal-fistula-repair-fistulotomy-lift-seton',
      ],
      'Cardiac & thoracic': [
        'cabg-coronary-artery-bypass-grafting',
        'aortic-valve-replacement-avr',
        'mitral-valve-repair-replacement',
        'tricuspid-valve-repair-replacement',
        'cardiac-valve-repair-replacement-open',
        'aortic-root-ascending-aorta-repair',
        'thoracic-aortic-aneurysm-repair-tevar-open-descending',
        'lvad-placement-left-ventricular-assist-device',
        'heart-transplant',
        'ecmo-cannulation-decannulation',
        'cardiac-catheterization-pci',
        'pericardial-window',
        'lobectomy-vats-open',
        'pneumonectomy',
        'vats-wedge-resection',
        'thoracotomy-open-exploratory-thoracotomy',
        'esophagectomy-ivor-lewis-mckeown-minimally-invasive',
        'lung-transplant-single-double',
        'mediastinal-mass-resection',
        'thymectomy-vats-open-robotic',
        'mediastinoscopy',
        'decortication-pleural',
        'pleurodesis-chemical-surgical-vats',
        'chest-wall-resection-and-reconstruction',
        'bronchoscopy-flexible-rigid',
      ],
    };
    final order = preferredOrder[widget.category];
    if (!isSearching && order != null) {
      matches.sort((a, b) {
        final ai = order.indexOf(a.id);
        final bi = order.indexOf(b.id);
        return (ai < 0 ? order.length : ai).compareTo(
          bi < 0 ? order.length : bi,
        );
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category ?? 'Surgical Case Prep',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: const [LumaHomeButton()],
      ),
      body: SafeArea(
        top: false,
        // The app-wide Quick Ref shortcut floats outside this Scaffold.
        // Keep the scroll viewport above it, including at larger text sizes.
        minimum: EdgeInsets.only(
          bottom: MediaQuery.textScalerOf(context).scale(48) + 36,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.category != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () =>
                                  Navigator.of(context)
                                      .pushReplacementNamed('/surgical-prep'),
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: const Text('All specialties'),
                            ),
                          ),
                        Text(
                          widget.category == null
                              ? 'Choose a specialty'
                              : '${widget.category} cases',
                          style: lumaDisplay(size: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.category == null
                              ? 'Open a specialty to browse its clinical case references.'
                              : 'Select a procedure for its quick overview and detailed anesthesia considerations.',
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Clinical review drafts · Not yet approved for release',
                          style: TextStyle(color: LumaColors.inkMuted),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _search,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: widget.category == null
                                ? 'Search all surgical cases'
                                : 'Search ${widget.category} cases',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _search.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear case search',
                                    icon: const Icon(Icons.close),
                                    onPressed: () => setState(_search.clear),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (widget.category == null && isSearching)
                          const Text('Matching cases across specialties'),
                      ],
                    ),
                  ),
                ),
                if (!showCases)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    sliver: SliverToBoxAdapter(child: _specialties()),
                  ),
                if (showCases && matches.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text('No matching cases. Try another term.'),
                          TextButton(
                            onPressed: () => setState(_search.clear),
                            child: const Text('Reset search'),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (showCases)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    sliver: SliverList.builder(
                      itemCount: matches.length,
                      itemBuilder: (_, i) => _caseTile(matches[i]),
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
