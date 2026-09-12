import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';

part 'example_item_dto.freezed.dart';
part 'example_item_dto.g.dart';

/// 서버 JSON을 그대로 받는 클래스. 필드명은 서버 스펙을 따른다.
@freezed
abstract class ExampleItemDto with _$ExampleItemDto {
  const factory({required String id, required String title}) = _ExampleItemDto;

  factory fromJson(Map<String, dynamic> json) => _$ExampleItemDtoFromJson(json);
}

extension ExampleItemDtoMapper on ExampleItemDto {
  ExampleItem toDomain() => ExampleItem(id: id, title: title);
}
