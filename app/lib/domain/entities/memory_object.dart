/// Confirmation state — the brief is explicit (section 6) that only
/// confirmed information should be trusted for critical reminders.
enum ConfirmationStatus { pending, confirmed, rejected }

enum Sensitivity { normal, personal, financial, medical, identity }

/// The core domain entity. Deliberately not a 1:1 copy of the brief's
/// proposed schema (section 9 asks for it to be critiqued, not implemented
/// blindly): heterogeneous, category-specific fields (policy numbers,
/// vehicle info, amounts, currencies, ...) live in [structuredData] as a
/// JSON map rather than as dozens of mostly-null columns. Fields promoted
/// to first-class properties here are the ones every memory type shares
/// and that the app needs to filter/sort on directly — see
/// docs/DATABASE.md for the reasoning.
///
/// This is a plain Dart class with no Flutter or package imports, so it
/// can be unit tested and used by domain logic without a widget tree or a
/// database connection.
class MemoryObject {
  const MemoryObject({
    required this.id,
    required this.title,
    required this.category,
    required this.sourceType,
    required this.createdAt,
    required this.updatedAt,
    required this.confirmationStatus,
    this.description,
    this.eventDate,
    this.confidenceScore,
    this.sensitivity = Sensitivity.normal,
    this.structuredData = const {},
    this.archived = false,
  });

  final String id;
  final String title;
  final String? description;
  final String category;
  final String sourceType; // e.g. 'photo', 'pdf', 'text'
  final DateTime createdAt;
  final DateTime updatedAt;

  /// The single most important date for this memory (expiration, renewal,
  /// appointment, etc.). Null means "no date was confidently identified" —
  /// never defaulted or guessed (brief section 15/16).
  final DateTime? eventDate;

  /// 0.0–1.0, or null if not yet assessed. Drives the confidence-aware UX
  /// described in brief section 16.
  final double? confidenceScore;

  final ConfirmationStatus confirmationStatus;
  final Sensitivity sensitivity;

  /// Category-specific extracted fields (provider, policy number, vehicle,
  /// amount, currency, location, reference number, tags, ...).
  final Map<String, Object?> structuredData;

  final bool archived;
}
