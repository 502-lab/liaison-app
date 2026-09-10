# Flutter 프로젝트 초기 설정 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Android/iOS 공통 Flutter 앱의 뼈대를 만든다. 버전 고정, 패키지, flavor, lint, core 인프라, 레퍼런스 feature, 계층 규칙 테스트, 문서, CI까지 포함하고 실제 화면·디자인·Firebase 연동은 제외한다.

**Architecture:** `app / core / shared / features` 4개 최상위 폴더. feature 안은 `data / domain / presentation`으로 나누고 의존 방향은 `presentation → domain ← data`만 허용한다. Repository 인터페이스와 구현체의 연결은 feature 루트의 `<feature>_di.dart`에서만 하며, 가짜 구현 교체는 Riverpod override로 한다.

**Tech Stack:** Flutter (최신 stable, fvm 고정), Riverpod 3 + riverpod_generator, go_router, dio, freezed 4 + json_serializable, flutter_secure_storage, very_good_analysis, riverpod_lint, flutter_flavorizr, mocktail, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-09-10-flutter-app-architecture-design.md`

## Global Constraints

- 프로젝트 이름 `liaison_app`, 플랫폼은 `android,ios`만 생성한다.
- applicationId / Bundle ID: dev `com.liaison.app.dev`, prod `com.liaison.app`. 가정값이며 스토어 등록 전 확정 필요.
- 모든 Flutter/Dart 명령은 `fvm flutter ...`, `fvm dart ...`로 실행한다. `.fvmrc`를 커밋한다.
- 생성 파일(`*.g.dart`, `*.freezed.dart`)은 커밋한다.
- 모든 Provider는 `@riverpod` 코드 생성으로 만든다. 수동 `Provider(...)` 금지.
- `domain/`은 Flutter, dio, riverpod을 import하지 않는다. `presentation/`은 `data/`를 import하지 않는다. feature끼리 import하지 않는다. `features/`, `shared/`에서 `dart:io`의 `Platform` 분기 금지.
- 커밋 메시지는 `type: 한글 명사형 요약` 형식(`COMMIT_CONVENTION.md`). 브랜치는 `chore/flutter-project-setup`.
- 이번 작업에서 Firebase 패키지, 카메라 패키지, 테마 토큰은 추가하지 않는다.
- Dart 파일에서 상대 import를 쓰지 않는다 (`always_use_package_imports`).
- `flutter analyze` 전에 항상 `fvm dart format lib test`를 실행한다. very_good_analysis의 80자 제한을 포매터가 맞춰준다.

---

## 파일 구조 요약

이 계획이 만들거나 수정하는 파일이다. 태스크 순서대로 채워진다.

```
.fvmrc, .vscode/settings.json, .gitignore, pubspec.yaml, analysis_options.yaml
env/dev.json, env/prod.json
android/ (flutter create + flavorizr 결과), ios/ (동일)
android/app/src/dev/README.md, android/app/src/prod/README.md
ios/Runner/Firebase/dev/README.md, ios/Runner/Firebase/prod/README.md
lib/
  main_dev.dart, main_prod.dart, bootstrap.dart
  app/app.dart, app/fake_overrides.dart, app/router/app_router.dart
  core/config/flavor.dart, core/config/app_config.dart, core/config/app_config_provider.dart
  core/error/app_exception.dart, core/error/dio_exception_mapper.dart
  core/storage/token_storage.dart, core/storage/token_storage_provider.dart
  core/network/auth_interceptor.dart, core/network/dio_provider.dart
  core/notification/notification_service.dart, core/notification/notification_service_provider.dart
  features/README.md
  features/example/example_di.dart
  features/example/domain/model/example_item.dart, domain/example_repository.dart
  features/example/data/dto/example_item_dto.dart, data/example_api.dart,
    data/example_repository_impl.dart, data/example_repository_fake.dart
  features/example/presentation/example_list_provider.dart, presentation/example_screen.dart
test/
  architecture_test.dart
  core/config/app_config_test.dart, core/error/dio_exception_mapper_test.dart,
  core/network/auth_interceptor_test.dart
  features/example/data/example_item_dto_test.dart, data/example_repository_impl_test.dart
  features/example/presentation/example_list_provider_test.dart, presentation/example_screen_test.dart
docs/ARCHITECTURE.md, docs/SETUP.md, README.md, .github/PULL_REQUEST_TEMPLATE.md
.github/workflows/flutter-ci.yml
```

---

### Task 0: 개발 머신 사전 준비 (사람이 직접 실행)

이 태스크는 관리자 권한이 필요해서 자동 실행하지 않는다. 실행자는 아래 확인 명령을 돌려 통과 여부만 보고하고, 실패한 항목은 사용자에게 안내한다.

**현재 확인된 상태 (2026-09-10, 이 머신):** Xcode.app와 Android Studio는 설치되어 있으나 `xcode-select`가 CommandLineTools를 가리키고 있고, CocoaPods·fvm·Flutter가 없다. Homebrew와 JDK 25는 있다.

- [ ] **Step 1: Xcode를 활성 개발자 디렉터리로 선택** (사용자가 실행)

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

- [ ] **Step 2: CocoaPods와 xcodeproj gem 설치** (사용자가 실행)

```bash
brew install cocoapods
sudo gem install xcodeproj
```

`sudo gem`이 싫으면 `gem install --user-install xcodeproj`로 대신한다. `xcodeproj`는 `flutter_flavorizr`가 iOS 프로젝트 파일을 수정할 때 시스템 Ruby에서 불러온다.

- [ ] **Step 3: 확인**

Run:
```bash
xcodebuild -version && pod --version && ruby -e "require 'xcodeproj'; puts 'xcodeproj ok'"
```
Expected: Xcode 버전, CocoaPods 버전, `xcodeproj ok`가 각각 출력된다.

통과하지 못하면 Task 3의 iOS 처리기와 이후 iOS 관련 검증 단계는 건너뛰고, 보고서에 "iOS 미검증"으로 남긴다. Android와 Dart 측 작업은 모두 진행할 수 있다.

---

### Task 1: fvm 설치, Flutter 버전 고정, 프로젝트 생성

**Files:**
- Create: `.fvmrc`, `.vscode/settings.json`, `.gitignore`, `pubspec.yaml`, `android/`, `ios/`, `lib/main.dart`(임시), `test/widget_test.dart`(삭제 예정)
- Modify: 없음 (README.md는 `flutter create`가 덮어쓰지 않는지 확인)

**Interfaces:**
- Produces: `fvm flutter` 명령이 동작하는 프로젝트. 이후 모든 태스크가 이 명령을 쓴다.

- [ ] **Step 1: 브랜치 생성**

```bash
git switch docs/flutter-architecture-spec
git switch -c chore/flutter-project-setup
```

- [ ] **Step 2: fvm 설치와 Flutter stable 고정**

```bash
brew tap leoafarias/fvm
brew install fvm
fvm install stable
fvm use stable --pin
```

`--pin`은 `stable`이라는 이름 대신 실제 버전 번호(예: `3.41.2`)를 `.fvmrc`에 적는다. 팀원 모두 같은 번호를 쓰게 된다.

- [ ] **Step 3: 고정 결과 확인**

Run: `cat .fvmrc && fvm flutter --version`
Expected: `.fvmrc`에 `"flutter": "<숫자 버전>"`이 있고, 같은 버전이 출력된다. `.fvm/` 디렉터리가 생겼는지 `ls -a`로 확인한다.

- [ ] **Step 4: 프로젝트 생성**

기존 파일(README, 컨벤션 문서)이 있는 디렉터리에 생성한다. `flutter create`는 이미 있는 파일을 덮어쓰지 않는다.

```bash
fvm flutter create --org com.liaison --project-name liaison_app --platforms android,ios .
```

- [ ] **Step 5: 생성 결과 확인**

Run: `git status --short | head -30 && cat README.md | head -5`
Expected: `android/`, `ios/`, `lib/`, `test/`, `pubspec.yaml`, `analysis_options.yaml`, `.gitignore`, `.metadata`가 새로 생겼고 README.md 첫 줄이 `# liaison-app`으로 유지된다. 만약 README가 덮어써졌다면 `git checkout README.md`로 되돌린다.

