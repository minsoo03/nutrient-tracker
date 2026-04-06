# GitHub 연결 가이드 (영양소 트래킹 앱)

## 순서 요약
1. GitHub에서 새 레포 만들기 (웹에서 직접)
2. 터미널에서 git 초기화 & 연결
3. 첫 push
4. 이후 코드 변경마다 push 방법

---

## 1단계 — GitHub에서 새 레포 만들기

1. [github.com](https://github.com) 로그인
2. 오른쪽 상단 **+** 버튼 클릭 → **New repository**
3. 아래처럼 설정:
   - **Repository name:** `nutrient-tracker` (또는 원하는 이름)
   - **Description:** 일일 영양소 & 장기 건강 트래킹 앱
   - **Visibility:** Private (비공개 권장)
   - **⚠️ "Add a README file" 체크 해제** (이미 로컬에 파일 있음)
4. **Create repository** 클릭
5. 생성 후 나오는 페이지에서 레포 주소 복사
   예: `https://github.com/your-username/nutrient-tracker.git`

---

## 2단계 — 터미널에서 git 초기화 & 연결

터미널(Terminal)을 열고 아래 명령어를 순서대로 실행하세요.

```bash
# 1. 프로젝트 폴더로 이동 (폴더 경로를 본인 경로로 변경)
cd ~/Documents/앱출시해보자/nutrient-tracker

# 2. git 초기화
git init

# 3. 기본 브랜치 이름을 main으로 설정
git branch -M main

# 4. GitHub 레포 연결 (your-username은 본인 GitHub 아이디로 변경)
git remote add origin https://github.com/your-username/nutrient-tracker.git

# 5. 스크립트 실행 권한 부여
chmod +x push.sh
chmod +x auto_push.sh
```

---

## 3단계 — 첫 번째 push

```bash
# 모든 파일 추가
git add .

# 첫 커밋
git commit -m "init: 프로젝트 초기 설정"

# GitHub에 올리기
git push -u origin main
```

> 처음 push 시 GitHub 로그인을 요청할 수 있어요.
> **Username:** GitHub 아이디
> **Password:** GitHub 비밀번호 대신 **Personal Access Token** 입력
> (토큰 생성: GitHub → Settings → Developer settings → Personal access tokens → Generate new token)

---

## 이후 — 코드 수정할 때마다 push하는 2가지 방법

### 방법 A: 수동 push (권장 — 안전)

```bash
# push.sh 실행 (메시지 직접 입력)
./push.sh "feat: 음식 검색 화면 추가"

# 또는 메시지 생략 (자동으로 날짜/시간 커밋 메시지 생성)
./push.sh
```

### 방법 B: 자동 push (파일 저장할 때마다 자동)

```bash
# fswatch 설치 (한 번만)
brew install fswatch

# 자동 감시 시작 (터미널 탭 하나 켜두기)
./auto_push.sh
```

> ⚠️ 자동 push는 편리하지만 실수로 깨진 코드도 올라갈 수 있어요.
> 처음엔 방법 A(수동)를 사용하다가 익숙해지면 B로 전환하는 걸 권장해요.

---

## 자주 쓰는 git 명령어

| 명령어 | 설명 |
|--------|------|
| `git status` | 변경된 파일 목록 보기 |
| `git log --oneline` | 커밋 히스토리 보기 |
| `git diff` | 변경 내용 미리 보기 |
| `git push` | GitHub에 올리기 |
| `git pull` | GitHub에서 최신 코드 받기 |
