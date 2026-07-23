// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_processing_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pdfProcessingService)
final pdfProcessingServiceProvider = PdfProcessingServiceProvider._();

final class PdfProcessingServiceProvider
    extends
        $FunctionalProvider<
          PdfProcessingService,
          PdfProcessingService,
          PdfProcessingService
        >
    with $Provider<PdfProcessingService> {
  PdfProcessingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pdfProcessingServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pdfProcessingServiceHash();

  @$internal
  @override
  $ProviderElement<PdfProcessingService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PdfProcessingService create(Ref ref) {
    return pdfProcessingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PdfProcessingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PdfProcessingService>(value),
    );
  }
}

String _$pdfProcessingServiceHash() =>
    r'4bff83dd4139bf48cc4f2eb8fce98d7a61fdec5e';
