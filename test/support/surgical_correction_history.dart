import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Replay later, explicitly recorded corrections instead of requiring obsolete
/// clinical text in the reader. Every transition must match its exact preimage.
Map<String, dynamic> latestSurgicalPostimage(Map<String, dynamic> prior) {
  var expected = prior;
  for (final path in [
    'docs/surgical-testflight-2026-10-08/correction-ledger.json',
  ]) {
    final ledger = jsonDecode(File(path).readAsStringSync()) as Map;
    for (final row in ledger['records'] as List) {
      if (row['id'] != expected['id']) continue;
      expect(row['before'], equals(expected));
      expected = Map<String, dynamic>.from(row['after'] as Map);
    }
  }
  return expected;
}
