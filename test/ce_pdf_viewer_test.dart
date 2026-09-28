import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/ce/ce_pdf_viewer.dart';
import 'package:printing/printing.dart';

void main() {
  final bytes = Uint8List.fromList('%PDF-test'.codeUnits);

  Future<Widget> configuredViewer(
    WidgetTester tester,
    TargetPlatform platform,
  ) async {
    debugDefaultTargetPlatformOverride = platform;
    late Widget viewer;
    // Inspect configuration without pretending a widget test runs Apple's
    // PDFKit or a real native platform view.
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              viewer = CePdfViewer(
                bytes: bytes,
                title: 'Protected CE',
              ).build(context);
              return const SizedBox();
            },
          ),
        ),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
    return viewer;
  }

  testWidgets('iOS sends authorized bytes to the registered PDFKit view', (
    tester,
  ) async {
    final viewer =
        await configuredViewer(tester, TargetPlatform.iOS) as UiKitView;
    expect(viewer.viewType, CePdfViewer.nativeViewType);
    expect(viewer.creationParamsCodec, isA<StandardMessageCodec>());
    expect((viewer.creationParams as Map)['bytes'], same(bytes));
    expect((viewer.creationParams as Map)['title'], 'Protected CE');
    expect(viewer.key, ObjectKey(bytes));
    expect(viewer.gestureRecognizers, isNotEmpty);
  });

  testWidgets(
    'fallback keeps original PDF and disables export and modification',
    (tester) async {
      final viewer =
          await configuredViewer(tester, TargetPlatform.android) as PdfPreview;
      expect(viewer.allowPrinting, isFalse);
      expect(viewer.allowSharing, isFalse);
      expect(viewer.useActions, isFalse);
      expect(viewer.canChangePageFormat, isFalse);
      expect(viewer.canChangeOrientation, isFalse);
      expect(viewer.canDebug, isFalse);
      expect(viewer.dynamicLayout, isFalse);
      expect(await viewer.build(viewer.pageFormats.values.first), same(bytes));
    },
  );
}
