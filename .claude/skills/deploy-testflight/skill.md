---
name: deploy-testflight
description: Deploy develop branch to TestFlight via numbered branch and PR. Use when user wants to deploy to TestFlight.
disable-model-invocation: false
argument-hint:
---

# Deploy TestFlight Skill

develop 브랜치의 최신 상태를 TestFlight으로 배포합니다.
번호가 매겨진 브랜치를 생성하고 `testFlight` 브랜치로 PR을 생성합니다.

## 작업 절차

### 1. 사전 확인

```bash
# develop 최신화
git fetch origin

# 현재 브랜치 확인
git branch --show-current

# develop에 uncommitted 변경사항 확인
git status --short
```

**주의:**
- uncommitted 변경사항이 있으면 사용자에게 알리고 중단
- 현재 브랜치가 develop이 아니면 develop으로 checkout

### 2. 다음 번호 결정

```bash
# 기존 deploy/testflight 브랜치 번호 확인 (리모트 기준)
git branch -r | grep -oE 'origin/deploy/testflight-[0-9]+' | grep -oE '[0-9]+' | sort -n | tail -1
```

- 리모트에 번호가 없으면 사용자에게 번호를 확인
- 가장 큰 번호 + 1로 새 브랜치 생성
- **번호가 예상과 다를 수 있으므로 사용자에게 다음 번호를 확인 후 진행**

### 3. 브랜치 생성 및 Push

```bash
# develop 최신 상태에서 분기
git checkout origin/develop -b deploy/testflight-{다음번호}

# 원격에 Push
git push -u origin deploy/testflight-{다음번호}
```

### 4. PR 생성

**PR 템플릿 (`/.github/PULL_REQUEST_TEMPLATE/deploy.md`)을 기반으로 body를 작성합니다.**

```bash
# 이전 testFlight 대비 develop의 새 커밋 확인
git log origin/testFlight..origin/develop --oneline
```

앱 버전을 확인합니다:

```bash
# Tuist 매니페스트에서 MARKETING_VERSION 추출 (AppName 이 배포 대상이다)
# 앞의 `"..."` 패턴은 필수 — 같은 파일 주석에도 MARKETING_VERSION 이 등장한다.
grep -m1 '"MARKETING_VERSION":' AppName/Tuist/ProjectDescriptionHelpers/Settings+Recommended.swift \
  | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?'
```

> 레거시 `AppName/AppName.xcodeproj/project.pbxproj` 는 v2.2.0 에 동결되어 있다.
> 여기서 버전을 뽑으면 배포되지 않는 구버전이 PR 제목에 찍힌다 (이슈 #1128).

위 커밋 목록과 버전 정보를 활용하여 PR 생성:

```bash
gh pr create \
  --base testFlight \
  --title "🚀 [Release] v{버전} TestFlight #{다음번호} 배포" \
  --body "$(cat <<'EOF'
## 🚀 배포 유형

TestFlight

## 📋 포함된 변경사항

{develop에서 이전 testFlight 이후 추가된 커밋/PR 목록}

## ✅ Checklist

- [ ] 주요 기능 동작 확인
- [ ] 크래시 없음 확인
- [x] TestFlight 테스트 완료 (Release인 경우) — N/A
- [x] App Store 심사 가이드라인 준수 확인 (Release인 경우) — N/A
EOF
)"
```

### 5. 결과 출력

```
✅ TestFlight 배포 PR 생성 완료!
📌 PR URL: {URL}
🔀 deploy/testflight-{번호} → testFlight

머지 후 아카이브/업로드는 아직 수동입니다 (아래 참고).
```

### 6. 아카이브 (수동)

빌드 번호는 매니페스트가 `TUIST_BUILD_NUMBER` 에서 읽는다(기본값 1). TestFlight 은 같은
`MARKETING_VERSION` 안에서 빌드 번호가 중복되면 업로드를 거부하므로, 아카이브 전에 올린다:

```bash
cd AppName && TUIST_BUILD_NUMBER={이전 빌드 번호 + 1} make generate-open
```

Xcode 에서 `AppName` 스킴 → Any iOS Device → Product > Archive → Distribute App.

## 주의사항

- **develop에서만 분기** (feature 브랜치에서 직접 배포 금지)
- **직접 testFlight 브랜치에 push 금지**, 반드시 PR 경유
- 브랜치명은 `deploy/testflight-{번호}` 형식
