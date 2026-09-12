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
    const definedFlavor = String.fromEnvironment('FLAVOR');
    if (definedFlavor.isNotEmpty && definedFlavor != flavor.name) {
      throw StateError(
        'FLAVOR=$definedFlavor 인데 진입점은 ${flavor.name} 입니다. '
        '--dart-define-from-file=env/${flavor.name}.json 을 확인하세요',
      );
    }

    const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
    const useFakeRepositories = bool.fromEnvironment('USE_FAKE_REPOSITORIES');
    if (apiBaseUrl.isEmpty && !useFakeRepositories) {
      throw StateError(
        'API_BASE_URL이 비어 있습니다. '
        '--dart-define-from-file=env/<flavor>.json 을 빠뜨리지 않았는지 확인하세요',
      );
    }

    return AppConfig(
      flavor: flavor,
      apiBaseUrl: apiBaseUrl,
      useFakeRepositories: useFakeRepositories,
    );
  }

  final Flavor flavor;
  final String apiBaseUrl;

  /// true면 서버 대신 각 feature의 가짜 Repository를 쓴다.
  final bool useFakeRepositories;
}
