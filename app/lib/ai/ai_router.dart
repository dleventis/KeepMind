import 'ai_provider.dart';

/// The only class the rest of the app talks to for AI capabilities.
/// Selects the user's configured/active provider and delegates — nothing
/// upstream of this ever imports `OpenAIProvider` etc. directly (brief
/// section 14). No provider is configured by default: with none set, the
/// app must remain fully usable for manual capture, browsing, and local
/// reminders (see docs/AI_PROVIDERS.md risk note on BYOK adoption).
class AIRouter {
  /// Positional rather than named because the backing field is private
  /// and Dart forbids a named parameter starting with an underscore.
  AIRouter([this._activeProvider]);

  AIProvider? _activeProvider;

  AIProvider? get activeProvider => _activeProvider;

  void setActiveProvider(AIProvider? provider) {
    _activeProvider = provider;
  }

  bool get hasActiveProvider => _activeProvider != null;
}
