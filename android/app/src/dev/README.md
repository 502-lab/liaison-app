# Firebase 설정 파일 위치 (Android · dev)

Firebase 콘솔의 **dev 프로젝트**에서 받은 `google-services.json`을 이 폴더에 둔다.
git에는 올리지 않는다 (`.gitignore`에 등록됨).

파일이 들어오면 `android/app/build.gradle.kts`에 `com.google.gms.google-services` 플러그인을
적용하고 `firebase_core`, `firebase_messaging` 패키지를 추가한다.
설정 절차는 `docs/ARCHITECTURE.md`의 "Firebase" 항목 참고.
