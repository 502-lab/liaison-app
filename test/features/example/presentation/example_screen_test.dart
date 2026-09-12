import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liaison_app/core/error/app_exception.dart';
import 'package:liaison_app/features/example/domain/example_repository.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';
import 'package:liaison_app/features/example/example_di.dart';
import 'package:liaison_app/features/example/presentation/example_screen.dart';

class _StubRepository implements ExampleRepository {
  new(this._result);

  final Future<List<ExampleItem>> Function() _result;

  @override
  Future<List<ExampleItem>> fetchItems() => _result();
}

class _FailThenSucceedRepository implements ExampleRepository {
  int _callCount = 0;

  @override
  Future<List<ExampleItem>> fetchItems() async {
    _callCount++;
    if (_callCount == 1) {
      throw const NetworkException();
    }
    return const [ExampleItem(id: '1', title: '재시도 후 항목')];
  }
}

Widget _app(ExampleRepository repository) {
  // 루트 ProviderScope에 override를 직접 넣으면 riverpod_lint가
  // scoped_providers_should_specify_dependencies를 낸다. 테스트용 컨테이너를 쓴다.
  final container = ProviderContainer.test(
    overrides: [exampleRepositoryProvider.overrideWith((ref) => repository)],
  );
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: ExampleScreen()),
  );
}

void main() {
  testWidgets('항목 목록을 보여준다', (tester) async {
    await tester.pumpWidget(
      _app(
        _StubRepository(
          () async => const [ExampleItem(id: '1', title: '첫 항목')],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('첫 항목'), findsOneWidget);
  });

  testWidgets('비어 있으면 안내 문구를 보여준다', (tester) async {
    await tester.pumpWidget(_app(_StubRepository(() async => const [])));
    await tester.pumpAndSettle();

    expect(find.text('항목이 없습니다'), findsOneWidget);
  });

  testWidgets('실패하면 메시지와 다시 시도 버튼을 보여준다', (tester) async {
    await tester.pumpWidget(
      _app(_StubRepository(() => throw const NetworkException())),
    );
    await tester.pumpAndSettle();

    expect(find.text('네트워크에 연결할 수 없습니다'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });

  testWidgets('다시 시도를 누르면 refresh가 build를 다시 실행한다', (tester) async {
    await tester.pumpWidget(_app(_FailThenSucceedRepository()));
    await tester.pumpAndSettle();

    expect(find.text('네트워크에 연결할 수 없습니다'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(find.text('재시도 후 항목'), findsOneWidget);
    expect(find.text('네트워크에 연결할 수 없습니다'), findsNothing);
  });

  testWidgets('다시 시도가 또 실패해도 예외가 새지 않고 에러 화면이 유지된다', (tester) async {
    await tester.pumpWidget(
      _app(_StubRepository(() => throw const NetworkException())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('네트워크에 연결할 수 없습니다'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });
}
