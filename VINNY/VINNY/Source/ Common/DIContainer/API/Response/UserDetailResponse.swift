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

struct ResetVintageStyleResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: String
    let timestamp: String
}

struct ResetVintageItemResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: String
    let timestamp: String
}

struct ResetRegionResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: String
    let timestamp: String
}

struct ResetBrandResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: String
    let timestamp: String
}
