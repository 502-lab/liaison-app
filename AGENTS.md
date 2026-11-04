# AGENTS.md — liaison-app

AI 도구(Claude Code, Cursor, Copilot, Codex 등)와 사람 모두 작업 전에 읽습니다.

## 1. 공통 문서 (반드시 먼저)
`docs/common/`은 공통 문서 저장소 [502-lab/liaison-docs](https://github.com/502-lab/liaison-docs)를 연결한 git submodule입니다. 비어 있으면 `git submodule update --init`을 실행합니다.

- `docs/common/AI_RULES.md` — 절대 하지 않는 것, 반드시 하는 것
- `docs/common/GLOSSARY.md` — 표준어와 코드 이름
- `docs/common/CODE_CONVENTIONS.md` — 이름·API·시간·로그·테스트 규칙
- `docs/common/GIT_CONVENTIONS.md` — 커밋·브랜치·PR 규칙
- `docs/common/DOMAIN.md` — 도메인 모델 요약
- `docs/common/PRIVACY_RULES.md` — 개인정보 규칙

공통 문서를 고칠 때는 이 저장소가 아니라 liaison-docs에 PR을 올립니다.

## 2. 이 저장소
- **역할:** 학생·선생님·보호자용 Flutter 앱(역할별 화면). Android·iOS 모두 스토어로 배포합니다.
- **아키텍처:** `docs/ARCHITECTURE.md`(계층 규칙, Riverpod 규칙)를 따릅니다. 실행 방법은 README에 있습니다.
- **화면 기준:** 390×844
- **알림:** 채널은 일반·무음 두 가지이고 첫 배포 전에 확정합니다(Android 채널 중요도는 나중에 못 바꿈). iOS 무음은 `interruption-level: passive`. 푸시 본문에 개인정보를 넣지 않습니다.
- **원장·선생님 역할:** 30분 미사용 시 다시 로그인합니다(평소 로그인은 패스키). 학생 사진·API 응답을 디스크에 캐시하지 않고 메모리에만 둡니다. 토큰은 `flutter_secure_storage`에 둡니다.
- **분석·광고·오류 수집 SDK(Firebase Analytics, Crashlytics 등)를 넣지 않습니다.** FCM을 붙일 때 Analytics가 켜지지 않게 합니다.
- **커밋 전 비밀키 검사:** `git config core.hooksPath .githooks` (gitleaks 필요: `brew install gitleaks`). CI(Secret Scan)도 검사합니다.
- **공개 저장소입니다.** 실제 데이터·비밀값·`env/*.json`의 실제 키·법무 원문을 올리지 않습니다.
