import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/vasopressors/vasopressors_screen.dart';
import 'package:luma_anesthesia/blood_products/blood_products_view.dart';
import 'package:luma_anesthesia/vasopressors/drug_detail_screen.dart';

final drugs = [
  {
    'id': 'norepi',
    'name': 'Norepinephrine',
    'brand_name': 'Levophed',
    'vasoactive_role': 'vasopressor',
    'high_alert': true,
    'hemodynamic_tags': ['raises_bp'],
    'adult_dose': 'Test dose with important qualifications'
  },
  {
    'id': 'dob',
    'name': 'Dobutamine',
    'vasoactive_role': 'vasopressor',
    'hemodynamic_tags': ['raises_co']
  },
  {
    'id': 'prop',
    'name': 'Propofol',
    'brand_name': 'Diprivan',
    'vasoactive_role': 'infusion',
    'high_alert': true,
    'hemodynamic_tags': ['lowers_bp']
  },
];
final blood = [
  {
    'name': 'Packed Red Blood Cells',
    'abbreviation': 'PRBC',
    'category': 'Cellular',
    'typical_dose': r'First line\nSecond line',
    'sources': [
      {'citation': 'Example reference', 'url': 'https://example.com/clinical'}
    ]
  },
];

Future<void> open(
  WidgetTester tester, {
  Future<List<Map<String, dynamic>>> Function()? load,
}) async {
  await tester.pumpWidget(MaterialApp(
    home: VasopressorsScreen(
        loadMedications: load ?? () async => drugs,
        loadBloodProducts: () async => blood),
    routes: {'/home': (_) => const Scaffold(body: Text('Dashboard'))},
  ));
  await tester.pumpAndSettle();
}

void main() {
  for (final size in [
    const Size(320, 740),
    const Size(375, 812),
    const Size(1280, 800)
  ]) {
    testWidgets('tabs fit and work at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await open(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('2 OF 2 DRUGS'), findsOneWidget);
      expect(find.textContaining('Test dose'), findsNothing);
      await tester.tap(find.text('INFUSIONS'));
      await tester.pumpAndSettle();
      expect(find.text('Propofol'), findsOneWidget);
      await tester.tap(find.text('TRANSFUSIONS'));
      await tester.pumpAndSettle();
      expect(find.byType(BloodProductsView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('live search, filters, empty state and tab reset',
      (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), 'levop');
    await tester.pumpAndSettle();
    expect(find.text('Norepinephrine'), findsOneWidget);
    expect(find.text('Dobutamine'), findsNothing);
    await tester.enterText(find.byType(TextField), 'notfound');
    await tester.pumpAndSettle();
    expect(find.text('Clear search and filters'), findsOneWidget);
    await tester.tap(find.text('Clear search and filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('RAISES CO'));
    await tester.pumpAndSettle();
    expect(find.text('Dobutamine'), findsOneWidget);
    expect(find.text('Norepinephrine'), findsNothing);
    await tester.tap(find.text('INFUSIONS'));
    await tester.pumpAndSettle();
    expect(find.text('Propofol'), findsOneWidget);
  });

  testWidgets('network errors hide internals and retry recovers',
      (tester) async {
    var calls = 0;
    await open(tester, load: () async {
      if (calls++ == 0) throw StateError('private diagnostic');
      return drugs;
    });
    expect(find.textContaining('private diagnostic'), findsNothing);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Norepinephrine'), findsOneWidget);
  });

  testWidgets('direct-route Back and Home return to tiles', (tester) async {
    await open(tester);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await open(tester);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('transfusion search, detail and structured reference',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('TRANSFUSIONS'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pumpAndSettle();
    expect(find.text('No matching transfusion references.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'prbc');
    await tester.pumpAndSettle();
    await tester
        .tap(find.textContaining('Packed Red Blood Cells', findRichText: true));
    await tester.pumpAndSettle();
    expect(find.text('First line\nSecond line'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Example reference'), 400);
    expect(
        find.ancestor(
            of: find.text('Example reference'),
            matching: find.byType(TextButton)),
        findsOneWidget);
  });

  testWidgets(
      'drug detail removes raw bold markers and retains complete dosing',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: DrugDetailScreen(drug: {
      'id': 'test',
      'name': 'Reference test',
      'adult_dose':
          r'**Example indication:**\nComplete dose with qualifications',
      'sources': [
        {'citation': 'Example label', 'url': 'https://example.com/label'}
      ],
    })));
    await tester.pumpAndSettle();
    expect(find.text('Example indication:'), findsOneWidget);
    expect(find.text('Complete dose with qualifications'), findsOneWidget);
    expect(find.textContaining('**'), findsNothing);
  });
}
