import 'package:flutter/material.dart';

import '../data/drug_reference_updates.dart';
import '../models/medication.dart';
import '../theme/luma_theme.dart';
import 'clinical_source_link.dart';

/// Intentionally lazy: browsing a medication never waits on external providers.
class DrugReferenceUpdatesPanel extends StatefulWidget {
  const DrugReferenceUpdatesPanel({
    super.key,
    required this.medication,
    this.gateway,
  });
  final Medication medication;
  final DrugReferenceGateway? gateway;

  @override
  State<DrugReferenceUpdatesPanel> createState() =>
      _DrugReferenceUpdatesPanelState();
}

class _DrugReferenceUpdatesPanelState extends State<DrugReferenceUpdatesPanel> {
  DrugReferenceSnapshot? _snapshot;
  bool _loading = false;
  bool _attempted = false;
  bool _failed = false;
  DrugReferenceGateway get _gateway =>
      widget.gateway ?? SupabaseDrugReferenceGateway.instance;

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _attempted = true;
      _failed = false;
    });
    final id = widget.medication.id;
    try {
      try {
        final saved = await _gateway
            .saved(id)
            .timeout(const Duration(seconds: 2));
        if (!mounted) return;
        if (saved != null && _snapshot == null) {
          setState(() => _snapshot = saved);
        }
      } catch (_) {
        // Device storage may be blocked; online reference access still works.
      }
      final current = await _gateway
          .refresh(id)
          .timeout(const Duration(seconds: 35));
      if (mounted) setState(() => _snapshot = current);
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          if (_snapshot != null) {
            _snapshot = DrugReferenceSnapshot(_snapshot!.data, savedOnly: true);
          }
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.medication.name
        .replaceAll(RegExp(r'\([^)]*\)'), '')
        .trim();
    final dailySearch = Uri.https(
      'dailymed.nlm.nih.gov',
      '/dailymed/search.cfm',
      {'query': query},
    ).toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: LumaColors.inkNavy.withValues(alpha: .18)),
        ),
        child: ExpansionTile(
          title: const Text(
            'Shortages & official labeling',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: LumaColors.inkNavy,
            ),
          ),
          subtitle: const Text(
            'FDA reports · DailyMed labels',
            style: TextStyle(fontSize: 13),
          ),
          onExpansionChanged: (open) {
            if (open && !_attempted) _load();
          },
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reference updates, not local inventory. Confirm the exact '
              'drug, formulation, strength and manufacturer before using a report or label.',
            ),
            const SizedBox(height: 12),
            if (_loading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Text('Checking official sources…'),
            ],
            if (_failed)
              const Text(
                'Could not refresh. Check your connection or open the official sources below.',
                style: TextStyle(color: LumaColors.highAlert),
              ),
            _source(
              'fda',
              'FDA shortage reports',
              'https://dps.fda.gov/drugshortages',
            ),
            _source(
              'dailymed',
              'DailyMed prescribing information',
              dailySearch,
            ),
            const SizedBox(height: 8),
            const Text(
              'Do not rely on openFDA to make decisions regarding medical care. '
              'Verify with your pharmacy and institutional protocols. '
              'A DailyMed listing does not by itself establish FDA approval.',
              style: TextStyle(fontSize: 12, height: 1.45),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Check for updates'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _source(String key, String title, String fallback) {
    final data = _snapshot?.source(key) ?? {};
    final rows = (data['rows'] as List? ?? [])
        .whereType<Map>()
        .map((r) => Map<String, dynamic>.from(r))
        .toList();
    final available = data['state'] == 'ok';
    final stale = _snapshot?.isStale(key) ?? false;
    final links = _snapshot?.data['links'] as Map?;
    final sourceUrl = _safeUrl(links?[key]?.toString()) ?? fallback;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 28),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 6),
        if (key == 'dailymed')
          const Text(
            'Human prescription labels',
            style: TextStyle(fontSize: 13),
          ),
        if (stale && available)
          const Text(
            'Saved information. Current status is not verified.',
            style: TextStyle(
              color: LumaColors.highAlert,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (available) ...[
          Text(
            'Last checked: ${_date(data['checked_at'])}',
            style: const TextStyle(fontSize: 12),
          ),
          if ((data['source_updated']?.toString() ?? '').isNotEmpty)
            Text(
              'Source dataset updated: ${data['source_updated']}',
              style: const TextStyle(fontSize: 12),
            ),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            Text(
              key == 'fda'
                  ? 'No matching shortage report found. This does not confirm availability.'
                  : 'No matching label found. Search DailyMed directly.',
            ),
          if (rows.isNotEmpty) ...[
            const Text(
              'Possible matches. Other formulations and combination products may be included.',
              style: TextStyle(fontSize: 13),
            ),
            for (final row in rows.take(3)) _record(key, row),
            if (rows.length > 3)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  'More results',
                  style: TextStyle(fontSize: 14),
                ),
                children: [for (final row in rows.skip(3)) _record(key, row)],
              ),
            if ((num.tryParse('${data['total']}') ?? rows.length) > rows.length)
              const Text(
                'Additional results are available at the source. This list is not exhaustive.',
                style: TextStyle(fontSize: 13),
              ),
          ],
        ] else if (!_loading)
          const Text(
            'Updates are unavailable. Use the official source to check.',
          ),
        TextButton.icon(
          onPressed: () => ClinicalSourceLink.open(context, sourceUrl),
          icon: const Icon(Icons.open_in_new, size: 16),
          label: Text(
            key == 'fda' ? 'Open FDA shortage database' : 'Search DailyMed',
          ),
        ),
      ],
    );
  }

  Widget _record(String key, Map<String, dynamic> row) {
    final url = _safeUrl(row['url']?.toString());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${row['title'] ?? ''}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (key == 'fda')
            for (final entry in {
              'status': 'FDA report status',
              'availability': 'Product availability',
              'presentation': 'Presentation',
              'company': 'Manufacturer',
              'ndc': 'Package NDC',
              'reason': 'Reason',
              'notes': 'Source notes',
            }.entries)
              if ((row[entry.key]?.toString() ?? '').isNotEmpty)
                Text('${entry.value}: ${row[entry.key]}'),
          if ((row['updated']?.toString() ?? '').isNotEmpty)
            Text(
              '${key == 'fda' ? 'Report updated' : 'Label published'}: ${row['updated']}',
              style: const TextStyle(fontSize: 12),
            ),
          if (url != null)
            TextButton(
              onPressed: () => ClinicalSourceLink.open(context, url),
              child: Text(
                key == 'fda' ? 'View FDA source record' : 'View this label',
              ),
            ),
        ],
      ),
    );
  }

  static String? _safeUrl(String? value) {
    final uri = Uri.tryParse(value ?? '');
    if (uri == null ||
        uri.scheme != 'https' ||
        !{
          'api.fda.gov',
          'dps.fda.gov',
          'dailymed.nlm.nih.gov',
        }.contains(uri.host)) {
      return null;
    }
    return uri.toString();
  }

  static String _date(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    return date == null
        ? 'Not available'
        : '${date.toUtc().toIso8601String().replaceFirst('T', ' ').substring(0, 16)} UTC';
  }
}
