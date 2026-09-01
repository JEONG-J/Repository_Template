# Build & Run + Tuist 모듈 구조

> 빌드 명령, Tuist 모듈화 구조, 의존성 방향에 대한 상세 레퍼런스.
> 핵심 요약은 `CLAUDE.md` 참고.

- 작성자: 제옹(euijjang97)

## Build & Run

빌드 축은 `AppName/`(Tuist) 하나입니다. 레거시 xcodeproj 를 함께 굴리는 프로젝트라면
`### AppName (xcodeproj)` 절을 아래에 추가하고, 어느 쪽이 신규 작업 기준인지 명시합니다.

### AppName (Tuist)

Tuist 버전은 `AppName/mise.toml` 로 팀 전원 고정됩니다. Makefile이 `mise exec --` 래퍼를 제공하므로 **로컬 tuist 버전 차이가 발생하지 않습니다**.

```bash
cd AppName

# 최초 1회 (신규 팀원)
brew install mise      # mise가 없다면
make bootstrap         # mise.toml 기반 tuist 설치
make install           # SPM 의존성

# 일상 작업
make generate          # .xcworkspace 생성
make open              # Xcode 열기 (없으면 자동 generate)
make test              # xcodebuild 테스트
make doctor            # 환경 진단 (mise/tuist/xcode 버전)
make reset             # 꼬였을 때 전체 초기화
make help              # 전체 타겟 목록
```

자세한 사용법은 `AppName/MAKEFILE_GUIDE.md` 참고.

## Tuist 모듈 구조 (AppName)

`AppName/` 폴더가 Tuist 기반 모듈화 프로젝트의 루트입니다.

### 버전 관리 & 빌드 래퍼

| 파일 | 역할 |
|------|------|
| `mise.toml` | Tuist 버전 고정 (현재 `4.155.0`) — 팀 전원 동일 버전 보장 |
| `Makefile` | `mise exec -- tuist …` 래퍼. 모든 Tuist/xcodebuild 명령의 **표준 진입점** |
| `MAKEFILE_GUIDE.md` | 팀원용 사용 가이드 |

> Tuist 버전을 올릴 때는 **`mise.toml` 만** 수정하고 PR 본문에 릴리스 노트를 첨부합니다.
> Makefile / 로컬 tuist 설치는 손대지 않습니다.

### 전체 구조

```
AppName/
├── Makefile                       # 빌드/생성 래퍼 (mise exec 기반)
├── MAKEFILE_GUIDE.md              # 팀원용 사용 가이드
├── mise.toml                      # tuist 버전 고정
├── Project.swift                  # 앱 타겟 정의
├── Workspace.swift                # 전체 워크스페이스 (Core/*, Features/* glob + Widget/Watch)
├── Tuist.swift                    # Tuist 시스템 설정
├── Tuist/
│   ├── Package.swift              # SPM 외부 의존성 (Moya, Kingfisher)
│   └── ProjectDescriptionHelpers/
│       ├── Project+Core.swift     # Core 모듈 공통 헬퍼
│       └── Project+Feature.swift  # Feature 모듈 공통 헬퍼
├── Core/                          # 공유 인프라 모듈
│   ├── Foundation/                # 기반 유틸리티, Config
│   ├── Network/                   # 네트워크 레이어 (Moya)
│   ├── DesignSystem/              # 디자인 토큰, 색상
│   ├── UIComponents/              # 공용 UI 컴포넌트 (Kingfisher)
│   ├── DI/                        # 의존성 주입 컨테이너
│   ├── WatchConnectivity/         # iOS ↔ watchOS 통신 (워치 타겟 쓸 때만)
│   └── WidgetShared/              # Widget-App 공유 모델 (위젯 쓸 때만)
├── Features/                      # 기능 모듈 — 프로젝트에 맞게 채운다
│   ├── Auth/
│   ├── Home/
│   └── MyPage/
├── AppNameWidget/                 # Widget Extension 타겟
└── AppNameWatchApp/               # watchOS Companion App 타겟
```

> Core 는 "여러 Feature 가 공유하는 인프라"만 둡니다. 특정 Feature 전용 인프라를 Core 로 올리면
> 전 모듈이 그 의존성을 떠안습니다 — 그 Feature 의 `Data` 타겟에 두는 것이 기본값입니다.

