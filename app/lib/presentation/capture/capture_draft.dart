import '../../domain/services/date_candidate_finder.dart';

/// What the capture pipeline has worked out so far, on its way to the
/// confirmation screen. Not persisted — this only exists between
/// "the user captured something" and "the user pressed Save".
///
/// Everything here is a *suggestion*. Nothing in this object is trusted
/// until the user confirms it on the confirmation screen (brief §6, §16).
class CaptureDraft {
  const CaptureDraft({
    this.imagePath,
    this.rawText,
    this.dateCandidates = const [],
  });

  /// Temporary path to the captured image. Only copied into durable
  /// storage (via AttachmentStore) if the user actually saves.
  final String? imagePath;

  /// Verbatim OCR output, or null for a typed-in memory.
  final String? rawText;

  /// Dates found deterministically in [rawText]. May contain two entries
  /// for a single ambiguous date like `03/04/2026` — one per reading.
  final List<DateCandidate> dateCandidates;

  bool get isFromImage => imagePath != null;
}
