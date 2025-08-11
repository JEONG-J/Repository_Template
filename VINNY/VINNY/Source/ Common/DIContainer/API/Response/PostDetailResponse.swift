import Foundation

struct PostDetailResponse: Codable {
    let success: Bool
    let message: String
    let status: Int
    let data: PostData?
    let timestamp: String
}

struct PostData: Codable {
    let postId: Int
}
