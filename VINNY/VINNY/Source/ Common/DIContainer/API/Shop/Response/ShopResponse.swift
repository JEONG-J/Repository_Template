//
//  ShopResponse.swift
//  VINNY
//
//  Created by 소민준 on 8/12/25.
//

import Foundation

//가게 상세조회 api

struct ShopInfoResponseDTO: Decodable {
    let isSuccess : Bool
    let code : String
    let message: String
    let result: [ShopResultDTO]
    let timestamp: String
}
struct ShopResultDTO:Decodable {
    let reviewId: Int
    let title: String
    let content:String
    let userName:String
    let elapsedTime: String
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
