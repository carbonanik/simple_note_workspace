// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_note_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(networkNotesRepository)
const networkNotesRepositoryProvider = NetworkNotesRepositoryProvider._();

final class NetworkNotesRepositoryProvider
    extends
        $FunctionalProvider<NotesRepository, NotesRepository, NotesRepository>
    with $Provider<NotesRepository> {
  const NetworkNotesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkNotesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkNotesRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotesRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotesRepository create(Ref ref) {
    return networkNotesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotesRepository>(value),
    );
  }
}

String _$networkNotesRepositoryHash() =>
    r'e111ffa3cc360fbd721b20a9f17bafb0562ddb17';
