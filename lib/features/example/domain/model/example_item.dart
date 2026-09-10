import 'package:freezed_annotation/freezed_annotation.dart';

part 'example_item.freezed.dart';

/// 화면이 쓰는 모델. 서버 응답 형태(DTO)와 분리한다.
@freezed
abstract class ExampleItem with _$ExampleItem {
  const factory({required String id, required String title}) = _ExampleItem;
}
