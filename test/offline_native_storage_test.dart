import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:luma_anesthesia/offline/cache_storage_native.dart';
import 'package:luma_anesthesia/offline/offline_cache.dart';

class FileTestStorage extends CacheStorage {
  FileTestStorage(Directory dir, this.keyStore)
    : super(directoryOverride: () async => dir);
  final Map<String, String> keyStore;
  @override
  Future<String?> secret() async => keyStore['key'];
  @override
  Future<void> saveSecret(String value) async {
    keyStore['key'] = value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('native encrypted files survive new instances; parallel writes remain intact', () async {
    final dir = await Directory.systemTemp.createTemp('luma-offline-test-');
    addTearDown(() => dir.delete(recursive: true));
    final keyStore = <String, String>{};
    final first = OfflineCache(storage: FileTestStorage(dir, keyStore));
    await first.setOwner('fixture-user');
    await first.grant(DateTime.now().add(const Duration(hours: 1)));
    await first.save('public', {'title': 'public fixture'});
    await first.save('private', {'title': 'private fixture'}, private: true);
    final rawFiles = await dir
        .list()
        .where((f) => f is File)
        .cast<File>()
        .toList();
    final bytes = (await Future.wait(rawFiles.map((f) => f.readAsString())))
        .join();
    expect(bytes, contains('public fixture'));
    expect(bytes, isNot(contains('private fixture')));
    final restarted = OfflineCache(storage: FileTestStorage(dir, keyStore));
    await restarted.setOwner('fixture-user');
    expect(await restarted.saved('private', private: true), {
      'title': 'private fixture',
    });
    await Future.wait(List.generate(12, (_) => restarted.restoreLease()));
    expect(await restarted.restoreLease(), isTrue);
    expect(
      (await dir.list().toList()).where((f) => f.path.endsWith('.tmp')),
      isEmpty,
    );
    await restarted.setOwner(null);
    expect(
      (await restarted.storage.keys()).every((k) => k.startsWith('public:')),
      isTrue,
    );
  });
}
