//
//  PostRequest.swift
//  VINNY
//
//  Created by 소민준 on 8/15/25.
//

import Foundation

struct CreatePostRequestDTO: Encodable {
    let title: String
    let content: String
    let brandNames: [String]
    let styleNames: [String]
    let shopName: String
}

struct UpdatePostRequestDTO: Encodable {
    let title: String
    let content: String
    let styleNames: [String]?
    let brandNames: [String]?
    let shopName: String?
}

