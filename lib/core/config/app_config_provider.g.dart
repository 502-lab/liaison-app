// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// bootstrap에서 반드시 override한다. override 없이 읽으면 즉시 실패해서
/// 설정 누락을 빨리 알 수 있다.

@ProviderFor(appConfig)
final appConfigProvider = AppConfigProvider._();

/// bootstrap에서 반드시 override한다. override 없이 읽으면 즉시 실패해서
/// 설정 누락을 빨리 알 수 있다.

final class AppConfigProvider
    extends $FunctionalProvider<AppConfig, AppConfig, AppConfig>
    with $Provider<AppConfig> {
  /// bootstrap에서 반드시 override한다. override 없이 읽으면 즉시 실패해서
  /// 설정 누락을 빨리 알 수 있다.
  AppConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appConfigHash();

  @$internal
  @override
  $ProviderElement<AppConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppConfig create(Ref ref) {
    return appConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppConfig>(value),
    );
  }
}

String _$appConfigHash() => r'c3d931773e2e53803b32e7c054acab04ef4b6969';
