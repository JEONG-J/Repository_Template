//
//  HomeResponse.swift
//  VINNY
//
//  Created by 소민준 on 8/15/25.
//

import Foundation

// MARK: - Home For-You Shops (GET /api/home/shops/for-you)
struct ForYouShopDTO: Decodable, Hashable {
    let id: Int
    let name: String
    let openTime: String?
    let closeTime: String?
    let instagram: String?
    let address: String?
    let images: ForYouImageDTO?
    let shopVintageStyleList: [ForYouVintageStyleDTO]?
}

struct ForYouImageDTO: Decodable, Hashable {
    let url: String?
    let main: Bool?
}

struct ForYouVintageStyleDTO: Decodable, Hashable {
    let id: Int
    let vintageStyleName: String
}
