//
//  AutoCompleteAPITarget.swift
//  VINNY
//
//  Created by 소민준 on 8/18/25.
//


import Foundation
import Moya

enum AutoCompleteAPITarget {
    case shops(keyword: String)
    case brands(keyword: String)
}

extension AutoCompleteAPITarget: TargetType {
    var baseURL: URL { URL(string: "https://app.vinnydesign.net")! }

    var path: String {
        switch self {
        case .shops:
            return "/api/autocomplete/shops"
        case .brands:
            return "/api/autocomplete/brands"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case .shops(let keyword), .brands(let keyword):
            return .requestParameters(parameters: ["keyword": keyword], encoding: URLEncoding.queryString)
        }
    }

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
    var sampleData: Data { Data() }
}

private let autoProvider = MoyaProvider<AutoCompleteAPITarget>(plugins: [NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))])

extension AutoCompleteAPITarget {
    static func fetchShopAutoComplete(keyword: String) async throws -> [AutoCompleteShopDTO] {
        let res = try await autoProvider.request(.shops(keyword: keyword))
        let decoded = try JSONDecoder().decode(AutoCompleteShopsResponseDTO.self, from: res.data)
        return decoded.result
    }
    static func fetchBrandAutoComplete(keyword: String) async throws -> [AutoCompleteBrandDTO] {
        let res = try await autoProvider.request(.brands(keyword: keyword))
        let decoded = try JSONDecoder().decode(AutoCompleteBrandsResponseDTO.self, from: res.data)
        return decoded.result
    }
}
