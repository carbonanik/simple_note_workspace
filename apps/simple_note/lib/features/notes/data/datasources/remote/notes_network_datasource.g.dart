// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_network_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notesNetworkDataSource)
const notesNetworkDataSourceProvider = NotesNetworkDataSourceProvider._();

final class NotesNetworkDataSourceProvider
    extends
        $FunctionalProvider<
          NotesNetworkDataSource,
          NotesNetworkDataSource,
          NotesNetworkDataSource
        >
    with $Provider<NotesNetworkDataSource> {
  const NotesNetworkDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notesNetworkDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notesNetworkDataSourceHash();

  @$internal
  @override
  $ProviderElement<NotesNetworkDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotesNetworkDataSource create(Ref ref) {
    return notesNetworkDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotesNetworkDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotesNetworkDataSource>(value),
    );
  }
}

String _$notesNetworkDataSourceHash() =>
    r'42130975be7decb80d777a3e0eb509dc77a9bb70';
