/// App-wide constants. Branding strings live here (not scattered through
/// widgets) specifically so the product can be renamed later without a
/// find-and-replace across the codebase — see brief section 1.
class AppConstants {
  AppConstants._();

  static const String appName = 'Mindkeep';
  static const String tagline = 'Capture it now. Remember it when it matters.';
  static const String emptyHomeMessage =
      'Nothing you need to remember right now.';
  static const String captureButtonLabel = '+ Remember something';

  /// App Store review requires a subscription app to expose a reachable
  /// privacy policy and terms of use (Guideline 3.1.2). Both are linked
  /// from Settings.
  ///
  /// The policy is served from this repo's own docs/ folder via GitHub
  /// Pages — no domain to buy or renew, and it stays version-controlled
  /// alongside the behaviour it describes. Pages is enabled and this URL
  /// was verified live on 25 August 2026; re-check it before any
  /// submission, since a dead link here is a certain rejection.
  static const String privacyPolicyUrl =
      'https://dleventis.github.io/KeepMind/privacy.html';

  /// Apple's Standard EULA. Apple explicitly supports linking to this
  /// instead of writing a custom agreement, so there is one fewer page to
  /// host and keep alive. Replace only if Mindkeep ever needs terms that
  /// differ from the standard ones.
  static const String termsOfUseUrl =
      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

  /// Apple's canonical deep link to the user's own subscription
  /// management. Review expects a way out of a subscription that is not
  /// buried — linking here rather than explaining where to tap is both
  /// kinder and what the guidelines ask for.
  static const String manageSubscriptionsUrl =
      'https://apps.apple.com/account/subscriptions';
}
