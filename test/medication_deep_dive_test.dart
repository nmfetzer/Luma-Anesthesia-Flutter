import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/widgets/medication_deep_dive.dart';
import 'package:luma_anesthesia/data/medication_public_fields.dart';

void main() {
  test('public projection excludes only Deep Dive', () {
    expect(medicationPublicFields, isNot(contains('deep_dive_content')));
    for (final field in ['adult_dose', 'peds_dose', 'clinical_pearls', 'sources']) {
      expect(medicationPublicFields, contains(field));
    }
  });

  testWidgets('denied drug Deep Dive opens paywall, not account',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: MedicationDeepDive(
        medicationId: 'test',
        load: () async => {'allowed': false},
      )),
      routes: {
        '/subscribe': (_) => const Scaffold(body: Text('Subscription paywall')),
      },
    ));
    await tester.tap(find.text('Open Deep Dive'));
    await tester.pumpAndSettle();
    expect(find.text('Subscription paywall'), findsOneWidget);
  });

  testWidgets('paid prose loads on demand and clears on auth change',
      (tester) async {
    final changes = StreamController<void>.broadcast();
    addTearDown(changes.close);
    var requests = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: MedicationDeepDive(
        medicationId: 'test',
        authChanges: changes.stream,
        load: () async {
          requests++;
          return {'allowed': true, 'body': 'Protected test prose'};
        },
      )),
    ));
    expect(requests, 0);
    await tester.tap(find.text('Open Deep Dive'));
    await tester.pumpAndSettle();
    expect(find.text('Protected test prose'), findsOneWidget);
    changes.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Protected test prose'), findsNothing);
  });

  testWidgets('network failure does not pretend the user needs to pay',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: MedicationDeepDive(
        medicationId: 'test',
        load: () async => throw StateError('offline'),
      )),
    ));
    await tester.tap(find.text('Open Deep Dive'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Unable to check access'), findsOneWidget);
  });
}
