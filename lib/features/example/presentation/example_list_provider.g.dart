// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 서버 데이터를 다루는 상태는 AsyncNotifier로 만든다.
/// 예외는 삼키지 않고 AsyncError로 흘려보낸다. 화면이 표시를 결정한다.
///
/// 자동 재시도를 끄는 이유는 `core/riverpod/retry_policy.dart`를 참고한다.

@ProviderFor(ExampleList)
final exampleListProvider = ExampleListProvider._();

/// 서버 데이터를 다루는 상태는 AsyncNotifier로 만든다.
/// 예외는 삼키지 않고 AsyncError로 흘려보낸다. 화면이 표시를 결정한다.
///
/// 자동 재시도를 끄는 이유는 `core/riverpod/retry_policy.dart`를 참고한다.
final class ExampleListProvider
    extends $AsyncNotifierProvider<ExampleList, List<ExampleItem>> {
  /// 서버 데이터를 다루는 상태는 AsyncNotifier로 만든다.
  /// 예외는 삼키지 않고 AsyncError로 흘려보낸다. 화면이 표시를 결정한다.
  ///
  /// 자동 재시도를 끄는 이유는 `core/riverpod/retry_policy.dart`를 참고한다.
  ExampleListProvider._()
    : super(
        from: null,
        argument: null,
        retry: noRetry,
        name: r'exampleListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exampleListHash();

  @$internal
  @override
  ExampleList create() => ExampleList();
}

String _$exampleListHash() => r'254fd9758da6814fc005f389761e81874de4dfa2';

/// 서버 데이터를 다루는 상태는 AsyncNotifier로 만든다.
/// 예외는 삼키지 않고 AsyncError로 흘려보낸다. 화면이 표시를 결정한다.
///
/// 자동 재시도를 끄는 이유는 `core/riverpod/retry_policy.dart`를 참고한다.

abstract class _$ExampleList extends $AsyncNotifier<List<ExampleItem>> {
  FutureOr<List<ExampleItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ExampleItem>>, List<ExampleItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ExampleItem>>, List<ExampleItem>>,
              AsyncValue<List<ExampleItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
