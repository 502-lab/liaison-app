import 'package:flutter_test/flutter_test.dart';
import 'package:liaison_app/core/config/app_config.dart';
import 'package:liaison_app/core/config/flavor.dart';

void main() {
  group('AppConfig.fromEnvironment', () {
    test('dart-define가 없으면 StateError를 던진다', () {
      expect(() => AppConfig.fromEnvironment(Flavor.dev), throwsStateError);
    });
  });

  group('AppConfig', () {
    test('생성자로 만들면 전달한 값을 그대로 갖는다', () {
      const config = AppConfig(
        flavor: Flavor.dev,
        apiBaseUrl: 'http://x',
        useFakeRepositories: true,
      );

      expect(config.flavor, Flavor.dev);
      expect(config.apiBaseUrl, 'http://x');
      expect(config.useFakeRepositories, isTrue);
    });
  });

  group('Flavor', () {
    test('이름은 flavorizr flavor 이름과 같다', () {
      expect(Flavor.dev.name, 'dev');
      expect(Flavor.prod.name, 'prod');
    });
  });
}
