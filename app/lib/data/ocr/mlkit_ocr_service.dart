import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../core/errors/app_errors.dart';
import '../../domain/services/ocr_service.dart';

/// On-device OCR via ML Kit Text Recognition v2.
///
/// Fully on-device on both platforms: the model ships with the plugin, so
/// no image ever leaves the phone during the OCR stage. That matters —
/// the privacy hierarchy in docs/PRIVACY.md puts external AI last, and
/// running OCR locally means a user with no AI provider configured still
/// gets their document read.
///
/// Latin script only for now. ML Kit ships separate models for Chinese,
/// Devanagari, Japanese, and Korean; adding them is a per-script
/// [TextRecognizer] plus the matching native pod/gradle dependency, and
/// is tracked with the rest of the i18n work (brief §37).
class MlKitOcrService implements OcrService {
  MlKitOcrService();

  TextRecognizer? _recognizer;

  TextRecognizer get _instance =>
      _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<String> extractText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognized = await _instance.processImage(inputImage);
      // An empty string is a valid result — a photo of a blank wall has no
      // text in it. Callers distinguish "no text found" from "OCR broke".
      return recognized.text;
    } catch (e) {
      throw OCRFailure(
        debugMessage: 'ML Kit text recognition failed for $imagePath: $e',
      );
    }
  }

  @override
  Future<void> dispose() async {
    await _recognizer?.close();
    _recognizer = null;
  }
}
