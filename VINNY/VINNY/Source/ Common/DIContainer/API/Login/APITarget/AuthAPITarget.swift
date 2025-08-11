//
//  AuthAPITarget.swift
//  VINNY
//
//  Created by 소민준 on 8/6/25.
//


// AuthAPITarget.swiftimport Foundation
import Moya
import Foundation

enum AuthAPITarget {
    case login(dto: LoginRequestDTO)
    case reissueToken(dto: ReissueTokenRequestDTO)
    case fetchMe
    case session
    
}

extension AuthAPITarget: TargetType {
    var baseURL: URL {
        return URL(string:"https://app.vinnydesign.net/")! // 명세서 URL
    }

    var path: String {
        switch self {
        case .login:
            return "api/auth/login/kakao"
        case .reissueToken:
            return "api/auth/reissue"
        case .fetchMe:
            return "api/auth/me"
        case .session:
            return "api/auth/session"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login, .reissueToken:
            return .post
        case .session, .fetchMe:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .login(let dto):
            return .requestJSONEncodable(dto)
        case .reissueToken(let dto):
            return .requestJSONEncodable(dto)
        case .fetchMe:
            return .requestPlain
        case .session:
            return .requestPlain
        }
    }

    var headers: [String : String]? {
            return [
                "Content-Type": "application/json",
                "Accept": "*/*",
                "Accept-Language": "ko-KR,ko;q=0.9"
            ]
        }

    var sampleData: Data {
        return Data()
    }
}
extension AuthAPITarget: AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        switch self {
        case .login, .reissueToken: return .none
        case .fetchMe, .session:    return .bearer   
        }
    }
}
