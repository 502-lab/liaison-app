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

공통 규칙은 공통 문서 저장소 [liaison-docs](https://github.com/502-lab/liaison-docs)에 있습니다(이 저장소의 `docs/common/`). AI 도구는 `AGENTS.md`·`CLAUDE.md`를 통해 자동으로 읽습니다.

- [AI 작업 규칙](docs/common/AI_RULES.md)
- [용어집](docs/common/GLOSSARY.md)
- [코드·API 규칙](docs/common/CODE_CONVENTIONS.md)
- [커밋·브랜치·PR 규칙](docs/common/GIT_CONVENTIONS.md)
- [PR 템플릿](.github/PULL_REQUEST_TEMPLATE.md)

처음 받을 때는 `git clone --recursive`, 이미 받았다면 `git submodule update --init`을 실행합니다.
