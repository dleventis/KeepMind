import '../ai_provider.dart';
import '../models/ai_extraction_result.dart';

/// Stub for a future on-device model (brief section 11, "LocalProvider").
/// No network calls, no API key. Left unimplemented rather than
/// fabricating a fake local-model integration — which on-device model and
/// runtime to use is an open question for a later phase, not this one.
class LocalProvider implements AIProvider {
  const LocalProvider();

  @override
  String get providerId => 'local';

  @override
  bool supportsVision() => false;

  @override
  bool supportsStructuredOutput() => false;

  @override
  Future<String> analyzeText(String text) => _notImplemented();

  @override
  Future<String> analyzeImage(List<int> imageBytes) => _notImplemented();

  @override
  Future<AIExtractionResult?> extractStructuredData(String untrustedContent) =>
      _notImplemented();

  @override
  Future<String> answerMemoryQuery(String question, {required String context}) =>
      _notImplemented();

  @override
  Future<List<double>> generateEmbedding(String text) => _notImplemented();

  Never _notImplemented() {
    throw UnimplementedError(
      'LocalProvider is unscoped — no on-device model has been chosen yet.',
    );
  }
}
