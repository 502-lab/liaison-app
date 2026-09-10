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
