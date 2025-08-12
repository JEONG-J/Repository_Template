// SearchAPITarget.swift

import Foundation
import Moya

enum SearchAPITarget {
    case getSearchShop(keyword: String)
    case getSearchPost(keyword: String)
}

extension SearchAPITarget: TargetType {
    var baseURL: URL { URL(string: "https://app.vinnydesign.net")! }

    var path: String {
        switch self {
        case .getSearchShop: return "/api/search/shop/search"
        case .getSearchPost: return "/api/search/posts/search"
        }
    }

    var method: Moya.Method { .get }

    var task: Task {
        switch self {
        case let .getSearchShop(keyword),
             let .getSearchPost(keyword):
            return .requestParameters(
                parameters: ["keyword": keyword],
                encoding: URLEncoding.queryString
            )
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

// 공용 Provider + async 도우미
private let searchProvider = MoyaProvider<SearchAPITarget>(
    plugins: [NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))]
)

private extension MoyaProvider {
    func asyncRequest(_ target: Target) async throws -> Response {
        try await withCheckedThrowingContinuation { cont in
            self.request(target) { result in
                switch result {
                case .success(let r): cont.resume(returning: r)
                case .failure(let e): cont.resume(throwing: e)
                }
            }
        }
    }
}

// 🔗 호출 함수 (Service 역할 통합)
// ⛳️ 주의: 현재 네 DTO는 result가 '단일 객체'로 정의되어 있으므로 배열로 반환하려면 감싸서 돌려준다.
extension SearchAPITarget {
    static func searchShops(keyword: String) async throws -> [Shops] {
        let res = try await searchProvider.asyncRequest(.getSearchShop(keyword: keyword))
        let decoded = try JSONDecoder().decode(ShopSearchResponseDTO.self, from: res.data)
        let shops = decoded.result.map(Shops.init(from:))
        print("✅ decoded shops count:", shops.count)   // ← 디버그
        return shops
    }

    static func searchPosts(keyword: String) async throws -> [PostSearchResultDTO] {
            let res = try await searchProvider.asyncRequest(.getSearchPost(keyword: keyword))
            let decoded = try JSONDecoder().decode(PostSearchResponseDTO.self, from: res.data)
            return decoded.result              // ← 이제 배열 그대로 반환
        }
    }
