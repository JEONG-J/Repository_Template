//
//  AutoCompleteResponse.swift
//  VINNY
//
//  Created by 소민준 on 8/18/25.
//

import Foundation

//샵검색

struct AutoCompleteShopDTO: Decodable {
    let name: String
    let imageUrl: String
    let address: String
}

struct AutoCompleteShopsResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [AutoCompleteShopDTO]
    let timestamp: String
}

// 브랜드 자동완성 
struct AutoCompleteBrandsResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [AutoCompleteBrandDTO]
    let timestamp: String
}

struct AutoCompleteBrandDTO: Decodable {
    let keyword :String
    let imageUrl: String
}
