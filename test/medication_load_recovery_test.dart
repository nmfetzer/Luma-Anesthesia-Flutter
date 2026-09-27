import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:luma_anesthesia/data/medication_repository.dart';
import 'package:luma_anesthesia/screens/drugs_categories_screen.dart';
import 'package:luma_anesthesia/screens/category_detail_screen.dart';

import 'medication_sources_test.dart' show MemoryAuthStorage;

void main() {
  var fail = true;
  final offsets = <int>[];
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test',
      httpClient: MockClient((request) async {
        if (fail) throw http.ClientException('Network unavailable');
        final offset = int.parse(request.url.queryParameters['offset'] ?? '0');
        offsets.add(offset);
        return http.Response(
          jsonEncode(
            List.generate(
              offset == 0 ? 200 : 1,
              (i) => {
                'id': '${offset + i}',
                'name': 'Medication ${offset + i}',
                'category': 'Cardiac & Hemodynamics',
              },
            ),
          ),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: MemoryAuthStorage(),
        autoRefreshToken: false,
        detectSessionInUri: false,
      ),
    );
  });
  tearDownAll(() => Supabase.instance.dispose());
  setUp(() {
    fail = true;
    offsets.clear();
    MedicationRepository.instance.clearCache();
  });
  for (final screen in [
    const DrugsCategoriesScreen(),
    const CategoryDetailScreen(category: null),
  ]) {
    testWidgets(
      '${screen.runtimeType} network error stops spinner and retries',
      (t) async {
        await t.pumpWidget(MaterialApp(home: screen));
        await t.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.textContaining('An internet connection'), findsOneWidget);
        fail = false;
        await t.tap(find.text('Retry'));
        // Large PostgREST pages are decoded on a real isolate, outside the
        // widget test's fake clock.
        await t.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)),
        );
        await t.pumpAndSettle();
        expect(find.textContaining('An internet connection'), findsNothing);
        expect(await MedicationRepository.instance.all(), hasLength(201));
        expect(offsets, [0, 200]);
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets('drug header menu and account are real navigation controls', (
    t,
  ) async {
    fail = false;
    await t.pumpWidget(
      MaterialApp(
        home: const DrugsCategoriesScreen(),
        routes: {
          '/account': (_) => const Scaffold(body: Text('Account destination')),
        },
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('NF'), findsNothing);
    await t.tap(find.byTooltip('Menu'));
    await t.pumpAndSettle();
    expect(find.text('MEDICATIONS'), findsOneWidget);
    Navigator.of(t.element(find.text('MEDICATIONS'))).pop();
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Account'));
    await t.pumpAndSettle();
    expect(find.text('Account destination'), findsOneWidget);
  });
}
