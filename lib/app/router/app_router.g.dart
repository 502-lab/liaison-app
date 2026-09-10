// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 앱 라우터. 로그인·역할별 진입 분기는 인증 feature가 생기면
/// `redirect:` 파라미터에서 처리한다.
/// 로그인/역할 redirect는 `ref.watch`가 아니라 `refreshListenable` 또는
/// `ref.listen`으로 연결한다. ref.watch하면 상태가 바뀔 때마다 GoRouter가
/// 재생성되어 네비게이션 스택이 초기화된다.

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// 앱 라우터. 로그인·역할별 진입 분기는 인증 feature가 생기면
/// `redirect:` 파라미터에서 처리한다.
/// 로그인/역할 redirect는 `ref.watch`가 아니라 `refreshListenable` 또는
/// `ref.listen`으로 연결한다. ref.watch하면 상태가 바뀔 때마다 GoRouter가
/// 재생성되어 네비게이션 스택이 초기화된다.

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// 앱 라우터. 로그인·역할별 진입 분기는 인증 feature가 생기면
  /// `redirect:` 파라미터에서 처리한다.
  /// 로그인/역할 redirect는 `ref.watch`가 아니라 `refreshListenable` 또는
  /// `ref.listen`으로 연결한다. ref.watch하면 상태가 바뀔 때마다 GoRouter가
  /// 재생성되어 네비게이션 스택이 초기화된다.
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerHash() => r'49026b0ea7ef6704e199485f2be1bc0e0ecccf1e';
