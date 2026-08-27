<div align="center">

# {{프로젝트 이름}}

**"{{한 줄 슬로건}}"**

{{한 줄 소개 — 이 앱이 누구의 어떤 문제를 푸는지}}

[![Release](https://img.shields.io/github/v/release/YOUR-ORG/YOUR-REPO?label=release&color=blue)](https://github.com/YOUR-ORG/YOUR-REPO/releases)
[![Swift](https://img.shields.io/badge/Swift-6.3-orange.svg)]()
[![Xcode](https://img.shields.io/badge/Xcode-26.2-1575F9.svg)]()
[![iOS](https://img.shields.io/badge/iOS-26.0+-black.svg)]()
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20Modular-2ea44f.svg)]()

</div>

---

## 📖 소개

{{해결하려는 문제와 사용자가 얻는 경험을 2~3줄로.}}

**Killer Features**

- 🔔 **{{기능 1}}** — {{한 줄 설명}}
- 📱 **{{기능 2}}** — {{한 줄 설명}}
- 📍 **{{기능 3}}** — {{한 줄 설명}}

## 🛠️ 기술 스택

<div align="center">
<img src="{{기술 스택 이미지 URL}}" width="100%" alt="기술 스택">
</div>

## 🏢 iOS 팀 조직도
<div align="center">

| 🥇 1기 · {{YYYY.MM.DD}} – {{YYYY.MM.DD}} | 🥈 2기 · 진행 중 |
|:---:|:---:|
| <img src="{{1기 조직도 이미지 URL}}" width="400" alt="iOS 1기 조직도"> | <img src="{{2기 조직도 이미지 URL}}" width="400" alt="iOS 2기 조직도"> |

</div>

> 기수별 팀원 구성(사진·역할·GitHub)은 [Wiki › Team](https://github.com/YOUR-ORG/YOUR-REPO/wiki/Team)에서,
> 신규 기능·운영 기록은 [Wiki › Release History](https://github.com/YOUR-ORG/YOUR-REPO/wiki/Release-History)에서 확인하세요.

## 📚 개발 문서

아키텍처·코딩 컨벤션·빌드 방법 등 상세 가이드는 `docs/claude/` 에 있습니다.
팀 규모가 커지면 [Wiki](https://github.com/YOUR-ORG/YOUR-REPO/wiki) 로 이관하고 아래 표의 링크만 바꾸세요.

| 주제 | 문서 |
|------|------|
| 🏗️ 아키텍처 | [architecture.md](docs/claude/architecture.md) |
| 📐 절대 규칙 & 코딩 컨벤션 | [CLAUDE.md](CLAUDE.md) · [coding-style.md](docs/claude/coding-style.md) |
| ⚠️ 에러 처리 | [architecture.md › 에러 처리](docs/claude/architecture.md) |
| 🌐 네트워크 & DTO 디코딩 | [network-router.md](docs/claude/network-router.md) · [response-dto-decoding.md](docs/claude/response-dto-decoding.md) |
| 🎨 디자인 시스템 | [design-system.md](docs/claude/design-system.md) |
| 🧱 모듈 구조 (Tuist) | [build-and-modules.md](docs/claude/build-and-modules.md) |
| ⚙️ 빌드 & 실행 | [AppName/MAKEFILE_GUIDE.md](AppName/MAKEFILE_GUIDE.md) |
| 🔀 Git 워크플로우 | [git-workflow.md](docs/claude/git-workflow.md) |
| 🔍 PR 리뷰 | [pr-review.md](docs/claude/pr-review.md) |
| 🍎 iOS 26 프레임워크 | [ios26-frameworks/INDEX.md](docs/claude/ios26-frameworks/INDEX.md) |
| 🛰️ OpenAPI 스캐폴딩 | [SWAGGER_AUTOMATION_GUIDE.md](docs/openapi/SWAGGER_AUTOMATION_GUIDE.md) |

> 신규 합류자는 **빌드 & 실행** → **아키텍처** → **절대 규칙** 순서로 시작하세요.

## 🔑 시크릿 설정

- `Secrets.xcconfig`(`BASE_URL`, `KAKAO_KEY` 등)와 `GoogleService-Info.plist`는 **팀 내부 채널**에서 수령합니다.
- 실제 키·설정 파일은 원격 저장소에 커밋하지 않습니다.
- 상세 절차: [AppName/Secrets/README.md](AppName/Secrets/README.md)

```bash
cd AppName
make bootstrap                                       # mise + tuist 설치 (최초 1회)
cp Secrets/Secrets.xcconfig.template Secrets/Secrets.xcconfig
make open                                            # generate + Xcode 열기
```

---

<div align="center">

**Made with ❤️ by {{팀 이름}}**

</div>
