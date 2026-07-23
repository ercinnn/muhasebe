import 'dart:typed_data';

export 'ocr_service_stub.dart' if (dart.library.io) 'ocr_service_io.dart';

/// Mobile-only OCR fallback for scanned PDFs with no text layer
/// (`google_mlkit_text_recognition` has no web implementation). The web
/// build resolves to [OcrServiceImpl] in ocr_service_stub.dart, a no-op;
/// native platforms resolve to ocr_service_io.dart's mlkit-backed one.
abstract class OcrService {
  /// Renders each page and runs on-device OCR over it. Returns null where
  /// OCR isn't available (web) or no text was recognized.
  Future<String?> recognizeText(Uint8List pdfBytes);
}
