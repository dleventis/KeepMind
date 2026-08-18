/// On-device OCR. Kept as a domain interface with no package imports so
/// the capture/processing flow can be tested without ML Kit, a camera, or
/// a real device — see `test/` for the fake used by widget tests.
///
/// Implementation: `data/ocr/mlkit_ocr_service.dart`.
abstract interface class OcrService {
  /// Extracts plain text from the image at [imagePath].
  ///
  /// Returns an empty string when the image contains no readable text —
  /// that is a legitimate result, not an error. Throws `OCRFailure` (see
  /// core/errors/app_errors.dart) only when recognition itself fails.
  Future<String> extractText(String imagePath);

  /// Releases native recognizer resources. Must be called when the
  /// service is disposed — ML Kit holds native memory that is not
  /// reclaimed by Dart GC.
  Future<void> dispose();
}
