---
name: create-pr
description: Create a GitHub Pull Request with auto-generated title and body following project conventions. Use when user wants to create a PR.
disable-model-invocation: false
argument-hint: [optional: custom PR title]
---

# Create PR Skill

현재 브랜치의 변경사항을 분석하여 프로젝트 컨벤션에 맞는 PR을 자동으로 생성합니다.

## 작업 절차

### 1. 변경사항 분석

다음 명령어를 **병렬로** 실행하여 변경사항 파악:

```bash
# 변경된 파일 확인
git status

# 변경 내용 확인 (staged + unstaged)
git diff HEAD

# 현재 브랜치에서 develop 이후의 모든 커밋 확인
git log develop..HEAD --oneline

# develop 브랜치와의 전체 diff 확인
git diff develop...HEAD
```

### 2. Unstaged 변경사항 처리 (중요!)

**반드시 커밋을 먼저 생성한 후 PR을 만들어야 합니다.**

```bash
# Unstaged 변경사항이 있는 경우
if [ -n "$(git status --short)" ]; then
    # 모든 변경사항 stage
    git add .

    # 커밋 메시지 생성 및 커밋
    git commit -m "{이모지}[Type] {작업 내용}"

    # 원격 브랜치에 push
    git push origin {current-branch}
fi
```

