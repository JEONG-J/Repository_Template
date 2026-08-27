# TEMPLATE_SETUP.md

이 저장소를 새 iOS 프로젝트로 쓸 때 해야 할 일. 다 끝내면 이 파일은 지운다.

## 1. 이름 치환

앱 이름을 `Growly` 로 정했다면:

```bash
grep -rl --exclude-dir=.git 'AppName' . | xargs sed -i '' 's/AppName/Growly/g'
grep -rl --exclude-dir=.git 'AppFoundation' . | xargs sed -i '' 's/AppFoundation/GrowlyFoundation/g'
grep -rl --exclude-dir=.git 'com.example.appname' . | xargs sed -i '' 's/com\.example\.appname/com.yourorg.growly/g'
grep -rl --exclude-dir=.git 'dev.example.' . | xargs sed -i '' 's/dev\.example\./dev.yourorg./g'
grep -rl --exclude-dir=.git 'YOUR-ORG' . | xargs sed -i '' 's/YOUR-ORG/YourGithubOrg/g'
grep -rl --exclude-dir=.git 'api.example.com' . | xargs sed -i '' 's/api\.example\.com/api.growly.com/g'
mv AppName/AppName.entitlements AppName/Growly.entitlements
mv AppName Growly
```

딥링크 URL 스킴(`appname://`)과 Bonjour 서비스명(`_appname-card._tcp`)도 같이 바꾼다.

## 2. `CLAUDE.md` · `README.md` 채우기

두 파일 모두 `{{ }}` 자리를 채운다. `grep -rn '{{' CLAUDE.md README.md` 로 남은 곳을 확인한다.

- `CLAUDE.md` — 프로젝트 이름·슬로건·목적·모듈 목록·버전·서버 레포 URL. 맨 위 안내 블록은 지운다.
- `README.md` — 슬로건·소개·Killer Features 3개·기술스택 이미지·조직도 이미지·팀 이름.
  `YOUR-ORG/YOUR-REPO` 는 1번 치환에서 이미 바뀐다.

서버가 정수를 정수로 내려주는 프로젝트면 **절대 규칙 #2·#3(String 통일 / custom Codable)은 삭제**한다.

## 3. Tuist 스캐폴딩

`AppName/Project.swift` 와 `Workspace.swift` 는 **동작하는 참조 설정**이지 빈 템플릿이 아니다.
아래 디렉터리를 만들거나, 쓰지 않는 타겟을 지운다.

- `Core/*` — `Project+Core.swift` 로 정의하는 공용 모듈 (Foundation / Network / DesignSystem / UIComponents …)
- `Features/*` — `Project+Feature.swift` 로 정의하는 Feature 3계층 (Domain / Data / Presentation)
- `AppNameWidget`, `AppNameWatchApp` — 안 쓰면 `Workspace.swift` 에서 제거
- `AppName/Resources/GoogleService-Info.plist` — Firebase 안 쓰면 Project.swift 에서 관련 키 제거

Info.plist 에 카카오·Google OAuth·TMap·NearbyInteraction·CloudKit 키가 들어 있다.
쓰지 않는 SDK는 `Project.swift` / `AppName.entitlements` / `Secrets/` 에서 함께 지운다.

```bash
cd AppName
make bootstrap   # mise + tuist 설치
cp Secrets/Secrets.xcconfig.template Secrets/Secrets.xcconfig
make open
```

## 4. 다듬을 문서

복사 시 프로젝트 고유 내용이 남아 있는 곳:

- `docs/claude/build-and-modules.md` — 모듈 경계 정책이 이전 프로젝트 Feature 기준. 모듈 목록 갱신 필요
- `docs/claude/git-workflow.md` — PR 제목 예시의 이슈 번호는 예시일 뿐.
  브랜치·커밋·PR·이슈 컨벤션이 전부 여기 있다 (README 에 중복 서술하지 않는다)

## 5. GitHub 설정

- `.github/workflows/tuist-ci.yml` — 기본 브랜치가 `develop` 이 아니면 `on:` 수정.
  Discord 알림을 쓰면 `DISCORD_WEBHOOK_URL` · `DISCORD_MENTION_ROLE_ID` 시크릿 등록,
  안 쓰면 `notify` job 삭제. Firebase 쓰면 `GOOGLE_SERVICE_INFO_PLIST_BASE64` 등록.
- `.github/ISSUE_TEMPLATE/*.yml` — 라벨이 저장소에 실제로 존재해야 한다. 없으면 먼저 만든다.

## 6. 포함된 것

| 경로 | 내용 |
|------|------|
| `CLAUDE.md` | 규약 허브 (절대 규칙 + 레퍼런스 인덱스) |
| `docs/claude/` | 아키텍처·코딩스타일·디자인시스템·네트워크·DTO·Git워크플로·PR리뷰 |
| `docs/claude/ios26-frameworks/` | iOS 26 프레임워크 가이드 20종 (Liquid Glass, FoundationModels 등) |
| `.claude/agents/`, `.claude/skills/`, `.agents/skills/` | Claude Code 에이전트·스킬 (심볼릭 링크 유지) |
| `.github/` | 이슈 템플릿 6종 · PR 템플릿 · 배포 PR 템플릿 · Tuist CI |
| `tools/openapi/` | OpenAPI → Swift 엔드포인트 스캐폴딩 스크립트 + 템플릿 |
| `docs/openapi/` | 위 스캐폴딩 도구 사용 가이드 (Swagger 자동화) |
| `AppName/` | Tuist 세팅 (Project/Workspace/Helpers/Makefile/mise/Secrets) |
| `.mcp.json` | Figma MCP 서버 설정 |
