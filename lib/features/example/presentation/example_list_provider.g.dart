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
/// Riverpod 3의 기본 retry 정책(최대 10회, 지수 백오프로 최대 6.4초 간격)은
/// 실패를 즉시 AsyncError로 드러내려는 위 의도와 충돌해 예외가 AsyncLoading
/// 상태로 한참 머물게 만든다. 재시도는 화면의 '다시 시도' 버튼(refresh)이
/// 담당하므로 자동 재시도는 끈다.

@ProviderFor(ExampleList)
final exampleListProvider = ExampleListProvider._();

/// 서버 데이터를 다루는 상태는 AsyncNotifier로 만든다.
/// 예외는 삼키지 않고 AsyncError로 흘려보낸다. 화면이 표시를 결정한다.
///
/// Riverpod 3의 기본 retry 정책(최대 10회, 지수 백오프로 최대 6.4초 간격)은
/// 실패를 즉시 AsyncError로 드러내려는 위 의도와 충돌해 예외가 AsyncLoading
/// 상태로 한참 머물게 만든다. 재시도는 화면의 '다시 시도' 버튼(refresh)이
/// 담당하므로 자동 재시도는 끈다.
final class ExampleListProvider
    extends $AsyncNotifierProvider<ExampleList, List<ExampleItem>> {
  /// 서버 데이터를 다루는 상태는 AsyncNotifier로 만든다.
  /// 예외는 삼키지 않고 AsyncError로 흘려보낸다. 화면이 표시를 결정한다.
  ///
  /// Riverpod 3의 기본 retry 정책(최대 10회, 지수 백오프로 최대 6.4초 간격)은
  /// 실패를 즉시 AsyncError로 드러내려는 위 의도와 충돌해 예외가 AsyncLoading
  /// 상태로 한참 머물게 만든다. 재시도는 화면의 '다시 시도' 버튼(refresh)이
  /// 담당하므로 자동 재시도는 끈다.
  ExampleListProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
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

String _$exampleListHash() => r'67b29b717325b6c16dfcc60d933b7be1823029b2';

/// 서버 데이터를 다루는 상태는 AsyncNotifier로 만든다.
/// 예외는 삼키지 않고 AsyncError로 흘려보낸다. 화면이 표시를 결정한다.
///
/// Riverpod 3의 기본 retry 정책(최대 10회, 지수 백오프로 최대 6.4초 간격)은
/// 실패를 즉시 AsyncError로 드러내려는 위 의도와 충돌해 예외가 AsyncLoading
/// 상태로 한참 머물게 만든다. 재시도는 화면의 '다시 시도' 버튼(refresh)이
/// 담당하므로 자동 재시도는 끈다.

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
