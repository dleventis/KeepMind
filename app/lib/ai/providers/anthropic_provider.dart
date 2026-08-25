import '../ai_provider.dart';
import '../models/ai_extraction_result.dart';

/// Stub — see openai_provider.dart for the shared reasoning. BYOK only;
/// do not assume a Claude Pro subscription grants API access (brief
/// section 12) — only implement auth Anthropic documents as officially
/// supported for this use case.
class AnthropicProvider implements AIProvider {
  const AnthropicProvider();

  @override
  String get providerId => 'anthropic';

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
      'AnthropicProvider is a Phase A stub — live integration is Phase E.',
    );
  }
}
