import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<String> saveCeCsv(String filename, String content) async {
  final blob = web.Blob(
    ['\uFEFF$content'.toJS].toJS,
    web.BlobPropertyBag(type: 'text/csv;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  await Future<void>.delayed(const Duration(seconds: 1));
  web.URL.revokeObjectURL(url);
  return 'CSV download requested. Store this learner information securely.';
}
