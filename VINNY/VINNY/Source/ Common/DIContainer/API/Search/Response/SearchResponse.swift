//
//  SearchResponse.swift
//  VINNY
//
//  Created by 소민준 on 8/11/25.
//

import Foundation

struct ShopSearchResponseDTO: Decodable {
    let isSuccess: Bool
    let code : String
    let message : String
    let result : ShopSearchResultDTO
    let timestamp: String
    
    
}
struct ShopSearchResultDTO: Decodable {
    let id: Int
    let name: String
    let address : String
    let addressDetail : String
    let region : String
    let style : [String]
    let imageUrl : String
    let status : String
    
}

struct PostSearchResponseDTO: Decodable {
    let isSuccess: Bool
    let code : String
    let message: String
    let result: PostSearchResultDTO
    let timestamp: String
}

struct PostSearchResultDTO: Decodable {
    let id: Int
    let imageUrl: [String]
}
