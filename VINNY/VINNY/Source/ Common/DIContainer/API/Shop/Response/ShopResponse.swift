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
    let elapsedTime: String
    let imageUrls: [String]
}

//홈뷰에서 랭킹별 가게 조회

struct ShopByRankingResponseDTO: Decodable {
    let isSuccess : Bool
    let code : String
    let message: String
    let result : [ShopByRankingDTO]
    let timestamp: String
}

struct ShopByRankingDTO: Decodable {

    let shopId : Int
    let name: String
    let address :String
    let region :String
    let tags: [String]
    let thumbnailUrl : String?
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

struct ShopImageDTO: Decodable {
    let url: String
    let main: Bool
}

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
    let images: [ShopImageDTO]?
    let logoImage: String
    let shopVintageStyleList: [VintageStyleDTO]?
}

struct VintageStyleDTO: Decodable, Hashable {
    let id: Int
    let vintageStyleName: String
}

//홈에 취향 저격 가게 
struct ShopForYouResponseDTO: Decodable {
    let id: Int
    let name: String
    let openTime: String?
    let closeTime: String?
    let instagram: String?
    let address: String?
    let logoImage: String
    let images: ShopImageDTO       // single image object
    let shopVintageStyleList: [VintageStyleDTO]?
}


// 가게 찜
struct ShopLoveResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: ShopResultDTO?
    let timestamp: String
}


struct ShopLoveCancelResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: String?             // ← 문자열!
    let timestamp: String
}
