import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/medication_deep_dive.dart';
import '../widgets/luma_home_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shared/luma_theme_tokens.dart';

/// Rich drug detail screen — clinical-reference aesthetic.
///
/// Placeholder rule: any field that starts with a known filler phrase is
/// treated as empty and its section is hidden. Never show fake content.
class DrugDetailScreen extends StatelessWidget {
  final Map<String, dynamic> drug;
  const DrugDetailScreen({super.key, required this.drug});

  static const _placeholderPrefixes = [
    'consult prescribing information',
    'consult drug interaction',
    'follow institutional',
    'refer to institutional',
  ];

  bool _isPlaceholder(String? text) {
    if (text == null) return true;
    final t = text.trim().toLowerCase();
    if (t.isEmpty) return true;
    return _placeholderPrefixes.any((p) => t.startsWith(p));
  }

  String? _clean(dynamic v) {
    if (v == null) return null;
    final s = v.toString().replaceAll(r'\n', '\n').replaceAll('**', '').trim();
    if (_isPlaceholder(s)) return null;
    return s.isEmpty ? null : s;
  }

  List<String> _bulletize(String? raw) {
    if (raw == null) return const [];
    final normalized =
        raw.replaceAll(RegExp(r'^\s*[-•]\s*', multiLine: true), '').trim();
    final parts = <String>[];
    for (final line in normalized.split(RegExp(r'\n+'))) {
      for (final chunk in line.split(RegExp(r';\s+'))) {
        final c = chunk.trim();
        if (c.isNotEmpty) parts.add(c);
      }
    }
    return parts;
  }

  List<Map<String, dynamic>> _parseSources(dynamic raw) {
    if (raw == null) return const [];
    final list = raw is List ? raw : const [];
    final out = <Map<String, dynamic>>[];
    for (final item in list) {
      Map? m;
      if (item is Map) {
        m = item;
      } else if (item is String) {
        try {
          final decoded = jsonDecode(item);
          if (decoded is Map) m = decoded;
        } catch (_) {}
      }
      if (m != null) out.add(Map<String, dynamic>.from(m));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final highAlert = drug['high_alert'] == true;
    final blackBox = _clean(drug['black_box_warning']);
    final lasa = _clean(drug['lasa_warning']);

    return Scaffold(
      backgroundColor: LumaTokens.creamSoft,
      appBar: AppBar(
        actions: const [LumaHomeButton()],
        backgroundColor: LumaTokens.creamSoft,
        elevation: 0,
        iconTheme: const IconThemeData(color: LumaTokens.textPrimary),
        title: Text('DRUG DETAIL', style: LumaTokens.eyebrow),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleBlock(highAlert),
            if (blackBox != null)
              _buildCallout(
                tone: _CalloutTone.red,
                eyebrow: 'BLACK BOX WARNING',
                body: blackBox,
              ),
            if (lasa != null)
              _buildCallout(
                tone: _CalloutTone.amber,
                eyebrow: 'LOOK-ALIKE SOUND-ALIKE',
                body: lasa,
              ),
            const SizedBox(height: 16),
            _bulletSection('Indications', drug['indications']),
            _dosingSection(),
            _mixingSection(),
            _kineticsSection(),
            _bulletSection('Contraindications', drug['contraindications']),
            _bulletSection(
                'Warnings & Precautions', drug['warnings_precautions']),
            _bulletSection('Side Effects', drug['side_effects']),
            _bulletSection('Serious Adverse Effects', drug['serious_effects']),
            _bulletSection('Drug Interactions', drug['drug_interactions']),
            _criticalInteractions(),
            _bulletSection('Mechanism', drug['mechanism'], forceProse: true),
            _bulletSection('Clinical Pearls', drug['clinical_pearls']),
            _bulletSection('Antidote / Reversal', drug['antidote_reversal']),
            _bulletSection(
                'Administration Details', drug['administration_details']),
            _bulletSection('Special Populations', drug['special_populations']),
            _bulletSection(
                'Pregnancy & Lactation', drug['pregnancy_lactation']),
            _monitoringSection(),
            _deepDiveSection(context),
            _sourcesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBlock(bool highAlert) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (highAlert) ...[
          Text('HIGH-ALERT MEDICATION', style: LumaTokens.highAlertLabel),
          const SizedBox(height: 8),
        ],
        Text(drug['name']?.toString() ?? '', style: LumaTokens.drugTitle),
        if ((drug['brand_name'] ?? '').toString().trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            drug['brand_name'].toString(),
            style: LumaTokens.drugTitle.copyWith(
              fontStyle: FontStyle.italic,
              color: LumaTokens.goldDeep,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
        if ((drug['class_short'] ?? '').toString().trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            drug['class_short'].toString().toUpperCase(),
            style: LumaTokens.classLabel,
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCallout({
    required _CalloutTone tone,
    required String eyebrow,
    required String body,
  }) {
    final borderColor =
        tone == _CalloutTone.red ? LumaTokens.alertRed : LumaTokens.goldDeep;
    final eyebrowColor =
        tone == _CalloutTone.red ? LumaTokens.alertRed : LumaTokens.goldDeep;
    final bgColor =
        tone == _CalloutTone.red ? LumaTokens.alertRedBg : LumaTokens.parchment;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: bgColor,
        border:
            Border.all(color: borderColor.withValues(alpha: 0.35), width: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: LumaTokens.eyebrow.copyWith(
              color: eyebrowColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          ..._bulletize(body).map((b) => _bulletLine(b, dotColor: borderColor)),
        ],
      ),
    );
  }

  Widget _bulletSection(String label, dynamic value,
      {bool forceProse = false}) {
    final cleaned = _clean(value);
    if (cleaned == null) return const SizedBox.shrink();
    final items = _bulletize(cleaned);
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LumaSectionHeader(label),
          if (forceProse || items.length == 1)
            Text(items.join(' '), style: LumaTokens.body)
          else
            ...items.map((b) => _bulletLine(b)),
        ],
      ),
    );
  }

  Widget _bulletLine(String text, {Color? dotColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 10),
            child: Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: dotColor ?? LumaTokens.goldDeep,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(child: Text(text, style: LumaTokens.body)),
        ],
      ),
    );
  }

