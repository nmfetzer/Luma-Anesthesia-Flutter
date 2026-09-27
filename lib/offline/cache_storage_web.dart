import 'package:shared_preferences/shared_preferences.dart';
import 'cache_backend.dart';

/// Browser storage is only for public references, never protected prose.
class CacheStorage implements CacheBackend {
  static const prefix = 'luma_offline_v1:';
  Future<String?> read(String key) async =>
      (await SharedPreferences.getInstance()).getString('$prefix$key');
  Future<void> write(String key, String value) async {
    if (!await (await SharedPreferences.getInstance()).setString(
      '$prefix$key',
      value,
    )) {
      throw StateError('Browser storage is unavailable or full.');
    }
  }

  Future<void> remove(String key) async =>
      (await SharedPreferences.getInstance()).remove('$prefix$key');
  Future<List<String>> keys() async => (await SharedPreferences.getInstance())
      .getKeys()
      .where((k) => k.startsWith(prefix))
      .map((k) => k.substring(prefix.length))
      .toList();
  Future<String?> secret() async => null;
  Future<void> saveSecret(String value) async =>
      throw UnsupportedError('Native only');
  bool get supportsPrivate => false;
}
