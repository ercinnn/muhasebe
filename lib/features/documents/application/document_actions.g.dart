// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Combines the DB write with its client-side side effect (cancelling the
/// mobile local reminder — a no-op on web) so both call sites stay in sync.
///
/// keepAlive: this provider is only ever `ref.read(...).notifier`'d from a
/// button's onPressed, never `ref.watch`'d — an autodispose instance can get
/// disposed mid-`markPaid()` (multiple awaits in a row), throwing "Cannot
/// use the Ref after it has been disposed" and silently dropping whatever
/// ran after the point of disposal (see `fcmServiceProvider` for the same
/// pattern).

@ProviderFor(DocumentActions)
final documentActionsProvider = DocumentActionsProvider._();

/// Combines the DB write with its client-side side effect (cancelling the
/// mobile local reminder — a no-op on web) so both call sites stay in sync.
///
/// keepAlive: this provider is only ever `ref.read(...).notifier`'d from a
/// button's onPressed, never `ref.watch`'d — an autodispose instance can get
/// disposed mid-`markPaid()` (multiple awaits in a row), throwing "Cannot
/// use the Ref after it has been disposed" and silently dropping whatever
/// ran after the point of disposal (see `fcmServiceProvider` for the same
/// pattern).
final class DocumentActionsProvider
    extends $NotifierProvider<DocumentActions, void> {
  /// Combines the DB write with its client-side side effect (cancelling the
  /// mobile local reminder — a no-op on web) so both call sites stay in sync.
  ///
  /// keepAlive: this provider is only ever `ref.read(...).notifier`'d from a
  /// button's onPressed, never `ref.watch`'d — an autodispose instance can get
  /// disposed mid-`markPaid()` (multiple awaits in a row), throwing "Cannot
  /// use the Ref after it has been disposed" and silently dropping whatever
  /// ran after the point of disposal (see `fcmServiceProvider` for the same
  /// pattern).
  DocumentActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentActionsProvider',
        isAutoDispose: false,
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

String _$documentActionsHash() => r'91b13aadb8b3d8f4a02788eef93aed03eea6d101';

/// Combines the DB write with its client-side side effect (cancelling the
/// mobile local reminder — a no-op on web) so both call sites stay in sync.
///
/// keepAlive: this provider is only ever `ref.read(...).notifier`'d from a
/// button's onPressed, never `ref.watch`'d — an autodispose instance can get
/// disposed mid-`markPaid()` (multiple awaits in a row), throwing "Cannot
/// use the Ref after it has been disposed" and silently dropping whatever
/// ran after the point of disposal (see `fcmServiceProvider` for the same
/// pattern).

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
