import 'package:keepmind/domain/services/ocr_service.dart';

/// Test double for OCR. Widget tests must never reach ML Kit — it needs
/// platform channels and a real image — so every test that renders the
/// capture flow overrides `ocrServiceProvider` with one of these
/// (brief §35: normal tests require no live integrations).
class FakeOcrService implements OcrService {
  FakeOcrService({this.textToReturn = '', this.error});

  final String textToReturn;

  /// When set, [extractText] throws this instead of returning — used to
  /// exercise the OCR-failure path.
  final Object? error;

  int extractCallCount = 0;
  bool disposed = false;

  @override
  Future<String> extractText(String imagePath) async {
    extractCallCount++;
    final e = error;
    if (e != null) throw e;
    return textToReturn;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}
