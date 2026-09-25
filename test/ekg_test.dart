import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/ekg/ekg_content.dart';
import 'package:luma_anesthesia/ekg/ekg_screen.dart';

void main() {
  test('specification includes twenty rhythms with all four required sections', () {
    final rhythms = ekgEntries.where((e) => e.category == 'Rhythm Library');
    expect(rhythms.length, 20);
    for (final rhythm in rhythms) {
      expect(rhythm.sections.keys, [
        'Key ECG Findings', 'Anesthesia Considerations',
        'Proceed vs Delay Considerations', 'Monitoring Requirements']);
      expect(rhythm.sources, isNotEmpty);
    }
    expect(ekgEntries.where((e) => e.category == 'Electrolytes').length, 6);
    expect(ekgEntries.map((e) => e.title).toSet().length, ekgEntries.length);
  });

  testWidgets('production route does not expose clinical draft', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: EkgScreen()));
    expect(find.textContaining('not yet available'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('owner can search the EKG draft and open all four sections',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: EkgScreen(showClinicalDraft: true)));
    await tester.enterText(find.byType(TextField), 'Mobitz II');
    await tester.pump();
    await tester.tap(find.widgetWithText(ListTile, 'Mobitz II'));
    await tester.pumpAndSettle();
    expect(find.text('Key ECG Findings'), findsOneWidget);
    expect(find.text('Anesthesia Considerations'), findsOneWidget);
    await tester.ensureVisible(find.text('Monitoring Requirements'));
    expect(find.text('Monitoring Requirements'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
