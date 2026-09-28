import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

/// Displays already-authorized PDF bytes. This widget does not fetch documents,
/// write files, change course access, or generate a replacement certificate.
class CePdfViewer extends StatelessWidget {
  const CePdfViewer({super.key, required this.bytes, required this.title});

  final Uint8List bytes;
  final String title;

  static const nativeViewType = 'com.cehalo.luma/pdf-view';

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      // PDFKit preserves PDF text, links, scrolling and pinch zoom. A changed
      // byte buffer gets a fresh platform view rather than a stale document.
      return UiKitView(
        key: ObjectKey(bytes),
        viewType: nativeViewType,
        creationParams: {'bytes': bytes, 'title': title},
        creationParamsCodec: const StandardMessageCodec(),
        gestureRecognizers: const {
          Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
        },
      );
    }

    // Use the printing plugin already required for certificate downloads.
    // Never expose print/share or page-format changes for paid learner PDFs.
    return PdfPreview(
      key: ObjectKey(bytes),
      build: (_) => bytes,
      useActions: false,
      allowPrinting: false,
      allowSharing: false,
      canChangePageFormat: false,
      canChangeOrientation: false,
      canDebug: false,
      dynamicLayout: false,
      maxPageWidth: 1400,
      onError: (_, __) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Unable to display this PDF. Return to the course and try again.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
