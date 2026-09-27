import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'cache_backend.dart';

class CacheStorage implements CacheBackend {
  CacheStorage({this.directoryOverride});

  /// Test seam for real filesystem checks without a native platform channel.
  final Future<Directory> Function()? directoryOverride;
  int _serial = 0;
  Future<Directory> _directory() async {
    if (directoryOverride != null) return directoryOverride!();
    final root = await getApplicationSupportDirectory();
    return Directory('${root.path}/luma_offline_v1').create(recursive: true);
  }

  String _name(String key) => base64Url.encode(utf8.encode(key));
  Future<String?> read(String key) async {
    final file = File('${(await _directory()).path}/${_name(key)}');
    return await file.exists() ? file.readAsString() : null;
  }

  Future<void> write(String key, String value) async {
    final path = '${(await _directory()).path}/${_name(key)}';
    final tmp = File(
      '$path.${DateTime.now().microsecondsSinceEpoch}.${_serial++}.tmp',
    );
    await tmp.writeAsString(value, flush: true);
    await tmp.rename(path);
  }

  Future<void> remove(String key) async {
    final file = File('${(await _directory()).path}/${_name(key)}');
    if (await file.exists()) await file.delete();
  }

  Future<List<String>> keys() async {
    final files = await (await _directory()).list().toList();
    final keys = <String>[];
    for (final file in files.whereType<File>()) {
      if (file.path.endsWith('.tmp')) continue;
      try {
        keys.add(utf8.decode(base64Url.decode(file.uri.pathSegments.last)));
      } catch (_) {
        /* Ignore unrelated/corrupt filenames. */
      }
    }
    return keys;
  }

  Future<String?> secret() =>
      const FlutterSecureStorage().read(key: 'luma_offline_key_v1');
  Future<void> saveSecret(String value) => const FlutterSecureStorage().write(
    key: 'luma_offline_key_v1',
    value: value,
  );
  bool get supportsPrivate => true;
}
