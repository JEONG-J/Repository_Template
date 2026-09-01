# Swagger 기반 API 연결 자동화 (최소 세트)

이 문서는 `openapi.json`(Swagger/OpenAPI 스펙)을 기반으로 iOS API 연결 뼈대를 빠르게 만드는 방법을 설명합니다.

- 작성자: 제옹(euijjang97)

## 포함된 구성

- `tools/openapi/generate_endpoint_scaffold.sh`
  - 엔드포인트 1개 기준 스캐폴드 생성
- `tools/openapi/diff_openapi_endpoints.sh`
  - 스펙 변경 시 추가/삭제 엔드포인트 비교
- `tools/openapi/templates/*`
  - API/DTO/Repository/UseCase/Swift Testing 템플릿

## 사전 준비

- `jq` 설치 필요
- OpenAPI spec 파일 준비 (`openapi.json`)

## 기본 사용 흐름

1. View 요구사항 정의
2. 필요한 API 엔드포인트 목록 결정
3. 각 엔드포인트마다 스캐폴드 생성
4. TODO 채우기 (DTO, 도메인 매핑, DI 등록)
5. 테스트 보완

## 명령어

### 1) 엔드포인트 스캐폴드 생성

```bash
tools/openapi/generate_endpoint_scaffold.sh \
  --spec ./openapi.json \
  --feature Home \
  --path /api/v1/notices/recent \
  --method get
```

생성 위치:

- `AppName/AppName/Features/<Feature>/Data/Generated/*.generated.swift`
- `AppName/AppName/Features/<Feature>/Data/Generated/*.generated.meta.md`

### 2) 스펙 변경점 확인

```bash
tools/openapi/diff_openapi_endpoints.sh ./openapi-prev.json ./openapi.json
```

출력:

- Added endpoints
- Removed endpoints

## 내가 해야 하는 작업 vs Codex에게 줄 작업

### 내가 주면 좋은 입력

- 어떤 화면/유즈케이스인지
- 필요한 API 목록 (method + path)
- 응답에서 실제로 화면에 필요한 필드
- 인증 필요 여부

### Codex에게 맡기기 좋은 작업

- 스캐폴드 생성 및 파일 배치
- DTO 필드 채우기 초안
- Repository/UseCase 연결
- DIContainer 등록 포인트 제안
- Swift Testing 테스트 골격 작성

## 중요한 제한

- 템플릿은 "뼈대" 생성이 목적
- request/response 필드 타입은 스펙에 따라 수동 검토 필요
- Feature별 실제 도메인 모델 매핑은 수동 보정 필요
