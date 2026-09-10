import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liaison_app/core/error/app_exception.dart';
import 'package:liaison_app/features/example/data/dto/example_item_dto.dart';
import 'package:liaison_app/features/example/data/example_api.dart';
import 'package:liaison_app/features/example/data/example_repository_impl.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';
import 'package:mocktail/mocktail.dart';

class _MockExampleApi extends Mock implements ExampleApi;

void main() {
  late _MockExampleApi api;
  late ExampleRepositoryImpl repository;

  setUp(() {
    api = _MockExampleApi();
    repository = ExampleRepositoryImpl(api);
  });

  test('API 응답을 도메인 모델 목록으로 바꾼다', () async {
    when(api.fetchItems)
        .thenAnswer((_) async => const [ExampleItemDto(id: '1', title: 'A')]);

    final items = await repository.fetchItems();

    expect(items, const [ExampleItem(id: '1', title: 'A')]);
  });

  test('DioException은 AppException으로 바뀐다', () async {
    when(api.fetchItems).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/examples'),
        type: DioExceptionType.connectionTimeout,
      ),
    );

    expect(repository.fetchItems, throwsA(isA<NetworkException>()));
  });
}
