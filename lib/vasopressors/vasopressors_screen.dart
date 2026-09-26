import 'package:flutter/material.dart';
import '../widgets/luma_home_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../shared/luma_theme_tokens.dart';
import '../blood_products/blood_products_view.dart';
import '../data/medication_public_fields.dart';
import 'drug_detail_screen.dart';

/// Vasopressors, Infusions & Transfusions.
///
/// Three tabs backed by Supabase columns:
///   - Vasopressors: medication.vasoactive_role = 'vasopressor'
///   - Infusions:    medication.vasoactive_role = 'infusion'
///   - Transfusions: blood_products (all rows)
///
/// Hemodynamic filters use medication.hemodynamic_tags (text[]).
class VasopressorsScreen extends StatefulWidget {
  const VasopressorsScreen(
      {super.key, this.loadMedications, this.loadBloodProducts});

  final Future<List<Map<String, dynamic>>> Function()? loadMedications;
  final Future<List<Map<String, dynamic>>> Function()? loadBloodProducts;

  @override
  State<VasopressorsScreen> createState() => _VasopressorsScreenState();
}

class _VasopressorsScreenState extends State<VasopressorsScreen> {
  int _tabIndex = 0; // 0 = Vasopressors, 1 = Infusions, 2 = Transfusions
  String _activeFilter = 'ALL';
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> _vasopressors = [];
  List<Map<String, dynamic>> _infusions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMedications();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMedications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await (widget.loadMedications?.call() ?? _fetchMedications())
          .timeout(const Duration(seconds: 20));

      final list = List<Map<String, dynamic>>.from(rows);
      String sortKey(Map<String, dynamic> r) => (r['name'] ?? '')
          .toString()
          .trim()
          .toLowerCase()
          .replaceFirst(RegExp(r'^[^a-z0-9]+'), '');
      list.sort((a, b) => sortKey(a).compareTo(sortKey(b)));
      final v =
          list.where((r) => r['vasoactive_role'] == 'vasopressor').toList();
      final i = list.where((r) => r['vasoactive_role'] == 'infusion').toList();

