import 'package:dio/dio.dart';
import 'package:liaison_app/core/error/app_exception.dart';
import 'package:liaison_app/core/error/dio_exception_mapper.dart';
import 'package:liaison_app/features/example/data/dto/example_item_dto.dart';
import 'package:liaison_app/features/example/data/example_api.dart';
import 'package:liaison_app/features/example/domain/example_repository.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';

class ExampleRepositoryImpl implements ExampleRepository {
  new(this._api);

  final ExampleApi _api;

  @override
  Future<List<ExampleItem>> fetchItems() async {
    try {
      final dtos = await _api.fetchItems();
      return dtos.map((dto) => dto.toDomain()).toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    } on Object catch (e) {
      throw UnknownException(debugMessage: e.toString());
    }
  }
}
