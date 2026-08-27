---
name: go
description: AI가 스스로 결과물을 검증하도록 1) iOS E2E 빌드·테스트 → 2) 코드 단순화 → 3) PR 생성까지 한 번에 실행합니다. 보리스 체르니(Anthropic)의 "AI self-verification" 철학을 iOS 환경에 맞게 구현한 올인원 워크플로 스킬입니다.
disable-model-invocation: false
argument-hint: [optional: 커스텀 PR 제목 또는 추가 컨텍스트]
---

# /go — Self-Verifying Ship Skill

> "AI에게 스스로 결과물을 검증할 수 있는 환경을 열어주는 것이 가장 중요하다." — Boris Cherny

iOS 프로젝트에서는 브라우저 확장 대신 **xcodebuild + iOS Simulator**로 E2E 검증 루프를 구성합니다.
한 번의 `/go` 호출로 AI가 **빌드 → 테스트 → 코드 단순화 → PR 생성**까지 스스로 수행합니다.

---

## 전체 흐름

```
[Phase 1] E2E 검증      — xcodebuild clean build + test (시뮬레이터)
                          + Explore 서브에이전트로 빌드 로그 파싱
[Phase 2] 코드 단순화   — jeong-ios-dev 서브에이전트 병렬 분산 (Feature 단위)
[Phase 3] 재검증        — 재빌드 + code-reviewer 서브에이전트 회귀 점검
[Phase 4] PR 생성       — /create-pr 스킬 위임 (메인 Claude 직접)
```

각 Phase는 **이전 Phase가 통과했을 때만** 진행합니다. 실패 시 즉시 중단하고 원인을 보고합니다.

### 서브에이전트 활용 전략

| Phase | 서브에이전트 | 사용 이유 |
|-------|------------|---------|
| 1 | `Agent(Explore)` (실패 시) | 수백 줄 빌드 로그에서 원인만 추출 → 메인 컨텍스트 보호 |
| 2 | `Agent(jeong-ios-dev)` × N (병렬) | 프로젝트 컨벤션 내재화 + Feature 단위 병렬 단순화 |
| 3 | `Agent(code-reviewer)` | 단순화 후 독립 관점 회귀 리뷰 |
| 4 | 없음 | PR 생성은 단일 작업, 메인 Claude가 직접 수행 |

---

## 선행 조건 확인

스킬 실행 전 다음 사항을 점검합니다:

```bash
# 1. 현재 브랜치가 develop이 아닌지
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "develop" ] || [ "$CURRENT_BRANCH" = "main" ]; then
    echo "❌ develop/main 브랜치에서는 /go를 실행할 수 없습니다."
    exit 1
fi

# 2. 변경사항 존재 여부
if [ -z "$(git status --short)" ] && [ -z "$(git log develop..HEAD --oneline)" ]; then
    echo "❌ 커밋할 변경사항도, develop 대비 커밋도 없습니다."
    exit 1
fi

# 3. xcodebuild 사용 가능 여부
command -v xcodebuild >/dev/null || { echo "❌ xcodebuild 미설치"; exit 1; }
```

---

## Phase 1. E2E 빌드 & 테스트 검증

**목적:** AI가 작성한 코드가 실제로 빌드되고 테스트가 통과하는지 자가 검증합니다.

### 1-A. 시뮬레이터 선택

`CLAUDE.local.md` 지침에 따라 **iPhone 16 Pro**를 기본 사용합니다.

```bash
# 사용 가능한 시뮬레이터 확인
DESTINATION='platform=iOS Simulator,name=iPhone 16 Pro'
```

### 1-B. Clean Build

```bash
xcodebuild \
    -project AppName/AppName.xcodeproj \
    -scheme AppName \
    -configuration Debug \
    -destination "$DESTINATION" \
    clean build \
    2>&1 | tee /tmp/go_build.log | xcbeautify 2>/dev/null || cat /tmp/go_build.log
```

**실패 시 (필수: Explore 서브에이전트 사용):**

빌드 로그는 수백~수천 줄이 될 수 있어 **메인 컨텍스트를 오염시키면 안 됩니다.**
반드시 다음과 같이 `Explore` 서브에이전트에 파싱을 위임합니다:

```
Agent(
  subagent_type: "Explore",
  description: "Parse xcodebuild errors",
  prompt: "/tmp/go_build.log 파일을 읽고 다음만 뽑아서 보고해줘:
           1) error: 라인 전체 (최대 10개)
           2) 각 에러가 발생한 파일 경로와 라인 번호
           3) 에러 원인 분류 (타입 오류 / 의존성 누락 / 시그니처 불일치 등)
           파일 전체 내용은 붙이지 말고, 에러 라인 ±3줄만 포함.
           300자 이내로 보고."
)
```

서브에이전트 응답을 받은 후:
- 원인 파일을 Read하고 수정 적용
- Phase 1 재실행 (최대 3회 자동 재시도, 그 이상은 사용자 확인)

