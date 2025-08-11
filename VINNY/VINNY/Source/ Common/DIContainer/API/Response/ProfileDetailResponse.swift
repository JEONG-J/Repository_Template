import Foundation

struct GetProfileDTO: Decodable, Equatable {
    let userId: Int
    let nickname: String
    let profileImage: String?
    let comment: String?
    let postCount: Int
    let likedShopCount: Int
    let savedCount: Int
}

struct GetProfilePostDTO: Decodable {
    let postId: Int
    let imageUrl: String
}

// 3. 찜한 샵
struct GetProfileSavedShopDTO: Decodable {
    let shopId: Int
    let name: String
    let address: String
    let thumbnailUrl: String
    let vintageStyles: [String]
}
