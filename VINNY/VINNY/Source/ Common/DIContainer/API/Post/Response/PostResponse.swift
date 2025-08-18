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


// MARK: - GET /api/post/{postId} (Detail)
struct PostDetailResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: PostDetailDTO
    let timestamp: String
}

struct PostDetailDTO: Decodable, Hashable {
    let postId: Int
    let title: String
    let author: PostAuthorDTO
    let content: String
    let images: [String]
    let createdAt: String
    let createdAtRelative: String
    let likesCount: Int
    let bookmarkedByMe: Bool
    let shop: PostShopMiniDTO?
    let styles: [PostStyleMiniDTO]
    let brand: PostBrandMiniDTO?
    let likedByMe: Bool
}


// MARK: - POST /api/post (Create)
struct CreatePostRequestDTO: Encodable {
    let title: String
    let content: String
    let shopId: Int?
    let styleId: Int?
    let brandId: Int?
}

struct CreatePostResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: CreatePostResultDTO
    let timestamp: String
}

struct CreatePostResultDTO: Decodable {
    let postId: Int
}

// MARK: - PUT /api/post/{postId} (Update)


struct UpdatePostResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: CreatePostResultDTO   // server returns { postId }, same shape as create
    let timestamp: String
}

//게시글 좋아요 누르기
struct PostLikeDTO: Decodable {
    let isSuccess : Bool
    let code : String
    let message: String
    let result : String
    let timestamp :String
}


