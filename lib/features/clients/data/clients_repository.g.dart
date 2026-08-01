// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clients_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clientsRepository)
final clientsRepositoryProvider = ClientsRepositoryProvider._();

final class ClientsRepositoryProvider
    extends
        $FunctionalProvider<
          ClientsRepository,
          ClientsRepository,
          ClientsRepository
        >
    with $Provider<ClientsRepository> {
  ClientsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ClientsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClientsRepository create(Ref ref) {
    return clientsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientsRepository>(value),
    );
  }
}

String _$clientsRepositoryHash() => r'a9b301658e918d061e4a0dfe2b59ab949cd7aace';

@ProviderFor(myClients)
final myClientsProvider = MyClientsProvider._();

final class MyClientsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Client>>,
          List<Client>,
          FutureOr<List<Client>>
        >
    with $FutureModifier<List<Client>>, $FutureProvider<List<Client>> {
  MyClientsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myClientsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myClientsHash();

  @$internal
  @override
  $FutureProviderElement<List<Client>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Client>> create(Ref ref) {
    return myClients(ref);
  }
}

String _$myClientsHash() => r'a4c93c96358bdfa26fa5575a0ad5bbd8151de029';

@ProviderFor(myInvites)
final myInvitesProvider = MyInvitesProvider._();

final class MyInvitesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Invite>>,
          List<Invite>,
          FutureOr<List<Invite>>
        >
    with $FutureModifier<List<Invite>>, $FutureProvider<List<Invite>> {
  MyInvitesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myInvitesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myInvitesHash();

  @$internal
  @override
  $FutureProviderElement<List<Invite>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Invite>> create(Ref ref) {
    return myInvites(ref);
  }
}

String _$myInvitesHash() => r'82be6b667b39efc02f346d7dbc77c2d11af9082d';

@ProviderFor(clientContactInfo)
final clientContactInfoProvider = ClientContactInfoFamily._();

final class ClientContactInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<ClientContactInfo?>,
          ClientContactInfo?,
          FutureOr<ClientContactInfo?>
        >
    with
        $FutureModifier<ClientContactInfo?>,
        $FutureProvider<ClientContactInfo?> {
  ClientContactInfoProvider._({
    required ClientContactInfoFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clientContactInfoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clientContactInfoHash();

  @override
  String toString() {
    return r'clientContactInfoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ClientContactInfo?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ClientContactInfo?> create(Ref ref) {
    final argument = this.argument as String;
    return clientContactInfo(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientContactInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clientContactInfoHash() => r'129746a5bbad6f1ab20fd8645bfaea406e2cde68';

final class ClientContactInfoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ClientContactInfo?>, String> {
  ClientContactInfoFamily._()
    : super(
        retry: null,
        name: r'clientContactInfoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClientContactInfoProvider call(String clientId) =>
      ClientContactInfoProvider._(argument: clientId, from: this);

  @override
  String toString() => r'clientContactInfoProvider';
}
