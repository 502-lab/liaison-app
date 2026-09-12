# Firebase 설정 파일 위치 (iOS · prod)

Firebase 콘솔의 **prod 프로젝트**에서 받은 `GoogleService-Info.plist`를 이 폴더에 둔다.
git에는 올리지 않는다 (`.gitignore`에 등록됨).

configuration(dev/prod)에 맞는 파일을 빌드 시 복사하는 Build Phase 스크립트는
`flutterfire configure --ios-build-config` 명령이 만든다.
설정 절차는 `docs/ARCHITECTURE.md`의 "Firebase" 항목 참고.
