import 'package:liaison_app/features/example/domain/model/example_item.dart';

/// 실패 시 AppException의 하위 타입을 던진다.
abstract interface class ExampleRepository {
  Future<List<ExampleItem>> fetchItems();
}
