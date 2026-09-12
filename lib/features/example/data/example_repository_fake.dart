import 'package:liaison_app/features/example/domain/example_repository.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';

/// 서버 없이 화면을 개발할 때 쓴다. 짧은 지연으로 로딩 상태를 볼 수 있게 한다.
class ExampleRepositoryFake implements ExampleRepository {
  const new();

  @override
  Future<List<ExampleItem>> fetchItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const [
      ExampleItem(id: '1', title: '쎈 개념연산 p.42-43'),
      ExampleItem(id: '2', title: '학습지 3회차 1-10번'),
      ExampleItem(id: '3', title: '개념원리 p.101-104'),
    ];
  }
}
