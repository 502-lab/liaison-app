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
sudo gem install xcodeproj   # flutter_flavorizr의 iOS 처리기가 사용
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
fvm dart fix --apply   # lint가 제안하는 자동 수정 적용
```

## 자주 겪는 문제

| 증상 | 해결 |
| --- | --- |
| `part 'xxx.g.dart'` 파일이 없다는 에러 | 4번의 build_runner 명령 실행 |
| `flutter run`이 `lib/main.dart`를 찾는다 | `-t lib/main_dev.dart`를 빠뜨림 |
| `--flavor` 없이 실행해서 gradle 에러 | `--flavor dev` 추가 |
| Xcode에서 `xcodebuild requires Xcode` | 1번의 `xcode-select` 명령 실행 |
