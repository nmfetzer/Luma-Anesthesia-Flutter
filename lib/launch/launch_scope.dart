/// Public release scope. Deferred sections stay closed in every build.
abstract final class LaunchScope {
  static const deferred = <String, String>{
    '/luma-ai': 'Luma AI',
    '/luma-academy': 'Luma Academy',
    '/ekg': 'EKG',
  };

  static bool isDeferred(String route) {
    return deferred.keys.any(
      (base) => route == base || route.startsWith('$base/'),
    );
  }

  static String titleFor(String route) => deferred.entries
      .firstWhere(
        (entry) => route == entry.key || route.startsWith('${entry.key}/'),
      )
      .value;
}
