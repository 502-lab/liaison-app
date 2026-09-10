import 'package:liaison_app/core/config/app_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config_provider.g.dart';

/// bootstrap에서 반드시 override한다. override 없이 읽으면 즉시 실패해서
/// 설정 누락을 빨리 알 수 있다.
@riverpod
AppConfig appConfig(Ref ref) {
  throw UnimplementedError('appConfigProvider는 bootstrap에서 override되어야 합니다');
}