### 1-C. 테스트 실행

```bash
xcodebuild \
    -project AppName/AppName.xcodeproj \
    -scheme AppName \
    -destination "$DESTINATION" \
    test \
    2>&1 | tee /tmp/go_test.log | xcbeautify 2>/dev/null || cat /tmp/go_test.log
```

**테스트 타겟이 없거나 스킵된 경우:**
- 빌드만 통과해도 Phase 1은 PASS로 간주 (경고 메시지 출력)
- `AppNameTests/` 디렉터리 존재 여부로 판단

### 1-D. Phase 1 결과 출력

```
🧪 [Phase 1 — E2E 검증]
✅ Clean Build 성공 (소요 {N}초)
✅ 테스트 {passed}/{total} 통과
→ Phase 2로 진행합니다.
```

---

## Phase 2. 코드 단순화 (jeong-ios-dev 병렬 분산)

**목적:** 중복 제거, 과도한 추상화 축소, 불필요한 주석/에러 처리 제거.

**원칙:** 단순화는 **프로젝트 컨벤션을 가장 잘 아는 `jeong-ios-dev` 서브에이전트**에게 위임합니다.
메인 Claude는 **조율자(dispatcher)** 역할만 합니다.

### 2-A. 변경 파일 분석 및 그룹화

```bash
# 변경된 Swift 파일 목록 → Feature별로 그룹화
CHANGED_FILES=$(git diff --name-only develop...HEAD | grep "\.swift$")
```

Feature 단위(`Features/Auth/`, `Features/Notice/`, `Features/Home/` 등)로 파일을 묶습니다.
`Core/`, `Utilities/` 변경은 별도 그룹.

### 2-B. 병렬/단일 분기

- **변경 파일이 1개 Feature 이내이거나 < 3 파일**: `Skill(simplify)` 단일 실행
- **변경 파일이 2개 이상의 Feature에 걸침**: `Agent(jeong-ios-dev)` **병렬 분산**

### 2-C. 병렬 분산 실행 (2개 이상 Feature)

**반드시 하나의 메시지에 여러 `Agent` 호출을 넣어 병렬 실행합니다.**

```
Agent × N (동시 호출):

Agent(
  subagent_type: "jeong-ios-dev",
  description: "Simplify Features/Auth",
  prompt: "Features/Auth/ 하위의 변경된 파일들을 단순화해줘.
           대상 파일: {파일 목록}

           단순화 규칙 (CLAUDE.md 준수):
           1) 중복 로직 제거 → 공용 컴포넌트로 추출 또는 참조
           2) 과도한 추상화 축소 (불필요한 Protocol/Wrapper 제거)
           3) 불필요한 주석 제거 (WHY가 자명한 경우)
           4) @Observable, Loadable<T>, DIContainer 패턴은 건드리지 말 것
           5) '지금은 작동하지만 가독성이 나쁜 코드'만 대상
           6) 기능 추가·시그니처 변경 금지

           직접 파일을 Edit하고, 변경 요약만 200자 이내로 보고."
)

Agent(
  subagent_type: "jeong-ios-dev",
  description: "Simplify Features/Notice",
  prompt: "Features/Notice/ 하위의 변경된 파일들을 단순화해줘.
           (위와 동일한 규칙 적용, 대상 파일만 다름)"
)

... (다른 Feature 그룹도 동일 패턴으로)
```

### 2-D. 단순화 후 변경사항 확인

모든 서브에이전트가 완료되면:

```bash
git diff --stat
```

각 서브에이전트의 보고와 실제 `git diff`를 **대조 검증**합니다.
(서브에이전트는 의도를 보고하지만, 실제 변경은 직접 확인해야 함)

### 2-E. Phase 2 결과 출력

```
✂️  [Phase 2 — 코드 단순화 (jeong-ios-dev × {N} 병렬)]
- Features/Auth: {N1} lines 감소
- Features/Notice: {N2} lines 감소
- 총 감소: {total} lines
→ Phase 3로 진행합니다.
```

---

## Phase 3. 재검증 (Re-verify)

**목적:** 단순화가 기능을 깨뜨리지 않았는지 확인.

### 3-A. 조건부 재빌드

Phase 2에서 변경사항이 있을 때만 실행:

```bash
if [ -n "$(git diff --stat)" ]; then
    xcodebuild \
        -project AppName/AppName.xcodeproj \
        -scheme AppName \
        -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
        build test \
        2>&1 | tee /tmp/go_reverify.log | xcbeautify 2>/dev/null || cat /tmp/go_reverify.log
fi
```

**실패 시:**
- 단순화로 인한 회귀 발생 → Phase 2 변경사항을 되돌릴지(`git checkout -- .`) 사용자에게 확인
- 절대 강제로 되돌리지 않음

### 3-B. 독립 회귀 리뷰 (code-reviewer 서브에이전트)

빌드가 통과해도 **컨벤션 퇴화·의도치 않은 동작 변경**은 빌드로 잡히지 않습니다.
`code-reviewer` 서브에이전트에게 **독립 관점 회귀 점검**을 맡깁니다:

