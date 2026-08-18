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
    this.sourceUri,
    this.rawText,
  });

  final String id;
  final String title;
  final String? description;
  final String category;

  /// 'photo', 'pdf', or 'text'.
  final String sourceType;

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

  /// Absolute path to the captured image on this device, if any. Local
  /// filesystem path rather than a URL — nothing is uploaded anywhere
  /// (see docs/PRIVACY.md). Managed by `data/files/attachment_store.dart`.
  final String? sourceUri;

  /// Raw OCR output, kept verbatim and untouched.
  ///
  /// Two reasons this is stored rather than discarded after extraction:
  /// re-running a better extraction later (Phase E/F AI, or an improved
  /// parser) without asking the user to re-photograph the document, and
  /// full-text search (Phase H). It is *untrusted input* — see
  /// docs/SECURITY.md on prompt injection; anything read out of a document
  /// is data, never an instruction.
  final String? rawText;

  /// Returns a copy with the given fields replaced. For the nullable
  /// fields ([description], [eventDate], [confidenceScore]), pass the
  /// sentinel-aware setters below when you need to explicitly clear a
  /// value rather than leave it unchanged — plain `copyWith(eventDate:
  /// null)` is indistinguishable from "don't change this," which is the
  /// classic Dart copyWith footgun, so clearing goes through
  /// [clearEventDate]/[clearDescription]/[clearConfidenceScore] instead.
  MemoryObject copyWith({
    String? title,
    String? description,
    String? category,
    String? sourceType,
    DateTime? updatedAt,
    DateTime? eventDate,
    double? confidenceScore,
    ConfirmationStatus? confirmationStatus,
    Sensitivity? sensitivity,
    Map<String, Object?>? structuredData,
    bool? archived,
    String? sourceUri,
    String? rawText,
    bool clearDescription = false,
    bool clearEventDate = false,
    bool clearConfidenceScore = false,
  }) {
    return MemoryObject(
      id: id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      category: category ?? this.category,
      sourceType: sourceType ?? this.sourceType,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      eventDate: clearEventDate ? null : (eventDate ?? this.eventDate),
      confidenceScore: clearConfidenceScore
          ? null
          : (confidenceScore ?? this.confidenceScore),
      confirmationStatus: confirmationStatus ?? this.confirmationStatus,
      sensitivity: sensitivity ?? this.sensitivity,
      structuredData: structuredData ?? this.structuredData,
      archived: archived ?? this.archived,
      sourceUri: sourceUri ?? this.sourceUri,
      rawText: rawText ?? this.rawText,
    );
  }
}
