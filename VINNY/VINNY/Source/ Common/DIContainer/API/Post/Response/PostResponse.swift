//
//  PostResponse.swift
//  VINNY
//
//  Created by 소민준 on 8/15/25.
//


import Foundation

// MARK: - GET /api/post (Paged list)
struct PostListResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: PostListResultDTO
    let timestamp: String
}

struct PostListResultDTO: Decodable {
    let posts: [PostItemDTO]
    let pageInfo: PageInfoDTO
}

struct PageInfoDTO: Decodable {
    let page: Int
    let size: Int
    let totalPages: Int
    let totalElements: Int
}

struct PostItemDTO: Decodable, Hashable {
    let postId: Int
    let author: PostAuthorDTO
    let title: String
    let content: String
    let images: [String]
    let createdAt: String
    let createdAtRelative: String
    let likesCount: Int
    let bookmarkedByMe: Bool
    let shop: PostShopMiniDTO?
    let style: PostStyleMiniDTO?
    let brand: PostBrandMiniDTO?
    let likedByMe: Bool
}

struct PostAuthorDTO: Decodable, Hashable {
    let userId: Int
    let nickname: String
    let profileImageUrl: String?
    let comment: String?
}

struct PostShopMiniDTO: Decodable, Hashable {
    let shopId: Int
    let shopName: String
}

struct PostStyleMiniDTO: Decodable, Hashable {
    let styleId: Int
    let styleName: String
}

struct PostBrandMiniDTO: Decodable, Hashable {
    let brandId: Int
    let brandName: String
}
