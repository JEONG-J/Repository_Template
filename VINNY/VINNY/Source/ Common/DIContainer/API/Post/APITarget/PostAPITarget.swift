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
    case getPostDetail(postId: Int)
    case createPost(dto: CreatePostRequestDTO, images: [Data])
    case updatePost(postId: Int, body: UpdatePostRequestDTO)
    case deletePost(postId: Int)
    case likePost(postId: Int)
    case unlikePost(postId: Int)
}

extension PostAPITarget: TargetType {
    var baseURL: URL { URL(string: "https://app.vinnydesign.net")! }

    var path: String {
        switch self {
        case .getPosts:
            return "/api/post"
        case .getPostDetail(let postId):
            return "/api/post/\(postId)"
        case .createPost:
            return "/api/post"
        case .updatePost(let postId, _):
            return "/api/post/\(postId)"
        case .deletePost(let postId):
            return "/api/post/\(postId)"
        case .likePost(let postId):
            return "/api/post/\(postId)/likes"
        case .unlikePost(let postId):
            return "/api/post/\(postId)/likes"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getPosts, .getPostDetail:
            return .get
        case .createPost:
            return .post
        case .updatePost:
            return .patch
        case .deletePost:
            return .delete
        case .likePost:
            return .post
        case .unlikePost:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case let .getPosts(page, size):
            return .requestParameters(
                parameters: ["page": page, "size": size],
                encoding: URLEncoding.queryString
            )

        case .getPostDetail:
            return .requestPlain

        case let .createPost(dto, images):
            var parts: [MultipartFormData] = []

            // Encode DTO as JSON and send as a form part named "dto"
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            if let jsonData = try? encoder.encode(dto) {
                parts.append(MultipartFormData(
                    provider: .data(jsonData),
                    name: "dto",
                    fileName: "dto.json",
                    mimeType: "application/json"
                ))
            }

            // Attach images[]
            for (idx, data) in images.enumerated() {
                parts.append(MultipartFormData(
                    provider: .data(data),
                    name: "images",
                    fileName: "image_\(idx).jpg",
                    mimeType: "image/jpeg"
                ))
            }

            return .uploadMultipart(parts)
        case let .updatePost(_, body):
            return .requestJSONEncodable(body)
        case .deletePost:
            return .requestPlain
        case .likePost:
            return .requestPlain
        case .unlikePost:
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
        switch self {
        case .createPost:
            // Explicitly set multipart content type for createPost
            h["Content-Type"] = "multipart/form-data"
        default:
            h["Content-Type"] = "application/json"
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
        #if DEBUG
        print("[Moya] → Request: \(type(of: self)) \(target.method.rawValue) \(target.path)")
        if let headers = target.headers { print("[Moya] Headers: \(headers)") }
        #endif
        return try await withCheckedThrowingContinuation { cont in
            self.request(target) { result in
                switch result {
                case .success(let r):
                    #if DEBUG
                    let bodyPreview = String(data: r.data.prefix(512), encoding: .utf8) ?? "«non-utf8»"
                    print("[Moya] ← Response: \(r.statusCode) for \(target.path)\nBody: \(bodyPreview)")
                    #endif
                    cont.resume(returning: r)
                case .failure(let e):
                    #if DEBUG
                    print("[Moya] ← Failure for \(target.path): \(e)")
                    #endif
                    cont.resume(throwing: e)
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

    static func fetchPostDetail(postId: Int) async throws -> PostDetailDTO {
        let res = try await postProvider.asyncRequest(.getPostDetail(postId: postId))
        let decoded = try JSONDecoder().decode(PostDetailResponseDTO.self, from: res.data)
        return decoded.result
    }
    
    static func submitPost(dto: CreatePostRequestDTO, images: [Data]) async throws -> Int {
        #if DEBUG
        print("[PostAPI] submitPost called — title: \(dto.title), images: \(images.count)")
        #endif
        let res = try await postProvider.asyncRequest(.createPost(dto: dto, images: images))
        #if DEBUG
        print("[PostAPI] submitPost response status: \(res.statusCode)")
        #endif
        let decoded = try JSONDecoder().decode(CreatePostResponseDTO.self, from: res.data)
        #if DEBUG
        print("[PostAPI] submitPost decoded postId: \(decoded.result.postId)")
        #endif
        return decoded.result.postId
    }
    
    @discardableResult
    static func submitPostUpdate(postId: Int, body: UpdatePostRequestDTO) async throws -> Int {
        #if DEBUG
        print("[PostAPI] submitPostUpdate called — id: \(postId)")
        #endif
        let res = try await postProvider.asyncRequest(.updatePost(postId: postId, body: body))
        #if DEBUG
        print("[PostAPI] submitPostUpdate status: \(res.statusCode)")
        if let raw = String(data: res.data, encoding: .utf8) { print("[PostAPI] submitPostUpdate raw: \(raw)") }
        #endif
        if (200...299).contains(res.statusCode) { return res.statusCode }
        throw NSError(domain: "PostAPI", code: res.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(res.statusCode)"])
    }
    
    @discardableResult
    static func performDelete(postId: Int) async throws -> Int {
        #if DEBUG
        print("[PostAPI] performDelete called — postId: \(postId)")
        #endif
        let res = try await postProvider.asyncRequest(.deletePost(postId: postId))
        #if DEBUG
        print("[PostAPI] performDelete status: \(res.statusCode)")
        #endif
        return res.statusCode
    }
    
    @discardableResult
    static func performLike(postId: Int, isCurrentLiked: Bool) async throws -> Int {
        let target: PostAPITarget = isCurrentLiked ? .unlikePost(postId: postId) : .likePost(postId: postId)
        let res = try await postProvider.asyncRequest(target)
        return res.statusCode
    }
    
}
