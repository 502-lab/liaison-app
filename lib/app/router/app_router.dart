import 'package:go_router/go_router.dart';
import 'package:liaison_app/features/example/presentation/example_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// 앱 라우터. 로그인·역할별 진입 분기는 인증 feature가 생기면
/// `redirect:` 파라미터에서 처리한다.
@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/example',
    routes: [
      GoRoute(
        path: '/example',
        builder: (context, state) => const ExampleScreen(),
      ),
    ],
  );
}