- [ ] **Step 6: .gitignore에 fvm 항목 추가**

`.gitignore` 끝에 추가:

```
# fvm
.fvm/
```

`.fvmrc`와 `.vscode/settings.json`은 커밋한다 (fvm이 만든 `dart.flutterSdkPath` 설정이 팀원 에디터를 같은 SDK로 맞춘다).

- [ ] **Step 7: 템플릿 테스트가 통과하는지 확인**

Run: `fvm flutter test`
Expected: `All tests passed!` (템플릿의 카운터 테스트 1개)

- [ ] **Step 8: 커밋**

```bash
git add -A
git commit -m "chore: Flutter 프로젝트 생성 및 fvm 버전 고정"
```

---

### Task 2: 패키지 설치와 lint 설정

**Files:**
- Modify: `pubspec.yaml`, `analysis_options.yaml`
- Delete: `test/widget_test.dart`, `lib/main.dart` (Task 3에서 진입점을 새로 만든다)

**Interfaces:**
- Produces: 이후 태스크가 쓰는 패키지 전부. `fvm dart run build_runner build` 명령.

- [ ] **Step 1: 런타임 패키지 추가**

```bash
fvm flutter pub add flutter_riverpod riverpod_annotation go_router dio freezed_annotation json_annotation flutter_secure_storage shared_preferences
```

- [ ] **Step 2: 개발 패키지 추가**

```bash
fvm flutter pub add dev:riverpod_generator dev:riverpod_lint dev:build_runner dev:freezed dev:json_serializable dev:very_good_analysis dev:mocktail dev:flutter_flavorizr
```

- [ ] **Step 3: 버전 확인**

Run: `grep -E "^\s+(freezed|riverpod_generator|riverpod_lint|flutter_riverpod|very_good_analysis):" pubspec.yaml`
Expected: `freezed: ^4.x`, `flutter_riverpod: ^3.x`, `riverpod_generator: ^3.x` 이상. freezed가 3.x로 잡히면 `fvm flutter pub add dev:freezed:^4.0.0`으로 올린다.

- [ ] **Step 4: analysis_options.yaml 교체**

파일 전체를 아래로 바꾼다. `riverpod_lint` 버전은 pubspec에 적힌 값과 같은 값을 쓴다.

```yaml
include: package:very_good_analysis/analysis_options.yaml

plugins:
  riverpod_lint: ^3.0.0   # pubspec.yaml의 riverpod_lint 버전과 맞춘다

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "build/**"

linter:
  rules:
    # 초반 팀에서 모든 public 멤버에 문서 주석을 요구하면 코드보다 주석 쓰는 시간이 길어진다.
    public_member_api_docs: false
    # 화면 위젯 파일은 한 파일에 private 위젯이 여러 개 들어가는 게 자연스럽다.
    one_member_abstracts: false
```

- [ ] **Step 5: 템플릿 파일 삭제**

```bash
rm lib/main.dart test/widget_test.dart
```

- [ ] **Step 6: analyze가 플러그인을 인식하는지 확인**

Run: `fvm flutter analyze`
Expected: `No issues found!` 또는 lib에 파일이 없다는 안내. `plugins` 항목 관련 에러가 나오면 `.fvmrc`의 Dart 버전이 analyzer 플러그인을 지원하지 않는 것이다. 그 경우 `plugins:` 블록을 지우고 `fvm flutter pub add dev:custom_lint` 후 CI와 문서의 analyze 단계에 `fvm dart run custom_lint`를 추가한다. 어느 쪽을 택했는지 커밋 본문에 적는다.

- [ ] **Step 7: 커밋**

```bash
git add -A
git commit -m "chore: 상태관리·라우팅·네트워크 패키지 및 lint 설정 추가"
```

---

### Task 3: flavor 생성과 진입점, AppConfig

**Files:**
- Modify: `pubspec.yaml` (flavorizr 설정), `android/**`, `ios/**` (flavorizr 결과), `.gitignore`
- Create: `env/dev.json`, `env/prod.json`, `lib/core/config/flavor.dart`, `lib/core/config/app_config.dart`, `lib/core/config/app_config_provider.dart`, `lib/bootstrap.dart`, `lib/main_dev.dart`, `lib/main_prod.dart`, `lib/app/app.dart`, `lib/app/fake_overrides.dart`, `android/app/src/dev/README.md`, `android/app/src/prod/README.md`, `ios/Runner/Firebase/dev/README.md`, `ios/Runner/Firebase/prod/README.md`
- Test: `test/core/config/app_config_test.dart`

**Interfaces:**
- Produces:
  - `enum Flavor { dev, prod }`
  - `class AppConfig { final Flavor flavor; final String apiBaseUrl; final bool useFakeRepositories; factory AppConfig.fromEnvironment(Flavor flavor); }`
  - `appConfigProvider` (`Provider<AppConfig>`, bootstrap에서 override)
  - `Future<void> bootstrap(Flavor flavor)`
  - `List<Override> fakeOverrides()` in `lib/app/fake_overrides.dart` (Task 5가 항목을 추가)
  - `class App extends ConsumerWidget` (Task 5에서 라우터를 붙인다. 이 태스크에서는 임시 화면)

- [ ] **Step 1: flavorizr 설정을 pubspec.yaml 끝에 추가**

```yaml
flavorizr:
  app:
    android:
      flavorDimensions: "flavor-type"
  flavors:
    dev:
      app:
        name: "Liaison Dev"
      android:
        applicationId: "com.liaison.app.dev"
      ios:
        bundleId: "com.liaison.app.dev"
    prod:
      app:
        name: "Liaison"
      android:
        applicationId: "com.liaison.app"
      ios:
        bundleId: "com.liaison.app"
  instructions:
    - assets:download
    - assets:extract
    - android:androidManifest
    - android:buildGradle
    - android:dummyAssets
    - android:icons
    - ios:podfile
    - ios:xcconfig
    - ios:buildTargets
    - ios:schema
    - ios:dummyAssets
    - ios:icons
    - ios:plist
    - ios:launchScreen
    - ide:config
    - assets:clean
```

`flutter:*` 처리기를 뺐기 때문에 Dart 진입점은 생성되지 않는다. Task 0을 통과하지 못한 머신에서는 `ios:*` 줄을 모두 지우고 실행한 뒤, 보고서에 "iOS flavor 미생성"으로 남긴다.

- [ ] **Step 2: flavorizr 실행**

```bash
fvm dart run flutter_flavorizr
```

처리기 이름이 없다는 에러가 나면 `fvm dart run flutter_flavorizr -h`로 현재 버전의 처리기 목록을 확인해 이름을 맞춘다.

- [ ] **Step 3: 결과 확인**

Run: `grep -n "productFlavors" -A 12 android/app/build.gradle.kts; ls ios/Runner.xcodeproj/xcshareddata/xcschemes/ 2>/dev/null`
Expected: `dev`, `prod` 두 flavor와 각 `applicationId`가 gradle에 있다. iOS를 처리했다면 `dev.xcscheme`, `prod.xcscheme`가 보인다.

- [ ] **Step 4: env 파일 생성**

`env/dev.json`:
```json
{
  "API_BASE_URL": "http://localhost:8080",
  "USE_FAKE_REPOSITORIES": true
}
```

`env/prod.json`:
```json
{
  "API_BASE_URL": "https://api.liaison.example",
  "USE_FAKE_REPOSITORIES": false
}
```

prod의 주소는 서버 도메인이 정해지면 바꾼다. 시크릿은 이 파일에 넣지 않는다.

- [ ] **Step 5: 실패하는 테스트 작성** — `test/core/config/app_config_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:liaison_app/core/config/app_config.dart';
import 'package:liaison_app/core/config/flavor.dart';

void main() {
  group('AppConfig.fromEnvironment', () {
    test('dart-define가 없으면 기본값을 쓴다', () {
      final config = AppConfig.fromEnvironment(Flavor.dev);

      expect(config.flavor, Flavor.dev);
      expect(config.apiBaseUrl, '');
      expect(config.useFakeRepositories, isFalse);
    });
  });

  group('Flavor', () {
    test('이름은 flavorizr flavor 이름과 같다', () {
      expect(Flavor.dev.name, 'dev');
      expect(Flavor.prod.name, 'prod');
    });
  });
}
```

