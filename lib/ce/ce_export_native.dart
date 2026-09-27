import 'package:flutter/services.dart';

Future<String> saveCeCsv(String filename, String content) async {
  await Clipboard.setData(ClipboardData(text: content));
  return 'CSV copied. Paste into a secure file, or use the web portal to download.';
}
