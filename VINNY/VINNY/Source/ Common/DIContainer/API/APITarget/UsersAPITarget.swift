//
//  CoursesAPITarger.swift
//  VINNY
//
//  Created by 홍지우 on 6/25/25.
//

import Foundation
import Moya

// 공통 응답 제네릭 (없을 경우 대비)
struct CommonResponseDTO<T: Decodable>: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: T
    let timestamp: String
}

enum UsersAPITarget {
    //코스 상세정보 API
    case getYourSavedShop(userId: Int)
    case getYourProfile(userId: Int)
    case getYourPost(userId: Int)

    // 취향 재설정 API
    case resetVintageStyle(ResetVintageStyleRequestDTO)
    case resetVintageItem(ResetVintageItemRequestDTO)
    case resetRegion(ResetRegionRequestDTO)
    case resetBrand(ResetBrandRequestDTO)
}

extension UsersAPITarget: TargetType {
    
    
    var headers: [String : String]? {
        var h: [String: String] = [
            "Accept": "application/json",
            "Accept-Language": "ko-KR,ko;q=0.9"
        ]

        if let token = KeychainHelper.shared.get(forKey: "accessToken"), !token.isEmpty {
            h["Authorization"] = "Bearer \(token)"
        }

        h["Content-Type"] = "application/json"

        return h
    }
    
    var baseURL: URL {
        // NOTE: users 엔드포인트에 정확히 붙도록 고정
        return URL(string: "https://app.vinnydesign.net/api/users")!
    }
    
    var path: String {
        switch self {
        case .getYourSavedShop(let userId):
            return "\(userId)/shops/favorites"
        case .getYourProfile(let userId):
            return "\(userId)/profile"
        case .getYourPost(let userId):
            return "\(userId)/posts"
        case .resetVintageStyle:
            return "me/reset/vintage-style"
        case .resetVintageItem:
            return "me/reset/vintage-item"
        case .resetRegion:
            return "me/reset/region"
        case .resetBrand:
            return "me/reset/brand"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getYourSavedShop, .getYourProfile, .getYourPost:
            return .get
        case .resetVintageStyle, .resetVintageItem, .resetRegion, .resetBrand:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .getYourSavedShop, .getYourProfile, .getYourPost:
            return .requestPlain
        case .resetVintageStyle(let body):
            return .requestJSONEncodable(body)
        case .resetVintageItem(let body):
            return .requestJSONEncodable(body)
        case .resetRegion(let body):
            return .requestJSONEncodable(body)
        case .resetBrand(let body):
            return .requestJSONEncodable(body)
        }
    }
}

extension UsersAPITarget {
    private static let provider = MoyaProvider<UsersAPITarget>(plugins: [NetworkLoggerPlugin()])
    
    static func resetVintageStyle(ids: [Int]) async throws -> ResetVintageStyleResponseDTO {
        let dto = ResetVintageStyleRequestDTO(vintageStyleIds: ids)
        let response = try await provider.request(.resetVintageStyle(dto))
        return try response.map(ResetVintageStyleResponseDTO.self)
    }
    
    static func resetVintageItem(ids: [Int]) async throws -> ResetVintageItemResponseDTO {
        let dto = ResetVintageItemRequestDTO(vintageItemIds: ids)
        let response = try await provider.request(.resetVintageItem(dto))
        return try response.map(ResetVintageItemResponseDTO.self)
    }
    
    static func resetRegion(ids: [Int]) async throws -> ResetRegionResponseDTO {
        let dto = ResetRegionRequestDTO(regionIds: ids)
        let response = try await provider.request(.resetRegion(dto))
        return try response.map(ResetRegionResponseDTO.self)
    }
    
    static func resetBrand(ids: [Int]) async throws -> ResetBrandResponseDTO {
        let dto = ResetBrandRequestDTO(brandIds: ids)
        let response = try await provider.request(.resetBrand(dto))
        return try response.map(ResetBrandResponseDTO.self)
    }
}
