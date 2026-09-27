import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/main.dart';
import 'package:luma_anesthesia/ce/ce_screen.dart';
import 'package:luma_anesthesia/crisis/provider_support_screen.dart';
import 'package:luma_anesthesia/diagnostics/diagnostics_screen.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_screen.dart';

void main() {
  test('production defaults preserve clinical review and normal app entry', () {
    const app = LumaApp();
    expect(app.showDiagnosticsDraft, isFalse);
    expect(app.cePortal, isFalse);
    expect(app.allowSocialSignIn, isTrue);
  });

  testWidgets(
    'merged navigation retains Diagnostics, support, Quick Ref and CE',
    (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      await tester.pumpWidget(const LumaApp(showDiagnosticsDraft: true));
      await tester.pump(const Duration(milliseconds: 500));
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final context = tester.element(find.byType(MaterialApp));
      Widget screen(String name, [Object? arguments]) {
        final route =
            app.onGenerateRoute!(
                  RouteSettings(name: name, arguments: arguments),
                )!
                as MaterialPageRoute<dynamic>;
        return route.builder(context);
      }

      expect(screen('/provider-support'), isA<ProviderSupportScreen>());
      final quick =
          screen('/quick-references', 'GLP1') as QuickReferencesScreen;
      expect(quick.initialQuery, 'GLP1');
      final diagnostics = screen('/diagnostics') as DiagnosticsScreen;
      expect(diagnostics.showClinicalDraft, isTrue);
      expect(screen('/ce-halo'), isA<CeCourseScreen>());
      expect(screen('/ce-halo/courses'), isA<CeCourseScreen>());
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Luma app starts at the existing welcome flow', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(const LumaApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
