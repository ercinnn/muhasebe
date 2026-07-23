// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UploadController)
final uploadControllerProvider = UploadControllerProvider._();

final class UploadControllerProvider
    extends $NotifierProvider<UploadController, List<UploadDraft>> {
  UploadControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'uploadControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$uploadControllerHash();

  @$internal
  @override
  UploadController create() => UploadController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<UploadDraft> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<UploadDraft>>(value),
    );
  }
}

String _$uploadControllerHash() => r'ae2f1f1c36cad6c6608cfc3c6cdef7fcda0ccb13';

abstract class _$UploadController extends $Notifier<List<UploadDraft>> {
  List<UploadDraft> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<UploadDraft>, List<UploadDraft>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<UploadDraft>, List<UploadDraft>>,
              List<UploadDraft>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
