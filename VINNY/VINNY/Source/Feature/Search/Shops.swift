//
//  Shop.swift
//  VINNY
//
//  Created by 소민준 on 7/19/25.
//
import SwiftUI

struct Shops: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let tags: [String]
    static let dummyList: [Shops] = [
        Shops(name: "망원빈티지", address: "서울특별시 마포구 망원동 376-6", tags : ["지역", "스트릿", "데님"]),
        Shops(name: "홍대빈티지", address: "서울 마포구 와우산로 21길 16", tags : ["캐쥬얼", "빈티지", "아메카지"]),
    ]
}


extension Shops {
    init(from dto: ShopSearchResultDTO) {
        self.init(
            name: dto.name,
            address: dto.address ,
            tags: dto.styles
        )
    }
}
