// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'documents_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(documentsRepository)
final documentsRepositoryProvider = DocumentsRepositoryProvider._();

final class DocumentsRepositoryProvider
    extends
        $FunctionalProvider<
          DocumentsRepository,
          DocumentsRepository,
          DocumentsRepository
        >
    with $Provider<DocumentsRepository> {
  DocumentsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentsRepositoryHash();

  @$internal
  @override
  $ProviderElement<DocumentsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DocumentsRepository create(Ref ref) {
    return documentsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocumentsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocumentsRepository>(value),
    );
  }
}

String _$documentsRepositoryHash() =>
    r'd0d8f2f3e2740ea4145e6cdb3e139a92d2393044';

@ProviderFor(clientDocuments)
final clientDocumentsProvider = ClientDocumentsProvider._();

final class ClientDocumentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DocumentRecord>>,
          List<DocumentRecord>,
          Stream<List<DocumentRecord>>
        >
    with
        $FutureModifier<List<DocumentRecord>>,
        $StreamProvider<List<DocumentRecord>> {
  ClientDocumentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientDocumentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientDocumentsHash();

  @$internal
  @override
  $StreamProviderElement<List<DocumentRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DocumentRecord>> create(Ref ref) {
    return clientDocuments(ref);
  }
}

String _$clientDocumentsHash() => r'262e5228ebd4898c0df7b935b69f4a8f9940b469';

@ProviderFor(accountantDocuments)
final accountantDocumentsProvider = AccountantDocumentsProvider._();

final class AccountantDocumentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DocumentRecord>>,
          List<DocumentRecord>,
          Stream<List<DocumentRecord>>
        >
    with
        $FutureModifier<List<DocumentRecord>>,
        $StreamProvider<List<DocumentRecord>> {
  AccountantDocumentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountantDocumentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountantDocumentsHash();

  @$internal
  @override
  $StreamProviderElement<List<DocumentRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DocumentRecord>> create(Ref ref) {
    return accountantDocuments(ref);
  }
}

String _$accountantDocumentsHash() =>
    r'8991b083f453ad7e8b91f0030ee48b0b917b4f6c';

@ProviderFor(documentById)
final documentByIdProvider = DocumentByIdFamily._();

final class DocumentByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<DocumentRecord?>,
          DocumentRecord?,
          FutureOr<DocumentRecord?>
        >
    with $FutureModifier<DocumentRecord?>, $FutureProvider<DocumentRecord?> {
  DocumentByIdProvider._({
    required DocumentByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'documentByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$documentByIdHash();

  @override
  String toString() {
    return r'documentByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DocumentRecord?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DocumentRecord?> create(Ref ref) {
    final argument = this.argument as String;
    return documentById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$documentByIdHash() => r'77925127465350c6c9529bd2b080e24f99203b1a';

final class DocumentByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DocumentRecord?>, String> {
  DocumentByIdFamily._()
    : super(
        retry: null,
        name: r'documentByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DocumentByIdProvider call(String id) =>
      DocumentByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'documentByIdProvider';
}