- [ ] **Step 6: 테스트 실패 확인**

Run: `fvm flutter test test/core/config/app_config_test.dart`
Expected: 컴파일 에러 (`app_config.dart` 없음)

- [ ] **Step 7: Flavor와 AppConfig 구현**

`lib/core/config/flavor.dart`:
```dart
/// 빌드 환경. 이름은 flavorizr가 만든 Android/iOS flavor 이름과 같아야 한다.
enum Flavor { dev, prod }
```

`lib/core/config/app_config.dart`:
```dart
import 'package:liaison_app/core/config/flavor.dart';

/// 실행 시점에 결정되는 앱 설정.
///
/// 값은 `--dart-define-from-file=env/<flavor>.json`으로 주입된다.
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.useFakeRepositories,
  });

  factory AppConfig.fromEnvironment(Flavor flavor) {
    return AppConfig(
      flavor: flavor,
      apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
      useFakeRepositories: const bool.fromEnvironment('USE_FAKE_REPOSITORIES'),
    );
  }

  final Flavor flavor;
  final String apiBaseUrl;

  /// true면 서버 대신 각 feature의 가짜 Repository를 쓴다.
  final bool useFakeRepositories;
}
```

`lib/core/config/app_config_provider.dart`:
```dart
import 'package:liaison_app/core/config/app_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config_provider.g.dart';

/// bootstrap에서 반드시 override한다. override 없이 읽으면 즉시 실패해서
/// 설정 누락을 빨리 알 수 있다.
@riverpod
AppConfig appConfig(Ref ref) {
  throw UnimplementedError('appConfigProvider는 bootstrap에서 override되어야 합니다');
}
```

- [ ] **Step 8: 코드 생성 후 테스트 통과 확인**

Run: `fvm dart run build_runner build --delete-conflicting-outputs && fvm flutter test test/core/config/app_config_test.dart`
Expected: `app_config_provider.g.dart` 생성, `All tests passed!`

- [ ] **Step 9: App, fake_overrides, bootstrap, 진입점 작성**

`lib/app/app.dart` (Task 5에서 라우터로 교체된다):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liaison_app/core/config/app_config_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    return MaterialApp(
      title: 'Liaison',
      home: Scaffold(
        body: Center(child: Text('flavor: ${config.flavor.name}')),
      ),
    );
  }
}
```

`lib/app/fake_overrides.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 서버 없이 앱을 띄울 때 적용하는 override 목록.
///
/// 각 feature는 `<feature>_di.dart`에 자기 가짜 override 목록을 두고,
/// 여기서 그것들을 모은다. 새 feature를 만들면 이 목록에 추가한다.
List<Override> fakeOverrides() {
  return [];
}
```

`lib/bootstrap.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liaison_app/app/app.dart';
import 'package:liaison_app/app/fake_overrides.dart';
import 'package:liaison_app/core/config/app_config.dart';
import 'package:liaison_app/core/config/app_config_provider.dart';
import 'package:liaison_app/core/config/flavor.dart';

/// 모든 flavor 진입점이 공유하는 초기화.
Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment(flavor);

  final container = ProviderContainer(
    overrides: [
      appConfigProvider.overrideWith((ref) => config),
      if (config.useFakeRepositories) ...fakeOverrides(),
    ],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const App(),
    ),
  );
}
```

`lib/main_dev.dart`:
```dart
import 'package:liaison_app/bootstrap.dart';
import 'package:liaison_app/core/config/flavor.dart';

Future<void> main() => bootstrap(Flavor.dev);
```

`lib/main_prod.dart`:
```dart
import 'package:liaison_app/bootstrap.dart';
import 'package:liaison_app/core/config/flavor.dart';

Future<void> main() => bootstrap(Flavor.prod);
```

- [ ] **Step 10: Firebase 설정 파일 자리 마련**

`.gitignore`에 추가:
```
# Firebase 설정 파일 (환경별로 각자 받아서 넣는다)
android/app/src/dev/google-services.json
android/app/src/prod/google-services.json
ios/Runner/Firebase/dev/GoogleService-Info.plist
ios/Runner/Firebase/prod/GoogleService-Info.plist
```

네 폴더에 각각 `README.md`를 만든다. 내용은 폴더에 맞게 파일명만 바꾼다.

`android/app/src/dev/README.md`:
```markdown
# Firebase 설정 파일 위치 (Android · dev)

Firebase 콘솔의 **dev 프로젝트**에서 받은 `google-services.json`을 이 폴더에 둔다.
git에는 올리지 않는다 (`.gitignore`에 등록됨).

파일이 들어오면 `android/app/build.gradle.kts`에 `com.google.gms.google-services` 플러그인을
적용하고 `firebase_core`, `firebase_messaging` 패키지를 추가한다.
설정 절차는 `docs/ARCHITECTURE.md`의 "Firebase" 항목 참고.
```

`android/app/src/prod/README.md`: 위와 같고 `dev` → `prod`.

`ios/Runner/Firebase/dev/README.md`:
```markdown
# Firebase 설정 파일 위치 (iOS · dev)

Firebase 콘솔의 **dev 프로젝트**에서 받은 `GoogleService-Info.plist`를 이 폴더에 둔다.
git에는 올리지 않는다 (`.gitignore`에 등록됨).

configuration(dev/prod)에 맞는 파일을 빌드 시 복사하는 Build Phase 스크립트는
`flutterfire configure --ios-build-config` 명령이 만든다.
설정 절차는 `docs/ARCHITECTURE.md`의 "Firebase" 항목 참고.
```

`ios/Runner/Firebase/prod/README.md`: 위와 같고 `dev` → `prod`.

- [ ] **Step 11: analyze와 dev flavor 빌드 확인**

Run:
```bash
fvm dart format lib test
fvm flutter analyze
fvm flutter build apk --debug --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
```
Expected: `No issues found!`, APK 빌드 성공 (`build/app/outputs/flutter-apk/app-dev-debug.apk`). 첫 빌드는 gradle 다운로드로 수 분 걸린다.

iOS를 처리한 머신이라면 추가로:
```bash
fvm flutter build ios --debug --no-codesign --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
```
Expected: 빌드 성공. CocoaPods 관련 에러는 `cd ios && pod install && cd ..` 후 재시도.

- [ ] **Step 12: 커밋**

```bash
git add -A
git commit -m "chore: dev/prod flavor와 진입점, AppConfig 추가"
```

---

### Task 4: core 인프라 (에러, 저장소, 네트워크, 알림 자리)

**Files:**
- Create: `lib/core/error/app_exception.dart`, `lib/core/error/dio_exception_mapper.dart`, `lib/core/storage/token_storage.dart`, `lib/core/storage/token_storage_provider.dart`, `lib/core/network/auth_interceptor.dart`, `lib/core/network/dio_provider.dart`, `lib/core/notification/notification_service.dart`, `lib/core/notification/notification_service_provider.dart`
- Modify: `lib/bootstrap.dart`
- Test: `test/core/error/dio_exception_mapper_test.dart`, `test/core/network/auth_interceptor_test.dart`

**Interfaces:**
- Consumes: `appConfigProvider`, `AppConfig`, `Flavor` (Task 3)
- Produces:
  - `sealed class AppException implements Exception { final String message; }` 와 하위 `NetworkException`, `UnauthorizedException`, `ServerException(statusCode)`, `UnknownException(message)`
  - `AppException mapDioException(DioException e)`
  - `abstract interface class TokenStorage { Future<String?> readAccessToken(); Future<void> writeAccessToken(String token); Future<void> clear(); }`, 구현 `SecureTokenStorage`, `InMemoryTokenStorage`
  - `tokenStorageProvider`, `dioProvider`, `notificationServiceProvider`
  - `abstract interface class NotificationService { Future<void> initialize(); }`

- [ ] **Step 1: 실패하는 테스트 작성** — `test/core/error/dio_exception_mapper_test.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liaison_app/core/error/app_exception.dart';
import 'package:liaison_app/core/error/dio_exception_mapper.dart';

