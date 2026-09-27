// Isolated design preview; never a production entrypoint.
import 'package:flutter/material.dart';

import 'ce/ce_demo_repository.dart';
import 'ce/ce_course2_demo_data.dart';
import 'ce/ce_screen.dart';
import 'theme/luma_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'CE HALO | Course 2 Preview',
      debugShowCheckedModeBanner: false,
      theme: buildLumaTheme(),
      home: CeCourseScreen(
        repository: DemoCeRepository(
          courseNumber: 2,
        catalog: demoCourse2Catalog,
        questionBanks: demoCourse2Banks,
        ),
      ),
    ),
  );
}
