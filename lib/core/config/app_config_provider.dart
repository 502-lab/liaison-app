import 'package:liaison_app/core/config/app_config.dart';
import 'package:liaison_app/core/riverpod/retry_policy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config_provider.g.dart';

/// bootstrap에서 반드시 override한다. override 없이 읽으면 즉시 실패해서
/// 설정 누락을 빨리 알 수 있다 (재시도 없이 바로 실패하도록 noRetry).
/// keepAlive인 인프라 Provider(dio 등)가 watch하므로 keepAlive여야 한다.
@Riverpod(keepAlive: true, retry: noRetry)
AppConfig appConfig(Ref ref) {
  throw UnimplementedError('appConfigProvider는 bootstrap에서 override되어야 합니다');
}
