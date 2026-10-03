import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/link.dart';

import 'package:luma_anesthesia/ce/web/ce_portal_frame.dart';

void main() {
  testWidgets('main website link preserves portal in a separate tab', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CePortalFrame(child: Scaffold(body: Text('Course content'))),
      ),
    );
    final link = tester.widget<Link>(find.byType(Link));
    expect(link.uri, Uri.parse('https://cehalo.com/'));
    expect(link.target, LinkTarget.blank);
    expect(find.text('Back to CE HALO'), findsOneWidget);
    expect(find.text('Course content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0, 820.0, 1280.0]) {
    testWidgets('navigation fits width $width with large text', (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const CePortalFrame(
            child: Scaffold(body: Text('Course content')),
          ),
        ),
      );
      expect(find.text('Back to CE HALO'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
