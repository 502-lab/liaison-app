# 아키텍처

설계 배경과 결정 이유는 `docs/superpowers/specs/2026-09-10-flutter-app-architecture-design.md`에 있다.
이 문서는 코드를 쓸 때 바로 보는 요약본이다.

## 폴더 구조

```
lib/
  main_dev.dart / main_prod.dart   # flavor별 진입점. bootstrap()만 호출
  bootstrap.dart                   # 설정 읽기, ProviderContainer 생성, 알림 초기화, runApp
  app/
    app.dart                       # MaterialApp.router
    fake_overrides.dart            # 각 feature의 가짜 Repository override 모음
    router/app_router.dart         # go_router. 로그인·역할 분기는 redirect에서
    theme/                         # 디자인 확정 후 색·타이포 토큰 (아직 없음)
  core/                            # 기능과 무관한 인프라
    config/                        # Flavor, AppConfig (dart-define 값)
    error/                         # AppException, dio 예외 매핑
    network/                       # dio Provider, 인증 인터셉터
    storage/                       # 토큰 저장소
    notification/                  # 알림 초기화 (Firebase 연동 전엔 no-op)
    riverpod/                      # 재시도 정책 (noRetry)
  shared/                          # 두 개 이상의 feature가 쓰는 위젯·모델 (아직 없음)
  features/
    <feature>/
      <feature>_di.dart            # Repository Provider 조립. data ↔ domain 연결
      data/                        # API 호출, DTO, Repository 구현체, 가짜 구현
      domain/                      # 도메인 모델, Repository 인터페이스 (순수 Dart)
      presentation/                # 화면, 위젯, Provider(Notifier)
```

## 계층 규칙

의존 방향은 `presentation → domain ← data` 하나뿐이다. `test/architecture_test.dart`가 검사한다.

| 규칙 | 위반 예 |
| --- | --- |
| `presentation`은 `data`를 import하지 않는다 | 화면에서 DTO나 API 클래스를 직접 씀 |
| `data`는 `presentation`을 import하지 않는다 | Repository 구현체가 화면 위젯을 참조 |
| `domain`은 Flutter, dio, riverpod을 import하지 않는다 | 도메인 모델에 `BuildContext` 등장 |
| feature끼리 import하지 않는다. 공유는 `shared/`로 | `homework`에서 `textbook/domain` 참조 |
| `features/`, `shared/`에서 `Platform.isIOS` 분기를 쓰지 않는다 | 플랫폼 차이는 `core/` 인터페이스 뒤에 |
| 상대 import를 쓰지 않는다 | `import '../model/x.dart'` |

Repository 인터페이스(domain)와 구현체(data)를 연결하는 Provider는 `<feature>_di.dart`에만 둔다.
presentation은 이 파일을 import해서 Repository를 얻는다.

## Riverpod 사용 규칙

- 모든 Provider는 `@riverpod` 어노테이션으로 생성한다. 파일 상단에 `part '<파일명>.g.dart';`를 쓰고 `fvm dart run build_runner build --delete-conflicting-outputs`로 생성한다.
- 화면 상태는 `Notifier`, 서버에서 가져오는 데이터는 `AsyncNotifier`로 통일한다. 예시: `features/example/presentation/example_list_provider.dart`
- 예외는 삼키지 않는다. `AsyncError`로 흘려보내고 화면이 `switch (state)`로 표시를 결정한다.
- 실제 ↔ 가짜 Repository 교체는 override로 한다. `env/dev.json`의 `USE_FAKE_REPOSITORIES`가 true면 `app/fake_overrides.dart`의 목록이 적용된다.
- 테스트는 `ProviderContainer.test(overrides: [...])`로 Repository를 바꿔 끼운다.
- Riverpod 3는 Provider가 실패하면 기본으로 최대 10회 지수 백오프 재시도를 하고, 그동안 상태가 `AsyncError`가 아니라 `AsyncLoading`이라 화면에 에러가 보이지 않는다. 이 앱은 이를 끈다: `core/riverpod/retry_policy.dart`가 `Duration? noRetry(int retryCount, Object error) => null;`를 제공하고, 서버 데이터 Provider는 `@Riverpod(retry: noRetry)`를 붙인다 (`features/example/presentation/example_list_provider.dart` 참고). `bootstrap.dart`도 `ProviderContainer`에 `retry: noRetry`를 전달한다.
- `Ref`, `Override`는 `package:riverpod_annotation/riverpod_annotation.dart`에서 import한다. `flutter_riverpod`은 위젯(`ConsumerWidget`, `ProviderScope`)과 `bootstrap.dart`의 `ProviderContainer`에서만 쓴다.
- 앱 수명 동안 살아있어야 하는 인프라 Provider(`appConfig`, `dio`, `tokenStorage`, `notificationService`, `router`)는 `@Riverpod(keepAlive: true)`로 만들고 `ref.onDispose`로 정리한다. keepAlive Provider가 watch하는 Provider도 keepAlive여야 한다(`only_use_keep_alive_inside_keep_alive`). 화면 상태 Provider는 기본(auto-dispose)으로 둔다.
- `riverpod_lint`는 `fvm dart analyze`에서만 실행된다. `fvm flutter analyze`는 analyzer 플러그인을 돌리지 않으므로 둘 다 통과해야 한다.

## 코드 스타일 메모