**커밋 메시지 형식:**
- 변경사항 분석 결과를 바탕으로 적절한 Type 선택
- 예: `💄[Design] MyPage 섹션 컴포넌트화 및 주석 추가`
- 예: `✨[Feat] Activity 출석 시스템 구현`
- **`Co-Authored-By` 라인, "Generated with Claude Code" 등 AI attribution 절대 추가 금지** (CLAUDE.md 절대 규칙 #8)

### 3. PR 제목 생성

**형식:** `이모지[Type] 작업 내용 요약`

**Type 판단 기준:**
- 커밋 메시지에서 가장 많이 등장하는 Type 사용
- 또는 변경된 파일 위치로 판단:
  - `Presentation/Views/` → Design
  - `Domain/UseCases/` → Feat
  - 버그 수정 커밋 → Fix
  - 구조 개선 → Refactor

**이모지 매핑 (`.claude/local.md` 참고):**
- ✨ [Feat] - 새로운 기능 추가
- 🐛 [Fix] - 버그 수정
- ♻️ [Refactor] - 코드 리팩토링
- 🎨 [Style] - 코드 포맷팅
- 📝 [Docs] - 문서 관련
- ✅ [Test] - 테스트 코드
- 🔧 [Chore] - 빌드/설정
- 💄 [Design] - UI 디자인
- 🚑 [Hotfix] - 긴급수정
- 👷 [CI/CD] - 배포/워크플로우

**예시:**
- `💄 [Design] MyPage 프로필 뷰 리팩토링`
- `✨ [Feat] Activity Feature 클린 아키텍처 구현 및 출석 시스템 개발`

### 3-1. Type → 라벨 자동 매핑

리포 표준 라벨(`gh label list` 결과 기준)에 맞춰 PR 생성 시 `--label` 자동 지정:

| PR Type | GitHub Label |
|---------|--------------|
| ✨ [Feat] | `:sparkles: Feature` |
| 🐛 [Fix] | `:bug: Bug` |
| 🚑 [Hotfix] | `:bug: Bug` |
| ♻️ [Refactor] | `:hammer: Refactor` |
| 💄 [Design] | `:lipstick: UI` |
| 📝 [Docs] | `:page_facing_up: Docs` |
| 🔧 [Chore] | `:wrench: chore` |
| 👷 [CI/CD] | `:wrench: chore` |
| 🎨 [Style] | `:fire: cleanup` |
| ✅ [Test] | (라벨 없음 — 생략) |

여러 성격이 섞여 있으면 다음 우선순위로 **복수 라벨** 부여 가능:
1. 가장 비중이 큰 변경(파일 수/줄 수)을 주 라벨로
2. 부수적으로 추가된 성격(예: Feature + Refactor)도 함께 부여
3. 배포 브랜치(`testFlight/*`, `release/*`)로의 PR이면 `🛫 TestFlight` 또는 `🚀 Release` 추가

**라벨 존재 여부는 사전 확인 필수** — 신규 라벨을 임의로 만들지 않습니다:

```bash
# 사용 가능 라벨 확인
gh label list --limit 50
```

존재하지 않는 라벨은 `--label` 에서 제외하고 사용자에게 안내합니다.

### 4. PR Body 작성

**반드시 다음 템플릿을 사용하세요:**

```markdown
## ✨ PR 유형

{변경사항 요약 - Feature/Fix/Refactor/Design 등}

## 📷 스크린샷 or 영상(UI 변경 시)

<!-- UI 관련 작업이라면 영상으로 올려주세요
그 외에는 스크린샷으로 올려도 무방합니다.
어떤 작업을 하였는지 시각적으로 바로 확인 가능하게 해주세요! -->

## 🛠️ 작업내용

{변경사항을 구체적으로 나열}
- {변경사항 1}
- {변경사항 2}

## 📋 추후 진행 상황

<!-- 다음에 진행할 작업에 대해 작성해주세요 -->

## 📌 리뷰 포인트

<!-- 주요 파일 경로와 확인해야 할 로직을 명시해주세요 -->
- `{주요 변경 파일 경로}` - {확인 포인트}

## ✅ Checklist

PR이 다음 요구 사항을 충족하는지 확인해주세요!!!

- [x] 커밋 메시지 컨벤션에 맞게 작성했습니다
    -  해당 링크 : [깃 모지 컨벤션](https://tngusmiso.tistory.com/57)
- [x] 유지-보수를 위해 주석처리를 잘 작성하였는가?
    - 해당 링크 : [Xcode 주석 정리](https://yoojin99.github.io/app/Swift-Documentation/)
```

> **금지**: PR 본문 끝에 `🤖 Generated with [Claude Code](...)` 푸터, `Co-Authored-By` 크레딧 등
> **AI가 작성했음을 드러내는 문구를 절대 추가하지 않습니다.** 위 템플릿 이외의 자동 서명/크레딧 라인 금지.

### 5. 작업내용 작성 가이드

**파일 변경 유형별 그룹화:**

1. **클린 아키텍처 관련:**
   ```
   - Domain/UseCases/ 추가
   - Repository Protocol 구현
   - ViewModel에 UseCase 주입
   ```

2. **UI 작업:**
   ```
   - {View명} 제작
   - {Component명} 컴포넌트 추가
   - {기능} UI 개선
   ```

3. **리팩토링:**
   ```
   - {파일명} → {새파일명} 리네임
   - {컴포넌트}를 Core로 이동 (재사용성 향상)
   - {기능} 로직 개선
   ```

### 6. 리뷰 포인트 작성 가이드

**주요 변경 파일 경로를 명시하고, 확인해야 할 로직 설명:**

```
- `Features/{Feature}/Domain/UseCases/` - UseCase 설계 확인
- `Features/{Feature}/Presentation/ViewModels/{ViewModel}.swift` - @Observable 패턴 및 상태 관리
- `Features/{Feature}/Presentation/Views/{View}.swift` - {확인할 로직}
- `Core/Manager/{Manager}.swift` - {확인할 로직}
```

### 7. PR 생성

**Assignee = `@me` (PR 작성자), Label = Type 매핑 결과** 를 기본으로 부여합니다.

```bash
# develop 브랜치 기준으로 PR 생성 (assignee + label 동시 지정)
gh pr create \
  --base develop \
  --assignee "@me" \
  --label "{Type 매핑 라벨}" \
  --title "{PR 제목}" \
  --body "$(cat <<'EOF'
{PR Body 내용}
EOF
)"
```

**복수 라벨**이 필요하면 `--label` 플래그를 여러 번 반복합니다:

```bash
gh pr create \
  --base develop \
  --assignee "@me" \
  --label ":sparkles: Feature" \
  --label ":hammer: Refactor" \
  --title "..." \
  --body "..."
```

**라벨 이름은 `gh label list` 출력의 정확한 문자열**(이모지 코드 포함)을 그대로 사용해야 매칭됩니다. 잘못된 라벨명이면 `gh pr create` 가 실패하므로, 사전에 `gh label list` 로 확인하세요.

> **다른 사용자에게 할당**해야 하는 경우는 `--assignee <github-login>` 으로 지정. 기본은 항상 `@me`.

> **PR 생성 후 추가/변경**이 필요하면:
> ```bash
> gh pr edit <PR번호> --add-assignee <user> --add-label "<라벨>"
> gh pr edit <PR번호> --remove-label "<라벨>"
> ```

### 8. 결과 출력

PR 생성 후:
```
✅ PR 생성 완료!
📌 PR URL: {URL}

{PR 제목}
```

## 특수 케이스 처리

### 케이스 1: Unstaged 변경사항이 있는 경우
**반드시 커밋을 먼저 생성해야 합니다:**
```bash
git add .
git commit -m "{이모지}[Type] {작업 내용}"
git push origin {current-branch}
gh pr create --base develop ...
```

### 케이스 2: 현재 브랜치가 develop인 경우
```
❌ develop 브랜치에서는 PR을 생성할 수 없습니다.
Feature 브랜치를 생성해주세요.
```

### 케이스 3: 사용자가 제목을 제공한 경우
제공된 제목 사용 (이모지는 자동 추가):
```
/create-pr MyPage 리팩토링
→ 💄 [Design] MyPage 리팩토링
```

## 주의사항

- **Base branch는 항상 `develop`** (CLAUDE.md 참고)
- **Assignee는 기본 `@me`** — 명시적으로 다른 담당자 지정이 없으면 항상 PR 작성자 본인에게 할당
- **Label은 Type 매핑 표 기준**으로 자동 부여 — 존재하지 않는 라벨이면 생략(임의 생성 금지)
- **UI 변경이 있으면 "스크린샷 필요" 메시지 출력**
- **작업내용은 구체적으로 작성** (파일명, 기능명 명시)
- **리뷰 포인트는 파일 경로 포함** (예: `Features/MyPage/...`)
- **Checklist는 기본적으로 체크됨** (`[x]`)
- **AI attribution 금지** — PR 제목/본문/커밋 메시지에 "Generated with Claude Code", `Co-Authored-By` 등
  AI 작성 흔적을 절대 포함하지 않음

## 예시

### 사용법 1: 자동 분석 후 PR 생성
```
/create-pr
```

### 사용법 2: 커스텀 제목으로 PR 생성
```
/create-pr MyPage 프로필 뷰 리팩토링
```

## 참고

- `.claude/local.md` - PR 컨벤션
- `CLAUDE.md` - Git Workflow, Base branch 정보
