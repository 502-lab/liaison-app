import 'package:flutter_test/flutter_test.dart';
import 'package:liaison_app/core/config/app_config.dart';
import 'package:liaison_app/core/config/flavor.dart';

void main() {
  group('AppConfig.fromEnvironment', () {
    test('dart-define가 없으면 기본값을 쓴다', () {
      final config = AppConfig.fromEnvironment(Flavor.dev);

      expect(config.flavor, Flavor.dev);
      expect(config.apiBaseUrl, '');
      expect(config.useFakeRepositories, isFalse);
    });
  });

  group('Flavor', () {
    test('이름은 flavorizr flavor 이름과 같다', () {
      expect(Flavor.dev.name, 'dev');
      expect(Flavor.prod.name, 'prod');
    });
  });
}
