// Isolated design preview; never a production entrypoint.
import 'package:flutter/material.dart';

import 'ce/ce_demo_repository.dart';
import 'ce/ce_course3_demo_data.dart';
import 'ce/ce_screen.dart';
import 'theme/luma_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'CE HALO | Course 3 Preview',
      debugShowCheckedModeBanner: false,
      theme: buildLumaTheme(),
      home: CeCourseScreen(
        repository: DemoCeRepository(
          courseNumber: 3,
          catalog: demoCourse3Catalog,
          questionBanks: demoCourse3Banks,
        ),
      ),
    ),
  );
}
