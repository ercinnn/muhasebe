import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/document_enums.dart';
import '../../features/classification/document_classifier.dart';
import '../../features/classification/models/extracted_document.dart';
import 'ocr_service.dart';
import 'pdf_text_extractor.dart';

part 'pdf_processing_service.g.dart';

class PdfProcessingResult {
  const PdfProcessingResult({required this.rawText, required this.document, required this.usedOcr});

  final String rawText;
  final ExtractedDocument document;
  final bool usedOcr;
}

/// Orchestrates: extract text -> (mobile only) OCR fallback if no text
/// layer -> classify. Web PDFs with no text layer stay unclassified with
/// needsManualEntry, per spec (no OCR available there).
class PdfProcessingService {
  PdfProcessingService(this._classifier, this._ocrService);

  final DocumentClassifier _classifier;
  final OcrService _ocrService;

  Future<PdfProcessingResult> process(Uint8List bytes, {String? sourceName}) async {
    var rawText = await extractTextFromPdfBytes(bytes, sourceName: sourceName);
    var usedOcr = false;

    if (!hasUsableTextLayer(rawText) && !kIsWeb) {
      final ocrText = await _ocrService.recognizeText(bytes);
      if (ocrText != null && hasUsableTextLayer(ocrText)) {
        rawText = ocrText;
        usedOcr = true;
      }
    }

    final document = hasUsableTextLayer(rawText)
        ? _classifier.classify(rawText)
        : const ExtractedDocument(
            category: DocumentCategory.unclassified,
            docType: DocType.other,
            needsManualEntry: true,
            needsReminder: false,
          );

    return PdfProcessingResult(rawText: rawText, document: document, usedOcr: usedOcr);
  }
}

@riverpod
PdfProcessingService pdfProcessingService(Ref ref) =>
    PdfProcessingService(DocumentClassifier(), OcrServiceImpl());
