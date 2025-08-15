//
//  ShopResponse.swift
//  VINNY
//
//  Created by 소민준 on 8/12/25.
//

import Foundation

//가게 상세조회 api

struct ShopInfoResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: ShopResultDTO      // ← 배열 ❌, 단일 객체 ✅
    let timestamp: String
}

struct ShopResultDTO: Decodable {
    let reviewId: Int
    let title: String
    let content: String
    let userName: String
    let elapsedTime: String        // ← 철자 'elapsed'로 통일
    let imageUrls: [String]
}

//홈뷰에서 스타일별 가게 조회

struct ShopByStyleResponseDTO: Decodable {
    let isSuccess : Bool
    let code : String
    let message: String
    let result : [ShopByStyleResultDTO]
    let timestamp: String
}

struct ShopByStyleResultDTO: Decodable {

    let shops: [ShopInfoResultDTO]
    let totalPages: Int
    let totalElements: Int
}

struct ShopInfoResultDTO: Decodable{
    
    let reviewID : Int
    let title : String
    let content :String
    let userName :String
    let elaspedTime: String
    let imageUrls :[String]
    
}
// MARK: - Shop Detail (GET /api/shop/{shopId})
struct ShopDetailResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: ShopDetailDTO
    let timestamp: String
}

struct ShopDetailDTO: Decodable {
    let id: Int
    let name: String
    let intro: String?
    let description: String?
    let status: String?
    let openTime: String?
    let closeTime: String?
    let instagram: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let region: String?
    let images: [String]?
    let shopVintageStyleList: [VintageStyleDTO]?
}

struct VintageStyleDTO: Decodable {
    let id: Int
    let vintageStyleName: String
}
