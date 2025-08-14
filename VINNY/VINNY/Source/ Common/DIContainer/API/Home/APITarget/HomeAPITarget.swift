//
//  HomeAPITarget.swift
//  VINNY
//
//  Created by 소민준 on 8/15/25.
//

import Foundation
// MARK: - HomeAPITarget (For-You)
import Moya

enum HomeAPITarget {
    case getForYou(limit: Int?)
}

extension HomeAPITarget: TargetType {
    var baseURL: URL { URL(string: "https://app.vinnydesign.net/api")! }

    var path: String {
        switch self {
        case .getForYou:
            return "/home/shops/for-you"
        }
    }

    var method: Moya.Method { .get }

    var task: Task {
        switch self {
        case let .getForYou(limit):
            var params: [String: Any] = [:]
            if let limit { params["limit"] = limit }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
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
        return h
    }

    var sampleData: Data { Data() }
}

// 개별 provider (다른 파일의 private asyncRequest 확장이랑 충돌 피하려고 여기서 직접 request 사용)
private let homeProvider = MoyaProvider<HomeAPITarget>(
    plugins: [NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))]
)

extension HomeAPITarget {
    // 최상위 배열 반환 엔드포인트
    static func getForYouShops(limit: Int? = nil) async throws -> [ForYouShopDTO] {
        try await withCheckedThrowingContinuation { cont in
            homeProvider.request(.getForYou(limit: limit)) { result in
                switch result {
                case .success(let res):
                    do {
                        let items = try JSONDecoder().decode([ForYouShopDTO].self, from: res.data)
                        cont.resume(returning: items)
                    } catch {
                        cont.resume(throwing: error)
                    }
                case .failure(let err):
                    cont.resume(throwing: err)
                }
            }
        }
    }
}
