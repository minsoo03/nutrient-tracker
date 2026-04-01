#!/bin/bash
# ───────────────────────────────────────────
# auto_push.sh — 파일 변경 감지 시 자동으로 GitHub에 push
# 필요 도구: fswatch (설치: brew install fswatch)
# 사용법: ./auto_push.sh
# 종료: Ctrl+C
# ───────────────────────────────────────────

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# fswatch 설치 여부 확인
if ! command -v fswatch &> /dev/null; then
  echo -e "${RED}❌ fswatch가 설치되어 있지 않아요.${NC}"
  echo -e "${YELLOW}아래 명령어로 설치해주세요:${NC}"
  echo -e "  brew install fswatch"
  exit 1
fi

# 현재 디렉토리 기준으로 감시
WATCH_DIR="$(pwd)"
echo -e "${CYAN}👁  자동 push 감시 시작: $WATCH_DIR${NC}"
echo -e "${YELLOW}파일이 저장될 때마다 자동으로 GitHub에 push됩니다.${NC}"
echo -e "종료하려면 ${RED}Ctrl+C${NC} 를 누르세요.\n"

# 마지막 push 시간 추적 (너무 자주 push 방지, 5초 쿨다운)
LAST_PUSH=0

fswatch -o --exclude='\.git' --exclude='\.DS_Store' "$WATCH_DIR" | while read -r NUM_CHANGES; do
  NOW=$(date +%s)
  DIFF=$((NOW - LAST_PUSH))

  # 5초 이내 재실행 방지
  if [ $DIFF -lt 5 ]; then
    continue
  fi

  LAST_PUSH=$NOW

  # 변경 사항이 있을 때만 push
  if [ -n "$(git status --porcelain)" ]; then
    COMMIT_MSG="auto: $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "\n${YELLOW}📁 변경 감지 → commit & push: \"$COMMIT_MSG\"${NC}"
    git add .
    git commit -m "$COMMIT_MSG" --quiet
    git push origin main --quiet

    if [ $? -eq 0 ]; then
      echo -e "${GREEN}✅ Push 완료 ($(date '+%H:%M:%S'))${NC}"
    else
      echo -e "${RED}❌ Push 실패. 네트워크 또는 권한을 확인해주세요.${NC}"
    fi
  fi
done
