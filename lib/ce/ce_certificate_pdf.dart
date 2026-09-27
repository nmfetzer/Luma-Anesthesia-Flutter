import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const ceApprovalStatement =
    'This program has been prior approved by the American Association of Nurse Anesthesiology for 20.00 MAC Ed CE credits; Code Number 1047239; Expiration Date 9/30/2029.';
const cePharmacologyStatement =
    'The American Association of Nurse Anesthesiology designates this program as meeting the criteria for up to 17.50 CE credits in Pharmacology & Therapeutics.';
const cePainStatement =
    'The American Association of Nurse Anesthesiology designates this program as meeting the criteria for up to 2.50 CE credits in Pain Management.';
const ceCaliforniaStatement =
    'AANA is an approved provider by the California Board of Registered Nursing, CEP #10862.';

/// Renderer only. Award authorization lives exclusively in the Supabase RPC.
/// Unknown/missing preview flags fail closed and render a non-credit sample.
Future<Uint8List> buildCeCertificatePdf(Map<String, dynamic> record) async {
  final preview = record['is_preview'] != false;
  if (!preview &&
      (record['id'] == null ||
          record['template_version'] != 'cehalo-course1-v1' ||
          record['credits_awarded'] != 20 ||
          record['completed_on'] == null ||
          (record['signature_png_base64'] as String? ?? '').isEmpty)) {
    throw StateError('The official certificate record is incomplete.');
  }
  final learner = Map<String, dynamic>.from(record['learner'] as Map? ?? {});
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/DejaVuSans.ttf'),
  );
  final bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/DejaVuSans-Bold.ttf'),
  );
  final logo = pw.MemoryImage(
    (await rootBundle.load('assets/branding/ce_halo_symbol.png')).buffer
        .asUint8List(),
  );
  const navy = PdfColor.fromInt(0xFF0B1437);
  const gold = PdfColor.fromInt(0xFFE9C778);
  const gray = PdfColor.fromInt(0xFF535C70);
  final doc = pw.Document(
    title: preview
        ? 'CE HALO Course 1 Certificate Preview'
        : 'CE HALO Certificate of Completion',
    author: 'Perplexity Computer',
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );
  pw.Widget text(
    String s, {
    double size = 10,
    bool strong = false,
    PdfColor color = navy,
  }) => pw.Text(
    s,
    style: pw.TextStyle(
      fontSize: size,
      fontWeight: strong ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: color,
    ),
  );
  pw.Widget field(String label, String value, {double height = 36}) =>
      pw.Container(
        constraints: pw.BoxConstraints(minHeight: height),
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            text(label.toUpperCase(), size: 9, color: gray),
            pw.SizedBox(height: 3),
            text(value, size: value.length > 70 ? 9 : 11, strong: true),
          ],
        ),
      );
  final name = '${learner['full_name'] ?? 'Sample Learner'}';
  final credentials = '${learner['credentials'] ?? 'CRNA'}';
  final aana = '${learner['aana_id'] ?? ''}';
  final location = '${learner['location'] ?? 'City, State / Country'}';
  final compact =
      name.length > 60 || credentials.length > 70 || location.length > 140;
  final signature = record['signature_png_base64'] as String?;
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(28),
      build: (_) => pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: navy, width: 1.5),
        ),
        padding: const pw.EdgeInsets.all(6),
        child: pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: gold, width: 0.8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                color: navy,
                padding: pw.EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: compact ? 6 : 10,
                ),
                child: pw.Row(
                  children: [
                    pw.Image(
                      logo,
                      width: compact ? 32 : 40,
                      height: compact ? 36 : 48,
                    ),
                    pw.SizedBox(width: 18),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        text('CE HALO', size: 22, strong: true, color: gold),
                        pw.SizedBox(height: 3),
                        text(
                          'CONTINUING EDUCATION',
                          size: 9,
                          color: PdfColors.white,
                        ),
                      ],
                    ),
                    pw.Spacer(),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        text('CE HALO LLC', size: 10, color: PdfColors.white),
                        text(
                          '${record['provider_city_state'] ?? 'Buffalo, New York'}',
                          size: 9,
                          color: PdfColors.white,
                        ),
                        pw.SizedBox(height: 4),
                        pw.UrlLink(
                          destination: 'mailto:info@cehalo.com',
                          child: text('info@cehalo.com', size: 9, color: gold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(26, 14, 26, 12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      if (preview) ...[
                        pw.Container(
                          color: const PdfColor.fromInt(0xFFF6EDDA),
                          padding: const pw.EdgeInsets.all(7),
                          child: text(
                            'PREVIEW ONLY  /  NOT VALID FOR CE CREDIT',
                            size: 10,
                            strong: true,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                      ],
                      text(
                        'Certificate of Completion',
                        size: compact ? 22 : 25,
                        strong: true,
                      ),
                      pw.SizedBox(height: 5),
                      text(
                        'PROVIDER-DIRECTED INDEPENDENT STUDY',
                        size: 9,
                        color: gray,
                      ),
                      pw.SizedBox(height: compact ? 5 : 10),
                      text(
                        preview ? 'Sample recipient' : 'Presented to',
                        size: 10,
                        color: gray,
                      ),
                      pw.SizedBox(height: 5),
                      text(
                        name,
                        size: name.length > 60
                            ? 12
                            : name.length > 32
                            ? 18
                            : 23,
                        strong: true,
                      ),
                      pw.SizedBox(height: 5),
                      field(
                        'Credentials',
                        credentials,
                        height: credentials.length > 70 ? 36 : 29,
                      ),
                      pw.SizedBox(height: compact ? 3 : 7),
                      text(
                        preview
                            ? 'Preview of the full-program award for'
                            : 'For successful completion of',
                        size: 10,
                        color: gray,
                      ),
                      pw.SizedBox(height: compact ? 3 : 7),
                      text(
                        'A Medication Review for\nthe Experienced CRNA',
                        size: compact ? 14 : 18,
                        strong: true,
                      ),
                      pw.SizedBox(height: compact ? 4 : 9),
                      pw.Container(
                        padding: pw.EdgeInsets.all(compact ? 6 : 10),
                        decoration: const pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFFF3F4F7),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            text(
                              preview
                                  ? '20.00 MAC Ed CE credits approved'
                                  : '20.00 MAC Ed CE credits awarded',
                              size: 14,
                              strong: true,
                            ),
                            pw.SizedBox(height: 5),
                            text(
                              '17.50 Pharmacology & Therapeutics  |  2.50 Pain Management',
                              size: 9,
                            ),
                            if (preview) ...[
                              pw.SizedBox(height: 4),
                              text(
                                'Credits earned by this preview: 0.00',
                                size: 9,
                                strong: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                      pw.SizedBox(height: compact ? 5 : 10),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: field(
                              'AANA ID',
                              aana.isEmpty
                                  ? 'Not provided / not applicable'
                                  : aana,
                            ),
                          ),
                          pw.SizedBox(width: 16),
                          pw.Expanded(
                            child: field(
                              'Participation dates',
                              preview
                                  ? 'Populated upon completion'
                                  : '${record['started_on']} to ${record['completed_on']}',
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      field(
                        'Location of completion (learner-reported)',
                        location,
                        height: 32,
                      ),
                      pw.SizedBox(height: 3),
                      pw.SizedBox(
                        height: 26,
                        child: signature != null && signature.isNotEmpty
                            ? pw.Align(
                                alignment: pw.Alignment.centerLeft,
                                child: pw.Image(
                                  pw.MemoryImage(base64Decode(signature)),
                                  height: 30,
                                ),
                              )
                            : pw.Align(
                                alignment: pw.Alignment.centerLeft,
                                child: text(
                                  'Provider signature pending approval',
                                  size: 9,
                                  color: gray,
                                ),
                              ),
                      ),
                      pw.Divider(color: navy, thickness: 0.6),
                      text(
                        '${record['signer_name'] ?? 'Nicole M Fetzer, MS, CRNA'}',
                        size: 10,
                        strong: true,
                      ),
                      text(
                        '${record['signer_title'] ?? 'Owner, CE HALO LLC'} · Provider verifying completion',
                        size: 9,
                      ),
                      pw.SizedBox(height: compact ? 6 : 12),
                      for (final statement in [
                        ceApprovalStatement,
                        cePharmacologyStatement,
                        cePainStatement,
                        ceCaliforniaStatement,
                      ]) ...[text(statement, size: 9), pw.SizedBox(height: 4)],
                      pw.Divider(color: gold, thickness: 0.8),
                      text(
                        'Certificate ID: ${preview ? 'PREVIEW-NOT-VALID' : record['id']}',
                        size: 9,
                      ),
                      pw.SizedBox(height: 3),
                      text(
                        preview
                            ? 'Design review only. This sample is not a completion record.'
                            : 'Issued from the CE HALO course completion record. Retain for your records.',
                        size: 9,
                        color: gray,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return doc.save();
}
