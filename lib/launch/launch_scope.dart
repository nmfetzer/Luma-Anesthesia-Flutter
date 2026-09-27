/// Initial release scope. Deferred implementations remain in source control,
/// but are not imported or opened by the launch app.
abstract final class LaunchScope {
  static const deferred = <String, String>{
    '/luma-ai': 'Luma AI',
    '/surgical-prep': 'Surgical Case Prep',
    '/diagnostics': 'Diagnostics',
    '/regional-procedures': 'Regional & Procedures',
    '/practice-guidelines': 'Practice Guidelines',
    '/luma-academy': 'Luma Academy',
    '/ekg': 'EKG',
  };

  static bool isDeferred(String route) =>
      deferred.keys.any((base) => route == base || route.startsWith('$base/'));

  static String titleFor(String route) => deferred.entries
      .firstWhere(
        (entry) => route == entry.key || route.startsWith('${entry.key}/'),
      )
      .value;
}
