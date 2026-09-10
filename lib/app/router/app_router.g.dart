// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 앱 라우터. 로그인·역할별 진입 분기는 인증 feature가 생기면
/// `redirect:` 파라미터에서 처리한다.

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// 앱 라우터. 로그인·역할별 진입 분기는 인증 feature가 생기면
/// `redirect:` 파라미터에서 처리한다.

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// 앱 라우터. 로그인·역할별 진입 분기는 인증 feature가 생기면
  /// `redirect:` 파라미터에서 처리한다.
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: true,
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

String _$routerHash() => r'afc376d9a3a74d0dd72e9b70c60edc34e1167143';
