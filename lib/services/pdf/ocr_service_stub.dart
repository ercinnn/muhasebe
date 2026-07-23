import 'dart:typed_data';

import 'ocr_service.dart';

/// Web build: no on-device OCR available. The upload flow falls back to
/// "Sınıflandırılamadı" + manual entry, per spec.
class OcrServiceImpl implements OcrService {
  @override
  Future<String?> recognizeText(Uint8List pdfBytes) async => null;
}
