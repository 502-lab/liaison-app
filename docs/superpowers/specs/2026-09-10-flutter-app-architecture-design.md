# Flutter 앱 아키텍처 설계

> 작성일: 2026-09-10
> 상태: 승인됨 (구현 계획 작성 전 단계)
> 대상: liaison-app (학생 / 선생님 / 학부모용 모바일 앱, Android + iOS)

## 1. 배경과 목표

### 배경

- 기획서 v0.2 기준으로 앱은 학생·선생님·학부모가 쓰는 **하나의 앱**이며, 로그인한 역할에 따라 화면이 분기된다.
- 핵심 기능: 숙제 부여·조회, 학생 "오늘 할 일", 촬영 기반 과제 제출, FCM 알림(포그라운드 포함), 다중 학원 소속.
- 앱 개발 인원은 2명이며 둘 다 Flutter 경험이 없다. 다만 처음부터 제대로 된 구조 위에서 시작하기를 원한다.
- 디자인 시안과 백엔드 API는 아직 확정되지 않았다.

### 이번 작업의 목표

디자인·API 없이도 진행할 수 있는 범위로 한정한다.

1. Flutter 프로젝트 생성과 초기 설정 (버전 고정, 패키지, flavor, lint, 코드 생성)
2. 폴더 구조와 계층 규칙 확정, 규칙을 lint로 강제
3. core 인프라 (네트워크 클라이언트, 에러 타입, 저장소 래퍼, 알림 초기화 자리)
4. 디자인과 무관한 **최소 레퍼런스 feature** 1개 (연결 방법의 살아있는 예시)
5. 문서 (아키텍처 설명, feature 추가 체크리스트, 개발 환경 세팅 가이드)
6. CI (`flutter analyze` + `flutter test`)

### 이번 작업에서 제외

- 실제 화면 구현, 테마·색·타이포 토큰 → 디자인 확정 후
- 카메라·촬영 가이드 프레임 → 패키지 후보만 문서에 기록
- Firebase 프로젝트 생성과 설정 파일 → 계정 발급 후, 넣을 자리만 마련
- iOS CI 빌드 → macOS 러너 비용 때문에 릴리즈 단계에서 추가

## 2. 폴더 구조와 계층 규칙

### 폴더 구조

```
lib/
  main_dev.dart            # dev flavor 진입점
  main_prod.dart           # prod flavor 진입점
  bootstrap.dart           # 두 진입점이 공유하는 초기화 (ProviderScope, 에러 핸들러 등)
  app/
    app.dart               # MaterialApp.router
    fake_overrides.dart    # 각 feature의 가짜 Repository override 목록을 모음
    router/                # go_router 설정, 역할별 redirect
    theme/                 # (디자인 확정 후 채움) 색·타이포 토큰
  core/
    config/                # AppConfig (flavor, API base URL 등 dart-define 값)
    network/               # dio 클라이언트, 인터셉터(토큰, 로깅), 에러 매핑
    storage/               # secure storage / shared preferences 래퍼
    notification/          # FCM 초기화, 포그라운드 알림 표시 (설정 파일 들어오면 활성화)
    error/                 # AppException, Failure
    utils/                 # 순수 유틸, 확장 함수
  shared/
    widgets/               # 두 개 이상의 feature가 쓰는 위젯
    models/                # 두 개 이상의 feature가 쓰는 모델
  features/
    <feature>/
      <feature>_di.dart                  # Repository Provider 등 의존성 조립 (data ↔ domain 연결)
      data/
        <feature>_api.dart               # dio 호출
        dto/                             # 서버 JSON 그대로 받는 클래스 (freezed)
        <feature>_repository_impl.dart   # DTO → 도메인 모델 변환
        <feature>_repository_fake.dart   # 서버 없이 쓰는 가짜 구현
      domain/
        model/                           # 화면이 쓰는 모델 (순수 Dart)
        <feature>_repository.dart        # 인터페이스
      presentation/
        <feature>_provider.dart          # @riverpod Notifier / AsyncNotifier
        <feature>_screen.dart
        widgets/
        teacher/ student/ parent/        # 역할별 화면이 갈릴 때만 생성
test/
  core/
  features/<feature>/
```

기획서 v1 범위에서 예상되는 feature 목록 (이번 작업에서는 폴더를 만들지 않는다. 필요할 때 체크리스트대로 만든다):
`auth`, `academy`(소속 전환), `home`(오늘 할 일), `homework`, `textbook`, `submission`, `notification`, `parent`, `schedule`.

### 계층 규칙

의존 방향은 아래 한 가지뿐이다.

```
presentation ──▶ domain ◀── data
```