### 모듈 의존성 방향

```
App Target (AppName)
    ↓
Feature Presentation  (Domain + CoreDesignSystem + CoreUIComponents)
    ↓
Feature Domain        (AppFoundation)
Feature Data          (Domain + CoreNetwork + AppFoundation)
    ↓
Core Modules          (Foundation / Network / DesignSystem / UIComponents / DI)
    ↓
External Packages     (Moya 15.0.3 / Kingfisher 8.6.1)
```

### 모듈 경계 정책 (프로젝트별로 채운다)

여러 Feature 가 같은 도메인을 건드리기 시작하면 **소유자를 여기에 명시**합니다.
Feature 를 새로 팔지, 기존 Feature 에서 재사용할지는 그때그때 판단하면 반드시 갈라지므로,
확정된 경계를 문서에 박아 두고 이후 작업이 그것을 따르게 합니다.

한 항목당 아래 세 가지를 적습니다.

- **단일 소유자** — 모델·Repository/UseCase Protocol 을 어느 Domain 타겟이 갖는가
- **재사용 규칙** — 다른 Feature 는 무엇을 링크해 쓰고, 무엇을 자체 구현하지 않는가
- **예외** — 그럼에도 각 Feature 에 두는 것 (보통 엔드포인트별 wire DTO. 같은 이름이어도
  서로 다른 엔드포인트 계약이면 의도적으로 분리하고, 매핑 대상 Domain 모델만 공유합니다)