very_good_analysis 11이 Dart 3.13의 `unnecessary_type_name_in_constructor`를 활성화해서, 생성자는 클래스 이름을 반복하지 않는 축약형 `const new({...})` / `factory fromJson(...)`으로 쓴다. 옛 형태로 썼다면 `fvm dart fix --apply`로 변환한다.

## 에러 처리

- `core/error/app_exception.dart`의 `AppException`(sealed)만 화면에 도달한다. 종류: `NetworkException`, `UnauthorizedException`, `ServerException`, `UnknownException`.
- dio 예외는 Repository 구현체에서 `mapDioException`으로 변환한다. 화면은 `DioException`을 모른다.
- Repository 구현체는 `on DioException`은 `mapDioException`으로, 그 외 예외(`on Object`)는 `UnknownException`으로 감싼다. 화면에는 항상 `AppException`만 도달한다.
- 전역 처리(토큰 만료 시 로그인 이동 등)는 `core/network/` 인터셉터와 `app/router/`의 redirect가 맡는다.
- `bootstrap.dart`가 `FlutterError.onError`와 `PlatformDispatcher.onError`로 잡히지 않은 오류를 로그에 남긴다 (Crashlytics 도입 시 여기서 보고).
- `UnknownException`의 `message`는 사용자용 문구이고 기술 정보는 `debugMessage`에 담는다.

## 환경(flavor)

| | dev | prod |
| --- | --- | --- |
| 진입점 | `lib/main_dev.dart` | `lib/main_prod.dart` |
| 설정 | `env/dev.json` | `env/prod.json` |
| applicationId / Bundle ID | `com.liaison.app.dev` | `com.liaison.app` |

실행: `fvm flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json`

Android flavor 정의는 `android/app/flavorizr.gradle.kts`에 있다.

iOS는 flavor마다 Xcode scheme(`dev`, `prod`)과 configuration(`Debug-dev`, `Release-prod` 등 6개)이 있다. flavor 없는 기본 `Runner` scheme과 `Debug`/`Release`/`Profile` configuration, 네이티브 테스트 타깃 `RunnerTests`는 지웠다. flavor 없이 빌드하면 iOS도 Android처럼 실패한다. 값은 `ios/Flutter/<flavor><Config>.xcconfig`에 있고, `Info.plist`의 앱 이름과 LaunchScreen은 그 xcconfig의 `BUNDLE_DISPLAY_NAME`, `ASSET_PREFIX`를 읽는다. `ios/Podfile`의 `project 'Runner', {...}` 매핑은 이 configuration 이름과 맞아야 한다.

flavor를 추가하거나 Bundle ID를 바꿀 때는 `pubspec.yaml`의 `flavorizr` 항목을 고치고 `fvm dart run flutter_flavorizr -f`를 다시 실행한다. Xcode, CocoaPods, `xcodeproj` gem이 있어야 iOS 처리기가 돈다(`docs/SETUP.md` 1번). 프로젝트 파일을 통째로 다시 쓰는 도구라 실행 전에 `git status`가 깨끗한지 확인하고, 결과를 커밋 전에 검토한다. 실행 후 확인할 것: 기본 configuration이 되살아나지 않았는지, `ios/Flutter/<flavor><Config>.xcconfig`의 첫 줄이 `Pods-Runner.<config>-<flavor>.xcconfig`를 include하는지, xcconfig가 Runner의 Resources 단계에 들어가지 않았는지, 새 scheme에 Flutter의 SPM prepare PreAction이 있는지(각 flavor를 한 번 빌드하면 flutter가 넣는다).

`env/*.json`에는 시크릿을 넣지 않는다. 값은 `AppConfig.fromEnvironment`에서 읽는다.

`env/*.json`의 `FLAVOR` 값이 진입점과 다르거나 `API_BASE_URL`이 비어 있으면(가짜 모드가 아닐 때) 앱이 시작 시점에 StateError로 멈춘다.

## Firebase

아직 연동하지 않았다. 연동 순서:

1. Firebase 콘솔에서 dev / prod 프로젝트를 만든다. Android 패키지명과 iOS Bundle ID는 위 표의 값.
2. 설정 파일을 각 위치에 둔다 (git 미추적): `android/app/src/{dev,prod}/google-services.json`, `ios/Runner/Firebase/{dev,prod}/GoogleService-Info.plist`
3. `fvm flutter pub add firebase_core firebase_messaging flutter_local_notifications`
4. Android: `android/app/build.gradle.kts`에 `com.google.gms.google-services` 플러그인 적용.
5. iOS: `flutterfire configure --ios-build-config` 로 configuration별 plist 복사 스크립트 생성. APNs 키 등록, Push capability 추가.
6. `core/notification/`의 `NoopNotificationService`를 FCM 구현체로 교체. 포그라운드 알림은 `flutter_local_notifications`로 표시.

## 후속 작업에서 쓸 패키지 후보

`flutter_secure_storage`는 10.x로 고정되어 있다. 11.x는 compileSdk 37을 요구하는데 Android SDK 저장소에 `android-37`이 없어 빌드가 실패한다. SDK/플러그인 상황이 바뀌면 올린다.

| 용도 | 후보 |
| --- | --- |
| 카메라 촬영·가이드 프레임 | `camera` + 커스텀 오버레이 |
| 권한 | `permission_handler` |
| 이미지 압축 | `flutter_image_compress` |
| 플랫폼별 권한 문구 | iOS `Info.plist`의 `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`; Android `CAMERA`, `POST_NOTIFICATIONS` |
