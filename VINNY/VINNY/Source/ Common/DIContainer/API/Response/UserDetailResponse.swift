import Foundation

struct YourSavedShopResponse: Codable {
    let shopId: Int
    let name: String
    let address: String
    let region: String
    let styles: [String]
    let imageUrls: [String]
}

//struct YourSavedShop: Codable {
//    let shopId: Int
//    let name: String
//    let address: String
//    let region: String
//    let styles: [String]
//    let imageUrls: [String]
//}

struct yourProfileResponse: Codable {
    let userId: Int
    let nickname: String
    let comment: String?
    let postCount: Int
    let bookmarkCount: Int
    let profileImageUrl : String
    let backgroundImageUrl : String?
}

struct yourPostResponse: Codable {
    let postId: Int
    let imageUrl: String?
    let createdAt: String
}

//struct YourPost: Codable {
//    let postId: Int
//    let imageUrl: String
//    let createdAt: String
//}
