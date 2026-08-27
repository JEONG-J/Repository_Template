---
name: create-issue
description: Create a GitHub Issue using project issue templates. Use when user wants to create an issue or report a bug/feature request.
disable-model-invocation: false
argument-hint: [issue description or context]
---

# Create Issue Skill

사용자의 요청을 분석하여 프로젝트 이슈 템플릿에 맞는 GitHub Issue를 자동으로 생성합니다.

## 이슈 템플릿 목록

프로젝트에 6개의 이슈 템플릿이 있습니다:

| 템플릿 | 제목 접두사 | 라벨 (GitHub shortcode) | 용도 |
|--------|------------|------------------------|------|
| 🐛 버그 수정 | `🐛 Bug: ` | `:bug: Bug` | 버그 발견 및 수정 |
| ✨ 기능 추가 | `✨ Feature: ` | `:sparkles: Feature` | 새로운 기능 구현 |
| 🎨 디자인 반영 | `🎨 Design: ` | `:lipstick: UI` | UI/UX 디자인 반영 |
| ♻️ 리팩토링 | `♻️ Refactor: ` | `:hammer: Refactor` | 코드 정리/구조 개선 |
| 📄 문서 작업 | `📄 Docs: ` | `:page_facing_up: Docs` | 문서 생성/갱신 |
| 🍀 기타 작업 | `🍀 ETC: ` | `:wrench: chore` | 분류되지 않는 기타 작업 |

## 작업 절차

### 1. 템플릿 선택

사용자의 요청 내용을 분석하여 적절한 템플릿을 **자동으로** 판단합니다.

**판단 기준:**
- 버그/오류/수정/크래시/실패 → `bug`
- 새 기능/추가/구현 → `feature`
- UI/디자인/레이아웃/Figma → `design`
- 리팩토링/정리/구조 개선/분리 → `refactor`
- 문서/README/명세/주석 → `docs`
- 위에 해당하지 않는 경우 → `other`

자동 판단이 어려운 경우 사용자에게 질문합니다.

### 2. 템플릿별 Body 생성

사용자 요청에서 정보를 추출하여 각 템플릿의 필수 섹션을 채웁니다.

#### 🐛 Bug 템플릿

```markdown
### 🔍 문제 상황

{어떤 문제가 발생했는지 서술}

### 🔄 재현 단계

1. {재현 단계 - 파악 가능한 경우}
2.
3.

### ✅ 완료 조건

- [ ] {해결 조건 1}
- [ ] {해결 조건 2}
```

#### ✨ Feature 템플릿

```markdown
### 📌 작업 목적

{왜 이 기능이 필요한지 요약}

### ✅ 완료 조건

- [ ] {구현 항목 1}
- [ ] {구현 항목 2}

### 🔗 관련 정보

{Figma 링크, 관련 이슈 번호 등 - 있는 경우}
```

#### 🎨 Design 템플릿

```markdown
### 📌 작업 목적

{디자인 반영의 핵심 내용}

### ✅ 완료 조건

- [ ] {구현 항목 1}
- [ ] {구현 항목 2}

### 🎨 Figma 링크

{Figma 링크 - 있는 경우}
```

#### ♻️ Refactor 템플릿

```markdown
### 🤔 리팩토링 이유

{왜 리팩토링이 필요한지}

### 📦 리팩토링 범위

{영향 받는 파일/모듈}

### ✅ 완료 조건

- [ ] {완료 조건 1}
- [ ] {완료 조건 2}

### 💥 기대 효과

{리팩토링의 기대 효과 - 파악 가능한 경우}
```

#### 📄 Docs 템플릿

```markdown
### 📌 작업 목적

{문서 작업 내용}

### ✅ 완료 조건

- [ ] {완료 조건 1}
- [ ] {완료 조건 2}
```

#### 🍀 Other 템플릿

```markdown
### 📌 작업 목적

{작업 내용}

### 🤔 배경

{왜 이 작업이 필요한지 - 파악 가능한 경우}

### ✅ 완료 조건

- [ ] {완료 조건 1}
- [ ] {완료 조건 2}
```

### 3. 이슈 제목 생성

**형식:** `{이모지} {Type}: {작업 내용 요약}`

- 템플릿의 title prefix를 그대로 사용
- 뒤에 간결한 작업 내용 추가

**예시:**
- `🐛 Bug: AccessToken 재발급 API URI 불일치`
- `✨ Feature: GPS 기반 스마트 출석 시스템`
- `🎨 Design: MyPage 프로필 뷰 리디자인`
- `♻️ Refactor: Notice 모듈 클린 아키텍처 전환`

### 4. 이슈 생성

기본적으로 **현재 GitHub 사용자(`@me`)에게 자동으로 assign** 합니다.

```bash
gh issue create \
  --title "{이슈 제목}" \
  --label "{라벨}" \
  --assignee "@me" \
  --body "$(cat <<'EOF'
{이슈 Body}
EOF
)"
```

> 사용자가 다른 assignee 를 명시했거나 "assign 하지 마"처럼 명시적으로 거부한 경우에만 이 기본값을 변경합니다.

### 5. 결과 출력

```
✅ 이슈 생성 완료!
📌 Issue URL: {URL}

{이슈 제목}
```

## 특수 케이스

### 사용자가 템플릿 타입을 명시한 경우

```
/create-issue bug: 로그인 시 크래시 발생
→ 🐛 Bug: 로그인 시 크래시 발생 (bug 템플릿 사용)
```

### 사용자가 다른 assignee를 지정한 경우

기본값(`@me`) 대신 지정된 사용자로 교체:
```bash
gh issue create --assignee "{username}" ...
```

여러 명을 지정하려면 콤마로 구분 (`--assignee "alice,bob"`).

### 사용자가 assignee를 원하지 않는 경우

명시적으로 거부한 경우 `--assignee` 플래그를 빼고 생성합니다.

### 정보가 부족한 경우

필수 섹션(문제 상황, 작업 목적 등)을 채울 수 없으면 사용자에게 추가 정보를 요청합니다.

## 주의사항

- 완료 조건은 구체적으로 작성 (파일명, 기능명 명시)
- 사용자가 제공한 원문(디스코드 메시지, 슬랙 메시지 등)의 맥락을 최대한 반영
- 관련 코드 경로를 파악할 수 있으면 본문에 포함
- 라벨은 템플릿에 정의된 값을 정확히 사용
- **AI attribution 금지** — 이슈 제목/본문에 "Generated with Claude Code", "Created by Claude" 등
  AI 작성 흔적 문구를 절대 포함하지 않음
