/// Explicit opt-in for a clinician's internal TestFlight review archive only.
/// Not inferred from receipt environment, URL parameters, or Apple review flags.
/// Never use this archive for public App Store release.
abstract final class SurgicalReviewConfig {
  static const enabled = bool.fromEnvironment('LUMA_SURGICAL_REVIEW');
}
