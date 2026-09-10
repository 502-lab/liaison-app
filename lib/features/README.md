# 새 feature 만들기

`example/`을 복사해서 시작한다. 순서대로 하면 계층 규칙을 어길 일이 없다.

1. **폴더 복사**: `cp -r lib/features/example lib/features/<name>` 후 파일명과 클래스명의 `example`/`Example`을 `<name>`/`<Name>`으로 바꾼다. 생성 파일(`*.g.dart`, `*.freezed.dart`)은 지운다.
2. **domain/model**: 화면이 쓰는 모델을 freezed로 정의한다. Flutter, dio, riverpod import 금지.
3. **domain/<name>_repository.dart**: 인터페이스. 메서드는 도메인 모델만 주고받는다.
4. **data/dto**: 서버 JSON 형태 그대로. `toDomain()` 확장을 같이 둔다.
5. **data/<name>_api.dart**: dio 호출만.
6. **data/<name>_repository_impl.dart**: API 호출 + DTO 변환. `on DioException`은 `mapDioException`, 그 외는 `UnknownException`으로 변환.
7. **data/<name>_repository_fake.dart**: 서버 없이 쓸 가짜 데이터.
8. **<name>_di.dart**: `@riverpod <Name>Repository <name>Repository(Ref ref)`와 `<name>FakeOverrides()`.
9. **app/fake_overrides.dart**에 `...<name>FakeOverrides()` 추가.
10. **presentation/<name>_provider.dart**: `AsyncNotifier` 또는 `Notifier`. 서버 데이터 Provider에는 `@Riverpod(retry: noRetry)`를 붙인다 (`core/riverpod/retry_policy.dart` 참고).
11. **presentation/<name>_screen.dart**: 로딩 · 에러 · 빈 상태 · 데이터 네 가지를 모두 다룬다.
12. **app/router/app_router.dart**에 경로 추가.
13. **테스트**: `test/features/<name>/`에 DTO, Repository 구현체, Provider, 화면 테스트. `example`의 테스트를 복사해서 시작한다.
14. `fvm dart run build_runner build --delete-conflicting-outputs && fvm dart format lib test && fvm flutter analyze && fvm flutter test`

역할(학생/선생님/학부모)에 따라 화면이 다르면 `presentation/student/`, `presentation/teacher/`처럼 presentation 안에서만 나눈다. feature 자체를 역할별로 만들지 않는다.

`example/`은 실제 feature가 두 개 이상 생기면 삭제한다.
