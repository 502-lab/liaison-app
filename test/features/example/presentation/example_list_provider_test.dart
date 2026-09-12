import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liaison_app/core/error/app_exception.dart';
import 'package:liaison_app/features/example/domain/example_repository.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';
import 'package:liaison_app/features/example/example_di.dart';
import 'package:liaison_app/features/example/presentation/example_list_provider.dart';

class _StubRepository implements ExampleRepository {
  new(this._result);

  final Future<List<ExampleItem>> Function() _result;

  @override
  Future<List<ExampleItem>> fetchItems() => _result();
}

void main() {
  test('Repository 결과를 상태로 내놓는다', () async {
    final container = ProviderContainer.test(
      overrides: [
        exampleRepositoryProvider.overrideWith(
          (ref) => _StubRepository(
            () async => const [ExampleItem(id: '1', title: 'A')],
          ),
        ),
      ],
    );

    final items = await container.read(exampleListProvider.future);

    expect(items, const [ExampleItem(id: '1', title: 'A')]);
  });

  test('Repository가 던진 예외는 AsyncError로 흘러간다', () async {
    final container = ProviderContainer.test(
      overrides: [
        exampleRepositoryProvider.overrideWith(
          (ref) => _StubRepository(() => throw const NetworkException()),
        ),
      ],
    );

    await expectLater(
      container.read(exampleListProvider.future),
      throwsA(isA<NetworkException>()),
    );
    expect(
      container.read(exampleListProvider),
      isA<AsyncError<List<ExampleItem>>>(),
    );
  });
}
