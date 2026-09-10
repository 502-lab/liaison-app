import 'package:dio/dio.dart';
import 'package:liaison_app/features/example/data/dto/example_item_dto.dart';

/// 서버 호출만 담당한다. 예외 변환은 Repository 구현체가 한다.
class ExampleApi {
  new(this._dio);

  final Dio _dio;

  Future<List<ExampleItemDto>> fetchItems() async {
    final response = await _dio.get<List<dynamic>>('/examples');
    final body = response.data ?? const [];
    return body
        .map((e) => ExampleItemDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
