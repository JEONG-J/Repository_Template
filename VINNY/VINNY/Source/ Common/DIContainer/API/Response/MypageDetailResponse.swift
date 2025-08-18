import Foundation

//마이 페이지 프로필 정보 조회
struct MypageProfileResponse: Decodable, Equatable {
    let userId: Int
    let nickname: String
    var profileImage: String?
    var backgroundImage: String?
    let comment: String
    let postCount: Int
    let likedShopCount: Int
    let savedCount: Int
}

//작성한 게시글 썸네일 목록 조회
struct MypageWrittenPostsResponse: Decodable {
    let postId: Int
    let imageUrl: String
}

// 찜한 샵 목록 조회
struct MypageSavedShopsResponse: Decodable {
    let shopId: Int
    let name: String
    let regionName: String
    let address: String
    let thumbnailUrl: String
    let vintageStyles: [String]
}

//저장한 게시글 이미지 리스트 조회
struct MypageSavedPostsResponse: Decodable {
    let postId: Int
    let imageUrl: String?
}

struct MypageUpdateProfileResponse: Decodable {
    let userId: Int
    let nickname: String
    let profileImage: String?
    let backgroundImage: String?
    let comment: String
}

struct MypageUpdateProfileImageResponse: Decodable {
    let userId: Int
    let nickname: String
    let profileImage: String
    let backgroundImage: String?
    let comment: String
}

struct MypageUpdateBackgroundImageResponse: Decodable {
    let userId: Int
    let nickname: String
    let profileImage: String?
    let backgroundImage: String
    let comment: String
}
