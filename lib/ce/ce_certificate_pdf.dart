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

String certificateDate(dynamic value) {
  final raw = value?.toString() ?? '';
  final date = DateTime.tryParse(raw);
  return date == null
      ? 'Not yet entered'
      : '${date.month}/${date.day}/${date.year}';
}

/// Renderer only. Award authorization lives exclusively in the Supabase RPC.
/// The uploaded sample's signature artwork is a PREVIEW-ONLY fallback.
/// Official records must contain their own provider-approved signature.
Future<Uint8List> buildCeCertificatePdf(
  Map<String, dynamic> record, {
  bool serverTemplate = false,
}) async {
  final course2 = record['course_id'] == '1047241';
  final course3 = record['course_id'] == '1047243';
  final courseNumber = course3 ? 3 : (course2 ? 2 : 1);
  final courseTitle = course3
      ? 'Legal Essentials for the CRNA'
      : course2
      ? 'Uncommon but Catastrophic Anesthesia Events'
      : 'A Medication Review for the Experienced CRNA';
  final preview = record['is_preview'] != false;
  if (!preview &&
      (record['id'] == null ||
          record['template_version'] != 'cehalo-course$courseNumber-v1' ||
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
    (await rootBundle.load('assets/branding/ce_halo_certificate_logo.png'))
        .buffer
        .asUint8List(),
  );
  final signature = record['signature_png_base64'] as String?;
  final signatureImage = signature != null && signature.isNotEmpty
      ? pw.MemoryImage(base64Decode(signature))
      : preview
      ? pw.MemoryImage(
          (await rootBundle.load(
            'assets/branding/ce_halo_preview_signature.png',
          )).buffer.asUint8List(),
        )
      : null;
  const navy = PdfColor.fromInt(0xFF14234E);
  const gold = PdfColor.fromInt(0xFFBA8D36);
  const gray = PdfColor.fromInt(0xFF4C4C4C);
  final name = '${learner['full_name'] ?? 'Sample Learner'}';
  final credentials = '${learner['credentials'] ?? 'CRNA'}';
  final aana = '${learner['aana_id'] ?? ''}';
  final location = '${learner['location'] ?? 'City, State / Country'}';
  final compact =
      name.length > 60 || credentials.length > 70 || location.length > 140;
  final start =
      record['participation_start_on'] ?? learner['participation_start_on'];
  final end = record['participation_end_on'] ?? learner['participation_end_on'];
  final doc = pw.Document(
    title: preview
        ? 'CE HALO Course $courseNumber Certificate Preview'
        : 'CE HALO Certificate of Completion',
    author: 'Perplexity Computer',
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );
  pw.Widget text(
    String value, {
    double size = 10,
    bool strong = false,
    PdfColor color = navy,
    pw.TextAlign align = pw.TextAlign.left,
  }) => pw.Text(
    value,
    textAlign: align,
    style: pw.TextStyle(
      fontSize: size,
      fontWeight: strong ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: color,
    ),
  );
  pw.Widget centered(
    String value, {
    double size = 10,
    bool strong = false,
    PdfColor color = navy,
  }) => text(
    value,
    size: size,
    strong: strong,
    color: color,
    align: pw.TextAlign.center,
  );
  pw.Widget field(String label, String value) => pw.Padding(
    padding: pw.EdgeInsets.only(bottom: compact ? 7 : 12),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 126,
          child: text(label, size: 10, strong: true, color: PdfColors.black),
        ),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 4),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey400, width: .5),
              ),
            ),
            child: serverTemplate
                ? pw.Annotation(
                    builder: pw.AnnotationTextField(
                      name: label,
                      value: '',
                      textStyle: pw.TextStyle(
                        font: regular,
                        fontSize: compact ? 9 : 10,
                        color: navy,
                      ),
                    ),
                    child: pw.SizedBox(
                      width: double.infinity,
                      height:
                          label == 'Name:' || label == 'Location of Completion:'
                          ? (compact ? 80 : 28)
                          : label == 'AANA ID Number:'
                          ? 28
                          : 16,
                    ),
                  )
                : text(value, size: compact ? 9 : 10),
          ),
        ),
      ],
    ),
  );
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(28),
      build: (_) => pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: navy, width: 1.6),
        ),
        padding: const pw.EdgeInsets.all(9),
        child: pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: navy, width: .5),
          ),
          padding: const pw.EdgeInsets.fromLTRB(30, 10, 30, 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Stack(
                alignment: pw.Alignment.topCenter,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 4),
                    child: pw.Divider(color: gold, thickness: 1),
                  ),
                  pw.Image(
                    logo,
                    width: compact ? 57 : 90,
                    height: compact ? 57 : 90,
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              centered('CE HALO LLC', size: compact ? 16 : 18, strong: true),
              centered('Continuing Education for CRNAs', color: gray),
              centered(
                '${record['provider_city_state'] ?? 'Buffalo, New York'}',
                color: gray,
              ),
              pw.Center(
                child: pw.UrlLink(
                  destination: 'mailto:info@cehalo.com',
                  child: text('info@cehalo.com', color: gray),
                ),
              ),
              pw.SizedBox(height: compact ? 9 : 13),
              centered('Certificate of Completion', size: 22, strong: true),
              pw.SizedBox(height: 8),
              centered('Course $courseNumber: "$courseTitle"', size: 10.5),
              pw.SizedBox(height: 4),
              centered('Independent Study', color: gray),
              if (preview) ...[
                pw.SizedBox(height: 8),
                centered(
                  'PREVIEW ONLY / NOT VALID FOR CE CREDIT',
                  size: 9,
                  strong: true,
                ),
              ],
              pw.SizedBox(height: compact ? 13 : 23),
              field('Name:', '$name, $credentials'),
              field('AANA ID Number:', aana.isEmpty ? 'Not applicable' : aana),
              field(
                'Participation Dates:',
                '${certificateDate(start)} to ${certificateDate(end)}',
              ),
              field(
                'Completion Date:',
                preview
                    ? 'Populated upon course completion'
                    : certificateDate(record['completed_on']),
              ),
              field('Location of Completion:', location),
              text(
                preview
                    ? 'Number of MAC Ed CE credits awarded: 0.00 (preview)'
                    : 'Number of MAC Ed CE credits awarded: 20.00',
                strong: true,
                size: 10,
                color: PdfColors.black,
              ),
              if (preview) ...[
                pw.SizedBox(height: 4),
                text(
                  'Full program approved for 20.00 MAC Ed CE credits.',
                  size: 9,
                  color: gray,
                ),
              ],
              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: signatureImage == null
                    ? text(
                        'Provider signature pending approval',
                        size: 9,
                        color: gray,
                      )
                    : pw.Image(
                        signatureImage,
                        width: 235,
                        height: 32,
                        fit: pw.BoxFit.contain,
                      ),
              ),
              pw.Container(
                width: 290,
                alignment: pw.Alignment.centerLeft,
                child: pw.SizedBox(
                  width: 290,
                  child: pw.Divider(color: navy, thickness: .6),
                ),
              ),
              text(
                '${record['signer_name'] ?? 'Nicole M. Fetzer, MS, CRNA'}',
                strong: true,
                color: PdfColors.black,
              ),
              text(
                '${record['signer_title'] ?? 'Owner, CE HALO LLC'} · Signature of Program Provider verifying completion',
                size: 9,
                color: gray,
              ),
              pw.SizedBox(height: compact ? 12 : 27),
              pw.Divider(color: PdfColors.grey400, thickness: .5),
              for (final statement in [
                course3
                    ? ceApprovalStatement.replaceFirst('1047239', '1047243')
                    : course2
                    ? ceApprovalStatement.replaceFirst('1047239', '1047241')
                    : ceApprovalStatement,
                if (!course3)
                  course2
                      ? cePharmacologyStatement.replaceFirst('17.50', '10.50')
                      : cePharmacologyStatement,
                if (!course3)
                  course2
                      ? cePainStatement.replaceFirst('2.50', '1.00')
                      : cePainStatement,
                ceCaliforniaStatement,
              ]) ...[
                text(statement, size: 9, color: PdfColors.black),
                pw.SizedBox(height: 5),
              ],
              pw.SizedBox(height: 3),
              if (serverTemplate)
                pw.Annotation(
                  builder: pw.AnnotationTextField(
                    name: 'certificate_id',
                    value: '',
                    textStyle: pw.TextStyle(
                      font: regular,
                      fontSize: 9,
                      color: gray,
                    ),
                  ),
                  child: pw.SizedBox(width: double.infinity, height: 14),
                )
              else
                text(
                  'Certificate ID: ${preview ? 'PREVIEW-NOT-VALID' : record['id']}',
                  size: 9,
                  color: gray,
                ),
              if (preview)
                text(
                  'Design review only. No completion or CE award is recorded.',
                  size: 9,
                  color: gray,
                ),
            ],
          ),
        ),
      ),
    ),
  );
  return doc.save();
}
