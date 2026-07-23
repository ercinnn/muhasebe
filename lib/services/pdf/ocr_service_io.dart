import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdfrx/pdfrx.dart';

import 'ocr_service.dart';

/// Mobile/desktop: renders each PDF page to a bitmap and runs Google
/// ML Kit's on-device text recognizer over it.
class OcrServiceImpl implements OcrService {
  @override
  Future<String?> recognizeText(Uint8List pdfBytes) async {
    final document = await PdfDocument.openData(pdfBytes, sourceName: 'ocr-input.pdf');
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final buffer = StringBuffer();
      for (final page in document.pages) {
        final image = await page.render();
        if (image == null) continue;
        try {
          final inputImage = InputImage.fromBitmap(
            bitmap: image.pixels,
            width: image.width,
            height: image.height,
          );
          final recognized = await recognizer.processImage(inputImage);
          if (recognized.text.isNotEmpty) buffer.writeln(recognized.text);
        } finally {
          image.dispose();
        }
      }
      final result = buffer.toString();
      return result.isEmpty ? null : result;
    } finally {
      await recognizer.close();
      await document.dispose();
    }
  }
}