      if (!mounted) return;
      setState(() {
        _vasopressors = v;
        _infusions = i;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'Unable to load medications. Check your connection and try again.';
        _loading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMedications() async {
    final rows = await Supabase.instance.client
        .from('medication')
        .select(medicationPublicFields)
        .not('vasoactive_role', 'is', null)
        .order('name');
    return List<Map<String, dynamic>>.from(rows);
  }

  List<Map<String, dynamic>> get _currentList {
    final base = _tabIndex == 0 ? _vasopressors : _infusions;

    return base.where((drug) {
      // Filter chip
      if (_activeFilter != 'ALL') {
        final tags = (drug['hemodynamic_tags'] as List?)?.cast<String>() ?? [];
        if (_activeFilter == 'HIGH ALERT') {
          if (drug['high_alert'] != true) return false;
        } else {
          final needed = _filterToTag(_activeFilter);
          if (needed != null && !tags.contains(needed)) return false;
        }
      }
      // Search
      if (_searchQuery.isNotEmpty) {
        final hay =
            '${drug['name'] ?? ''} ${drug['brand_name'] ?? ''} ${drug['class_short'] ?? ''}'
                .toLowerCase();
        if (!hay.contains(_searchQuery)) return false;
      }
      return true;
    }).toList();
  }

  String? _filterToTag(String label) {
    switch (label) {
      case 'RAISES BP':
        return 'raises_bp';
      case 'LOWERS BP':
        return 'lowers_bp';
      case 'RAISES HR':
        return 'raises_hr';
      case 'LOWERS HR':
        return 'lowers_hr';
      case 'RAISES CO':
        return 'raises_co';
    }
    return null;
  }

  List<String> get _filtersForTab {
    if (_tabIndex == 0) {
      return const ['ALL', 'RAISES BP', 'RAISES HR', 'RAISES CO', 'HIGH ALERT'];
    }
    return const ['ALL', 'LOWERS BP', 'LOWERS HR', 'RAISES BP', 'HIGH ALERT'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LumaTokens.creamSoft,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSegmentedControl(),
            if (_tabIndex != 2) ...[
              _buildSearchBar(),
              _buildFilterRow(),
            ],
            const SizedBox(height: 4),
            Container(height: 0.5, color: LumaTokens.hairlineNavy),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back,
                color: LumaTokens.textPrimary, size: 20),
            tooltip: 'Back',
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Expanded(
            child: Center(
              child: Text(
                'VASOPRESSORS · INFUSIONS · TRANSFUSIONS',
                textAlign: TextAlign.center,
                style: LumaTokens.eyebrow.copyWith(letterSpacing: 1),
              ),
            ),
          ),
          const LumaHomeButton(),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final labels = ['VASOPRESSORS', 'INFUSIONS', 'TRANSFUSIONS'];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(labels.length, (i) {
          final active = _tabIndex == i;
          return Expanded(
            child: Semantics(
              selected: active,
              child: TextButton(
                onPressed: () => setState(() {
                  _tabIndex = i;
                  _activeFilter = 'ALL';
                  _searchCtrl.clear();
                }),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
                  minimumSize: const Size(48, 48),
                ),
                child: Column(
                  children: [
                    Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: active
                          ? LumaTokens.filterActive
                              .copyWith(fontSize: 11, letterSpacing: 0.2)
                          : LumaTokens.filterInactive
                              .copyWith(fontSize: 11, letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 1.5,
                      width: 36,
                      color:
                          active ? LumaTokens.goldPrimary : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: LumaTokens.hairlineNavy, width: 0.5)),
        ),
        child: TextField(
          controller: _searchCtrl,
          style: LumaTokens.body,
          decoration: InputDecoration(
            icon: Icon(Icons.search, size: 16, color: LumaTokens.textMuted),
            hintText: 'Search drugs',
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: _searchCtrl.clear,
                  ),
            hintStyle: LumaTokens.bodyMuted,
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filtersForTab.length,
        separatorBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('·', style: LumaTokens.filterInactive),
        ),
        itemBuilder: (context, index) {
          final label = _filtersForTab[index];
          final active = _activeFilter == label;
          return Semantics(
            selected: active,
            child: TextButton(
              onPressed: () => setState(() => _activeFilter = label),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: active
                          ? LumaTokens.filterActive
                          : LumaTokens.filterInactive),
                  const SizedBox(height: 3),
                  Container(
                    height: 1,
                    width: label.length * 6.5,
                    color: active ? LumaTokens.goldPrimary : Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_tabIndex == 2) {
      return BloodProductsView(load: widget.loadBloodProducts);
    }
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: LumaTokens.goldPrimary));
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!,
                style: LumaTokens.bodyMuted, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
                onPressed: _loadMedications, child: const Text('Retry')),
          ],
        )),
      );
    }

    final list = _currentList;
    if (list.isEmpty) {
      final hasFilters = _searchQuery.isNotEmpty || _activeFilter != 'ALL';
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
              hasFilters
                  ? 'No medications match your search or filter.'
                  : 'No medications are available in this tab.',
              style: LumaTokens.bodyMuted,
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: hasFilters
                ? () => setState(() {
                      _activeFilter = 'ALL';
                      _searchCtrl.clear();
                    })
                : _loadMedications,
            child: Text(hasFilters ? 'Clear search and filters' : 'Retry'),
          ),
        ]),
      ));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              Text(
                '${list.length} OF ${_tabIndex == 0 ? _vasopressors.length : _infusions.length} DRUGS',
                style: LumaTokens.eyebrow,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _buildDrugCard(list[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildDrugCard(Map<String, dynamic> drug) {
    final highAlert = drug['high_alert'] == true;
    final name = drug['name'] ?? '';
    final brand = (drug['brand_name'] ?? '').toString();
    final classShort = (drug['class_short'] ?? '').toString();

    return LumaCard(
      highAlert: highAlert,
      onTap: () => _openDrugDetail(drug),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (highAlert) ...[
            Text('HIGH-ALERT MEDICATION', style: LumaTokens.highAlertLabel),
            const SizedBox(height: 6),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(name, style: LumaTokens.drugName),
                    if (brand.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(brand,
                          style: LumaTokens.drugName.copyWith(
                            fontStyle: FontStyle.italic,
                            color: LumaTokens.goldDeep,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          )),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: LumaTokens.textMuted),
            ],
          ),
          if (classShort.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(classShort.toUpperCase(), style: LumaTokens.classLabel),
          ],
          const SizedBox(height: 10),
          Text('View dosing, preparation & safety',
              style: LumaTokens.bodyMuted),
        ],
      ),
    );
  }

  void _openDrugDetail(Map<String, dynamic> drug) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DrugDetailScreen(drug: drug)),
    );
  }
}
