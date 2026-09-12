import 'package:liaison_app/core/riverpod/retry_policy.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';
import 'package:liaison_app/features/example/example_di.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'example_list_provider.g.dart';

/// 서버 데이터를 다루는 상태는 AsyncNotifier로 만든다.
/// 예외는 삼키지 않고 AsyncError로 흘려보낸다. 화면이 표시를 결정한다.
///
/// 자동 재시도를 끄는 이유는 `core/riverpod/retry_policy.dart`를 참고한다.
@Riverpod(retry: noRetry)
class ExampleList extends _$ExampleList {
  @override
  Future<List<ExampleItem>> build() {
    return ref.watch(exampleRepositoryProvider).fetchItems();
  }

  /// 실패는 state(AsyncError)로 화면에 전달되므로 여기서 다시 던지지 않는다.
  /// 던지면 버튼 콜백에서 버려진 Future가 uncaught error가 된다.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future.then<void>((_) {}, onError: (_) {});
  }
}
