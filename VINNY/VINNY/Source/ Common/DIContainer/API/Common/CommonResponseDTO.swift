//  서버 응답 형식에 맞춘 공통 DTO(Data Transfer Object) 정의 파일.
//  모든 API 응답은 이 구조체를 통해 디코딩되며, 통일된 방식으로 결과를 처리할 수 있음.
// 얘는 추가적인 코드 추가가 거의 필요없음

import Foundation


// MARK: - 공통 응답 포맷 (성공 응답)
// 대부분의 API 응답이 다음과 같은 구조로 전달됨:
// {
//   "isSuccess": true,
//   "code": "SUCCESS",
//   "message": "요청에 성공했습니다.",
//   "result": { ... }
// }

// 제네릭으로 감싸서 어떤 타입이 오더라도 result를 추출 가능.⭐️⭐️⭐️
public struct ApiResponse<T: Decodable>: Decodable {
    public let isSuccess: Bool    // 요청 성공 여부
    public let code: String       // 서버에서 정의한 상태 코드 (예: "SUCCESS", "USER_NOT_FOUND")
    public let message: String    // 상태 메시지
    public let result: T?         // 실제 응답 데이터 (없을 수도 있음)
}

// MARK: - 에러 응답 파싱용 구조체

// 서버가 에러 응답 시 아래 구조로 반환할 수 있음:
// {
//   "message": "토큰이 유효하지 않습니다."
// }

// 이 구조체는 서버 에러 메시지를 파싱할 때 사용됨.
public struct ErrorResponse: Decodable {
    public let message: String    // 에러 메시지 내용
}

// MARK: - 빈 응답 처리용 구조체

// 어떤 API는 실제로 반환할 데이터가 없는 경우도 있음.
// 예: 상태 코드만으로 성공 여부 확인 (204 No Content 등)

// 그럴 때 용도로 사용하는 빈 응답 타입.
public struct EmptyResponse: Decodable {}

