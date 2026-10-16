/// Public release scope. Deferred sections stay closed in every build.
abstract final class LaunchScope {
  /// Review builds opt in. Does not create an Academy purchase entitlement.
  static const academyConnected = bool.fromEnvironment(
    'LUMA_ACADEMY_CONNECTED_ENABLED',
  );
  static const deferred = <String, String>{
    '/luma-ai': 'Luma AI',
    '/luma-academy': 'Luma Academy',
    '/ekg': 'EKG',
  };

  static bool isDeferred(String route) {
    if (academyConnected &&
        (route == '/luma-academy' || route.startsWith('/luma-academy/'))) {
      return false;
    }
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
