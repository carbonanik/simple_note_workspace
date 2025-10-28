// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_local_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notesLocalDataSource)
const notesLocalDataSourceProvider = NotesLocalDataSourceProvider._();

final class NotesLocalDataSourceProvider
    extends
        $FunctionalProvider<
          NotesLocalDataSource,
          NotesLocalDataSource,
          NotesLocalDataSource
        >
    with $Provider<NotesLocalDataSource> {
  const NotesLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notesLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notesLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<NotesLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotesLocalDataSource create(Ref ref) {
    return notesLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotesLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotesLocalDataSource>(value),
    );
  }
}

String _$notesLocalDataSourceHash() =>
    r'17c7c6f73123591c25c603c58780af752f614cda';
