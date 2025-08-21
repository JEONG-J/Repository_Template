//
//  ShopAPITarget.swift
//  VINNY
//
//  Created by 소민준 on 8/14/25.
//


// ShopAPITarget.swift
// ShopAPITarget.swift
import Foundation
import Moya

enum ShopAPITarget {
    case getDetail(id: Int)
    case ranking(page: Int, size: Int, region: [String]?, style: [String]?)
    case forYou(limit: Int)
    case shopLove(shopId: Int)
    case shopUnLove(shopId: Int)
}

extension ShopAPITarget: TargetType {
    var baseURL: URL { URL(string: "https://app.vinnydesign.net")! }
    var path: String {
        switch self {
        case .getDetail(let id):
            return "/api/shop/\(id)"           // Swagger: GET /api/shop/{shopId}
        case .ranking:
            return "/api/shops/ranking"
        case .forYou:
            return "/api/home/shops/for-you"
        case .shopLove(let shopId):
            return "/api/shops/\(shopId)/favorite"
        case .shopUnLove(let shopId):
            return "/api/shops/\(shopId)/favorite"
        }
    }
    var method: Moya.Method {
        switch self {
        case .getDetail:
            return .get
        case .ranking:
            return .get
        case .forYou:
            return .get
        case .shopLove:
            return .post
        case .shopUnLove:
            return .patch
        }
    }
    var task: Task {
        switch self {
        case .getDetail:
            return .requestPlain
        case let .ranking(page, size, region, style):
            var params: [String: Any] = ["page": page, "size": size]
            if let region, !region.isEmpty { params["region"] = region.joined(separator: ",") }
            if let style, !style.isEmpty { params["style"] = style.joined(separator: ",") }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .forYou(let limit):
            return .requestParameters(parameters: ["limit": limit], encoding: URLEncoding.queryString)
        case .shopLove:
            return .requestPlain
        case .shopUnLove:
            return .requestPlain
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
    var sampleData: Data {
        switch self {
        case .getDetail:
            return Data()
        case .ranking:
            let json = """
            {
              "isSuccess": true,
              "code": "COMMON200",
              "message": "성공입니다.",
              "result": [
                {
                  "shopId": 1,
                  "name": "빈티지 A",
                  "address": "서울시 마포구",
                  "region": "홍대",
                  "tags": ["밀리터리", "스트릿"],
                  "thumbnailUrl": "https://example.com/a.jpg"
                }
              ],
              "timestamp": "2025-08-17T09:23:50.497Z"
            }
            """
            return Data(json.utf8)
        case .forYou:
            return Data()
        case .shopLove:
            return Data()
        case .shopUnLove:
            return Data()
        }
    }
}

// 공용 provider + async 도우미 (SearchAPITarget과 동일 패턴)
private let shopProvider = MoyaProvider<ShopAPITarget>(
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

// 호출 함수

extension ShopAPITarget {
    static func getDetail(shopId: Int) async throws -> ShopDetailDTO {
        let res = try await shopProvider.asyncRequest(.getDetail(id: shopId))
        let decoded = try JSONDecoder().decode(ShopDetailResponseDTO.self, from: res.data)
        return decoded.result
    }
}

// MARK: - 랭킹 API 호출
extension ShopAPITarget {
    static func getRanking(
        page: Int,
        size: Int,
        region: [String]? = nil,
        style: [String]? = nil
    ) async throws -> [ShopByRankingDTO] {
        let res = try await shopProvider.asyncRequest(
            .ranking(page: page, size: size, region: region, style: style)
        )
        let decoded = try JSONDecoder().decode(ShopByRankingResponseDTO.self, from: res.data)
        return decoded.result
    }
    static func getForYou(limit: Int = 10) async throws -> [ShopForYouResponseDTO] {
        let res = try await shopProvider.asyncRequest(.forYou(limit: limit))
        return try JSONDecoder().decode([ShopForYouResponseDTO].self, from: res.data)
    }
}


extension ShopAPITarget {
    @discardableResult
    static func postShopLove(shopId: Int) async throws -> Int {
        let res = try await shopProvider.asyncRequest(.shopLove(shopId: shopId))
        return res.statusCode
    }

    @discardableResult
    static func toggleShopLove(shopId: Int, isLoved: Bool) async throws -> Int {
        let target: ShopAPITarget = isLoved ? .shopUnLove(shopId: shopId) : .shopLove(shopId: shopId)
        let res = try await shopProvider.asyncRequest(target)
        return res.statusCode
    }
}