DioException _dio(DioExceptionType type, {int? status}) {
  final options = RequestOptions(path: '/test');
  return DioException(
    requestOptions: options,
    type: type,
    response: status == null
        ? null
        : Response<void>(requestOptions: options, statusCode: status),
  );
}

void main() {
  group('mapDioException', () {
    test('타임아웃과 연결 실패는 NetworkException', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]) {
        expect(mapDioException(_dio(type)), isA<NetworkException>());
      }
    });

    test('401 응답은 UnauthorizedException', () {
      final result = mapDioException(
        _dio(DioExceptionType.badResponse, status: 401),
      );
      expect(result, isA<UnauthorizedException>());
    });

    test('그 외 에러 응답은 상태 코드를 담은 ServerException', () {
      final result = mapDioException(
        _dio(DioExceptionType.badResponse, status: 500),
      );
      expect(result, isA<ServerException>());
      expect((result as ServerException).statusCode, 500);
    });

    test('취소·인증서·알 수 없음은 UnknownException', () {
      for (final type in [
        DioExceptionType.cancel,
        DioExceptionType.badCertificate,
        DioExceptionType.unknown,
      ]) {
        expect(mapDioException(_dio(type)), isA<UnknownException>());
      }
    });
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `fvm flutter test test/core/error/dio_exception_mapper_test.dart`
Expected: 컴파일 에러 (파일 없음)

- [ ] **Step 3: AppException과 매퍼 구현**

`lib/core/error/app_exception.dart`:
```dart
/// 앱 전체에서 쓰는 예외. 화면은 이 타입만 본다.
///
/// 세분화는 실제 화면이 구분해서 보여줘야 할 때 추가한다.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// 네트워크 연결 실패, 타임아웃.
final class NetworkException extends AppException {
  const NetworkException() : super('네트워크에 연결할 수 없습니다');
}

/// 인증 만료 또는 미인증 (HTTP 401).
final class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('다시 로그인해 주세요');
}

/// 서버가 에러 상태 코드로 응답.
final class ServerException extends AppException {
  const ServerException({required this.statusCode})
      : super('서버 오류가 발생했습니다 ($statusCode)');

  final int statusCode;
}

/// 분류되지 않은 오류.
final class UnknownException extends AppException {
  const UnknownException([String? message])
      : super(message ?? '알 수 없는 오류가 발생했습니다');
}
```

`lib/core/error/dio_exception_mapper.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:liaison_app/core/error/app_exception.dart';

/// dio 예외를 [AppException]으로 바꾼다. Repository 구현체에서 호출한다.
AppException mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode;
      if (status == 401) return const UnauthorizedException();
      return ServerException(statusCode: status ?? -1);
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return UnknownException(e.message);
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `fvm flutter test test/core/error/dio_exception_mapper_test.dart`
Expected: `All tests passed!`

- [ ] **Step 5: 실패하는 테스트 작성** — `test/core/network/auth_interceptor_test.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liaison_app/core/network/auth_interceptor.dart';
import 'package:liaison_app/core/storage/token_storage.dart';

