import 'package:liaison_app/core/config/flavor.dart';

/// 실행 시점에 결정되는 앱 설정.
///
/// 값은 `--dart-define-from-file=env/<flavor>.json`으로 주입된다.
class AppConfig {
  const new({
    required this.flavor,
    required this.apiBaseUrl,
    required this.useFakeRepositories,
  });

  factory fromEnvironment(Flavor flavor) {
    return AppConfig(
      flavor: flavor,
      apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
      useFakeRepositories: const bool.fromEnvironment('USE_FAKE_REPOSITORIES'),
    );
  }

  final Flavor flavor;
  final String apiBaseUrl;

  /// true면 서버 대신 각 feature의 가짜 Repository를 쓴다.
  final bool useFakeRepositories;
}
