import '../surgical_prep/surgical_review_config.dart';

/// Public release scope. Surgical review is an explicit internal-build opt-in;
/// other deferred sections stay closed in either build.
abstract final class LaunchScope {
  static const deferred = <String, String>{
    '/luma-ai': 'Luma AI',
    '/surgical-prep': 'Surgical Case Prep',
    '/luma-academy': 'Luma Academy',
    '/ekg': 'EKG',
  };

  static bool isDeferred(String route) {
    if (SurgicalReviewConfig.enabled &&
        (route == '/surgical-prep' || route.startsWith('/surgical-prep/'))) {
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
