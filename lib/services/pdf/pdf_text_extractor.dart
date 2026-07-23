import 'dart:typed_data';

import 'package:pdfrx/pdfrx.dart';

/// Minimum extracted character count below which a PDF is treated as
/// having no usable text layer (scanned/image-only document).
const minTextLayerLength = 20;

/// Extracts and concatenates the text of every page in a PDF.
///
/// pdfrx dispatches the actual PDFium work to its own internal worker
/// isolate/thread pool, so this is intentionally not wrapped in an
/// additional `compute()` call — that would spawn a second isolate without
/// the Flutter bindings pdfrx's Flutter-side initialization relies on.
Future<String> extractTextFromPdfBytes(Uint8List bytes, {String? sourceName}) async {
  final document = await PdfDocument.openData(bytes, sourceName: sourceName);
  try {
    final buffer = StringBuffer();
    for (final page in document.pages) {
      final pageText = await page.loadText();
      if (pageText != null && pageText.fullText.isNotEmpty) {
        buffer.writeln(pageText.fullText);
      }
    }
    return buffer.toString();
  } finally {
    await document.dispose();
  }
}

bool hasUsableTextLayer(String extractedText) => extractedText.trim().length >= minTextLayerLength;