void main() {
  group('AuthInterceptor', () {
    test('토큰이 있으면 Authorization 헤더를 붙인다', () async {
      final storage = InMemoryTokenStorage();
      await storage.writeAccessToken('abc123');
      final interceptor = AuthInterceptor(storage);
      final options = RequestOptions(path: '/me');

      await interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers['Authorization'], 'Bearer abc123');
    });

    test('토큰이 없으면 헤더를 붙이지 않는다', () async {
      final interceptor = AuthInterceptor(InMemoryTokenStorage());
      final options = RequestOptions(path: '/me');

      await interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('InMemoryTokenStorage', () {
    test('clear 후에는 null을 돌려준다', () async {
      final storage = InMemoryTokenStorage();
      await storage.writeAccessToken('t');
      await storage.clear();

      expect(await storage.readAccessToken(), isNull);
    });
  });
}
```

- [ ] **Step 6: 실패 확인**

Run: `fvm flutter test test/core/network/auth_interceptor_test.dart`
Expected: 컴파일 에러

- [ ] **Step 7: TokenStorage와 AuthInterceptor 구현**

`lib/core/storage/token_storage.dart`:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 액세스 토큰 저장소. 인증 방식이 확정되면 리프레시 토큰 메서드를 추가한다.
abstract interface class TokenStorage {
  Future<String?> readAccessToken();
  Future<void> writeAccessToken(String token);
  Future<void> clear();
}

/// 기기 보안 저장소(Keychain / Keystore)에 저장한다.
class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage(this._storage);

  static const _accessTokenKey = 'access_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<void> writeAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _accessTokenKey);
}

/// 테스트와 가짜 모드에서 쓴다.
class InMemoryTokenStorage implements TokenStorage {
  String? _accessToken;

  @override
  Future<String?> readAccessToken() async => _accessToken;

  @override
  Future<void> writeAccessToken(String token) async => _accessToken = token;

  @override
  Future<void> clear() async => _accessToken = null;
}
```

`lib/core/storage/token_storage_provider.dart`:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:liaison_app/core/storage/token_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_storage_provider.g.dart';

@riverpod
TokenStorage tokenStorage(Ref ref) {
  return const SecureTokenStorage(FlutterSecureStorage());
}
```

`lib/core/network/auth_interceptor.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:liaison_app/core/storage/token_storage.dart';

/// 저장된 액세스 토큰을 모든 요청의 Authorization 헤더에 붙인다.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

- [ ] **Step 8: 테스트 통과 확인**

Run: `fvm flutter test test/core/network/auth_interceptor_test.dart`
Expected: `All tests passed!`

- [ ] **Step 9: dio Provider와 알림 자리 작성**

`lib/core/network/dio_provider.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:liaison_app/core/config/app_config_provider.dart';
import 'package:liaison_app/core/config/flavor.dart';
import 'package:liaison_app/core/network/auth_interceptor.dart';
import 'package:liaison_app/core/storage/token_storage_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

/// 앱 전체가 공유하는 HTTP 클라이언트.
@riverpod
Dio dio(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.interceptors.add(AuthInterceptor(ref.watch(tokenStorageProvider)));
  if (config.flavor == Flavor.dev) {
    dio.interceptors.add(LogInterceptor(responseBody: true));
  }
  return dio;
}
```

`lib/core/notification/notification_service.dart`:
```dart
/// 푸시 알림 초기화 지점.
///
/// Firebase 설정 파일과 firebase_messaging 패키지가 들어오면
/// FCM 토큰 등록, 포그라운드 알림 표시를 담당하는 구현체로 교체한다.
abstract interface class NotificationService {
  Future<void> initialize();
}

/// Firebase 연동 전까지 쓰는 빈 구현.
class NoopNotificationService implements NotificationService {
  const NoopNotificationService();

  @override
  Future<void> initialize() async {}
}
```

`lib/core/notification/notification_service_provider.dart`:
```dart
import 'package:liaison_app/core/notification/notification_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service_provider.g.dart';

@riverpod
NotificationService notificationService(Ref ref) {
  return const NoopNotificationService();
}
```

- [ ] **Step 10: bootstrap에서 알림 초기화 호출**

`lib/bootstrap.dart`의 `final container = ProviderContainer(...)` 다음, `runApp` 앞에 추가:

```dart
  await container.read(notificationServiceProvider).initialize();
```

import 추가:
```dart
import 'package:liaison_app/core/notification/notification_service_provider.dart';
```

- [ ] **Step 11: 코드 생성, analyze, 전체 테스트**

Run: `fvm dart run build_runner build --delete-conflicting-outputs && fvm dart format lib test && fvm flutter analyze && fvm flutter test`
Expected: `No issues found!`, 모든 테스트 통과

- [ ] **Step 12: 커밋**

```bash
git add -A
git commit -m "feat: 에러 타입, 토큰 저장소, dio 클라이언트, 알림 초기화 자리 추가"
```

---

### Task 5: 레퍼런스 feature `example`과 라우터

**Files:**
- Create: `lib/features/example/domain/model/example_item.dart`, `lib/features/example/domain/example_repository.dart`, `lib/features/example/data/dto/example_item_dto.dart`, `lib/features/example/data/example_api.dart`, `lib/features/example/data/example_repository_impl.dart`, `lib/features/example/data/example_repository_fake.dart`, `lib/features/example/example_di.dart`, `lib/features/example/presentation/example_list_provider.dart`, `lib/features/example/presentation/example_screen.dart`, `lib/app/router/app_router.dart`
- Modify: `lib/app/app.dart`, `lib/app/fake_overrides.dart`
- Test: `test/features/example/data/example_item_dto_test.dart`, `test/features/example/data/example_repository_impl_test.dart`, `test/features/example/presentation/example_list_provider_test.dart`, `test/features/example/presentation/example_screen_test.dart`

**Interfaces:**
- Consumes: `dioProvider`, `mapDioException`, `AppException` (Task 4), `fakeOverrides()` (Task 3)
- Produces:
  - `class ExampleItem { String id; String title; }` (freezed)
  - `abstract interface class ExampleRepository { Future<List<ExampleItem>> fetchItems(); }`
  - `class ExampleItemDto` + `extension ExampleItemDtoMapper on ExampleItemDto { ExampleItem toDomain(); }`
  - `class ExampleApi { ExampleApi(Dio dio); Future<List<ExampleItemDto>> fetchItems(); }`
  - `exampleRepositoryProvider`, `List<Override> exampleFakeOverrides()` in `example_di.dart`
  - `exampleListProvider` (`AsyncNotifierProvider<ExampleList, List<ExampleItem>>`), `ExampleList.refresh()`
  - `routerProvider` (`Provider<GoRouter>`), 경로 `/example`

- [ ] **Step 1: 실패하는 테스트 작성** — `test/features/example/data/example_item_dto_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:liaison_app/features/example/data/dto/example_item_dto.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';

void main() {
  group('ExampleItemDto', () {
    test('JSON에서 읽는다', () {
      final dto = ExampleItemDto.fromJson({'id': '1', 'title': '첫 항목'});

      expect(dto.id, '1');
      expect(dto.title, '첫 항목');
    });

    test('도메인 모델로 변환한다', () {
      const dto = ExampleItemDto(id: '1', title: '첫 항목');

      expect(dto.toDomain(), const ExampleItem(id: '1', title: '첫 항목'));
    });
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `fvm flutter test test/features/example/data/example_item_dto_test.dart`
Expected: 컴파일 에러

- [ ] **Step 3: domain 모델, 인터페이스, DTO 구현**

`lib/features/example/domain/model/example_item.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'example_item.freezed.dart';

/// 화면이 쓰는 모델. 서버 응답 형태(DTO)와 분리한다.
@freezed
abstract class ExampleItem with _$ExampleItem {
  const factory ExampleItem({
    required String id,
    required String title,
  }) = _ExampleItem;
}
```

`lib/features/example/domain/example_repository.dart`:
```dart
import 'package:liaison_app/features/example/domain/model/example_item.dart';

/// 실패 시 [AppException]의 하위 타입을 던진다.
abstract interface class ExampleRepository {
  Future<List<ExampleItem>> fetchItems();
}
```

`lib/features/example/data/dto/example_item_dto.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';

part 'example_item_dto.freezed.dart';
part 'example_item_dto.g.dart';

/// 서버 JSON을 그대로 받는 클래스. 필드명은 서버 스펙을 따른다.
@freezed
abstract class ExampleItemDto with _$ExampleItemDto {
  const factory ExampleItemDto({
    required String id,
    required String title,
  }) = _ExampleItemDto;

  factory ExampleItemDto.fromJson(Map<String, dynamic> json) =>
      _$ExampleItemDtoFromJson(json);
}

extension ExampleItemDtoMapper on ExampleItemDto {
  ExampleItem toDomain() => ExampleItem(id: id, title: title);
}
```

- [ ] **Step 4: 코드 생성 후 테스트 통과 확인**

Run: `fvm dart run build_runner build --delete-conflicting-outputs && fvm flutter test test/features/example/data/example_item_dto_test.dart`
Expected: `All tests passed!`

- [ ] **Step 5: 실패하는 테스트 작성** — `test/features/example/data/example_repository_impl_test.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liaison_app/core/error/app_exception.dart';
import 'package:liaison_app/features/example/data/dto/example_item_dto.dart';
import 'package:liaison_app/features/example/data/example_api.dart';
import 'package:liaison_app/features/example/data/example_repository_impl.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';
import 'package:mocktail/mocktail.dart';

class _MockExampleApi extends Mock implements ExampleApi {}

void main() {
  late _MockExampleApi api;
  late ExampleRepositoryImpl repository;

  setUp(() {
    api = _MockExampleApi();
    repository = ExampleRepositoryImpl(api);
  });

  test('API 응답을 도메인 모델 목록으로 바꾼다', () async {
    when(api.fetchItems).thenAnswer(
      (_) async => const [ExampleItemDto(id: '1', title: 'A')],
    );

    final items = await repository.fetchItems();

    expect(items, const [ExampleItem(id: '1', title: 'A')]);
  });

  test('DioException은 AppException으로 바뀐다', () async {
    when(api.fetchItems).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/examples'),
        type: DioExceptionType.connectionTimeout,
      ),
    );

    expect(repository.fetchItems, throwsA(isA<NetworkException>()));
  });
}
```

- [ ] **Step 6: 실패 확인**

Run: `fvm flutter test test/features/example/data/example_repository_impl_test.dart`
Expected: 컴파일 에러

- [ ] **Step 7: API, Repository 구현체, 가짜 구현, DI 작성**

`lib/features/example/data/example_api.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:liaison_app/features/example/data/dto/example_item_dto.dart';

/// 서버 호출만 담당한다. 예외 변환은 Repository 구현체가 한다.
class ExampleApi {
  ExampleApi(this._dio);

  final Dio _dio;

  Future<List<ExampleItemDto>> fetchItems() async {
    final response = await _dio.get<List<dynamic>>('/examples');
    final body = response.data ?? const [];
    return body
        .map((e) => ExampleItemDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
```

`lib/features/example/data/example_repository_impl.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:liaison_app/core/error/dio_exception_mapper.dart';
import 'package:liaison_app/features/example/data/dto/example_item_dto.dart';
import 'package:liaison_app/features/example/data/example_api.dart';
import 'package:liaison_app/features/example/domain/example_repository.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';

class ExampleRepositoryImpl implements ExampleRepository {
  ExampleRepositoryImpl(this._api);

  final ExampleApi _api;

  @override
  Future<List<ExampleItem>> fetchItems() async {
    try {
      final dtos = await _api.fetchItems();
      return dtos.map((dto) => dto.toDomain()).toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
```

`lib/features/example/data/example_repository_fake.dart`:
```dart
import 'package:liaison_app/features/example/domain/example_repository.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';

/// 서버 없이 화면을 개발할 때 쓴다. 짧은 지연으로 로딩 상태를 볼 수 있게 한다.
class ExampleRepositoryFake implements ExampleRepository {
  const ExampleRepositoryFake();

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
```

`lib/features/example/example_di.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liaison_app/core/network/dio_provider.dart';
import 'package:liaison_app/features/example/data/example_api.dart';
import 'package:liaison_app/features/example/data/example_repository_fake.dart';
import 'package:liaison_app/features/example/data/example_repository_impl.dart';
import 'package:liaison_app/features/example/domain/example_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'example_di.g.dart';

/// 이 feature의 의존성 조립. data와 domain을 동시에 import할 수 있는 유일한 파일.
@riverpod
ExampleRepository exampleRepository(Ref ref) {
  return ExampleRepositoryImpl(ExampleApi(ref.watch(dioProvider)));
}

/// 서버 없이 실행할 때 적용하는 override. `app/fake_overrides.dart`가 모은다.
List<Override> exampleFakeOverrides() {
  return [
    exampleRepositoryProvider.overrideWith((ref) => const ExampleRepositoryFake()),
  ];
}
```

- [ ] **Step 8: 코드 생성 후 테스트 통과 확인**

Run: `fvm dart run build_runner build --delete-conflicting-outputs && fvm flutter test test/features/example/data/`
Expected: `All tests passed!`

- [ ] **Step 9: 실패하는 테스트 작성** — `test/features/example/presentation/example_list_provider_test.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liaison_app/core/error/app_exception.dart';
import 'package:liaison_app/features/example/domain/example_repository.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';
import 'package:liaison_app/features/example/example_di.dart';
import 'package:liaison_app/features/example/presentation/example_list_provider.dart';

class _StubRepository implements ExampleRepository {
  _StubRepository(this._result);

  final Future<List<ExampleItem>> Function() _result;

  @override
  Future<List<ExampleItem>> fetchItems() => _result();
}

void main() {
  test('Repository 결과를 상태로 내놓는다', () async {
    final container = ProviderContainer.test(
      overrides: [
        exampleRepositoryProvider.overrideWith(
          (ref) => _StubRepository(
            () async => const [ExampleItem(id: '1', title: 'A')],
          ),
        ),
      ],
    );

    final items = await container.read(exampleListProvider.future);

    expect(items, const [ExampleItem(id: '1', title: 'A')]);
  });

  test('Repository가 던진 예외는 AsyncError로 흘러간다', () async {
    final container = ProviderContainer.test(
      overrides: [
        exampleRepositoryProvider.overrideWith(
          (ref) => _StubRepository(() => throw const NetworkException()),
        ),
      ],
    );

    await expectLater(
      container.read(exampleListProvider.future),
      throwsA(isA<NetworkException>()),
    );
    expect(container.read(exampleListProvider), isA<AsyncError<List<ExampleItem>>>());
  });
}
```

- [ ] **Step 10: 실패 확인**

Run: `fvm flutter test test/features/example/presentation/example_list_provider_test.dart`
Expected: 컴파일 에러

- [ ] **Step 11: Provider 구현**

`lib/features/example/presentation/example_list_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';
import 'package:liaison_app/features/example/example_di.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'example_list_provider.g.dart';

/// 서버 데이터를 다루는 상태는 AsyncNotifier로 만든다.
/// 예외는 삼키지 않고 AsyncError로 흘려보낸다. 화면이 표시를 결정한다.
@riverpod
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
```

- [ ] **Step 12: 코드 생성 후 테스트 통과 확인**

Run: `fvm dart run build_runner build --delete-conflicting-outputs && fvm flutter test test/features/example/presentation/example_list_provider_test.dart`
Expected: `All tests passed!`

- [ ] **Step 13: 실패하는 위젯 테스트 작성** — `test/features/example/presentation/example_screen_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liaison_app/core/error/app_exception.dart';
import 'package:liaison_app/features/example/domain/example_repository.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';
import 'package:liaison_app/features/example/example_di.dart';
import 'package:liaison_app/features/example/presentation/example_screen.dart';

class _StubRepository implements ExampleRepository {
  _StubRepository(this._result);

  final Future<List<ExampleItem>> Function() _result;

  @override
  Future<List<ExampleItem>> fetchItems() => _result();
}

Widget _app(ExampleRepository repository) {
  return ProviderScope(
    overrides: [exampleRepositoryProvider.overrideWith((ref) => repository)],
    child: const MaterialApp(home: ExampleScreen()),
  );
}

void main() {
  testWidgets('항목 목록을 보여준다', (tester) async {
    await tester.pumpWidget(
      _app(_StubRepository(() async => const [ExampleItem(id: '1', title: '첫 항목')])),
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
}
```

- [ ] **Step 14: 실패 확인**

Run: `fvm flutter test test/features/example/presentation/example_screen_test.dart`
Expected: 컴파일 에러

- [ ] **Step 15: 화면 구현**

`lib/features/example/presentation/example_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liaison_app/core/error/app_exception.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';
import 'package:liaison_app/features/example/presentation/example_list_provider.dart';

/// 레퍼런스 화면. 스타일은 입히지 않는다.
/// 로딩 · 에러 · 빈 목록 · 목록 네 가지 상태를 모두 다룬다.
class ExampleScreen extends ConsumerWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(exampleListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: switch (items) {
        AsyncData(:final value) => _ItemList(items: value),
        AsyncError(:final error) => _ErrorView(
            error: error,
            onRetry: () => ref.read(exampleListProvider.notifier).refresh(),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({required this.items});

  final List<ExampleItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('항목이 없습니다'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ListTile(title: Text(items[index].title)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = switch (error) {
      AppException(:final message) => message,
      _ => '알 수 없는 오류가 발생했습니다',
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 8),
          FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
```

- [ ] **Step 16: 위젯 테스트 통과 확인**

Run: `fvm flutter test test/features/example/presentation/example_screen_test.dart`
Expected: `All tests passed!`

- [ ] **Step 17: 라우터와 App 연결, fake override 등록**

`lib/app/router/app_router.dart`:
```dart
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
```

`lib/app/app.dart` 전체 교체:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liaison_app/app/router/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Liaison',
      routerConfig: ref.watch(routerProvider),
    );
  }
}
```

`lib/app/fake_overrides.dart` 전체 교체:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liaison_app/features/example/example_di.dart';

/// 서버 없이 앱을 띄울 때 적용하는 override 목록.
///
/// 각 feature는 `<feature>_di.dart`에 자기 가짜 override 목록을 두고,
/// 여기서 그것들을 모은다. 새 feature를 만들면 이 목록에 추가한다.
List<Override> fakeOverrides() {
  return [
    ...exampleFakeOverrides(),
  ];
}
```

- [ ] **Step 18: 코드 생성, analyze, 전체 테스트, 앱 실행 확인**

Run: `fvm dart run build_runner build --delete-conflicting-outputs && fvm dart format lib test && fvm flutter analyze && fvm flutter test`
Expected: `No issues found!`, 모든 테스트 통과

에뮬레이터나 기기가 연결되어 있으면:
```bash
fvm flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
```
Expected: 0.3초 로딩 후 가짜 항목 3개가 보인다. 기기가 없으면 Task 3 Step 11의 APK 빌드 명령으로 빌드만 확인한다.

- [ ] **Step 19: 커밋**

```bash
git add -A
git commit -m "feat: 레퍼런스 feature example과 라우터 추가"
```

---

### Task 6: 계층 규칙 테스트

**Files:**
- Test: `test/architecture_test.dart`

**Interfaces:**
- Consumes: `lib/` 전체 파일 구조 (Task 3~5)
- Produces: 규칙 위반 시 실패하는 테스트. CI의 `flutter test`에 포함된다.

- [ ] **Step 1: 테스트 작성** — `test/architecture_test.dart`

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// lib/ 아래 Dart 파일의 import 문으로 계층 규칙을 검사한다.
/// 규칙은 docs/ARCHITECTURE.md와 같아야 한다.
void main() {
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.endsWith('.g.dart'))
      .where((f) => !f.path.endsWith('.freezed.dart'))
      .toList();

  final importPattern = RegExp(r'''^import\s+['"]([^'"]+)['"]''', multiLine: true);
  final featurePattern = RegExp(r'lib/features/([^/]+)/');

  List<String> importsOf(File file) =>
      importPattern.allMatches(file.readAsStringSync()).map((m) => m.group(1)!).toList();

  test('상대 import를 쓰지 않는다', () {
    for (final file in files) {
      for (final import in importsOf(file)) {
        expect(
          import.startsWith('package:') || import.startsWith('dart:'),
          isTrue,
          reason: '${file.path}: 상대 import "$import"는 금지. package: 경로를 쓴다',
        );
      }
    }
  });

  test('domain은 Flutter, dio, riverpod을 import하지 않는다', () {
    const forbidden = [
      'package:flutter/',
      'package:dio/',
      'package:flutter_riverpod/',
      'package:riverpod_annotation/',
      'package:riverpod/',
    ];
    for (final file in files.where((f) => f.path.contains('/domain/'))) {
      for (final import in importsOf(file)) {
        expect(
          forbidden.any(import.startsWith),
          isFalse,
          reason: '${file.path}: domain에서 "$import" import 금지',
        );
      }
    }
  });

  test('presentation은 data를 import하지 않는다', () {
    for (final file in files.where((f) => f.path.contains('/presentation/'))) {
      for (final import in importsOf(file)) {
        expect(
          import.contains('/data/'),
          isFalse,
          reason: '${file.path}: presentation에서 data import 금지. '
              '<feature>_di.dart를 통해 Repository Provider를 쓴다',
        );
      }
    }
  });

  test('data는 presentation을 import하지 않는다', () {
    for (final file in files.where((f) => f.path.contains('/data/'))) {
      for (final import in importsOf(file)) {
        expect(
          import.contains('/presentation/'),
          isFalse,
          reason: '${file.path}: data에서 presentation import 금지',
        );
      }
    }
  });

  test('feature끼리 import하지 않는다', () {
    for (final file in files) {
      final owner = featurePattern.firstMatch(file.path)?.group(1);
      if (owner == null) continue;
      for (final import in importsOf(file)) {
        final target = RegExp(r'features/([^/]+)/').firstMatch(import)?.group(1);
        if (target == null) continue;
        expect(
          target,
          owner,
          reason: '${file.path}: 다른 feature "$target" import 금지. 공유가 필요하면 shared/로 올린다',
        );
      }
    }
  });

  test('features와 shared에서 Platform 분기를 쓰지 않는다', () {
    final platformPattern = RegExp(r'\bPlatform\.(is[A-Z]\w*|operatingSystem)');
    final targets = files.where(
      (f) => f.path.contains('lib/features/') || f.path.contains('lib/shared/'),
    );
    for (final file in targets) {
      expect(
        platformPattern.hasMatch(file.readAsStringSync()),
        isFalse,
        reason: '${file.path}: 플랫폼 분기는 core/ 인터페이스 뒤에 숨긴다',
      );
    }
  });
}
```

- [ ] **Step 2: 통과 확인**

Run: `fvm flutter test test/architecture_test.dart`
Expected: 6개 테스트 모두 통과

- [ ] **Step 3: 규칙이 실제로 잡히는지 확인 (일시적 위반 삽입)**

`lib/features/example/presentation/example_screen.dart` 맨 위에 임시로 한 줄 추가:
```dart
import 'package:liaison_app/features/example/data/example_api.dart';
```

Run: `fvm flutter test test/architecture_test.dart`
Expected: "presentation은 data를 import하지 않는다" 테스트가 실패하고 reason에 파일 경로가 나온다.

확인 후 그 줄을 삭제하고 다시 실행해 통과를 확인한다.

- [ ] **Step 4: 커밋**

```bash
git add test/architecture_test.dart
git commit -m "test: 계층 규칙을 검사하는 architecture test 추가"
```

---

### Task 7: 문서

**Files:**
- Create: `docs/ARCHITECTURE.md`, `docs/SETUP.md`, `lib/features/README.md`
- Modify: `README.md`, `.github/PULL_REQUEST_TEMPLATE.md`

**Interfaces:**
- Consumes: Task 1~6의 결과 전부. 문서의 명령과 경로는 실제 파일과 일치해야 한다.

- [ ] **Step 1: docs/ARCHITECTURE.md 작성**

````markdown
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
    theme/                         # 디자인 확정 후 색·타이포 토큰
  core/                            # 기능과 무관한 인프라
    config/                        # Flavor, AppConfig (dart-define 값)
    error/                         # AppException, dio 예외 매핑
    network/                       # dio Provider, 인증 인터셉터
    storage/                       # 토큰 저장소
    notification/                  # 알림 초기화 (Firebase 연동 전엔 no-op)
  shared/                          # 두 개 이상의 feature가 쓰는 위젯·모델
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

## 에러 처리

- `core/error/app_exception.dart`의 `AppException`(sealed)만 화면에 도달한다. 종류: `NetworkException`, `UnauthorizedException`, `ServerException`, `UnknownException`.
- dio 예외는 Repository 구현체에서 `mapDioException`으로 변환한다. 화면은 `DioException`을 모른다.
- 전역 처리(토큰 만료 시 로그인 이동 등)는 `core/network/` 인터셉터와 `app/router/`의 redirect가 맡는다.

## 환경(flavor)

| | dev | prod |
| --- | --- | --- |
| 진입점 | `lib/main_dev.dart` | `lib/main_prod.dart` |
| 설정 | `env/dev.json` | `env/prod.json` |
| applicationId / Bundle ID | `com.liaison.app.dev` | `com.liaison.app` |

실행: `fvm flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json`

`env/*.json`에는 시크릿을 넣지 않는다. 값은 `AppConfig.fromEnvironment`에서 읽는다.

## Firebase

아직 연동하지 않았다. 연동 순서:

1. Firebase 콘솔에서 dev / prod 프로젝트를 만든다. Android 패키지명과 iOS Bundle ID는 위 표의 값.
2. 설정 파일을 각 위치에 둔다 (git 미추적): `android/app/src/{dev,prod}/google-services.json`, `ios/Runner/Firebase/{dev,prod}/GoogleService-Info.plist`
3. `fvm flutter pub add firebase_core firebase_messaging flutter_local_notifications`
4. Android: `android/app/build.gradle.kts`에 `com.google.gms.google-services` 플러그인 적용.
5. iOS: `flutterfire configure --ios-build-config` 로 configuration별 plist 복사 스크립트 생성. APNs 키 등록, Push capability 추가.
6. `core/notification/`의 `NoopNotificationService`를 FCM 구현체로 교체. 포그라운드 알림은 `flutter_local_notifications`로 표시.

## 후속 작업에서 쓸 패키지 후보

| 용도 | 후보 |
| --- | --- |
| 카메라 촬영·가이드 프레임 | `camera` + 커스텀 오버레이 |
| 권한 | `permission_handler` |
| 이미지 압축 | `flutter_image_compress` |
| 플랫폼별 권한 문구 | iOS `Info.plist`의 `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`; Android `CAMERA`, `POST_NOTIFICATIONS` |
````

- [ ] **Step 2: docs/SETUP.md 작성**

````markdown
# 개발 환경 세팅

macOS(Apple Silicon) 기준. 두 사람이 같은 절차를 따르도록 순서대로 진행한다.

## 1. 기본 도구

```bash
# Homebrew가 없으면 https://brew.sh 참고
brew install fvm cocoapods
brew install --cask android-studio   # 이미 있으면 생략
```

App Store에서 Xcode를 설치한 뒤:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

Android Studio를 한 번 실행해 SDK, 플랫폼 도구, 에뮬레이터를 설치한다.
`Settings > Languages & Frameworks > Android SDK > SDK Tools`에서 **Android SDK Command-line Tools**를 체크한다.

## 2. Flutter (fvm)

프로젝트를 클론한 뒤 루트에서:

```bash
fvm install          # .fvmrc의 버전을 받는다
fvm flutter doctor   # 빨간 X가 없어야 한다
```

앞으로 `flutter`, `dart` 명령은 항상 `fvm flutter`, `fvm dart`로 쓴다.
전역 Flutter를 따로 설치하지 않는다. 버전이 어긋나면 빌드 결과가 달라진다.

VS Code: fvm이 만든 `.vscode/settings.json`이 SDK 경로를 가리킨다. Flutter 확장만 설치하면 된다.
Android Studio: `Settings > Languages & Frameworks > Flutter`에서 SDK 경로를 `<프로젝트>/.fvm/flutter_sdk`로 지정한다.

## 3. Android 라이선스

```bash
fvm flutter doctor --android-licenses
```

## 4. 의존성과 코드 생성

```bash
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
```

생성 파일은 git에 들어 있으므로 클론 직후에는 생략해도 빌드된다. 모델이나 Provider를 고친 뒤에는 반드시 다시 돌린다.
계속 고치는 중이면 `fvm dart run build_runner watch --delete-conflicting-outputs`가 편하다.

## 5. 실행

```bash
# 에뮬레이터 또는 기기 확인
fvm flutter devices

# dev flavor 실행 (서버 없이 가짜 데이터)
fvm flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
```

iOS 시뮬레이터에서 처음 실행할 때 CocoaPods 에러가 나면:

```bash
cd ios && pod install && cd ..
```

## 6. 확인 명령

PR 올리기 전에 세 개 모두 통과해야 한다.

```bash
fvm flutter analyze
fvm flutter test
fvm dart format --set-exit-if-changed lib test
```

## 자주 겪는 문제

| 증상 | 해결 |
| --- | --- |
| `part 'xxx.g.dart'` 파일이 없다는 에러 | 4번의 build_runner 명령 실행 |
| `flutter run`이 `lib/main.dart`를 찾는다 | `-t lib/main_dev.dart`를 빠뜨림 |
| `--flavor` 없이 실행해서 gradle 에러 | `--flavor dev` 추가 |
| Xcode에서 `xcodebuild requires Xcode` | 1번의 `xcode-select` 명령 실행 |
````

- [ ] **Step 3: lib/features/README.md 작성**

````markdown
# 새 feature 만들기

`example/`을 복사해서 시작한다. 순서대로 하면 계층 규칙을 어길 일이 없다.

1. **폴더 복사**: `cp -r lib/features/example lib/features/<name>` 후 파일명과 클래스명의 `example`/`Example`을 `<name>`/`<Name>`으로 바꾼다. 생성 파일(`*.g.dart`, `*.freezed.dart`)은 지운다.
2. **domain/model**: 화면이 쓰는 모델을 freezed로 정의한다. Flutter, dio, riverpod import 금지.
3. **domain/<name>_repository.dart**: 인터페이스. 메서드는 도메인 모델만 주고받는다.
4. **data/dto**: 서버 JSON 형태 그대로. `toDomain()` 확장을 같이 둔다.
5. **data/<name>_api.dart**: dio 호출만.
6. **data/<name>_repository_impl.dart**: API 호출 + DTO 변환 + `mapDioException`.
7. **data/<name>_repository_fake.dart**: 서버 없이 쓸 가짜 데이터.
8. **<name>_di.dart**: `@riverpod <Name>Repository <name>Repository(Ref ref)`와 `<name>FakeOverrides()`.
9. **app/fake_overrides.dart**에 `...<name>FakeOverrides()` 추가.
10. **presentation/<name>_provider.dart**: `AsyncNotifier` 또는 `Notifier`.
11. **presentation/<name>_screen.dart**: 로딩 · 에러 · 빈 상태 · 데이터 네 가지를 모두 다룬다.
12. **app/router/app_router.dart**에 경로 추가.
13. **테스트**: `test/features/<name>/`에 DTO, Repository 구현체, Provider, 화면 테스트. `example`의 테스트를 복사해서 시작한다.
14. `fvm dart run build_runner build --delete-conflicting-outputs && fvm dart format lib test && fvm flutter analyze && fvm flutter test`

역할(학생/선생님/학부모)에 따라 화면이 다르면 `presentation/student/`, `presentation/teacher/`처럼 presentation 안에서만 나눈다. feature 자체를 역할별로 만들지 않는다.

`example/`은 실제 feature가 두 개 이상 생기면 삭제한다.
````

- [ ] **Step 4: README.md 갱신**

파일 전체를 아래로 바꾼다.

```markdown
# liaison-app

학원 숙제 알림장 앱 (학생 · 선생님 · 학부모). Flutter, Android + iOS.

## 시작하기

1. [개발 환경 세팅](docs/SETUP.md)
2. [아키텍처](docs/ARCHITECTURE.md)
3. [새 feature 만들기](lib/features/README.md)

```bash
fvm flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
```

## 📚 컨벤션

작업 전에 아래 문서를 확인해주세요.

- [커밋 컨벤션](COMMIT_CONVENTION.md)
- [브랜치 컨벤션](BRANCH_CONVENTION.md)
- [PR 템플릿](.github/PULL_REQUEST_TEMPLATE.md)
```

- [ ] **Step 5: PR 템플릿의 테스트 방법 항목 수정**

`.github/PULL_REQUEST_TEMPLATE.md`에서 `## 🧪 테스트 방법` 섹션을 아래로 교체한다.

```markdown
## 🧪 테스트 방법

<!-- 리뷰어가 이 변경을 어떻게 확인할 수 있는지 적어주세요 -->

- [ ] `fvm flutter analyze` 통과
- [ ] `fvm flutter test` 통과
-
```

- [ ] **Step 6: 문서의 명령이 실제로 동작하는지 확인**

Run:
```bash
fvm flutter analyze && fvm flutter test && fvm dart format --set-exit-if-changed lib test
```
Expected: 세 명령 모두 종료 코드 0. format이 실패하면 `fvm dart format lib test`로 정리 후 재실행.

- [ ] **Step 7: 커밋**

```bash
git add -A
git commit -m "docs: 아키텍처, 환경 세팅, feature 추가 가이드 작성"
```

---

### Task 8: CI 워크플로우

**Files:**
- Create: `.github/workflows/flutter-ci.yml`

**Interfaces:**
- Consumes: `.fvmrc` (Task 1), build_runner·analyze·test 명령 (Task 2~7)

- [ ] **Step 1: 워크플로우 작성** — `.github/workflows/flutter-ci.yml`

```yaml
name: Flutter CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Read Flutter version from .fvmrc
        id: fvmrc
        run: echo "version=$(jq -r .flutter .fvmrc)" >> "$GITHUB_OUTPUT"

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ steps.fvmrc.outputs.version }}
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Generate code
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Check generated files are committed
        run: |
          if ! git diff --exit-code; then
            echo "::error::생성 파일이 최신이 아닙니다. build_runner를 실행하고 결과를 커밋하세요."
            exit 1
          fi

      - name: Format
        run: dart format --set-exit-if-changed lib test

      - name: Analyze
        run: flutter analyze

      - name: Test
        run: flutter test
```

- [ ] **Step 2: YAML 문법 확인**

Run: `python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/flutter-ci.yml')); print('yaml ok')"`
Expected: `yaml ok`. PyYAML이 없으면 `ruby -ryaml -e "YAML.load_file('.github/workflows/flutter-ci.yml'); puts 'yaml ok'"`.

- [ ] **Step 3: 로컬에서 CI와 같은 순서로 실행**

Run:
```bash
fvm dart run build_runner build --delete-conflicting-outputs && git diff --exit-code && fvm dart format --set-exit-if-changed lib test && fvm flutter analyze && fvm flutter test
```
Expected: 모두 종료 코드 0. `git diff --exit-code`가 실패하면 생성 파일이 커밋되지 않은 것이므로 커밋한다.

- [ ] **Step 4: 커밋**

```bash
git add .github/workflows/flutter-ci.yml
git commit -m "ci: analyze·test·생성 파일 검사 워크플로우 추가"
```

- [ ] **Step 5: 푸시와 PR (사용자 확인 후)**

main은 PR로만 변경한다. 사용자에게 확인을 받은 뒤:

```bash
git push -u origin chore/flutter-project-setup
gh pr create --title "chore: Flutter 프로젝트 초기 설정" --body-file - <<'EOF'
## 📋 작업 내용

Flutter 프로젝트 뼈대를 만들었습니다. 버전 고정, 패키지, dev/prod flavor, lint, core 인프라, 레퍼런스 feature, 계층 규칙 테스트, 문서, CI.

## 🔍 주요 변경 사항

- fvm으로 Flutter 버전 고정, Android/iOS 프로젝트 생성
- Riverpod 3 · go_router · dio · freezed 4 · very_good_analysis 설정
- dev/prod flavor (`flutter_flavorizr`), `env/*.json`, `main_dev.dart` / `main_prod.dart`
- `core/`: AppException, dio 클라이언트, 토큰 저장소, 알림 초기화 자리
- `features/example/`: 레퍼런스 feature (계층 구조 · 가짜 Repository · 테스트)
- `test/architecture_test.dart`: 계층 규칙 검사
- `docs/ARCHITECTURE.md`, `docs/SETUP.md`, `lib/features/README.md`
- `.github/workflows/flutter-ci.yml`

## 🎨 디자인

- 시안: 없음 (디자인 확정 전. 화면 스타일 미적용)

## 🧪 테스트 방법

- [x] `fvm flutter analyze` 통과
- [x] `fvm flutter test` 통과
- `docs/SETUP.md` 순서대로 세팅 후 `fvm flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json`

## 🔗 관련 이슈

설계: `docs/superpowers/specs/2026-09-10-flutter-app-architecture-design.md`

🤖 Generated with [Claude Code](https://claude.com/claude-code)

https://claude.ai/code/session_018kbVx57rKzBt1bCroQiEsW
EOF
```

CI가 초록색인지 확인한다. iOS를 검증하지 못한 머신에서 작업했다면 PR 본문 "리뷰어에게"에 그 사실을 적는다.