```
Agent(
  subagent_type: "code-reviewer",
  description: "Post-simplify regression review",
  prompt: "Phase 2에서 jeong-ios-dev 서브에이전트가 단순화를 수행했다.
           단순화된 파일들: {변경 파일 목록}

           다음 관점에서만 회귀 리뷰해줘 (신규 개선 제안 X):
           1) 단순화가 기존 동작을 바꿨는지 (시그니처/파라미터/리턴 타입)
           2) @Observable, Loadable, DIContainer 패턴이 깨졌는지
           3) private 접근 제어자가 의도치 않게 public으로 바뀌었는지
           4) 에러 처리 경로가 사라졌는지
           5) 사용되던 API가 제거되어 호출 측이 깨질 가능성

           [CRITICAL]/[OK]만 분류해서 300자 이내로 보고.
           [CRITICAL]이 하나라도 있으면 명시적으로 표시."
)
```

**[CRITICAL] 발견 시:**
- 해당 부분만 메인 Claude가 직접 수정
- 수정 후 재빌드 (최대 1회)
- 여전히 실패하면 사용자에게 revert 여부 확인

### 3-C. Phase 3 결과 출력

```
🔁 [Phase 3 — 재검증]
✅ 빌드/테스트 재통과
✅ code-reviewer 회귀 점검 (CRITICAL 0건)
→ Phase 4로 진행합니다.
```

(Phase 2에서 변경 없음이면: `⏭️  건너뜀 (변경사항 없음)`)

---

## Phase 4. PR 생성

### 4-A. `/create-pr` 스킬 위임

```
Skill(create-pr, args: "{사용자가 제공한 인자 또는 생략}")
```

`create-pr` 스킬이 다음을 자동 수행합니다:
- Unstaged 변경사항 자동 커밋 & push
- 커밋 분석 기반 PR 제목 생성 (이모지 + Type)
- 프로젝트 템플릿 기반 PR Body 작성
- `gh pr create --base develop`로 PR 생성

### 4-B. Phase 4 결과 출력

`create-pr` 스킬이 반환한 PR URL을 최종 요약에 포함합니다.

---

## 최종 요약 출력

4개 Phase 완료 후 다음을 출력합니다:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 /go 완료 — Ship Ready

| Phase | 결과 |
|-------|------|
| 1. E2E 검증 | ✅ 빌드/테스트 통과 |
| 2. 코드 단순화 | ✅ {N} lines 감소 |
| 3. 재검증 | ✅ 회귀 없음 |
| 4. PR 생성 | ✅ {PR URL} |

📌 브랜치: {current-branch} → develop
📌 PR: {PR URL}
━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 중단 조건 (Fail-Fast)

다음 상황에서는 **즉시 중단**하고 사용자에게 보고합니다:

| 중단 조건 | 대응 |
|---------|------|
| Phase 1 빌드 실패 (3회 재시도 후) | 에러 로그 발췌 + 원인 파일 제시 |
| Phase 1 테스트 실패 | 실패 테스트 이름 + 예상 원인 |
| Phase 3 회귀 발생 | Phase 2 revert 여부 확인 질문 |
| `gh` 인증 안 됨 | `gh auth login` 안내 |
| develop/main 브랜치 | 피처 브랜치 생성 안내 |

---

## 사용 예시

```
# 기본 실행 (브랜치의 모든 변경사항을 검증 → 단순화 → PR)
/go

# PR 제목 지정
/go MyPage 프로필 뷰 리팩토링
```

---

## 설계 원칙

1. **AI Self-Verification First** — 사용자에게 "작동할 것 같아요"가 아니라 "빌드·테스트 로그로 증명합니다"
2. **Fail-Fast** — 앞 단계 실패 시 절대 다음으로 진행하지 않음
3. **기존 스킬 재사용** — `simplify`, `create-pr`은 이미 검증된 스킬, 중복 구현 금지
4. **Non-Destructive** — 단순화가 회귀를 유발하면 사용자 확인 없이 되돌리지 않음
5. **CLAUDE.md 원칙 준수** — Base branch=develop, 이모지 컨벤션, Clean Architecture 규칙 모두 상속
6. **메인 Claude는 조율자** — 무거운 작업(로그 파싱·병렬 단순화·회귀 리뷰)은 서브에이전트에 위임, 메인 컨텍스트는 의사결정에만 사용
7. **서브에이전트 결과는 반드시 검증** — 서브에이전트의 보고(의도)와 실제 `git diff`(결과)를 대조 확인

---

## 참고

- `CLAUDE.md` — Git Workflow, Build & Run 섹션
- `CLAUDE.local.md` — iPhone 16 Pro 시뮬레이터 지정
- `.claude/skills/simplify/` — 코드 단순화 로직 (글로벌 스킬)
- `.claude/skills/create-pr/SKILL.md` — PR 생성 템플릿
