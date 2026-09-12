import 'package:go_router/go_router.dart';
import 'package:liaison_app/features/example/presentation/example_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// 앱 라우터. 로그인·역할별 진입 분기는 인증 feature가 생기면
/// `redirect:` 파라미터에서 처리한다.
/// 로그인/역할 redirect는 `ref.watch`가 아니라 `refreshListenable` 또는
/// `ref.listen`으로 연결한다. ref.watch하면 상태가 바뀔 때마다 GoRouter가
/// 재생성되어 네비게이션 스택이 초기화된다.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final router = GoRouter(
    initialLocation: '/example',
    routes: [
      GoRoute(
        path: '/example',
        builder: (context, state) => const ExampleScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}