> 예시 형식:
> **경계 정책 — 일정(Schedule) (#123 확정)**: 전용 Schedule Feature 모듈은 신설하지 않는다.
> 단일 소유자는 `HomeDomain` + `HomeData` + `HomePresentation` 이다.
> 다른 Feature 는 일정 모델을 `HomeDomain` 에서 재사용하고 자체 모델을 다시 만들지 않는다.

경계를 바꾼 결정은 **이력째** 남깁니다 — 뒤집힌 결정(한 번 폐기했다가 되살린 방식 등)을 지우면
같은 논의가 반복됩니다.

### Feature 모듈 구조

각 Feature는 Clean Architecture에 따라 **3개 타겟**으로 분리됩니다.

| 타겟 | Product Type | Bundle ID 패턴 | Sources |
|------|-------------|----------------|---------|
| `{Name}Domain` | `.staticFramework` | `dev.example.feature.{name}.domain` | `Domain/Sources/**` |
| `{Name}Data` | `.staticFramework` | `dev.example.feature.{name}.data` | `Data/Sources/**` |
| `{Name}Presentation` | `.staticFramework` | `dev.example.feature.{name}.presentation` | `Presentation/Sources/**` |

### 플랫폼(destination) 정책

기본값은 iOS 전용입니다. watchOS 재사용이 필요한 타겟만 `[.iPhone, .appleWatch]` /
`.multiplatform(iOS: "26.4", watchOS: "26.4")` 로 개방합니다 — Core 모듈은 `coreProject` 의
`destinations`/`deploymentTargets` 인자, Feature Domain 은 `featureProject` 의
`domainDestinations`/`domainDeploymentTargets` 인자로 지정합니다.

**개방은 의존 사슬 전체에 해야 합니다.** watchOS 로 여는 타겟이 iOS 전용 타겟에 의존하면
`unable to resolve module dependency` 로 빌드가 깨집니다 — 그 의존을 `condition: .when([.ios])`
로 덮어두면 워치 타겟이 실제로 링크하기 전까지 증상이 드러나지 않으니, 개방할 때 사슬을 끝까지
따라가 함께 엽니다.

`Data`/`Presentation` 타겟은 iOS 전용으로 두는 것이 원칙입니다 — 네트워크 스택(Moya 등)에
의존해 워치가 링크할 수 없습니다. 워치의 데이터 수급은 WatchConnectivity 경로로 해결합니다.

**개방한 타겟 목록은 이 문서에 표로 유지합니다** — 어떤 타겟이 멀티플랫폼인지 매니페스트를
전부 열어보지 않고 알 수 있어야 합니다.

### ProjectDescriptionHelpers

보일러플레이트 제거를 위해 두 개의 헬퍼 함수를 사용합니다.

```swift
// Core 모듈 생성
coreProject(
    name: "CoreNetwork",
    bundleIdSuffix: "network",
    dependencies: [.target(name: "AppFoundation"), .external(name: "Moya")]
)

// Feature 모듈 생성 (3개 타겟 자동 생성)
featureProject(
    name: "Auth",
    domainExtraDependencies: [],
    dataExtraDependencies: [],
    presentationExtraDependencies: []
)
```

두 헬퍼 모두 리소스 파라미터(`dataResources`/`presentationResources`)를 선택적으로 받습니다.
`staticFramework` 는 Compile Sources 산출물이 소비 타겟까지 전파되지 않으므로, 런타임에 필요한
자산(CoreML 모델, USDZ, JSON 시드 등)은 **별도 리소스 번들로 명시**해야 합니다. 소스만 넣고
리소스를 빼면 빌드는 통과하고 런타임에 `nil` 로 터집니다.

### 외부 의존성

| 패키지 | 버전 | 사용처 |
|--------|------|--------|
| Moya | 15.0.3 | CoreNetwork |
| Kingfisher | 8.6.1 | CoreUIComponents |
| KakaoSDK (kakao-ios-sdk) | 2.27.0+ | CoreNetwork (`KakaoLoginManager`) |
| GoogleSignIn-iOS | 9.1.0+ | CoreNetwork (`GoogleLoginManager`) |

### 주요 설정

- **Tuist 버전**: `AppName/mise.toml` 고정 (`4.155.0`)
- **Deployment Target**: iOS 26.4 (`Project.swift` 기준, 전체 타겟 공통)
- **Product Type**: 모든 모듈 `.staticFramework`
- **Bundle ID**: Core → `dev.example.core.*` / Feature → `dev.example.feature.*.*`
- **Workspace**: glob(`Core/*`, `Features/*`) + `AppNameWidget`, `AppNameWatchApp` 명시 포함

### 공유 Keychain Access Group

앱과 확장(위젯 등)이 로그인 토큰을 공유하려면 `keychain-access-groups` entitlement 를 씁니다.
팀 ID 를 문자열로 박지 말고 `$(AppIdentifierPrefix)` 를 쓰고, entitlements 파일은 만드는 것으로
끝이 아니라 **매니페스트에 배선**해야 합니다(`entitlements: .file(path: "...")`) — 파일만 두고
인자를 안 넘기면 조용히 무효입니다.

```xml
<key>keychain-access-groups</key>
<array>
    <string>$(AppIdentifierPrefix)com.example.appname.shared</string>
    <string>$(AppIdentifierPrefix)com.example.appname</string>
</array>
```

- **배열 순서가 계약입니다.** `kSecAttrAccessGroup` 을 지정하지 않은 `SecItemAdd` 는 배열
  **첫 항목**에 저장합니다. 토큰 저장소가 access group 을 명시하지 않는다면 이 기본값 규칙에
  전적으로 의존하는 것이므로, 공유 그룹을 첫 번째에 둡니다.
- **두 번째 항목(각 타겟 자기 App ID 그룹)은 안전장치입니다.** 검색·삭제는 access group 미지정 시
  앱이 가진 모든 그룹을 훑으므로, 기존 배포판이 기본 그룹에 저장해 둔 토큰이 계속 읽힙니다.
  이 줄을 빼면 업데이트 즉시 전 사용자 강제 로그아웃입니다.
- **watchOS 는 keychain 을 공유하지 않습니다.** Apple Watch 는 자체 keychain 을 가진 별개 기기라
  access group 을 맞춰도 워치가 iPhone 의 항목을 읽지 못합니다. access group 은 동일 기기 내
  동일 팀 서명 타겟(앱·확장) 간 공유 메커니즘입니다. 워치 토큰은 WatchConnectivity 로
  iPhone→Watch 전송 후 워치 자체 keychain 에 저장하는 경로입니다.
- **서명 주의**: 관련 App ID 에 Keychain Sharing capability 가 없으면 실기기/아카이브 서명에서
  실패하고, 런타임 증상은 `SecItemAdd` 의 `errSecMissingEntitlement(-34018)` 입니다.

> ⚠️ 이 entitlement 는 "미사용으로 보인다"는 이유로 정리 커밋에 휩쓸려 사라지기 쉽습니다.
> 코드 검색으로는 쓰임이 드러나지 않으니(암묵적 기본값에 의존하므로) 제거하지 않습니다.
