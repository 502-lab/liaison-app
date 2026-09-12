# 개발 환경 세팅

macOS(Apple Silicon) 기준. 두 사람이 같은 절차를 따르도록 순서대로 진행한다.

## 1. 기본 도구

```bash
# Homebrew가 없으면 https://brew.sh 참고
brew tap leoafarias/fvm
brew install fvm cocoapods
brew install --cask android-studio   # 이미 있으면 생략
```

App Store에서 Xcode를 설치한 뒤:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

Xcode를 처음 열면 iOS 시뮬레이터 런타임을 내려받으라는 안내가 뜬다. 받아 둔다.

flavor를 다시 생성할 때만(`fvm dart run flutter_flavorizr`) 시스템 Ruby에 `xcodeproj` gem이 필요하다. 평소에는 필요 없다.

```bash
sudo gem install xcodeproj          # 또는 gem install --user-install xcodeproj
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

# prod flavor
fvm flutter run --flavor prod -t lib/main_prod.dart --dart-define-from-file=env/prod.json
```

`--flavor`, `-t`, `--dart-define-from-file` 세 가지는 항상 같은 flavor로 맞춘다.

**iOS**: 첫 빌드 때 `flutter`가 `pod install`을 자동으로 실행한다. 직접 실행해야 하면 `cd ios && pod install`.
Xcode에서 열 때는 `ios/Runner.xcworkspace`를 열고 scheme은 `dev` 또는 `prod`를 고른다.
기본 `Runner` scheme과 `Debug`/`Release` configuration은 지웠으므로 flavor 없이는 빌드되지 않는다 (Android와 같다).

**Android 에뮬레이터에서 로컬 서버 접속**: 에뮬레이터의 `localhost`는 호스트가 아니라 에뮬레이터 자신이다.
`env/dev.json`의 `API_BASE_URL`을 `http://10.0.2.2:8080`으로 바꾸고, http를 쓰려면 `android/app/src/dev/AndroidManifest.xml`에 `android:usesCleartextTraffic="true"`를 추가한다. 지금은 가짜 Repository 모드라 해당 없음.

## 6. 확인 명령

PR 올리기 전에 네 개 모두 통과해야 한다.

```bash
fvm flutter analyze
fvm dart analyze      # riverpod_lint는 이 명령에서만 실행된다
fvm flutter test
fvm dart format --set-exit-if-changed lib test
```

lint가 옛 생성자 형태 같은 자동 수정 가능한 경고를 내면 아래로 고친 뒤 위 세 명령을 다시 돌린다.

```bash
fvm dart fix --apply
```

## 자주 겪는 문제

| 증상 | 해결 |
| --- | --- |
| `part 'xxx.g.dart'` 파일이 없다는 에러 | 4번의 build_runner 명령 실행 |
| `flutter run`이 `lib/main.dart`를 찾는다 | `-t lib/main_dev.dart`를 빠뜨림 |
| `--flavor` 없이 실행해서 gradle 에러 | `--flavor dev` 추가 |
| 시작하자마자 `StateError` (FLAVOR / API_BASE_URL) | `--dart-define-from-file=env/<flavor>.json`을 진입점과 맞춰 넘겼는지 확인 |
| Xcode에서 `xcodebuild requires Xcode` | 1번의 `xcode-select` 명령 실행 |
| Xcode에서 scheme 목록에 `dev`/`prod`가 없다 | `Runner.xcodeproj`가 아니라 `Runner.xcworkspace`를 열었는지 확인 |
| `flutter run`이 iOS에서 `Runner` scheme을 찾는다 | `--flavor dev` 또는 `--flavor prod`를 빠뜨림 |
