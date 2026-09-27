// Isolated UI preview. Never imported by production main.dart.
import 'package:flutter/material.dart';

import 'ce/ce_course2_demo_data.dart';
import 'ce/ce_course3_demo_data.dart';
import 'ce/ce_demo_repository.dart';
import 'ce/ce_library_screen.dart';
import 'theme/luma_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repos = [
    DemoCeRepository(),
    DemoCeRepository(
      courseNumber: 2,
      catalog: demoCourse2Catalog,
      questionBanks: demoCourse2Banks,
    ),
    DemoCeRepository(
      courseNumber: 3,
      catalog: demoCourse3Catalog,
      questionBanks: demoCourse3Banks,
    ),
  ];
  for (final repo in repos) {
    await repo.call('demo_unlock');
    await repo.call('profile', {
      'full_name': 'Jordan Example',
      'credentials': 'DNP, CRNA',
      'aana_id': '',
      'location': 'Rochester, New York, USA',
      'participation_start_on': '2026-10-01',
      'participation_end_on': '2026-10-03',
    });
  }
  runApp(
    MaterialApp(
      title: 'CE HALO | Course Library Preview',
      debugShowCheckedModeBanner: false,
      theme: buildLumaTheme(),
      home: CeLibraryScreen(repositories: repos),
    ),
  );
}
