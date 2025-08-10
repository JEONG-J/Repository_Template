//수정 예정
import Foundation

struct ShopListResult: Codable {
    let totalPages: Int
    let totalElements: Int
    let size: Int
    let content: [ShopContent]
    let number: Int
    let sort: ShopSortInfo
    let numberOfElements: Int
    let pageable: ShopPageable
    let last: Bool
    let first: Bool
    let empty: Bool
}

struct ShopContent: Codable {
    let id: Int
    let name: String
    let address: String
    let addressDetail: String
    let region: String
    let styles: [String]
    let imageUrl: String
    let status: String
}

struct ShopSortInfo: Codable {
    let empty: Bool
    let sorted: Bool
    let unsorted: Bool
}

struct ShopPageable: Codable {
    let offset: Int
    let sort: PostSortInfo
    let paged: Bool
    let pageNumber: Int
    let pageSize: Int
    let unpaged: Bool
}

struct PostListResult: Codable {
    let totalPages: Int
    let totalElements: Int
    let size: Int
    let content: [PostContent]
    let number: Int
    let sort: PostSortInfo
    let numberOfElements: Int
    let pageable: PostPageable
    let last: Bool
    let first: Bool
    let empty: Bool
}

struct PostContent: Codable {
    let id: Int
    let title: String
    let content: String
    let author: Author
    let images: [String]
    let styles: [String]
    let createdAt: String // or Date if you want
    let totalImageCount: Int
    let likeCount: Int
}

struct Author: Codable {
    let id: Int
    let nickname: String
    let profileImage: String
    let comment: String
}

struct PostSortInfo: Codable {
    let empty: Bool
    let sorted: Bool
    let unsorted: Bool
}

struct PostPageable: Codable {
    let offset: Int
    let sort: PostSortInfo
    let paged: Bool
    let pageNumber: Int
    let pageSize: Int
    let unpaged: Bool
}
