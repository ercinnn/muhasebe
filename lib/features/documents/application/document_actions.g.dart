// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Combines the DB write with its client-side side effect (cancelling the
/// mobile local reminder — a no-op on web) so both call sites stay in sync.

@ProviderFor(DocumentActions)
final documentActionsProvider = DocumentActionsProvider._();

/// Combines the DB write with its client-side side effect (cancelling the
/// mobile local reminder — a no-op on web) so both call sites stay in sync.
final class DocumentActionsProvider
    extends $NotifierProvider<DocumentActions, void> {
  /// Combines the DB write with its client-side side effect (cancelling the
  /// mobile local reminder — a no-op on web) so both call sites stay in sync.
  DocumentActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentActionsHash();

  @$internal
  @override
  DocumentActions create() => DocumentActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$documentActionsHash() => r'423a26462eb5c4b44bc1ebed1443f1e6d6240aaf';

/// Combines the DB write with its client-side side effect (cancelling the
/// mobile local reminder — a no-op on web) so both call sites stay in sync.

abstract class _$DocumentActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
