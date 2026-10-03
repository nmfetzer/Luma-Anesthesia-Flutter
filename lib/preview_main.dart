// Embedded browser preview only. The mobile app still uses main.dart.
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'main.dart' show LumaApp;
import 'offline/offline_library.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (LumaConfig.supabaseConfigured) {
    await Supabase.initialize(
      url: LumaConfig.supabaseUrl,
      anonKey: LumaConfig.supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: _PreviewMemoryStorage(),
        detectSessionInUri: false,
        autoRefreshToken: false,
      ),
    );
    try {
      await OfflineLibrary.initialize(Supabase.instance.client);
    } catch (_) {}
  }
  runApp(
    const LumaApp(
      allowSocialSignIn: false,
      showComingSoon: true,
      diagnosticsReviewPreview: true,
    ),
  );
}

class _PreviewMemoryStorage extends GotrueAsyncStorage {
  final Map<String, String> _items = {};

  @override
  Future<String?> getItem({required String key}) async => _items[key];

  @override
  Future<void> setItem({required String key, required String value}) async {
    _items[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _items.remove(key);
  }
}
