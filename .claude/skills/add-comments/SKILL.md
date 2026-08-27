---
name: add-comments
description: Add Swift documentation comments and MARK sections to changed files. Use when user wants to add comments to modified code.
disable-model-invocation: false
argument-hint: [optional: specific file path]
---

# Add Comments Skill

이 스킬은 변경된 Swift 파일에 주석을 자동으로 추가합니다.

## 작업 절차

### 1. 변경된 파일 확인

**인자가 제공된 경우:**
- 제공된 파일 경로에만 주석 추가

**인자가 없는 경우 (기본):**
- `git status`로 변경된 `.swift` 파일 찾기 (M, A, AM 상태만)
- Untracked 파일은 제외
- 최대 30개 파일까지 처리

### 2. 각 파일에 대해 주석 추가

**반드시 `.claude/local.md`의 Swift 주석 컨벤션을 따르세요.**

#### 필수 작업:

1. **MARK 섹션 추가** (없는 경우만)
   ```swift
   // MARK: - Property
   // MARK: - Body
   // MARK: - Function
   ```

2. **문서화 주석 (`///`)** 추가
   - Public 함수/변수/클래스/구조체에만 추가
   - Private은 필요시에만 추가
   - 다음 키워드 활용:
     - `- Parameters:` 파라미터 설명
     - `- Returns:` 반환값 설명
     - `- Throws:` 발생 가능한 에러
     - `- Important:` 중요 사항
     - `- Warning:` 경고
     - `- Note:` 참고사항
     - `- Example:` 사용 예시

3. **복잡한 로직에 인라인 주석** (`//`)
   - 3줄 이상의 복잡한 로직
   - 비즈니스 로직 설명
   - "왜" 이렇게 했는지 설명 (what이 아니라 why)

#### 주석 추가 규칙:

**추가해야 할 것:**
- Public API (protocol, public func/var/struct/class)
- 복잡한 알고리즘이나 비즈니스 로직
- 이해하기 어려운 코드 (예: 수학 공식, 정규식)
- UseCase, Repository, ViewModel의 주요 메서드

**추가하지 말아야 할 것:**
- 자명한 코드 (예: `let name = user.name`)
- SwiftUI View의 단순한 body
- getter/setter
- 이미 충분히 설명적인 함수명/변수명

### 3. 출력 형식

각 파일 처리 후:
```
✅ {파일명}: {추가된 주석 개수}개 주석 추가
   - 문서화 주석: X개
   - MARK 섹션: Y개
   - 인라인 주석: Z개
```

모든 파일 처리 후 요약:
```
📝 주석 추가 완료
총 {N}개 파일, {M}개 주석 추가
```

## 예시

### 사용법 1: 변경된 모든 파일에 주석 추가
```
/add-comments
```

### 사용법 2: 특정 파일에만 주석 추가
```
/add-comments AppName/Features/MyPage/Presentation/ViewModels/MyPageViewModel.swift
```

## 주의사항

- **기존 주석은 수정하지 않음** (새로 추가만 함)
- **코드 로직은 절대 변경하지 않음**
- **이미 주석이 있는 부분은 건너뜀**
- **CLAUDE.md의 "변경하지 않은 코드에는 주석 추가 금지" 원칙 준수**

## 참고

- `.claude/local.md` - Swift 주석 컨벤션
- `CLAUDE.md` - 프로젝트 코딩 스타일
