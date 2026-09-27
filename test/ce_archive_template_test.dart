// Builds server-only templates from the exact approved Flutter layout.
// No fixture reaches the database, Storage or a real learner account.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/ce/ce_certificate_pdf.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('generate versioned archive templates with approved design', () async {
    final signature = base64Encode(
      await File('assets/branding/ce_halo_preview_signature.png').readAsBytes(),
    );
    await Directory('build/certificate-templates').create(recursive: true);
    for (final course in [1, 2]) {
      for (final compact in [false, true]) {
        final bytes = await buildCeCertificatePdf({
          'is_preview': false,
          'id': 'TEMPLATE-NOT-ISSUED',
          'course_id': course == 2 ? '1047241' : '1047239',
          'template_version': 'cehalo-course$course-v1',
          'credits_awarded': 20,
          'completed_on': '2026-10-03',
          'signature_png_base64': signature,
          'learner': {
            'full_name': compact ? 'A' * 100 : '',
            'credentials': '',
            'location': '',
          },
        }, serverTemplate: true);
        expect(bytes.length, greaterThan(10000));
        await File(
          'build/certificate-templates/course$course-${compact ? "compact" : "standard"}.pdf',
        ).writeAsBytes(bytes);
      }
    }
  });
}
