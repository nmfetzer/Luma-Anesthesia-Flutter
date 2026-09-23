import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma_anesthesia/main.dart';

void main() {
  testWidgets('Luma app starts at the existing welcome flow', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(const LumaApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
