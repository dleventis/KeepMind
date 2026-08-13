import 'models/ai_extraction_result.dart';

/// Provider-independent AI abstraction (brief section 11). No screen or
/// repository ever imports a concrete implementation of this — only
/// `AIRouter` does. Implementations: `providers/openai_provider.dart`,
/// `providers/anthropic_provider.dart`, `providers/local_provider.dart`
/// (all stubs in this Phase A skeleton; live HTTP calls are Phase E).
abstract interface class AIProvider {
  String get providerId;

  bool supportsVision();
  bool supportsStructuredOutput();

  Future<String> analyzeText(String text);

  Future<String> analyzeImage(List<int> imageBytes);

  /// [untrustedContent] is OCR output or user-provided text — always
  /// passed to the underlying model as clearly-delimited, labeled
  /// untrusted data, never concatenated into system/instruction text.
  /// See docs/SECURITY.md, "Prompt injection defense".
  Future<AIExtractionResult?> extractStructuredData(String untrustedContent);

  Future<String> answerMemoryQuery(String question, {required String context});

  Future<List<double>> generateEmbedding(String text);
}
