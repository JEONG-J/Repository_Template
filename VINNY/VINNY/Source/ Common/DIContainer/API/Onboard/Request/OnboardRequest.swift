//
//  OnboardRequest.swift
//  VINNY
//
//  Created by 소민준 on 8/9/25.
//


import Foundation

/// 온보딩 전송 요청 DTO
struct OnboardRequestDTO: Encodable {
    let vintageStyleIds: [Int]   // 최소 1, 최대 3
    let brandIds: [Int]          // 최소 1, 최대 5
    let vintageItemIds: [Int]    // 최소 1, 최대 3
    let regionIds: [Int]         // 최소 1, 최대 3
}
