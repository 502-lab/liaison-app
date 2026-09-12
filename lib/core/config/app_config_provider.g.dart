// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// bootstrap에서 반드시 override한다. override 없이 읽으면 즉시 실패해서
/// 설정 누락을 빨리 알 수 있다 (재시도 없이 바로 실패하도록 noRetry).
/// keepAlive인 인프라 Provider(dio 등)가 watch하므로 keepAlive여야 한다.

@ProviderFor(appConfig)
final appConfigProvider = AppConfigProvider._();

/// bootstrap에서 반드시 override한다. override 없이 읽으면 즉시 실패해서
/// 설정 누락을 빨리 알 수 있다 (재시도 없이 바로 실패하도록 noRetry).
/// keepAlive인 인프라 Provider(dio 등)가 watch하므로 keepAlive여야 한다.

final class AppConfigProvider
    extends $FunctionalProvider<AppConfig, AppConfig, AppConfig>
    with $Provider<AppConfig> {
  /// bootstrap에서 반드시 override한다. override 없이 읽으면 즉시 실패해서
  /// 설정 누락을 빨리 알 수 있다 (재시도 없이 바로 실패하도록 noRetry).
  /// keepAlive인 인프라 Provider(dio 등)가 watch하므로 keepAlive여야 한다.
  AppConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: noRetry,
        name: r'appConfigProvider',
        isAutoDispose: false,
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

String _$appConfigHash() => r'1680e155f8d16f004bd249fef8a5418ed91fd8a1';
