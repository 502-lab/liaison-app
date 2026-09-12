import 'package:liaison_app/core/network/dio_provider.dart';
import 'package:liaison_app/features/example/data/example_api.dart';
import 'package:liaison_app/features/example/data/example_repository_fake.dart';
import 'package:liaison_app/features/example/data/example_repository_impl.dart';
import 'package:liaison_app/features/example/domain/example_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'example_di.g.dart';

/// 이 feature의 의존성 조립. data와 domain을 동시에 import할 수 있는 유일한 파일.
@riverpod
ExampleRepository exampleRepository(Ref ref) {
  return ExampleRepositoryImpl(ExampleApi(ref.watch(dioProvider)));
}

/// 서버 없이 실행할 때 적용하는 override. `app/fake_overrides.dart`가 모은다.
List<Override> exampleFakeOverrides() {
  return [
    exampleRepositoryProvider.overrideWith(
      (ref) => const ExampleRepositoryFake(),
    ),
  ];
}