| 규칙 | 이유 |
| --- | --- |
| `presentation`은 `data`를 import하지 않는다. 화면은 도메인 모델만 본다. Repository Provider가 필요하면 feature 루트의 `<feature>_di.dart`를 import한다. | 서버 응답 형태가 바뀌어도 화면 코드가 안 바뀐다. |
| `<feature>_di.dart`만 `data`와 `domain`을 동시에 import할 수 있다. Repository 인터페이스를 구현체에 연결하는 Provider는 전부 여기 둔다. | 조립 지점이 한 파일이라 실제 ↔ 가짜 구현 교체가 한 곳에서 끝난다. |
| `data`는 `presentation`을 import하지 않는다. | 데이터 계층을 화면 없이 단독 테스트할 수 있다. |
| `domain`은 Flutter, dio, riverpod을 import하지 않는다. 순수 Dart만. | 도메인 테스트가 가장 가볍고 빠르다. |
| feature끼리 서로 import하지 않는다. 공유가 필요하면 `shared/`로 올린다. | feature 간 결합이 생기면 하나를 고칠 때 다른 것이 깨진다. |
| `features/`와 `shared/`에서 `Platform.isIOS` 같은 플랫폼 분기를 쓰지 않는다. 필요하면 `core/`의 인터페이스 뒤에 숨긴다. | Android/iOS 차이가 한 곳에 모인다. |

UseCase 계층은 두지 않는다. Provider가 Repository를 직접 호출한다. v1 규모에서 UseCase는 파일 수만 늘린다.

역할별 화면 분리는 `presentation/` 안에서만 한다. "숙제"라는 도메인은 하나이고 역할에 따라 보는 화면만 다르기 때문이다. 역할별로 feature 자체를 나누지 않는다.

이 규칙들은 사람이 외우는 것이 아니라 lint가 잡는다 (5장 참고).

## 3. 기술 선택

| 영역 | 선택 | 대안과 배제 이유 |
| --- | --- | --- |
| 상태관리 | **Riverpod 3** + `riverpod_annotation` / `riverpod_generator` / `riverpod_lint` | Bloc: 규율은 강하나 보일러플레이트가 많아 초반 속도가 느림. Provider: 비동기·캐싱을 직접 처리해야 함. |
| 라우팅 | **go_router** | Navigator 2.0 직접 사용: 학습 비용이 큼. |
| 네트워크 | **dio** | http: 인터셉터·타임아웃·취소 처리가 약함. |
| 모델 | **freezed 4** + `json_serializable` | 수동 `fromJson`: 필드 추가 때마다 실수 여지. |
| 로컬 저장 | `flutter_secure_storage` (토큰), `shared_preferences` (설정) | |
| 알림 (후속) | `firebase_core`, `firebase_messaging`, `flutter_local_notifications` | 포그라운드 표시는 local_notifications가 담당. Firebase 설정 파일 없이는 Android 빌드가 깨지므로 **이번 작업에서는 설치하지 않고** `core/notification/`에 인터페이스와 no-op 구현만 둔다. |
| 카메라·권한 (후속) | `camera`, `permission_handler`, `image` 또는 `flutter_image_compress` | 이번 작업에서는 설치하지 않고 문서에만 기록. |
| lint | `very_good_analysis` + `riverpod_lint` (analysis_options의 `plugins:` 항목으로 등록하는 analyzer 플러그인) | `flutter_lints`는 규칙이 느슨함. |
| flavor 생성 | `flutter_flavorizr` (dev 의존성, 한 번만 실행) | 수동: iOS는 Xcode 프로젝트 파일을 직접 편집해야 해서 실수가 잦음. |
| 버전 고정 | **fvm**, `.fvmrc` 커밋 | 팀원 간 Flutter 버전 불일치 방지. |
| 테스트 | `flutter_test`, `mocktail` | mockito: 코드 생성이 추가로 필요. |

### Riverpod 사용 규칙

- 모든 Provider는 `@riverpod` 어노테이션으로 생성한다. 수동 `Provider(...)` 생성자는 쓰지 않는다.
- 화면 상태는 `Notifier`, 서버에서 가져오는 데이터는 `AsyncNotifier`로 통일한다.
- Repository 구현체 교체(실제 ↔ 가짜)는 Provider override로 한다. 각 feature의 `<feature>_di.dart`가 자기 가짜 override 목록을 내놓고, `app/fake_overrides.dart`가 모으며, `bootstrap.dart`가 dart-define 값 `USE_FAKE_REPOSITORIES`에 따라 적용한다.
- 테스트는 `ProviderContainer.test()`로 컨테이너를 만들고 Repository를 override한다.

### 코드 생성

