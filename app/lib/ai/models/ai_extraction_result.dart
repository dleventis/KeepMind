/// Structured, validated AI output — the brief is explicit (section 15)
/// that arbitrary free-text AI responses must never be trusted directly
/// for application logic. Every [AIProvider.extractStructuredData] call
/// must return one of these, constructed only after validating the raw
/// provider response against this shape; malformed responses should raise
/// `InvalidAIResponse` (see core/errors/app_errors.dart) rather than
/// producing a partially-filled result.
class AIExtractionResult {
  const AIExtractionResult({
    required this.documentType,
    required this.title,
    this.dates = const [],
    this.entities = const [],
    this.amounts = const [],
    this.suggestedAction,
    this.suggestedReminders = const [],
    this.confidence = const {},
  });

  final String documentType;
  final String title;
  final List<ExtractedDate> dates;
  final List<String> entities;
  final List<ExtractedAmount> amounts;
  final String? suggestedAction;
  final List<Duration> suggestedReminders; // offsets before the event date
  final Map<String, double> confidence; // field name -> 0.0..1.0

  /// Deserializes and validates a raw JSON map from a provider response.
  /// Returns null (never throws, never guesses) if the shape doesn't
  /// match — callers should treat null as "ask the user instead of
  /// trusting this" per brief section 16.
  static AIExtractionResult? tryParse(Map<String, Object?> json) {
    final documentType = json['document_type'];
    final title = json['title'];
    if (documentType is! String || title is! String) return null;

    return AIExtractionResult(
      documentType: documentType,
      title: title,
      suggestedAction: json['suggested_action'] as String?,
      // dates/entities/amounts/confidence parsing intentionally left as a
      // Phase F task once a real provider response shape exists to test
      // against — a fabricated parser here would be exactly the kind of
      // invented-without-verification code the brief warns against.
    );
  }
}

class ExtractedDate {
  const ExtractedDate({
    required this.label,
    required this.value,
    required this.confidence,
  });

  final String label; // e.g. "expiration", "renewal", "appointment"
  final DateTime value;
  final double confidence;
}

class ExtractedAmount {
  const ExtractedAmount({
    required this.value,
    required this.currency,
  });

  final double value;
  final String currency; // ISO 4217, e.g. "EUR"
}
