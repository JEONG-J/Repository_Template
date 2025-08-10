import Foundation
import Moya

enum OnboardAPITarget {
    /// 온보딩 정보 전송 (POST)
    /// body: OnboardRequestDTO
    case submit(dto: OnboardRequestDTO)
}

extension OnboardAPITarget: TargetType {
    var baseURL: URL {
        // 명세서와 동일 도메인
        return URL(string: "https://app.vinnydesign.net/")!
    }

    var path: String {
        switch self {
        case .submit:
            return "api/users/me/onboard"
        }
    }

    var method: Moya.Method {
        switch self {
        case .submit:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .submit(let dto):
            return .requestJSONEncodable(dto)
        }
    }

    var headers: [String : String]? {
        // 기본 헤더 + (응급 보강) Authorization 직접 주입
        var h: [String: String] = ["Content-Type": "application/json"]
        if let token = KeychainHelper.shared.get(forKey: "accessToken"), !token.isEmpty {
            h["Authorization"] = "Bearer \(token)"
        }
        return h
    }

    var sampleData: Data {
        return """
        {
          "isSuccess": true,
          "code": "COMMON200",
          "message": "성공입니다.",
          "result": "OK",
          "timestamp": "2025-08-09T08:24:00.936Z"
        }
        """.data(using: .utf8) ?? Data()
    }
}

// 이 타겟은 Bearer 토큰이 필요함을 명시
extension OnboardAPITarget: AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? { .bearer }
}
