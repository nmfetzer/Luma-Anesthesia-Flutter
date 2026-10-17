// LOCAL QA ONLY. This entry point is never used for the delivered portal build.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:luma_anesthesia/academy/academy_repository.dart';
import 'package:luma_anesthesia/academy/academy_screen.dart';
import 'package:luma_anesthesia/theme/luma_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildLumaTheme(),
      home: AcademyLearningHome(
        repository: AcademyRepository.test((fn, args) async {
          final response = await http.post(
            Uri.base.resolve('/rpc/$fn'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(args),
          );
          if (response.statusCode != 200) throw StateError('QA request failed');
          return jsonDecode(response.body);
        }, () => 'local-synthetic-owner'),
      ),
    ),
  );
}
