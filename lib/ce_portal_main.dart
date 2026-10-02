// Production CE web portal entry point for ce.cehalo.com.
// Uses real Supabase authentication and gating; never imports demo fixtures.
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'main.dart' show LumaApp;
import 'ce/web/ce_web_checkout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: LumaConfig.supabaseUrl,
    publishableKey: LumaConfig.supabaseAnonKey,
  );
  runApp(const CeWebCheckoutScope(child: LumaApp(cePortal: true)));
}
