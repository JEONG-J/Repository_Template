//
//  ShopAPITarget.swift
//  VINNY
//
//  Created by 소민준 on 8/14/25.
//


// ShopAPITarget.swift
// ShopAPITarget.swift  ✅ 신규
import Foundation
import Moya

enum ShopAPITarget {
    case getDetail(id: Int)
}

extension ShopAPITarget: TargetType {
    var baseURL: URL { URL(string: "https://app.vinnydesign.net")! }
    var path: String {
        switch self {
        case .getDetail(let id):
            return "/api/shop/\(id)"           // Swagger: GET /api/shop/{shopId}
        }
    }
    var method: Moya.Method { .get }
    var task: Task { .requestPlain }
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
