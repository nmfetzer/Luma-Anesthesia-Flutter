import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/ce/ce_certificate_pdf.dart';
import 'package:luma_anesthesia/ce/ce_certificate_screen.dart';
import 'package:luma_anesthesia/ce/ce_demo_repository.dart';
import 'package:luma_anesthesia/ce/ce_participation_dates.dart';

Future<DemoCeRepository> registered() async {
  final repo = DemoCeRepository();
  await repo.call('demo_unlock');
  await repo.call('profile', {
    'full_name': 'Jordan Example',
    'credentials': 'DNP, CRNA',
    'aana_id': 'SAMPLE ONLY',
    'location': 'Rochester, New York, USA',
    'participation_start_on': '2026-10-01',
    'participation_end_on': '2026-10-03',
  });
  return repo;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('participation dates validate pairs, calendar, order, period and future dates', () {
    expect(validateCeParticipationDates('', ''), isNull);
    expect(validateCeParticipationDates('2026-10-01', ''), isNotNull);
    expect(validateCeParticipationDates('2026-02-30', '2026-10-03'), isNotNull);
    expect(validateCeParticipationDates('2026-10-03', '2026-10-01'), isNotNull);
    expect(validateCeParticipationDates('2026-09-30', '2026-10-03'), isNotNull);
    expect(validateCeParticipationDates('2029-09-30', '2029-10-01'), isNotNull);
    expect(
      validateCeParticipationDates(
        '2026-10-01',
        '2026-10-03',
        now: DateTime(2026, 9, 27),
      ),
      isNotNull,
    );
    expect(
      validateCeParticipationDates('2026-10-01', '2026-10-03', preview: true),
      isNull,
    );
    expect(
      validateCeParticipationDates(
        '2026-10-01',
        '2026-10-03',
        now: DateTime(2026, 10, 3),
      ),
      isNull,
    );
    expect(certificateDate('2026-10-03'), '10/3/2026');
  });
  test('unregistered preview cannot generate', () async {
    await expectLater(DemoCeRepository().call('certificate'), throwsException);
  });
  test(
    'creator can preview without completing modules; never issue credit',
    () async {
      final repo = await registered();
      final status = await repo.call('certificate');
      expect(status['can_issue'], false);
      expect((status['modules'] as List).length, 11);
      expect(
        (status['modules'] as List).where((m) => m['complete'] == true),
        isEmpty,
      );
      final response = await repo.call('certificate', {'action': 'preview'});
      final record = response['certificate'] as Map;
      expect(record['is_preview'], true);
      expect(record['credits_awarded'], 0);
      expect(record['learner']['full_name'], 'Jordan Example');
      expect(record['learner']['participation_start_on'], '2026-10-01');
      expect(record['learner']['participation_end_on'], '2026-10-03');
      await expectLater(
        repo.call('certificate', {'action': 'issue'}),
        throwsException,
      );
      final ledger = await repo.call('records', {'include_preview': true});
      expect(ledger['total'], 0);
    },
  );
  test('PDF renderer creates preview and fails closed on incomplete official record', () async {
    final repo = await registered();
    final response = await repo.call('certificate', {'action': 'preview'});
    final record = Map<String, dynamic>.from(response['certificate'] as Map);
    final pdf = await buildCeCertificatePdf(record);
    expect(pdf.length, greaterThan(10000));
    expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
    // Real production renderer output used for review; no second design template.
    await Directory('build/certificate-review').create(recursive: true);
    await File(
      'build/certificate-review/CE_HALO_Course1_Certificate_PREVIEW.pdf',
    ).writeAsBytes(pdf);
    await expectLater(
      buildCeCertificatePdf({'is_preview': false}),
      throwsStateError,
    );
    final longPdf = await buildCeCertificatePdf({
      ...record,
      'learner': {
        'full_name': List.filled(10, 'Alexandria-José').join(' '),
        'credentials': List.filled(10, 'DNP CRNA').join(' '),
        'location': List.filled(12, 'Long resort and city name').join(' '),
        'aana_id': '',
      },
    });
    expect(longPdf.length, greaterThan(10000));
    await File('build/certificate-review/long-fields-preview.pdf')
        .writeAsBytes(longPdf);
  });
  for (final width in [375.0, 1280.0]) {
    testWidgets('certificate requirements fit $width and hide official issue', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(home: CeCertificateScreen(repository: await registered())),
      );
      await tester.pumpAndSettle();
      expect(find.text('Preview certificate design'), findsOneWidget);
      expect(find.text('Generate my certificate'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
