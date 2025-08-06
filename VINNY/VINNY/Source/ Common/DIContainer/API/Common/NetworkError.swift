//  네트워크 통신 중 발생할 수 있는 에러들을 통합적으로 처리하기 위한 열거형.
//  SwiftUI에서도 ViewModel에서 error.localizedDescription으로 사용자에게 에러 메시지를 쉽게 보여줄 수 있도록 설계함.
// 얘는 추가적인 코드 추가가 거의 필요없음

import Foundation
// MARK: - 네트워크 오류 타입 정의

/// 네트워크 요청 중 발생할 수 있는 다양한 오류를 정의.
/// 각 case는 실제 서비스에서 발생할 수 있는 일반적인 상황을 커버함.
public enum NetworkError: Error {
    
    /// 인터넷 연결이 없거나 서버에 연결할 수 없음.
    case networkError(message: String)
    /// JSON 디코딩에 실패했을 때.
    case decodingError(underlyingError: DecodingError)
    /// 서버가 에러 응답을 반환했을 때 (상태 코드 기반).
    case serverError(statusCode: Int, message: String)
    /// 원인을 특정할 수 없는 기타 오류.
    case unknown
}

// MARK: - 사용자에게 보여줄 수 있는 에러 메시지 구현

/// Swift의 LocalizedError 프로토콜을 채택하여
/// 각 에러에 맞는 사용자 친화적인 메시지를 제공.
/// 이걸 통해 ViewModel에서 `error.localizedDescription` 으로 간단히 에러 메시지를 표시할 수 있음.
extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .networkError(let msg):
            return "네트워크 오류: \(msg)"
            
        case .decodingError(let err):
            return "디코딩 오류: \(err.localizedDescription)"
            
        case .serverError(let code, let msg):
            return "서버 오류 \(code): \(msg)"
            
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}

