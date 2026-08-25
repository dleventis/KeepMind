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

  /// App Store review requires a reachable privacy policy, and — for
  /// auto-renewable subscriptions — terms of use (an EULA). These are
  /// placeholders: submitting with them unresolved is a guaranteed
  /// rejection, so they must point at real, live pages before the build
  /// is sent for review.
  ///
  /// TODO(pre-submission): replace with the real hosted URLs.
  static const String privacyPolicyUrl = 'https://keepmind.app/privacy';
  static const String termsOfUseUrl = 'https://keepmind.app/terms';

  /// Apple's canonical deep link to the user's own subscription
  /// management. Review expects a way out of a subscription that is not
  /// buried — linking here rather than explaining where to tap is both
  /// kinder and what the guidelines ask for.
  static const String manageSubscriptionsUrl =
      'https://apps.apple.com/account/subscriptions';
}
