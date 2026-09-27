import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'ce_repository.dart';
import 'ce_export.dart';

String ceRecordsCsv(
  List<Map<String, dynamic>> rows, {
  bool certificates = false,
}) {
  final columns = certificates
      ? [
          'certificate_id',
          'account_id',
          'course_id',
          'reporting_class',
          'full_name',
          'credentials',
          'aana_id',
          'location',
          'participation_start_on',
          'participation_end_on',
          'completion_date',
          'completed_at',
          'issued_at',
          'credits_awarded',
          'pharmacology_credits',
          'pain_credits',
          'archive_status',
          'archive_sha256',
          'reporting_status',
        ]
      : [
          'account_id',
          'course_id',
          'reporting_class',
          'module_id',
          'full_name',
          'credentials',
          'aana_id',
          'location',
          'completed_at',
          'module_credits',
          'pharmacology_credits',
          'pain_credits',
          'is_preview',
          'reporting_status',
          'full_course_awarded',
          'quiz_attempts',
          'evaluation',
        ];
  String cell(dynamic value) {
    var s = value is Map || value is List
        ? jsonEncode(value)
        : '${value ?? ''}';
    // Prevent spreadsheet formula execution, including whitespace-prefixed input.
    if (RegExp(r'^\s*[=+\-@]').hasMatch(s)) s = "'$s";
    return '"${s.replaceAll('"', '""')}"';
  }

  return [
    columns.map(cell).join(','),
    ...rows.map((r) => columns.map((c) => cell(r[c])).join(',')),
  ].join('\r\n');
}

class CeRecordsScreen extends StatefulWidget {
  const CeRecordsScreen({super.key, required this.repository});
  final CeRepository repository;
  @override
  State<CeRecordsScreen> createState() => _CeRecordsScreenState();
}

class _CeRecordsScreenState extends State<CeRecordsScreen> {
  final month = TextEditingController(
    text:
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}',
  );
  bool previews = false, busy = false, loaded = false;
  bool certificates = true;
  StreamSubscription<String?>? accountSubscription;
  String? error, notice;
  List<Map<String, dynamic>> rows = [];
  @override
  void initState() {
    super.initState();
    final initial = widget.repository.accountId;
    accountSubscription = widget.repository.accountChanges.listen((id) {
      if (id != initial && mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    month.dispose();
    accountSubscription?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    final value = month.text.trim();
    if (value.isNotEmpty &&
        !RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(value)) {
      setState(() => error = 'Use YYYY-MM, or leave blank for all months.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
      notice = null;
      loaded = false;
      rows = [];
    });
    try {
      final all = <Map<String, dynamic>>[];
      int offset = 0;
      while (true) {
        final page = await widget.repository.call(
          certificates ? 'certificate_records' : 'records',
          {
            'month': value.isEmpty ? null : value,
            'include_preview': previews,
            'offset': offset,
          },
        );
        final batch = (page['rows'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        all.addAll(batch);
        offset += batch.length;
        if (offset >= (page['total'] as num) || batch.isEmpty) break;
      }
      if (mounted) {
        setState(() {
          rows = all;
          loaded = true;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Provider records & exports')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Monthly completion ledger',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Provider-only records, filtered by actual completion month in America/New_York. Full-course certificates are separate from individual module activity.',
            ),
            const SizedBox(height: 12),
            const Text(
              'These are internal recordkeeping exports, not an AANA-formatted upload. A certificate export does not submit credits to AANA. Review AANA IDs and credit totals before reporting.',
            ),
            const SizedBox(height: 22),
            DropdownButtonFormField<bool>(
              initialValue: certificates,
              decoration: const InputDecoration(
                labelText: 'Record type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: true,
                  child: Text('Full-course certificates'),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text('Module activity & evaluations'),
                ),
              ],
              onChanged: busy
                  ? null
                  : (value) => setState(() {
                      certificates = value!;
                      loaded = false;
                      rows = [];
                      notice = null;
                    }),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: month,
              enabled: !busy,
              onChanged: (_) => setState(() {
                loaded = false;
                rows = [];
              }),
              decoration: const InputDecoration(
                labelText: 'Completion month (YYYY-MM)',
                helperText: 'Leave blank for all months',
                border: OutlineInputBorder(),
              ),
            ),
            if (!certificates)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: previews,
                title: const Text('Include provider previews (not reportable)'),
                onChanged: busy
                    ? null
                    : (v) => setState(() {
                        previews = v!;
                        loaded = false;
                        rows = [];
                      }),
              ),
            FilledButton(
              onPressed: busy ? null : load,
              child: Text(busy ? 'Loading…' : 'Load records'),
            ),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            if (loaded) ...[
              const SizedBox(height: 16),
              Text(
                '${rows.length} ${certificates ? "issued certificates" : "completed module records"}',
              ),
              if (rows.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No completed records for this filter. Nothing has been submitted to AANA.',
                  ),
                ),
              OutlinedButton(
                onPressed: rows.isEmpty || busy
                    ? null
                    : () async {
                        final message = await saveCeCsv(
                          'CE_HALO_${widget.repository.courseId}_${certificates ? "certificates" : "module_ledger"}_${month.text.trim().isEmpty ? "all" : month.text.trim()}.csv',
                          ceRecordsCsv(rows, certificates: certificates),
                        );
                        if (mounted) setState(() => notice = message);
                      },
                child: const Text(
                  kIsWeb
                      ? 'Download internal ledger CSV'
                      : 'Copy internal ledger CSV',
                ),
              ),
              if (notice != null) Text(notice!),
              for (final row in rows)
                Card(
                  child: ExpansionTile(
                    title: Text(
                      '${row['full_name']} • ${certificates ? row['certificate_id'] : row['module_id']}',
                    ),
                    subtitle: Text(
                      '${row['completed_at']}\n${row['reporting_status']}',
                    ),
                    childrenPadding: const EdgeInsets.all(16),
                    children: [
                      SelectableText(
                        const JsonEncoder.withIndent('  ').convert(row),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    ),
  );
}
