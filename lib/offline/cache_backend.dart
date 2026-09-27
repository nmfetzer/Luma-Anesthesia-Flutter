abstract interface class CacheBackend {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
  Future<List<String>> keys();
  Future<String?> secret();
  Future<void> saveSecret(String value);
  bool get supportsPrivate;
}
