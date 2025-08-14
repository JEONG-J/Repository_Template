//
//  PostAPITarget.swift
//  VINNY
//
//  Created by 소민준 on 8/15/25.
//



import Foundation
import Moya

enum PostAPITarget {
    case getPosts(page: Int, size: Int)
}

extension PostAPITarget: TargetType {
    var baseURL: URL { URL(string: "https://app.vinnydesign.net")! }

    var path: String {
        switch self {
        case .getPosts:
            return "/api/post"
        }
    }

    var method: Moya.Method { .get }

    var task: Task {
        switch self {
        case let .getPosts(page, size):
            return .requestParameters(
                parameters: ["page": page, "size": size],
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

private let postProvider = MoyaProvider<PostAPITarget>(
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

extension PostAPITarget {
    static func getPosts(page: Int = 0, size: Int = 10) async throws -> PostListResultDTO {
        let res = try await postProvider.asyncRequest(.getPosts(page: page, size: size))
        let decoded = try JSONDecoder().decode(PostListResponseDTO.self, from: res.data)
        return decoded.result
    }
}