  Widget _dosingSection() {
    final adult = _clean(drug['adult_dose']);
    final peds = _clean(drug['peds_dose']);
    if (adult == null && peds == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LumaSectionHeader('Dosing'),
          if (adult != null) ...[
            Text('ADULT', style: LumaTokens.dosingLabel),
            const SizedBox(height: 6),
            ..._bulletize(adult).map((b) => _bulletLine(b)),
          ],
          if (adult != null && peds != null) const SizedBox(height: 14),
          if (peds != null) ...[
            Text('PEDIATRIC', style: LumaTokens.dosingLabel),
            const SizedBox(height: 6),
            ..._bulletize(peds).map((b) => _bulletLine(b)),
          ],
        ],
      ),
    );
  }

  Widget _mixingSection() {
    final recipe = _clean(drug['standard_recipe']);
    final target = _clean(drug['target_concentration']);
    final diluent = _clean(drug['diluent']);
    final finalVol = drug['final_volume_ml'];
    final altConc = _clean(drug['alternative_concentrations']);
    final mixingPearls = _clean(drug['mixing_pearls']);
    final stabRoom = drug['stability_hours_room_temp'];
    final stabFridge = drug['stability_hours_refrigerated'];

    final hasAny = recipe != null ||
        target != null ||
        diluent != null ||
        finalVol != null ||
        altConc != null ||
        mixingPearls != null ||
        stabRoom != null ||
        stabFridge != null;
    if (!hasAny) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LumaSectionHeader('Mixing & Preparation'),
          if (recipe != null) _kvRow('Standard Recipe', recipe),
          if (target != null) _kvRow('Target Concentration', target),
          if (diluent != null) _kvRow('Diluent', diluent),
          if (finalVol != null) _kvRow('Final Volume', '$finalVol mL'),
          if (altConc != null) _kvRow('Alternative Concentrations', altConc),
          if (stabRoom != null) _kvRow('Stability (room temp)', '$stabRoom h'),
          if (stabFridge != null)
            _kvRow('Stability (refrigerated)', '$stabFridge h'),
          if (mixingPearls != null) ...[
            const SizedBox(height: 10),
            Text('MIXING PEARLS', style: LumaTokens.dosingLabel),
            const SizedBox(height: 6),
            ..._bulletize(mixingPearls).map((b) => _bulletLine(b)),
          ],
        ],
      ),
    );
  }

  Widget _kineticsSection() {
    final onset = _clean(drug['onset_duration']);
    final onsetMin = drug['onset_minutes'];
    final durMin = drug['duration_minutes'];
    final pk = _clean(drug['pharmacokinetics']);

    final hasAny =
        onset != null || onsetMin != null || durMin != null || pk != null;
    if (!hasAny) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LumaSectionHeader('Onset · Duration · Kinetics'),
          if (onset != null) _kvRow('Onset / Duration', onset),
          if (onsetMin != null) _kvRow('Onset', '$onsetMin min'),
          if (durMin != null) _kvRow('Duration', '$durMin min'),
          if (pk != null) ...[
            const SizedBox(height: 10),
            Text('PHARMACOKINETICS', style: LumaTokens.dosingLabel),
            const SizedBox(height: 6),
            ..._bulletize(pk).map((b) => _bulletLine(b)),
          ],
        ],
      ),
    );
  }

  Widget _criticalInteractions() {
    final raw = drug['interactions_critical'];
    if (raw is! List || raw.isEmpty) return const SizedBox.shrink();
    final items =
        raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LumaSectionHeader('Critical Interactions'),
          ...items.map((b) => _bulletLine(b, dotColor: LumaTokens.alertRed)),
        ],
      ),
    );
  }

  Widget _monitoringSection() {
    final raw = drug['monitoring_parameters'];
    if (raw is! List || raw.isEmpty) return const SizedBox.shrink();
    final items =
        raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LumaSectionHeader('Monitoring'),
          ...items.map((b) => _bulletLine(b)),
        ],
      ),
    );
  }

  Widget _deepDiveSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 4, bottom: 8),
          initiallyExpanded: false,
          iconColor: LumaTokens.goldDeep,
          collapsedIconColor: LumaTokens.goldDeep,
          title: Text(
            'DEEP DIVE',
            style: LumaTokens.eyebrow.copyWith(
              color: LumaTokens.goldDeep,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.6,
            ),
          ),
          children: [
            Container(height: 0.5, color: LumaTokens.hairlineGold),
            const SizedBox(height: 12),
            MedicationDeepDive(medicationId: drug['id'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _sourcesSection(BuildContext context) {
    final sources = _parseSources(drug['sources']);
    if (sources.isEmpty) return const SizedBox.shrink();

    // Sort by 'number' if present
    sources.sort((a, b) {
      final na = a['number'];
      final nb = b['number'];
      if (na is num && nb is num) return na.compareTo(nb);
      return 0;
    });

    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LumaSectionHeader('Sources'),
          for (int i = 0; i < sources.length; i++)
            _sourceRow(context, i + 1, sources[i]),
        ],
      ),
    );
  }

  Widget _sourceRow(
      BuildContext context, int fallbackNumber, Map<String, dynamic> s) {
    final number =
        s['number'] is num ? (s['number'] as num).toInt() : fallbackNumber;
    final citation = (s['citation'] ?? '').toString().trim();
    final url = (s['url'] ?? '').toString().trim();
    final type = (s['type'] ?? '').toString().trim();

    final uri = Uri.tryParse(url);
    final hasUrl = uri != null &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'https' || uri.scheme == 'http');
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 26,
          child: Text(
            '$number.',
            style: LumaTokens.bodySmall.copyWith(
              color: LumaTokens.goldDeep,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                citation.isNotEmpty ? citation : url,
                style: LumaTokens.body.copyWith(
                  fontSize: 12.5,
                  height: 1.4,
                  decoration:
                      hasUrl ? TextDecoration.underline : TextDecoration.none,
                  decorationColor: LumaTokens.goldDeep.withValues(alpha: 0.4),
                ),
              ),
              if (type.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  type.toUpperCase(),
                  style: LumaTokens.eyebrow.copyWith(
                    fontSize: 9,
                    color: LumaTokens.textMuted,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (hasUrl)
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 2),
            child:
                Icon(Icons.open_in_new, size: 13, color: LumaTokens.goldDeep),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: hasUrl
          ? InkWell(
              onTap: () => _openUrl(context, url),
              borderRadius: BorderRadius.circular(4),
              child: content,
            )
          : content,
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    var ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Missing browser handlers should not crash the clinical reference.
    }
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }

  Widget _kvRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: LumaTokens.dosingLabel),
          const SizedBox(height: 3),
          Text(value, style: LumaTokens.body),
        ],
      ),
    );
  }
}

enum _CalloutTone { red, amber }
