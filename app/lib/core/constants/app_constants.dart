/// App-wide constants. Branding strings live here (not scattered through
/// widgets) specifically so the product can be renamed later without a
/// find-and-replace across the codebase — see brief section 1.
class AppConstants {
  AppConstants._();

  static const String appName = 'KeepMind';
  static const String tagline =
      'Send it to KeepMind now. Remember it when it matters.';
  static const String emptyHomeMessage =
      'Nothing you need to remember right now.';
  static const String captureButtonLabel = '+ Remember something';
}
