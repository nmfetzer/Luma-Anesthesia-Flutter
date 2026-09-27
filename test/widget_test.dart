import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/main.dart';
import 'package:luma_anesthesia/ce/ce_library_screen.dart';
import 'package:luma_anesthesia/crisis/provider_support_screen.dart';
import 'package:luma_anesthesia/launch/deferred_section_screen.dart';
import 'package:luma_anesthesia/launch/launch_scope.dart';
import 'package:luma_anesthesia/quick_references/quick_reference_screen.dart';
import 'package:luma_anesthesia/special_considerations/special_considerations_screen.dart';

void main() {
  test('production defaults preserve clinical review and normal app entry', () {
    const app = LumaApp();
    expect(app.showComingSoon, isFalse);
    expect(app.cePortal, isFalse);
    expect(app.allowSocialSignIn, isTrue);
  });

  testWidgets(
    'launch navigation blocks deferred sections, retains support, Quick Ref and CE',
    (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      await tester.pumpWidget(const LumaApp());
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
      expect(LaunchScope.isDeferred('/special-considerations'), isFalse);
      final considerations = screen('/special-considerations')
          as SpecialConsiderationsScreen;
      expect(considerations.onSubscribe, isNotNull);
      expect(considerations.onSignIn, isNotNull);
      final quick =
          screen('/quick-references', 'GLP1') as QuickReferencesScreen;
      expect(quick.initialQuery, 'GLP1');
      for (final path in LaunchScope.deferred.keys) {
        final deferred = screen(path) as DeferredSectionScreen;
        expect(deferred.showComingSoon, isFalse);
        expect(
          screen('$path/detail?preview=true'),
          isA<DeferredSectionScreen>(),
        );
      }
      expect(screen('/ce-halo'), isA<CeLibraryScreen>());
      expect(screen('/ce-halo/courses'), isA<CeLibraryScreen>());
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'private preview uses inert coming-soon routes, never draft content',
    (tester) async {
      await tester.pumpWidget(const LumaApp(showComingSoon: true));
      await tester.pump(const Duration(milliseconds: 100));
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final route =
          app.onGenerateRoute!(const RouteSettings(name: '/diagnostics'))!
              as MaterialPageRoute<dynamic>;
      final screen = route.builder(
        tester.element(find.byType(MaterialApp)),
      ) as DeferredSectionScreen;
      expect(screen.showComingSoon, isTrue);
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
