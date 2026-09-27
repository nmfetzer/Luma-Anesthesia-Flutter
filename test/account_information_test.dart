import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/theme/luma_theme.dart';
import 'package:luma_anesthesia/widgets/account_information.dart';
import 'package:luma_anesthesia/screens/account_screen.dart';

import 'account_screen_test.dart' show FakeAccount;

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget app({Future<bool> Function(Uri)? open, double scale = 1}) =>
      MaterialApp(
        theme: buildLumaTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AccountInformation(openExternal: open),
          ),
        ),
      );

  testWidgets('all four policy buttons open the exact CE HALO destinations', (
    tester,
  ) async {
    final opened = <Uri>[];
    await tester.pumpWidget(
      app(
        open: (uri) async {
          opened.add(uri);
          return true;
        },
      ),
    );
    for (final label in [
      'Privacy Policy',
      'Medical Disclaimer',
      'Terms of Use & EULA',
      'Data Protection & HIPAA Statement',
    ]) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    expect(opened.map((uri) => uri.toString()), [
      'https://cehalo.com/privacy-policy',
      'https://cehalo.com/medical-disclaimer',
      'https://cehalo.com/terms-of-use-eula',
      'https://cehalo.com/data-protection-hipaa',
    ]);
  });

  testWidgets('support actions compose addressed and subject-labeled emails', (
    tester,
  ) async {
    final opened = <Uri>[];
    await tester.pumpWidget(
      app(
        open: (uri) async {
          opened.add(uri);
          return true;
        },
      ),
    );
    for (final label in [
      'Contact CE HALO LLC',
      'Report a content concern',
      'Ask about CE reporting',
      'Contact us about your data',
    ]) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    expect(
      opened.every(
        (uri) => uri.scheme == 'mailto' && uri.path == 'info@cehalo.com',
      ),
      isTrue,
    );
    expect(opened.map((uri) => uri.queryParameters['subject']), [
      'Luma Anesthesia question or suggestion',
      'Luma Anesthesia content concern',
      'CE completion and AANA reporting',
      'Privacy Request',
    ]);
  });

  testWidgets('unavailable browser gives a selectable address and can close', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(app(open: (_) async => false));
    await tester.ensureVisible(find.text('Privacy Policy'));
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(SelectableText, 'https://cehalo.com/privacy-policy'),
      findsOneWidget,
    );
    await tester.tap(find.text('Copy address'));
    await tester.pumpAndSettle();
    expect(copied, 'https://cehalo.com/privacy-policy');
    expect(find.text('Address copied'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('email launch exceptions retain a usable contact address', (
    tester,
  ) async {
    await tester.pumpWidget(app(open: (_) async => throw StateError('no app')));
    await tester.ensureVisible(find.text('Contact CE HALO LLC'));
    await tester.tap(find.text('Contact CE HALO LLC'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(SelectableText, 'info@cehalo.com'),
      findsOneWidget,
    );
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final signedIn in [false, true]) {
    testWidgets('information remains available when signedIn=$signedIn', (
      tester,
    ) async {
      final account = FakeAccount();
      if (signedIn) account.email = 'review@example.com';
      await tester.pumpWidget(
        MaterialApp(home: AccountScreen(access: account)),
      );
      await tester.pumpAndSettle();
      expect(find.text(AccountInformation.clinicalDisclaimer), findsOneWidget);
      expect(
        find.text(
          'Completed CEs are sent to the AANA at the end of every month.',
        ),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('Privacy Policy'));
      expect(find.text('Privacy Policy').hitTestable(), findsOneWidget);
    });
  }

  testWidgets('narrow viewport and large text have no layout overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(scale: 2));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Data Protection & HIPAA Statement'));
    expect(tester.takeException(), isNull);
  });
}