- `build_runner`로 생성한다. 생성 파일(`*.g.dart`, `*.freezed.dart`)은 **git에 커밋**한다. 클론 직후 바로 빌드가 되어야 초반 팀에서 환경 문제로 막히는 일이 줄어든다.
- CI에서 `build_runner build`를 한 번 돌린 뒤 `git diff --exit-code`로 생성 파일이 최신인지 검사한다.

## 4. 환경(flavor)과 플랫폼 설정

### flavor

- `dev`, `prod` 두 개. 스테이징이 필요해지면 그때 추가한다.
- 진입점은 `main_dev.dart`, `main_prod.dart`. 둘 다 `bootstrap.dart`를 호출하고 flavor만 다르게 넘긴다.
- API base URL 같은 값은 `--dart-define-from-file=env/dev.json` 형태로 주입한다. `env/*.json`은 시크릿이 없는 값만 두고 커밋한다.
- Android/iOS flavor 설정은 `flutter_flavorizr`로 생성한다. 새 프로젝트에서 한 번 실행하며, Dart 코드 생성 처리기(`flutter:*`)는 제외해서 진입점은 직접 작성한다.
- Android: `productFlavors` `dev`/`prod`, applicationId는 `com.liaison.app.dev` / `com.liaison.app`. 두 flavor가 한 기기에 같이 설치된다.
- iOS: Xcode scheme과 configuration `dev`/`prod`, Bundle ID는 Android와 동일한 값.
- **Bundle ID / applicationId(`com.liaison.app`)는 가정값이다.** 팀이 소유한 도메인 기준으로 스토어 등록 전에 확정해야 하며, Firebase 프로젝트를 만들기 전에 바꾸는 것이 가장 싸다.

### Firebase

- Firebase 프로젝트는 dev / prod 별도로 만든다 (이번 작업 범위 밖, 자리만 마련).
- 설정 파일 위치
  - Android: `android/app/src/dev/google-services.json`, `android/app/src/prod/google-services.json`
  - iOS: `ios/Runner/Firebase/dev/GoogleService-Info.plist`, `.../prod/...`. configuration에 맞는 파일을 복사하는 Build Phase 스크립트는 Firebase 설정 시점에 `flutterfire configure --ios-build-config` 명령이 생성한다.
- 설정 파일은 `.gitignore`에 넣고, 자리 표시용 `README.md`를 각 폴더에 둔다.
- `core/notification/`에는 `NotificationService` 인터페이스와 no-op 구현만 둔다. Firebase 설정 파일과 패키지가 들어오면 구현체만 교체한다.

### 플랫폼별 설정 체크리스트 (후속 작업에서 채움)

| 항목 | Android | iOS |
| --- | --- | --- |
| 알림 | 알림 채널 생성, `POST_NOTIFICATIONS` 권한 (API 33+) | APNs 키 등록, 포그라운드 표시 옵션, Push capability |
| 카메라 | `CAMERA` 권한 | `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` |
| 최소 버전 | minSdk 24 | iOS 13 |

## 5. 초반 팀을 위한 가드레일

### 레퍼런스 feature

- 이름은 `example`로 둔다. 실제 기능이 아님을 이름으로 드러낸다.
- 내용: 가짜 Repository가 항목 목록을 돌려주고, `AsyncNotifier`가 받아서 스타일 없는 `ListView`로 뿌린다. 로딩·에러·빈 목록 상태를 모두 표시한다.
- 포함하는 것: `data`(api 호출 뼈대 + fake), `domain`(모델 + 인터페이스), `presentation`(provider + screen), 라우터 등록, Repository 테스트, Provider 테스트.
- 역할: 새 feature를 만들 때 복사하는 템플릿, 계층 규칙이 실제로 어떻게 지켜지는지 보여주는 증명, 온보딩 교재.
- 디자인이 확정되고 실제 feature가 두 개 이상 생기면 삭제한다.

### lint

- `analysis_options.yaml`에 `very_good_analysis`를 include하고, 팀이 감당하기 어려운 규칙만 명시적으로 끈다 (끄는 이유를 주석으로 남긴다).
- `riverpod_lint`를 analyzer 플러그인으로 등록해 Riverpod 오용을 잡는다. analyzer 플러그인은 `dart analyze`에서만 실행되므로(`flutter analyze`는 실행하지 않음) CI와 로컬 확인에서 두 명령을 모두 돌린다.
- 계층 규칙(2장)은 `test/architecture_test.dart`가 `lib/` 아래 모든 Dart 파일의 import 문을 검사하는 방식으로 강제한다. 서드파티 import lint는 유지보수 상태가 들쭉날쭉해 채택하지 않는다. `always_use_package_imports` 규칙(very_good_analysis 포함)이 켜져 있어 package import만 검사하면 된다. 위반 시 `flutter test`가 실패하므로 CI에서 잡힌다.

