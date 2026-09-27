// Isolated design preview. Never used for an App Store or Play Store build.
import 'package:flutter/material.dart';
import 'ce/ce_demo_repository.dart';
import 'ce/ce_screen.dart';
import 'theme/luma_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'CE HALO | Course 1 Preview',
      debugShowCheckedModeBanner: false,
      theme: buildLumaTheme(),
      home: CeCourseScreen(repository: DemoCeRepository()),
    ),
  );
}
