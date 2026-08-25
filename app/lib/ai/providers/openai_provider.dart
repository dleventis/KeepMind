import '../ai_provider.dart';
import '../models/ai_extraction_result.dart';

/// Stub — live HTTP integration is Phase E work, not part of this
/// skeleton (brief section 51: one development step at a time). BYOK: the
/// user's own API key, read from SecureKeyStore at call time, never a
/// developer-owned credential. See docs/AI_PROVIDERS.md.
class OpenAIProvider implements AIProvider {
  const OpenAIProvider();

  @override
  String get providerId => 'openai';

  @override
  bool supportsVision() => true;

  @override
  bool supportsStructuredOutput() => true;

  @override
  Future<String> analyzeText(String text) => _notImplemented();

  @override
  Future<String> analyzeImage(List<int> imageBytes) => _notImplemented();

  @override
  Future<AIExtractionResult?> extractStructuredData(String untrustedContent) =>
      _notImplemented();

  @override
  Future<String> answerMemoryQuery(
    String question, {
    required String context,
  }) => _notImplemented();

  @override
  Future<List<double>> generateEmbedding(String text) => _notImplemented();

  Never _notImplemented() {
    throw UnimplementedError(
      'OpenAIProvider is a Phase A stub — live integration is Phase E.',
    );
  }
}