### 문서

| 파일 | 내용 |
| --- | --- |
| `README.md` | 프로젝트 소개, 환경 세팅 가이드 링크, 실행 명령 (`fvm flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json`) |
| `docs/ARCHITECTURE.md` | 폴더 구조, 계층 규칙, 기술 선택 요약 (이 문서의 2~4장을 팀용으로 압축) |
| `docs/SETUP.md` | fvm, Flutter, Xcode, Android SDK, CocoaPods 설치와 확인 명령. 두 명이 같은 절차로 세팅하도록 |
| `lib/features/README.md` | 새 feature 만드는 순서 체크리스트 (폴더 복사 → 이름 변경 → 모델 정의 → 인터페이스 → fake → provider → 화면 → 라우터 등록 → 테스트) |
| `.github/PULL_REQUEST_TEMPLATE.md` | "테스트 방법" 항목에 `flutter analyze`, `flutter test` 통과 여부 체크박스 추가 |

기존 커밋·브랜치 컨벤션(`COMMIT_CONVENTION.md`, `BRANCH_CONVENTION.md`)은 그대로 따른다.

## 6. 테스트와 CI

### 테스트 범위

| 대상 | 필수 여부 | 방식 |
| --- | --- | --- |
| `domain` 모델·로직 | 필수 | unit test |
| `data` Repository 구현체 | 필수 | unit test, dio는 `mocktail`로 대체 |
| `presentation` Provider | 필수 | `ProviderContainer.test()` + Repository override |
| 화면 | 핵심 흐름만 | widget test |
| 계층 규칙 | 필수 | `test/architecture_test.dart` |

초반 팀이 전부 테스트하려다 지치지 않도록 범위를 위 표로 못 박는다.

### CI

- `.github/workflows/flutter-ci.yml`을 추가한다. 기존 Discord 알림 워크플로우와 같은 폴더.
- 트리거: `pull_request` (main 대상), `push` (main).
- 단계: checkout → Flutter 설치 (`.fvmrc`의 버전을 읽어 사용) → `flutter pub get` → `build_runner build` → 생성 파일 diff 검사 → `flutter analyze` → `dart analyze` → `flutter test`.
- 러너는 `ubuntu-latest`. Android APK 빌드 검증은 시간이 오래 걸리므로 초반에는 포함하지 않고, 릴리즈 브랜치 전략이 정해지면 추가한다.
- iOS 빌드 검증은 포함하지 않는다 (1장 제외 항목).

## 7. 에러 처리 원칙

- `core/error/`에 `AppException`(sealed class)을 두고 네트워크·인증·서버·알 수 없음 정도로만 나눈다. 세분화는 실제 화면이 필요로 할 때 한다.
- dio 예외는 인터셉터 또는 Repository 구현체에서 `AppException`으로 변환한다. 화면 코드가 `DioException`을 직접 보지 않는다.
- Provider는 예외를 삼키지 않고 `AsyncError`로 흘려보낸다. 화면은 `AsyncValue.when`으로 로딩·에러·데이터를 표시한다.
- 전역 처리(토큰 만료 시 로그인 화면 이동 등)는 `app/router/`의 redirect와 `core/network/` 인터셉터가 담당한다.

## 8. 가정

- 백엔드는 REST + JSON이다. `liaison-back`이 아직 비어 있어 확인할 수 없다. 다르면 `data` 계층만 바뀐다.
- 인증은 토큰 기반(액세스 + 리프레시)이다. 방식이 정해지면 `core/network/` 인터셉터만 수정한다.
- Flutter는 작업 시점의 최신 stable을 `.fvmrc`에 고정한다. 프로젝트 이름은 `liaison_app`, 플랫폼은 Android와 iOS만 생성한다 (web, desktop 제외).
- 각 개발자의 머신에 Flutter, Xcode, Android SDK 설치는 `docs/SETUP.md`를 따라 각자 진행한다.
- iOS flavor 생성(`flutter_flavorizr`)과 iOS 빌드는 Xcode가 `xcode-select`로 선택되어 있고 CocoaPods와 Ruby gem `xcodeproj`가 설치된 머신에서만 검증할 수 있다. 관리자 권한이 필요한 설치는 개발자가 직접 한다.

## 9. 다음 단계

이 문서 승인 후 구현 계획(`docs/superpowers/plans/`)을 작성한다. 계획은 대략 아래 순서로 나뉜다.

1. fvm 설정과 `flutter create`, 패키지 설치, lint 설정
2. flavor (Android / iOS / 진입점 / env 파일)
3. 폴더 뼈대와 `core/` 인프라
4. 레퍼런스 feature `example`과 테스트
5. 계층 규칙 lint 또는 architecture test
6. 문서와 CI
