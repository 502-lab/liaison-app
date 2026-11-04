#!/bin/sh
# 세션 시작 시 공통 문서(docs/common, liaison-docs 서브모듈)를 확인한다.
# 출력은 Claude Code 세션 맥락에 들어간다. 실패해도 세션을 막지 않는다(항상 exit 0).
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

if [ ! -f docs/common/AI_RULES.md ]; then
  git submodule update --init docs/common >/dev/null 2>&1
fi

if [ ! -f docs/common/AI_RULES.md ]; then
  echo "⚠ 공통 문서(docs/common)를 받지 못했습니다. 'git submodule update --init'을 실행한 뒤 작업하세요. 공통 규칙: https://github.com/502-lab/liaison-docs"
  exit 0
fi

pinned=$(git -C docs/common rev-parse HEAD 2>/dev/null)
latest=$(git ls-remote https://github.com/502-lab/liaison-docs.git refs/heads/main 2>/dev/null | cut -f1)
if [ -n "$latest" ] && [ "$pinned" != "$latest" ]; then
  echo "ℹ 이 저장소가 가리키는 공통 문서가 최신이 아닙니다. 최신 규칙은 https://github.com/502-lab/liaison-docs 에 있습니다. 반영하려면 Dependabot의 'docs/common' 갱신 PR을 병합하거나 'git submodule update --remote docs/common'을 실행하세요."
fi
exit 0
