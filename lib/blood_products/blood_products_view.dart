import 'package:flutter/material.dart';
import '../widgets/luma_home_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../shared/luma_theme_tokens.dart';

/// Blood Products list view — reads from `blood_products` table.
class BloodProductsView extends StatefulWidget {
  const BloodProductsView({super.key});

  @override
  State<BloodProductsView> createState() => _BloodProductsViewState();
}

class _BloodProductsViewState extends State<BloodProductsView> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<List<Map<String, dynamic>>> _fetch() async {
    final res = await Supabase.instance.client
        .from('blood_products')
        .select()
        .order('display_order');
    return List<Map<String, dynamic>>.from(res);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation(LumaTokens.goldDeep),
              ),
            ),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load blood products.\n${snap.error}',
                style: LumaTokens.bodyMuted),
          );
        }
        final rows = snap.data ?? [];

        final Map<String, List<Map<String, dynamic>>> grouped = {};
        for (final r in rows) {
          final cat = (r['category'] ?? 'Other').toString();
          grouped.putIfAbsent(cat, () => []).add(r);
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            for (final entry in grouped.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 10),
                child: Text(entry.key.toUpperCase(), style: LumaTokens.eyebrow),
              ),
              for (final p in entry.value) ...[
                _BloodProductCard(product: p),
                const SizedBox(height: 10),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _BloodProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _BloodProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final name = (product['name'] ?? '').toString();
    final abbr = (product['abbreviation'] ?? '').toString();
    final unit = (product['unit_size'] ?? '').toString();

    return LumaCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _BloodProductDetail(product: product)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: LumaTokens.drugName,
                        children: [
                          TextSpan(text: name),
                          if (abbr.isNotEmpty)
                            TextSpan(
                              text: '   $abbr',
                              style: LumaTokens.drugName.copyWith(
                                fontStyle: FontStyle.italic,
                                color: LumaTokens.goldDeep,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (unit.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('UNIT · $unit'.toUpperCase(), style: LumaTokens.classLabel),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: LumaTokens.textMuted),
            ],
          ),
          if (product['typical_dose'] != null &&
              product['typical_dose'].toString().trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(height: 0.5, color: LumaTokens.hairlineNavy),
            const SizedBox(height: 10),
            Text('TYPICAL DOSE', style: LumaTokens.dosingLabel),
            const SizedBox(height: 3),
            Text(
              product['typical_dose'].toString(),
              style: LumaTokens.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _BloodProductDetail extends StatelessWidget {
  final Map<String, dynamic> product;
  const _BloodProductDetail({required this.product});

  @override
  Widget build(BuildContext context) {
    final name = (product['name'] ?? '').toString();
    final abbr = (product['abbreviation'] ?? '').toString();
    final category = (product['category'] ?? '').toString();

    return Scaffold(
      backgroundColor: LumaTokens.creamSoft,
      appBar: AppBar(
        actions: const [LumaHomeButton()],
        backgroundColor: LumaTokens.creamSoft,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: LumaTokens.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: LumaTokens.hairlineNavy),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: LumaTokens.drugTitle),
            if (abbr.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                abbr,
                style: LumaTokens.drugTitle.copyWith(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: LumaTokens.goldDeep,
                ),
              ),
            ],
            if (category.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(category.toUpperCase(), style: LumaTokens.classLabel),
            ],
            const SizedBox(height: 20),
            _productBasicsCard(),
            const SizedBox(height: 18),
            _textSection('Indications', product['indications']),
            _textSection('Typical Dose', product['typical_dose']),
            _textSection('Expected Effect', product['expected_effect']),
            _textSection('Infusion Rate', product['infusion_rate']),
            _textSection('Compatibility', product['compatibility']),
            _textSection('Reactions', product['reactions']),
            _textSection('Contraindications', product['contraindications']),
            _textSection('Special Considerations', product['special_considerations']),
            _sourcesCard(product['sources']),
          ],
        ),
      ),
    );
  }

  Widget _productBasicsCard() {
    final unit = (product['unit_size'] ?? '').toString();
    final storage = (product['storage'] ?? '').toString();
    final shelf = (product['shelf_life'] ?? '').toString();
    if (unit.isEmpty && storage.isEmpty && shelf.isEmpty) {
      return const SizedBox.shrink();
    }
    return LumaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LumaSectionHeader('Product Basics'),
          if (unit.isNotEmpty) LumaKeyValue(label: 'Unit Size', value: unit),
          if (storage.isNotEmpty) LumaKeyValue(label: 'Storage', value: storage),
          if (shelf.isNotEmpty) LumaKeyValue(label: 'Shelf Life', value: shelf),
        ],
      ),
    );
  }

  Widget _textSection(String label, dynamic value) {
    if (value == null) return const SizedBox.shrink();
    String body;
    if (value is List) {
      if (value.isEmpty) return const SizedBox.shrink();
      body = value.map((e) => '•  $e').join('\n');
    } else {
      body = value.toString().trim();
      if (body.isEmpty) return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: LumaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LumaSectionHeader(label),
            Text(body, style: LumaTokens.body),
          ],
        ),
      ),
    );
  }

  Widget _sourcesCard(dynamic sources) {
    if (sources == null || sources is! List || sources.isEmpty) {
      return const SizedBox.shrink();
    }
    return LumaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LumaSectionHeader('References'),
          for (final s in sources) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text('•  ${s.toString()}', style: LumaTokens.bodySmall),
            ),
          ],
        ],
      ),
    );
  }
}
