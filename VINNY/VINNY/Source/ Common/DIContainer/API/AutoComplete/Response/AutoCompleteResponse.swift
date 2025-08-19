//
//  AutoCompleteResponse.swift
//  VINNY
//
//  Created by 소민준 on 8/18/25.
//

import Foundation

struct AutoCompleteShopsResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [String]
    let timestamp: String
}

// 브랜드 자동완성 
struct AutoCompleteBrandsResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [String]
    let timestamp: String
}
