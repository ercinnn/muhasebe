// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_summary.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(inboxSummary)
final inboxSummaryProvider = InboxSummaryProvider._();

final class InboxSummaryProvider
    extends $FunctionalProvider<InboxSummary, InboxSummary, InboxSummary>
    with $Provider<InboxSummary> {
  InboxSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxSummaryHash();

  @$internal
  @override
  $ProviderElement<InboxSummary> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InboxSummary create(Ref ref) {
    return inboxSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InboxSummary value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InboxSummary>(value),
    );
  }
}

String _$inboxSummaryHash() => r'cb18a79a67e577ce516f593e29050bf872c1d072';
