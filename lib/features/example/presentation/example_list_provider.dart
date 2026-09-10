import 'package:liaison_app/features/example/domain/model/example_item.dart';
import 'package:liaison_app/features/example/example_di.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'example_list_provider.g.dart';

/// 서버 데이터를 다루는 상태는 AsyncNotifier로 만든다.
/// 예외는 삼키지 않고 AsyncError로 흘려보낸다. 화면이 표시를 결정한다.
///
/// Riverpod 3의 기본 retry 정책(최대 10회, 지수 백오프로 최대 6.4초 간격)은
/// 실패를 즉시 AsyncError로 드러내려는 위 의도와 충돌해 예외가 AsyncLoading
/// 상태로 한참 머물게 만든다. 재시도는 화면의 '다시 시도' 버튼(refresh)이
/// 담당하므로 자동 재시도는 끈다.
@Riverpod(retry: _noRetry)
class ExampleList extends _$ExampleList {
  @override
  Future<List<ExampleItem>> build() {
    return ref.watch(exampleRepositoryProvider).fetchItems();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(exampleRepositoryProvider).fetchItems(),
    );
  }
}

Duration? _noRetry(int retryCount, Object error) => null;
