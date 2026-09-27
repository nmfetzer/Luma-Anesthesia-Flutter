import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:printing/printing.dart';

import 'ce_repository.dart';
import 'ce_certificate_pdf.dart';

class CeCertificateScreen extends StatefulWidget {
  const CeCertificateScreen({super.key, required this.repository});
  final CeRepository repository;
  @override
  State<CeCertificateScreen> createState() => _CeCertificateScreenState();
}

class _CeCertificateScreenState extends State<CeCertificateScreen> {
  Map<String, dynamic>? status;
  Uint8List? bytes;
  String? error;
  bool busy = false;
  bool preview = true;
  StreamSubscription<String?>? subscription;
  @override
  void initState() {
    super.initState();
    load('status');
    final initial = widget.repository.accountId;
    subscription = widget.repository.accountChanges.listen((id) {
      if (id != initial && mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  Future<void> load(String action) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final response = await widget.repository.call('certificate', {
        'action': action,
      });
      Uint8List? pdf;
      if (response['certificate'] is Map) {
        final record = Map<String, dynamic>.from(
          response['certificate'] as Map,
        );
        preview = record['is_preview'] != false;
        // Previews remain local and zero-credit. Official downloads always use
        // the server-rendered, immutable archive, never a client-rendered copy.
        pdf = preview
            ? await buildCeCertificatePdf(record)
            : await widget.repository.certificatePdf();
      }
      if (mounted) {
        setState(() {
          status = response;
          bytes = pdf;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> download() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await Printing.sharePdf(
        bytes: bytes!,
        filename: preview
            ? 'CE_HALO_Course${widget.repository.courseNumber}_Certificate_PREVIEW.pdf'
            : 'CE_HALO_Course${widget.repository.courseNumber}_Certificate.pdf',
      );
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Unable to save the PDF. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Course certificate')),
    backgroundColor: const Color(0xFFF6F5F1),
    body: bytes != null
        ? Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF0B1437),
                child: Text(
                  preview
                      ? 'TEST / PREVIEW · No CE credits earned'
                      : 'Your completed course certificate',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Expanded(
                child: PdfViewer.data(
                  bytes!,
                  sourceName:
                      'CE HALO Course ${widget.repository.courseNumber} certificate',
                ),
              ),
              if (error != null)
                Padding(padding: const EdgeInsets.all(12), child: Text(error!)),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: busy
                            ? null
                            : () => preview
                                  ? load('status')
                                  : Navigator.of(context).pop(),
                        child: Text(
                          preview ? 'Back to requirements' : 'Back to course',
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: busy ? null : download,
                        icon: const Icon(Icons.download_outlined),
                        label: Text(busy ? 'Preparing…' : 'Download PDF'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    'Your learning, recognized.',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B1437),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Course ${widget.repository.courseNumber} · ${widget.repository.courseTitle}\n20.00 MAC Ed CE credits${widget.repository.hasDesignatedCredits ? ' (${widget.repository.pharmacologyCredits} Pharmacology & Therapeutics; ${widget.repository.painCredits} Pain Management)' : ''}.',
                    style: const TextStyle(height: 1.6),
                  ),
                  const SizedBox(height: 20),
                  if (busy) const LinearProgressIndicator(),
                  if (error != null) ...[
                    Text(
                      error!,
                      style: const TextStyle(color: Color(0xFF9A3030)),
                    ),
                    TextButton(
                      onPressed: busy ? null : () => load('status'),
                      child: const Text('Retry'),
                    ),
                  ],
                  if (status != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              status!['reason'] as String? ??
                                  'Your certificate is ready to generate.',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Your saved registration supplies your name, credentials, AANA ID (if provided), location of completion, and participation dates. Your actual course completion date is recorded separately.',
                              style: TextStyle(height: 1.5),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Certificates are for the entire program, not individual modules. Generating a certificate does not submit credits to AANA.',
                              style: TextStyle(height: 1.5),
                            ),
                            TextButton(
                              onPressed: busy
                                  ? null
                                  : () => Navigator.of(context).pop(true),
                              child: const Text('Edit course registration'),
                            ),
                            if (status!['can_preview'] == true) ...[
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: busy ? null : () => load('preview'),
                                icon: const Icon(Icons.visibility_outlined),
                                label: const Text('Preview certificate design'),
                              ),
                            ],
                            if (status!['can_issue'] == true) ...[
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: busy ? null : () => load('issue'),
                                child: const Text('Generate my certificate'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final module in (status!['modules'] as List? ?? []))
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        leading: Icon(
                          module['complete'] == true
                              ? Icons.check_circle_outline
                              : Icons.radio_button_unchecked,
                        ),
                        title: Text(module['title'] as String),
                        subtitle: Text(
                          module['complete'] == true
                              ? 'Requirements complete'
                              : 'Content, passing quiz and evaluation required',
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
  );
}
