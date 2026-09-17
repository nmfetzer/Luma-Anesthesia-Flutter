// -----------------------------------------------------------------------------
// Luma Anesthesia — app entry point.
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'screens/drugs_categories_screen.dart';
import 'theme/luma_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (LumaConfig.supabaseConfigured) {
    await Supabase.initialize(
      url: LumaConfig.supabaseUrl,
      anonKey: LumaConfig.supabaseAnonKey,
    );
  }

  runApp(const LumaApp());
}

class LumaApp extends StatelessWidget {
  const LumaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luma Anesthesia',
      debugShowCheckedModeBanner: false,
      theme: buildLumaTheme(),
      home: const DrugsCategoriesScreen(),
    );
  }
}
