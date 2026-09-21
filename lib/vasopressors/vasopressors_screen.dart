import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../shared/luma_theme_tokens.dart';
import '../blood_products/blood_products_view.dart';

/// Vasopressors, Infusions & Transfusions.
///
/// Three tabs backed by Supabase columns:
///   - Vasopressors: medication.vasoactive_role = 'vasopressor'
///   - Infusions:    medication.vasoactive_role = 'infusion'
///   - Transfusions: blood_products (all rows)
///
/// Hemodynamic filters use medication.hemodynamic_tags (text[]).
class VasopressorsScreen extends StatefulWidget {
  const VasopressorsScreen({super.key});

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
    try {
      final rows = await Supabase.instance.client
          .from('medication')
          .select(
              'id, name, brand_name, class_short, category, high_alert, hemodynamic_tags, vasoactive_role, adult_dose, indications, mechanism, clinical_pearls, contraindications, warnings_precautions')
          .not('vasoactive_role', 'is', null)
          .order('name');

      final list = List<Map<String, dynamic>>.from(rows as List);
      final v = list.where((r) => r['vasoactive_role'] == 'vasopressor').toList();
      final i = list.where((r) => r['vasoactive_role'] == 'infusion').toList();

      if (!mounted) return;
      setState(() {
        _vasopressors = v;
        _infusions = i;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
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
      case 'RAISES BP': return 'raises_bp';
      case 'LOWERS BP': return 'lowers_bp';
      case 'RAISES HR': return 'raises_hr';
      case 'LOWERS HR': return 'lowers_hr';
      case 'RAISES CO': return 'raises_co';
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
            icon: const Icon(Icons.arrow_back, color: LumaTokens.textPrimary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Expanded(
            child: Center(
              child: Text(
                'VASOPRESSORS · INFUSIONS · TRANSFUSIONS',
                style: LumaTokens.eyebrow.copyWith(letterSpacing: 1.8),
              ),
            ),
          ),
          const SizedBox(width: 32),
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
          return Padding(
            padding: const EdgeInsets.only(right: 22),
            child: GestureDetector(
              onTap: () => setState(() {
                _tabIndex = i;
                _activeFilter = 'ALL';
              }),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labels[i],
                    style: active
                        ? LumaTokens.filterActive.copyWith(fontSize: 12, letterSpacing: 1.5)
                        : LumaTokens.filterInactive.copyWith(fontSize: 12, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 1.5,
                    width: labels[i].length * 8.0,
                    color: active ? LumaTokens.goldPrimary : Colors.transparent,
                  ),
                ],
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
          border: Border(bottom: BorderSide(color: LumaTokens.hairlineNavy, width: 0.5)),
        ),
        child: TextField(
          controller: _searchCtrl,
          style: LumaTokens.body,
          decoration: InputDecoration(
            icon: Icon(Icons.search, size: 16, color: LumaTokens.textMuted),
            hintText: 'Search drugs',
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
      height: 32,
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
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = label),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: active ? LumaTokens.filterActive : LumaTokens.filterInactive),
                const SizedBox(height: 3),
                Container(
                  height: 1,
                  width: label.length * 6.5,
                  color: active ? LumaTokens.goldPrimary : Colors.transparent,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_tabIndex == 2) {
      return const BloodProductsView();
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: LumaTokens.goldPrimary));
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text('Error: $_error', style: LumaTokens.bodyMuted)),
      );
    }

    final list = _currentList;
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
    final adultDose = (drug['adult_dose'] ?? '').toString();

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
          if (adultDose.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('OR DOSING', style: LumaTokens.dosingLabel),
            const SizedBox(height: 3),
            Text(
              adultDose.split('\n').first,
              style: LumaTokens.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  void _openDrugDetail(Map<String, dynamic> drug) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _DrugDetailScreen(drug: drug)),
    );
  }
}

class _DrugDetailScreen extends StatelessWidget {
  final Map<String, dynamic> drug;
  const _DrugDetailScreen({required this.drug});

  @override
  Widget build(BuildContext context) {
    final highAlert = drug['high_alert'] == true;
    return Scaffold(
      backgroundColor: LumaTokens.creamSoft,
      appBar: AppBar(
        backgroundColor: LumaTokens.creamSoft,
        elevation: 0,
        iconTheme: const IconThemeData(color: LumaTokens.textPrimary),
        title: Text('DRUG DETAIL', style: LumaTokens.eyebrow),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (highAlert) ...[
              Text('HIGH-ALERT MEDICATION', style: LumaTokens.highAlertLabel),
              const SizedBox(height: 8),
            ],
            Text(drug['name'] ?? '', style: LumaTokens.drugTitle),
            if ((drug['brand_name'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(drug['brand_name'],
                  style: LumaTokens.drugTitle.copyWith(
                    fontStyle: FontStyle.italic,
                    color: LumaTokens.goldDeep,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  )),
            ],
            if ((drug['class_short'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(drug['class_short'].toString().toUpperCase(),
                  style: LumaTokens.classLabel),
            ],
            const SizedBox(height: 20),
            _section('Indications', drug['indications']),
            _section('Adult Dosing', drug['adult_dose']),
            _section('Mechanism', drug['mechanism']),
            _section('Clinical Pearls', drug['clinical_pearls']),
            _section('Contraindications', drug['contraindications']),
            _section('Warnings', drug['warnings_precautions']),
          ],
        ),
      ),
    );
  }

  Widget _section(String label, dynamic value) {
    final text = (value ?? '').toString();
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LumaSectionHeader(label),
          Text(text, style: LumaTokens.body),
        ],
      ),
    );
  }
}
