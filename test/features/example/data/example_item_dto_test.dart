import 'package:flutter_test/flutter_test.dart';
import 'package:liaison_app/features/example/data/dto/example_item_dto.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';

void main() {
  group('ExampleItemDto', () {
    test('JSON에서 읽는다', () {
      final dto = ExampleItemDto.fromJson({'id': '1', 'title': '첫 항목'});

      expect(dto.id, '1');
      expect(dto.title, '첫 항목');
    });

    test('도메인 모델로 변환한다', () {
      const dto = ExampleItemDto(id: '1', title: '첫 항목');

      expect(dto.toDomain(), const ExampleItem(id: '1', title: '첫 항목'));
    });
  });
}
