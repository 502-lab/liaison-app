import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liaison_app/app/app.dart';
import 'package:liaison_app/app/fake_overrides.dart';
import 'package:liaison_app/core/config/app_config.dart';
import 'package:liaison_app/core/config/app_config_provider.dart';
import 'package:liaison_app/core/config/flavor.dart';
import 'package:liaison_app/core/notification/notification_service_provider.dart';
import 'package:liaison_app/core/riverpod/retry_policy.dart';

/// 모든 flavor 진입점이 공유하는 초기화.
Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 잡히지 않은 오류를 기기 로그에만 남긴다. 오류 수집 SDK(Crashlytics·Sentry 등)는 쓰지 않는다(AI_RULES 1-4).
  FlutterError.onError = (details) {
    // presentError가 콘솔에 전체 오류를 출력한다. 밖으로 보내지 않는다.
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught platform error: $error\n$stack');
    return true;
  };

  final config = AppConfig.fromEnvironment(flavor);

  final container = ProviderContainer(
    overrides: [
      appConfigProvider.overrideWith((ref) => config),
      if (config.useFakeRepositories) ...fakeOverrides(),
    ],
    retry: noRetry,
  );

  await container.read(notificationServiceProvider).initialize();

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
