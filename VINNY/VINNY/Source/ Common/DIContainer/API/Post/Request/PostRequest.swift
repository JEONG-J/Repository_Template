//
//  PostRequest.swift
//  VINNY
//
//  Created by 소민준 on 8/15/25.
//

import Foundation

struct UpdatePostRequestDTO: Encodable {
    let title: String
    let content: String
    let styleIds: [Int]?    // optional so we can omit when unchanged
    let brandIds: [Int]?    // optional so we can omit when unchanged
    let shopId: Int?
}
