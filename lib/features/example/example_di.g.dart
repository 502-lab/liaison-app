// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 이 feature의 의존성 조립. data와 domain을 동시에 import할 수 있는 유일한 파일.

@ProviderFor(exampleRepository)
final exampleRepositoryProvider = ExampleRepositoryProvider._();

/// 이 feature의 의존성 조립. data와 domain을 동시에 import할 수 있는 유일한 파일.

final class ExampleRepositoryProvider
    extends
        $FunctionalProvider<
          ExampleRepository,
          ExampleRepository,
          ExampleRepository
        >
    with $Provider<ExampleRepository> {
  /// 이 feature의 의존성 조립. data와 domain을 동시에 import할 수 있는 유일한 파일.
  ExampleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exampleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exampleRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExampleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExampleRepository create(Ref ref) {
    return exampleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExampleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExampleRepository>(value),
    );
  }
}

String _$exampleRepositoryHash() => r'f73f2ff88c10f693f480649fb864dd4ad53bbb84';
