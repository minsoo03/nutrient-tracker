#!/bin/bash
# ───────────────────────────────────────────
# push.sh — 변경된 코드를 GitHub에 올리는 스크립트
# 사용법: ./push.sh "커밋 메시지"
#         ./push.sh  (메시지 생략 시 자동으로 시간 기반 메시지 사용)
# ───────────────────────────────────────────

# 색상 설정
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 커밋 메시지 설정 (인자 없으면 자동 생성)
if [ -z "$1" ]; then
  COMMIT_MSG="update: $(date '+%Y-%m-%d %H:%M')"
else
  COMMIT_MSG="$1"
fi

echo -e "${YELLOW}📦 변경 사항 확인 중...${NC}"
git status --short

# 변경 사항이 없으면 종료
if [ -z "$(git status --porcelain)" ]; then
  echo -e "${GREEN}✅ 변경된 파일이 없어요. 이미 최신 상태입니다.${NC}"
  exit 0
fi

echo -e "\n${YELLOW}➕ 파일 추가 중...${NC}"
git add .

echo -e "${YELLOW}💾 커밋 중: \"$COMMIT_MSG\"${NC}"
git commit -m "$COMMIT_MSG"

echo -e "${YELLOW}🚀 GitHub에 push 중...${NC}"
git push origin main

if [ $? -eq 0 ]; then
  echo -e "\n${GREEN}✅ 성공적으로 push 완료!${NC}"
else
  echo -e "\n${RED}❌ Push 실패. 위 오류 메시지를 확인해주세요.${NC}"
  exit 1
fi
